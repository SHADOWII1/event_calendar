const { DataTypes } = require('sequelize');
const sequelize = require('../config/seq_db');

const Training = sequelize.define('Training', {
  id_training: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true,
      },
      title: {
        type: DataTypes.STRING,
        allowNull: false,
      },
      code: {
        type: DataTypes.STRING,
        allowNull: false,
        unique: true,  // Ensuring the code is unique
      },
      description: {
        type: DataTypes.TEXT,
      },
      start_date: {
        type: DataTypes.DATE,
      },
      end_date: {
        type: DataTypes.DATE,
      },
      start_time: {
        type: DataTypes.TIME,
      },
      end_time: {
        type: DataTypes.TIME,
      },
      max_enrolled_students: {
        type: DataTypes.INTEGER,
        allowNull: false,
      },
      min_enrolled_students: {
        type: DataTypes.INTEGER,
        allowNull: false,
      },
}, {
  tableName: 'trainings', // Optional: explicit table name if different from 'Users'
  timestamps: false,
});

module.exports = Training;
