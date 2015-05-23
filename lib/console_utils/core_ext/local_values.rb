unless Binding.method_defined?(:local_values)
  class Binding
    # Returns a hash with symbol keys that maps local variable names to their corresponding values.
    def local_values
      Hash[local_variables.map { |name| [name.to_s, local_variable_get(name)] }]
    end
  end
end