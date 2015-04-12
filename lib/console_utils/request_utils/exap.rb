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
      format INSPECT_FORMAT, request.path, response.status
    end

    private

    delegate :controller, to: :app, prefix: true, allow_nil: true
    delegate :request, :response, to: :app_controller, allow_nil: true

    def resp_wrap(meth, url, *args)
      @url, @_args = url, args
      p args
      app.send(meth, url, *normalize_args)
      self
    end
  end
end