require 'capistrano'

# TODO: use the built in Capistrano web:disable by setting: 
# maintenance_basename (path to html)
# maintenance_template_path (path to erb)

module Capistrano::Lemur::Outage
  def self.load_into(configuration)
    configuration.load do

      set(:outage_templates) { ["membership_outage.html","registration_outage.html"] }


      namespace :web do

        desc "LMR Serve up a custom maintenance page."
        task :disable, :roles => :web do
          Capistrano::Lemur::Outage.disable_template
        end
        
        desc "LMR Remove a custom maintenance page."
        task :enable, :roles => :web do
          Capistrano::Lemur::Outage.enable_template
        end 

      end
      
      namespace :membership do

        desc "LMR Serve up a custom maintenance page."
        task :disable, :roles => :web do
          Capistrano::Lemur::Outage.disable_template(outage_templates)
        end
        
        desc "LMR Remove a custom maintenance page."
        task :enable, :roles => :web do
          Capistrano::Lemur::Outage.enable_template(outage_templates)
        end 

      end

    end
  end
  
  
  def self.enable_template(templates = Array("maintenance.html") )    
    templates.each do |template|
     require 'erb'
     on_rollback { run "rm #{current_path}/public/system/#{template}" }
     
     reason = ENV['REASON']
     deadline = ENV['UNTIL']
     
     file = File.read(File.join("app/views/system/#{template}.erb"))
     page = ERB.new(file).result(binding)
     put(page, "#{current_path}/public/system/#{template}", :mode => 0644)
    end  
  end

  def self.disable_template(templates = Array("maintenance.html") )
    templates.each do |template|
      run "rm #{current_path}/public/system/#{template}"
    end
  end
  
end

if Capistrano::Configuration.instance
  Capistrano::Lemur::Outage.load_into(Capistrano::Configuration.instance)
end
