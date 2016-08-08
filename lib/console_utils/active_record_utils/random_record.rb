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
        model.type_for_attribute('id').send(:cast_value, connection.select_value(select(:id).random.limit(1)))
      end
    end

    module Querying
      delegate :random, :anyone, :anyid, to: :all
    end
  end
end