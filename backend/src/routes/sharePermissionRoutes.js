const express = require('express');
const authMiddleware = require('../middleware/authMiddleware');

const {
    createSharePermission,
    getSharePermissions
} = require('../controllers/sharePermissionController');

const router = express.Router();

router.get(
    '/',
    authMiddleware,
    getSharePermissions
);

router.post(
    '/',
    authMiddleware,
    createSharePermission
);

module.exports = router;