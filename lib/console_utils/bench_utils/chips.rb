require "benchmark/ips"

module ConsoleUtils::BenchUtils #:nodoc:
  class Chips < SimpleDelegator
    class << self
      # The globally shared +Chips+ object
      def shared
        @shared ||= new
      end

      def method_missing(meth, *args, &blk)
        shared.respond_to?(meth) ? shared.send(meth, *args, &blk) : super
      end

      def respond_to_missing?(*args)
        shared.respond_to?(*args) || super
      end
    end

    attr_reader :results

    # Creates Chips context using a given hash of reports.
    def initialize(reports = nil)
      super(reports.to_h)
      @results = []
    end

    # Executes <tt>Benchmark.ips {|x| ...; x.compare! }</tt> using
    # the given hash of procs as reports and push the result to
    # <tt>results</tt> stack.
    def compare!
      results << begin
        Benchmark.ips do |x|
          each_pair {|name, proc| x.report(name, &proc) }
          x.compare!
        end
      end
    end

    # :call-seq:
    #   call("label") { ...things to bench... }
    #
    # Adds a labeled report block. The same as <tt>x.report(label) { ... }</tt>.
    def call(name, &block)
      self[name] = block.to_proc
    end

    # Get a recent result
    def recent
      results.last
    end

    # Splits reports to a new context
    def split!(*args)
      Chips.new(__getobj__.split!(*args))
    end

    def del(*args)
      __getobj__.delete(*args)
    end
  end
end