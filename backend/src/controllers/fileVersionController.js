const fileVersionService = require('../services/fileVersionService');

const createFileVersion = async (req, res) => {
    try {
        const {
            fileId,
            s3Key,
            fileSize,
            checksum,
            uploadedBy
        } = req.body;

        const version = await fileVersionService.createFileVersion({
            fileId,
            s3Key,
            fileSize,
            checksum,
            uploadedBy
        });

        return res.status(201).json({
            success: true,
            message: 'File version created successfully',
            version
        });

    } catch (error) {
        console.error(
            'Create file version error:',
            error.message
        );

        return res.status(500).json({
            success: false,
            message: 'Failed to create file version'
        });
    }
};

const getFileVersions = async (req, res) => {
    try {
        const versions = await fileVersionService.getFileVersions(
            req.params.fileId
        );

        return res.status(200).json({
            success: true,
            versions
        });

    } catch (error) {
        console.error(
            'Get file versions error:',
            error.message
        );

        return res.status(500).json({
            success: false,
            message: 'Failed to get file versions'
        });
    }
};

module.exports = {
    createFileVersion,
    getFileVersions
};