const express = require('express');
const authMiddleware = require('../middleware/authMiddleware');

const {
    createFolder,
    getFolderById,
    getRootFolders,
    getSubfolders,
    updateFolder,
    deleteFolder
} = require('../controllers/folderController');

const router = express.Router();

router.get('/root', authMiddleware, getRootFolders);

router.get('/:id', authMiddleware, getFolderById);

router.get(
    '/:parentId/subfolders',
    authMiddleware,
    getSubfolders
);

router.post('/', authMiddleware, createFolder);

router.put('/:id', authMiddleware, updateFolder);

router.delete('/:id', authMiddleware, deleteFolder);

module.exports = router;