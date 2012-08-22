Capistrano::Configuration.instance.load do

  namespace :mysql do

    desc "LMR Create default db and user."
    task :create_users, :roles => :db, :only => {:primary => true}, :except => { :no_release => true } do


    response = Capistrano::CLI.ui.ask "Use config/database.yml to create user (Yn)?"
    if response.present? && response.downcase == 'y'
      db_config = YAML::load_file("config/database.yml")
      db_user = db_config[rails_env.to_s]["username"]
      db_password = db_config[rails_env.to_s]["password"]
      db_name = db_config[rails_env.to_s]["database"]
    else
      db_user  = Capistrano::CLI.ui.ask("Application database user: ")
      db_password = Capistrano::CLI.password_prompt("Password: ")
      db_name = Capistrano::CLI.ui.ask("Database name: ")
    end

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


    desc "Just creates a mysql user"
    task :create_user, :roles => :mysql, :except => { :no_release => true } do

      if defined?(mysql_server) && !mysql_server.nil?
        db_server = mysql_server
      else
        db_server =  Capistrano::CLI.ui.ask("Mysql server (Blank for first server with :mysql role): ")
        db_server = roles[:mysql].servers.first if db_server.nil?
      end
      db_user  = Capistrano::CLI.ui.ask("Database user: ")
      db_host = Capistrano::CLI.ui.ask("Database host (blank for '%'): ") || "%"
      db_password = Capistrano::CLI.password_prompt("Database user password: ")
      db_name = Capistrano::CLI.ui.ask("Database name: ")

     db_root_password = Capistrano::CLI.password_prompt("Mysql root user password (blank to use value created by Chef run)?")
     if db_root_password.to_s.length == 0
       usr = user
       set :user, "root"
       db_root_password = capture("cat /var/cache/local/preseeding/mysql-server.seed").split(" ")[3]
       set :user, usr
     end

     check_user  = capture("mysql --user=root -p#{db_root_password} -B -N -e \"select count(*) from mysql.user where host = '#{db_host}' and user = '#{db_user}';\"").chomp.to_i
     run "mysql --user=root -p#{db_root_password} -e \"CREATE USER '#{db_user}'@'%' IDENTIFIED BY '#{db_password}'\"" unless check_user == 1
     run "mysql --user=root -p#{db_root_password} -e \"GRANT CREATE ON *.* TO '#{db_user}'@'#{db_host}'\""
     run "mysql --user=root -p#{db_root_password} -e \"GRANT ALL PRIVILEGES ON #{db_name}.* TO '#{db_user}'@'#{db_host}' IDENTIFIED BY '#{db_password}' WITH GRANT OPTION\""
     run "mysql --user=root -p#{db_root_password} -e \"FLUSH PRIVILEGES;\""
    end

    desc "Runs rake db:create"
    task :create_db, :roles => :db, :only => {:primary => true}, :except => { :no_release => true } do
      response = Capistrano::CLI.ui.ask("Run task using foreman (Yn)?: ")
      if !response.nil? && response.downcase == 'y'
        run "cd #{current_path} && bin/foreman run bin/rake db:create"
      else
        run "cd #{current_path} && bin/rake db:create"
      end
    end

  end

end