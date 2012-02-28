Capistrano::Configuration.instance.load do

  namespace :web do
    desc "LMR Serve up a custom maintenance page."
    task :disable, :roles => :web do
      require 'erb'
      on_rollback { run "rm #{current_path}/public/system/maintenance.html" }
      
      reason = ENV['REASON']
      deadline = ENV['UNTIL']
      
      template = File.read(File.join("app/views/system/maintenance.html.erb"))
      page = ERB.new(template).result(binding)
      
      upload(page, "#{current_path}/public/system/maintenance.html", :mode => 0644)
    end
    
    desc "LMR Remove a custom maintenance page."
    task :enable, :roles => :web do
      run "rm #{current_path}/public/system/maintenance.html"
    end
  end

end