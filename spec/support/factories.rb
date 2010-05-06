require 'factory_girl'

Factory.define :user do |f|
  f.sequence(:username) { |n| "user#{n}" }
  f.sequence(:email) { |n| "user#{n}@example.com" }
  f.password 'mypassword'
  f.display_name { |record| record.username.capitalize }
  # TODO Figure out why these two lines aren't enough to confirm a user
  ### f.confirmed_at Time.now
  ### f.confirmation_token nil
  f.after_build do |record|
    # NOTE: Confirm user record so that #sign_in test helper works
    # TODO Figure out why `record.confirm!` must be called twice
    record.confirm!
    record.confirm!
  end
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
