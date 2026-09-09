const fileService = require('../services/fileService');

const createFile = async (req, res) => {
    try {
        const {
            folderId,
            ownerId,
            originalName,
            storedName,
            mimeType,
            fileSize,
            s3Bucket,
            s3Key,
            checksum
        } = req.body;

        const file = await fileService.createFile({
            folderId,
            ownerId,
            originalName,
            storedName,
            mimeType,
            fileSize,
            s3Bucket,
            s3Key,
            checksum
        });

        return res.status(201).json({
            success: true,
            message: 'File created successfully',
            file
        });

    } catch (error) {
        console.error('Create file error:', error.message);

        return res.status(500).json({
            success: false,
            message: 'Failed to create file'
        });
    }
};

const getFileById = async (req, res) => {
    try {
        const file = await fileService.getFileById(
            req.params.id
        );

        if (!file) {
            return res.status(404).json({
                success: false,
                message: 'File not found'
            });
        }

        return res.status(200).json({
            success: true,
            file
        });

    } catch (error) {
        console.error('Get file error:', error.message);

        return res.status(500).json({
            success: false,
            message: 'Failed to get file'
        });
    }
};

const getFolderFiles = async (req, res) => {
    try {
        const files = await fileService.getFolderFiles(
            req.params.folderId
        );

        return res.status(200).json({
            success: true,
            files
        });

    } catch (error) {
        console.error('Get folder files error:', error.message);

        return res.status(500).json({
            success: false,
            message: 'Failed to get files'
        });
    }
};

const updateFile = async (req, res) => {
    try {
        const {
            originalName,
            folderId,
            status
        } = req.body;

        const file = await fileService.updateFile(
            req.params.id,
            originalName,
            folderId,
            status
        );

        return res.status(200).json({
            success: true,
            message: 'File updated successfully',
            file
        });

    } catch (error) {
        console.error('Update file error:', error.message);

        return res.status(500).json({
            success: false,
            message: 'Failed to update file'
        });
    }
};

const deleteFile = async (req, res) => {
    try {
        const result = await fileService.deleteFile(
            req.params.id
        );

        return res.status(200).json({
            success: true,
            message: 'File deleted successfully',
            result
        });

    } catch (error) {
        console.error('Delete file error:', error.message);

        return res.status(500).json({
            success: false,
            message: 'Failed to delete file'
        });
    }
};

module.exports = {
    createFile,
    getFileById,
    getFolderFiles,
    updateFile,
    deleteFile
};