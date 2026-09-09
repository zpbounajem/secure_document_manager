const express = require('express');
const authMiddleware = require('../middleware/authMiddleware');

const {
    createFile,
    getFileById,
    getFolderFiles,
    updateFile,
    deleteFile
} = require('../controllers/fileController');

const router = express.Router();

router.post('/', authMiddleware, createFile);

router.get(
    '/folder/:folderId',
    authMiddleware,
    getFolderFiles
);

router.get('/:id', authMiddleware, getFileById);

router.put('/:id', authMiddleware, updateFile);

router.delete('/:id', authMiddleware, deleteFile);

module.exports = router;