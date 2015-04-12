#:nodoc: all

begin
  require "sourcify"
rescue LoadError
end

module AwesomePrint
  module Proc
    #:startdoc:
    def self.included(base)
      base.send :alias_method, :cast_without_proc, :cast
      base.send :alias_method, :cast, :cast_with_proc
    end

    # Add Proc class to the dispatcher pipeline.
    def cast_with_proc(obj, type)
      if (type == :proc || obj.is_a?(::Proc)) && obj.respond_to?(:to_source)
        :proc
      else
        cast_without_proc(obj, type)
      end
    end

    private

    # Format Proc object.
    def awesome_proc(obj)
      if !@options[:raw] && (/\A(?<kw>proc)\s*(?<block_source>.+?)\z/ =~ obj.to_source)
        kw = "->" if obj.lambda?
        sprintf("%s %s", colorize(kw, :keyword), colorize(block_source, :string))
      else
        awesome_object(obj)
      end
    end
    #:enddoc:
  end
end

if defined?(Sourcify) && Sourcify::VERSION >= "0.6.0.rc4"
  AwesomePrint::Formatter.include(AwesomePrint::Proc)
end