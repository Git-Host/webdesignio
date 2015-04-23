express = require('express')

resource = require('lib/resource')

controllers = require('./controllers')

app = module.exports = express()
app.set 'view engine', 'jade'
app.set 'views', "#{__dirname}/views"
router = express.Router()

app.use '/admin', router

router.use (req, res, done) ->
  if req.vhost.hostname isnt process.env.WD_HOSTNAME
    return res.redirect("#{process.env.WD_URL}/admin")
  return res.redirect('/') if not req.isAuthenticated() or not req.user.isAdmin
  req.website = name: 'admin'
  done()

router.get '/', (req, res) -> res.redirect "#{req.baseUrl}/dashboard"
router.get '/dashboard', controllers.dashboard

resource router, 'website', require('./controllers/websites')
resource router, 'user', require('./controllers/users')
