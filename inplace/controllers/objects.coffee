mongoose = require('mongoose')
_ = require('underscore')

_Object = mongoose.model('Object')

selectLang = (req) ->
  if req.session.lang?
    lang = req.session.lang
  else
    lang = req.website.defaultlang

exports.update = (req, res, done) ->
  _Object.findById req.params.object, (err, object) ->
    return done(err) if err

    object ?= new _Object(
      _id: req.params.object
      website: req.website._id
      type: req.body.type
    )

    lang = selectLang(req)
    object.properties[lang] = req.body.properties
    object.markModified('properties')

    object.save (err, object, n) ->
      return done(err) if err

      object.properties = object.properties[lang]

      if req.body.global?
        if req.website.global[lang]?
          _.extend req.website.global[lang], req.body.global
        else
          req.website.global[lang] = req.body.global
        req.website.markModified('global')
        req.website.save (err, website, n) ->
          return done(err) if err
          res.send object
      else
        res.send object
