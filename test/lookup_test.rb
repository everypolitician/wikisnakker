require 'test_helper'

describe Wikisnakker::Lookup do
  it 'should not fail if given an empty array' do
    Wikisnakker::Lookup.new([]).values.must_equal([])
  end
end
