require 'spec_helper'

describe ConsoleUtils do
  it 'has a version number' do
    expect(ConsoleUtils::VERSION).not_to be nil
  end

  it { is_expected.to have_attributes(request_methods: %i(get post put delete patch head)) }

  xit 'does something useful' do
    expect(false).to eq(true)
  end
end
