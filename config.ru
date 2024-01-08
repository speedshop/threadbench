CPU_SPIN_TIME = 0.01875
IO_WAIT_TIME = 0.00625
REPEAT = 10
GARBAGE_OBJECTS_COUNT = 300_000

puts "Testing with:"
puts "#{CPU_SPIN_TIME} seconds per CPU spin block"
puts "#{IO_WAIT_TIME} seconds per I/O wait"
puts "Each operation is repeated #{REPEAT} times"
puts "... so each request takes #{(CPU_SPIN_TIME + IO_WAIT_TIME) * REPEAT} seconds ..."
puts "... and each request is spending #{((IO_WAIT_TIME / (IO_WAIT_TIME + CPU_SPIN_TIME)) * 100).round(2)}% of its time in IO"
puts "#{GARBAGE_OBJECTS_COUNT} objects are generated w/each request"

def cpu_spin(seconds)
  time = Time.now
  while (time + seconds) > Time.now
  end
end

APP = lambda do |env|
  REPEAT.times do
    sleep(IO_WAIT_TIME)
    cpu_spin(CPU_SPIN_TIME)
  end
  GARBAGE_OBJECTS_COUNT.times { "a" }
  [200, {'Content-Type' => 'text/plain'}, ['Hello World']]
end

run APP

# Thread.new do
#   sleep 5
#   puts GC.stat
# end