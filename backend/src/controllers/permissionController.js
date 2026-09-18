
const permissionService = require('../services/permissionService');


// Create a new permission
const createPermission = async (req, res) => {
    try {
        const { name, description } = req.body;

        const permission = await permissionService.createPermission(
            name,
            description
        );

        return res.status(201).json({
            success: true,
            message: 'Permission created successfully',
            permission
        });

    } catch (error) {
        console.error('Create permission error:', error);

        return res.status(500).json({
            success: false,
            message: 'Failed to create permission'
        });
    }
};


// Get all permissions
const getAllPermissions = async (req, res) => {
    try {
        const permissions = await permissionService.getAllPermissions();

        return res.status(200).json({
            success: true,
            permissions
        });

    } catch (error) {
        console.error('Get all permissions error:', error);

        return res.status(500).json({
            success: false,
            message: 'Failed to get permissions'
        });
    }
};


// Assign permission to role
const assignPermissionToRole = async (req, res) => {
    try {
        const roleId = req.params.roleId;
        const { permissionId } = req.body;

        const result = await permissionService.assignPermissionToRole(
            roleId,
            permissionId
        );

        return res.status(200).json({
            success: true,
            message: 'Permission assigned to role successfully',
            result
        });

    } catch (error) {
        console.error('Assign permission error:', error);

        return res.status(500).json({
            success: false,
            message: 'Failed to assign permission to role'
        });
    }
};


// Remove permission from role
const removePermissionFromRole = async (req, res) => {
    try {
        const roleId = req.params.roleId;
        const permissionId = req.params.permissionId;

        const result = await permissionService.removePermissionFromRole(
            roleId,
            permissionId
        );

        return res.status(200).json({
            success: true,
            message: 'Permission removed from role successfully',
            result
        });

    } catch (error) {
        console.error('Remove permission error:', error);

        return res.status(500).json({
            success: false,
            message: 'Failed to remove permission from role'
        });
    }
};


// Get permissions for a role
const getRolePermissions = async (req, res) => {
    try {
        const roleId = req.params.roleId;

        const permissions = await permissionService.getRolePermissions(
            roleId
        );

        return res.status(200).json({
            success: true,
            permissions
        });

    } catch (error) {
        console.error('Get role permissions error:', error);

        return res.status(500).json({
            success: false,
            message: 'Failed to get role permissions'
        });
    }
};


module.exports = {
    createPermission,
    getAllPermissions,
    assignPermissionToRole,
    removePermissionFromRole,
    getRolePermissions
};

