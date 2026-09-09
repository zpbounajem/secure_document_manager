const express = require('express');

const authMiddleware = require('../middleware/authMiddleware');

const {
    createRole,
    updateRole,
    deleteRole,
    getAllRoles
} = require('../controllers/roleController');

const router = express.Router();


// Get all roles
router.get('/', authMiddleware, getAllRoles);


// Create role
router.post('/', authMiddleware, createRole);


// Update role
router.put('/:id', authMiddleware, updateRole);


// Delete role
router.delete('/:id', authMiddleware, deleteRole);


module.exports = router;