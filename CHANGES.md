puppet-module-tool changes
==========================

r0.2.8
------

* Fixed rake tasks so that RSpec isn't required to run those tasks that don't need it.
* Fixed generated dependency metadata so that version and repository values are only set if specified.

r0.2.7
------

* Fixed program so it'd be pure Ruby, it used to depend on the Versionomy library which required compiled extensions.

r0.2.6
------

* Fixed gem builder to no longer install Puppet as a dependency since users can have a non-gem version.

r0.2.5
------

* Added ability to specify username and password credentials for a repository URL, e.g.: http://myuser:mypassword@myrepository.com/

r0.2.4
------

* Improved user documentation, explained different ways to run the program.

r0.2.3
------

* Fixed Rakefile, readded the rspec tasks inadvertantly removed in r0.2.2.
* Fixed builder to extract information about Puppet providers.
* Fixed tool's method for getting the current repository to use Puppet's settings.
* Improved cli_spec, added examples describing how to build a module's checksums, dependencies and Puppet types and providers.
* Improved builder to produce pretty JSON that's easy for a human to read.

r0.2.2
------

* Fixed unpacker to use the private working directory instead of '/tmp'.
* Fixed installer, it now detects if a module is already installed.
* Fixed default repository path to 'http://forge.puppetlabs.com'
* Fixed README's license text to explain that GPLv2 or later is acceptable.
* Added `rake gem` to build a gem in the 'pkg' directory.

r0.2.1
------

* Fixed license to refer to 'Puppet Labs'.
* Added user documentation to `README.markdown`.

r0.2.0
------

* Fixed errors causing tool to add unwanted hyphens to ends of names.
* Fixed loading of 'puppet' gem conditionally, instead of failing on startup.
* Fixed startup to create required work directory, instead of failing on startup.
* Fixed repository to use a default repository URL rather than failing without arguments.
* Fixed setting of module's full name to ensure a valid name.
* Fixed generator to refuse to generate a directory with an invalid name.
* Fixed installer to refuse to install a file with an invalid name.
* Fixed unpacker to install into directory with the module's full name.
* Fixed installer to install files from the local filesystem.
* Fixed lookup of tool's root directory to use correct, simple and reliable mechanism.
* Fixed problematic 'autoload' calls and reorganized how libraries are loaded.
* Fixed and expanded README instructions.
* Disabled actions 'freeze', 'register', 'release' and 'unrelease' to save time, users can use the website for these.
* Improved cleaner, it can now be called as a library method.
* Added test suite, brought test code coverage up to 86%.
* Added documentation to most of application's methods, classes, and lightly refactored.
* Added libraries and methods to stub and test methods accessing remote resources.
* Added #tap and #returning methods to clarify code.

r0.1.0
------

Initial draft.
