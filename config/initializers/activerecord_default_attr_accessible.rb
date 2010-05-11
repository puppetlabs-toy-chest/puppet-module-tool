# SECURITY: Prevent mass-assignment of attributes, e.g. we don't want 
# unauthorized people making themselves admins. Each model class must invoke
# +attr_accessible+ and declare theattributes that can be assigned.
ActiveRecord::Base.send(:attr_accessible, nil)
