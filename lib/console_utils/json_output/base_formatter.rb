module ConsoleUtils
  module JSONOutput
    # The abstract singleton class for a prettified JSON formatting.
    class BaseFormatter
      include Singleton

      # Prints formatted JSON to stdout.
      def call(body, *args, **options) # :yields:
        formatted = format_with_fallback(body, args: args, **options)
        if block_given?
          yield(formatted)
        else
          puts formatted
        end
      end

      # Formats a given JSON string
      def format(body, **opts)
        raise NotImplementedError
      end

      def format_with_fallback(body, **opts)
        format(body, **opts)
      rescue ParseError => error
        warn error
        return body.to_s
      end
    end
  end
end
