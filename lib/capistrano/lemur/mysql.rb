Capistrano::Configuration.instance.load do

  namespace :mysql do
  
    desc "LMR Create default db and user."
    task :create_users, :roles => :db, :only => {:primary => true}, :except => { :no_release => true } do
  
     db_config = YAML::load_file("config/database.yml")
     db_user = db_config[rails_env.to_s]["username"]
     db_password = db_config[rails_env.to_s]["password"]
     db_name = db_config[rails_env.to_s]["database"]
    
     db_root_password = Capistrano::CLI.password_prompt("Mysql root user password (blank to use value created by Chef run)?") 
     if db_root_password.to_s.length == 0
       sudo "ls -al" #So we don't get prompted on the line below.....  
       db_root_password = capture("sudo cat /var/cache/local/preseeding/mysql-server.seed").split(" ")[3]
       puts "Use this password #{db_root_password} "
     end

     fetch(:mysql_server, roles[:app].collect {|r| r.host} + ["localhost"]).each do |server|       
       check_user  = capture("mysql --user=root -p#{db_root_password} -B -N -e \"select count(*) from mysql.user where host = '#{server}' and user = '#{db_user}';\"").chomp.to_i
       run "mysql --user=root -p#{db_root_password} -e \"CREATE USER '#{db_user}'@'#{server}' IDENTIFIED BY '#{db_password}'\"" unless check_user == 1
       run "mysql --user=root -p#{db_root_password} -e \"GRANT CREATE ON *.* TO '#{db_user}'@'#{server}'\""
       run "mysql --user=root -p#{db_root_password} -e \"GRANT ALL PRIVILEGES ON #{db_name}.* TO '#{db_user}'@'#{server}' IDENTIFIED BY '#{db_password}' WITH GRANT OPTION\""
       run "mysql --user=root -p#{db_root_password} -e \"FLUSH PRIVILEGES;\""
     end
   
    end

    before "deploy:cold", "mysql:create_users"
    
  end

end