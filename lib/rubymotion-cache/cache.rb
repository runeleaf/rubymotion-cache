module Cache

  def setup
    self.class::KEY.each {|k,v| self.send("#{k.to_s}=", Cache.read(self.class::KEY[k])) }
  end

  def save
    self.class::KEY.each {|k,v| Cache.write(self.class::KEY[k], self.send(k.to_s)) }
    true
  end

  module ClassMethods
    def keys
      NSUserDefaults.standarduserDefaults.dictionaryRepresentation
    end

    def write(key, data)
      NSUserDefaults.standardUserDefaults[cache_key(key)] = data
      NSUserDefaults.standardUserDefaults[timestamp_key(key)] = Time.now
      self.synchronize
    end

    def read(key)
      NSUserDefaults.standardUserDefaults[cache_key(key)]
    end

    def delete(key)
      NSUserDefaults.standardUserDefaults.removeObjectForKey(cache_key(key))
      self.synchronize
    end

    def exists?(key)
      !NSUserDefaults.standardUserDefaults[cache_key(key)].nil? && Time.now - NSUserDefaults.standardUserDefaults[timestamp_key(key)] <= 3600
    end

    def synchronize
      NSUserDefaults.standardUserDefaults.synchronize
    end

    def purge
      keys.each do |key|
        self.delete(key) if key =~ keyspace
      end
      self.synchronize
    end

    def get(sym)
      self.read(self::KEY[sym])
    end

    def put(sym, data)
      self.write(self::KEY[sym], data)
    end

    def cachekey_name(str)
      @keyspace = str
    end

    private
    def keyspace
      @keyspace ||= "near-app-key"
    end

    def cache_key(key)
      "#{keyspace}-#{key}"
    end

    def timestamp_key(key)
      "#{cache_key(key)}-timestamp"
    end
  end

  extend ClassMethods

  def self.included(klass)
    klass.extend ClassMethods
  end
end
