require 'spec_helper'

describe ConsoleUtils do
  it 'has a version number' do
    _(ConsoleUtils::VERSION).wont_be_nil
  end

  it 'should contain the base request methods' do
    %i(get post put delete patch head).each do |rm|
      _(ConsoleUtils.request_methods).must_include rm
    end
  end

  it "shouldn't have disabled modules by default" do
    _(ConsoleUtils.disabled_modules).must_be_empty
  end
end