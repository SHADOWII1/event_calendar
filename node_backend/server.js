const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const db = require('./config/db');
const trainingRoutes = require('./routes/training');
const userRoutes = require('./routes/user');
const authRoutes = require('./routes/auth');
const subscriptionRoutes = require('./routes/subscription');
const sequelize = require('./config/seq_db');
const User = require('./models/userModel');
const bcryptjs = require('bcryptjs');

const app = express();

// Middleware
app.use(cors());
app.use(bodyParser.json());

app.use(express.json());

// Routes
app.use('/api/training', trainingRoutes);
app.use('/api/user', userRoutes);
app.use('/api/auth', authRoutes);
app.use('/api/subscription', subscriptionRoutes);


// Start Server
const PORT = 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));

async function startApp() {
  try {
      // User data
      const userData = {
        first_name: 'Student',
        last_name: 'Student',
        email: 'student@example.com',
        password: 'securepassword123',
        matriculation_number: 'STU0001',
        role:'Student',
      };

      // Hash the password
      const salt = await bcryptjs.genSalt(10);
      const hashedPassword = await bcryptjs.hash(userData.password, salt);

      // Create user in the database
      const newUser = await User.create({
        first_name: userData.first_name,
        last_name: userData.last_name,
        email: userData.email,
        password: hashedPassword,
        matriculation_number: userData.matriculation_number,
        role: userData.role,
      });

      console.log('User created successfully:', newUser.toJSON());
    } catch (error) {
      console.error('Error creating user:', error.message);
    }
}
