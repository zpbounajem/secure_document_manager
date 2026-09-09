const pool = require('../config/db');

const createFile = async ({
    folderId,
    ownerId,
    originalName,
    storedName,
    mimeType,
    fileSize,
    s3Bucket,
    s3Key,
    checksum
}) => {
    const [result] = await pool.query(
        'CALL sp_create_file(?, ?, ?, ?, ?, ?, ?, ?, ?)',
        [
            folderId,
            ownerId,
            originalName,
            storedName,
            mimeType,
            fileSize,
            s3Bucket,
            s3Key,
            checksum
        ]
    );

    return result[0][0];
};

const getFileById = async (fileId) => {
    const [result] = await pool.query(
        'CALL sp_get_file_by_id(?)',
        [fileId]
    );

    return result[0][0] || null;
};

const getFolderFiles = async (folderId) => {
    const [result] = await pool.query(
        'CALL sp_get_folder_files(?)',
        [folderId]
    );

    return result[0];
};

const updateFile = async (
    fileId,
    originalName,
    folderId,
    status
) => {
    const [result] = await pool.query(
        'CALL sp_update_file(?, ?, ?, ?)',
        [
            fileId,
            originalName,
            folderId,
            status
        ]
    );

    return result[0][0] || null;
};

const deleteFile = async (fileId) => {
    const [result] = await pool.query(
        'CALL sp_delete_file(?)',
        [fileId]
    );

    return result[0][0] || null;
};

module.exports = {
    createFile,
    getFileById,
    getFolderFiles,
    updateFile,
    deleteFile
};