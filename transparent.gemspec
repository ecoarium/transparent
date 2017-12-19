# -*- encoding: utf-8 -*-
$:.push File.expand_path("lib", File.dirname(__FILE__))

require 'transparent/version'

Gem::Specification.new do |gem|
  gem.name    = "transparent"
  gem.version       = Transparent::VERSION
  gem.description = "transparency"
  gem.summary       = gem.description
  gem.author  = "Jay Flowers"
  gem.email = ['jay.flowers@gmail.com']

  gem.files =  Dir.glob("lib/**/*.rb")
  gem.files << 'transparent.gemspec'

  gem.extensions << "ext/engine/extconf.rb"

	gem.add_dependency 'json', 		'~> 1.8'
	gem.add_dependency 'coercible', '~> 1.0'
	gem.add_dependency 'descendants_tracker', '~> 0.0'
	gem.add_dependency 'symmetric-encryption', '~> 3.6'
	gem.add_dependency 'thread_safe', '~> 0.3'

	gem.add_development_dependency 'sshkey',		'~> 1.6'
	gem.add_development_dependency 'rake-compiler', '~> 0.8'

  gem.require_paths = ["lib"]
end
