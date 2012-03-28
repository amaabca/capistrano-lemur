Capistrano::Configuration.instance.load do
  
      set(:unicorn_target) { current_path }

      # TODO: make this more generic once we start using in multiple apps
      namespace :unicorn do

        # override default tasks to make capistrano happy
        desc "LMR Start unicorn"
        task :start, :roles => :app do
          #start_primary
          #start_secondary unless (find_servers :roles => :app, :except => {:primary => true}).empty?
          run "cd #{current_path} && bundle exec unicorn -c #{unicorn_target}/config/unicorn.rb -E #{rails_env} -D"
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

      after "deploy:start",   "unicorn:start"
      after "deploy:restart", "unicorn:restart"
      after "deploy:stop",    "unicorn:stop"
    
end
