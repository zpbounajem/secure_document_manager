const pool = require('../config/db');

const shareFile = async ({
    fileId,
    userId,
    permissionId,
    sharedBy,
    expiresAt
}) => {
    const [result] = await pool.query(
        'CALL sp_share_file(?, ?, ?, ?, ?)',
        [
            fileId,
            userId,
            permissionId,
            sharedBy,
            expiresAt
        ]
    );

    return result[0][0] || null;
};

const removeFileShare = async (fileId, userId) => {
    const [result] = await pool.query(
        'CALL sp_remove_file_share(?, ?)',
        [fileId, userId]
    );

    return result[0][0] || null;
};

const getFileShares = async (fileId) => {
    const [result] = await pool.query(
        'CALL sp_get_file_shares(?)',
        [fileId]
    );

    return result[0];
};

const getSharedFilesForUser = async (userId) => {
    const [result] = await pool.query(
        'CALL sp_get_shared_files_for_user(?)',
        [userId]
    );

    return result[0];
};

module.exports = {
    shareFile,
    removeFileShare,
    getFileShares,
    getSharedFilesForUser
};