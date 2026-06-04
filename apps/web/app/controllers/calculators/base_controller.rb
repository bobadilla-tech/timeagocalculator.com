module Calculators
  class BaseController < ApplicationController
    include SeoMetaTaggable

    private

    def parse_date(param)
      Date.parse(params[param].to_s)
    rescue ArgumentError, TypeError
      nil
    end
  end
end
