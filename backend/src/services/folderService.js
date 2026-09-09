const pool = require('../config/db');

const createFolder = async (name, parentId, ownerId) => {
    const [result] = await pool.query(
        'CALL sp_create_folder(?, ?, ?)',
        [name, parentId, ownerId]
    );

    return result[0][0];
};

const getFolderById = async (folderId) => {
    const [result] = await pool.query(
        'CALL sp_get_folder_by_id(?)',
        [folderId]
    );

    return result[0][0] || null;
};

const getRootFolders = async (ownerId) => {
    const [result] = await pool.query(
        'CALL sp_get_root_folders(?)',
        [ownerId]
    );

    return result[0];
};

const getSubfolders = async (parentId) => {
    const [result] = await pool.query(
        'CALL sp_get_subfolders(?)',
        [parentId]
    );

    return result[0];
};

const updateFolder = async (folderId, name, parentId) => {
    const [result] = await pool.query(
        'CALL sp_update_folder(?, ?, ?)',
        [folderId, name, parentId]
    );

    return result[0][0] || null;
};

const deleteFolder = async (folderId) => {
    const [result] = await pool.query(
        'CALL sp_delete_folder(?)',
        [folderId]
    );

    return result[0][0] || null;
};

module.exports = {
    createFolder,
    getFolderById,
    getRootFolders,
    getSubfolders,
    updateFolder,
    deleteFolder
};