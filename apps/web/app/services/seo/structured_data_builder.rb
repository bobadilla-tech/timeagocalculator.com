module Seo
  class StructuredDataBuilder
    def self.web_application(name:, url:, description:)
      {
        "@context" => "https://schema.org",
        "@type" => "WebApplication",
        "name" => name,
        "url" => url,
        "description" => description,
        "applicationCategory" => "UtilitiesApplication",
        "operatingSystem" => "Web"
      }
    end

    def self.event(name:, start_date:, description:, url:)
      {
        "@context" => "https://schema.org",
        "@type" => "Event",
        "name" => name,
        "startDate" => start_date.iso8601,
        "description" => description,
        "url" => url
      }
    end

    def self.faq(pairs)
      {
        "@context" => "https://schema.org",
        "@type" => "FAQPage",
        "mainEntity" => pairs.map do |q, a|
          {
            "@type" => "Question",
            "name" => q,
            "acceptedAnswer" => { "@type" => "Answer", "text" => a }
          }
        end
      }
    end

    def self.breadcrumb(items)
      {
        "@context" => "https://schema.org",
        "@type" => "BreadcrumbList",
        "itemListElement" => items.each_with_index.map do |(name, url), i|
          { "@type" => "ListItem", "position" => i + 1, "name" => name, "item" => url }
        end
      }
    end

    def self.howto(name:, description:, steps:)
      {
        "@context" => "https://schema.org",
        "@type" => "HowTo",
        "name" => name,
        "description" => description,
        "step" => steps.map.with_index(1) do |s, i|
          {
            "@type" => "HowToStep",
            "name" => s[:name] || "Step #{i}",
            "text" => s[:text]
          }
        end
      }
    end
  end
end
