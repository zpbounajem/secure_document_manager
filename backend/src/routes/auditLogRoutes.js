const express = require('express');
const authMiddleware = require('../middleware/authMiddleware');

const {
    createAuditLog,
    getUserAuditLogs,
    getAllAuditLogs
} = require('../controllers/auditLogController');

const router = express.Router();

router.get(
    '/',
    authMiddleware,
    getAllAuditLogs
);

router.get(
    '/user/:userId',
    authMiddleware,
    getUserAuditLogs
);

router.post(
    '/',
    authMiddleware,
    createAuditLog
);

module.exports = router;