require 'test_helper'

describe 'Single Record' do
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
    subject.P106.value.must_equal 'politician'
  end

  it 'should have two children' do
    subject.P1971.value.must_equal 2
  end

  it 'should have a Freebase ID' do
    subject.P646.value.must_equal '/m/01y41c'
  end

  it 'should be in IRL' do
    subject.P102.value.must_equal 'Pro Patria and Res Publica Union'
  end

  it 'should expand Image URLs' do
    subject.P18.value.must_equal 'https://upload.wikimedia.org/wikipedia/commons/0/08/Juhan-Parts.jpg'
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
