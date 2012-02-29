require 'pathname'

Capistrano::Configuration.instance.load do
  
  namespace :filesystem do
    
    desc "Iterate over 'app_symlinks' hash: { '/path/to/src1' => '/path/to/dest2', '/path/to/src2' => '/path/to/dest2'}"
    task :create_symlinks do      
      fetch(:app_symlinks).each_pair do |src, dest|
        run "if [ ! -L #{lemur_fullpath(dest)} ]; then ln -s #{lemur_fullpath(src)} #{lemur_fullpath(dest)}; fi"
      end
    end
    
    desc "Create all directories in 'app_directories' array"
    task :create_directories do
      fetch(:app_directories).each do |directory|
        run "mkdir -p #{lemur_fullpath(directory)}"
      end
    end
    
    def lemur_fullpath(path)
      Pathname.new(path).relative? ? File.join(current_path, path) : path
    end
    
  end

end