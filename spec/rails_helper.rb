require "spec_helper"

require File.expand_path("../../config/environment", __FILE__)
require "rspec/rails"
require "webmock/rspec"
require "pry"

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

VCR.configure do |c|
  c.cassette_library_dir = "spec/cassettes"
  c.hook_into :webmock
  c.ignore_localhost = true
  c.configure_rspec_metadata!
  c.filter_sensitive_data("<KEY>") { ENV['ST_GITHUB_CLIENT_ID'] }
  c.filter_sensitive_data("<KEY>") { ENV['ST_GITHUB_CLIENT_SECRET'] }
end

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures/"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false
  config.infer_spec_type_from_file_location!

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  config.before(:each) do |example|
    Rails.cache.clear
  end
end
