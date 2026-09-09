const express = require('express');
const authMiddleware = require('../middleware/authMiddleware');

const {
    createNotification,
    getUserNotifications,
    markNotificationRead,
    markAllNotificationsRead
} = require('../controllers/notificationController');

const router = express.Router();

router.get(
    '/user/:userId',
    authMiddleware,
    getUserNotifications
);

router.post(
    '/',
    authMiddleware,
    createNotification
);

router.patch(
    '/:id/read/:userId',
    authMiddleware,
    markNotificationRead
);

router.patch(
    '/user/:userId/read-all',
    authMiddleware,
    markAllNotificationsRead
);

module.exports = router;