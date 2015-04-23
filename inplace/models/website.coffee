mongoose = require('mongoose')

Schema = mongoose.Schema

schema = new Schema(
  isActive:
    type: Boolean
    default: true

  users: [
    type: Schema.Types.ObjectId
    ref: 'User'
  ]
  name:
    type: String
    required: true

  # Sometimes we need a readonly flag.  E.g. if the main page wasn't
  # created yet.
  readOnly:
    type: Boolean
    default: false
  domains: [String]
  multilang:
    type: Boolean
    default: false
  defaultlang:
    type: String
    default: 'de'
  files: [
    _id: Schema.Types.ObjectId
    key: String
    filename: String
    type: {type: String}

    # Saving the aws bucket.
    bucket: String

    # File size.
    byteCount: Number

    # aws region.
    region: String
    created: Number
  ],
  global: {
    type: Schema.Types.Mixed,
    default: {}
  }
)

module.exports = mongoose.model('Website', schema)
