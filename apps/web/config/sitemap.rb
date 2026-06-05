SitemapGenerator::Sitemap.default_host = "https://timeagocalculator.com"
SitemapGenerator::Sitemap.sitemaps_path = "sitemaps/"
SitemapGenerator::Sitemap.create_index = true

SitemapGenerator::Sitemap.create do
  add "/time-ago-calculator",        changefreq: "monthly", priority: 0.9
  add "/time-until-calculator",      changefreq: "monthly", priority: 0.9
  add "/date-difference-calculator", changefreq: "monthly", priority: 0.9
  add "/age-calculator",             changefreq: "monthly", priority: 0.9
  add "/date-calculator",           changefreq: "monthly", priority: 0.8

  Event.published.find_each do |event|
    add "/how-long-ago/#{event.slug}", changefreq: "yearly", priority: 0.7,
        lastmod: event.updated_at
  end

  Holiday.where(published: true).find_each do |holiday|
    add "/countdown/#{holiday.slug}", changefreq: "monthly", priority: 0.8,
        lastmod: holiday.updated_at
  end
end
