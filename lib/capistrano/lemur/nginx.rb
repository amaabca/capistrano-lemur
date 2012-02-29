Capistrano::Configuration.instance.load do
  namespace :nginx do
    
    set(:nginx_path) { "/etc/nginx" }
    set(:nginx_cmd) {"/etc/init.d/nginx"}

    desc "LMR Copy application nginx config into sites-available and symlink into sites-enabled"
    task :setup, :roles => :web do
      confirm = Capistrano::CLI.ui.ask "This is a dangerous task. Type 'yes sir' to continue."
      if confirm.downcase == 'yes sir'
        location = Capistrano::CLI.ui.ask "Filename of nginx config file (blank for default of config/nginx.#{stage})?"
        location = "nginx.#{stage}" if location.nil? or location.length < 1
        # Backup the old config and copy app config
        run "cp #{nginx_path}/sites-available/#{application} #{nginx_path}/sites-available/#{application}.#{Time.now.strftime("%Y%m%d_%I%M")} && cp #{current_path}/config/#{location} #{nginx_path}/sites-available/#{application}"
        run "if [ ! -L #{nginx_path}/sites-enabled/#{application} ]; then ln -s #{nginx_path}/sites-available/#{application} #{nginx_path}/sites-enabled/#{application}; fi"
      else
        puts "Nginx configuration change aborted"
        exit
      end
    end
    
    task :test_config, :roles => :web do
      sudo "#{nginx_cmd} configtest"
    end

    desc "LMR Restart only primary node"
    task :restart_primary, :roles => :web, :only => {:primary => true} do
      restart
    end

    desc "LMR Restart only secondary node"
    task :restart_secondary, :roles => :web, :except => {:primary => true} do
      restart
    end
    
    desc "LMR Restart all Nginx nodes"
    task :restart_all, :roles => :web do
      restart
    end

  
    def restart
      confirm = Capistrano::CLI.ui.ask "This is a dangerous task. Type 'yes sir' to continue."
      if confirm.downcase == "yes sir"
        sudo "#{nginx_cmd} restart"
      else
        puts "Restart aborted"
        exit      
      end
    end

  end  
end