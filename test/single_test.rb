require 'test_helper'

describe 'Single Record' do
  around { |test| VCR.use_cassette('single', &test) }

  subject { Wikisnakker::Item.find('Q312894') }

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

  it 'should be a politician' do
    subject.P106.value.label('en').must_equal 'politician'
  end

  it 'should have two children' do
    subject.P1971.value.must_equal 2
  end

  it 'should have a Freebase ID' do
    subject.P646.value.must_equal '/m/01y41c'
  end

  it 'should be in IRL' do
    subject.P102.value.label('en').must_equal 'Pro Patria and Res Publica Union'
  end

  it 'should expand Image URLs' do
    subject.P18.value.must_equal 'https://upload.wikimedia.org/wikipedia/commons/0/08/Juhan-Parts.jpg'
  end

  it 'should have been PM' do
    positions = subject.P39s
    pm = positions.find_all { |p| p.value.label('en') == 'Prime Minister of Estonia' }
    pm.size.must_equal 1
  end

  it 'should be male' do
    gender = subject.P21
    gender.value.label('en').must_equal 'male'
  end

  it 'should return nil for a singular missing property' do
    subject.P999999999999.must_be_nil
  end

  it 'should return an empty array for a singular missing property' do
    subject.P999999999999s.must_equal []
  end

  it 'should implement "respond_to?" correctly' do
    subject.respond_to?(:P999999999999).must_equal true
    subject.respond_to?(:P999999999999s).must_equal true
    subject.respond_to?(:Ps).must_equal false
    subject.respond_to?(:p42).must_equal false
  end
end

describe 'Record with URL' do
  around { |test| VCR.use_cassette('mdc', &test) }

  subject { Wikisnakker::Item.find('Q1146616') }

  it 'should have a website' do
    subject.P856.value.must_equal 'http://www.mdczimbabwe.org/'
  end

  it 'should have a logo' do
    subject.P154.value.must_equal 'https://upload.wikimedia.org/wikipedia/commons/b/b0/Flag_of_the_Movement_for_Democratic_Change.svg'
  end

  it 'should have a list of properties' do
    subject.properties.must_equal ["P31", "P646", "P17", "P571", "P159", "P1142", "P856", "P154", "P488", "P214"]
  end

  it 'should allow accessing properties using square brackets' do
    subject[:P856].value.must_equal 'http://www.mdczimbabwe.org/'
  end
end

describe 'Sitelinks' do
  around { |test| VCR.use_cassette('mdc', &test) }

  let(:item) { Wikisnakker::Item.find('Q1146616') }
  subject { item.sitelinks }

  it 'returns sitelinks objects' do
    assert_equal 19, subject.size
    assert_equal 'afwiki', subject.keys.first
    assert_equal 'Movement for Democratic Change', subject.values.first.title
  end
end

describe 'snak with time precision 4' do
  around { |test| VCR.use_cassette('enn-eesmaa', &test) }

  subject { Wikisnakker::Item.find('Q11857954') }

  it 'has a date of birth year' do
    assert_equal '1946', subject.P569.value
  end
end
