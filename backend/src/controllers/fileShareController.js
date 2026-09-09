const fileShareService = require('../services/fileShareService');

const shareFile = async (req, res) => {
    try {
        const fileId = req.params.fileId;

        const {
            userId,
            permissionId,
            sharedBy,
            expiresAt
        } = req.body;

        const share = await fileShareService.shareFile({
            fileId,
            userId,
            permissionId,
            sharedBy,
            expiresAt
        });

        return res.status(201).json({
            success: true,
            message: 'File shared successfully',
            share
        });

    } catch (error) {
        console.error('Share file error:', error.message);

        return res.status(500).json({
            success: false,
            message: 'Failed to share file'
        });
    }
};

const removeFileShare = async (req, res) => {
    try {
        const result =
            await fileShareService.removeFileShare(
                req.params.fileId,
                req.params.userId
            );

        return res.status(200).json({
            success: true,
            message: 'File share removed successfully',
            result
        });

    } catch (error) {
        console.error(
            'Remove file share error:',
            error.message
        );

        return res.status(500).json({
            success: false,
            message: 'Failed to remove file share'
        });
    }
};

const getFileShares = async (req, res) => {
    try {
        const shares =
            await fileShareService.getFileShares(
                req.params.fileId
            );

        return res.status(200).json({
            success: true,
            shares
        });

    } catch (error) {
        console.error(
            'Get file shares error:',
            error.message
        );

        return res.status(500).json({
            success: false,
            message: 'Failed to get file shares'
        });
    }
};

const getSharedFilesForUser = async (req, res) => {
    try {
        const shares =
            await fileShareService.getSharedFilesForUser(
                req.params.userId
            );

        return res.status(200).json({
            success: true,
            shares
        });

    } catch (error) {
        console.error(
            'Get shared files error:',
            error.message
        );

        return res.status(500).json({
            success: false,
            message: 'Failed to get shared files'
        });
    }
};

module.exports = {
    shareFile,
    removeFileShare,
    getFileShares,
    getSharedFilesForUser
};