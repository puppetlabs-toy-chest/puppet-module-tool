Factory.define :user do |u|
  u.username 'bruce'
  u.email 'bruce@reductivelabs.com'
  u.password 'test'
end

Factory.define :namespace do |n|
  n.name 'foo'
  n.association :owner, :factory => :user
end
