
express = require('express')
mongoose = require('mongoose')
cookieParser = require('cookie-parser')
cookie = require('cookie')
signature = require('cookie-signature')
session = require('express-session')
bodyParser = require('body-parser')
passport = require('passport')
RedisStore = require('connect-redis')(session)
redis = require('redis')
require('express-resource')

# Load project module.
Project = require('lib/project')

# Load all the models of the applications.
require './api/models'

User = mongoose.model('User')

project = module.exports = Project()

project.set 'view engine', 'jade'
project.set 'cookie secret', process.env.COOKIE_SECRET || 'keyboard cat'

if process.env.REDISCLOUD_URL
  redisUrl = require('url').parse(process.env.REDISCLOUD_URL)
  redisAuth = redisUrl.auth.split(':')
  project.set 'session store options',
    host: redisUrl.hostname
    port: redisUrl.port
    pass: redisAuth[1]
else
  project.set 'session store options',
    host: process.env.REDIS_PORT_6379_TCP_ADDR
    port: process.env.REDIS_PORT_6379_TCP_PORT

project.set 'session store', new RedisStore(
  project.get 'session store options'
)

do ->
  options = project.get('session store options')
  opts = {}
  opts.auth_pass = options.pass if options.pass
  project.set 'redis', redis.createClient(
    parseInt(options.port)
    options.host
    opts
  )

###
Serialize user.
###
passport.serializeUser (user, next) ->
  next null, user._id

###
Deserialize user from database.
###
passport.deserializeUser (id, next) ->
  User.findById id, (err, user) ->
    return next(err) if err
    next null, user

# Create Strategy for database user.
passport.use User.createStrategy()

project.use bodyParser.urlencoded(extended: true)

###
Little hack to transfer the session id to the redirect URL.
###
project.use (req, res, done) ->
  return done() unless req.query.sid?

  # Hack in new redirected session id.
  cookies = cookie.parse(req.headers.cookie or '')
  cookies['connect.sid'] = req.query.sid
  args = []
  for own key, value of cookies
    if key is 'connect.sid'
      secret = project.get('cookie secret')
      value = "s:#{signature.sign(value, secret)}"
    args.push [key, value]
  args = args.map (a) -> cookie.serialize.apply(cookie, a)
  req.headers.cookie = args.join('; ')
  req.sessionIdInjected = true
  done()

project.use cookieParser(project.get('cookie secret'))
project.use session(
  secret: project.get('cookie secret')
  store: project.get('session store')
  saveUninitialized: true
  resave: true
  rolling: true
)
project.use passport.initialize()
project.use passport.session()

project.use (req, res, done) ->

  # Redirect the user to his/her website after injecting the session cookie.
  return done() unless req.sessionIdInjected
  proto = if project.get('env') is 'production' then 'https' else 'http'
  res.redirect "#{proto}://#{req.get('host')}"

project.use require('method-override')('_method')

project.use require('lib/flash')

project.use (req, res, done) ->
  Website = mongoose.model('Website')

  # Set template rootpath.
  res.locals.basedir = process.cwd()
  res.locals.req = req
  res.locals.websiteUrl = (website) ->
    return null unless website.domains[0]
    proto = if project.get('env') is 'production' then 'https' else 'http'
    domain = "#{proto}://#{website.domains[0]}"
    domain += ":#{req.vhost.port}" if req.vhost.port
    domain

  req.redis = project.get('redis')
  u = require('url').parse('http://' + req.get('host'))
  req.vhost =
    port: u.port
    host: u.host
    hostname: u.hostname

  ###
  Check if we could edit the website if it wasn't read-only.
  ###
  req.couldEditWebsite = ->
    return false unless req.website
    return false unless req.isAuthenticated()
    return true if req.user.isAdmin
    return false unless req.website.users
    if req.isAuthenticated()
      for user in req.website.users
        return true if user.equals(req.user._id)
    false

  ###
  Provide method to get editing status.
  ###
  req.canEditWebsite = ->
    return false unless req.couldEditWebsite()
    return false if req.website.readOnly
    true

  ###
  Resolve website object.
  ###
  Website.findOne
    domains: $elemMatch: $in: [req.vhost.hostname]
  , (err, website) ->
    return done(err) if err
    return done() unless website
    req.website = website
    done()

# Load all applications.
project.boot [
  ['assets']
  'docs'
  'inplace'
  'admin'
  'i18n'
  'dispatcher'
  'website'
]
