module Puppet::Module::Tool

  class ContentsDescription

    def initialize(path)
      @path = path
    end

    def annotate(metadata)
      data[:types].each do |type|
        metadata.types << type
      end
    end

    def data
      unless @data
        @data = {:types => []}
        Dir[File.join(@path, 'lib/puppet/type/*.rb')].each do |filename|
          require filename
          type_name = File.basename(filename, '.rb')
          type = Puppet::Type.type(type_name.to_sym)
          if type
            type_hash = {:name => type_name, :doc => type.doc}
            @data[:types] << type_hash
            type_hash[:properties] = attr_doc(type, :property)
            type_hash[:parameters] = attr_doc(type, :param)
            if type.providers.size > 0
              type_hash[:providers] = provider_doc(type)
            end
          else
            puts "Could not find/load type: #{type_name}"
          end
        end
      end
      @data
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
