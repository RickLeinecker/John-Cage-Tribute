const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const AppointmentSchema = new Schema({
    user: {
        type: mongoose.Schema.Types.ObjectID,
        ref: 'users'
    },

    composer: {
        type: String
    },

    title: {
        type: String,
        required: true
    },

    pin: {
        type: Number,
        required: true
    },

    time: {
        type: Number,
        required: true
    },

    start: {
        type: Date,
        required: true
    },

    end: {
        type: Date
    },

    members: {
        type: Number,
        required: true
    },

    logged: {
        type: Number,
        default: 0
    },
});

module.exports = Appointment = mongoose.model('appointment', AppointmentSchema);