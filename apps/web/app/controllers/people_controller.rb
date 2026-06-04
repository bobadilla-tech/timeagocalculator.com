PEOPLE = {
  "tom-cruise"    => { name: "Tom Cruise",    birthdate: Date.new(1962, 7, 3) },
  "taylor-swift"  => { name: "Taylor Swift",  birthdate: Date.new(1989, 12, 13) },
  "elon-musk"     => { name: "Elon Musk",     birthdate: Date.new(1971, 6, 28) },
  "mrbeast"       => { name: "MrBeast",       birthdate: Date.new(1998, 5, 7) },
  "lebron-james"  => { name: "LeBron James",  birthdate: Date.new(1984, 12, 30) },
  "beyonce"       => { name: "Beyoncé",       birthdate: Date.new(1981, 9, 4) },
  "dwayne-johnson"=> { name: "Dwayne Johnson", birthdate: Date.new(1972, 5, 2) },
  "rihanna"       => { name: "Rihanna",       birthdate: Date.new(1988, 2, 20) }
}.freeze

class PeopleController < ApplicationController
  include SeoMetaTaggable

  def show
    person = PEOPLE[params[:slug]]
    return render plain: "Not Found", status: :not_found if person.nil?

    @name   = person[:name]
    @result = DateCalculations::AgeCalculator.new(reference_date: person[:birthdate]).call

    set_meta_tags(
      title: "How Old Is #{@name}? Age in #{Date.today.year}",
      description: "#{@name} is #{@result.years} years old as of #{Date.today.year}. Born #{person[:birthdate].strftime("%B %-d, %Y")}.",
      canonical: age_page_url(params[:slug])
    )

    @schema = Seo::StructuredDataBuilder.web_application(
      name: "How Old Is #{@name}?",
      url: age_page_url(params[:slug]),
      description: "#{@name} age calculator — how old is #{@name} in #{Date.today.year}?"
    )
  end
end
