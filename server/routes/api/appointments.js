const express = require('express');
const router = express.Router();
const { check, validationResult } = require('express-validator');
const auth = require('../../middleware/auth.js');

const Appointment = require('../../models/Appointment');
const User = require('../../models/User');

// Composer posts initial appointment

router.post('/',
    [auth,
        [
            check('title', 'title is required').not().isEmpty(),
            check('pin', 'a PIN of 6 digits is required').isLength({ min: 6, max: 6 }),
            check('start', 'please add in a valid date and time').isAfter(),
            check('members', 'please add in a number of performers').isInt({ gt: 1, lt: 9 }),
            check('time', 'please add in the length you want to record').isInt({ gt: 120, lt: 600 })
        ]
    ], async (req, res) => {
        // Checks to make sure all fields have been entered
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(400).json({ errors: errors.array() });
        }

        var start = new Date(req.body.start);
        var time = req.body.time;
        var end = new Date(start.getTime() + (time * 1000));
        var startBuffer = new Date();
        startBuffer.setTime(start.getTime() - (15 * 60000));
        var endBuffer = new Date();
        endBuffer.setTime(end.getTime() + (15 * 60000));

        // Ensure start time doesn't interfere with any other appointment
        try {
            let appointment = await Appointment.findOne({
                start: { $gte: startBuffer, $lte: endBuffer }
            })

            if (appointment) {
                return res.status(400).json({ errors: [{ msg: "Date has already been claimed " }] });
            }

            const user = await User.findById(req.user.id).select('-password');
            appointment = new Appointment({
                user: req.user.id,
                composer: user.username,
                time: time,
                start: start,
                members: req.body.members,
                end: end,
                title: req.body.title,
                pin: req.body.pin,
            });

            await appointment.save();
            res.json(appointment);
        } catch (err) {
            console.error(err.message);
            res.status(500).send("Server error");
        }
    });

// Composer finds initial information about appointment

router.get('/Appts', auth, async (req, res) => {
    try {
        let appointments = await Appointment.find({ user: req.user.id }).sort({ start: 1 });
        res.json(appointments);
    }
    catch (err) {
        console.error(err.message);
        res.status(500).send("Server error");
    }
});

// Composer delets their own appointments

// ]

router.delete('/:id', auth, async (req, res) => {
    try {
        const appointment = await Appointment.findById(req.params.id);
        if (!appointment) {
            return res.status(404).json({ msg: "appointment not found" })
        }

        if (appointment.user.toString() != req.user.id) {
            return res.status(401).json({ msg: 'User not autherized' });
        }
        await appointment.remove();
    }
    catch (err) {
        console.error(err.message);
        res.status(500).send("Server error");
    }
});

// Mobile App Routes
// Get all appointment information

router.get('/', async (req, res) => {
    try {
        const appointments = await Appointment.find().sort({ start: 1 }).select('-pin');
        res.json(appointments);
    }
    catch (err) {
        console.error(err.message);
        res.status(500).send("Server error");
    }
});

// This is used by the mobile app to try to log into an appointment

router.post('/mobile/:id',
    check('pin', 'a PIN of 6 digits is required').isLength({ min: 6, max: 6 }),
    async (req, res) => {

        // Ensure that a pin is actually entered

        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(400).json({ errors: errors.array() });
        }

        try {
            const appointment = await Appointment.findById(req.params.id);
            if (!appointment) {
                return res.status(404).json({ msg: "appointment not found" })
            }
            if (req.body.pin != appointment.pin)
                return res.status(401).json({ msg: 'Invalid pin' });

            if (appointment.logged == appointment.members)
                return res.status(400).json({ msg: "No more room" });
            appointment.logged += 1;

            await appointment.save();

            res.json({ success: true });
        }
        catch (err) {
            console.error(err.message);
            res.status(500).send("Server error");
        }
    });

// This is for testing on the backend

router.put('/remove/:id', async (req, res) => {
    try {
        const appointment = await Appointment.findById(req.params.id);
        if (appointment.logged == 0)
            return res.status(400).json({ msg: "No one has joined" });
        appointment.logged -= 1;

        await appointment.save();

        res.json({ success: true });

    } catch (err) {
        console.error(err.message);
        res.status(500).send("Server error");
    }
});
module.exports = router;