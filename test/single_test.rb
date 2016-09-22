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

  it 'should stringify as its name' do
    subject.to_s.must_equal 'Juhan Parts'
  end

  it 'should cope with extended language names' do
    subject.label('zh-hant').must_equal '尤漢·帕茨'
  end

  it 'should not die with missing language' do
    subject.label('zz').must_be_nil
  end

  it 'should have a description in English' do
    subject.description('en').must_equal 'Prime Minister of Estonia'
  end

  it 'should have a description in German' do
    subject.description('de').must_equal 'estnischer Politiker'
  end

  it 'should have no description in Swedish' do
    subject.description('se').must_be_nil
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
    subject.properties.must_equal [:P31, :P646, :P17, :P571, :P159, :P1142, :P856, :P154, :P488, :P214]
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
    assert_equal :afwiki, subject.keys.first
    assert_equal 'Movement for Democratic Change', subject.values.first.title
  end
end

describe 'snak time' do
  describe 'precision 9' do
    around { |test| VCR.use_cassette('enn-eesmaa', &test) }

    subject { Wikisnakker::Item.find('Q11857954') }

    it 'has a date of birth year' do
      assert_equal '1946', subject.P569.value
    end
  end

  describe 'precision 10' do
    around { |test| VCR.use_cassette('bogumil-borowski', &test) }

    subject { Wikisnakker::Item.find('Q9175546') }

    it 'has a date of death month' do
      assert_equal '2014-08', subject.P570.value
    end
  end
end

describe 'qualifiers' do
  around { |test| VCR.use_cassette('qualifiers', &test) }

  let(:item) { Wikisnakker::Item.find('Q21856082') }
  let(:position) { position = item.P39 }

  it 'should know the start date' do
    assert_equal '2013-12-10', position.qualifiers.P580.value
  end

  it 'should know the electoral district' do
    assert_equal 'Buenos Aires Province', position.qualifiers.P768.value.label('en')
  end

  it 'should stringify its properties' do
    assert_equal 'Buenos Aires Province', position.qualifiers.P768.value.to_s
    assert_equal '2013-12-10', position.qualifiers.P580.value.to_s
  end

  it 'should allow accessing properties using square brackets' do
    assert_equal '2013-12-10', position.qualifiers[:P580].value
    assert_equal '2013-12-10', position.qualifiers['P580'].value
  end

  it 'should have a list of available qualifiers' do
    assert_equal [:P768, :P580], position.qualifiers.properties
  end

  it "shouldn't error if qualifiers are missing" do
    VCR.use_cassette('roberto_noble') do
      roberto_noble = Wikisnakker::Item.find('Q12341')
      position = roberto_noble.P39s.first
      assert_equal [], position.qualifiers.properties
    end
  end
end

describe 'snaktype' do
  around { |test| VCR.use_cassette('snaktype', &test) }
  let(:item) { Wikisnakker::Item.find('Q617611') }

  describe 'somevalue' do
    it 'should return nil' do
      assert_nil item.P21.value
    end
  end

  describe 'novalue' do
    it 'should return nil' do
      assert_nil item.P735.value
    end
  end
end

describe 'aliases' do
  around { |test| VCR.use_cassette('aliases', &test) }
  let(:item) { Wikisnakker::Item.find('Q2036942') }

  it 'should return aliases for the given language' do
    item.aliases('en').must_equal(['Rafael Edward Cruz'])
    item.aliases('ru').must_equal(['Тед Круз'])
  end

  it 'should return an empty array when there are no aliases for language' do
    item.aliases('de').must_equal([])
  end

  it 'has a list of all aliases' do
    expected = {
      ru: [{ language: 'ru', value: 'Тед Круз' }],
      en: [{ language: 'en', value: 'Rafael Edward Cruz' }],
      es: [{ language: 'es', value: 'Rafael Edward Cruz' }]
    }
    item.all_aliases.must_equal(expected)
  end
end
