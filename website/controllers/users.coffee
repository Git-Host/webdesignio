async = require('async')
mongoose = require('mongoose')
_ = require('highland')

User = mongoose.model('User')

exports.create = (req, res, done) ->
  unless req.body.password
    req.flash 'danger', 'Bitte ein Passwort angeben!'
    return res.render('register', req.body)

  unless req.body.password is req.body.password2
    req.flash 'danger', 'Passwörter stimmen nicht überein!'
    return res.render('register', req.body)

  getUser = _.wrapCallback(User.findOne.bind(User))

  getUser email: req.body.email, hash: $exists: false
    .filter (x) -> x?
    .flatMap _.wrapCallback (user, next) ->
      user.name = req.body.name if req.body.name
      user.setPassword req.body.password, next
    .flatMap _.wrapCallback (user, next) -> user.save next
    .errors done
    .toArray (users) ->
      return done() unless users.length
      req.flash 'success', 'Account erfolgreich erstellt!'
      res.redirect "#{req.baseUrl}/auth"
