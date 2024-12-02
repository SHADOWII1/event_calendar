const db = require('../config/db');
const moment = require('moment-timezone');

exports.addUser = (req, res) => {
    const { first_name, last_name, email, password, role, created_at, matriculation_number } = req.body;

    // SQL query to insert the new user into the database
    const query = `
        INSERT INTO users (first_name, last_name, email, password, role, created_at, matriculation_number)
        VALUES (?, ?, ?, ?, ?, ?, ?)
    `;

    // Hash the password before saving it to the database
    const bcrypt = require('bcrypt');
    const saltRounds = 10;

    bcrypt.hash(password, saltRounds, (err, hashedPassword) => {
        if (err) {
            return res.status(500).json({ error: 'Error hashing password' });
        }

        // Execute the query with the hashed password
        db.query(query, [first_name, last_name, email, hashedPassword, role, created_at, matriculation_number], (err, result) => {
            if (err) {
                return res.status(500).json({ error: err.message });
            }
            res.status(200).json({ message: 'User added successfully', userId: result.insertId });
        });
    });
};


exports.getUsers = (req, res) => {
    const query = `SELECT * FROM users`;
    db.query(query, (err, results) => {
        if (err) {
            return res.status(500).json({ error: err.message });
        }
        results.forEach(user => {
                    user.created_at = moment(user.created_at).tz('Europe/Berlin').format('YYYY-MM-DD HH:mm:ss');
                });
        res.status(200).json(results);
    });
};

exports.deleteUserByMatriculationNumber = (req, res) => {
    const { matriculation_number } = req.body; // Expect `matriculation_number` to be provided in the request body

    const query = `
        DELETE FROM users WHERE matriculation_number = ?
    `;

    db.query(query, [matriculation_number], (err, result) => {
        if (err) {
            return res.status(500).json({ error: err.message });
        }
        if (result.affectedRows === 0) {
            return res.status(404).json({ message: 'User not found with the provided matriculation number' });
        }
        res.status(200).json({ message: 'User deleted successfully' });
    });
};


exports.updateUser = (req, res) => {
    const { matriculation_number, first_name, last_name, email, role, password } = req.body;

    // Query to update user details, excluding password if it's not provided
    const query = `
        UPDATE users
        SET
            first_name = ?,
            last_name = ?,
            email = ?,
            role = ?
            ${password ? ',password = ?' : ''}
        WHERE matriculation_number = ?
    `;

    // Prepare the values for the query
    const values = password ? [first_name, last_name, email, role, password, matriculation_number] :
                              [first_name, last_name, email, role, matriculation_number];

    // Execute the query
    db.query(query, values, (err, result) => {
        if (err) {
            return res.status(500).json({ error: err.message });
        }
        if (result.affectedRows === 0) {
            return res.status(404).json({ message: 'User not found with the provided matriculation number' });
        }
        res.status(200).json({ message: 'User updated successfully' });
    });
};

