module ConsoleUtils::RequestUtils
  class RequestParams
    def initialize(uid_or_params = true, params = nil, headers_or_env = nil)
      if ConsoleUtils.auto_token
        @uid = case uid_or_params
               when Numeric, true, false, nil
                 uid_or_params
               when headers_or_env.nil?
                 need_shift!
               end
      else
        need_shift!
      end

      params, headers_or_env = [uid_or_params, params] if need_shift?

      @params         = params || {}
      @headers_or_env = headers_or_env || {}

      @uid = ConsoleUtils.default_uid if need_default_uid?

      if @uid.present?
        @params[ConsoleUtils.token_param] ||= yield(@uid) if block_given?
        printf(Requester::AUTOAUTH_FORMAT, @uid, to_a)
      end
    end

    def to_a
      [@params.presence, @headers_or_env.presence].tap(&:compact!)
    end

    def with_default(default_params = nil)
      @params.merge!(default_params.is_a?(Hash) ? default_params : {})
      to_a
    end

    def need_default_uid?
      @uid == true
    end

    def need_shift!
      @need_shift = true
    end

    def need_shift?
      !!@need_shift
    end
  end
end
