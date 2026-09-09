const pool = require('../config/db');

const shareFolder = async ({
    folderId,
    userId,
    permissionId,
    sharedBy,
    expiresAt
}) => {
    const [result] = await pool.query(
        'CALL sp_share_folder(?, ?, ?, ?, ?)',
        [
            folderId,
            userId,
            permissionId,
            sharedBy,
            expiresAt
        ]
    );

    return result[0][0] || null;
};

const removeFolderShare = async (folderId, userId) => {
    const [result] = await pool.query(
        'CALL sp_remove_folder_share(?, ?)',
        [folderId, userId]
    );

    return result[0][0] || null;
};

const getFolderShares = async (folderId) => {
    const [result] = await pool.query(
        'CALL sp_get_folder_shares(?)',
        [folderId]
    );

    return result[0];
};

const getSharedFoldersForUser = async (userId) => {
    const [result] = await pool.query(
        'CALL sp_get_shared_folders_for_user(?)',
        [userId]
    );

    return result[0];
};

module.exports = {
    shareFolder,
    removeFolderShare,
    getFolderShares,
    getSharedFoldersForUser
};