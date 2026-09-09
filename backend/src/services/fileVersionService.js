const pool = require('../config/db');

const createFileVersion = async ({
    fileId,
    s3Key,
    fileSize,
    checksum,
    uploadedBy
}) => {
    const [result] = await pool.query(
        'CALL sp_create_file_version(?, ?, ?, ?, ?)',
        [
            fileId,
            s3Key,
            fileSize,
            checksum,
            uploadedBy
        ]
    );

    return result[0][0];
};

const getFileVersions = async (fileId) => {
    const [result] = await pool.query(
        'CALL sp_get_file_versions(?)',
        [fileId]
    );

    return result[0];
};

module.exports = {
    createFileVersion,
    getFileVersions
};