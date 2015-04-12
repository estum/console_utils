module ConsoleUtils #:nodoc:

  # = Benchmark utils
  #
  # Provides the collection of tools for benchmarking

  module BenchUtils
    extend ActiveSupport::Autoload

    autoload :Chips

    # :call-seq:
    #   chips[ .("report") {} | .compare! {} | ... ]
    #
    # Access to globally shared <tt>Benchmark.ips</tt> object, which
    # works out of a block and allows to change the stack "on the fly"
    # and to keep the result during the work.
    #
    # ==== Examples
    #
    #     chips.("merge") { the_hash.merge(other_hash) }
    #     chips.("merge!") { the_hash.merge!(other_hash) }
    #     # => x.report(..) { ... }
    #
    #     chips.compare! # compare two reports
    #
    #     # add more reports:
    #     chips.("deep_merge") { the_hash.deep_merge(other_hash) }
    #
    #     # change an existing:
    #     chips.("merge!") { the_hash.deep_merge!(other_hash) }
    #
    #     chips.compare! # compare three reports
    #
    #     # remove report labeled as "merge!":
    #     chips.del("merge!")
    #
    #     # it is just a delegator of the hash:
    #     chips          # => { "merge" => #<Proc:...>, ... }
    #     chips["merge"] # => #<Proc:...>
    #     chips.clear    # clear procs
    def chips
      Chips.shared
    end
  end
end
