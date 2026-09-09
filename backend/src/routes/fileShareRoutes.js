const express = require('express');
const authMiddleware = require('../middleware/authMiddleware');

const {
    createFileVersion,
    getFileVersions
} = require('../controllers/fileVersionController');

const router = express.Router();

router.post('/', authMiddleware, createFileVersion);

router.get(
    '/file/:fileId',
    authMiddleware,
    getFileVersions
);

module.exports = router;