module Wikisnakker
  class Item
    def self.find(ids)
      lookup = Lookup.find(ids)
      data = lookup.values.reject { |d| d[:missing] == '' }
      inflated = data.map { |rd| new(rd) }
      ids.is_a?(Array) ? inflated : inflated.first
    end

    def initialize(raw)
      @raw = raw
    end

    PROPERTY_REGEX = /^(P\d+)(s?)$/

    def method_missing(method_name, *arguments, &block)
      pid, plural = method_name.to_s.scan(PROPERTY_REGEX).flatten
      return super unless pid
      plural.empty? ? first_property(pid) : property(pid)
    end

    def respond_to_missing?(method_name, include_private = false)
      method_name.to_s.match(PROPERTY_REGEX) || super
    end

    def [](key)
      __send__(key)
    end

    def property(pid)
      # A claim's rank can be either preferred, normal or deprecated. We sort them by
      # rank in reverse order because lexicographic ordering happens to work for the
      # known ranks.
      raw[:claims][pid.to_sym].to_a.map { |c| Claim.new(c) }.group_by(&:rank).sort.reverse.map(&:last).flatten
    end

    def first_property(pid)
      property(pid).first
    end

    def id
      raw[:id]
    end

    def labels
      raw[:labels]
    end

    def descriptions
      raw[:descriptions] || {}
    end

    def all_aliases
      raw[:aliases]
    end

    def properties
      raw[:claims].keys
    end

    def sitelinks
      Hash[raw[:sitelinks].map do |key, value|
        [key.to_sym, Sitelink.new(value)]
      end]
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

    private

    attr_reader :raw
  end
end
