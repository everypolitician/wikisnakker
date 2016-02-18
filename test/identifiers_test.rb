require 'test_helper'

describe 'Single Record' do
  around { |test| VCR.use_cassette('identifiers', &test) }

  subject { Wikisnakker::Item.find('Q385483') }

  it 'should should be the correct ID' do
    subject.id.must_equal 'Q385483'
  end

  it 'should have a VIAF ID' do
    subject.P214.value.must_equal '59119452'
  end

  it 'should have a senat ID' do
    subject.P1808.value.must_equal 'senateur/magras_michel08019v'
  end
end
