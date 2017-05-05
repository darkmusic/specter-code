Specter Framework

(c) 2006 Andrew Davey <andrew@equin.co.uk>

(c) 2008 Cedric Vivier <cedricv@neonux.com>



Building
========

First, make sure you have the following installed on your setup :

- [Boo 0.8+](https://github.com/boo-lang/boo) - the superb language
- [NUnit 2.2+](http://www.nunit.org/) - the famous TDD framework
- [NAnt 0.84+](http://nant.sf.net/) - the build system


Just type:
	
	nant
	
to build the project.

When succeeded then you can type :

	nant install

to install Specter (you may need administrative privileges [sudo])


	nant test
	
will build and test all the specs if you want so.

To rebuild everything from scratch:

	nant rebuild
	


How to Start
============

For a brief description of the project and its goals
take a look at docs/SpecterGuide.html .

src/ contains all the source code for the framework and tools

build/ contains the result of the build yeah

docs/ contains documentation about Specter features

examples/ contains examples of how to use Specter, you should read these! really! :)

specs/ contains the specs of Specter itself

bin/ contains the latest release version



Compiling and testing a spec
==========================

(note: you do not need "-r:bin/Specter.Framework.dll" if you have installed it)

	booc -r:bin/Specter.Framework.dll examples/myfirstspec.boo

Will generate myfirstspec.exe, a standalone Specter spec assembly and runner.
To view the results just launch myfirstspec.exe in a console or alternatively :

	specter-console myfirstspec.exe


If you'd like to generate a NUnit test suite you just need to compile your spec as a library :

	booc -t:library -r:bin/Specter.Framework.dll examples/myfirstspec.boo
	
It will create myfirstspec.dll in the current directory.
Then you can run it, as usual, with NUnit from the command line :

	nunit-console myfirstspec.dll

Or with your existing NUnit tools in your integrated development environment (IDE).

The NUnit testsuite dll can still be run through specter-console tool :

	specter-console myfirstspec.dll



Need Help ?
==========================

[http://specter.sf.net/](http://specter.sf.net/)

[http://groups.google.com/group/specter-framework/](http://groups.google.com/group/specter-framework/)

[irc://irc.gnome.org/specter](irc://irc.gnome.org/specter)

