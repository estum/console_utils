require 'spec_helper'

ConsoleUtils::ActiveRecordUtils.extended(nil)

describe ConsoleUtils::ActiveRecordUtils::RandomRecord::FinderMethods do
  it 'should return random record' do
    User.anyone.must_be_kind_of(ActiveRecord::Base)
  end

  it 'should return random record id' do
    assert_includes [1,2], User.anyid
  end
end
