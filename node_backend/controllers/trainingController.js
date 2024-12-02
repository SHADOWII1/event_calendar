const db = require('../config/db');
const moment = require('moment-timezone');


exports.addTraining = (req, res) => {
    const { title, code, description, start_date, end_date, start_time, end_time, max_enrolled_students, min_enrolled_students } = req.body;

      const query = `
        INSERT INTO trainings (title, code, description, start_date, end_date, start_time, end_time, max_enrolled_students, min_enrolled_students)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
      `;
    db.query(query, [title, code, description, start_date, end_date, start_time, end_time, max_enrolled_students, min_enrolled_students], (err, result) => {
        if (err) {
            return res.status(500).json({ error: err.message });
        }
        res.status(200).json({ message: 'Training added successfully', trainingId: result.insertId });
    });
};

exports.deleteTrainingByCode = (req, res) => {
    const { code } = req.body; // Expect `code` to be provided in the request body

    const query = `
        DELETE FROM trainings WHERE code = ?
    `;
    db.query(query, [code], (err, result) => {
        if (err) {
            return res.status(500).json({ error: err.message });
        }
        if (result.affectedRows === 0) {
            return res.status(404).json({ message: 'Training not found with the provided code' });
        }
        res.status(200).json({ message: 'Training deleted successfully' });
    });
};

exports.updateTraining = (req, res) => {
    const { title, code, description, start_date, end_date, start_time, end_time, max_enrolled_students, min_enrolled_students } = req.body;

    const query = `
        UPDATE trainings
        SET
            title = ?,
            description = ?,
            start_date = ?,
            end_date = ?,
            start_time = ?,
            end_time = ?,
            max_enrolled_students = ?,
            min_enrolled_students = ?
        WHERE code = ?
    `;

    db.query(
        query,
        [title, description, start_date, end_date, start_time, end_time, max_enrolled_students, min_enrolled_students, code],
        (err, result) => {
            if (err) {
                return res.status(500).json({ error: err.message });
            }
            if (result.affectedRows === 0) {
                return res.status(404).json({ message: 'Training not found' });
            }
            res.status(200).json({ message: 'Training updated successfully' });
        }
    );
};

exports.getTrainings = (req, res) => {
    const query = `
        SELECT
            id_training,
            title,
            code,
            description,
            start_date,
            end_date,
            start_time,
            end_time,
            max_enrolled_students,
            min_enrolled_students
        FROM trainings
    `;

    db.query(query, (err, results) => {
        if (err) {
            return res.status(500).json({ error: err.message });
        }

        // Convert to a specific time zone (e.g., 'Europe/Berlin')
        results.forEach(training => {
            training.start_date = moment(training.start_date).tz('Europe/Berlin').format('YYYY-MM-DD HH:mm:ss');
            training.end_date = moment(training.end_date).tz('Europe/Berlin').format('YYYY-MM-DD HH:mm:ss');
        });

        res.status(200).json(results);
    });
};
