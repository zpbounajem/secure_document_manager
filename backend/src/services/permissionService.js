const pool = require('../config/db');


// Create a new permission
const createPermission = async (name, description) => {
    const [result] = await pool.query(
        'CALL sp_create_permission(?, ?)',
        [name, description]
    );

    return result[0][0];
};


// Get all permissions
const getAllPermissions = async () => {
    const [result] = await pool.query(
        'CALL sp_get_all_permissions()'
    );

    return result[0];
};


// Assign permission to role
const assignPermissionToRole = async (roleId, permissionId) => {
    const [result] = await pool.query(
        'CALL sp_assign_permission_to_role(?, ?)',
        [roleId, permissionId]
    );

    return result[0][0] || null;
};


// Remove permission from role
const removePermissionFromRole = async (roleId, permissionId) => {
    const [result] = await pool.query(
        'CALL sp_remove_permission_from_role(?, ?)',
        [roleId, permissionId]
    );

    return result[0][0] || null;
};


// Get permissions assigned to a role
const getRolePermissions = async (roleId) => {
    const [result] = await pool.query(
        'CALL sp_get_role_permissions(?)',
        [roleId]
    );

    return result[0];
};


module.exports = {
    createPermission,
    getAllPermissions,
    assignPermissionToRole,
    removePermissionFromRole,
    getRolePermissions
};