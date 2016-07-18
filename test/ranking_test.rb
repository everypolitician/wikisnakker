require 'test_helper'

describe 'fields ordered by rank' do
  around { |test| VCR.use_cassette('ranking', &test) }

  it 'allows you to access the rank of the claim' do
    claim = Wikisnakker::Claim.new(rank: 'preferred')
    claim.rank.must_equal('preferred')
  end

  it 'returns the highest ranked field by default' do
    item = Wikisnakker::Item.new(
      sitelinks: [],
      claims: {
        P1: [
          { rank: 'normal', mainsnak: { datatype: 'string', datavalue: { value: 'normal rank 1' } } },
          { rank: 'normal', mainsnak: { datatype: 'string', datavalue: { value: 'normal rank 2' } } },
          { rank: 'preferred', mainsnak: { datatype: 'string', datavalue: { value: 'preferred rank' } } },
          { rank: 'deprecated', mainsnak: { datatype: 'string', datavalue: { value: 'deprecated rank' } } },
        ],
      }
    )
    item.P1.value.must_equal('preferred rank')
    item.P1s.map(&:value).must_equal(['preferred rank', 'normal rank 1', 'normal rank 2', 'deprecated rank'])
  end
end
