class Session < ApplicationRecord
  has_secure_token :token
  belongs_to :user
end
