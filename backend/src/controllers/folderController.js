const folderService = require('../services/folderService');

const createFolder = async (req, res) => {
    try {
        const { name, parentId, ownerId } = req.body;

        const folder = await folderService.createFolder(
            name,
            parentId,
            ownerId
        );

        return res.status(201).json({
            success: true,
            message: 'Folder created successfully',
            folder
        });

    } catch (error) {
        console.error('Create folder error:', error.message);

        return res.status(500).json({
            success: false,
            message: 'Failed to create folder'
        });
    }
};

const getFolderById = async (req, res) => {
    try {
        const folder = await folderService.getFolderById(
            req.params.id
        );

        if (!folder) {
            return res.status(404).json({
                success: false,
                message: 'Folder not found'
            });
        }

        return res.status(200).json({
            success: true,
            folder
        });

    } catch (error) {
        console.error('Get folder error:', error.message);

        return res.status(500).json({
            success: false,
            message: 'Failed to get folder'
        });
    }
};

const getRootFolders = async (req, res) => {
    try {
        const { ownerId } = req.query;

        const folders = await folderService.getRootFolders(ownerId);

        return res.status(200).json({
            success: true,
            folders
        });

    } catch (error) {
        console.error('Get root folders error:', error.message);

        return res.status(500).json({
            success: false,
            message: 'Failed to get root folders'
        });
    }
};

const getSubfolders = async (req, res) => {
    try {
        const folders = await folderService.getSubfolders(
            req.params.parentId
        );

        return res.status(200).json({
            success: true,
            folders
        });

    } catch (error) {
        console.error('Get subfolders error:', error.message);

        return res.status(500).json({
            success: false,
            message: 'Failed to get subfolders'
        });
    }
};

const updateFolder = async (req, res) => {
    try {
        const { name, parentId } = req.body;

        const folder = await folderService.updateFolder(
            req.params.id,
            name,
            parentId
        );

        return res.status(200).json({
            success: true,
            message: 'Folder updated successfully',
            folder
        });

    } catch (error) {
        console.error('Update folder error:', error.message);

        return res.status(500).json({
            success: false,
            message: 'Failed to update folder'
        });
    }
};

const deleteFolder = async (req, res) => {
    try {
        const result = await folderService.deleteFolder(
            req.params.id
        );

        return res.status(200).json({
            success: true,
            message: 'Folder deleted successfully',
            result
        });

    } catch (error) {
        console.error('Delete folder error:', error.message);

        return res.status(500).json({
            success: false,
            message: 'Failed to delete folder'
        });
    }
};

module.exports = {
    createFolder,
    getFolderById,
    getRootFolders,
    getSubfolders,
    updateFolder,
    deleteFolder
};