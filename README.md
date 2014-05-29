# UberCache

### About

UberCache is a simple wrapper for complex Memcache operations, using Dalli.

This gem is an abstraction of code I have been using in production for a while, to make caching more simple, and manageable throughout many applications.

### Install UberCache:

in your Gemfile:

    gem "uber_cache"

and bundle install!

Wow, that was easy.

### How to use UberCache:

UberCache is meant to be super simple.  With simple read, write, read_or_write, clear and clear_all methods.

    @cache = UberCache.new("cars-dev", "localhost:11211")
    
    @cache.write("foo_key", "bar_value")
    >> "bar_value"
    @cache.read("foo_key")
    >> "bar_value"
    @cache.read_or_write("foo_key") {
      "something else"
    }
    >> "bar_value"
    @cache.clear("foo_key")
    @cache.read_or_write("foo_key") {
      "something else"
    }
    >> "something else"
    @cache.clear_all

Also UberCache stores LARGE object, too big for normal Memcache/Dalli, using the obj_read, obj_write, obj_read_or_write methods.

    @cache = UberCache.new("cars-dev", "localhost:11211")
    
    @cache.obj_write("bar_key", my_obj)
    >> my_obj
    @cache.obj_read("bar_key")
    >> my_obj
    @cache.obj_read_or_write("bar_key") {
      other_obj
    }
    >> my_obj
    @cache.clear("bar_key")
    @cache.read_or_write("bar_key") {
      other_obj
    }
    >> other_obj
    @cache.clear_all
