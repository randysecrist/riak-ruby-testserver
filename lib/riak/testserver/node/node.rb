module Riak
  # A Node encapsulates the generation and management of standalone
  # Riak nodes. It is used by the {TestServer} to start and manage an
  # in-memory node for supporting integration test suites.
  class Node
    include TestServer::Translation

    # Creates a new Riak node. Unlike {#new}, this will also generate
    # the node if it does not exist on disk.  Equivalent to {::new}
    # followed by {#create}.
    # @see #new
    def self.create(configuration={})
      new(configuration).tap do |node|
        node.create
      end
    end

    # Creates the template for a Riak node. To generate the node after
    # initialization, use {#create}.
    def initialize(configuration={})
      set_defaults
      configure configuration
    end

    # @return [String] the version of the Riak node
    def version
      @version ||= configure_version
    end

    # @return [Pathname] the location of Riak installation, aka RUNNER_BASE_DIR
    def base_dir
      @base_dir ||= configure_base_dir
    end

    protected
    # Detects the Riak version from the generated release
    def debug(msg)
      $stderr.puts msg if ENV["DEBUG_RIAK_NODE"]
    end

    # Detects the Riak version from the generated release
    def configure_version
      if base_dir
        versions = (base_dir + 'releases' + 'start_erl.data').read
        versions.split(" ")[1]
      end
    end

    # Determines the base_dir from source parent
    def configure_base_dir
      source.parent
    end

  end
end
