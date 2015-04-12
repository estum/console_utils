require "rails/railtie"

module ConsoleUtils
  ##
  # Console Utils Railtie
  class Railtie < ::Rails::Railtie
    #:nodoc: all
    config.console_utils = ActiveSupport::OrderedOptions.new

    initializer 'console_utils.logger' do
      ActiveSupport.on_load(:console_utils) { self.logger = ::Rails.logger }
    end

    initializer "console_utils.set_configs" do |app|
      options = app.config.console_utils

      options.disabled_modules ||= ConsoleUtils.disabled_modules
      options.disabled_modules << :ActiveRecordUtils unless defined?(ActiveRecord)

      ActiveSupport.on_load(:console_utils) do
        options.each { |k,v| send(:"#{k}=", v) }
      end
    end

    console do |app|
      ConsoleUtils.setup_modules_to do
        if defined?(Pry)
          TOPLEVEL_BINDING.eval('self')
        else
          Rails.application.config.console::ExtendCommandBundle
        end
      end
    end
  end
end