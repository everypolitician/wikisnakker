require 'test_helper'

describe 'fields ordered by rank' do
  around { |test| VCR.use_cassette('ranking', &test) }

  it 'allows you to access the rank of the claim' do
    claim = Wikisnakker::Claim.new('rank' => 'preferred')
    claim.rank.must_equal('preferred')
  end

  it 'returns the highest ranked field by default' do
    item = Wikisnakker::Item.find('Q401383')
    item.P569.value.must_equal('1966-05-02')
  end
end
