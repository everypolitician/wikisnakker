require 'test_helper'

describe 'fields ordered by rank' do
  it 'allows you to access the rank of the claim' do
    claim = Wikisnakker::Claim.new('rank' => 'preferred')
    claim.rank.must_equal('preferred')
  end
end
