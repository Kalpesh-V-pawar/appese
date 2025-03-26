const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const bodyParser = require('body-parser');

// Create Express app
const app = express();

// Middleware
app.use(cors());
app.use(bodyParser.json());

// MongoDB Connection (using environment variable)
mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/flutterdb', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
})
.then(() => console.log('MongoDB connected successfully'))
.catch(err => console.error('MongoDB connection error:', err));

// Create a Schema for Entries
const EntrySchema = new mongoose.Schema({
  text: {
    type: String,
    required: true,
    trim: true
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

// Create a Model
const Entry = mongoose.model('Entry', EntrySchema);

// Root endpoint
app.get('/', (req, res) => {
  res.json({ message: 'Welcome to the Flutter MongoDB Backend' });
});

// API Route to add a new entry
app.post('/api/add-entry', async (req, res) => {
  try {
    // Extract text from request body
    const { text } = req.body;

    // Validate input
    if (!text || text.trim() === '') {
      return res.status(400).json({ 
        message: 'Text cannot be empty' 
      });
    }

    // Create new entry
    const newEntry = new Entry({
      text: text.trim()
    });

    // Save entry to database
    const savedEntry = await newEntry.save();

    // Respond with success message
    res.status(200).json({
      message: 'Entry saved successfully',
      entry: savedEntry
    });
  } catch (error) {
    console.error('Error saving entry:', error);
    res.status(500).json({ 
      message: 'Error saving entry', 
      error: error.message 
    });
  }
});

// API Route to fetch all entries
app.get('/api/entries', async (req, res) => {
  try {
    const entries = await Entry.find().sort({ createdAt: -1 });
    res.status(200).json(entries);
  } catch (error) {
    console.error('Error fetching entries:', error);
    res.status(500).json({ 
      message: 'Error fetching entries', 
      error: error.message 
    });
  }
});

// Export the app for Vercel
module.exports = app;