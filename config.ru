CPU_PERCENT = 0.75
IO_WAIT_PERCENT = 0.25
raise "CPU+IO does not equal 1!" unless CPU_PERCENT+IO_WAIT_PERCENT == 1
RESPONSE_TIME_SECONDS=0.25
GARBAGE_OBJECTS_COUNT = 300_000
TICK_RATE_SECONDS = 0.01

puts "Testing with:"
puts "#{CPU_PERCENT * 100}% time spent waiting on CPU"
puts "#{IO_WAIT_PERCENT * 100}% time spent waiting on IO"
puts "#{RESPONSE_TIME_SECONDS} seconds average response duration (approximate, not including GC)"
puts "#{GARBAGE_OBJECTS_COUNT} objects are generated w/each request"
puts "We will decide to do CPU or IO every #{TICK_RATE_SECONDS * 1000.0} milliseconds"

def cpu_spin(seconds)
  time = Time.now
  while (time + seconds) > Time.now
  end
end

APP = lambda do |env|
  ticks_remaining = Integer(RESPONSE_TIME_SECONDS/TICK_RATE_SECONDS)

  GARBAGE_OBJECTS_COUNT.times { "a" } # simulate creating + discarding objects for each request

  until ticks_remaining == 0
    case rand(0.0..1.0)
    when (0.0..CPU_PERCENT)
      cpu_spin(TICK_RATE_SECONDS)
    else
      sleep(TICK_RATE_SECONDS)
    end
    ticks_remaining -= 1
  end

  [200, {'Content-Type' => 'text/plain'}, ['Hello World']]
end

run APP

# Thread.new do
#   sleep 5
#   puts GC.stat
# end