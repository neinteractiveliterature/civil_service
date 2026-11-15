
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "civil_service/version"

Gem::Specification.new do |spec|
  spec.name          = "civil_service"
  spec.version       = CivilService::VERSION
  spec.authors       = ["Nat Budin"]
  spec.email         = ["nbudin@patientslikeme.com"]

  spec.summary       = %q{A tiny service object framework for Rails apps}
  spec.description   = %q{CivilService provides a base class for your service objects.  With CivilService, you can use ActiveModel validations to do pre-flight checks before the service runs, and create your own result object classes to capture the results of complex operations.}
  spec.homepage      = "https://github.com/neinteractiveliterature/civil_service"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activemodel", ">= 3.0.0"

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "minitest", "~> 6.0"
end
