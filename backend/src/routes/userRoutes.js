const express = require('express');

const authMiddleware = require('../middleware/authMiddleware');

const {
    getCurrentUser,
    getUserById,
    getAllUsers,
    createUser,
    updateUser,
    updateUserRole,
    updateUserStatus,
    updateLastLogin
} = require('../controllers/userController');

const router = express.Router();


// Get currently authenticated user
router.get('/me', authMiddleware, getCurrentUser);


// Get all users
router.get('/', authMiddleware, getAllUsers);


// Get user by ID
router.get('/:id', authMiddleware, getUserById);


// Create user
router.post('/', authMiddleware, createUser);


// Update user
router.put('/:id', authMiddleware, updateUser);


// Update user role
router.patch('/:id/role', authMiddleware, updateUserRole);


// Update user status
router.patch('/:id/status', authMiddleware, updateUserStatus);


// Update last login
router.patch('/:id/last-login', authMiddleware, updateLastLogin);


module.exports = router;