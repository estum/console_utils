module ConsoleUtils
  module JSONOutput
    extend ActiveSupport::Autoload

    class ParseError < StandardError
      def initialize(original_message = nil)
        super("Failed to format a json. (#{original_message})")
      end
    end

    eager_autoload do
      autoload :BaseFormatter
    end

    autoload :DefaultFormatter
    autoload :JqFormatter

    FORMATTER_CLASSES = {}

    # Get current formatter object
    def self.formatter
      const_get(formatter_class_name).instance
    end

    def self.json_formatter # :nodoc:
      ConsoleUtils.json_formatter
    end

    def self.formatter_class_name # :nodoc:
      FORMATTER_CLASSES[json_formatter] ||= "#{json_formatter}_formatter".classify.freeze
    end

    private_constant :FORMATTER_CLASSES
    private_class_method :json_formatter, :formatter_class_name
  end

  JSONOutput.eager_load!
end