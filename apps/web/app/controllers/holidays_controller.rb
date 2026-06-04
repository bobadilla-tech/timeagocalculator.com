class HolidaysController < ApplicationController
  include SeoMetaTaggable

  def show
    @holiday = Holiday.published.find_by!(slug: params[:slug])
    @result  = @holiday.time_until

    set_meta_tags(
      title: "How Long Until #{@holiday.title}? #{Date.today.year} Countdown",
      description: "Live countdown to #{@holiday.title}. #{@result.days} days, #{@result.months} months to go.",
      canonical: countdown_url(@holiday.slug)
    )

    @schema = Seo::StructuredDataBuilder.web_application(
      name: "#{@holiday.title} Countdown",
      url: countdown_url(@holiday.slug),
      description: "How long until #{@holiday.title}? Live updating countdown timer."
    )
  end
end
