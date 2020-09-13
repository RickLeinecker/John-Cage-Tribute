/*const mongoose = require('mongoose');

const RecordingSchema = new mongoose.Schema({
  host: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'user'
  },
  duration: {
    type: Number,
    required: true
  },
  description: {
    type: String,
    default: 'No description has been added.'
  },
  performers: [
    {
      user: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'user'
      }
    }
  ],
  title: {
    type: String,
    required: true,
    default: '(Untitled)'
  },
  date: {
    type: Date,
    default: Date.now
  },
  tags: [
    {
      tag1: {
        type: String
      },
      tag2: {
        type: String
      },
      tag3: {
        type: String
      }
    }
  ],
  fileid: {
    type: String
  },
  filesize: {
    type: Number
  },
  filename: {
    type: String
  },
  contenttype: {
    type: String
  },
  pin: {
    type: Number,
    required: true
  },
  numberofrecorders: {
    // We may be able to remove this and handle it on the frontend
    type: Number,
    required: true
  },
  numberoflisteners: {
    // We may be able to remove this and handle on the frontend
    type: Number,
    required: true
  }
});

module.exports = Recording = mongoose.model('recording', RecordingSchema);
*/
