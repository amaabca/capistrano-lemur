# See http://unicorn.bogomips.org/Unicorn/Configurator.html for complete
# documentation.

# https://github.com/grosser/parallel/blob/master/lib/parallel.rb#L65
def processor_count
  case RbConfig::CONFIG['host_os']
  when /darwin9/
    `hwprefs cpu_count`.to_i
  when /darwin/
    (`which hwprefs` != '' ? `hwprefs thread_count` : `sysctl -n hw.ncpu`).to_i
  when /linux/
    `grep -c processor /proc/cpuinfo`.to_i
  when /freebsd/
    `sysctl -n hw.ncpu`.to_i
  when /mswin|mingw/
    require 'win32ole'
    wmi = WIN32OLE.connect("winmgmts://")
    cpu = wmi.ExecQuery("select NumberOfLogicalProcessors from Win32_Processor")
    cpu.to_enum.first.NumberOfLogicalProcessors
  else
    $stderr.puts "Unknown architecture ( #{RbConfig::CONFIG["host_os"]} ) assuming one processor."
    1
  end
end

# Use value in UNICORN_WORKERS, or one worker per core in production and 2
# otherwise (development, etc.)
num_workers = if ENV['UNICORN_WORKERS']
                ENV['UNICORN_WORKERS'].to_i
              elsif ENV['RACK_ENV'] == 'production'
                processor_count
              else
               2
              end
worker_processes (num_workers)
  
unless ENV['HEROKU']
  pid         "tmp/pids/unicorn.pid"
  stdout_path "log/unicorn.stdout.log"
  stderr_path "log/unicorn.stderr.log"

  # listen on a unix domain socket (additional tcp ports may be passed into to
  # unicorn with the -p flag)
  listen File.expand_path("#{File.dirname(__FILE__)}/../tmp/sockets/unicorn.sock")
end

# Nuke workers after 30 seconds instead of 60 seconds (the default)
timeout 30

# Load application into the master before forking workers for super-fast
# worker spawn times
preload_app true

# REE copy-on-write memory savings, if available
GC.copy_on_write_friendly = true  if GC.respond_to?(:copy_on_write_friendly=)

before_fork do |server, worker|
  # Highly recomended for Rails + "preload_app true" as there's no need for
  # the master process to hold a connection
  ActiveRecord::Base.connection.disconnect! if defined?(ActiveRecord::Base)

  # Zero down time deploys. See:
  # * https://github.com/blog/517-unicorn
  # * https://gist.github.com/206253
  old_pid = "#{server.config[:pid]}.oldbin"
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end

after_fork do |server, worker|
  # Establish a connection as the worker
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord::Base)
end