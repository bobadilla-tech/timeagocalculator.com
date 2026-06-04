class Event < ApplicationRecord
  RECURRENCES = %w[one_time annual].freeze
  CATEGORIES  = %w[sports holidays cultural entertainment awareness religious seasonal financial academic patriotic].freeze

  validates :title, :slug, :starts_at, presence: true
  validates :slug, uniqueness: true, format: { with: /\A[a-z0-9\-]+\z/ }
  validates :recurrence, inclusion: { in: RECURRENCES }

  scope :published,       -> { where(published: true) }
  scope :featured,        -> { where(featured: true) }
  scope :upcoming,        -> { where("starts_at > ?", Time.current) }
  scope :past,            -> { where("starts_at <= ?", Time.current) }
  scope :sorted_upcoming, -> { upcoming.order(starts_at: :asc) }
  scope :sorted_past,     -> { past.order(starts_at: :desc) }
  scope :by_category,     ->(cat) { where(category: cat) }
  scope :for_region,      ->(code) { where("? = ANY(country_codes)", code) }

  def upcoming?
    starts_at > Time.current
  end

  def days_until
    return nil unless upcoming?
    (local_starts_date - local_today).to_i
  end

  def weeks_until
    return nil unless upcoming?
    (days_until / 7.0).ceil
  end

  def days_since
    return nil if upcoming?
    (local_today - local_starts_date).to_i
  end

  def time_ago
    DateCalculations::TimeAgoCalculator.new(reference_date: starts_at).call
  end

  def faq
    date_str = local_starts_date.strftime("%B %-d, %Y")
    day_name = local_starts_date.strftime("%A")

    if upcoming?
      days  = days_until
      weeks = weeks_until
      [
        { q: "How many days until #{title}?",
          a: "There are #{days} #{"day".pluralize(days)} until #{title} on #{day_name}, #{date_str}." },
        { q: "How many weeks until #{title}?",
          a: "There are approximately #{weeks} #{"week".pluralize(weeks)} until #{title}." },
        { q: "What day of the week is #{title}?",
          a: "#{title} falls on #{day_name}, #{date_str}." }
      ]
    else
      result  = time_ago
      d_since = days_since
      [
        { q: "How long ago was #{title}?",
          a: "#{title} was #{result&.human || "a historical event"}, on #{day_name}, #{date_str}." },
        { q: "How many days ago was #{title}?",
          a: "#{title} was #{d_since} #{"day".pluralize(d_since)} ago, on #{date_str}." },
        { q: "What day did #{title} happen?",
          a: "#{title} occurred on #{day_name}, #{date_str}." }
      ]
    end
  end

  private

  # Today's date in the event's local timezone (falls back to UTC)
  def local_today
    return Date.current unless timezone.present?
    Time.current.in_time_zone(timezone).to_date
  end

  # The event's start date in its own local timezone
  def local_starts_date
    return starts_at.to_date unless timezone.present?
    starts_at.in_time_zone(timezone).to_date
  end
end
