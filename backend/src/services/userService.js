const pool = require('../config/db');

const createUser = async ({
    firebaseUid,
    email,
    firstName,
    lastName,
    displayName,
    profileImage,
    roleId
}) => {
    const [result] = await pool.query(
        'CALL sp_create_user(?, ?, ?, ?, ?, ?, ?)',
        [
            firebaseUid,
            email,
            firstName,
            lastName,
            displayName,
            profileImage,
            roleId
        ]
    );

    return result[0][0] || null;
};

const getUserById = async (userId) => {
    const [result] = await pool.query(
        'CALL sp_get_user_by_id(?)',
        [userId]
    );

    return result[0][0] || null;
};

const getUserByFirebaseUid = async (firebaseUid) => {
    const [result] = await pool.query(
        'CALL sp_get_user_by_firebase_uid(?)',
        [firebaseUid]
    );

    return result[0][0] || null;
};

const getAllUsers = async () => {
    const [result] = await pool.query(
        'CALL sp_get_all_users()'
    );

    return result[0];
};

const updateUser = async ({
    userId,
    email,
    firstName,
    lastName,
    displayName,
    profileImage
}) => {
    const [result] = await pool.query(
        'CALL sp_update_user(?, ?, ?, ?, ?, ?)',
        [
            userId,
            email,
            firstName,
            lastName,
            displayName,
            profileImage
        ]
    );

    return result[0][0] || null;
};

const updateUserRole = async (userId, roleId) => {
    const [result] = await pool.query(
        'CALL sp_update_user_role(?, ?)',
        [userId, roleId]
    );

    return result[0][0] || null;
};

const updateUserStatus = async (userId, status) => {
    const [result] = await pool.query(
        'CALL sp_update_user_status(?, ?)',
        [userId, status]
    );

    return result[0][0] || null;
};

const updateLastLogin = async (userId) => {
    const [result] = await pool.query(
        'CALL sp_update_last_login(?)',
        [userId]
    );

    return result[0][0] || null;
};

module.exports = {
    createUser,
    getUserById,
    getUserByFirebaseUid,
    getAllUsers,
    updateUser,
    updateUserRole,
    updateUserStatus,
    updateLastLogin
};