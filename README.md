puppet-module-site
==================

This is a Rails application that provides a website and web service for publishing, findiing and downloading Puppet modules.

Setup
-----

1. Run `sudo gem install less`
2. Run `sudo rake gems:install`
3. Run `rake setup` to create the required directories and these files using sensible defaults: `config/database.yml`, `spec/spec.opts` and `spec/rcov.opts`.
4. Customize the above files if you'd like, but do not check them into the repository.
5. Create the database using your database's tools or using these tasks:
    * For development: Run `rake db:create`
    * For production: Run `rake RAILS_ENV=production db:create`
6. Create the database tables:
    * For development: Run `rake db:migrate db:test:prepare`
    * For production: Run `rake RAILS_ENV=production db:migrate`
