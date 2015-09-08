require "open3"

module ConsoleUtils
  module JSONOutput
    # The jq formatter uses the external {jq}[http://stedolan.github.com/jq] utility.
    class JqFormatter < BaseFormatter
      delegate :jq_command, :to => :ConsoleUtils

      def format(body) #:nodoc:
        output, err, s = Open3.capture3(jq_command, stdin_data: body)

        raise ParseError, err.squish unless s.success?

        output
      end
    end
  end
end
