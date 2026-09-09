const pool = require('../config/db');

const getUserStorageSummary = async (userId) => {
    const [result] = await pool.query(
        'CALL sp_get_user_storage_summary(?)',
        [userId]
    );

    return result[0][0] || null;
};

module.exports = {
    getUserStorageSummary
};