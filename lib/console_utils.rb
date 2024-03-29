require 'active_support'
require 'active_support/core_ext'
require 'active_support/tagged_logging'
require 'pastel'
require 'console_utils/core_ext/array_to_proc'
require 'console_utils/core_ext/local_values'
require 'console_utils/version'

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

  JSON_FORMATTERS = [
    :default,
    :jq
  ]

  MODULES = [
    :ActiveRecordUtils,
    :RequestUtils,
    :BenchUtils,
    :OtherUtils
  ]

  MODULES.each { |mod| autoload mod }

  autoload :JSONOutput
  autoload :ReplState


  # :section: Configuration

  # :attr:
  # An array with disabled modules (default: <tt>[]</tt>)
  mattr_accessor(:disabled_modules) { [] }

  # :attr:
  # ID of the user which will be used by default in requests
  # (default: <tt>1</tt>)
  mattr_accessor(:default_uid) { 1 }

  # :attr:
  # A plain string of the default token used to authorize user
  # (default: <tt>nil</tt>)
  mattr_accessor(:default_token)

  # :attr:
  # A name of user's model (default: <tt>:User</tt>)
  mattr_accessor(:user_model_name) { :User }

  # :attr:
  # A primary key of user's model (default: <tt>:id</tt>)
  mattr_accessor(:user_primary_key) { :id }

  # :attr:
  # A column name with a user's token. Using by request tools.
  # (default: <tt>:auth_token</tt>)
  mattr_accessor(:user_token_column) { :auth_token }

  # :attr:
  # A name of the request parameter used to authorize user by a token
  # (default: <tt>:token</tt>)
  mattr_accessor(:token_param) { :token }

  # :attr:
  # JSON formatter used in API request helpers
  # (<tt>:default</tt> or <tt>:jq</tt>)
  mattr_accessor(:json_formatter) { :default }

  # :attr:
  # Command for +jq+ json formatter (default: <tt>"jq . -C"</tt>)
  mattr_accessor(:jq_command) { %w[jq -C] }

  # :attr:
  # Binary path to +curl+ (using in remote requests). (default: <tt>"curl"</tt>)
  mattr_accessor(:curl_bin) { "curl" }

  # :attr:
  # Don't print generated curl command with remote requests.
  # (default: <tt>false</tt>)
  mattr_accessor(:curl_silence) { false }

  # :attr:
  # Remote endpoint used in remote API request helpers
  # (default: <tt>"http://example.com"</tt>)
  mattr_accessor(:remote_endpoint) { "http://example.com" }

  # :attr:
  # Output logger (<tt>Logger.new(STDOUT)</tt> by default)
  mattr_accessor(:logger) { ActiveSupport::TaggedLogging.new(Logger.new(STDOUT)) }

  # :attr:
  # Enable the auth automator with the "exap"
  # (default: <tt>true</tt>)
  mattr_accessor(:request_auto_auth) { true }

  # :attr:
  # Request methods to delegate with requester
  # (default: <tt>[:get, :post, :put, :delete, :patch, :head]</tt>)
  mattr_accessor(:request_methods) {  %i(get post put delete patch head) }

  # :attr:
  # Specifies a callable object, which will hook requests with
  # credentials. There are two built-in implementations: the default
  # one <tt>ConsoleUtils::RequestUtils::DefaultAuthAutomator</tt> and
  # the <tt>ConsoleUtils::RequestUtils::SimpleTokenAutomator</tt>,
  # which is useful when using the +simple_token_automator+ gem.
  mattr_accessor(:auth_automator) { ConsoleUtils::RequestUtils::DefaultAuthAutomator }

  # :attr:
  # Keeps any amount of callable objects to invoke them before each request,
  # with an instance of <tt>ConsoleUtils::RequestUtils::RequestParams</tt>
  # as only the argument.
  # (default: <tt>[]</tt>)
  mattr_accessor(:request_hooks) { [] }

  # :section: Class Methods

  class << self
    alias_method :config, :itself

    # :method: self.configure
    def configure # :yields:
      yield(config)
    end

    def enabled_modules # :yields:
      unless block_given?
        return to_enum(__method__) { ConsoleUtils::MODULES.size - disabled_modules.size }
      end

      (ConsoleUtils::MODULES - disabled_modules).each do |mod|
        yield(const_get(mod))
      end
    end

    # Returns User's class set in the <tt>:user_class_name</tt>
    def user_model
      Object.const_get(user_model_name)
    end
    alias_method :user_class, :user_model

    def user_scope(scope = nil)
      case scope
      when nil    then user_model
      when Symbol then user_model.public_send(scope)
                  else user_model.all.merge(scope)
      end
    end

    # Finds +user_model+ by +user_primary_key+.
    # If the first argument is <tt>:any</tt>, gets a random user.
    def find_user(id, scope: nil)
      if id == :any
        user_scope(scope).anyone.tap do |u|
          puts "random user #{user_primary_key}: #{u.public_send(user_primary_key)}"
        end
      else
        user_scope(scope).where(user_primary_key => id).first!
      end
    end

    def auto_token_for(id)
      user = find_user(id, scope: user_model.select([:id, user_token_column]))
      user.public_send(user_token_column)
    end

    # Setup enabled modules for Pry context
    def pry!
      setup_modules_to(TOPLEVEL_BINDING.eval('self'))
    end

    # Setup enabled modules by extending given context
    def setup_modules_to(context = nil)
      ReplState.setup(context)
    end

    def pastel
      @pastel ||= Pastel.new
    end
  end

  ActiveSupport.run_load_hooks(:console_utils, self)
end

if defined? Rails
  require "console_utils/railtie"
end