Puppet Module Tool
==================

The Puppet Module Tool, `pmt`, helps you author, publish, and manage
Puppet modules.

Basics
------

Add the `pmt` command to your shell (we'll make this into a `gem` soon):

    alias pmt=$PWD/bin/pmt

Display the program's built-in help by running:

    pmt help

Display information on a specific command by running a command like:

    pmt help install

Many commands will use a specific repository if you pass it to the `-r`
option at the end, like:

    pmt search mymodule -r http://forge.puppetlabs.com/

Search for modules
------------------

Searching displays modules on the repository that match your query.

For example, search the default repository for modules whose names
include the substring `mymodule`:

    pmt search mymodule

Install a module release
------------------------

Installing a module release from a repository downloads a special
archive file. This archive is then automatically unpacked into a new
directory under your current directory. You can then add this *module
directory* to your Puppet configuration files to use it.

For example, install the latest release of the module named `mymodule`
written by `myuser` from the default repository:

    pmt install myuser-mymodule

Or install a specific version:

    pmt install myuser-mymodule --version=0.0.1

Generate a module
-----------------

Generating a new module produces a new directory prepopulated with a
directory structure and files recommended for Puppet best practices.

For example, generate a new module:

    pmt generate myuser-mymodule

The above command will create a new *module directory* called
`myuser-mymodule` under your current directory with the generated files.

Please read the files in this generated directory for further details.

Build a module release
----------------------

Building a module release processes the files in your module directory
and produces a special archive file that you can share or install.

For example, build a module release from within the module directory:

    pmt build

The above command will report where it created the module release
archive file.

For example, if this was version `0.0.1` of `myuser-mymodule`, then this
would have created a `pkg/myuser-mymodule-0.0.1.tar.gz` release file.

The build process reads a `Modulefile` in your module directory and uses
its contents to direct its work.

The `Modulefile` is a *Ruby domain-specific language (DSL)*.

Here's an example of a `Modulefile`:

    name 'myuser-mymodule'
    version '0.0.1'
    dependency 'otheruser-othermodule', '1.2.3'

The build process reads the `Modulefile` and uses it to build a
`metadata.json` file. This generated JSON file is included in the module
release archive so that repositories and installers can extract details
from your release. Do **not** edit this `metadata.json` file yourself
because it's clobbered each time during the build process -- you should
make all your changes to the `Modulefile` instead.

All the files in the `pkg` directory of your module directory are
artifacts of the build process. You can delete them when you're done.

Share a module
--------------

Sharing a module release with others helps others avoid reinventing the
wheel, and encourages them to help with your work by improving it. For
every module you share, we hope you'll find many modules by others that
will be useful to you.

You can share your modules at
[http://forge.puppetlabs.com/](http://forge.puppetlabs.com/)

Get involved
------------

This is new and exciting for us. We have many plans for this and what
you see now is just the beginning. If you have ideas, please get in
touch. Puppet Labs can be contacted at: info@puppetlabs.com

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
version 2. See the LICENSE file for details.

Copyright
---------

Copyright (C) 2010 Puppet Labs Inc.
