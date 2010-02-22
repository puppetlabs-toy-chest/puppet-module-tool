module PuppetModules
  module Applications
    
    class CLI < Application

      requires 'main', 'versionomy'

      def run

        repository_option = proc do
          option :repository, :r do
            description "URL to module repository (default: http://modules.puppetlabs.com)"
            cast :uri
            argument :required
          end
        end

        path_argument = proc do
          argument :path do
            description "The path to the module"
            optional
            argument :required
            default Dir.pwd
            validate { |value| File.directory?(value) }
          end
        end

        Main do

          mode :search do
            description "Search the module repository"
            argument :term do
              description "Search term"
              required
            end
            instance_eval(&repository_option)
            def run
              if params[:repository].given?
                PuppetModules.repository = params[:repository].value
              end
              searcher = PuppetModules::Applications::Searcher.new(params[:term].value)
              searcher.run
            end
          end
          
          mode :install do
            argument :name do
              required
            end
            option :version, :v do
              description "Version number to install"
              optional
              argument :required
            end
            option :force, :f do
              description "Force overwrite of existing module, if any"
              optional
              cast :bool
              default false
            end
            instance_eval(&repository_option)
            def run
              if params[:repository].given?
                PuppetModules.repository = params[:repository].value
              end
              installer = PuppetModules::Applications::Installer.new(params[:name].value, params[:version].value, params[:force].value)
              installer.run
            end
          end

          mode :release do
            description "Add a module version to the module repository"
            argument :module do
              description "Full module name (eg, username/name)"
              required
              argument :required
            end
            argument :filename do
              required
              validate { |value| File.file?(value) }
            end
            option :version, :v do
              description "Release version number (will parse version number from filename if not given)"
              optional
              argument :required
            end
            instance_eval(&repository_option)
            def run
              if params[:repository].given?
                PuppetModules.repository = params[:repository].value
              end
              PuppetModules::Applications::Releaser.run(params[:module].value,
                                                        params[:filename].value,
                                                        params[:version].value)
            end
          end

          mode :unrelease do
            description "Remove a module version from the repository"
            argument :module do
              description "Full module name (eg, username/name)"
              required
              argument :required
            end
            option :version, :v do
              description "Release version number"
              required
              argument :required
            end
            instance_eval(&repository_option)
            def run
              if params[:repository].given?
                PuppetModules.repository = params[:repository].value
              end
              PuppetModules::Applications::Unreleaser.run(params[:module].value,
                                                          params[:version].value)
            end
          end
          
          mode :clean do
            description "Clears module cache (all repositories)"
            def run
              PuppetModules::Applications::Cleaner.run
            end
          end

          mode :build do
            description "Build a module for release"
            instance_eval(&path_argument)
            option :version, :v do
              description "The version number for the release"
              required
              argument :required
              validate { |value| Versionomy.parse(value) rescue nil }
            end
            def run
              PuppetModules::Applications::Builder.run(params[:path].value, params[:version].value)
            end
          end

          mode :metadata do
            description "Write metadata for the module"
            instance_eval(&path_argument)
            option 'write-file', :w do
              description "Write file (set to false/0 to output to standard out)"
              cast :bool
              argument :required
              default true
            end
            def run
              PuppetModules::Applications::MetadataGenerator.run(params[:path].value, params['write-file'].value)
            end
            
          end

        end  
        
      end
    end

  end
end

