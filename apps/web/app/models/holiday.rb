class Holiday < ApplicationRecord
  validates :title, :slug, :month, :day, presence: true
  validates :slug, uniqueness: true, format: { with: /\A[a-z0-9\-]+\z/ }
  validates :month, inclusion: { in: 1..12 }
  validates :day, inclusion: { in: 1..31 }

  scope :published, -> { where(published: true) }

  def next_occurrence
    candidate = Date.new(Date.today.year, month, day)
    candidate = candidate.next_year if candidate <= Date.today
    candidate
  end

  def time_until
    DateCalculations::TimeUntilCalculator.new(reference_date: next_occurrence).call
  end
end
