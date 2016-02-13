# Load the Rails application.
puts "environment start"
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Rails.application.initialize!

puts "environment over"
