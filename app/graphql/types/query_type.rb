module Types
  class QueryType < Types::BaseObject

    include HomeHelper

    field :search, [String], null: false, description: "Search an user"do
      argument :name, String, required: true
    end

    field :profile ,Types::UserType,null: false, description: "get a profile"do
      argument :name, String, required: true
    end

    field :histories ,[Types::UserType],null: false, description: "get histories (previously seen profile)"

    field :history ,Types::UserType,null: false, description: "get an already seen profile"do
      argument :name, String, required: true
    end

    field :repo_history ,Types::RepoType,null: false, description: "get an already seen repo"do
      argument :repo, String, required: true
      argument :login, String, required: true
    end

    field :get_contrib ,String,null: false, description: "get contribution from a user on a repo"do
      argument :repo, String, required: true
      argument :login, String, required: true
    end

    def search(name:)
      client = connect
      results = []
      query_search(name,client).data.search.nodes.each do |o|
        results << o.login unless o.id.length > 25
      end
      results
    end

    def profile(name:)
      client = connect
      response = query_profile(name,client)
      language = ''
      repos = response.data.user.repositories.nodes
      get_top_language_use(repos).each do |l|
        language += "#{l[0]} "
      end
      user = User.find_or_initialize_by(login: name)
      user.language = language
      user.number_repos = response.data.user.repositories.total_count
      user.save
      repos.each do |r|
        repo = Repo.find_or_initialize_by(name:r.name)
        lang=''
        r.languages.nodes.each do |l|
          lang += "#{l.name} "
        end
        repo.language = lang
        repo.user_id = user.id
        repo.save
      end
      user
    end

    def histories
      User.all
    end

    def history(name:)
      User.find_by_login(name)
    end

    def repo_history(login:,repo:)
      User.find_by_login(login).repos.where(name:repo).first
    end

    def get_contrib(login:,repo:)
      contrib = get_contribution(repo,login)
      if contrib['message']
        "No info"
      else
        "Contribution: #{contrib['contribution']}, #{contrib['stats_contrib']}% Rank: #{contrib['rank']}"
      end
    end
  end
end
