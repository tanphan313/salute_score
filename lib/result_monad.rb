class ResultMonad
  def initialize
    begin
      @value = yield if block_given?
      @error = nil
    rescue => e
      @error = e
    end
  end

  def to_s
    if ok?
      "#<ResultMonad:0x%x value: %s>" % [object_id, @value.inspect]
    else
      "#<ResultMonad:0x%x error: %s>" % [object_id, @error.inspect]
    end
  end

  alias_method :inspect, :to_s

  def then
    if ok?
      ResultMonad.new { yield(@value) }
    else
      self
    end
  end

  def rescue
    return self if ok?
    ResultMonad.new{ yield(@error) }
  end

  def map
    if ok?
      ResultMonad.new { yield(@value) }
    else
      self
    end
  end

  def value
    unless block_given?
      raise ArgumentError, "must provide a block to ResultMonad#value to be invoked in case of error"
    end

    if ok?
      @value
    else
      yield(@error)
    end
  end

  def value!
    if ok?
      @value
    else
      raise @error
    end
  end

  def ok?
    !@error
  end

  def error
    @error
  end

  def self.error(e)
    result = allocate
    result.instance_variable_set(:@error, e)
    result
  end
end
