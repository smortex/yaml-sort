# yaml-sort

[![CI](https://github.com/smortex/yaml-sort/actions/workflows/ci.yaml/badge.svg)](https://github.com/smortex/yaml-sort/actions/workflows/ci.yaml)
[![Maintainability](https://api.codeclimate.com/v1/badges/4df28a3babe44d1a83c0/maintainability)](https://codeclimate.com/github/smortex/yaml-sort/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/4df28a3babe44d1a83c0/test_coverage)](https://codeclimate.com/github/smortex/yaml-sort/test_coverage)

An utility to manage YAML files and ensure their lines is in a predictable order.

This is mainly indended to manage [Hiera files](https://puppet.com/docs/puppet/7/hiera_intro.html) for [Puppet](https://puppet.com/) and translation files in [Ruby on Rails](https://rubyonrails.org/) applications.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add yaml-sort

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install yaml-sort

## Usage

```
Usage: yaml-sort [options] [filename]
    -i, --in-place                   Update files in-place
    -l, --lint                       Ensure files content is sorted as expected
```

## Hiera Integration for Puppet

Add this to your Rakefile:

```ruby
require "yaml/sort/tasks/puppet"

Rake::Task[:lint].enhance ["lint:hiera_data_ordering"]
```

This provide two new targets:

```
rake lint:hiera_data_ordering  # Check Hiera data content ordering
rake reorder_hiera_data        # Reorder Hiera data in-place
```

## Ruby on Rails Integration

Add this to your Rakefile:

```ruby
require "yaml/sort/tasks/rails"

Rake::Task[:test].enhance ["test:translations_ordering"]
```

This provide two new targets:

```
rake reorder_translations        # Reorder translations in-place
rake test:translations_ordering  # Check translations content ordering
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/smortex/yaml-sort. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/smortex/yaml-sort/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the yaml-sort project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/smortex/yaml-sort/blob/main/CODE_OF_CONDUCT.md).
