const sharePermissionService = require('../services/sharePermissionService');

const createSharePermission = async (req, res) => {
    try {
        const { name, description } = req.body;

        const permission =
            await sharePermissionService.createSharePermission(
                name,
                description
            );

        return res.status(201).json({
            success: true,
            message: 'Share permission created successfully',
            permission
        });

    } catch (error) {
        console.error(
            'Create share permission error:',
            error.message
        );

        return res.status(500).json({
            success: false,
            message: 'Failed to create share permission'
        });
    }
};

const getSharePermissions = async (req, res) => {
    try {
        const permissions =
            await sharePermissionService.getSharePermissions();

        return res.status(200).json({
            success: true,
            permissions
        });

    } catch (error) {
        console.error(
            'Get share permissions error:',
            error.message
        );

        return res.status(500).json({
            success: false,
            message: 'Failed to get share permissions'
        });
    }
};

module.exports = {
    createSharePermission,
    getSharePermissions
};