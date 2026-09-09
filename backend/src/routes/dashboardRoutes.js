const express = require('express');
const authMiddleware = require('../middleware/authMiddleware');

const {
    getUserStorageSummary
} = require('../controllers/dashboardController');

const router = express.Router();

router.get(
    '/storage/:userId',
    authMiddleware,
    getUserStorageSummary
);

module.exports = router;