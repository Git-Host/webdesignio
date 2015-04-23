mongoose = require('mongoose')
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

models.Website.update {},
  {$set: {defaultlang: 'de'}},
  {multi: true},
  (err, numberAffected) ->
    if err
      error(err)
      process.exit(-1)
    log "Updated defautlang of " + numberAffected + " Websites"

models.Page.find (err, pages) ->
  if err
    error(err)
    process.exit(-1)

  for page in pages
    content = page.content
    page.content = {}
    page.content['de'] = content

  page.save() for page in pages
  log "Updated content of " + pages.length + " Pages"

models.Object.find (err, objects) ->
  if err
    error(err)
    process.exit(-1)

  for object in objects
    properties = object.properties
    object.properties = {}
    object.properties['de'] = properties

  object.save() for object in objects
  log "Updated properties of " + objects.length + " Objects"
