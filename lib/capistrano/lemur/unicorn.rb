Capistrano::Configuration.instance.load do
  
      set(:unicorn_target) { shared_path }

      # TODO: make this more generic once we start using in multiple apps
      namespace :deploy do

        # override default tasks to make capistrano happy
        desc "LMR Start unicorn"
        task :start, :roles => :app do
          start_primary
          start_secondary unless (find_servers :roles => :app, :except => {:primary => true}).empty?
        end

        desc "LMR Start unicorn on primary server"
        task :start_primary, :roles => :app, :only => { :primary => true } do
          run "cd #{current_path} && server=primary bundle exec unicorn -c #{current_path}/config/unicorn.rb -E #{rails_env} -D"
        end
  
        desc "LMR Start unicorn on secondary server(s)"
        task :start_secondary, :roles => :app, :except => { :primary => true } do
          run "cd #{current_path} && server=secondary bundle exec unicorn -c #{current_path}/config/unicorn.rb -E #{rails_env} -D"
        end
  
        desc "LMR Start unicorn on primary server"
        task :stop_primary, :roles => :app, :only => { :primary => true } do
          run "kill -QUIT `cat #{unicorn_target}/tmp/pids/unicorn.pid`"
          sleep 2
          start_primary
        end
  
        desc "LMR Start unicorn on secondary server(s)"
        task :stop_secondary, :roles => :app, :except => { :primary => true } do
          run "kill -QUIT `cat #{unicorn_target}/tmp/pids/unicorn.pid`"
          sleep 2
          start_secondary
        end

        desc "LMR Kick unicorn"
        task :restart, :roles => :app do
          run "kill -USR2 `cat #{unicorn_target}/tmp/pids/unicorn.pid`"
        end

        desc "LMR Kill a unicorn"
        task :stop, :roles => :app do
          run "kill -QUIT `cat #{unicorn_target}/tmp/pids/unicorn.pid`"
        end
        
      end
    
    
    namespace :unicorn do   

      desc "Generate Unicorn configuration file"
      task :generate_config, :roles => :app do
        if Capistrano::CLI.ui.ask("This is a dangerous task. Type 'yes sir' to continue.") == 'yes sir'
          config = fetch(:unicorn_template, File.read(File.join(File.dirname(__FILE__), 'config/unicorn.rb' )))
          run "mkdir -p #{unicorn_target}/config"
          put config, "#{current_path}/config/unicorn.rb"
        else
          puts "Unicorn configuration change aborted"
        end
      end
      
      before "nginx:restart", "deploy:start"
      
    end
end