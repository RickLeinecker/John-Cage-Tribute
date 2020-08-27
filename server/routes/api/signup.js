const express = require('express')
const router = express.Router()
const bcrypt = require('bcryptjs')
const jwt = require('jsonwebtoken')

const User = require('../../models/User')

router.post("/", async (req, res) => {
    const { email, username, password } = req.body

    // Simple validation
    if (!email || !username || !password) {
        console.log('Please enter all fields.')
        return res
            .status(400)
            .json({ email, username, password, msg: "Please enter all fields." })
    }

    try {
        // Check for existing user
        console.log('Finding an email...')
        const existingEmail = await User.findOne({ email })

        if (existingEmail) {
            console.log('Existing email...')
            return res
                .status(400)
                .json({ msg: "User with that email already exists." })
        }

        // Check for existing user
        console.log('Finding a username...')
        const existingUsername = await User.findOne({ username })

        if (existingUsername) {
            console.log('Existing username...')
            return res
                .status(400)
                .json({ msg: "User with that username already exists." })
        }

        console.log('Creating newUser object from User schema...')

        const newUser = new User({
            email,
            username,
            password
        })

        console.log('Salting and hashing...')

        // Create salt & hash
        const salt = await bcrypt.genSalt(10);
        const hash = await bcrypt.hash(newUser.password, salt)

        newUser.password = hash;
        const savedUser = await newUser.save()

        console.log('Signing JWT...')

        jwt.sign(
            { id: savedUser.id },
            process.env.JWT_SECRET,
            (err, token) => {
                if (err) {
                    throw err;
                }

                res.json({
                    token,
                    user: {
                        id: savedUser.id,
                        email: savedUser.email,
                        username: savedUser.username,
                        password: savedUser.password
                    }
                })
            }
        )
    } catch (err) {
        console.log('General error: ', err)
        res.status(404).json({ success: false, msg: err })
    }
})

module.exports = router