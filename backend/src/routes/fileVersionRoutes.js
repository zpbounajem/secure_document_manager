const express = require('express');
const authMiddleware = require('../middleware/authMiddleware');

const {
    shareFile,
    removeFileShare,
    getFileShares,
    getSharedFilesForUser
} = require('../controllers/fileShareController');

const router = express.Router();

router.get(
    '/user/:userId',
    authMiddleware,
    getSharedFilesForUser
);

router.get(
    '/file/:fileId',
    authMiddleware,
    getFileShares
);

router.post(
    '/file/:fileId',
    authMiddleware,
    shareFile
);

router.delete(
    '/file/:fileId/user/:userId',
    authMiddleware,
    removeFileShare
);

module.exports = router;