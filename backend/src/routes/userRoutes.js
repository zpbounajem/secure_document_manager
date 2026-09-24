const express = require('express');

const authMiddleware = require('../middleware/authMiddleware');

const {
    getCurrentUser,
    getUserById,
    getAllUsers,
    createUser,
    loginUser,
    updateUser,
    updateUserRole,
    updateUserStatus,
    updateLastLogin
} = require('../controllers/userController');

const router = express.Router();


// Get currently authenticated user
router.get(
    '/me',
    authMiddleware,
    getCurrentUser
);


// Login
router.post(
    '/login',
    authMiddleware,
    loginUser
);


// Get all users
router.get(
    '/',
    authMiddleware,
    getAllUsers
);


// Create user
router.post(
    '/',
    authMiddleware,
    createUser
);


// Get user by ID
router.get(
    '/:id',
    authMiddleware,
    getUserById
);


// Update user
router.put(
    '/:id',
    authMiddleware,
    updateUser
);


// Update user role
router.patch(
    '/:id/role',
    authMiddleware,
    updateUserRole
);


// Update user status
router.patch(
    '/:id/status',
    authMiddleware,
    updateUserStatus
);


// Update last login
router.patch(
    '/:id/last-login',
    authMiddleware,
    updateLastLogin
);


module.exports = router;