const express = require('express');
const authMiddleware = require('../middleware/authMiddleware');

const {
    shareFolder,
    removeFolderShare,
    getFolderShares,
    getSharedFoldersForUser
} = require('../controllers/folderShareController');

const router = express.Router();

router.get(
    '/user/:userId',
    authMiddleware,
    getSharedFoldersForUser
);

router.get(
    '/folder/:folderId',
    authMiddleware,
    getFolderShares
);

router.post(
    '/folder/:folderId',
    authMiddleware,
    shareFolder
);

router.delete(
    '/folder/:folderId/user/:userId',
    authMiddleware,
    removeFolderShare
);

module.exports = router;