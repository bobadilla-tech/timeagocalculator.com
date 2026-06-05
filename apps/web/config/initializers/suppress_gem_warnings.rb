module Warning
  class << self
    alias_method :_original_warn, :warn

    def warn(msg, category: nil, **)
      return if msg.to_s.include?("ActiveSupport::Configurable is deprecated")
      _original_warn(msg, category: category)
    end
  end
end
