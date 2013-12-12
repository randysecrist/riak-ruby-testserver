$:.unshift(File.join(File.dirname(__FILE__), '..'))
$:.unshift(File.dirname(__FILE__))

ENV['RACK_ENV'] = 'test'
ROOT_TEST = File.expand_path(File.dirname(__FILE__))

#require 'minitest/unit'
require 'simplecov'
SimpleCov.start do
  project_name "Riak Test Server"

  add_filter "/test/"

  add_group "Library", "lib"
end
# prevent early calculation of coverage stats
SimpleCov.at_exit {}

require 'rack/test'
require 'shoulda'
require 'pathname'

puts 'Loading Library ...'
require 'lib/riak/testserver'

# fire up test server before loading app
require 'test/support/riak_test_server'
Riak::TestServer.load_config(File.join('config','riak.yml.example'), ENV['RACK_ENV'].to_sym)

puts 'Setting up Temporary Database ...'
Example::TestServer.setup

# these execute in reverse order on exit
success = false
at_exit { exit! success } # check for hooks added after this if tests pass; and success is still == false
at_exit { puts 'Suite Tear Down' }
at_exit {
  # Spit out coverage stats.
  SimpleCov.result.format!
}
at_exit do
  # https://github.com/test-unit/test-unit/blob/v2.5.3/lib/test/unit.rb#L501
  if $!.nil? and Test::Unit::AutoRunner.need_auto_run?
    success = Test::Unit::AutoRunner.run
    Example::TestServer.destroy unless Riak::TestServer.config[:retain_test_server] == true
    success
  end
end
at_exit { puts 'Starting Tests ...' }

require 'webmock'
WebMock.disable_net_connect! allow_localhost: true, allow: ["#{Riak::TestServer.config[:host]}:#{Riak::TestServer.config[:http_port]}"]

ROOT_DIR = File.expand_path(File.join(File.dirname(__FILE__), '.'))
FIXTURES_PATH = Pathname.new(File.join(ROOT_DIR,'support','fixtures'))

require 'faker'

class ::Test::Unit::TestCase
  include Rack::Test::Methods

  def valid_user_details
    @user_data ||=  {
      :name => Faker::Name.name,
      :gender => 'm',
      :locale => "#{Faker::Address.city}, #{Faker::Address.state_abbr}",
      :email => Faker::Internet.email,
      :phone_numbers =>[Faker::PhoneNumber.phone_number, Faker::PhoneNumber.cell_phone],
      :birthdate => '2013-07-30T11:21:24Z',
      :sources => []
    }
  end

  def assert_starts_with(expected, actual)
    assert !(actual.match /^#{expected}/).nil?, "Expected " + actual + " to start with " + expected
  end
end
