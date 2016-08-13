require "console_utils/request_utils/requester"

module ConsoleUtils::RequestUtils #:nodoc:
  class Exap < Requester
    INSPECT_FORMAT = "<Local: %s (%s)>".freeze

    ConsoleUtils.request_methods.each do |request_method|
      class_eval <<~RUBY, __FILE__, __LINE__ + 1
        def #{request_method}(url, *args)
          @url = url
          @_args = args
          app.#{request_method}(@url, *normalize_args)
          self
        end
      RUBY
    end

    def to_s
      response.try(:body)
    end

    def inspect
      format INSPECT_FORMAT, request.try(:path), response.try(:status)
    end

    private

    def request
      app.controller.try(:request)
    end

    def response
      app.controller.try(:response)
    end

    def response_body
      app.controller.try(:response_body) || response.try(:body)
    end
  end
end