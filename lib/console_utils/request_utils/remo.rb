require 'uri'
require 'open3'
require 'shellwords'
require 'console_utils/request_utils/requester'

module ConsoleUtils::RequestUtils #:nodoc:
  class Remo < Requester
    INSPECT_FORMAT  = "<Remote: %s in %s ms>".freeze
    INSPECT_NOTHING = "<Remote: nothing>".freeze

    attr_reader :request_method

    ConsoleUtils.request_methods.each do |request_method|
      class_eval <<~RUBY, __FILE__, __LINE__ + 1
        def #{request_method}(url, *args)
          @_args = args
          @url = urlify(url, *normalize_args)
          @request_method = "#{request_method.to_s.upcase}"
          perform
        end
      RUBY
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

    attr_reader :_result

    protected

    def perform
      Curl.(request_method, url) do |result, payload|
        @_result = result
        set_payload!(payload)
      end
    end

    private

    def set_payload!((*body_lines, code, time, size))
      @_body = body_lines.join
      @_code = code.to_i
      @_size = size.to_f
      @_time = time.tr(?,, ?.).to_f
      self
    end

    def urlify(*args)
      options = args.extract_options!
      URI.join(ConsoleUtils.remote_endpoint, *args).
        tap { |uri| uri.query = options.to_query }.to_s
    end

    class Curl
      OUT_FORMAT = "\n%{http_code}\n%{time_total}\n%{size_download}".freeze

      def self.call(*args)
        result = new(*args)
        yield(result.to_h, result.payload)
      end

      attr_reader :request, :response, :payload

      def initialize(request_method, url)
        cmd = %W(#{ConsoleUtils.curl_bin} --silent -v --write-out #{OUT_FORMAT} -X #{request_method} #{url})
        puts "# #{cmd.shelljoin.inspect}" unless ConsoleUtils.curl_silence

        @response = {}
        @request  = {}
        @payload  = []

        Open3.popen3(Shellwords.join(cmd)) do |stdin, stdout, stderr, thr|
          # stdin.close
          { stderr: stderr, stdin: stdout }.each do |key, io|
            Thread.new do
              while line = io.gets
                key == :stderr ? process_stderr(line) : @payload << line
              end
            end
          end
          thr.join
        end
      end

      KEY_MAP = { ">" => :request, "<" => :response }

      def process_stderr(line)
        # warn(line)
        if type = KEY_MAP[line.chr]
          line = line[2, line.size-1].strip

          return if line.size == 0

          case type
          when :request; set_request(line)
          when :response; set_response(line)
          end
        end
      end

      def set_request(line)
        # warn("Request: #{line}")
        if !@request.key?(:http_version) && line =~ /^(GET|POST|PUT|PATCH|HEAD|OPTION|DELETE) (.+?) HTTP\/(.+)$/
          @request.merge!(method: $1, url: $2, http_version: $3)
        else
          header, value = line.split(": ", 2)
          @request[header] = value
        end
      end

      def set_response(line)
        # warn("Response: #{line}")
        if !@response.key?(:http_version) && line =~ /^HTTP\/(.+) (\d+?) (.+)$/
          @response.merge!(http_version: $1, http_code: $2, http_status: $3)
        else
          header, value = line.split(": ", 2)
          @response[header] = value
        end
      end

      def to_h
        { response: @response, request: @request }
      end
    end
  end
end