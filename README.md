# MongoidRecurring

[![Build Status](https://travis-ci.org/tomasc/mongoid_recurring.svg)](https://travis-ci.org/tomasc/mongoid_recurring) [![Gem Version](https://badge.fury.io/rb/mongoid_recurring.svg)](http://badge.fury.io/rb/mongoid_recurring) [![Coverage Status](https://img.shields.io/coveralls/tomasc/mongoid_recurring.svg)](https://coveralls.io/r/tomasc/mongoid_recurring)

Recurring date time fields for Mongoid models, using [IceCube](https://github.com/seejohnrun/ice_cube/).

When included in a model, this gem expands the recurring rules set of an `IceCube` schedule on save into an array of embedded `MongoidRecurring::Occurence` models.

It also adds definitions of several scopes that allow for convenient querying of models stored in the db.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mongoid_recurring'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mongoid_recurring

## Usage

```ruby
  class MyModel
    include Mongoid::Document
    include MongoidRecurring::HasRecurringFields
    has_recurring_fields
  end
```

Which will then add `dtstart`, `dtend`, `all_day`, `schedule` and `schedule_dtend` fields to the model.

The model will generate all occurrences on before save, and stores them as embedded `MongoidRecurring::Occurrence` documents in the `:occurrences` embedded relation.

A scope named `.for_datetime_range` can be then used to query for documents with occurrences in specified DateTime range:

```ruby
  MyModel.for_datetime_range( Date.today, Date.today+1.week )
```

## Configuration

By default, when `schedule_dtend` is not specified, the `:occurrences` are populated for 1 year in advance. This duration can be configured as follows:

  has_recurring_fields schedule_duration: 2.weeks

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/mongoid_recurring/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
