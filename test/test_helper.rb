require 'wikisnakker'

require 'minitest/autorun'
require 'minitest/around'
require 'minitest/around/spec'
require 'vcr'
require 'pry'

VCR.configure do |c|
  c.cassette_library_dir = 'test/vcr_cassettes'
  c.hook_into :webmock
end
