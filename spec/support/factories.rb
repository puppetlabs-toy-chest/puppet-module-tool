Factory.define :user do |f|
  f.sequence(:username) { |n| "user#{n}" }
  f.sequence(:email) { |n| "user#{n}@efample.com" }
  f.password 'testthis'
end

Factory.define :mod do |f|
  f.sequence(:name) { |n| "name#{n}" }
  f.sequence(:project_url) { |n| "http://example.com/mod#{n}" }
  f.association :owner, :factory => :user
end

Factory.define :release do |f|
  f.sequence(:version) { |n| "0.#{n}" }
  f.notes { |record| "This is version #{record.version}" }
  f.association :mod
end
