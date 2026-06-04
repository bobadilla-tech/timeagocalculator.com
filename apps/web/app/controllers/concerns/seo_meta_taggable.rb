module SeoMetaTaggable
  extend ActiveSupport::Concern

  included do
    before_action :set_default_meta_tags
  end

  private

  def set_default_meta_tags
    set_meta_tags(
      site: "Time Ago Calculator",
      separator: "—",
      og: {
        site_name: "timeagocalculator.com",
        type: "website"
      },
      twitter: {
        card: "summary_large_image"
      }
    )
  end
end
