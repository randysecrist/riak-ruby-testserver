# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'riak/testserver/version'

Gem::Specification.new do |spec|
  spec.name          = "riak-ruby-testserver"
  spec.version       = Riak::TestServer::VERSION
  spec.authors       = ["Randy Secrist"]
  spec.email         = ["randy.secrist@gmail.com"]
  spec.description   = %q{Generates a developer friendly Riak instance.}
  spec.summary       = %q{May be handy for test suites which expect a clean data slate.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'i18n'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'

  spec.add_development_dependency 'riak-client'

  spec.add_development_dependency 'rack-test'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'minitest'
  #spec.add_development_dependency 'mini_shoulda'
  spec.add_development_dependency 'ruby-prof'
  spec.add_development_dependency 'debugger'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'webmock'
  spec.add_development_dependency 'faker'
end
