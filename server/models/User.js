const mongoose = require('mongoose')
const Schema = mongoose.Schema

// Create Schema
const UserSchema = new Schema({
    email: {
        type: String,
        required: true,
        unique: true
    },
    username: {
        type: String,
        required: true,
        unique: true
    },
    password: {
        type: String,
        required: true
    },
    register_date: {
        type: Date,
        default: Date.now
    },


    // TODO: Do this but for compositions n shiet
    //   posts: [{ type: mongoose.Schema.Types.ObjectId, ref: "Yak" }],
    //   comments: [{ type: Schema.Types.ObjectId, ref: "Comment" }]
})

module.exports = User = mongoose.model("User", UserSchema)