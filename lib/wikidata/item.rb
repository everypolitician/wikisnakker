require "wikidata/item/version"

require 'colorize'
require 'pry'
require 'open-uri/cached'
require 'json'

class WikiData

  class Lookup

    def initialize(ids)
      @_hash = ids.compact.uniq.each_slice(50).map { |sliced|
        page_args = { 
          action: 'wbgetentities',
          ids: sliced.join("|"),
          format: 'json',
        }
        url = 'https://www.wikidata.org/w/api.php?' + URI.encode_www_form(page_args)
        # warn "Fetching #{url}"
        json = JSON.parse(open(url).read)
        json['entities']
      }.reduce(&:merge)
    end

    def all
      @_hash.values
    end

  end

  class Item < WikiData

    def self.find(ids)
      _ids = [ids].flatten
      data = Lookup.new(_ids).all
      inflated = data.map { |rd| self.new(rd) }
      _ids.size == 1 ? inflated.first : inflated
    end

    def initialize(raw)
      @_raw = raw
    end

    def method_missing(name)
      handle = name.to_s.upcase.match(/P(\d+)(S?)/) or return
      pid, wantarray = handle.captures
      res = p(pid)
      wantarray.empty? ? p(pid).first : p(pid)
    end
      
    def id
      @_raw['title']
    end

    def _raw
      @_raw
    end

    def labels
      @_raw['labels']
    end

    def label(lang)
      labels[lang]['value']
    end

    def p(pid)
      (@_raw['claims']["P#{pid}"] || []).map { |c| Claim.new(c) }
    end

  end

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
      @_mainsnak ||= Snak.new( @data["mainsnak"] )
    end

  end

  class Snak

    def initialize(snak)
      @snak = snak
    end

    def value
      case @snak['datatype']
      when 'wikibase-item'
        "Q%s" % @snak["datavalue"]["value"]["numeric-id"]
      when 'time'
        case @snak["datavalue"]["value"]["precision"]
        when 11
          @snak["datavalue"]["value"]["time"][1..10]
        else
          binding.pry
        end
      else
        warn "Unknown datatype: #{@snak['datatype']}"
        binding.pry
      end
    end
  end
end
