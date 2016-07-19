module ConsoleUtils
  class ReplState
    IVAR = :"@__console_utils__"
    EMPTY_CONTEXT_ALERT    = "Trying to setup with empty context".freeze
    ALREADY_EXTENDED_ALERT = "Trying to setup again on fully extended context".freeze
    CONTEXT_DEBUG_MSG      = "Console instance: %p".freeze
    MODULE_EXTENDS_MSG     = "extending context...".freeze

    def self.setup(context)
      state = (context.instance_variable_defined?(IVAR) ? context.instance_variable_get(IVAR) : nil) || ReplState.new

      return true if state.frozen?

      logger.tagged("console_utils-#{VERSION}") do
        if context.nil?
          logger.warn { EMPTY_CONTEXT_ALERT }
          return
        end

        unless state.persisted?
          logger.level = Logger::WARN

          if ENV["CONSOLE_UTILS_DEBUG"]
            logger.level = Logger::DEBUG
            logger.debug { CONTEXT_DEBUG_MSG % context }
          end
        end

        if state.fully_extended?
          logger.warn { ALREADY_EXTENDED_ALERT }
        else
          ConsoleUtils.enabled_modules do |mod|
            state.extending(mod.to_s) do
              logger.debug { MODULE_EXTENDS_MSG }
              context.extend(mod)
            end
          end
        end
      end

      context.instance_variable_set(IVAR, state.persist!)
    end

    def self.logger
      ConsoleUtils.logger
    end

    def initialize
      @version    = VERSION
      @extensions = []
      @persisted  = false
    end

    def persisted?
      @persisted
    end

    def persist!
      @persisted = true
      fully_extended? ? freeze : self
    end

    def fully_extended?
      @persisted && @extensions.size == ConsoleUtils.enabled_modules.size
    end

    def extending(mod_name)
      if include?(mod_name)
        true
      else
        ConsoleUtils.logger.tagged(mod_name) { yield }
        @extensions << mod_name
      end
    end

    def include?(mod)
      @extensions.include?(mod.to_s)
    end

    alias_method :extended_with?, :include?
  end
end
