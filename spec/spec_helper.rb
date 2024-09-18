ENV["RAILS_ENV"] = "test"
require "database_cleaner"
require "bundler/setup"
require "scenic_firebird_adapter"
require "scenic"

ActiveRecord::Base.establish_connection(
  adapter: "firebird",
  database: ":memory:",
  verbosity: "quiet"
)

RSpec.configure do |config|
  config.order = "random"

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  DatabaseCleaner.strategy = :transaction

  config.around(:each) do |example|
    DatabaseCleaner.start
    example.run
    DatabaseCleaner.clean
  end
end
