fs = require('fs')

express = require('express')

app = module.exports = express()
router = express.Router()

app.use '/docs', router

router.use (req, res, done) ->
  return res.redirect('/') unless req.isAuthenticated()
  done()

router.get '/', (req, res) ->
  res.render 'index'

router.get /^([a-z0-9\/]+)$/, (req, res, done) ->
  section = req.params[0]
    .replace(/^\//, '')
    .replace(/\/$/, '')
  unless fs.existsSync("#{__dirname}/views/#{section}.jade")
    return done()
  res.render section
