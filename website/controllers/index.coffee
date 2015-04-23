exports.register = (req, res) -> res.render 'register'
exports.users = require('./users')
exports.auth = require('./auth')
