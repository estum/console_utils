module ConsoleUtils::ActiveRecordUtils  #:nodoc:
  module RandomRecord #:nodoc:
    module FinderMethods
      def random
        reorder('RANDOM()')
      end

      def anyone
        random.first
      end

      def anyid(n = nil)
        if n
          @_anyid_history[-n.abs].presence || anyid()
        else
          idval = connection.select_value(select(:id).random.limit(1))
          model.type_for_attribute('id').send(:cast_value, idval).tap do |result|
            (@_anyid_history ||= []) << result
            @_anyid_history.shift if @_anyid_history.size > 10
          end
        end
      end
    end

    module Querying
      delegate :random, :anyone, :anyid, to: :all
    end
  end
end