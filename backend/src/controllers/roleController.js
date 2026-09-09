const roleService = require('../services/roleService');


// Create a new role
const createRole = async (req, res) => {
    try {
        const { name, description } = req.body;

        const role = await roleService.createRole(
            name,
            description
        );

        return res.status(201).json({
            success: true,
            message: 'Role created successfully',
            role
        });

    } catch (error) {
        console.error('Create role error:', error.message);

        return res.status(500).json({
            success: false,
            message: 'Failed to create role'
        });
    }
};


// Update a role
const updateRole = async (req, res) => {
    try {
        const roleId = req.params.id;
        const { name, description } = req.body;

        const role = await roleService.updateRole(
            roleId,
            name,
            description
        );

        if (!role) {
            return res.status(404).json({
                success: false,
                message: 'Role not found'
            });
        }

        return res.status(200).json({
            success: true,
            message: 'Role updated successfully',
            role
        });

    } catch (error) {
        console.error('Update role error:', error.message);

        return res.status(500).json({
            success: false,
            message: 'Failed to update role'
        });
    }
};


// Delete a role
const deleteRole = async (req, res) => {
    try {
        const roleId = req.params.id;

        const result = await roleService.deleteRole(roleId);

        return res.status(200).json({
            success: true,
            message: 'Role deleted successfully',
            result
        });

    } catch (error) {
        console.error('Delete role error:', error.message);

        return res.status(500).json({
            success: false,
            message: 'Failed to delete role'
        });
    }
};


// Get all roles
const getAllRoles = async (req, res) => {
    try {
        const roles = await roleService.getAllRoles();

        return res.status(200).json({
            success: true,
            roles
        });

    } catch (error) {
        console.error('Get all roles error:', error.message);

        return res.status(500).json({
            success: false,
            message: 'Failed to get roles'
        });
    }
};


module.exports = {
    createRole,
    updateRole,
    deleteRole,
    getAllRoles
};