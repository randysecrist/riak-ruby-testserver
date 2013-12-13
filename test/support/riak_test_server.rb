require 'riak/testserver'
require 'singleton'

class RiakNotFound < StandardError; end

module Example
  # Extends the {Riak::TestServer} to be aware of the Example
  # configuration and adjust settings appropriately. Also simplifies
  # its usage in the generation of test helpers.
  class TestServer < Riak::TestServer::Harness
    include Singleton
    attr_accessor :remote

    # Creates and starts the test server
    def self.setup
      unless instance.remote
        instance.recreate

        # compile any erlang sources
        instance.erlang_sources.each do |p|
          `#{instance.root}/erts-*/bin/erlc -o #{p} #{p}/*` if p.exist?
        end

        instance.start
        status = Timeout.timeout(20) {
          `#{instance.admin_script} wait-for-service riak_kv #{instance.name}`
        }
      end
    end

    def self.clear
      unless instance.remote
        instance.drop
      end
    end

    def self.destroy
      unless instance.remote
        instance.destroy
      end
    end

    def validate_riak_location(bin_dir)
      return nil unless bin_dir
      # what my human brain does when making sure the bin_dir has everything
      subdirs = Dir.entries(File.expand_path('..', bin_dir))
      subdirs[2] == 'bin' && subdirs[3] == 'data' && subdirs[4].match(/erts/) &&
      subdirs[5] == 'etc' && subdirs[6] == 'lib' && subdirs[7] == 'log' &&
      subdirs[8] == 'releases'
      # testserver doesn't care about the solr-webapp 'yet'
    end

    def find_riak
      # best reasonable guess (using path) at finding riak for developer use
      path_result = ENV['PATH'].split(':').detect { |dir| File.exists?(dir + '/riak') }
      if path_result
        potential_path = File.absolute_path(File.readlink("#{path_result}/riak"), path_result)
        if potential_path.match /Cellar/ #homebrew
          potential_path = File.expand_path('../../libexec/bin', potential_path)
        end
      end

      # setting the env variable should trump any guesses
      riak_bin_dir = ENV['RIAK_BIN_DIR'] || potential_path
      unless validate_riak_location(riak_bin_dir)
        raise RiakNotFound.new <<-EOM

You must have riak installed and in your path to run the tests
or you can define the environment variable RIAK_BIN_DIR to
tell the tests where to find RIAK_BIN_DIR. For example:

    export RIAK_BIN_DIR=/path/to/riak/bin

      EOM
        exit 1
      end
      return riak_bin_dir
    end

    @private
    def initialize(options=Riak::TestServer.config.dup)
      @remote = Riak::TestServer.config[:skip_testserver]
      @remote = true unless Riak::TestServer.config[:host] == "127.0.0.1"

      unless @remote
        options[:root] ||= (ENV['RIAK_TEST_PATH'] || '/tmp/.example.riak')
        options[:env] ||= {}
        options[:env][:riak_kv] ||= {}
        if js_source_dir = Riak::TestServer.config.delete(:js_source_dir)
          options[:env][:riak_kv][:js_source_dir] ||= js_source_dir
        end
        options[:env][:riak_kv][:allow_strfun] = true
        options[:env][:riak_kv][:map_cache_size] ||= 0
        options[:env][:riak_kv][:http_url_encoding] = :on
        (options[:env][:riak_kv][:add_paths] ||= []) << File.expand_path('./lib/erl_src')
        options[:env][:riak_core] ||= {}
        options[:env][:riak_core][:http] ||= [ Tuple[Riak::TestServer.config[:host], Riak::TestServer.config[:http_port]] ]
        options[:env][:riak_core][:handoff_port] ||= Riak::TestServer.config[:handoff_port]
        options[:env][:riak_core][:slide_private_dir] ||= options[:root] + '/slide-data'
        options[:env][:riak_api] ||= {}
        options[:env][:riak_api][:pb_port] ||= Riak::TestServer.config[:pb_port]
        options[:env][:riak_api][:pb_ip] ||= Riak::TestServer.config[:host]
        options[:source] ||= find_riak
        super(options)
      end
    end
  end
end

class TestServerShim
  def recycle
    Example::TestServer.clear
  end
end

$test_server = TestServerShim.new
