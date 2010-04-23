puppet-module-site changes
==========================

r0.0.1
------

* Added `README.md` with setup instructions.
* Added `rake setup` task to create required configuration files using sensible defaults.
* Added Rails `preview` environment, just like `production` but using `development` database.
* Fixed email sending configuration, added a valid email address.
* Fixed user's timeline from throwing exceptions by disabling unfinished code.
* Fixed Capistrano multistages, extracted settings into separate files.

r0.0.0
------
* First draft.
