require_relative "lib/devise/rownd/version"

Gem::Specification.new do |spec|
  spec.name        = "devise-rownd"
  spec.version     = Devise::Rownd::VERSION
  spec.authors     = ["Bobby Radford"]
  spec.email       = ["bobby@rownd.io"]
  spec.homepage    = "https://github.com/rownd/devise-rownd"
  spec.summary     = "Rownd Authentication for Devise"
  spec.description = "A Devise extension for authenticating with Rownd"
  spec.license     = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/rownd/devise-rownd"
  spec.metadata["changelog_uri"] = "https://github.com/rownd/devise-rownd/CHANGELOG.md"

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.required_ruby_version = ">= 2.6.5"
  spec.required_rubygems_version = ">= 3.0.3"

  spec.add_dependency "devise", "~> 4.0"
  spec.add_dependency "faraday", "~> 1.0"
  spec.add_dependency "faraday_middleware", "~> 1.2.0"
  spec.add_dependency "rbnacl", "~> 7.1.1"
  spec.add_dependency "jose", "~> 1.1.3"

  spec.add_development_dependency "rails", "~> 6.1.5"
  spec.add_development_dependency "rake", "~> 13.0.6"
  spec.add_development_dependency "rubocop", "~> 1.26.1"
  spec.add_development_dependency "rubocop-performance", "~> 1.13.3"
  spec.add_development_dependency "rubocop-rake", "~> 0.6.0"
  spec.add_development_dependency "rubocop-rspec", "~> 2.9.0"
end
