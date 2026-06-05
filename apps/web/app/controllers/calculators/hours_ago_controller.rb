module Calculators
  class HoursAgoController < BaseController
    def show
      set_meta_tags(
        title: "Hours Ago Calculator",
        description: "Calculate what time it was X hours ago from a given time.",
        canonical: hours_ago_calculator_url
      )

      @schema = Seo::StructuredDataBuilder.web_application(
        name: "Hours Ago Calculator",
        url: hours_ago_calculator_url,
        description: "Calculate what time it was X hours ago from a given time."
      )

      # Provide server baseline time for client-side calculations
      @now = Time.zone.now
    end
  end
end
