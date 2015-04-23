mongoose = require('mongoose')
express = require('express')
_ = require('underscore')
bodyParser = require('body-parser')
resource = require('lib/resource')

models = require('./models')

Page = models.Page
_Object = models.Object
app = module.exports = express()
router = express.Router()

app.use '/inplace', router

###
#Select Page, Object or global language
###
selectLang = (req, obj) ->
  if obj instanceof Page
    obj = obj.content
  else if obj instanceof _Object
    obj = obj.properties
  else
    obj = req.website.global

  # Use preferred or user-defined language
  if req.session.lang
    lang = req.session.lang if obj[req.session.lang]?

  # Use another accepted language as second choice
  unless lang?
    lang = (lang for lang in (req.session.acceptedLanguages or []) \
      when obj[lang]?)[0]

  # Fallback to default language
  unless lang?
    lang = req.website.defaultlang

  return lang

###
Register new cms page.
###
app.page = (slug, view) ->
  view = slug unless view?
  (req, res, done) ->
    req.page slug, (err, page) ->
      return done(err) if err
      res.set('Content-Language', selectLang(req, page))
      res.render view, page: page

app.use (req, res, done) ->

  ###
  Lazy load a page.
  ###
  req.page = (slug, fn) ->
    Page.findOne
      website: req.website._id
      slug: slug
    , (err, page) ->
      return fn(err) if err

      unless page?
        page = new Page(
          slug: slug
          website: req.website._id
        )

      lang = selectLang(req, page)
      page.content = page.content[lang] unless _.isEmpty(page.content)

      if req.website.global?
        # Check again for global translation
        lang = selectLang(req)
        for own key of req.website.global[lang]
          page.content[key] = req.website.global[lang][key]

      fn null, page

  req.removeObject = (id, fn) ->
    _Object.remove
      website: req.website._id
      _id: id
    , (err) ->
      if err
        if err.name is 'CastError'
          fn()
        else
          fn(err)
        return
      fn()

  ###
  Lazy load an object.
  ###
  req.object = (type, id, fn) ->
    if typeof id is 'function'
      fn = id
      id = null
    unless id?
      object = new _Object(
        website: req.website._id
        type: type
      )
      return fn(null, object)
    query =
      website: req.website._id
      type: type
      _id: id
    _Object.findOne query, (err, object) ->
      if err
        if err.name is 'CastError'
          fn()
        else
          fn(err)
        return
      return fn() unless object

      lang = selectLang(req, object)
      object.properties = object.properties[lang] \
        unless _.isEmpty(object.properties)

      if req.website.global?
        # Check again for global translation
        lang = selectLang(req)
        for own key of req.website.global[lang]
          object.properties[key] = req.website.global[lang][key]

      fn null, object

  ###
  Query for user objects.
  ###
  req.objects = (type, query, fn) ->
    if typeof query is 'function'
      fn = query
      query = {}
    query.website = req.website._id
    query.type = type
    _Object.find query, (err, objects) ->
      return fn(err) if err

      for object in objects
        lang = selectLang(req, object)
        object.properties = object.properties[lang] \
          unless _.isEmpty(object.properties)

      fn null, objects

  res.renderPage = (slug, view, locals) ->
    locals = {} unless locals?
    req.page slug, (err, page) ->
      res.render view,
        _.extend(
          {}
        ,
          locals
        ,
          page: page
        )

  done()

router.use (req, res, done) ->
  return res.sendStatus(403) unless req.canEditWebsite()
  done()

router.use bodyParser.json()
resource router, 'page', require('./controllers/pages')
resource router, 'object', require('./controllers/objects')
resource router, 'image', require('./controllers/images')
resource router, 'file', require('./controllers/downloads')
