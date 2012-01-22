* * *
# **Important Note: Module merged into core puppet**

This module has been converted to a [puppet face](http://puppetlabs.com/blog/puppet-faces-what-the-heck-are-faces/)
and merged into the core puppet repository. Any further development should take place in [puppetlabs/puppet](https://github.com/puppetlabs/puppet). 

You can find the code for the new tool here [`puppet/lib/puppet/face/module`](https://github.com/puppetlabs/puppet/tree/master/lib/puppet/face/module).
* * *

Puppet Module Tool
==================

The Puppet Module Tool, `puppet-module`, creates, installs and searches for
modules on the Puppet Forge at http://forge.puppetlabs.com

Dependencies
------------

To run `puppet-module`, you must have the following installed:

* Ruby 1.8.x: http://www.ruby-lang.org/en/downloads/
* RubyGems 1.3.x: http://rubygems.org/pages/download/
* Puppet 0.25.x: http://www.puppetlabs.com/

Soure code
----------

The source code for this tool is available online at
http://github.com/puppetlabs/puppet-module-tool

You can checkout the source code by installing the `git` distributed version
control system and running:

    git clone git://github.com/puppetlabs/puppet-module-tool.git

Running
-------

There are a number of ways to run the `puppet-module` program:

1. **From an official gem:** Install it by running:

        sudo gem install puppet-module

2. **From a locally-built gem:** Checkout the source code and from the checkout directory, run:

        # Build the gem
        rake gem
        # Install the file produced by the above command, e.g.:
        sudo gem install pkg/puppet-module-0.3.0.gem

3. **From a source code checkout:** Checkout the source code and from the checkout directory, run:

        alias puppet-module=$PWD/bin/puppet-module

**N.B.** you must have Puppet installed locally for `puppet-module` to work.

If Puppet is not installed by your system's package manager, install the RubyGem with:

        sudo gem install puppet

Basics
------

Display the program's built-in help by running:

    puppet-module help

Display information on a specific command by running a command like:

    puppet-module help install

Many commands will use a specific repository if you pass it to the `-r`
option at the end, like:

    puppet-module search mymodule -r http://forge.puppetlabs.com/

Search for modules
------------------

Searching displays modules on the repository that match your query.

For example, search the default repository for modules whose names
include the substring `mymodule`:

    puppet-module search mymodule

Install a module release
------------------------

Installing a module release from a repository downloads a special
archive file. This archive is then automatically unpacked into a new
directory under your current directory. You can then add this *module
directory* to your Puppet configuration files to use it.

For example, install the latest release of the module named `mymodule`
written by `myuser` from the default repository:

    puppet-module install myuser-mymodule

Or install a specific version:

    puppet-module install myuser-mymodule --version=0.0.1

Generate a module
-----------------

Generating a new module produces a new directory prepopulated with a
directory structure and files recommended for Puppet best practices.

For example, generate a new module:

    puppet-module generate myuser-mymodule

The above command will create a new *module directory* called
`myuser-mymodule` under your current directory with the generated files.

Please read the files in this generated directory for further details.

Build a module release
----------------------

Building a module release processes the files in your module directory
and produces a special archive file that you can share or install.

For example, build a module release from within the module directory:

    puppet-module build

The above command will report where it created the module release
archive file.

For example, if this was version `0.0.1` of `myuser-mymodule`, then this
would have created a `pkg/myuser-mymodule-0.0.1.tar.gz` release file.

The build process reads a `Modulefile` in your module directory and uses
its contents to build a `metadata.json` file. This generated JSON file
is included in the module release archive so that repositories and
installers can extract details from your release. Do **not** edit this
`metadata.json` file yourself, because it's clobbered each time during
the build process -- you should make all your changes to the
`Modulefile` instead.

All the files in the `pkg` directory of your module directory are
artifacts of the build process. You can delete them when you're done.

Write a valid `Modulefile`
--------------------------

The Modulefile resembles a configuration or data file, but is actually a Ruby domain-specific language (DSL), which means it's evaluated as code by the puppet-module tool. A Modulefile consists of a series of method calls which write or append to the available fields in the metadata object.

Normal rules of Ruby syntax apply:

    name 'myuser-mymodule'
    version '0.0.1'
    dependency( 'otheruser-othermodule', '1.2.3' )
    description "This is a full description
        of the module, and is being written as a multi-line string."

The following metadata fields/methods are available:

* `name` -- The full name of the module (e.g. "username-module").
* `version` -- The current version of the module.
* `dependency` -- A module that this module depends on. Unlike the other fields, the `dependency` method accepts up to three arguments: a module name, a version requirement, and a repository. A Modulefile may include multiple `dependency` lines.
* `source` -- The module's source. The use of this field is not specified.
* `author` -- The module's author. If not specified, this field will default to the username portion of the module's `name` field.
* `license` -- The license under which the module is made available.
* `summary` -- One-line description of the module.
* `description` -- Complete description of the module.
* `project_page` -- The module's website.

Share a module
--------------

Sharing a module release with others helps others avoid reinventing the
wheel, and encourages them to help with your work by improving it. For
every module you share, we hope you'll find many modules by others that
will be useful to you.

You can share your modules at http://forge.puppetlabs.com/

Building and sharing a new module version
-----------------------------------------

To build and share a new module version:

1. Edit the `Modulefile` and increase the `version` number.
2. Run the `puppet-module build` as explained in the *Build a module release* section.
3. Upload the new release file as explained in the *Share a module* section.

Cleaning the cache
------------------

Modules that you install are saved to a cache within your `~/.puppet`
directory. This cache can be cleaned out by running:

    puppet-module clean

Deleting a module
-----------------

The tool does not keep track of what modules you have installed. TO delete a
module just delete the directory the module was extracted into.

Technical disclaimer for techies
--------------------------------

This tool downloads untrusted code from the Internet. Please read the
source code before executing it to avoid surprises. If it breaks, it's
not our fault -- although we encourage you to contact the authors,
file a bug report and send patches.

Legal disclaimer for lawyers
----------------------------

THE PROGRAM AND MODULES ARE DISTRIBUTED IN THE HOPE THAT THEY WILL BE
USEFUL, BUT WITHOUT ANY WARRANTY. THEY ARE PROVIDED "AS IS" WITHOUT
WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
PARTICULAR PURPOSE. THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF
THE PROGRAM IS WITH YOU. SHOULD THE PROGRAM OR MODULES PROVE DEFECTIVE,
YOU ASSUME THE COST OF ALL NECESSARY SERVICING, REPAIR OR CORRECTION.

IN NO EVENT WILL Puppet Labs Inc. BE LIABLE TO YOU FOR DAMAGES,
INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES
ARISING OUT OF THE USE OR INABILITY TO USE THIS PROGRAM OR MODULES
(INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING RENDERED
INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A FAILURE OF
THE PROGRAM OR MODULES TO OPERATE WITH ANY OTHER PROGRAMS OR MODULES),
EVEN IF Puppet Labs Inc. HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH
DAMAGES.

License
-------

This software is distributed under the GNU General Public License
version 2 or any later version. See the LICENSE file for details.

Copyright
---------

Copyright (C) 2010 Puppet Labs Inc.
