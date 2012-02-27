Capistrano::Configuration.instance.load do
  namespace :nginx do
    
    set(:nginx_path) { "/etc/nginx" }
    set(:nginx_restart_cmd) {"/etc/init.d/nginx restart"}

    desc "Install nginx"
    task :setup, :roles => :web do
      confirm = Capistrano::CLI.ui.ask "This is a dangerous task. Type 'yes sir' to continue."
      if confirm.downcase == 'yes sir'
        location = Capistrano::CLI.ui.ask "Filename of nginx config file (blank for default of config/templates/appname.stage)?"
        location = "#{application}.#{stage}" if location.nil? or location.length < 1
        run "cp #{current_path}/config/templates/#{location} #{nginx_path}/sites-available/#{application}"
        run "if [ ! -L #{nginx_path}/sites-enabled/#{application} ]; then ln -s #{nginx_path}/sites-available/#{application} #{nginx_path}/sites-enabled/#{application}; fi"
      else
        puts "Nginx configuration change aborted"
        exit
      end
    end

    task :restart_primary, :roles => :web, :only => {:primary => true} do
      restart
    end

    task :restart_secondary, :roles => :web, :except => {:primary => true} do
      restart
    end
    
    desc  "Restart all Nginx nodes"
    task :restart_all, :roles => :web do
      restart
    end

  
    def restart
      confirm = Capistrano::CLI.ui.ask "This is a dangerous task. Type 'yes sir' to continue."
      if confirm.downcase == "yes sir"
        sudo "#{nginx_restart_cmd}"
      else
        puts "Restart aborted"
        exit      
      end
    end

  end  
end