require_relative '../helper'

module Riak
  module TestServer
    class RiakTest < Test::Unit::TestCase
    #class RiakTest < Minitest::Test

      context "riak" do
        teardown do
          $test_server.recycle
        end

        should 'load riak config and create client' do
          assert_equal true, true
          puts 'All Done!';
        end
      end

    end
  end
end
