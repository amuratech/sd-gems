Gem::Specification.new do |s|
  s.name = %q{sd_auth}
  s.version = "1.0.0"
  s.date = %q{2021-11-24}
  s.summary = %q{sd_auth provides authentication for ruby services}
  s.files = Dir["lib/**/*"]
  s.require_paths = ["lib"]
  s.authors = ['shweta.kale@kylas.io', 'tanmay.ghawate@kylas.io']
  s.add_dependency 'jwt', '~>2.2.3'
  s.add_dependency 'underscorize_keys', '~> 0.0.1'
  s.add_dependency 'rest-client', '~> 2.1.0'
  s.add_dependency 'multi_json', '~> 1.15.0'
  s.add_dependency 'json-schema', '~> 2.8.1'
  s.add_development_dependency 'webmock', '~> 3.12.2'
end