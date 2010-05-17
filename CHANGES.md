puppet-module-tool changes
==========================

r0.2.2
------

* Fixed unpacker to use the private working directory instead of '/tmp'.

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
