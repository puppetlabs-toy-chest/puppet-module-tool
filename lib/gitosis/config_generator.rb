module Gitosis

  class ConfigGenerator

    DEFAULT_CONFIG = {
      :gitosis => {
        ## To override the default ~/repositories path
        # repositories = repositories
        
        ## Allow gitweb to show all known repositories. If you want gitweb,
        ## you need either this or a [repo foo] section for each repository
        ## you want visible in gitweb.
        :gitweb => 'no',
        
        ## Allow git-daemon to publish all known repositories. As with gitweb,
        ## this can be done globally or per-repository.
        :daemon => 'yes',
        
        ## Logging level, one of DEBUG, INFO, WARNING, ERROR, CRITICAL
        :loglevel => 'DEBUG'
      }
    }

    def config
      @config ||= DEFAULT_CONFIG.dup
    end

    def generate
      populate!
      build
    end

    private

    # TODO: Performance pass; once we have gitosis set-up to read from
    # multiple config files, we can write each namespace separately as
    # needed instead of generating the entire file at once.
    def populate!
      Namespace.all(:include => [{:namespace_memberships => :user}, :mods]).each do |namespace|
        settings = config[namespace.full_name] = {}
        settings[:members] = members(namespace)
        settings[:writable] = namespace.mods.map { |mod| mod.repo_path }
      end
    end

    def build
      config.inject('') do |output, (section, settings)|
        if section == :gitosis
          output << "[gitosis]\n"
        else
          output << "[group #{section}]\n"
        end
        settings.each do |key, value|
          if value.is_a?(Array)
            value = value.join(' ')
          end
          output << "#{key} = #{value}\n"
        end
        output << "\n"
      end
    end

    def members(namespace)
      namespace.users.inject([]) do |list, user|
        if !user.public_key.blank?
          list << user.name
        else
          list
        end
      end
    end

  end

end
