module ConsoleUtils::RequestUtils
  module JSONOutput
    FORMATTERS = {}

    # The abstract singleton class for a prettified JSON formatting.
    class Formatter
      include Singleton

      # Prints formatted JSON to stdout.
      def call(body)
        puts format(body)
      end

      # Formats a given JSON string
      def format(body)
        raise NotImplementedError
      end

      def self.inherited(sub) #:nodoc:
        super
        key = sub.name.demodulize.underscore.to_sym
        FORMATTERS[key] = sub
      end
    end

    # The default formatter uses standart JSON library to output prettified JSON
    class Default < Formatter
      def format(body) #:nodoc:
        jj JSON(body)
      rescue JSON::GeneratorError => e
        warn "Warning: Failed to format a json.", e.message, body
        body.to_s
      end
    end

    # The jq formatter uses the external {jq}[http://stedolan.github.com/jq] utility.
    class Jq < Formatter
      delegate :jq_command, :to => :ConsoleUtils

      def format(body) #:nodoc:
        IO.popen(jq_command, 'r+') { |io| (io << body).tap(&:close_write).read }
      end
    end

    class << self
      delegate :json_formatter, :to => :ConsoleUtils

      # Get current formatter object
      def formatter
        FORMATTERS[json_formatter].instance
      end
    end

    private_constant :Formatter
    private_class_method :json_formatter
  end
end
