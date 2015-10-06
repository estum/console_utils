require "console_utils/request_utils/requester"

module ConsoleUtils::RequestUtils #:nodoc:
  class Exap < Requester
    INSPECT_FORMAT = "<Local: %s (%s)>".freeze

    ConsoleUtils.request_methods.each do |reqm|
      define_method(reqm) do |*args|
        @url, *@_args = args
        app.public_send(reqm, @url, *normalize_args)
        self
      end
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