class RedisObjectFactory
  attr_reader :type, :key, :ids, :id

  class << self
    attr_accessor :redis  
  end

  def initialize(type_, ids_)
    @type = type_
    @ids = ids_
    @id = @ids.values.join("_")
    @key = "#{@type}_#{@id}"
    initial_data
  end

  def data
    data = Hash.new(0)
    data.merge(self.class.redis.hgetall @key)
  end

  def initial_data
    @initial_data ||= data
  end
end
