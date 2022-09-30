require 'open3'
require 'shellwords'

module ConsoleUtils
  module JSONOutput
    # The jq formatter uses the external {jq}[http://stedolan.github.com/jq] utility.
    class JqFormatter < BaseFormatter
      delegate :jq_command, to: :ConsoleUtils

      def format(body, args: nil, flags: nil, compact: false, **) #:nodoc:
        flags = Array.wrap(flags) + %w[-c] if compact
        cmd = compose(flags, args)
        output, err, s = Open3.capture3(cmd, stdin_data: body)

        if s.success?
          output
        else
          warn({flags:flags,args:args}.inspect)
          warn "$ #{cmd}"
          raise ParseError, err.squish
        end
      end

      def compose(flags, args)
        Shellwords.join jq_command.dup.concat(Array.wrap(flags), Array.wrap(args))
      end
    end
  end
end
