Capistrano::Configuration.instance.load do
  namespace :bundler do
    task :create_symlink, :roles => :app do
      shared_dir = File.join(shared_path, 'bundle')
      release_dir = File.join(current_release, '.bundle')
      run("mkdir -p #{shared_dir} && ln -s #{shared_dir} #{release_dir}")
    end
 
    task :bundle_new_release, :roles => :app do
      #bundler.create_symlink
      run "cd #{current_path} && bundle install --deployment --quiet --without development test cucumber"
    end
  end
end