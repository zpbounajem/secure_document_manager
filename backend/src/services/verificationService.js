const pool = require('../config/db');

const generateVerificationCode = () => {
    return Math.floor(
        100000 + Math.random() * 900000
    ).toString();
};

const setVerificationCode = async ({
    userId,
    verificationCode,
    expiresAt
}) => {
    await pool.query(
        'CALL sp_set_verification_code(?, ?, ?)',
        [
            userId,
            verificationCode,
            expiresAt
        ]
    );
};

const getVerificationCode = async (email) => {
    const normalizedEmail = email.trim().toLowerCase();

    const [result] = await pool.query(
        'CALL sp_get_verification_code(?)',
        [normalizedEmail]
    );

    return result[0][0] || null;
};

const getUserByEmail = async (email) => {
    const normalizedEmail = email.trim().toLowerCase();

    const [rows] = await pool.query(
        `
        SELECT
            id,
            firebase_uid,
            email,
            first_name,
            last_name,
            display_name,
            profile_image,
            role_id,
            status,
            email_verified
        FROM users
        WHERE LOWER(TRIM(email)) = ?
        LIMIT 1
        `,
        [normalizedEmail]
    );

    return rows[0] || null;
};

const verifyEmailCode = async ({
    email,
    verificationCode
}) => {
    const normalizedEmail = email.trim().toLowerCase();

    const [result] = await pool.query(
        'CALL sp_verify_email_code(?, ?)',
        [
            normalizedEmail,
            verificationCode
        ]
    );

    return result[0][0] || null;
};

const clearVerificationCode = async (userId) => {
    await pool.query(
        'CALL sp_clear_verification_code(?)',
        [userId]
    );
};

const createAndStoreVerificationCode = async (userId) => {
    const verificationCode = generateVerificationCode();

    const expiresAt = new Date(
        Date.now() + 5 * 60 * 1000
    );

    await setVerificationCode({
        userId,
        verificationCode,
        expiresAt
    });

    return {
        verificationCode,
        expiresAt
    };
};

module.exports = {
    generateVerificationCode,
    setVerificationCode,
    getVerificationCode,
    getUserByEmail,
    verifyEmailCode,
    clearVerificationCode,
    createAndStoreVerificationCode
};