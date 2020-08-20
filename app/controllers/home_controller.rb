class HomeController < ApplicationController

  before_action :load_history
  before_action :load_client

  def index
  end


  def search
    response = helpers.query_search(params[:search][:name],@client)
    @result = response.data.search.nodes.count
    @users = response.data.search.nodes
  end

  def profile
    response = helpers.query_profile(params[:name],@client)
    @language = ''
    @login = params[:name]
    @repos = response.data.user.repositories.nodes
    @total = response.data.user.repositories.total_count
    helpers.get_top_language_use(@repos).each do |l|
      @language += "#{l[0]} "
    end
    user = User.find_or_initialize_by(login: params[:name])
    user.language = @language
    user.number_repos = @total
    user.save
    @repos.each do |r|
      repo = Repo.find_or_initialize_by(name:r.name)
      lang=''
      r.languages.nodes.each do |l|
        lang += "#{l.name} "
      end
      repo.language = lang
      repo.user_id = user.id
      repo.save
    end
  end

  def repo
    @login = params[:name]
    @repo = params[:repo]
    @contribution = helpers.get_contribution(@repo,@login)
  end

  def history
    user = User.find_by_login(params[:login])
    @login = user.login
    @repos = user.repos
    @total = user.number_repos
    @language = user.language
    render 'profile'
  end
  def delete_history
    Repo.delete_all
    User.delete_all
    redirect_to root_path
  end

  private

  def load_history
    @histories=User.all
  end

  def load_client

    if @client.nil?
      @client = helpers.connect
    end
  end
end
