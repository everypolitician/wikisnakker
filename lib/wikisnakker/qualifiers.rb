module Wikisnakker
  class Qualifiers
    def initialize(qualifier_snaks)
      @qualifier_snaks = qualifier_snaks || {}
    end

    def properties
      qualifier_snaks.keys
    end

    def [](key)
      __send__(key)
    end

    PROPERTY_REGEX = /^(P\d+)(s?)$/

    def method_missing(method_name, *arguments, &block)
      pid, plural = method_name.to_s.scan(PROPERTY_REGEX).flatten
      return super unless pid
      plural.empty? ? first_snak(pid) : snak(pid)
    end

    def respond_to_missing?(method_name, include_private = false)
      method_name.to_s.match(PROPERTY_REGEX) || super
    end

    private

    def snak(pid)
      qualifier_snaks[pid.to_sym].to_a.map { |c| Snak.new(c) }
    end

    def first_snak(pid)
      snak(pid).first
    end

    attr_reader :qualifier_snaks
  end
end
