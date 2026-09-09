const pool = require('../config/db');

const createNotification = async ({
    userId,
    type,
    title,
    message,
    resourceType,
    resourceId
}) => {
    const [result] = await pool.query(
        'CALL sp_create_notification(?, ?, ?, ?, ?, ?)',
        [
            userId,
            type,
            title,
            message,
            resourceType,
            resourceId
        ]
    );

    return result[0][0];
};

const getUserNotifications = async (userId) => {
    const [result] = await pool.query(
        'CALL sp_get_user_notifications(?)',
        [userId]
    );

    return result[0];
};

const markNotificationRead = async (
    notificationId,
    userId
) => {
    const [result] = await pool.query(
        'CALL sp_mark_notification_read(?, ?)',
        [
            notificationId,
            userId
        ]
    );

    return result[0][0] || null;
};

const markAllNotificationsRead = async (userId) => {
    const [result] = await pool.query(
        'CALL sp_mark_all_notifications_read(?)',
        [userId]
    );

    return result[0][0] || null;
};

module.exports = {
    createNotification,
    getUserNotifications,
    markNotificationRead,
    markAllNotificationsRead
};