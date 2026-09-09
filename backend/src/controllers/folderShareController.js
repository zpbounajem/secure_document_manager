const folderShareService = require('../services/folderShareService');

const shareFolder = async (req, res) => {
    try {
        const folderId = req.params.folderId;

        const {
            userId,
            permissionId,
            sharedBy,
            expiresAt
        } = req.body;

        const share = await folderShareService.shareFolder({
            folderId,
            userId,
            permissionId,
            sharedBy,
            expiresAt
        });

        return res.status(201).json({
            success: true,
            message: 'Folder shared successfully',
            share
        });

    } catch (error) {
        console.error('Share folder error:', error.message);

        return res.status(500).json({
            success: false,
            message: 'Failed to share folder'
        });
    }
};

const removeFolderShare = async (req, res) => {
    try {
        const result =
            await folderShareService.removeFolderShare(
                req.params.folderId,
                req.params.userId
            );

        return res.status(200).json({
            success: true,
            message: 'Folder share removed successfully',
            result
        });

    } catch (error) {
        console.error(
            'Remove folder share error:',
            error.message
        );

        return res.status(500).json({
            success: false,
            message: 'Failed to remove folder share'
        });
    }
};

const getFolderShares = async (req, res) => {
    try {
        const shares =
            await folderShareService.getFolderShares(
                req.params.folderId
            );

        return res.status(200).json({
            success: true,
            shares
        });

    } catch (error) {
        console.error(
            'Get folder shares error:',
            error.message
        );

        return res.status(500).json({
            success: false,
            message: 'Failed to get folder shares'
        });
    }
};

const getSharedFoldersForUser = async (req, res) => {
    try {
        const shares =
            await folderShareService.getSharedFoldersForUser(
                req.params.userId
            );

        return res.status(200).json({
            success: true,
            shares
        });

    } catch (error) {
        console.error(
            'Get shared folders error:',
            error.message
        );

        return res.status(500).json({
            success: false,
            message: 'Failed to get shared folders'
        });
    }
};

module.exports = {
    shareFolder,
    removeFolderShare,
    getFolderShares,
    getSharedFoldersForUser
};