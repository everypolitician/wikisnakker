module Wikisnakker
  class Item
    include DynamicProperties

    def self.find(ids)
      lookup = Lookup.find(ids)
      data = lookup.values.reject { |d| d[:missing] == '' }
      inflated = data.map { |rd| new(rd) }
      ids.is_a?(Array) ? inflated : inflated.first
    end

    attr_reader :id
    attr_reader :labels
    attr_reader :descriptions
    attr_reader :properties
    attr_reader :sitelinks
    attr_reader :all_aliases

    def initialize(raw)
      @id = raw[:title]
      @labels = raw[:labels]
      @descriptions = raw[:descriptions] || {}
      @all_aliases = raw[:aliases]
      @properties = raw[:claims].keys
      @sitelinks = Hash[raw[:sitelinks].map do |key, value|
        [key.to_sym, Sitelink.new(value)]
      end]
      raw[:claims].each do |property_id, claims|
        define_property_method "#{property_id}s".to_sym do
          # A claim's rank can be either preferred, normal or deprecated. We sort them by
          # rank in reverse order because lexicographic ordering happens to work for the
          # known ranks.
          claims.map { |c| Claim.new(c) }.group_by(&:rank).sort.reverse.map(&:last).flatten
        end

        define_property_method property_id do
          __send__("#{property_id}s").first
        end
      end
    end

    # TODO: have an option that defaults to a different language
    def to_s
      labels.key?(:en) ? labels[:en][:value] : @id
    end

    def label(lang)
      return nil unless labels.key?(lang.to_sym)
      labels[lang.to_sym][:value]
    end

    def description(lang)
      return nil unless descriptions.key?(lang.to_sym)
      descriptions[lang.to_sym][:value]
    end

    def aliases(lang)
      return [] unless all_aliases.key?(lang.to_sym)
      all_aliases[lang.to_sym].map { |a| a[:value] }
    end
  end
end
