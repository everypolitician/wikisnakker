require 'wikisnakker/version'

require 'digest/md5'
require 'pry'
require 'open-uri'
require 'json'
require 'set'

module Wikisnakker
  class Lookup
    def self.find(ids)
      lookup = new(ids)
      property_lookup = new(lookup.properties)
      lookup.populate_with(property_lookup)
      lookup
    end

    def initialize(*ids)
      ids = ids.flatten.compact.uniq
      @used_props = Set.new
      entities = ids.each_slice(50).map do |id_slice|
        get(id_slice)['entities']
      end
      @entities = entities.reduce(&:merge)
    end

    def properties
      @used_props.to_a.map { |e| "Q#{e}" }
    end

    def values
      @values ||= @entities.values
    end

    def [](key)
      @entities[key]
    end

    def populate_with(properties)
      each_wikibase_entitiyid(@entities) do |entityid|
        entityid['value'] = properties["Q#{entityid['value']['numeric-id']}"]
      end
    end

    private

    def get(*ids)
      query = {
        action: 'wbgetentities',
        ids: ids.flatten.join('|'),
        format: 'json'
      }
      url = 'https://www.wikidata.org/w/api.php?' + URI.encode_www_form(query)
      json = JSON.parse(open(url).read)
      save_wikibase_entityids(json)
      json
    end

    # If a property is set to another Wikidata article, resolve that
    # (e.g. set 'gender' to 'male' rather than 'Q6581097')
    # We don't know yet what that will resolve to, and we don't want
    # to look them up one by one, so keep track of any entity ids we
    # encounter and then resolve them later in '#populate_with'.
    def save_wikibase_entityids(json)
      each_wikibase_entitiyid(json) do |entityid|
        @used_props << entityid['value']['numeric-id']
      end
    end

    def each_wikibase_entitiyid(obj)
      recurse_proc(obj) do |result|
        next unless result.is_a?(Hash) && result['type'] == 'wikibase-entityid'
        yield(result)
      end
    end

    # Recursively calls passed _Proc_ if the parsed data structure is an _Array_ or _Hash_
    # Taken from the json gem.
    # @see http://git.io/v4Tf7
    def recurse_proc(result, &proc)
      case result
      when Array
        result.each { |x| recurse_proc x, &proc }
        proc.call result
      when Hash
        result.each do |x, y|
          recurse_proc x, &proc
          recurse_proc y, &proc
        end
        proc.call result
      else
        proc.call result
      end
    end
  end

  module DynamicProperties
    PROPERTY_REGEX = /^P\d+s?$/

    def method_missing(method_name, *arguments, &block)
      return super unless method_name.to_s.match(PROPERTY_REGEX)
      method_name[-1] == 's' ? [] : nil
    end

    def respond_to_missing?(method_name, include_private = false)
      method_name.to_s.match(PROPERTY_REGEX) || super
    end

    def property(property, &block)
      define_singleton_method(property.to_sym, &block)
    end

    def [](key)
      __send__(key)
    end
  end

  class Item
    include DynamicProperties

    def self.find(ids)
      lookup = Lookup.find(ids)
      data = lookup.values
      inflated = data.map { |rd| new(rd) }
      ids.is_a?(Array) ? inflated : inflated.first
    end

    attr_reader :id
    attr_reader :labels
    attr_reader :properties
    attr_reader :sitelinks

    def initialize(raw)
      @id = raw['title']
      @labels = raw['labels']
      @properties = raw['claims'].keys
      @sitelinks = Hash[raw['sitelinks'].map do |key, value|
        [key, Sitelink.new(value)]
      end]
      raw['claims'].each do |property_id, claims|
        property "#{property_id}s".to_sym do
          claims.map { |c| Claim.new(c) }
        end

        property property_id do
          __send__("#{property_id}s").first
        end
      end
    end

    def label(lang)
      labels[lang]['value']
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
      @_mainsnak ||= Snak.new(@data['mainsnak'])
    end

    def qualifiers
      Qualifiers.new(@data['qualifiers'])
    end
  end

  class Snak
    def initialize(snak)
      @snak = snak
    end

    # https://www.wikidata.org/wiki/Special:ListDatatypes
    # https://www.wikidata.org/wiki/Help:Data_type
    def value
      case @snak['datatype']
      when 'commonsMedia'
        # https://commons.wikimedia.org/wiki/Commons:FAQ#What_are_the_strangely_named_components_in_file_paths.3F
        # commons = 'https://commons.wikimedia.org/wiki/File:%s' % @snak["datavalue"]["value"]
        val = @snak['datavalue']['value'].gsub(' ', '_')
        md5 = Digest::MD5.hexdigest val
        "https://upload.wikimedia.org/wikipedia/commons/#{md5[0]}/#{md5[0..1]}/#{val}"
      when 'wikibase-item'
        # "Q%s" % @snak["datavalue"]["value"]["numeric-id"]
        Item.new(@snak['datavalue']['value'])
      when 'string'
        @snak['datavalue']['value']
      when 'quantity'
        if @snak['datavalue']['value']['upperBound'] == @snak['datavalue']['value']['lowerBound']
          @snak['datavalue']['value']['amount'].to_i
        else
          warn "FIXME: Unhandled 'quantity': #{@snak['datavalue']['value']}"
        end
      when 'time'
        case @snak['datavalue']['value']['precision']
        when 11
          @snak['datavalue']['value']['time'][1..10]
        when 10
          @snak['datavalue']['value']['time'][1..7]
        when 9
          @snak['datavalue']['value']['time'][1..4]
        when 7
          "" # Just ignore dates with century precision
        else
          warn "FIXME: Unhandled 'time' precision: #{@snak['datavalue']['value']['precision']}"
        end
      when 'url'
        @snak['datavalue']['value']
      else
        warn "FIXME: '#{@snak['datatype']}' is not implemented yet in Wikisnakker::Snak#value. Defaulting to empty string. #{@snak['datavalue']['value']}"
        ''
      end
    end
  end

  class Sitelink
    attr_reader :site
    attr_reader :title
    attr_reader :badges

    def initialize(raw)
      @site = raw['site']
      @title = raw['title']
      @badges = raw['badges']
    end
  end

  class Qualifiers
    include DynamicProperties

    attr_reader :snaks
    attr_reader :properties

    def initialize(qualifier_snaks)
      @properties = qualifier_snaks.keys
      qualifier_snaks.each do |property_id, snaks|
        property "#{property_id}s".to_sym do
          snaks.map { |s| Snak.new(s) }
        end

        property property_id do
          __send__("#{property_id}s").first
        end
      end
    end
  end
end
