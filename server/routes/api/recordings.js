const express = require('express');
const router = express.Router();
const config = require('config');
const { check, validationResult } = require('express-validator');
const auth = require('../../middleware/auth.js');

const Recording = require('../../models/Recording');
const User = require('../../models/User');

// GRIDfs requirements in another file in order to keep everything clean

require('./upload+download')(router);

//Change the recording information

router.put('/:id', auth, async(req,res) =>  {
  try{
  const recording = await Recording.findById(req.params.id);
  if(!recording)
    return res.status(404).json({ msg: "recording not found"});
  if(recording.user.toString() != req.user.id)
    return res.status(401).json({ msg: 'User not autherized'});
  if (req.body.description.length > 256)
    return res.status(400).json({ errors: [{ msg: "Description is too long"}]});

  recording.private = req.body.private;
  recording.description = req.body.description;
  recording.tags =
  {
    tag1: req.body.tag1,
    tag2: req.body.tag2,
    tag3: req.body.tag3
  };

  await recording.save;
  res.json(recording);
  }catch(err){
    console.error(err.message);
    res.status(500).send("Server error");
  }
});

// Obtaining the list of archieved MP3's

router.get('/', async (req, res) => {
  try{
    recordings = await Recording.find({private: false}).sort({start: -1});
    res.json(recordings);
  }
  catch(err){
    console.error(err.message);
    res.status(500).send("Server error");
  }
});

// Filter by title

router.get('/title', async (req, res) => {
  try{
    recordings = await Recording.find({private: false, title: req.body.title}).sort({start: -1});
    if(!recordings)
      res.json("No title matches what you have searched.");
    res.json(recordings);
  }
  catch(err){
    console.error(err.message);
    res.status(500).send("Server error");
  }
});

// Filter by Tags

/*
router.get('/tags', async (req, res) => {
  try{
    recordings = await Recording.find({private: false, title: req.body.title}).sort({start: -1});
    res.json(recordings);
  }
  catch(err){
    console.error(err.message);
    res.status(500).send("Server error");
  }
});
*/

//view a specific recordings information

router.get('/:id', async (req, res) => {
  try{
    const recordings = await Recording.find({id: req.params.id, private: false}).sort({start: -1});
    if(!recording)
      return res.status(404).json({ msg: "recording not found"});
    res.json(recordings);
  }

  catch(err){
    console.error(err.message);
    res.status(500).send("Server error");
  }
});

// Obtain a list of a users Recordings

router.get('/user/:id', async (req, res) => {
  try{
    const recording = await Recording.find({user: req.params.id, private: false}).sort({start: -1});
    res.json(recording);
  }

  catch(err){
    console.error(err.message);
    res.status(500).send("Server error");
  }
});

//Obtain a list of your own recordings

router.get('/userRecordings', auth, async (req, res) => {
  try{
    const compare = await User.findById(req.user.id).select('-password');
    const recordings = await Recording.find({user: compare.id}).sort({start: -1});
    res.json(recordings);
  }

  catch(err){
    console.error(err.message);
    res.status(500).send("Server error");
  }
});

module.exports = router;
