const express = require('express')
const router = express.Router()
const bcrypt = require('bcryptjs')
const jwt = require('jsonwebtoken')

const auth = require('../../middleware/auth')

// User Model
const users = require('../../models/User')

router.post("/", (req, res) => {
    const { username, password } = req.body

    // Simple validation
    if (!username || !password) {
        return res.status(400).json({ msg: "Please enter all fields." })
    }

    // Check for existing user
    try {
        users.findOne({ username }).then((user) => {
            if (!user) return res.status(400).json(
                { msg: "User does not exist." }
            )

            // Validate password
            bcrypt.compare(password, user.password).then((isMatch) => {
                if (!isMatch) {
                    return res.status(400)
                        .json({ msg: "Invalid credentials." })
                }

                jwt.sign(
                    { id: user.id },
                    process.env.JWT_SECRET,
                    { expiresIn: 3600 },
                    (err, token) => {
                        if (err) throw err
                        res.json({
                            token,
                            user: {
                                id: user.id,
                                email: user.email,
                                username: user.username,
                                password: user.password
                            }
                        })
                    }
                )
            })
        })
    }
    catch (err) {
        console.log('General error: ', err)
        res.status(404).json({ success: false, msg: err })
    }
})

router.post("/existing", auth, (req, res) => {
    users.findById(req.user.id)
        .select("-password")
        .then((user) => {
            console.log('Retrieved user from JWT!')
            res.json(user)
        })
})

module.exports = router