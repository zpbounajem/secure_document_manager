const pool = require('../config/db');

const createAuditLog = async ({
    userId,
    action,
    resourceType,
    resourceId,
    description,
    ipAddress,
    userAgent
}) => {
    const [result] = await pool.query(
        'CALL sp_create_audit_log(?, ?, ?, ?, ?, ?, ?)',
        [
            userId,
            action,
            resourceType,
            resourceId,
            description,
            ipAddress,
            userAgent
        ]
    );

    return result[0][0];
};

const getUserAuditLogs = async (userId) => {
    const [result] = await pool.query(
        'CALL sp_get_user_audit_logs(?)',
        [userId]
    );

    return result[0];
};

const getAllAuditLogs = async () => {
    const [result] = await pool.query(
        'CALL sp_get_all_audit_logs()'
    );

    return result[0];
};

module.exports = {
    createAuditLog,
    getUserAuditLogs,
    getAllAuditLogs
};