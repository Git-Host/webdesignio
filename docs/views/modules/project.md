# Project module

## Api

Each instance inherits all properties and methods of an express instance.

### Project()

Constructor which returns a newly patched express instance.

#### .boot(apps)

Boots up the given applications.  `apps` is an Array of applications to boot.

*Example:*

    project.boot [
      'website'
      'admin'
    ]

Application constructors can be designed to get arguments
(e.g. configuration). If this is the case they can be passed using
this syntax:

*Example:*

    project.boot [
    ...
    ['assets', arg1, arg2]
    ...
    ]

Here is `assets` the name of the application and `arg1, arg2` are
arguments to the constructor.
