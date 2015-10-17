require 'minitest/autorun'
require 'wikidata/item'

describe 'Single Record' do

  subject { WikiData::Item.find('Q312894') }

  it 'should should know ID' do
    subject.id.must_equal 'Q312894'
  end

  it 'should know the name' do
    subject.label('en').must_equal 'Juhan Parts'
  end

  it 'should cope with extended language names' do
    subject.label('zh-hant').must_equal '尤漢·帕茨'
  end

  it 'should have a birth date' do
    subject.p569.must_equal '1966-08-27'
  end
end

