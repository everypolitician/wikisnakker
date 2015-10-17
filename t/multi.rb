require 'minitest/autorun'
require 'wikidata/item'

require 'open-uri/cached'


def ids_from_claim(claim_str)
  url = 'https://wdq.wmflabs.org/api?q=claim[%s]' % claim_str
  json = JSON.parse(open(url).read)
  json['items'].map { |id| "Q#{id}" }
end

describe 'data' do

  subject { 
    # Members of the 13th Riigikogu
    ids = ids_from_claim('463:20530392')
    WikiData::Item.find(ids)
  }

  it 'should get multiple items' do
    subject.count.must_be :>, 50
  end

  it 'should have Juhan Parts' do
    parts = subject.find_all { |i| i.id == 'Q312894' }
    parts.count.must_equal 1
    parts.first.id.must_equal 'Q312894'
    parts.first.label('en').must_equal 'Juhan Parts'
  end

end

