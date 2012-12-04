namespace :utils do
  namespace :logs do
    desc "tail production log files"
    task :tail, :roles => :app do
      run "tail -f #{shared_path}/log/*.log /var/log/nginx/*.log" do |channel, stream, data|
        puts  # for an extra line break before the host name
        puts "#{channel[:host]}: #{data}"
        break if stream == :err
      end
    end
  end

  desc "run top on remote servers"
  task :monitor, :roles => :app do
    run "top -b" do |channel, stream, data|
      puts  # for an extra line break before the host name
      puts "#{channel[:host]}: #{data}"
      break if stream == :err
    end
  end

end