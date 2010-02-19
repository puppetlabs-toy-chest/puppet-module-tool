Factory.define :user do |x|
  x.sequence(:username) { |n| "user#{n}" }
  x.sequence(:email) { |n| "user#{n}@example.com" }
  x.password 'testthis'
end

Factory.define :mod do |x|
  x.sequence(:name) { |n| "name#{n}" }
  x.sequence(:source) { |n| "http://example.com/mod#{n}.git" }
end

Factory.define(:release) { }


