mongoose = require('mongoose')
async = require('async')
error = require('util').error
log = require('util').log

models = require('inplace/models')

mongooseUrl = process.env.MONGOHQ_URL
mongooseUrl = process.env.MONGOLAB_URI unless mongooseUrl?

unless mongooseUrl

  # Construct connection url from docker environment variables.
  mongooseUrl = """mongodb://#{process.env.MONGO_PORT_27017_TCP_ADDR}:\
    #{process.env.MONGO_PORT_27017_TCP_PORT}/starterkit"""

mongoose.connect mongooseUrl, (err) ->
  if err
    error(err)
    process.exit(-1)

models.Website.find (err, websites) ->
  if err
    error(err)
    process.exit(-1)

  numberAffected = 0
  async.each(
    websites,
    (website, cb) ->
      for file in website.files
        file.type = 'img'
        numberAffected++
      website.save(cb)
    (err) ->
      if err
        error(err)
        process.exit(-1)
      log "Updated type of " + numberAffected + " files"
  )
