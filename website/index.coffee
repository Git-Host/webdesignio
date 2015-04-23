
express = require('express')
mongoose = require('mongoose')

resource = require('lib/resource')
inplace = require('inplace')

controllers = require('./controllers')

Website = mongoose.model('Website')

app = module.exports = express()

app.use (req, res, done) ->
  if not req.website? and req.vhost.hostname isnt process.env.WD_HOSTNAME
    return res.redirect(process.env.WD_URL)
  unless req.website?
    req.website = new Website(
      name: 'website'
      domains: [req.vhost.hostname]
      readOnly: true
    )
  done()

app.get '/', inplace.page('home', 'index')
app.get '/portfolio', inplace.page('portfolio', 'portfolio')
app.get '/portfolio/anne-ammann', inplace.page('p_anne_ammann', 'portfolio_items/anne_ammann')
app.get '/portfolio/anycom', inplace.page('p_anycom', 'portfolio_items/anycom')
app.get '/portfolio/dratanassov', inplace.page('p_atanassov', 'portfolio_items/dratanassov')
app.get '/portfolio/pbm', inplace.page('p_pbm', 'portfolio_items/pbm')
app.get '/impressum', inplace.page('impressum', 'impressum')

app.get '/register', controllers.register
app.post '/register', controllers.users.create
app.route '/auth'
  .get controllers.auth.show
  .post controllers.auth.create
app.get '/logout', controllers.auth.destroy

resource app, 'message', require('./controllers/messages')
resource app, 'email', require('./controllers/emails')

app.all '*', (req, res) -> res.status(404).render '404'
