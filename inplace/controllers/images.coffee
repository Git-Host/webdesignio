files = require('./files')

exports.create = (req, res, done) ->
  return files.create(req, res, done, 'img', 'inline')

exports.list = (req, res) ->
  return files.list(req, res, 'img')

exports.destroy = (req, res, done) ->
  return files.destroy(req, res, done, req.params.image)
