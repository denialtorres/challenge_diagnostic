class User < ApplicationRecord
  has_secure_password validations: true
  has_many :sessions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :password, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }
end
