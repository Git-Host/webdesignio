express = require('express')

app = module.exports = express()

###
Set language(s) by content-negotiation or user override
###
app.use (req, res, next) ->
  req.session.acceptedLanguages = req.acceptsLanguages()

  req.session.acceptedLanguages = \
    (lang.split('-')[0] for lang in req.session.acceptedLanguages)

  unless req.session.lang
    req.session.lang = req.session.acceptedLanguages[0]

  req.session.lang = req.query.lang if req.query.lang?

  next()
