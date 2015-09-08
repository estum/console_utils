require "console_utils/request_utils/requester"

module ConsoleUtils::RequestUtils #:nodoc:
  class Exap < Requester
    INSPECT_FORMAT = "<Local: %s (%s)>".freeze

    REQUEST_METHODS.each do |reqm|
      define_method(reqm) { |*args| resp_wrap(reqm, *args) }
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

    def resp_wrap(meth, url, *args)
      @url, @_args = url, args
      app.send(meth, url, *normalize_args)
      self
    end
  end
end