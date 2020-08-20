module Types
  class RepoType < Types::BaseObject
    field :name, String, null: false
    field :language, String, null: true
    field :user_id, ID, null: false
  end
end