module Wikisnakker
  class Claim
    def initialize(data)
      @data = data
    end

    def value
      mainsnak.value
    end

    def to_s
      mainsnak.value
    end

    def mainsnak
      @_mainsnak ||= Snak.new(@data[:mainsnak])
    end

    def qualifiers
      Qualifiers.new(@data[:qualifiers])
    end

    def rank
      @data[:rank]
    end
  end
end
