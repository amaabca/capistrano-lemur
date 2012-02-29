Capistrano::Configuration.instance.load do
  
  namespace :symlinks do
    desc "Iterate over 'symlinks' hash: { '/path/to/src1' => '/path/to/dest2', '/path/to/src2' => '/path/to/dest2'}"
    task :default do      
      all_symlinks.each_pair do |src, dest|
        run "if [! -L '#{dest}']; then ln -s #{src} #{dest}; fi"
      end
    end
  end

end