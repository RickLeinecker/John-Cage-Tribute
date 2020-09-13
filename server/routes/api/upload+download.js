// This file exists to uncomplicate things
const express = require('express');
const mongoose = require('mongoose');
const multer = require('multer');
const config = require('config');
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const auth = require('../../middleware/auth.js');

const Grid = require('gridfs-stream');
const GridFsStorage = require('multer-gridfs-storage');
const Recording = require('../../models/Recording');
const User = require('../../models/User');


const conn = mongoose.connection;

// Uploading the MP3 File
module.exports = router => {

  let gfs;

  conn.once('open', () => {
    // Init stream
    gfs = new mongoose.mongo.GridFSBucket(conn.db, {
      bucketName: 'uploads'
    });
  });

  const storage = new GridFsStorage({
    url: config.get('mongoURI'),
    file: (req, file) => {
      return new Promise((resolve, reject) => {
        crypto.randomBytes(16, (err, buf) => {
          if (err) {
            return reject(err);
          }
          // Randomize the filename
          const filename = buf.toString('hex') + path.extname(file.originalname);
          // Add file to the bucket
          const fileInfo = {
            filename: filename,
            bucketName: 'uploads'
          };
          resolve(fileInfo);
        });
      });
    }
  });

  const upload = multer({ storage });

  router.post('/', upload.single('file'), async(req, res) => {
    try{
      //const appointment = await Appointment.findById(req.body.appointment);
      const file = req.file;
      const user = await User.findById(req.body.user).select('-password');
      recording = new Recording({
        user: req.body.user,
        //date: appointment.end,
        composer: user.name,
        //title: appointment.title,
        time: req.body.time,
        //Rid: file.id,
        length: file.size,
        filename: file.filename,
        type: file.contentType
      });

      await recording.save();
      res.json(recording);

    }catch (err) {
        console.error(err.message);
        res.status(500).send("Server error");
    }
  });

  // View recordings from database

  router.get('/view/:filename', (req, res) => {
    const file = gfs
      .find({
        filename: req.params.filename
      })
      .toArray((err, files) => {
        if (!files || files.length === 0) {
          return res.status(404).json({
            err: "no files exist"
          });
        }
        gfs.openDownloadStreamByName(req.params.filename).pipe(res);
    });
  });
}
