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
    dob = subject.P569
    "#{dob}".must_equal '1966-08-27'
  end

  it 'should have two children' do
    subject.P1971.value.must_equal 2
  end

  it 'should have been PM' do
    positions = subject.P39s
    pm = positions.find_all { |p| p.value == 'Prime Minister of Estonia' }
    pm.size.must_equal 1
  end

  it 'should be male' do
    gender = subject.P21
    gender.value.must_equal 'male'
  end


end

