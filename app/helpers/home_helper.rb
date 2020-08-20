module HomeHelper

  def connect
    token = ENV["github_access_token"]
    Graphlient::Client.new('https://api.github.com/graphql',
                           headers: {
                               'Authorization' => "Bearer #{token}"
                           }
    )
  end

  def get_contribution(repo_name,dev_name)
    response = HTTParty.get("http://api.github.com/repos/#{dev_name}/#{repo_name}/contributors")
    if response.key?('message')
      return response
    end
    total_contribution = 0
    contribution = 0
    ranking = {}
    rank = "unranked"
    result = {}

    response.each do |r|
      if r["login"].eql? dev_name
        contribution = r["contributions"]
      end
      ranking[r["login"]] = r["contributions"]
      total_contribution += r["contributions"]
    end

    ranking.sort_by {|_, v| -v}.first(10)
    if ranking.key?(dev_name)
      rank = ranking.find_index { |k,_| k.eql?(dev_name) } + 1
    end

    result['rank'] = rank
    result["contribution"] = contribution.to_i
    result['stats_contrib'] = (contribution.fdiv(total_contribution)*100).round unless contribution.eql? 0
    result
  end


  def get_top_language_use(repos)
    lang = {}
    repos.each do |r|
      if lang.empty?
        r.languages.nodes.each do |l|
          lang[l.name]=1
        end
      else
        r.languages.nodes.each do |l|
          if lang.key?(l.name)
            lang[l.name] += 1
          else
            lang[l.name] = 1
          end
        end
      end
    end
    lang.sort_by {|k, v| -v}.first(3)
  end

  def query_profile(name,client)
    query = client.parse <<~GRAPHQL
      query($name: String!) {
        user(login: $name) {
          repositories(first: 100, privacy: PUBLIC) {
            totalCount
            nodes {
              name
              languages(first: 10) {
                nodes {
                  name
                }
                totalSize
              }
            }
          }
        }
      }
    GRAPHQL
    client.execute query, name: name
  end

  def query_search(name,client)
    query = client.parse <<~GRAPHQL
      query($name: String!) {
        search(query: $name, type: USER, first: 100) {
          nodes {
            ... on User {
              login
              id
            }
            ... on Organization {
              id
            }
          }
        }
      }
    GRAPHQL
    client.execute query, name: name
  end
end
