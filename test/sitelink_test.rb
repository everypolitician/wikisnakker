require 'test_helper'

describe Wikisnakker::Sitelink do
  subject do
    Wikisnakker::Sitelink.new(
      'site' => 'commonswiki',
      'title' => 'Category:Jaak Aaviksoo',
      'badges' => []
    )
  end

  it 'has a site property' do
    subject.site.must_equal 'commonswiki'
  end

  it 'has a title property' do
    subject.title.must_equal 'Category:Jaak Aaviksoo'
  end

  it 'has a badges property' do
    subject.badges.must_equal []
  end
end
