const pool = require('../config/db');

const createSharePermission = async (name, description) => {
    const [result] = await pool.query(
        'CALL sp_create_share_permission(?, ?)',
        [name, description]
    );

    return result[0][0];
};

const getSharePermissions = async () => {
    const [result] = await pool.query(
        'CALL sp_get_share_permissions()'
    );

    return result[0];
};

module.exports = {
    createSharePermission,
    getSharePermissions
};