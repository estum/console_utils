module ConsoleUtils
  module JSONOutput
    # The abstract singleton class for a prettified JSON formatting.
    class BaseFormatter
      include Singleton

      # Prints formatted JSON to stdout.
      def call(body) # :yields:
        formatted = format_with_fallback(body)
        if block_given?
          yield(formatted)
        else
          puts formatted
        end
      end

      # Formats a given JSON string
      def format(body)
        raise NotImplementedError
      end

      def format_with_fallback(body)
        format(body)
      rescue ParseError => error
        warn error
        return body.to_s
      end
    end
  end
end
