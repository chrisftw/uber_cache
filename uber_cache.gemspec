Gem::Specification.new do |s|
  s.name        = 'uber_cache'
  s.version     = '0.0.2'
  s.date        = '2017-05-12'
  s.summary     = "Simple Caching Wrapper for Dalli/Memcache"
  s.description = "Simple Caching Wrapper for Dalli/Memcache - Built to make caching a little easier."
  s.authors     = ["Chris Reister"]
  s.email       = 'chris@chrisreister.com'
  s.files       = ["lib/uber_cache.rb"]
  s.homepage    = 'https://github.com/chrisftw/uber_cache'
  s.license     = 'MIT'
  
  s.add_dependency 'dalli', "~> 2.0"
  s.add_development_dependency 'rspec', '~> 0'
end
