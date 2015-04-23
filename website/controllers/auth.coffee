qs = require('querystring')

mongoose = require('mongoose')
passport = require('passport')

Website = mongoose.model('Website')

exports.show = (req, res, done) ->
  fail = if req.query.fail then true else false
  if req.website and req.website.name isnt 'website'
    req.website.populate 'users', (err, website) ->
      return done(err) if err
      email = if website.users.length is 1 then website.users[0].email else ''
      url = """
        #{process.env.WD_URL}/auth?\
        #{qs.stringify website: website._id.toString(), email: email}"""
      return res.redirect(url)
  else
    res.render 'auth',
      fail: fail
      website: req.query.website
      email: req.query.email

exports.create = (req, res, done) ->
  middleware = passport.authenticate('local',
    failureRedirect: "#{req.baseUrl}/auth?fail=1"
  )
  middleware req, res, (err) ->
    return done(err) if err
    unless req.body.website
      return res.redirect('/admin') if req.user.isAdmin
    query =
      if req.body.website
        _id: req.body.website
      else
        users: $elemMatch: $in: [req.user._id]
    Website.findOne query, (err, website) ->
      return done(err) if err
      return res.redirect("#{req.baseUrl}/") unless website
      res.redirect "#{res.locals.websiteUrl(website)}?sid=#{req.sessionID}"

exports.destroy = (req, res, done) ->
  req.logout()
  res.redirect "#{req.baseUrl}/auth"
