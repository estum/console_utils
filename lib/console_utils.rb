require "active_support"
require "active_support/rails"
require 'term/ansicolor'
require 'console_utils/core_ext/array_to_proc'
require "console_utils/version"

begin
  require "awesome_print"
rescue LoadError
else
  require "awesome_print/proc" if defined?(AwesomePrint)
end

# = Rails Console Utils
# Collection of utilities to use in Rails Console.
#
# == Modules
#
# [ActiveRecordUtils]
#
#     useful console methods for <tt>ActiveRecord::Base</tt> models
#
# [BenchUtils]
#
#     benchmark shorthands
#
# [RequestUtils]
#
#     tools to make local and remote JSON API requests with
#     json response body formatting and automatic auth
#     (currently supports only token auth).
#
# [OtherUtils]
#
#     uncategorized collection of methods
#
# == Configuration
# Parameters are changable by the <tt>config.console_utils</tt> key inside
# the app's configuration block. It is also available as
# <tt>ConsoleUtils.configure(&block)</tt> in the custom initializer.
module ConsoleUtils
  extend ActiveSupport::Autoload

  MODULES = [
    :ActiveRecordUtils,
    :RequestUtils,
    :BenchUtils,
    :OtherUtils
  ]

  JSON_FORMATTERS = %i(default jq)

  MODULES.each { |mod| autoload mod }

  # :section: Configuration

  ##
  # :attr:
  # An array with disabled modules (default: <tt>[]</tt>)
  mattr_accessor(:disabled_modules) { [] }
  ##
  # :attr:
  # Enable the auto-fetching of user's auth token in requests
  # (default: <tt>true</tt>)
  mattr_accessor(:auto_token) { true }
  ##
  # :attr:
  # ID of the user which will be used by default in requests
  # (default: <tt>1</tt>)
  mattr_accessor(:default_uid) { 1 }
  ##
  # :attr:
  # A name of user's model (default: <tt>:User</tt>)
  mattr_accessor(:user_model_name) { :User }
  ##
  # :attr:
  # A primary key of user's model (default: <tt>:id</tt>)
  mattr_accessor(:user_primary_key) { :id }
  ##
  # :attr:
  # A column name with a user's token. Using by request tools.
  # (default: <tt>:auth_token</tt>)
  mattr_accessor(:user_token_column) { :auth_token }
  ##
  # :attr:
  # A name of the request parameter used to authorize user by a token
  # (default: <tt>:token</tt>)
  mattr_accessor(:token_param) { :token }
  ##
  # :attr:
  # JSON formatter used in API request helpers
  # (<tt>:default</tt> or <tt>:jq</tt>)
  mattr_accessor(:json_formatter) { :default }
  ##
  # :attr:
  # Command for +jq+ json formatter (default: <tt>"jq . -C"</tt>)
  mattr_accessor(:jq_command) { "jq . -C" }
  ##
  # :attr:
  # Binary path to +curl+ (using in remote requests). (default: <tt>"curl"</tt>)
  mattr_accessor(:curl_bin) { "curl" }
  ##
  # :attr:
  # Don't print generated curl command with remote requests.
  # (default: <tt>false</tt>)
  mattr_accessor(:curl_silence) { false }
  ##
  # :attr:
  # Remote endpoint used in remote API request helpers
  # (default: <tt>"http://example.com"</tt>)
  mattr_accessor(:remote_endpoint) { "http://example.com" }
  ##
  # :attr:
  # Output logger (<tt>Rails.logger</tt> by default)
  mattr_accessor :logger


  # :section: Class Methods

  class << self
    def config
      self
    end
    private :config

    # :method: self.configure
    def configure
      yield(config)
    end

    # Returns User's class set in the <tt>:user_class_name</tt>
    def user_model
      Object.const_get(user_model_name)
    end
    alias_method :user_class, :user_model

    # Finds +user_model+ by +user_primary_key+.
    # If the first argument is <tt>:any</tt>, gets a random user.
    def find_user(id, scope: nil)
      case id
      when :any
        (scope || user_model).anyone
      else
        (scope || user_model).where(user_primary_key => id).first!
      end
    end

    def enabled_modules
      ConsoleUtils::MODULES - disabled_modules
    end

    # Yields each enabled module with a given block
    def each_enabled_module
      enabled_modules.each { |mod| yield const_get(mod) }
    end

    # Setup enabled modules by extending given context
    def setup_modules_to(context = nil)
      context = yield() if block_given?
      puts "Console instance: #{context.inspect}" if ENV["CONSOLE_UTILS_DEBUG"]
      each_enabled_module { |mod| context.send(:extend, mod) }
    end
  end

  ActiveSupport.run_load_hooks(:console_utils, self)
end

if defined? Rails
  require "console_utils/railtie"
end