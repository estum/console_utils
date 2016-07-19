require 'rails'
require 'rails/all'
require 'active_support/core_ext'

require 'pry-rails'

# Initialize our test app

require 'console_utils'

class TestApp < Rails::Application
  config.active_support.deprecation = :log
  config.eager_load = false

  config.secret_token = 'a' * 100

  config.root = File.expand_path('../..', __FILE__)
  config.active_support.test_order = :random
end

TestApp.initialize!

# Create in-memory database
ActiveRecord::Migration.verbose = false

ActiveRecord::Schema.define do
  create_table :users do |t|
    t.string :name
  end

  create_table :posts do |t|
    t.belongs_to :user
    t.string :title
  end
end

# Define models

class User < ActiveRecord::Base
  has_many :posts
end

class Post < ActiveRecord::Base
  belongs_to :user
end