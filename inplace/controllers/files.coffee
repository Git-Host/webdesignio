async = require('async')
AWS = require('aws-sdk')
multiparty = require('multiparty')
mongoose = require('mongoose')
_ = require('underscore')
contentDisposition = require('content-disposition')

Website = mongoose.model('Website')

exports.create = (req, res, done, type, contentDispositionType) ->
  s3 = new AWS.S3()
  form = new multiparty.Form()
  streams = 0
  limit = 5000000
  received = false
  form.on 'part', (part) ->
    return part.resume() unless part.filename
    return part.resume() if received
    received = true
    if part.byteCount > limit
      return res.status(400).send("Datei #{part.filename} zu groß!")
    ++streams
    async.waterfall [
      (next) ->
        id = new mongoose.Types.ObjectId()
        part.on 'error', next
        s3.putObject
          Body: part
          Bucket: 'web-designio'
          ACL: 'public-read'
          Key: "#{req.website._id.toString()}/#{id.toString()}"
          ContentLength: part.byteCount
          ContentType: part.headers['content-type']
          ContentDisposition: contentDisposition(part.filename, contentDispositionType)
        , (err, data) ->
          return next(err) if err
          next null, id

      (id, next) ->
        update =
          $inc:
            __v: 1
            quotaSize: part.byteCount
          $push:
            files:
              _id: id
              key: "#{req.website._id.toString()}/#{id.toString()}"
              filename: part.filename
              bucket: 'web-designio'
              byteCount: part.byteCount
              region: 'eu-west-1'
              created: new Date().getTime()
              type: type
        Website.collection.update
          _id: req.website._id
        ,
          update
        , (err, num) ->
          return next(err) if err
          return done() unless num
          next()
    ], (err) ->
      return done(err) if err
      --streams
      return reply() unless streams

  form.on 'error', done
  form.on 'close', ->
    return reply() unless streams

  reply = ->
    res.send()

  form.parse req

exports.list = (req, res, type) ->
  files = _.filter(req.website.files, (file) -> return file.type == type)
  res.send _.sortBy(files, (x) -> 0 - x.created)

###
Destroy a file from the specified through s3.
###
exports.destroy = (req, res, done, fileToDelete) ->
  async.waterfall [
    (next) ->
      file = _.find(req.website.files, (f) ->
        f._id.equals fileToDelete
      )
      return done() unless file
      index = req.website.files.indexOf(file)
      $pull = {}
      $pull.files = _id: file._id
      Website.collection.update
        _id: req.website._id
      ,
        $pull: $pull
      , (err, num) ->
        return next(err) if err
        return done() unless num
        next null, file

    (file, next) ->
      s3 = new AWS.S3()
      s3.deleteObject
        Bucket: file.bucket
        Key: file.key
      , (err) ->
        return next(err) if err
        res.send()
  ], done
