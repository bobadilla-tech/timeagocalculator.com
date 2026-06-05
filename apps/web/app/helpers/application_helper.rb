module ApplicationHelper
  CATEGORY_EMOJIS = {
    "sports"        => "🏆",
    "holidays"      => "🎉",
    "cultural"      => "🌍",
    "entertainment" => "🎬",
    "awareness"     => "🎗️",
    "religious"     => "✝️",
    "seasonal"      => "🌸",
    "financial"     => "💰",
    "academic"      => "🎓",
    "patriotic"     => "🏴",
    "historical"    => "📜",
    "birthdays"     => "🎂",
    "economic"      => "📈",
    "artists"       => "🎵"
  }.freeze

  def category_emoji(category)
    CATEGORY_EMOJIS[category.to_s] || "📅"
  end
end
