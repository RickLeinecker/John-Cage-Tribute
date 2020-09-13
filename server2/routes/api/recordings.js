/*
const express = require('express');
const axios = require('axios');
const config = require('config');
const router = express.Router();
const auth = require('../../middleware/auth');
const { check, validationResult } = require('express-validator');
const normalize = require('normalize-url');
const Recording = require('../../models/Recording');
const User = require('../../models/User');
// GRIDfs requirements in another file in order to keep everything clean
require('./upload+download')(router);

// Get all recordings by a specific user
// Delete user and recordings

// @route    PUT api/recordings/:id
// @desc     Edit recording information
// @access   Private
router.put('/:id', auth, async (req, res) => {
  try {
    const recording = await Recording.findById(req.params.id);
    if (!recording) {
      return res.status(404).json({ msg: 'Recording not found' });
    }
    if (recording.host.toString() != req.user.id) {
      return res.status(401).json({ msg: 'User not authorized' });
    }
    if (req.body.description.length > 256) {
      return res
        .status(400)
        .json({ errors: [{ msg: 'Description is too long!' }] });
    }
    if (req.body.title.length > 80) {
      return res.status(400).json({ errors: [{ msg: 'Title is too long!' }] });
    }
    if (req.body.tag1.length > 40) {
      return res.status(400).json({ errors: [{ msg: 'Tag is too long!' }] });
    }
    if (req.body.tag2.length > 40) {
      return res.status(400).json({ errors: [{ msg: 'Tag is too long!' }] });
    }
    if (req.body.tag3.length > 40) {
      return res.status(400).json({ errors: [{ msg: 'Tag is too long!' }] });
    }
    recording.title = req.body.title;
    recording.description = req.body.description;
    recording.tags = {
      tag1: req.body.tag1,
      tag2: req.body.tag2,
      tag3: req.body.tag3
    };
    await recording.save;
    res.json(recording);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server error');
  }
});
// @route    GET api/recordings
// @desc     Get all recordings
// @access   Public
router.get('/', async (req, res) => {
  try {
    recording = await Recording.find().sort({ date: -1 });
    res.json(recording);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server error');
  }
});
// @route    GET api/recordings/:id
// @desc     Get recording by ID
// @access   Public
router.get('/:id', async (req, res) => {
  try {
    const recording = await Recording.findById(req.params.id).sort({
      start: -1
    });
    if (!req.params.id.match(/^[0-9a-fA-F]{24}$/) || !recording) {
      return res.status(404).json({ msg: 'recording not found' });
    }
    res.json(recording);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server error');
  }
});
// @route    GET api/recordings/own
// @desc     Get all of own recordings
// @access   Private
router.get('/own', auth, async (req, res) => {
  try {
    const compare = await User.findById(req.user.id).select('-password');
    const recordings = await Recording.find({ host: compare.id }).sort({
      start: -1
    });
    res.json(recordings);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server error');
  }
});
// Client will handle search by hostname/desc/title/tags.
module.exports = router;
*/
