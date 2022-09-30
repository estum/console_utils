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
          @request_method = "#{request_method.to_s.upcase}"
          @request_params = normalize_args
          @url = urlify(url, @request_params.params)
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
      data = @request_params.params.to_json unless params_to_query?
      Curl.(request_method, url, data: data, headers: @request_params.headers) do |result, payload|
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

    def urlify(path, options = nil)
      URI.join(ConsoleUtils.remote_endpoint, path).
        tap { |uri| uri.query = options.to_query if options && params_to_query? }.to_s
    end

    def params_to_query?
       ["GET", "HEAD"].include?(@request_method) || @request_params.headers["Content-Type"] != "application/json"
    end

    class Curl
      OUT_FORMAT = '\n%{http_code}\n%{time_total}\n%{size_download}'.freeze
      HEADER_JOIN_PROC = proc { |*kv| ["-H", kv.flatten.join(": ")] }

      def self.call(*args)
        result = new(*args)
        yield(result.to_h, result.payload)
      end

      attr_reader :request, :response, :payload

      def initialize(request_method, url, data: nil, headers: nil)
        cmd = %W(#{ConsoleUtils.curl_bin} --silent -v -g)
        cmd.push("-X#{request_method}")
        cmd.push(url)

        cmd.concat(headers.flat_map(&HEADER_JOIN_PROC)) if headers.present?
        cmd.push("-d", data) if data.present?

        cmd_line = Shellwords.join(cmd)
        cmd_line << %( --write-out "#{OUT_FORMAT}")

        puts "$ #{cmd_line}" if verbose?

        @response = {}
        @request  = {}
        @payload  = []

        Open3.popen3(cmd_line) do |stdin, stdout, stderr, thr|
          # stdin.close
          { stderr: stderr, stdout: stdout }.each do |key, io|
            Thread.new do
              begin
                until (line = io.gets).nil? do
                  key == :stderr ? process_stderr(line) : @payload << line
                end
              rescue => e
                warn e
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
          @response.merge!(http_version: $1, http_code: $2.to_i, http_status: $3)
        else
          header, value = line.split(": ", 2)
          @response[header] = value
        end
      end

      def to_h
        { response: @response, request: @request }
      end

      def verbose?
        !ConsoleUtils.curl_silence
      end
    end
  end
end