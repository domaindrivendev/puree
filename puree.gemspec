# -*- encoding: utf-8 -*-
require File.expand_path('../lib/puree/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Richard Morris"]
  gem.email         = ["richieinthecloud@gmail.com"]
  gem.description   = %q{"Lightweight framework for creating DDD / CQRS based apps with a pure domain model of plain old ruby objects (PORO's)"}
  gem.summary       = %q{Lightweight framework for creating DDD / CQRS based apps with a pure domain model of plain old ruby objects (PORO's)}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "puree"
  gem.require_paths = ["lib"]
  gem.version       = Puree::VERSION
end
