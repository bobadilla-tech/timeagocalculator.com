class Countdown < ApplicationRecord
  has_secure_password validations: false

  belongs_to :user, optional: true

  validates :title, :token, :target_date, presence: true
  validates :token, uniqueness: true
  validates :password, presence: true, if: -> { !is_public? }
  validates :password_confirmation, presence: true, if: -> { !is_public? && password.present? }

  before_validation :generate_token, on: :create

  def owned_by?(user)
    user.present? && self.user_id == user.id
  end

  def editable_by?(user)
    owned_by?(user) && !locked?
  end

  def time_until
    DateCalculations::TimeUntilCalculator.new(reference_date: target_date).call
  end

  private

  def generate_token
    loop do
      self.token = SecureRandom.urlsafe_base64(8)
      break unless Countdown.exists?(token: token)
    end
  end
end
