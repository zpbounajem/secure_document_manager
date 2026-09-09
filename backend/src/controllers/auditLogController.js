const auditLogService = require('../services/auditLogService');

const createAuditLog = async (req, res) => {
    try {
        const {
            userId,
            action,
            resourceType,
            resourceId,
            description,
            ipAddress,
            userAgent
        } = req.body;

        const log = await auditLogService.createAuditLog({
            userId,
            action,
            resourceType,
            resourceId,
            description,
            ipAddress,
            userAgent
        });

        return res.status(201).json({
            success: true,
            message: 'Audit log created successfully',
            log
        });

    } catch (error) {
        console.error(
            'Create audit log error:',
            error.message
        );

        return res.status(500).json({
            success: false,
            message: 'Failed to create audit log'
        });
    }
};

const getUserAuditLogs = async (req, res) => {
    try {
        const logs =
            await auditLogService.getUserAuditLogs(
                req.params.userId
            );

        return res.status(200).json({
            success: true,
            logs
        });

    } catch (error) {
        console.error(
            'Get user audit logs error:',
            error.message
        );

        return res.status(500).json({
            success: false,
            message: 'Failed to get audit logs'
        });
    }
};

const getAllAuditLogs = async (req, res) => {
    try {
        const logs =
            await auditLogService.getAllAuditLogs();

        return res.status(200).json({
            success: true,
            logs
        });

    } catch (error) {
        console.error(
            'Get all audit logs error:',
            error.message
        );

        return res.status(500).json({
            success: false,
            message: 'Failed to get audit logs'
        });
    }
};

module.exports = {
    createAuditLog,
    getUserAuditLogs,
    getAllAuditLogs
};