###
Controller for newsletter list entries.
###

{MailChimpAPI} = require('mailchimp')

do ->
  try
    mc = new MailChimpAPI(process.env.MAILCHIMP_API_KEY, version: '2.0')
  catch e
    require('util').log e.message

  exports.create = (req, res, done) ->
    unless req.body.email
      req.flash 'danger', '''
        Bitte eine gültige E-Mail Adresse eintragen!
      '''
      return res.redirect("#{req.baseUrl}/#subscribe")
    mc.call 'lists', 'list', filter: name: 'web-design.IO News', (err, data) ->
      return done(err) if err
      return done() unless data.total
      list = data.data[0]
      mc.call 'lists', 'subscribe',
        id: list.id
        email:
          email: req.body.email
      , (err, data) ->
        return done(err) if err
        req.flash 'success', '''
          Eine Bestätigungsemail wurde an dich versandt! Vielen Dank!
        '''
        res.redirect "#{req.baseUrl}/#subscribe"
