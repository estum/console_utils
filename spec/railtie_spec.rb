# encoding: UTF-8

require 'spec_helper'
require 'rails/commands/console'

describe ConsoleUtils::Railtie do
  it 'should make the helpers available only in TOPLEVEL_BINDING' do
    # Yes, I know this is horrible.
    begin
      $called_start = false
      real_pry = Pry

      silence_warnings do
        ::Pry = Class.new do
          def self.start(*)
            $called_start = true
          end
        end
      end

      Rails::Console.start(Rails.application)

      assert $called_start
    ensure
      silence_warnings do
        ::Pry = real_pry
      end
    end

    %w(exap remo).each do |helper|
      TOPLEVEL_BINDING.eval("respond_to?(:#{helper}, true)").must_equal true
      TOPLEVEL_BINDING.eval("Object.new.respond_to?(:#{helper}, true)").must_equal false
    end
  end
end