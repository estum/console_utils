require 'json'
require 'active_support/core_ext/numeric'

module ConsoleUtils::RequestUtils #:nodoc:
  class Requester < SimpleDelegator
    REQUEST_METHODS = %i(get post put delete patch).freeze

    attr_reader :url

    def to_h
      JSON.parse(to_s)
    end

    def to_body
      JSON.pretty_generate(to_h)
    rescue JSON::GeneratorError
      to_s
    end

    NO_RESPONSE = Term::ANSIColor.red(" \u27A7 Empty response's body.").freeze

    def preview(mth = nil)
      if output = to_s.presence
        case ConsoleUtils.json_formatter
        when :default then puts to_body
        when :jq      then puts jq(output)
        end

        show_complete_in!
        show_transfered!

        yield(self) if block_given?
      else
        puts NO_RESPONSE
      end
    end

    INFO_FORMAT = "%#-.50{url} | %#10{human_size} | %#10{human_time}\n".freeze

    def print_info
      tap { printf(INFO_FORMAT, to_info_hash) }
    end

    INFO_HASH_FIELDS = %i(url size time human_size human_time)

    def to_info_hash
      INFO_HASH_FIELDS.zip(INFO_HASH_FIELDS.map(&method(:public_send))).to_h
    end

    def size_downloaded
      size.to_s(:human_size)
    end

    alias_method :human_size, :size_downloaded

    def time_ms
      time.to_s(:human, units: { unit: 'ms' })
    end

    alias_method :human_time, :time_ms

    def size
      @_size.bytes
    end

    def time
      @_time.in_milliseconds
    end

    protected

    AUTOAUTH_FORMAT = %('ID: %s' %p\n).freeze

    def normalize_args
      if ConsoleUtils.auto_token
        uid = (@_args[0].is_a?(Hash) || @_args.empty?) ? ConsoleUtils.default_uid : @_args.shift

        if uid.present?
          printf(AUTOAUTH_FORMAT, uid, @_args)
          opts = @_args.extract_options!
          @_args.unshift(opts.tap { |x| x[ConsoleUtils.token_param] ||= __getobj__.autoken(uid) })
        end
      end

      @_args
    end

    protected

    # Copies to pasteboard
    def pbcopy(content = nil)
      content ||= to_body
      IO.popen('pbcopy', 'w') { |io| io << content.to_s }
      puts PBCOPY_MESSAGE
    end

    private

    PBCOPY_MESSAGE = Term::ANSIColor.green(" \u27A4 Response body copied to pasteboard\n").freeze

    COMPLETE_IN = Term::ANSIColor.green("Complete in %s").freeze

    def show_complete_in!(reset = true)
      return if @_time.nil?
      puts "=> #{COMPLETE_IN % [time_ms]}"
      @_time = nil
    end

    TRANSFERED = Term::ANSIColor.cyan("Transfered: %s").freeze

    def show_transfered!(reset = true)
      return if @_size.nil?
      puts "=> #{TRANSFERED % [size_downloaded]}"
      @_size = nil
    end

    private_constant :REQUEST_METHODS, :AUTOAUTH_FORMAT, :PBCOPY_MESSAGE,
                     :NO_RESPONSE, :COMPLETE_IN, :TRANSFERED,
                     :INFO_FORMAT
    # -

    # Pretty formats json
    def jq(raw)
     IO.popen(ConsoleUtils.jq_command, 'r+') { |io| (io << raw).tap(&:close_write).read }
    end
  end
end