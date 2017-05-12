require 'dalli'

class UberCache
  OBJ_MAX_SIZE = 1000000
  
  @client = nil
  @cache_prefix
  @hosts

  def initialize(cache_prefix, hosts, opts = {})
    @cache_prefix = cache_prefix
    @dalli_opts = opts
    @hosts = hosts
  end

  # read from the cache
  def read(key)
    client.get(keyify(key))
  end

  # write to the cache - value will pull from passed block if block is passed.
  def write(key, value = nil, opts = {}, &blk)
    value = blk.call() if blk
    ttl = opts[:ttl]
    client.set(keyify(key), value, ttl)
  end

  def read_or_write(key, opts = {}, &blk)
    found = client.get(keyify(key))
    return found unless found.nil?
    value = nil
    value = blk.call() if blk
    ttl = opts[:ttl]
    client.set(keyify(key), value, ttl)
    return value
  end

  def clear(key)
    client.set(keyify(key), nil)
  end

  def clear_all
    client.flush
  end
  
  #UberObjectCache
  def obj_read(master_key)
    data = []
    segment = 0
    while(more_data = read("#{master_key}-#{segment}"))
      data << more_data
      segment += 1
    end
    return nil if data.length == 0
    return Marshal::load(data.join(""))
  end

  def obj_write(master_key, obj = nil, opts = {}, &blk)
    obj = blk.call() if blk
    max_size = opts.delete(:max_size) || OBJ_MAX_SIZE
    data = Marshal::dump(obj)
    segment = 0
    while(data)
      write("#{master_key}-#{segment}", data.slice(0, max_size), opts)
      data = data.slice(max_size, data.length)
      segment += 1
    end
    clear("#{master_key}-#{segment}")
  end

  def obj_clear(master_key)
    clear("#{master_key}-0")
  end

  def obj_read_or_write(master_key, opts = {}, &blk)
    found = obj_read(master_key)
    reload = opts.delete(:reload) || false
    return found if found && !reload
    value = nil
    value = blk.call() if blk
    obj_write(master_key, value, opts)
    return value
  end

  private
  def client
    @client ||= Dalli::Client.new(@hosts, @dalli_opts)
  end

  #namespace the keys - to not kill other stuff.
  def keyify(key)
    "#{@cache_prefix}:#{key}"
  end
  
end
