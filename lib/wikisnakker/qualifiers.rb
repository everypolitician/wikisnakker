module Wikisnakker
  class Qualifiers
    include DynamicProperties

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
  end
end
