// Not gonna lie, approximatley 83.275% of my code was copied and pasted

const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const RecordingSchema = new mongoose.Schema({
    appointment: {
        type: Schema.Types.ObjectID,
        ref: 'appointment'
    },
    user: {
        type: String
    },
    date: {
        type: Date,
	default: Date.now
    },
    composer: {
        type: String
    },
    title: {
        type: String,
	default: "No title has been given"
    },
    time: {
        type: Number
    },
    id: {
        type: String
    },
    length: {
        type: Number
    },
    filename: {
        type: String,
    },
    type: {
        type: String
    },
    private: {
        type: Boolean,
        default: false
    },
    description: {
        type: String,
        default: "No descritption has been added"
    }
});

module.exports = Recording = mongoose.model('recordings', RecordingSchema);
