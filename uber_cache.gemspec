Gem::Specification.new do |s|
  s.name        = 'UberCache'
  s.version     = '0.0.1'
  s.date        = '2014-06-06'
  s.summary     = "Simple Caching Wrapper for Dalli/Memcache"
  s.description = "Simple Caching Wrapper for Dalli/Memcache"
  s.authors     = ["Chris Reister"]
  s.email       = 'chris@chrisreister.com'
  s.files       = ["lib/uber_cache.rb"]
  s.homepage    = 'https://github.com/chrisftw/uber_cache'
  s.license     = 'MIT'
  
  s.add_dependency 'dalli', "~> 2.0"
  s.add_development_dependency 'rspec'
end
