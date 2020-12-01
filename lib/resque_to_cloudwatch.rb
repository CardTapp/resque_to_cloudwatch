require 'logger'

require_relative "resque_to_cloudwatch/config.rb"
require_relative "resque_to_cloudwatch/cloudwatch_sender.rb"
require_relative "resque_to_cloudwatch/graphite_sender.rb"
require_relative "resque_to_cloudwatch/collectors.rb"