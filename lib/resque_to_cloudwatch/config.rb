# frozen_string_literal: true

require 'yaml'
require 'erb'

module ResqueToCloudwatch
  class Config
    attr_reader :access_key_id, :secret_access_key, :project, :period, :region
    attr_reader :redis_host, :redis_port, :hostname
    attr_reader :graphite_host, :graphite_port, :enable_graphite
    attr_reader :namespace, :dimensions
    attr_accessor :logger

    def initialize(path)
      raise "Config file #{path} not found or readable" unless File.exist?(path)

      @required_opts = %w[access_key_id secret_access_key project dimensions period region redis_host redis_port namespace]
      @hash = begin
                YAML.safe_load(ERB.new(File.read(path)).result, [Symbol])
              rescue StandardError
                nil
              end
      raise "Config file #{path} is empty" unless @hash

      @logger = Logger.new(STDOUT)
      logger.info 'Loading configuration'
      validate_config
      @hash.each_pair do |opt, value|
        # Support old-style where region is not an array
        value = [value] if opt == 'region' && value.is_a?(String)
        instance_variable_set("@#{opt}", value)
        logger.info "Config parameter: #{opt} is #{value}"
      end

      # Set up AWS credentials
      ::Aws.config.update(
        access_key_id: @hash['access_key_id'],
        secret_access_key: @hash['secret_access_key']
      )
    end

    private

    def validate_config
      missing_opts = @required_opts.select do |opt|
        @hash[opt].nil?
      end
      raise "Missing options: #{missing_opts.join(', ')}" unless missing_opts.empty?

      if @hash['enable_graphite']
        raise 'Graphite enabled but config missing graphite_host' if @hash['graphite_host'].nil?

        @hash['graphite_port'] ||= 2003
      else
        @hash['enable_graphite'] = false
      end
    end
  end
end
