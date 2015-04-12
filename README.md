[![Code Climate](https://codeclimate.com/github/estum/console_utils/badges/gpa.svg)](https://codeclimate.com/github/estum/console_utils)

# Rails Console Utils

ConsoleUtils gem provides several handy tools to use in Rails Console. It includes following modules:

1. **[RequestUtils](#requestutils)**
   the collection of methods to make either local or remote JSON API requests.
   Provides response body formatting and auto-token authentication feature
   (currently supports only params tokens).
2. **[BenchUtils](#benchutils)**
   benchmark shorthands
3. **[ActiveRecordUtils](#activerecordutils)**
   useful console methods for ActiveRecord::Base models
4. **[OtherUtils](#otherutils)**
   uncategorized methods

The gem was collected from several **very *(very-very)* raw** modules used in different projects in different time. The code was refactored, but currently there are no specs or complete docs (sowwy ^_^), but they are *coming soon*.

## Installation

Add this lines to your application's Gemfile.
**Note**: when using with `pry-rails` gem, make sure to depend it before this gem.

```ruby
group :development do
  ## to enable inspecting procs' sources, uncomment next lines:
  # gem 'term-ansicolor', '1.1.5'
  # gem 'sourcify', '~> 0.6.0.rc4', require: false

  ## when using `pry-rails`, it should be somewhere here:
  # gem 'pry-rails'

  gem 'console_utils'
end
```

And then execute:

    $ bundle

## Configuration

Parameters are changable by the `config.console_utils` key inside the app's configuration block. It is also available as `ConsoleUtils.configure(&block)` in the custom initializer file.

Example part of `config/environments/development.rb`:

```ruby
Rails.application.configure do
  # ...
  if config.console_utils
    config.console_utils.json_formatter = :jq
    config.console_utils.remote_endpoint = Settings.base_url
  end
end
```

### Options:

* `auto_token` - Enable auto-fetch of user's auth token in requests (default: `true`)
* `curl_bin` - Binary path to curl (using in remote requests). (default: `"curl"`)
* `curl_silence` - Disable print out generated curl command with remote requests. (default: `false`)
* `default_uid` - ID of the user which will be used by default in requests (default: `1`)
* `disabled_modules` - An array of disabled modules' names (default: `[]`)
* `jq_command` - Command for jq json formatter (default: `"jq . -C"`)
* `json_formatter` - JSON formatter used in API request helpers (:default or :jq)
* `logger` - Output logger (Rails.logger by default)
* `remote_endpoint` - Remote endpoint used in remote API request helpers (default: `"http://example.com"`)
* `token_param` - A name of the request parameter used to authorize user by a token (default: `:token`)
* `user_model_name` - A name of user's model (default: `:User`)
* `user_primary_key` - A primary key of user's model (default: `:id`)
* `user_token_column` - A column name with a user's token. Using by request tools. (default: `:auth_token`)

## RequestUtils

Includes requesters to a local (`exap`) or a remote (`remo`) project's API. There are many customizable settings in configuration, so it's better to check them before playing with this feature.

The following examples are actual to both of requesters - just swap `exap` to `remo` and it will work.

Appends auth token of default user to params, makes request and prints formatted response:

```ruby
exap.get("api/posts.json").preview
```

Authorize user #42, also copy formatted response to the pasteboard:

```ruby
exap.get("api/posts.json", 42).preview(&:pbcopy)
```

Authorize random user:

```ruby
exap.get("api/comments.json", :any).preview
```

Use additional request params (skip the second parameter to use default user), don't print response body:

```ruby
exap.put("api/account.json", 42, user: { name: "Anton" })
```

Skip auto-fetching user's token:

```ruby
exap.post("api/signup.json", nil, user: { name: "Guest" }).preview
```

**Note:** The `remo` requester supports the auto-token feature, but still fetchs tokens from a local DB.

## BetchUtils

Access to globally shared Benchmark.ips object, which works out of a block and allows to change the stack “on the fly” and to keep the result during the work.

Just add reports:

```ruby
chips.("merge") { the_hash.merge(other_hash) }
chips.("merge!") { the_hash.merge!(other_hash) }
# => x.report(..) { ... }
```

... and compare!

```ruby
chips.compare! # compares two reports: "merge" and "merge!"
```

And add more reports after:

```ruby
chips.("deep_merge") { the_hash.deep_merge(other_hash) }
```

... or change the existing one:

```ruby
chips.("merge!") { the_hash.deep_merge!(other_hash) }
```

... and compare again!

```ruby
chips.compare! # compare three reports: "merge", changed "merge!" and new "deep_merge"
```

You can remove report by a label:

```ruby
chips.del("merge!")
```

Split to a separate `Chips` object:

```ruby
other_chips = chips.split!("deep_merge") # split reports to separate hash
```

Well, to be honest, it is just a delegator of a reports hash, so:

```ruby
chips          # => { "merge" => proc { ... }, ... }
chips["merge"] # => proc { ... }
chips.clear    # clear all reports
```

## ActiveRecordUtils

Includes methods to query a random record:

```ruby
User.random         # => reorder("RANDOM()")
User.anyone         # get a random record (like [].sample method)
User.active.anyone  # works under a scope - get a random active record
User.anyid	        # get an id of some existing record
```

Also provides shorthand to find any user by id: `usr(id)`

## OtherUtils

#### clr()
Term::ANSIColor shorthand

#### shutting(:engine_key[, to: logger_level]) {}
Shuts up the logger of a specified Rails engine for a given key (`:rails`, `:record`, `:controller` or `:view`).

```ruby
shutting(:view, to: :warn) do
  ActionView.logger.info("not printed")
  ActionView.logger.warn("printed")
  Rails.logger.info("printed")
end

shutting(:rails, to: Logger::INFO) { ... }
shutting(:record, to: 1) { ... }
```

## Array#to_proc

> Oh no, core class extension!

Converts array to proc with chained calls of items. Every item can be either a method name or an array containing a method name and args.

```ruby
the_hash = { :one => "One", :two => "Two", :three => 3, :four => nil }
the_hash.select(&[[:[], 1], [:is_a?, String]])
# => { :one => "One", :two => "Two" }
```

Pretty good, huh? ;)

See again:

```ruby
mapping = { "one" => "1", "two" => "2", "" => "0" }
the_hash.values.map(&[:to_s, :downcase, [:sub, /one|two|$^/, mapping]])
# => ["1", "2", "3", "0"]
```

Avoid to use it in production, seriously.

## AwesomePrint::Proc

Just prints proc's source when inspecting proc. `Sourcify` is required, see the **Installation** section for notes.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/console_utils/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
