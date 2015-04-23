express = require('express')
less = require('less-middleware')
browserify = require('browserify-middleware')
serve = require('serve-static')
basename = require('path').basename
contentDisposition = require('content-disposition')
log = require('util').log

module.exports = ->
  app = express()
  app.use (req, res, done) ->
    name = ->
      if req.website?
        req.website.name
      else
        req.appName

    scriptPath = res.locals.scriptPath = (path, app) ->
      if process.env.NODE_ENV isnt 'production'
        "/assets/#{app or name()}/client/#{path}.coffee"
      else
        """https://s3-#{process.env.AWS_S3_REGION}.amazonaws.com/\
          #{process.env.AWS_S3_BUCKET}/#{app or name()}/client/#{path}.js"""

    res.locals.script = (path, raw, app) ->
      if raw
        path = res.locals.asset(path, true)
      else
        path = scriptPath(path, app)
      "<script src=\"#{path}\"></script>"

    stylePath = res.locals.stylePath = (path, app) ->
      if process.env.NODE_ENV isnt 'production'
        "/assets/#{app or name()}/styles/#{path}.css"
      else
        """https://s3-#{process.env.AWS_S3_REGION}.amazonaws.com/\
          #{process.env.AWS_S3_BUCKET}/#{app or name()}/styles/#{path}.css"""

    res.locals.style = (path, raw, app) ->
      if raw
        path = res.locals.asset(path, true)
      else
        path = stylePath(path, app)
      "<link rel=\"stylesheet\" href=\"#{path}\">"

    res.locals.asset = (path, root) ->
      if process.env.NODE_ENV isnt 'production'
        if root
          "/assets/#{path}"
        else
          "/assets/#{name()}/#{path}"
      else
        root = if root then '/' else "/#{name()}/"
        """https://s3-#{process.env.AWS_S3_REGION}.amazonaws.com/\
          #{process.env.AWS_S3_BUCKET}#{root}#{path}"""

    res.locals.file = (path) ->
      if process.env.NODE_ENV isnt 'production'
        "/files/#{name()}/#{path}"
      else
        """https://s3-#{process.env.AWS_S3_REGION}.amazonaws.com/\
          #{process.env.AWS_S3_BUCKET}/#{name()}/#{path}"""

    done()

  if process.env.NODE_ENV isnt 'production'

    ###
    Initialize the less middleware to compile our css assets on the
    fly.
    ###
    app.use '/assets', less(process.cwd(),
      dest: 'public'
      parser:
        paths: [
          'styles'
          '.'
          'public/components'
        ]
    )

    app.use '/assets', less("#{process.cwd()}/websites",
      dest: 'public'
      parser:
        paths: [
          'styles'
          '.'
          'public/components'
        ]
    )

    app.use '/assets', browserify("#{process.cwd()}",
      transform: ['coffeeify', 'jadeify']
      extensions: ['.coffee']
      grep: /^\/[a-z0-9_-]+\/client\/[a-z0-9_]+\.(?:coffee)$/
    )

    app.use '/assets', browserify("#{process.cwd()}/websites",
      transform: ['coffeeify', 'jadeify']
      extensions: ['.coffee']
      grep: /^\/[a-z0-9_-]+\/client\/[a-z0-9_]+\.(?:coffee)$/
    )

    app.use '/assets/:website', (req, res, done) ->
      if req.website?.name is req.params.website
        serve("websites/#{req.params.website}/public") req, res, done
      else
        serve("#{req.params.website}/public") req, res, done

    app.use '/files/:website', (req, res, done) ->
      res.download("websites/#{req.params.website}/public/#{req.url}")

    app.use '/assets', serve("#{process.cwd()}/public")

  app
