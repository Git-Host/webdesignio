mongoose = require('mongoose')
_ = require('underscore')

User = mongoose.model('User')

exports.list = (req, res, done) ->
  User.find (err, users) ->
    return done(err) if err
    res.render 'users/list',
      users: users

exports.new = (req, res, done) ->
  user = new User()
  res.render 'users/edit', user: user

exports.create = (req, res, done) ->
  User.findOneAndUpdate
    email: req.body.email
  ,
    $setOnInsert:
      email: req.body.email
  ,
    upsert: true
  , (err, user) ->
    return done(err) if err
    res.redirect "#{req.baseUrl}/users/#{user._id}/edit"

exports.edit = (req, res, done) ->
  User.findById req.params.user, (err, user) ->
    return done(err) if err
    return done() unless user
    res.render 'users/edit',
      user: user

exports.update = (req, res, done) ->
  User.findById req.params.user, (err, user) ->
    return done(err) if err
    return done() unless user
    delete req.body.email
    user.isAdmin = req.body.isAdmin is 'on'
    user.hash = undefined if req.body.reset is 'on'
    _.extend user, req.body
    user.save (err, user) ->
      return done(err) if err
      res.redirect "#{req.baseUrl}/users/#{user._id}/edit"

exports.destroy = (req, res, done) ->
  User.findById req.params.user, (err, user) ->
    return done(err) if err
    return done() unless user
    user.remove (err, user) ->
      return done(err) if err
      res.redirect "#{req.baseUrl}/users"
