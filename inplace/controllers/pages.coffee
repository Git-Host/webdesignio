mongoose = require('mongoose')
_ = require('underscore')

Page = mongoose.model('Page')
Website = mongoose.model('Website')

selectLang = (req) ->
  if req.session.lang?
    lang = req.session.lang
  else
    lang = req.website.defaultlang

exports.update = (req, res, done) ->
  Page.findById req.params.page, (err, page) ->
    return done(err) if err

    page ?= new Page(
      _id: req.params.page
      website: req.website._id
      slug: req.body.slug
    )

    lang = selectLang(req)
    page.content[lang] = req.body.content
    page.markModified('content')

    page.save (err, page, n) ->
      return done(err) if err

      page.content = page.content[lang]

      if req.body.global?
        if req.website.global[lang]?
          _.extend req.website.global[lang], req.body.global
        else
          req.website.global[lang] = req.body.global
        req.website.markModified('global')
        req.website.save (err, website, n) ->
          return done(err) if err
          res.send page
      else
        res.send page
