require 'json'
require 'active_support/core_ext/numeric'

module ConsoleUtils::RequestUtils #:nodoc:
  class Requester < SimpleDelegator
    REQUEST_METHODS  = %i(get post put delete patch).freeze
    INFO_HASH_FIELDS = %i(url size time human_size human_time).freeze
    INFO_FORMAT      = "%#-.50{url} | %#10{human_size} | %#10{human_time}\n".freeze
    NO_RESPONSE      = Term::ANSIColor.red(" \u27A7 Empty response's body.").freeze
    PBCOPY_MESSAGE   = Term::ANSIColor.green(" \u27A4 Response body copied to pasteboard\n").freeze
    COMPLETE_IN      = Term::ANSIColor.green("Complete in %s").freeze
    TRANSFERED       = Term::ANSIColor.cyan("Transfered: %s").freeze

    class_attribute :default_params, instance_writer: false
    attr_reader :url

    def preview(mth = nil)
      if output = to_s.presence
        ConsoleUtils::JSONOutput.formatter.(output)
        show_complete_in!
        show_transfered!
        yield(self) if block_given?
      else
        puts NO_RESPONSE
      end
    end

    # Copies to pasteboard
    def pbcopy(content = nil)
      content ||= ConsoleUtils::JSONOutput::Default.instance.format_with_fallback(to_s)
      IO.popen('pbcopy', 'w') { |io| io << content.to_s }
      puts PBCOPY_MESSAGE
    end

    def print_info
      tap { printf(INFO_FORMAT, to_info_hash) }
    end

    def size
      @_size.bytes
    end

    def time
      @_time.in_milliseconds
    end

    alias_method :human_size,
    def size_downloaded
      size.to_s(:human_size)
    end

    alias_method :human_time,
    def time_ms
      time.to_s(:human, units: { unit: 'ms' })
    end

    def to_info_hash
      INFO_HASH_FIELDS.zip(INFO_HASH_FIELDS.map(&method(:public_send))).to_h
    end

    protected

    def normalize_args
      RequestParams.new(*@_args).with_default(default_params).tap do |args|
        ConsoleUtils.logger.debug { args }
      end
    end

    private

    def show_complete_in!(reset = true)
      return if @_time.nil?
      puts "=> #{COMPLETE_IN % [time_ms]}"
      @_time = nil
    end

    def show_transfered!(reset = true)
      return if @_size.nil?
      puts "=> #{TRANSFERED % [size_downloaded]}"
      @_size = nil
    end

    private_constant :REQUEST_METHODS, :PBCOPY_MESSAGE,
                     :NO_RESPONSE, :COMPLETE_IN, :TRANSFERED,
                     :INFO_FORMAT
  end
end