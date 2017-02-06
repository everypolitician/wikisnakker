module Wikisnakker
  class Qualifiers
    attr_reader :snaks
    attr_reader :properties

    def initialize(qualifier_snaks)
      qualifier_snaks ||= {}
      @properties = qualifier_snaks.keys
      qualifier_snaks.each do |property_id, snaks|
        define_property_method "#{property_id}s".to_sym do
          snaks.map { |s| Snak.new(s) }
        end

        define_property_method property_id do
          __send__("#{property_id}s").first
        end
      end
    end

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
