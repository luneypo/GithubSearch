module Types
  class UserType < Types::BaseObject
    field :login, String, null: false
    field :language, String, null: true
    field :number_repos, String, null: true
    field :repos, [Types::RepoType], null:true
  end

  def repos
    object.repos
  end
end