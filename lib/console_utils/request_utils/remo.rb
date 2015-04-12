require 'uri'
require "console_utils/request_utils/requester"

module ConsoleUtils::RequestUtils #:nodoc:
  class Remo < Requester
    OUT_FORMAT      = "\n%{size_download}\n%{time_total}".freeze
    INSPECT_FORMAT  = "<Remote: %s in %s ms>".freeze
    INSPECT_NOTHING = "<Remote: nothing>".freeze

    attr_reader :request_method

    REQUEST_METHODS.each do |reqm|
      define_method(reqm) do |url, *args|
        @_args = args
        @url   = urlify(url, *normalize_args)
        @request_method = reqm.to_s.upcase
        perform
      end
    end

    def inspect
      if @url && @_time
        format(INSPECT_FORMAT, @url, @_time)
      else
        INSPECT_NOTHING
      end
    end

    def to_s
      @_body
    end

    protected

    def perform
      IO.popen(curl_command, "r+") { |io| set_payload!(io.readlines) }
    end

    private

    def set_payload!((*body_lines, size, time))
      @_body = body_lines.join
      @_size = size.to_f
      @_time = time.tr(?,, ?.).to_f
      self
    end

    def curl_command
      %W(#{ConsoleUtils.curl_bin} --silent --write-out #{OUT_FORMAT} -X #{request_method} #{url}).
        tap { |cmd| puts "# #{cmd.shelljoin.inspect}" unless ConsoleUtils.curl_silence }
    end

    def urlify(*args)
      options = args.extract_options!
      URI.join(ConsoleUtils.remote_endpoint, *args).
        tap { |uri| uri.query = options.to_query }.to_s
    end
  end
end