var audioData = [152,159,141,129,131,147,183,205,212,236,236,235,237,234,248,282,269,237,211,206,209,168,126,140,155,81,45,72,104,59,-1,30,55,47,17,48,91,40,21,45,104,77,27,57,85,58,20,24,43,27,-54,-6,50,26,-7,-22,11,20,-11,34,57,52,52,77,105,106,68,57,40,27,8,14,26,47,31,-1,-2,-25,-32,-51,-7,-2,4,-19,-26,-48,-57,-76,-80,-75,-86,-113,-83,-27,-42,-74,-80,-54,-24,3,31,58,41,22,26,25,24,47,56,75,110,99,74,39,25,14,-18,-28,-5,22,27,22,34,84,69,48,66,94,127,130,151,182,183,148,136,157,155,146,124,151,139,109,59,23,26,-9,-24,-29,-12,0,14,29,21,51,77]

const wavefile = require('wavefile').WaveFile;
const Lame = require("node-lame").Lame;
const stream = require('stream')
const FormData = require('@postman/form-data');

// First, create a WAV file buffer from the raw audio data.
// This encodes the number of channels, sample rate, and
// bit depth into the raw data which the MP3 conversion needs
var wav = new wavefile();
wav.fromScratch(1, 44100, '16', audioData);

// Save the WAV file buffer as a raw data buffer
var audioFileBuffer = Buffer.from(wav.toBuffer())
console.log(audioFileBuffer)

console.log(Buffer.isBuffer(audioFileBuffer))

// Create an MP3 encoder with data buffer input and output
const encoder = new Lame({
    "output": "buffer",
    "bitrate": 96
}).setBuffer(audioFileBuffer);

// Start encoding
encoder.encode()
    .then(() => {
        // Encoding finished
        var buffer = encoder.getBuffer();
        // Convert the MP3 data buffer into a readable stream
        var mp3FileStream = new stream.Readable()
        mp3FileStream._read = () => {}
        mp3FileStream.push(buffer)
        mp3FileStream.push(null)

        console.log(mp3FileStream)

        // Send the MP3 file to the database
        var formData = new FormData()
        formData.append('file', mp3FileStream);

        console.log(formData)
    })
    .catch((error) => {
        console.log('Error encoding MP3 file! ' + error)
    });