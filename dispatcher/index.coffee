url = require('url')

express = require('express')
async = require('async')
mongoose = require('mongoose')

Website = mongoose.model('Website')

###
Configure an app.
###
configure = (name) ->
  path = require.resolve(name)
  app = require(path)
  path = require('path').dirname(path)
  router = express.Router()
  app.set 'view engine', 'jade'
  app.set 'views', "#{path}/views"

  ###
  Redirect user always to the root domain of the application.
  ###
  router.use (req, res, done) ->
    unless req.vhost.hostname is req.website.domains[0]
      return res.redirect(
        "#{res.locals.websiteUrl(req.website)}#{req.originalUrl}"
      )
    else
      done()
  router.use app

  router

apps = {}

app = module.exports = express()

###
Middlware to find matching app.
###
app.use (req, res, done) ->
  r = req.redis
  return done() unless req.website
  r.get "apps:#{req.vhost.hostname}", (err, result) =>
    return done(err) if err
    return done() unless result
    app = apps[result]
    try
      app = apps[result] = configure(result) unless app?
    catch e
      return done(e)
    app.call this, req, res, done

###
Fill the cache initially.
###
app.on 'mount', (parent) ->
  c = parent.get('redis')
  Website.find (err, websites) ->
    return if err
    async.each websites, (website, next) ->
      async.each website.domains, (domain, next) ->
        c.set "apps:#{domain}", website.name, next
      , next
    , (err) ->
      log = require('util').log
      return log(err) if err
      log 'Cache filled'
