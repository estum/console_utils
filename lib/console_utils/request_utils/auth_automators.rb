module ConsoleUtils::RequestUtils
  class DefaultAuthAutomator
    def self.call(rq)
      p rq
      if rq.can_auto_auth?
        rq.params[ConsoleUtils.token_param] ||= ConsoleUtils.default_token.presence || ConsoleUtils.auto_token_for(rq.uid)
      end
    end
  end

  class SimpleTokenAutomator
    def self.call(rq)
      if rq.can_auto_auth?
        model_key = ConsoleUtils.user_model.model_name.param_key
        header_names = ::SimpleTokenAuthentication.header_names[model_key.to_sym]
        fields = header_names.keys
        user = ConsoleUtils.find_user(rq.uid, scope: ConsoleUtils.user_model.select(:id, *fields))
        header_names.each { |field, name| rq.headers[name] ||= user.public_send(field) }
      end
    end
  end
end
