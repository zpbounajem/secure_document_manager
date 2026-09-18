const express = require('express');

const authMiddleware = require('../middleware/authMiddleware');

const {
    createFileVersion,
    getFileVersions
} = require('../controllers/fileVersionController');

const router = express.Router();

// Create a new file version
router.post(
    '/',
    authMiddleware,
    createFileVersion
);

// Get all versions of a file
router.get(
    '/file/:fileId',
    authMiddleware,
    getFileVersions
);

module.exports = router;