Factory.define :user do |x|
  x.sequence(:username) { |n| "user#{n}" }
  x.sequence(:email) { |n| "user#{n}@example.com" }
  x.password 'testthis'
end

Factory.define :mod do |x|
  x.sequence(:name) { |n| "name#{n}" }
  x.sequence(:project_url) { |n| "http://example.com/mod#{n}" }
end

Factory.define(:release) { }

Factory.define(:watch) { }

