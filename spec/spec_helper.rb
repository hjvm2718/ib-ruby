require 'rspec'
require 'ib-ruby'

RSpec.configure do |config|
  # config.exclusion_filter = { :slow => true }
  # config.filter = { :focus => true }
  # config.include(UserExampleHelpers)
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
end

CONNECTION_OPTS = {
    #:host => 'free.brokertron.com',
    #:port=> 10501
}
