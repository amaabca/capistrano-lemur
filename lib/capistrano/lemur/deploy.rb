Capistrano::Configuration.instance.load do

  set(:migrate_target) { "current" }
  
  namespace :deploy do
    
  end
  
end