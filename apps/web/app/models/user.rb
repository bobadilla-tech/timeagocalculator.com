class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :identities, dependent: :destroy
  has_many :countdowns, dependent: :nullify
  has_many :countdown_favorites, dependent: :destroy
  has_many :favorited_countdowns, through: :countdown_favorites, source: :countdown

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true, uniqueness: { case_sensitive: false }
end
