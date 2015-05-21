module ConsoleUtils
  class ReplContext
    include Singleton

    def self.console
      instance[]
    end

    def call
      pry! || irb!
    end

    def irb!
      irb_rails! || ::IRB::ExtendCommandBundle
    end

    def irb_rails!
      ::Rails.application.config.console::ExtendCommandBundle if rails?
    end

    def pry!
      ::TOPLEVEL_BINDING.eval('self') if pry?
    end

    private

    def rails?
      defined?(::Rails::Application)
    end

    def pry?
      defined?(::Pry)
    end
  end
end
