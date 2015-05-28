module ConsoleUtils::RequestUtils
  class RequestParams
    def initialize(uid_or_params = true, params = nil, headers_or_env = nil)
      if ConsoleUtils.auto_token
        @uid = case uid_or_params
               when Numeric, true, false, nil then uid_or_params
               when headers_or_env.nil?       then need_shift!
               end
      else
        need_shift!
      end

      params, headers_or_env = [uid_or_params, params] if need_shift?

      @params = params.is_a?(Hash) ? params : {}
      @headers = headers_or_env.to_h

      if need_default_token?
        use_token ConsoleUtils.default_token
      else
        @uid = ConsoleUtils.default_uid if need_default_uid?
        use_token ConsoleUtils.auto_token_for(@uid) if @uid.present?
      end
    end

    def to_a
      [@params.presence, @headers.presence].tap(&:compact!)
    end

    def use_token value
      @params[ConsoleUtils.token_param] ||= value
    end

    def with_default(default_params = nil)
      @params.merge!(default_params.to_h)
      to_a
    end

    def need_default_uid?
      @uid == true && ConsoleUtils.default_token.nil?
    end

    def need_default_token?
      @uid == true && ConsoleUtils.default_token.present?
    end

    def need_shift!
      @need_shift = true
    end

    def need_shift?
      !!@need_shift
    end
  end
end
