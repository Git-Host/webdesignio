
# Proper implementation of expressjs/flash
module.exports = (req, res, next) ->
  unless Array.isArray(req.session.flash)
    req.session.flash = []
  res.locals.flash = req.session.flash.slice()
  req.session.flash = []
  req.flash = (type, message) ->
    unless message?
      message = type
      type = 'info'
    m =
      type: type
      message: message
    res.locals.flash.push m
    req.session.flash.push m
  res.locals.basedir = "#{__dirname}"
  res.locals.req = req
  next()
