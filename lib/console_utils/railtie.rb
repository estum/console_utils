module ConsoleUtils
  ##
  # Console Utils Railtie
  class Railtie < ::Rails::Railtie #:nodoc: all
    config.console_utils = ActiveSupport::OrderedOptions.new

    initializer "console_utils.set_configs" do |app|
      options = app.config.console_utils

      options.disabled_modules ||= ConsoleUtils.disabled_modules

      if !defined?(ActiveRecord) || !ConsoleUtils.disabled_modules.include?(:ActiveRecordUtils)
        options.disabled_modules << :ActiveRecordUtils

        ActiveSupport.on_load(:active_record) do
          ConsoleUtils.disabled_modules.delete(:ActiveRecordUtils)
        end
      end

      ActiveSupport.on_load(:console_utils) do
        options.each { |k, v| public_send(:"#{k}=", v) }
      end
    end

    console do
      ConsoleUtils.pry!
    end
  end
end