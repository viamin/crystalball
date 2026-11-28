# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'crystalball/version'

Gem::Specification.new do |spec|
  spec.name          = "crystalball"
  spec.version       = Crystalball::VERSION
  spec.authors       = ["Pavel Shutsin", "Evgenii Pecherkin", "Jaimerson Araujo"]
  spec.email         = ["publicshady@gmail.com"]

  spec.summary       = 'A library for RSpec regression test selection'
  spec.description   = 'Provides simple way to integrate regression test selection approach to your RSpec test suite'
  spec.homepage      = 'https://github.com/toptal/crystalball'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "bin"
  spec.executables   = [File.basename('bin/crystalball')]
  spec.require_paths = ["lib"]

  spec.add_dependency 'git', '>= 1.13', '< 4.0'
  spec.add_dependency 'ostruct'
  spec.add_dependency 'psych', '>= 5.2', '< 6.0'
  spec.add_dependency 'rspec', '>= 3.13', '< 3.14'

  spec.required_ruby_version = '>= 3.4'

  spec.add_development_dependency 'actionview', '~> 7.2.0'
  spec.add_development_dependency 'activerecord', '~> 7.2.0'
  spec.add_development_dependency 'factory_bot', '~> 6.5'
  spec.add_development_dependency 'i18n', '~> 1.14'
  spec.add_development_dependency 'parser', '~> 3.3'
  spec.add_development_dependency 'pry', '~> 0.15'
  spec.add_development_dependency 'rake', '~> 13.2'
  spec.add_development_dependency 'rubocop', '~> 1.72.0'
  spec.add_development_dependency 'rubocop-rspec', '~> 3.5.0'
  spec.add_development_dependency 'simplecov', '~> 0.22'
  spec.add_development_dependency 'sqlite3', '~> 2.6'
  spec.add_development_dependency 'test-prof', '~> 1.4'
  spec.add_development_dependency 'yard', '~> 0.9'
end
