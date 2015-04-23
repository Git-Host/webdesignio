mailgun = require('mailgun-js')(
  apiKey: process.env.MAILGUN_API_KEY
  domain: process.env.MAILGUN_DOMAIN
)

exports.create = [
  (req, res, next) ->
    if not req.body.name or not req.body.message or not req.body.email
      return res.sendStatus(400)
    body =
      from: "#{req.body.name} <#{req.body.email}>"
      to: 'info@domachine.de'
      subject: "[web-design.IO] Message from #{req.body.name}"
      text: req.body.message
    mailgun.messages().send body, (err, body) ->
      return next(err) if err
      res.send
        status: 'ok'
        messages: ok: message: 'Nachricht erfolgreich abgesendet!'
]
