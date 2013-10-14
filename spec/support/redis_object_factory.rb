class RedisObjectFactory
  attr_reader :type, :key, :id

  class << self
    attr_accessor :redis  
  end

  def initialize(type_, id_)
    @type = type_
    @id = id_
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
