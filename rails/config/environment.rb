# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
TestBed::Application.initialize!

RubyAMF.configure do |config|
  config.gateway_path = "/amf"
end