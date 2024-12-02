const { Sequelize } = require('sequelize');

// Create a Sequelize instance connected to your MariaDB database
const sequelize = new Sequelize('academic_calendar', 'root', 'root', {
  host: 'localhost',
  dialect: 'mysql',
});

// Test the connection
sequelize
  .authenticate()
  .then(() => console.log('Connection established successfully.'))
  .catch((err) => console.error('Unable to connect to the database:', err));

module.exports = sequelize;
