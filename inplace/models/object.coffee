mongoose = require('mongoose')

Schema = mongoose.Schema

schema = new Schema(
  website:
    type: Schema.Types.ObjectId
    required: true
  type:
    type: String
    required: true
  properties:
    type: Schema.Types.Mixed
    required: true
    default: {}
)

module.exports = mongoose.model('Object', schema)
