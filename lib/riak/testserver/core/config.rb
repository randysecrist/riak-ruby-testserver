require 'erb'
require 'yaml'
require 'riak'

# Contains the classes and modules related to the ODM built on top of
# the basic Riak client.
module Riak
  module TestServer

    class << self
      # @return [Riak::Client] The client for the current thread.
      def client
        Thread.current[:riak_client] ||= Riak::Client.new(client_config)
      end

      # Sets the client for the current thread.
      # @param [Riak::Client] value the client
      def client=(value)
        Thread.current[:riak_client] = value
      end

      # Sets the global Riak configuration.
      def config=(hash)
        self.client = nil
        @config = hash.symbolize_keys
      end

      # Reads the global Riak configuration.
      def config
        @config ||= {}
      end

      # Loads the Riak configuration from a given YAML file.
      # Evaluates the configuration with ERB before loading.
      def load_config(config_file, env_key = :test)
        config_file = File.expand_path(config_file)
        config_hash = symbolize_keys(YAML.load(ERB.new(File.read(config_file)).result))[env_key]
        configure_ports(config_hash)
        self.config = config_hash || {}
        rescue Errno::ENOENT
          raise Riak::TestServer::MissingConfiguration.new(config_file)
      end

      private
      def client_config
        config.slice(*Riak::Client::VALID_OPTIONS)
      end

      def configure_ports(config)
        return unless config && config[:min_port]
        config[:http_port] ||= (config[:min_port].to_i)
        config[:pb_port] ||= (config[:min_port].to_i + 1)
      end

      def symbolize_keys(hash)
        hash.inject({}){|result, (key, value)|
          new_key = case key
                    when String then key.to_sym
                    else key
                    end
          new_value = case value
                      when Hash then symbolize_keys(value)
                      when Array then value.map{ |v| v.is_a?(Hash) ? symbolize_keys(v) : v }
                      else value
                      end
          result[new_key] = new_value
          result
        }
      end

    end

    # Exception raised when the path passed to
    # {Riak::TestServer::load_config} does not point to a existing file.
    class MissingConfiguration < StandardError
      include Translation
      def initialize(file_path)
        super(t("missing_configuration", :file => file_path))
      end
    end

  end
end
