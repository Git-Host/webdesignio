# Modules

Modules are stored within `lib/`.  This directory is like our project
specific npm repository.  Load modules like in this example:

    project = require('lib/project')

Modules should be self-contained so that they could theoretically be
published to the public npm repository.
