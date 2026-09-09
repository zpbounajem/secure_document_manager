const notificationService = require('../services/notificationService');

const createNotification = async (req, res) => {
    try {
        const {
            userId,
            type,
            title,
            message,
            resourceType,
            resourceId
        } = req.body;

        const notification =
            await notificationService.createNotification({
                userId,
                type,
                title,
                message,
                resourceType,
                resourceId
            });

        return res.status(201).json({
            success: true,
            message: 'Notification created successfully',
            notification
        });

    } catch (error) {
        console.error(
            'Create notification error:',
            error.message
        );

        return res.status(500).json({
            success: false,
            message: 'Failed to create notification'
        });
    }
};

const getUserNotifications = async (req, res) => {
    try {
        const notifications =
            await notificationService.getUserNotifications(
                req.params.userId
            );

        return res.status(200).json({
            success: true,
            notifications
        });

    } catch (error) {
        console.error(
            'Get notifications error:',
            error.message
        );

        return res.status(500).json({
            success: false,
            message: 'Failed to get notifications'
        });
    }
};

const markNotificationRead = async (req, res) => {
    try {
        const result =
            await notificationService.markNotificationRead(
                req.params.id,
                req.params.userId
            );

        return res.status(200).json({
            success: true,
            message: 'Notification marked as read',
            result
        });

    } catch (error) {
        console.error(
            'Mark notification read error:',
            error.message
        );

        return res.status(500).json({
            success: false,
            message: 'Failed to mark notification as read'
        });
    }
};

const markAllNotificationsRead = async (req, res) => {
    try {
        const result =
            await notificationService.markAllNotificationsRead(
                req.params.userId
            );

        return res.status(200).json({
            success: true,
            message: 'All notifications marked as read',
            result
        });

    } catch (error) {
        console.error(
            'Mark all notifications read error:',
            error.message
        );

        return res.status(500).json({
            success: false,
            message: 'Failed to mark notifications as read'
        });
    }
};

module.exports = {
    createNotification,
    getUserNotifications,
    markNotificationRead,
    markAllNotificationsRead
};