class ModuleLookup

  TYPES = %w(users namespaces mods)

  attr_reader :params
  def initialize(params)
    @params = params
  end

  # The raw text for a hierarchal lookup
  def text
    @text ||= params[:q] || params[:id]
  end

  # Split a hierarchal lookup into key/value pairs
  def components
    @components ||= text.split('-').zip(TYPES).map(&:reverse)
  end

  # Convert a hierarchal lookup to a path
  def to_path
    unless hierarchal?
      raise ArgumentError, "Lookup is not hierarchal"
    end
    returning '/' do |memo|
      memo << components.flatten.join('/')
      memo << "/mods" unless specific?
      memo << ".json"        
    end
  end

  # If this is a heirarchal query (`foo-bar`, `foo-bar-baz`)
  def hierarchal?
    text.include?('-')
  end

  # If this is a fully-specified hierachal lookup (owner, namespace,
  # and mod name)
  def specific?
    hierarchal? && components.size == TYPES.size
  end

  # To be ready for querying, we at least need to know what the owner
  # id is.
  def ready?
    return @ready if defined?(@ready)
    @ready = params[owner_field]
  end

  # The result of the query
  def mods
    ready!
    case level
    when :namespace
      namespace.mods
    when :owner
      owner.owned_namespaces.map(&:mods).flatten.uniq
    end
  end

  def level
    ready!
    namespace ? :namespace : :owner
  end

  # The namespace of the query
  def namespace
    return @namespace if defined?(@namespace)
    ready!
    return unless owner
    @namespace = owner.owned_namespaces.first(:conditions => {:name => params[:namespace_id]})
  end

  # The owner of the query
  def owner
    return @owner if defined?(@owner)
    ready!
    if params[:organization_id]
      @owner = Organization.first(:conditions => {:name => params[:organization_id]})
    elsif params[:user_id]
      @owner = User.first(:conditions => {:username => params[:user_id]})
    end
  end

  private

  # Verify the lookup is ready for querying
  def ready!
    unless ready?
      raise ArgumentError, "Lookup is not ready"
    end
  end

  # The current owner field
  def owner_field
    @owner_field ||= @params[:organization_id] ? :organization_id : :user_id
  end

end
