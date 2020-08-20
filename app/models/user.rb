class User < ApplicationRecord
  has_many :repos, dependent: :destroy
end
