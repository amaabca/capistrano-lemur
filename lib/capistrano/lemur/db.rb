Capistrano::Configuration.instance.load do 
  
  set(:migrate_target) { "current" }
  
  namespace :db do
    desc "LMR Setup application schema"
    task :setup, :roles => :db, :only => {:primary => true}, :except => { :no_release => true } do
      run "cd #{current_path}; bundle exec rake RAILS_ENV=#{rails_env} db:create"
    end
    
    desc "LMR Export the database into the db/ folder"
    task :backup, :roles => :db, :only => {:primary => true}, :except => { :no_release => true } do
      run "cd #{current_path}; bundle exec rake RAILS_ENV=#{rails_env} db:data:backup"
    end
  
    desc "LMR Export the database into the db/ folder"
    task :restore, :roles => :db, :only => {:primary => true}, :except => { :no_release => true } do
      confirm = Capistrano::CLI.ui.ask "This is a dangerous task. Type 'yes sir' to continue."
      exit unless confirm.downcase == 'yes sir'
      run "cd #{current_path}; bundle exec rake RAILS_ENV=#{rails_env} db:data:restore"
    end

    desc "LMR Export the database into the db/ folder"
    task :restore_from_staging, :roles => :db, :only => {:primary => true}, :except => { :no_release => true } do
      confirm = Capistrano::CLI.ui.ask "This is a dangerous task. Type 'yes sir' to continue."
      exit unless confirm.downcase == 'yes sir'
      run "cd #{current_path}; bundle exec rake RAILS_ENV=#{rails_env} db:data:restore_from_staging"
    end

    desc "LMR Export the database into the db/ folder"
    task :restore_from_production, :roles => :db, :only => {:primary => true}, :except => { :no_release => true } do
      confirm = Capistrano::CLI.ui.ask "This is a dangerous task. Type 'yes sir' to continue."
      exit unless confirm.downcase == 'yes sir'
      run "cd #{current_path}; bundle exec rake RAILS_ENV=#{rails_env} db:data:restore_from_production"
    end
      
    desc "LMR Wipe tables then rerun all migrations and seed database"
    task :remigrate, :roles => :db, :only => {:primary => true}, :except => { :no_release => true } do
      confirm = Capistrano::CLI.ui.ask "This is a dangerous task. Type 'yes sir' to continue."
      exit unless confirm.downcase == 'yes sir'
      backup
      run "cd #{current_path}; bundle exec rake RAILS_ENV=#{rails_env} db:remigrate"
    end
    
    desc "Seed the database on already deployed code"
    task :seed, :roles => :db, :only => {:primary => true}, :except => { :no_release => true } do
      confirm = Capistrano::CLI.ui.ask "This is a dangerous task. Type 'yes sir' to continue."
      exit unless confirm.downcase == 'yes sir'
      run "cd #{current_path}; bundle exec rake RAILS_ENV=#{rails_env} db:seed"
    end
    
    after "mysql:create_users", "db:setup"
    
  end
  

  
end