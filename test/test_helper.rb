require 'bundler/setup'
require 'database_cleaner/mongoid'
require 'minitest'
require 'minitest/autorun'
require 'minitest/spec'

require 'mongoid'
require 'mongoid_recurring'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

if ENV["CI"]
  require "coveralls"
  Coveralls.wear!
end

Mongoid.configure do |config|
  config.connect_to('mongoid_recurring_test')
end

Mongoid.logger.level = Logger::INFO
Mongo::Logger.logger.level = Logger::INFO

class Minitest::Spec
  before(:each) { DatabaseCleaner.start }
  after(:each) { DatabaseCleaner.clean }
end

# ---------------------------------------------------------------------

class MyDocument
  include Mongoid::Document
  include MongoidRecurring::HasRecurringFields
  has_recurring_fields
end
