const { DataTypes } = require('sequelize');
const sequelize = require('../config/seq_db');

const Subscription = sequelize.define('Subscription', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },
  matriculation_number: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  training_code: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  subscription_date: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW,
  },
  status: {
    type: DataTypes.STRING,
    defaultValue: 'Confirmed',
  },
}, {
  tableName: 'subscriptions',
  timestamps: false,
});

module.exports = Subscription;
