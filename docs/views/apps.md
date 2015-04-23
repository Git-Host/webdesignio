# Apps

The project consists of one big express application which nests
multiple small express applications.

Each nested application is a so-called "App". And the master express
application is called "Project".  We use a
[helper module](modules/project) called "project" to make this as easy
as possible without losing the flexibility of express.  This module
resides within `lib/`.

The applications reside within the root directory of a project:

    my_project/
        app1/
        app2/

They are designed like normal node-modules.  Therefore each of them
has an `index.coffee` file contained.  An application is structured
with the MVC pattern in mind.  Each has four directories: `styles`,
`views`, `controllers`, `models`,

*Example:*

    app1/
        styles/
        client/
        views/
        controllers/
        models/

All those subdirectories are optional.

**Styles** This directory contains all the *less* stylesheets needed
 for the application.  These styles can be used in your views with the
 following urlpattern: `/assets/css/app1/mystyle.css`.  Here
 `mystyle.css` is your `mystyle.less` file in `styles/` which is
 compiled as needed using a `less-middleware`.

**Client** All files in this directory can be retrieved using the
  `browserify-middleware`.  Use them in your views with the following
  urlpattern: `/assets/js/app1/myfile.js`. Here `myfile.js` is your
  `mystyle.coffee` file in `client/`.

**Views** Here we store all the views of the application.  Views are
  written in *jade*.

**Controllers** This is the place for all controller modules.
*Example (index.coffee):*

    app.resource 'users', require('./controllers/users')
