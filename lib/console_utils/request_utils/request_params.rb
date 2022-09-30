# frozen_string_literal: true

module ConsoleUtils::RequestUtils
  RequestParams = Struct.new(:params, :headers)

  class RequestParams
    AutoUid = -> (uid) do
      ConsoleUtils.request_auto_auth && ((uid.nil? || uid == true) ? ConsoleUtils.default_uid : uid)
    end

    attr_accessor :uid, :rest_options

    def initialize(uid = true, *rest, params: nil, headers: nil, json: nil, **rest_options)
      params, headers = rest if params.nil? && headers.nil? && rest.size > 0
      params, headers, uid = [uid, params, nil] if uid.is_a?(Hash)
      headers ||= {}
      if params.nil? && json.present?
        params = json
        headers['Content-Type'] = 'application/json'
      end
      @uid = AutoUid[uid] || uid
      @rest_options = rest_options
      super(params, headers.to_h)

      ConsoleUtils.auth_automator.(self) if ConsoleUtils.auth_automator.respond_to?(:call)
      ConsoleUtils.request_hooks.each { |hook| hook.(self) }
      ConsoleUtils.logger.debug { "#{@uid}, #{self}" }
    end

    def to_h
      { **super(), **@rest_options }
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

      self
    end

    def can_auto_auth?
      ConsoleUtils.request_auto_auth && @uid && ConsoleUtils.auth_automator.respond_to?(:call)
    end
  end
end
