mongoose = require('mongoose')

User = mongoose.model('User')
Website = mongoose.model('Website')

updateDomainCache = (redis, old, website, done) ->
  args = []
  args.push """
    if table.getn(KEYS) > 0 then
      redis.call('del', unpack(KEYS))
    end
    for i=2, table.getn(ARGV) do
      redis.call('set', 'apps:'..ARGV[i], ARGV[1])
    end
  """
  args.push old.length
  args = args.concat(old.map (o) -> "apps:#{o}")
  args.push website.name
  args = args.concat(website.domains)
  redis.eval.call redis, args, done

exports.list = (req, res) ->
  Website.find (err, websites) ->
    res.render 'websites/list',
      websites: websites

exports.new = (req, res, done) ->
  User.find (err, users) ->
    return done(err) if err
    res.render 'websites/edit',
      website: new Website()
      users: users

exports.edit = (req, res, done) ->
  User.find (err, users) ->
    return done(err) if err
    Website.findById req.params.website
      .populate 'users'
      .exec (err, website) ->
        return done(err) if err
        return done() unless website
        res.render 'websites/edit',
          website: website
          users: users

exports.update = (req, res, done) ->
  Website.findById req.params.website, (err, website) ->
    return done(err) if err
    return done() unless website
    old = website.domains
    for key, value of req.body
      if key is 'domains'
        try
          website[key] = JSON.parse(value)
        catch e
          return done(e)
      else
        website[key] = value
    website.users = [] unless req.body.users?
    website.save (err, website) ->
      return done(err) if err
      updateDomainCache req.redis, old, website, (err) ->
        return done(err) if err
        res.redirect "#{req.baseUrl}/websites/#{website._id}/edit"

exports.destroy = (req, res, done) ->
  Website.findById req.params.website, (err, website) ->
    return done(err) if err
    return done() unless website
    website.remove (err) ->
      return done(err) if err
      updateDomainCache req.redis, website.domains,
        website: website.name
        domains: []
      , (err) ->
        return done(err) if err
        res.redirect "#{req.baseUrl}/websites"

exports.create = (req, res, done) ->
  website = new Website()
  for key, value of req.body
    if key is 'domains'
      try
        website[key] = JSON.parse(value)
      catch e
        return done(e)
    else
      website[key] = value
  website.save (err, website) ->
    return done(err) if err
    updateDomainCache req.redis, [], website, (err) ->
      return done(err) if err
      res.redirect "#{req.baseUrl}/websites/#{website._id}/edit"
