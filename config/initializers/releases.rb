Paperclip.interpolates :owner do |attachment, style|
  attachment.instance.mod.owner.username
end

Paperclip.interpolates :mod_name do |attachment, style|
  attachment.instance.mod.name
end

Paperclip.interpolates :version do |attachment, style|
  attachment.instance.version
end

Paperclip.interpolates :bucket do |attachment, style|
  attachment.instance.mod.owner.username[0, 1]
end
