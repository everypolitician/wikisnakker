require 'open-uri'
require 'yajl'
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
        get(id_slice)[:entities]
      end
      @entities = entities.reduce(&:merge) || {}
    end

    def properties
      @used_props.to_a.map { |e| "Q#{e}".to_sym }
    end

    def values
      @entities.values
    end

    def [](key)
      @entities[key]
    end

    def populate_with(properties)
      each_wikibase_entitiyid(@entities) do |entityid|
        entityid[:value] = properties["Q#{entityid[:value][:"numeric-id"]}".to_sym]
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
      json = Yajl::Parser.parse(open(url), symbolize_keys: true)
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
        @used_props << entityid[:value][:'numeric-id']
      end
    end

    def each_wikibase_entitiyid(obj)
      recurse_proc(obj) do |result|
        next unless result.is_a?(Hash) && result[:type] == 'wikibase-entityid'.freeze
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
end
