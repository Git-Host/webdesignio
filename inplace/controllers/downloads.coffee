files = require('./files')

exports.create = (req, res, done) ->
  return files.create(req, res, done, 'file', 'attachment')

exports.list = (req, res) ->
  return files.list(req, res, 'file')

exports.destroy = (req, res, done) ->
  return files.destroy(req, res, done, req.params.file)
