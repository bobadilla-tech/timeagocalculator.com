class BusinessDaysCalculation < ApplicationRecord
  belongs_to :user, optional: true

  before_validation :generate_token, on: :create
  validates :token, :mode, :from_date, :result_days, presence: true
  validates :token, uniqueness: true

  def owned_by?(user)
    user.present? && self.user_id == user.id
  end

  private

  def generate_token
    loop do
      self.token = SecureRandom.urlsafe_base64(8)
      break unless BusinessDaysCalculation.exists?(token:)
    end
  end
end
