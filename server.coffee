
# Integrate with nodetime.
if process.env.NODETIME_ACCOUNT_KEY
  require('nodetime').profile
    accountKey: process.env.NODETIME_ACCOUNT_KEY
    appName: require('./package').name

log = require('util').log
http = require('http')

mongoose = require('mongoose')

project = null
mongooseUrl = process.env.MONGOHQ_URL
mongooseUrl = process.env.MONGOLAB_URI unless mongooseUrl?
port = process.env.PORT or 3000

unless mongooseUrl

  # Construct connection url from docker environment variables.
  mongooseUrl = """mongodb://#{process.env.MONGO_PORT_27017_TCP_ADDR}:\
    #{process.env.MONGO_PORT_27017_TCP_PORT}/starterkit"""

server = http
  .createServer (req, res) ->
    run = =>
      project.call this, req, res

    # Boot the application directly if mongoose is already connected.
    return run() if project

    # Attempt to connect.
    mongoose.connect mongooseUrl, (err) ->
      return res.end('Failed to connect to database!') if err
      project = require('./index')
      project.set 'server', server

      # Integrate with newrelic.
      require('newrelic') if process.env.NEW_RELIC_LICENSE_KEY
      run()

  # Listen on port 3000 which is brought outside of docker.
  .listen port, ->
    log 'server listening'
