# Load the rails application
require File.expand_path('../application', __FILE__)

Rails::Initializer.run do |config|
  config.gem 'pusher'
end

# Initialize the rails application
Haltertop::Application.initialize!

Pusher.app_id = '5414'
Pusher.key = 'e0b03bb1cb7d458de516'
Pusher.secret = '8a8e8d9612f7391352e8'