module ConsoleUtils #:nodoc:
  module OtherUtils
    # <tt>Pastel</tt> shorthand
    def clr
      ConsoleUtils.pastel
    end

    # :call-seq:
    #   shutting(:engine_key[, to: logger_level]) {}
    #
    # Shuts up logger of Rails engine by a given key (<tt>:rails</tt>, <tt>:record</tt>,
    # <tt>:controller</tt> or <tt>:view</tt>).
    #
    #     shutting(:view, to: :warn) do
    #       ActionView.logger.info("not printed")
    #       ActionView.logger.warn("printed")
    #       Rails.logger.info("printed")
    #     end
    #
    #     shutting(:rails, to: Logger::INFO) { ... }
    #     shutting(:record, to: 1) { ... }
    #
    def shutting(*args, &block)
      Shutting.(*args, &block)
    end

    class Shutting
      ENGINES_KEYS_MAP = {
        :rails      => "Rails",
        :record     => "ActiveRecord::Base",
        :controller => "ActionController::Base",
        :view       => "ActionView::Base"
      }

      def self.call(*args, &block)
        new(*args).call(&block)
      end

      def initialize(key, to: Logger::WARN)
        @key = key
        @level = to
        @level = Logger.const_get(@level.upcase) unless @level.is_a?(Numeric)
      end

      def call(&block)
        with_logger { |logger| logger.silence(@level, &block) }
      end

      # Yields engine's logger for a given key.
      def with_logger
        const_get(ENGINES_KEYS_MAP[@key]).
          logger.tap { |logger| yield(logger) unless logger.nil? }
      end
    end
  end
end
