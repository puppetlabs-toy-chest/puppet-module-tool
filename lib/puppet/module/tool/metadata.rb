module Puppet::Module::Tool

  class Metadata

    # The full name of the module, which is a dash-separated combination of the +username+ and module +name+.
    attr_reader :full_name

    # The name of the user that owns this module.
    attr_reader :username

    # The name of this module. See also +full_name+.
    attr_reader :name

    # The version of this module, a string like '0.1.0'.
    attr_accessor :version

    # Instantiate from a hash, whose keys are setters in this class.
    # TODO How are +dependencies+ set without a `dependencies=` setter?
    # TODO Where are `doc` and `name` set?
    def initialize(settings = {})
      settings.each do |key, value|
        send("#{key}=", value)
      end
    end

    # Set the full name of this module, and from it, the +username+ and module +name+.
    def full_name=(full_name)
      @full_name = full_name
      @username, @name = Puppet::Module::Tool::username_and_modname_from(full_name)
    end

    # Does this metadata have a full_name defined based on username and modname?
    def full_name?
      @full_name && @username && @name
    end

    # Return module's dependencies.
    def dependencies
      @dependencies ||= []
    end

    # Return module's types.
    def types
      @types ||= []
    end

    # Return module's file checksums.
    def checksums
      @checksums ||= {}
    end

    # Return the dashed name of the module, which may either be the
    # dash-separated combination of the +username+ and module +name+, or just
    # the module +name+.
    def dashed_name
      [@username, @name].compact.join('-')
    end

    # Return the release name, which is the combination of the +dashed_name+
    # of the module and its +version+ number.
    def release_name
      [dashed_name, @version].join('-')
    end

    # Return the PSON record representing this instance.
    def to_pson(*args)
      {
        :name         => @full_name,
        :version      => @version,
        :dependencies => dependencies,
        :types        => types,
        :checksums    => checksums
      }.to_pson(*args)
    end

  end
  
end
