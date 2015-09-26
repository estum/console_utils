require 'spec_helper'

describe ConsoleUtils do
  it 'has a version number' do
    ConsoleUtils::VERSION.wont_be_nil
  end

  it 'should contain the base request methods' do
    %i(get post put delete patch head).each do |rm|
      ConsoleUtils.request_methods.must_include rm
    end
  end
end
