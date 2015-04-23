dirname = require('path').dirname
express = require('express')

module.exports = (opts = {}) ->
  project = express()

  ###
  Boot up all applications.
  ###
  project.boot = (apps) ->
    project.set 'apps', apps.map (x) ->
      if Array.isArray(x)
        x[0]
      else
        x

    for app, i in apps
      if Array.isArray(app)
        path = require.resolve(app[0])
        router = express.Router()
        do ->
          _app = app[0]
          router.use (req, res, done) ->
            req.appName = _app
            done()
        app = require(path).call(null, app[1..])
        router.use app
      else
        path = require.resolve(app)
        router = express.Router()
        do ->
          _app = app
          router.use (req, res, done) ->
            req.appName = _app
            done()
        app = require(path)
        router.use app
      unless app.get('view engine')
        if app.set?
          app.set 'view engine', project.get('view engine')
      if app.set?
        app.set 'views', "#{dirname(path)}/views"
      project.use router

  project
