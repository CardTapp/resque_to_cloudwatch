require 'aws-sdk-cloudwatch'

module ResqueToCloudwatch
  class CloudwatchSender
    
    # Pass an instance of CloudwatchToResque::Config
    def initialize(config)
      @config = config
    end
    
    def send_value(value, metric_name)
      @config.region.each do |region|
        dimensions = []
        dimensions << {:name => 'project', :value => @config.project}
        dimensions << {:name => 'hostname', :value => @config.hostname} unless @config.hostname.nil?
        cw = ::Aws::CloudWatch::Client.new(region: region)
        cw.put_metric_data({
          :namespace      => "#{@config.namespace}/resque",
          :metric_data    => [
            :metric_name  => metric_name,
            :dimensions   => dimensions,
            :value => value,
            :unit  => 'Count'
          ]
        })
        $log.info "CloudwatchSender: Sent metric value #{value} for #{metric_name} to region #{region}"
      end
    end
    
    def inspect
      to_s
    end
    
    def to_s
      "CloudwatchSender"
    end
    
  end
  
end
