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

      auth_automator.(self) if can_auto_auth?
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
      params.merge!(default_params.to_h)
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
