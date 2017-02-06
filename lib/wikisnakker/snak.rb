require 'digest/md5'

module Wikisnakker
  class Snak
    def initialize(snak)
      @snak = snak
    end

    # https://www.wikidata.org/wiki/Special:ListDatatypes
    # https://www.wikidata.org/wiki/Help:Data_type
    def value
      return if %w(somevalue novalue).include?(@snak[:snaktype])
      case @snak[:datatype]
      when 'commonsMedia'
        # https://commons.wikimedia.org/wiki/Commons:FAQ#What_are_the_strangely_named_components_in_file_paths.3F
        # commons = 'https://commons.wikimedia.org/wiki/File:%s' % @snak["datavalue"]["value"]
        val = @snak[:datavalue][:value].tr(' ', '_')
        md5 = Digest::MD5.hexdigest val
        "https://upload.wikimedia.org/wikipedia/commons/#{md5[0]}/#{md5[0..1]}/#{val}"
      when 'wikibase-item'
        # "Q%s" % @snak["datavalue"]["value"]["numeric-id"]
        Item.new(@snak[:datavalue][:value])
      when 'string'
        @snak[:datavalue][:value]
      when 'external-id'
        @snak[:datavalue][:value]
      when 'quantity'
        if @snak[:datavalue][:value][:upperBound] == @snak[:datavalue][:value][:lowerBound]
          @snak[:datavalue][:value][:amount].to_i
        else
          warn "FIXME: Unhandled 'quantity': #{@snak[:datavalue][:value]}"
        end
      when 'time'
        case @snak[:datavalue][:value][:precision]
        when 11
          @snak[:datavalue][:value][:time][1..10]
        when 10
          @snak[:datavalue][:value][:time][1..7]
        when 9
          @snak[:datavalue][:value][:time][1..4]
        when 7
          '' # Just ignore dates with century precision
        else
          warn "FIXME: Unhandled 'time' precision: #{@snak[:datavalue][:value][:precision]}"
        end
      when 'url'
        @snak[:datavalue][:value]
      else
        warn "FIXME: '#{@snak[:datatype]}' is not implemented yet in Wikisnakker::Snak#value. Defaulting to empty string. #{@snak[:datavalue][:value]}"
        ''
      end
    end
  end
end
