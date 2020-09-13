const express = require('express');
const connectDB = require('./config/db');
const path = require('path');
const app = express();
//const multer = require('multer');

// Connect Database
connectDB();
// Initialize Middleware
app.use(express.json());
// The line of code should get commented out when deploying, bring it back if testing on local machine server.
//app.get('/', (req, res) => res.send('API Running...'));
// Define Routes
app.use('/api/users', require('./routes/api/users'));
app.use('/api/auth', require('./routes/api/auth'));
//app.use('/api/recordings', require('./routes/api/recordings'));
//app.use('/api/upload+download', require('./routes/api/upload+download'));
//app.use('/sockets/room', require('./routes/sockets/room'));
app.use('/api/profile', require('./routes/api/profile'));
app.use('/api/posts', require('./routes/api/posts'));
// Serve static assets in production
//if (process.env.NODE_ENV === 'production') {
  // Set static folder
  app.use(express.static('client/build'));
  app.get('*', (req, res) => {
    res.sendFile(path.resolve(__dirname, 'client', 'build', 'index.html'));
  });
//}
const PORT = process.env.PORT || 8080;
app.listen(PORT, () => console.log(`Server Started on port ${PORT}`));
