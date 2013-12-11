module Riak
  class Node
    # Settings based on Riak 1.1.
    TS_ENV_DEFAULTS = {
      :riak_api => {
      },
      :riak_core => {
        :ring_creation_size => 8
      },
      :riak_kv => {
        :storage_backend => :riak_kv_bitcask_backend,
        :map_js_vm_count => 0,
        :reduce_js_vm_count => 0,
        :hook_js_vm_count => 0,
        :mapper_batch_size => 5,
        :js_max_vm_mem => 8,
        :js_thread_stack => 16,
        :riak_kv_stat => true,
        :legacy_stats => true,
        :vnode_vclocks => true,
        :http_url_encoding => :on,
        :legacy_keylisting => false,
        :mapred_system => :pipe,
        :mapred_2i_pipe => true,
        :listkeys_backpressure => true,
        :add_paths => [],
        :anti_entropy_concurrency => 1,
        :anti_entropy_tick => 15000,
        :warn_siblings => 25,
        :max_siblings => 100,
        :warn_object_size => 1048576,
        :max_object_size => 5242880
      },
      :riak_search => {
        :enabled => false
      },
      :merge_index => {
        :buffer_rollover_size => 1048576,
        :max_compact_segments => 20
      },
      :eleveldb => {},
      :bitcask => {},
      :lager => {
        :crash_log_size => 10485760,
        :crash_log_msg_size => 65536,
        :crash_log_date => "$D0",
        :crash_log_count => 5,
        :error_logger_redirect => true
      },
      :riak_sysmon => {
        :process_limit => 30,
        :port_limit => 30,
        :gc_ms_limit => 100,
        :heap_word_limit => 40111000,
        :busy_port => true,
        :busy_dist_port => true
      },
      :sasl => {
        :sasl_error_logger => false
      },
      :riak_control => {
        :enabled => false,
        :auth => :userlist,
        :userlist => {"user" => "pass"},
        :admin => true
      },
      :yokozuna => {
        :solr_jvm_args => "-Xms128m -Xmx128m -XX:+UseStringCache -XX:+UseCompressedOops",
        :solr_jmx_port => 9003,
        :solr_port => 9004,
        :enabled => true
      }
    }.freeze

    # Based on Riak 1.1.
    TS_VM_DEFAULTS = {
      "+K" => true,
      "+A" => 16,
      "-smp" => "enable",
      "+W" => "w",
      "+P" => 64000,
      "-env ERL_MAX_PORTS" => 4096,
      "-env ERL_FULLSWEEP_AFTER" => 0
    }.freeze

    protected
    # Populates the defaults
    def set_defaults
      @env = TS_ENV_DEFAULTS.deep_dup
      @vm = TS_VM_DEFAULTS.deep_dup
    end
  end
end
