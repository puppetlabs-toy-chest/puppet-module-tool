module PuppetModules

  module Applications

    class MetadataGenerator < Application

      requires 'puppet'

      def initialize(path, writing=true)
        @path = path
        $LOAD_PATH.unshift(File.join(path, 'lib'))
        @writing = writing
      end

      def run
        metadata = Metadata.new
        Modulefile.evaluate(metadata, File.join(@path, 'Modulefile'))
        Dir[File.join(@path, 'lib/puppet/type/*.rb')].each do |filename|
          type_name = File.basename(filename, '.rb')
          type = Puppet::Type.type(type_name.to_sym)
          type_hash = {:name => type_name, :doc => type.doc}
          metadata.types << type_hash
          type_hash[:properties] = attr_doc(type, :property)
          type_hash[:parameters] = attr_doc(type, :param)
          if type.providers.size > 0
            type_hash[:providers] = provider_doc(type)
          end
        end
        
        data = PSON.dump(metadata)
        if @writing
          File.open(File.join(@path, 'metadata.json'), 'w') do |f|
            f.data
          end
        else
          puts data
        end
      end

      def attr_doc(type, kind)
        attrs = []
        type.allattrs.each do |name|
          if type.attrtype(name) == kind && name != :provider
            attrs.push(:name => name, :doc => type.attrclass(name).doc)
          end
        end
        attrs
      end

      def provider_doc(type)
        providers = []
        type.providers.sort { |a,b|
          a.to_s <=> b.to_s
        }.each { |prov|
          providers.push(:name => prov, :doc => type.provider(prov).doc)
        }
        providers
      end
      
    end

  end
end
