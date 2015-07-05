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
      init_to(:irb) { irb_rails! || ::IRB::ExtendCommandBundle }
    end

    def irb_rails!
      init_to(:rails) { ::Rails.application.config.console::ExtendCommandBundle } if rails?
    end

    def pry!
      init_to(:pry) { ::TOPLEVEL_BINDING.eval('self') } if pry?
    end

    def initialized_to
      @initialized_to ||= []
    end

    def initialized?
      initialized_to.size > 0
    end

    def rails?
      defined? ::Rails::Application
    end

    def pry?
      defined? ::Pry
    end

    private

    def init_to(context)
      unless initialized_to.include?(context)
        initialized_to << context
        yield if block_given?
      end
    end
  end
end
