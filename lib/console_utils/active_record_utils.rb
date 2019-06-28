module ConsoleUtils #:nodoc:
  module ActiveRecordUtils
    extend ActiveSupport::Autoload

    autoload :RandomRecord

    def self.extended(mod)
      ActiveSupport.on_load(:active_record) do
        ActiveRecord::Relation.send(:prepend, RandomRecord::FinderMethods)
        ActiveRecord::Base.send(:extend, RandomRecord::Querying)
      end
    end

    # Shortcut to <tt>ConsoleUtils.find_user(id)</tt>
    def usr(id)
      ConsoleUtils.find_user(id)
    end
  end
end