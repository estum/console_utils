module ConsoleUtils::RequestUtils
  class RequestParams
    attr_accessor :uid

    def initialize(uid_or_params = true, params = nil, headers = nil)
      if uid_or_params.is_a? Hash
        headers, params, uid_or_params = [params, uid_or_params, nil]
      end

      @params = params
      @headers = headers
      @uid = auto_auth? && ((uid_or_params.nil? || uid_or_params == true) ? ConsoleUtils.default_uid : uid_or_params)

      ConsoleUtils.logger.debug { "#{uid}, #{params()}, #{headers()}" }

      auth_automator.(self)
    end

    def params
      @params ||= {}
    end

    def headers
      @headers ||= {}
    end

    def to_a
      [params, headers.presence].tap(&:compact!)
    end

    def with_default(default_params = nil)
      default_headers = default_params.delete(:headers) if default_params.is_a?(Hash)

      if params.is_a?(Hash)
        params.merge!(default_params.to_h)
      else
        headers.merge!(default_headers.to_h)
      end

      to_a
    end

    def can_auto_auth?
      auto_auth? && uid && auth_automator.respond_to?(:call)
    end

    private

    def auto_auth?
      ConsoleUtils.request_auto_auth
    end

    def auth_automator
      ConsoleUtils.auth_automator
    end
  end
end
