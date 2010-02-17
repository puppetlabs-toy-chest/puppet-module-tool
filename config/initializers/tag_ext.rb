module TagExt

  def to_param
    name
  end

end

Tag.instance_eval { include TagExt }
