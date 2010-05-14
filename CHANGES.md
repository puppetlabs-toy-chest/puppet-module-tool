puppet-module-site changes
==========================

r0.0.6.1
--------

* Fixed "devise" gem dependency, now require version 1.0.7 or a newer 1.0.x release.
* Added VERSION file, made application set its version from its contents.

r0.0.6
------

* Fixed gem dependency error, app now requires 'acts-as-taggable-on' version 2.0.4 because newer versions are broken.
* Fixed security vulnerabilities in model mass assignments, limited these to only those specifically allowed.
* Fixed security vulnerabilities in model format validations, made them match the beginning and end of strings rather than lines.
* Added cascade deletes, so that deleting a parent object (e.g. a user) will delete its children (e.g. mods and releases).

r0.0.5
------

* Fixed release model and controller: stopped it from creating invalid records during validation, adding better file and metadata validations, fixed attachment reading during validation, fixed redundant error messages by halting validation early when there's an error, made metadata extraction happen automatically, added detailed logging. Wrote many tests.
* Fixed JSON parsing, it was sometimes misguessing which parser/encoder to use -- which have different APIs -- and was silently discarded its errors.
* Fixed cross-site scripting vulnerabilities in ApplicationHelper, added documentation and wrote comprehensive specs.
* Fixed cross-site scripting vulnerabilties in ReleaseHelper, fixed #guess_next_version, extracted #label_doc into partial, added error checking to #link_to_dependency and wrote comprehensive specs.
* Added CSS styling for error messages to make them more visible.

r0.0.4
------

* Fixed insecure session and authentication encryption keys hardcoded into application.
* Fixed users controller by adding access control to ensure that users can only modify their own records and added error handling to ensure records are loaded properly. Wrote comprehensive specs.
* Fixed tags controller by adding error checking. Wrote comprehensive specs.
* Added mechanism to manage secret information, such as session encryption keys. See *Secrets* in `README.md`.
* Added exception notification system, sends emails with debugging information on uncaught exceptions.
* Added complete specs for module model.
* Added complete specs for release model, except for the metadata parsing code.
* Added mechanism to store and serve file attachments to tests.
* Added display of this web application's version number in its header for use during development.
* Disabled all code referencing watches and timeline events because it's a security hazard, wasn't done and kept getting in the way.
* Refactored models for clarity, added documentation and wrote specs.

r0.0.3
------

* Fixed the releases controller, this had numerous security vulnerabilities and logic errors. Refactored, added access controls, error checking and comprehensive specs. However, still need to fix #create action and models.
* Fixed how controllers load related records for users, modules and releases.
* Fixed how controllers ensure that required records are loaded and handle errors.
* Fixed how controllers authorize access to records and handle errors.
* Fixed the new module form, it failed if the user wasn't specified.
* Fixed the show module page, it failed if the feed URL was invalid.
* Fixed the show module page, displayed an "Add release" link.
* Fixed mailer to generate URLs that include port and protocol if necessary.
* Fixed flash notification message helper to ensure correct arguments, added docs and specs.
* Fixed release destroy, it was calling invalid methods and using bad defaults.
* Switched to 'maruku' gem, a pure Ruby Markdown parser.
* Added `rake spec:rcov:save` to save code coverage data, and `rake spec:rcov:diff` to display uncovered code since save.
* Added `cap db:use` to download remote `production` database and replace local `development` database with it.
* Added unified response utility methods to simplify specs.

r0.0.2
------

* Fixed the modules model and controllers, these had numerous security vulnerabilities and logic errors. Refactored these and added access controls, error checking and comprehensive specs.
* Fixed styling, the page headerings are now shown and button-like links have spacing between them.
* Added ability to delete modules.
* Added `annotate_models` plugin and annotated the models.
* Added `rdiscount` gem dependency for rendering Markdown.
* Removed gem dependencies `shoulda` and `mocha`.

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
