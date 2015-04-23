log = require('util').log

mongoose = require('mongoose')
passportLocalMongoose = require('passport-local-mongoose')

schema = new mongoose.Schema(
  isActive:
    type: Boolean
    default: true

  name: String
  email:
    type: String
    required: true

  # Indicates if this user is an admin user.  Refer to /docs/users.
  isAdmin:
    type: Boolean
    default: false
)
schema.plugin passportLocalMongoose,
  usernameField: 'email'
module.exports = mongoose.model('User', schema)
