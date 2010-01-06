Factory.define :user do |x|
  x.sequence(:username) { |n| "user#{n}" }
  x.sequence(:email) { |n| "user#{n}@example.com" }
  x.password 'testthis'
end

Factory.define :organization do |x|
  x.sequence(:name) { |n| "organization#{n}" }
  x.sequence(:title) { |n| "Organization #{n}" }
end

Factory.define :namespace do |x|
  x.sequence(:name) { |n| "ns#{n}" }
  x.association :owner, :factory => :user
end

Factory.define :ns_member, :class => NamespaceMembership do |x|
  x.association :user
  x.association :namespace
end

Factory.define :org_member, :class => OrganizationMembership do |x|
  x.association :user
  x.association :organization
end

Factory.define :mod do |x|
  x.sequence(:name) { |n| "name#{n}" }
  x.association :namespace
  x.sequence(:source) { |n| "http://example.com/mod#{n}.git" }
end


