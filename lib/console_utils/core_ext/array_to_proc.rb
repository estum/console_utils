unless Array.method_defined?(:to_proc)
  class Array
    # :call-seq:
    #   [].to_proc
    #   &[chain, [:of_calls, and, args], ...]
    #
    # Converts array to proc with chained calls of items.
    # Every item can be either a method name or an array containing
    # a method name and args.
    #
    # ==== Examples
    #
    #     the_hash = { :one => "One", :two => "Two", :three => 3, :four => nil }
    #     mapping = { "one" => "1", "two" => "2", "" => "0" }
    #
    #     the_hash.select(&[[:[], 1], [:is_a?, String]])
    #     # => { :one => "One", :two => "Two" }
    #
    #     the_hash.values.map(&[:to_s, :downcase, [:sub, /one|two|$^/, mapping]])
    #     # => ["1", "2", "3", "0"]
    def to_proc
      proc do |*obj|
        obj = obj.shift if obj.size == 1
        reduce(obj) do |chain, sym|
          chain.public_send(*Array(sym).flatten)
        end
      end
    end
  end
end