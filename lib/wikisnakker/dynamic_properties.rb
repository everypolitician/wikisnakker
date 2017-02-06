module Wikisnakker
  module DynamicProperties
    PROPERTY_REGEX = /^P\d+s?$/

    def method_missing(method_name, *arguments, &block)
      return super unless method_name.to_s.match(PROPERTY_REGEX)
      method_name[-1] == 's' ? [] : nil
    end

    def respond_to_missing?(method_name, include_private = false)
      method_name.to_s.match(PROPERTY_REGEX) || super
    end

    def define_property_method(property, &block)
      define_singleton_method(property.to_sym, &block)
    end

    def [](key)
      __send__(key)
    end
  end
end
