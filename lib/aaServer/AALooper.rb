# Class AALooper loops a method in a thread.
#
# @author Onereallylongname
class AALooper
  attr_reader :go, :toExecutList
  # Class Executorholds object and method to execut.
  #
  # @author Onereallylongname
  class Executor
    attr_reader :wait, :lastExec, :counter
    # Requires options hash
    #
    # @param args [Hash]
    # :object [Object] Object to run method on.
    # :method [Symbol] Name of the method.
    # :args [Array] Args for method.
    # :wait [Integer] Interval (in seconds) between executions. Default is 1.
    # :runs [Integer] Max number of times to run. Default is -1 (run forever).
    def initialize args
      @object  = args[:object] || self
      @method  = args[:method] || 'do_nothing'
      @args    = args[:args]   || nil
      @wait    = args[:wait]   || 1
      @maxRuns = args[:runs]   || -1
      @go      = false
      @lastExec= 0
      @counter = 0
      raise "Object: '#{@object}' of type '#{@object.class}' does not respond to '#{@method}'" unless @object.respond_to? @method
    end

    # Execut method
    def execut
      @object.send(@method, @args)
      add_run
    end

    # Start Object execution
    def start
      return nil if go?
      @counter = 0
      @go = true
    end

    # Stop Object from executing
    def stop
      @go = false
    end

    # Check if thread loop is running
    def go?
      return @go if @maxRuns < 0
      return (@go and (@counter < @maxRuns))
    end

    # Add one run
    def add_run
      @counter += 1
      @lastExec = Time.now
    end

    # Does nothing
    def do_nothing *args
      stop
    end

  end

  # Initialize
  def initialize
    @toExecutList = Hash.new
    @go = false
    @wait = 1
    @lastKey = 0
    @thread = nil
  end

  # Start the thread to loop method on object
  #
  # @return [nil] if loop is running
  # @return [Thread] if a new thread is started
  def start
    return nil if @toExecutList.size == 0
    @go = true
    @lastTime = 0
    calc_sleep_time
    @thread = Thread.new {
      @toExecutList.each {|k, toExec| toExec.start}
      while @go do
        timeNow = Time.now
        @toExecutList.each do |k, toExec|
          canGo = (((timeNow - toExec.lastExec).to_f >= toExec.wait) and toExec.go?)
          puts ">>> >>>  #{k} :: go? = #{toExec.go?}, canGo = #{canGo}, #{toExec.counter}"
          toExec.execut if canGo
        end
        sleep(@wait)
        @lastTime = timeNow
      end
      @go = false
    }
  end

  # Add Object and method to execute
  #
  # @param args [Hash] args for class Executor
  # @return [Symbol] key of the executor. can be used to remove the executor.
  def add_executor args
    newExecutor = Executor.new(args)
    p newExecutor
    newKey = gen_new_key
    @toExecutList[newKey] = newExecutor
    calc_sleep_time
    return newKey
  end

  # Remove Executor Object
  #
  # @param key [Symbol] Executor key
  def remove_executor key
    @toExecutList.delete(key)
    calc_sleep_time
  end

  # Get Sleep Time
  def calc_sleep_time
    waitList = []
    @toExecutList.each do |k, obj|
      waitList << obj.wait
    end
    @wait = waitList.reduce(waitList.max, :gcd)
  end

  # Get Zombies
  #
  # @return [Array] list of keys.
  def get_zombies
    (@toExecutList.select { |k, obj| !obj.go? }).keys if @go
  end

  # Stop loop and thread
  #
  # @return [Boolean] go
  def stop
    @toExecutList.each do |k, obj|
      obj.stop
    end
    @go = false
    @thread.terminate
  end

  # Restart loop and thread
  #
  # @return [Boolean] go
  def restart
    stop
    start
  end

private
  # Generate next key
  def gen_new_key
    @lastKey += 1
    return ('E' + (@lastKey).to_s).to_sym
  end

end
