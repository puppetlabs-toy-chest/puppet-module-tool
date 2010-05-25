puppet-module-site changes
==========================

r0.1.1
------

* Added caching and optimizataions to make app run ~5x faster.
* Added `rake clear` task to clear out the view, stylesheet and javascript caches.
* Added support for conditionally loading New Relic performance profiler, see README.

r0.1.0
------

* Fixed module and release views to display all information gathered and in an attractive way.
* Fixed external resources, the site now has all the stylesheets and images intended.
* Fixed module model to link directly to the current release, simplifying and speeding the code
* Fixed module/release listings to format nicely and include information like date.
* Fixed user-module relationship, eliminated needlessly problematic polymorphic association.
* Fixed menubar so its items are ordered, readable and don't derail the page heading.
* Fixed tags and modules views to sort modules by their full name.
* Fixed duplication of pages, made '/USERNAME/modules' redirect to '/USERNAME'.
* Fixed missing or non-obvious buttons for things like "add release", "add module", etc.

r0.0.7.7
--------

* Fixed module release dependency links so they can be generated from different kinds of names and repositories.
* Fixed tags to show a friendly page if no modules for the tag are found rather than a confusing error.
* Fixed tags so they're case-insensitive.
* Fixed categories so they're case-insensitive.
* Fixed categories so they're only shown if they're associated with at least one module.
* Fixed module release page to include a "Destroy release" button.
* Added `rake externals:download` to import the JavaScript, CSS and image files this site depends on.

r0.0.7.6
--------

* Fixed release finder to not throw exceptions if asked to find release for a module that doesn't exist.
* Fixed module tags, they weren't being assigned.
* Changed tags so that they're space-delimited, rather than comma delimited.
* Disabled authentication via HTTP Basic Auth so that the site can run with .htaccess protection.

r0.0.7.5
--------

* Moved homepage aside, replaced it with a blank page.

r0.0.7.4
--------

* Fixed homepage to add links for contacting us and learning how to create modules.

r0.0.7.3
--------

* Fixed module show page to list the Puppet parameters, properties and providers without throwing exceptions.

r0.0.7.2
--------

* Fixed MarukuHelper#markdown to use Hpricot syntax compatible with current and previous gem versions.
* Fixed user edit form, it's now possible to edit a user without changing their password. Added specs.
* Fixed the form to create or edit a user, made the admin field a checkbox.
* Added styling to the flash notification messages.

r0.0.7.1
--------

* Fixed footer's picture of the book, it wasn't being displayed.

r0.0.7
------

* DEPENDENCY: Added 'hpricot' gem.
* MIGRATION: Added admin user role and privileges.
* Fixed views that list and show modules to feature the current version, not the initial version.
* Fixed footer to say "Puppet Labs", corrected the links, and synced it with the main site.
* Fixed markdown helper to emit only valid, sanitized HTML regardless of what users give it.
* Changed authentication to login by username, not email address.
* Added ability to login as another user if logged in as an admin or using the dev environment.
* Added `rake setup:admin:grants` to grant admin rights to existing users from the console.
* Added initial text to homepage explaining the site and what people can do with it.
* Added helper to focus a HTML form input field when the page is ready.

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
