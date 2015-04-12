module ConsoleUtils::ActiveRecordUtils  #:nodoc:
  module RandomRecord #:nodoc:
    module FinderMethods
      def random
        reorder('RANDOM()')
      end

      def anyone
        random.first
      end

      def anyid
        anyone.id
      end
    end

    module Querying
      delegate :random, :anyone, :anyid, to: :all
    end
  end
end