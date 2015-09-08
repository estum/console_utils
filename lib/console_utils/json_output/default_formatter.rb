module ConsoleUtils
  module JSONOutput
    # The default formatter uses standart JSON library to output prettified JSON
    class DefaultFormatter < BaseFormatter
      def format(body) #:nodoc:
        JSON.pretty_generate JSON(body), :allow_nan => true, :max_nesting => false
      rescue JSON::ParseError, JSON::GeneratorError
        error = $!
        raise ParseError, "#{error.class.to_s}: #{error.message}"
      end
    end
  end
end
