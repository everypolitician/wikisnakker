module Wikisnakker
  class Sitelink
    attr_reader :site
    attr_reader :title
    attr_reader :badges

    def initialize(raw)
      @site = raw[:site]
      @title = raw[:title]
      @badges = raw[:badges]
    end
  end
end
