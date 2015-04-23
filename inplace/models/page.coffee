mongoose = require('mongoose')

Schema = mongoose.Schema

schema = new Schema(
  website:
    type: Schema.Types.ObjectId
    required: true
  slug:
    type: String
    required: true
  content:
    type: Schema.Types.Mixed
    required: true
    default: {}
)

module.exports = mongoose.model('Page', schema)
