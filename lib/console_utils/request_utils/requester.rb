require 'json'
require 'active_support/core_ext/numeric'

module ConsoleUtils::RequestUtils #:nodoc:
  class Requester < SimpleDelegator
    INFO_HASH_FIELDS = %i(url size time human_size human_time).freeze
    INFO_FORMAT      = "%#-.50{url} | %#10{human_size} | %#10{human_time}\n".freeze
    NO_RESPONSE      = ConsoleUtils.pastel.red(" \u27A7 Empty response's body.").freeze
    PBCOPY_MESSAGE   = ConsoleUtils.pastel.green(" \u27A4 Response body copied to pasteboard\n").freeze

    class_attribute :default_params, instance_writer: false
    attr_reader :url

    def preview(*args, **opts)
      if output = to_s.presence
        ConsoleUtils::JSONOutput.formatter.(output, *args, **opts)
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
      hsh = {}
      INFO_HASH_FIELDS.each { |field| hsh[field] = public_send(field) }
      hsh
    end

    protected

    def normalize_args
      params = RequestParams.new(*@_args).with_default(default_params)
      ConsoleUtils.logger.debug { params.to_a }
      params
    end

    private

    def show_complete_in!(reset = true)
      return if @_time.nil?
      if @_code && status_code = Rack::Utils::HTTP_STATUS_CODES[@_code]
        print "=> ", pastel.public_send(status_color(@_code), "Completed ", pastel.bold("#{@_code} #{status_code}"), " in #{time_ms}"), "\n"
      else
        puts "=> #{pastel.green("Completed in #{time_ms}")}"
      end
    ensure
      @_code = nil
      @_time = nil
    end

    def pastel
      ConsoleUtils.pastel
    end

    def show_transfered!(reset = true)
      return if @_size.nil?
      print "=> ", pastel.cyan("Transferred: #{size_downloaded}"), "\n"
    ensure
      @_size = nil
    end

    def status_color(code)
      case code
      when 200...400; :green
      when 400...500; :red
      when 500...600; :bright_red
      else            :yellow
      end
    end

    private_constant :PBCOPY_MESSAGE,
                     :NO_RESPONSE,
                     :INFO_FORMAT
  end
end