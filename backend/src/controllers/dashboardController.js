const dashboardService = require('../services/dashboardService');

const getUserStorageSummary = async (req, res) => {
    try {
        const summary =
            await dashboardService.getUserStorageSummary(
                req.params.userId
            );

        return res.status(200).json({
            success: true,
            summary
        });

    } catch (error) {
        console.error(
            'Get dashboard summary error:',
            error.message
        );

        return res.status(500).json({
            success: false,
            message: 'Failed to get dashboard summary'
        });
    }
};

module.exports = {
    getUserStorageSummary
};