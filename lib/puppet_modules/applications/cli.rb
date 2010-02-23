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

          mode :generate do
            description "Generate a new module structure"
            argument :name do
              required
              argument :required
            end
            def run
              installer = PuppetModules::Applications::Generator.new(params[:name].value)
              installer.run
            end
          end

          mode :release do
            description "Add a module version to the module repository"
            argument :filename do
              description "File to release.\nMust conform to USERNAME-MODULENAME-VERSION.tar.gz naming convention."
              required
              validate { |value| File.file?(value) }
            end
            instance_eval(&repository_option)
            def run
              if params[:repository].given?
                PuppetModules.repository = params[:repository].value
              end
              PuppetModules::Applications::Releaser.run(params[:filename].value)
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
            def run
              PuppetModules::Applications::Builder.run(params[:path].value)
            end
          end
          
        end  
        
      end
    end

  end
end

