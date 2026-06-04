class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :identities, dependent: :destroy
  has_many :countdowns, dependent: :nullify
  has_many :countdown_favorites, dependent: :destroy
  has_many :favorited_countdowns, through: :countdown_favorites, source: :countdown
  has_many :business_days_calculations, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }
  normalizes :username, with: ->(u) { u.strip.downcase }

  validates :email_address, presence: true, uniqueness: { case_sensitive: false }
  validates :username, uniqueness: { case_sensitive: false },
                       format: { with: /\A[a-z0-9_]+\z/, message: "only letters, numbers, underscores" },
                       length: { maximum: 30 },
                       allow_nil: true
end
