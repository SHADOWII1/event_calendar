const { DataTypes } = require('sequelize');
const sequelize = require('../config/seq_db'); // Import the initialized Sequelize instance

const User = sequelize.define('User', {
  id_user: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
    allowNull: false,
  },
  first_name: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  last_name: { // Additional column
    type: DataTypes.STRING,
    allowNull: false,
  },
  email: {
    type: DataTypes.STRING,
    allowNull: false,
    unique: true,
  },
  password: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  created_at: { // Timestamp column
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW,
  },
  role: { // Timestamp column
    type: DataTypes.STRING,
    allowNull: false,
  },
  matriculation_number: { // Timestamp column
      type: DataTypes.STRING,
      allowNull: false,
    },
}, {
  tableName: 'users', // Optional: explicit table name if different from 'Users'
  timestamps: false, // Disable Sequelize's automatic timestamps if not needed
});

module.exports = User;
