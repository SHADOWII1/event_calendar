const express = require('express');
const router = express.Router();
const { addTraining } = require('../controllers/trainingController');
const { deleteTrainingByCode } = require('../controllers/trainingController');
const { updateTraining } = require('../controllers/trainingController');
const { getTrainings } = require('../controllers/trainingController');

router.post('/add', addTraining);
router.post('/delete-by-code', deleteTrainingByCode);
router.post('/update', updateTraining);
router.get('/get-all-trainings', getTrainings);

module.exports = router;
