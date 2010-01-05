class ModuleLookup

  attr_reader :text
  def initialize(text)
    @text = text
  end

  def components
    @components ||= text.split('-')
  end

  def specific?
    components.size == 3
  end

  def to_sql
    if specific?
      text
    else
      text + "-%"
    end
  end

end
