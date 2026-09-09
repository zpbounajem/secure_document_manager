const express = require('express');

const authMiddleware = require('../middleware/authMiddleware');

const {
    createPermission,
    getAllPermissions,
    assignPermissionToRole,
    removePermissionFromRole,
    getRolePermissions
} = require('../controllers/permissionController');

const router = express.Router();


// Get all permissions
router.get('/', authMiddleware, getAllPermissions);


// Create permission
router.post('/', authMiddleware, createPermission);


// Get permissions for a role
router.get(
    '/role/:roleId',
    authMiddleware,
    getRolePermissions
);


// Assign permission to role
router.post(
    '/role/:roleId',
    authMiddleware,
    assignPermissionToRole
);


// Remove permission from role
router.delete(
    '/role/:roleId/:permissionId',
    authMiddleware,
    removePermissionFromRole
);


module.exports = router;