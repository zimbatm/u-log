# coding: utf-8
Gem::Specification.new do |spec|
  spec.name          = "u-log"
  spec.version       = "0.0.1"
  spec.authors       = ["zimbatm"]
  spec.email         = ["zimbatm@zimbatm.com"]
  spec.summary       = %q{a different take on logging}
  spec.description   = %q{U::Logger is a very simple logging library made for humans}
  spec.homepage      = 'https://github.com/zimbatm/u-logger'
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})

  spec.add_runtime_dependency "lines"

  spec.add_development_dependency "benchmark-ips"
  spec.add_development_dependency "minitest"
end
