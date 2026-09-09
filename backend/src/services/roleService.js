const pool = require('../config/db');

const createRole = async (name, description) => {
    const [result] = await pool.query(
        'CALL sp_create_role(?, ?)',
        [name, description]
    );

    return result[0][0];
};

const updateRole = async (roleId, name, description) => {
    const [result] = await pool.query(
        'CALL sp_update_role(?, ?, ?)',
        [roleId, name, description]
    );

    return result[0][0] || null;
};

const deleteRole = async (roleId) => {
    const [result] = await pool.query(
        'CALL sp_delete_role(?)',
        [roleId]
    );

    return result[0][0] || null;
};

const getAllRoles = async () => {
    const [result] = await pool.query(
        'CALL sp_get_all_roles()'
    );

    return result[0];
};

module.exports = {
    createRole,
    updateRole,
    deleteRole,
    getAllRoles
};