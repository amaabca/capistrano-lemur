Capistrano::Configuration.instance.load do 
  
  namespace :db do
    desc "Setup application schema"
    task :setup do
      run "cd #{current_path}; bundle exec rake RAILS_ENV=#{rails_env} db:create"
    end
    
    desc "Export the database into the db/ folder"
    task :backup, :only => {:primary => true}, :except => { :no_release => true } do
      run "cd #{current_path}; bundle exec rake RAILS_ENV=#{rails_env} db:data:backup"
    end
  
    desc "Export the database into the db/ folder"
    task :restore, :only => {:primary => true}, :except => { :no_release => true } do
      confirm = Capistrano::CLI.ui.ask "This is a dangerous task. Type 'yes sir' to continue."
      exit unless confirm.downcase == 'yes sir'
      run "cd #{current_path}; bundle exec rake RAILS_ENV=#{rails_env} db:data:restore"
    end

    desc "Export the database into the db/ folder"
    task :restore_from_staging, :only => {:primary => true}, :except => { :no_release => true } do
      confirm = Capistrano::CLI.ui.ask "This is a dangerous task. Type 'yes sir' to continue."
      exit unless confirm.downcase == 'yes sir'
      run "cd #{current_path}; bundle exec rake RAILS_ENV=#{rails_env} db:data:restore_from_staging"
    end

    desc "Export the database into the db/ folder"
    task :restore_from_production, :only => {:primary => true}, :except => { :no_release => true } do
      confirm = Capistrano::CLI.ui.ask "This is a dangerous task. Type 'yes sir' to continue."
      exit unless confirm.downcase == 'yes sir'
      run "cd #{current_path}; bundle exec rake RAILS_ENV=#{rails_env} db:data:restore_from_production"
    end
      
    desc "Wipe tables then rerun all migrations and seed database"
    task :remigrate, :only => {:primary => true}, :except => { :no_release => true } do
      confirm = Capistrano::CLI.ui.ask "This is a dangerous task. Type 'yes sir' to continue."
      exit unless confirm.downcase == 'yes sir'
      backup
      run "cd #{current_path}; bundle exec rake RAILS_ENV=#{rails_env} db:remigrate"
    end
  end
  
end