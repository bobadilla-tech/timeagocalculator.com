class WidgetsController < ApplicationController
  include SeoMetaTaggable

  FONTS = [
    [ "System (default)", "system" ],
    [ "Space Grotesk",    "Space Grotesk" ],
    [ "Inter",            "Inter" ],
    [ "Roboto",           "Roboto" ],
    [ "Georgia",          "Georgia" ]
  ].freeze

  FONT_NAMES = FONTS.map(&:last).freeze

  SHADOW_MAP = {
    "none"   => "none",
    "soft"   => "0 2px 8px rgba(0,0,0,0.15)",
    "medium" => "0 4px 16px rgba(0,0,0,0.25)",
    "strong" => "0 8px 32px rgba(0,0,0,0.45)"
  }.freeze

  def builder
    set_meta_tags(
      title: "Countdown Widget Builder — Free Embeddable Countdown Timer",
      description: "Create a free custom countdown widget for your website in minutes. Customize colors, fonts, and layout. Get an embed code to paste anywhere.",
      canonical: countdown_widget_builder_url
    )
    @schema = Seo::StructuredDataBuilder.web_application(
      name: "Countdown Widget Builder",
      url: countdown_widget_builder_url,
      description: "Build and embed a custom countdown timer widget for any website."
    )
    @fonts     = FONTS
    @timezones = ActiveSupport::TimeZone.all.map { |z| [ "#{z}", z.tzinfo.identifier ] }
  end

  def countdown
    render layout: "widget"
  end
end
