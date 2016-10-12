module HubHop
module SkyScannerAPI
class Throttle
  def initialize(limit, per, mutex = Mutex.new)
    @limit, @per, @mutex = limit, per, mutex
    @times = []
    @queue = []
  end

  def delay(&block)
    id = create_id
    add_to_queue id
    until me_next? id do
      Throttle::sleeep 1
    end
    while limit_exeeded? do
      Throttle::sleeep 1
    end
    add_to_limits
    pop_from_queue
    block.call
  end

  private

  def self.sleeep(n)
    sleep n
  end

  def create_id
    (@queue.sort.last || -1) + 1
  end

  def add_to_queue(id)
    @mutex.synchronize do
      @queue.push id
    end
  end

  def pop_from_queue
    @mutex.synchronize do
      @queue.shift
    end
  end

  def me_next?(id)
    @mutex.synchronize do
      @queue.first == id
    end
  end

  def add_to_limits
    @mutex.synchronize do
      @times.push Time.now
    end
  end

  def limit_exeeded?
    @mutex.synchronize do
      @times.reject! { |x| Throttle.time_passed?(x, @per) }
      @times.size >= @limit 
    end
  end

  def self.time_passed?(since, interval)
    Time.now - since > interval
  end
end
end
end
