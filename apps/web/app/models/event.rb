class Event < ApplicationRecord
  RECURRENCES = %w[one_time annual].freeze
  CATEGORIES  = %w[sports holidays cultural entertainment awareness religious seasonal financial academic patriotic historical birthdays economic artists].freeze

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

  def total_weeks_until
    return nil unless upcoming?
    (days_until / 7.0).floor
  end

  def total_months_until
    return nil unless upcoming?
    ((starts_at - Time.current) / 1.month).floor
  end

  def total_hours_until
    return nil unless upcoming?
    ((starts_at - Time.current) / 1.hour).floor
  end

  def total_minutes_until
    return nil unless upcoming?
    ((starts_at - Time.current) / 1.minute).floor
  end

  def total_seconds_until
    return nil unless upcoming?
    (starts_at - Time.current).floor
  end

  def weekdays_until
    return nil unless upcoming?
    d0    = local_today
    total = days_until
    full_weeks, rem = total.divmod(7)
    count = full_weeks * 5
    rem.times { |i| wd = (d0 + i + 1).wday; count += 1 unless wd == 0 || wd == 6 }
    count
  end

  def weekends_until
    return nil unless upcoming?
    d0    = local_today
    total = days_until
    full_weeks, rem = total.divmod(7)
    count = full_weeks
    rem.times { |i| count += 1 if (d0 + i + 1).wday == 6 }
    count
  end

  def time_ago
    DateCalculations::TimeAgoCalculator.new(reference_date: starts_at).call
  end

  def time_until
    return nil unless upcoming?
    result = DateCalculations::TimeUntilCalculator.new(reference_date: starts_at).call
    # Override target_timestamp_ms with starts_at UTC directly —
    # the base calculator converts to date then back to time (loses TZ precision)
    result.with(target_timestamp_ms: starts_at.to_i * 1000)
  end

  def faq
    date_str = local_starts_date.strftime("%B %-d, %Y")
    day_name = local_starts_date.strftime("%A")

    if upcoming?
      days    = days_until
      weeks   = total_weeks_until
      months  = total_months_until
      hours   = total_hours_until
      minutes = total_minutes_until
      secs    = total_seconds_until
      wdays   = weekdays_until
      wends   = weekends_until
      [
        { q: "How many months until #{title}?",
          a: "There #{months == 1 ? "is" : "are"} #{months} #{"month".pluralize(months)} until #{title} on #{day_name}, #{date_str}." },
        { q: "How many weeks until #{title}?",
          a: "There #{weeks == 1 ? "is" : "are"} #{weeks} #{"week".pluralize(weeks)} until #{title}." },
        { q: "How many days until #{title}?",
          a: "There are #{days} #{"day".pluralize(days)} until #{title} on #{day_name}, #{date_str}." },
        { q: "How many hours until #{title}?",
          a: "There are #{ActionController::Base.helpers.number_with_delimiter(hours)} hours until #{title}." },
        { q: "How many minutes until #{title}?",
          a: "There are #{ActionController::Base.helpers.number_with_delimiter(minutes)} minutes until #{title}." },
        { q: "How many seconds until #{title}?",
          a: "There are #{ActionController::Base.helpers.number_with_delimiter(secs)} seconds until #{title}." },
        { q: "How many week days until #{title}?",
          a: "There are #{wdays} week #{"day".pluralize(wdays)} until #{title}." },
        { q: "How many weekends until #{title}?",
          a: "There #{wends == 1 ? "is" : "are"} #{wends} #{"weekend".pluralize(wends)} until #{title}." },
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
