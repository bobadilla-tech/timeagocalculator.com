class Event < ApplicationRecord
  validates :title, :slug, :starts_at, presence: true
  validates :slug, uniqueness: true, format: { with: /\A[a-z0-9\-]+\z/ }

  scope :published, -> { where(published: true) }
  scope :by_category, ->(cat) { where(category: cat) }

  def time_ago
    DateCalculations::TimeAgoCalculator.new(reference_date: starts_at).call
  end
end
