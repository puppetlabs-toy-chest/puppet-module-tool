# Make tags space-delimited.
TagList.delimiter = " "

# Add a #to_param method to tags.
module TagExt

  def to_param
    name
  end

end

Tag.instance_eval { include TagExt }
