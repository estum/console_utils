# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'console_utils/version'

Gem::Specification.new do |spec|
  spec.name          = "console_utils"
  spec.version       = ConsoleUtils::VERSION
  spec.authors       = ["Anton"]
  spec.email         = ["anton.estum@gmail.com"]

  spec.summary       = %q{Groovy tools for Rails Console.}
  spec.description   = %q{Console Utils provides several handy tools to use in Rails Console.}
  spec.homepage      = "https://github.com/estum/console_utils"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(spec)/}) }
  spec.require_paths = ["lib"]
  spec.required_ruby_version = ">= 2.1"

  spec.add_dependency "activesupport", ">= 5.2", "< 7"
  spec.add_dependency "pastel"
  spec.add_dependency "awesome_print"
  spec.add_dependency "benchmark-ips"
  spec.add_dependency "pry-rails"
  # spec.add_dependency 'sourcify', '~> 0.6.0.rc4'

  spec.add_development_dependency "rdoc"
  spec.add_development_dependency "appraisal"
  spec.add_development_dependency "minitest"
end
