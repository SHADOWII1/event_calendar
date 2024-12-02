const express = require('express');
const router = express.Router();
const { addUser } = require('../controllers/userController');
const { getUsers } = require('../controllers/userController');
const { deleteUserByMatriculationNumber } = require('../controllers/userController');
const { updateUser } = require('../controllers/userController');

router.post('/add', addUser);
router.get('/get-all-users', getUsers);
router.post('/delete-by-matriculation-number', deleteUserByMatriculationNumber);
router.post('/update', updateUser);


module.exports = router;