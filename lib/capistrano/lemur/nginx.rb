Capistrano::Configuration.instance.load do
  namespace :nginx do
    
    set(:nginx_path)          { "/etc/nginx" }
    set(:nginx_cmd)           { "/etc/init.d/nginx" }
    set(:nginx_ports)         { Array("80") }
    
    set(:nginx_server_names) {
      find_servers(:roles => :web).collect {|s| s.host}
    }

    desc "LMR Copy application nginx config into sites-available and symlink into sites-enabled"
    task :setup, :roles => :web do
      confirm = Capistrano::CLI.ui.ask "This is a dangerous task. Type 'yes sir' to continue."
      if confirm.downcase == 'yes sir'
        location = Capistrano::CLI.ui.ask "Filename of nginx config file (blank for default of config/nginx.#{stage})?"
        location = "nginx.#{stage}" if location.nil? or location.length < 1
        # Backup the old config and copy app config
        run "cp #{nginx_path}/sites-available/#{application} #{nginx_path}/sites-available/#{application}.#{Time.now.strftime("%Y%m%dT%H%M%S")} && cp #{current_path}/config/#{location} #{nginx_path}/sites-available/#{application}"
        run "if [ ! -L #{nginx_path}/sites-enabled/#{application} ]; then ln -s #{nginx_path}/sites-available/#{application} #{nginx_path}/sites-enabled/#{application}; fi"
      else
        puts "Nginx configuration change aborted"
        exit
      end
    end
    
    desc "Generate Nginx virtual host file"
    task :generate_config, :roles => :web do
      confirm = Capistrano::CLI.ui.ask "This is a dangerous task. Type 'yes sir' to continue."
      if confirm.downcase == 'yes sir'
        config_file = ERB.new(fetch(:nginx_erb_template)).result(binding)
        put config_file, "#{nginx_path}/sites-available/#{application}"
        run "if [ ! -L /etc/nginx/sites-enabled/#{application} ]; then ln -s /etc/nginx/sites-available/#{application} /etc/nginx/sites-enabled/#{application}; fi"
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
      restart_nginx
    end

    desc "LMR Restart only secondary node"
    task :restart_secondary, :roles => :web, :except => {:primary => true} do
      restart_nginx
    end
    
    desc "LMR Restart all Nginx nodes"
    task :restart, :roles => :web do
      restart_nginx
    end

    def restart_nginx
      if Capistrano::CLI.ui.ask("This is a dangerous task. Type 'yes sir' to continue.") == "yes sir"
        sudo "#{nginx_cmd} restart"
      else
        puts "Restart aborted"
      end
    end

  end  
  
  set(:nginx_erb_template) do
    <<-NGINX  
  upstream <%= application.to_s %> {
    server unix:<%= shared_path.to_s %>/tmp/sockets/unicorn.sock fail_timeout=0;
  } 

  server {
    listen <%= nginx_ports.join(" ") %>;
    server_name <%= nginx_server_names.join(" ") %>;

    root <%= current_path.to_s %>/public;

    rewrite_log on;

    access_log  /var/log/nginx/<%= application.to_s %>-access.log combined;
    error_log   /var/log/nginx/<%= application.to_s %>-error.log;

    location / {
      #all requests are sent to the UNIX socket
      proxy_pass  http://<%= application.to_s %>;
      proxy_redirect     off;

      proxy_set_header   Host             $host;
      proxy_set_header   X-Real-IP        $remote_addr;
      proxy_set_header   X-Forwarded-For  $proxy_add_x_forwarded_for;

      client_max_body_size       10m;
      client_body_buffer_size    128k;

      proxy_connect_timeout      90;
      proxy_send_timeout         90;
      proxy_read_timeout         90;

      proxy_buffer_size          4k;
      proxy_buffers              4 32k;
      proxy_busy_buffers_size    64k;
      proxy_temp_file_write_size 64k;
    }

    # if the request is for a static resource, nginx should serve it directly
    # and add a far future expires header to it, making the browser
    # cache the resource and navigate faster over the website
    # this probably needs some work with Rails 3.1's asset pipe_line
    location ~ ^/(images|javascripts|stylesheets|system)/  {
      root <%= current_path.to_s %>/public;
      expires max;
      break;
    }
  }
  NGINX
  end

end