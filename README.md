# Wikisnakker [![Build Status](https://travis-ci.org/everypolitician/wikisnakker.svg?branch=master)](https://travis-ci.org/everypolitician/wikisnakker)

This project allows you to do bulk lookups of Wikidata items. If you want to look up large amounts of Wikidata items at once then this library should make that job considerably faster.

:warning: This project is under heavy development and is in a **very** pre-alpha state, it's not yet ready for use in production.

## Features/problems

- Many

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'wikisnakker', git: 'https://github.com/everypolitician/wikisnakker'
```

And then execute:

    $ bundle

## Usage

### Single item

You can get a Wikidata item using its qualifier. For example [Douglas Adams](https://www.wikidata.org/wiki/Q42) has the qualifier `Q42`.

```ruby
require 'wikisnakker'
douglas_adams = Wikisnakker::Item.find('Q42')
douglas_adams.label('en') # => "Douglas Adams"
```

The you can lookup properties on the returned item. For example `P19` is "place of birth". A `P19` is an item, so you can then call `.label()` on its return value and call further `P*` methods on it.

```ruby
cambridge = douglas_adams.P19.value
cambridge.label('en') # => "Cambridge"
```

`P569` is "date of birth" and `P570` is "date of death".

```ruby
douglas_adams.P569.value # => "1952-03-11"
douglas_adams.P570.value # => "2001-05-11"
```

### Multiple items

The main reason you might want to use this library is to lookup multiple items at once. You can pass an array of qualifiers to `Wikisnakker::Item.find`.

```ruby
require 'wikisnakker'
items = Wikisnakker::Item.find(['Q2', 'Q513', 'Q41225'])
items.map { |item| item.label('en') } # => ["Earth", "Mount Everest", "Big Ben"]
items.map { |item| item.P18.value } # => ["https://upload.wikimedia.org/wikipedia/commons/9/97/The_Earth_seen_from_Apollo_17.jpg", "https://upload.wikimedia.org/wikipedia/commons/e/e7/Everest_North_Face_toward_Base_Camp_Tibet_Luca_Galuzzi_2006.jpg", "https://upload.wikimedia.org/wikipedia/commons/7/78/Big-ben-1858.jpg"]
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/everypolitician/wikisnakker.
