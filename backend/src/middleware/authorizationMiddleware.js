
const pool = require('../config/db');

const authorizationMiddleware = (requiredPermission) => {
    return async (req, res, next) => {
        try {
            if (!req.user || !req.user.uid) {
                return res.status(401).json({
                    success: false,
                    message: 'Authenticated user information is missing'
                });
            }

            const firebaseUid = req.user.uid;

            const [userResult] = await pool.query(
                'CALL sp_get_user_by_firebase_uid(?)',
                [firebaseUid]
            );

            const user = userResult[0][0];

            if (!user) {
                return res.status(403).json({
                    success: false,
                    message: 'User account not found'
                });
            }

            if (!user.role_id) {
                return res.status(403).json({
                    success: false,
                    message: 'User does not have a role'
                });
            }

            const [permissionResult] = await pool.query(
                'CALL sp_get_role_permissions(?)',
                [user.role_id]
            );

            const permissions = permissionResult[0] || [];

            const hasPermission = permissions.some((permission) => {
                return permission.name === requiredPermission;
            });

            if (!hasPermission) {
                return res.status(403).json({
                    success: false,
                    message: 'You do not have permission to perform this action'
                });
            }

            req.userDatabase = user;
            req.permission = requiredPermission;

            next();

        } catch (error) {
            console.error(
                'Authorization error:',
                error.message
            );

            return res.status(500).json({
                success: false,
                message: 'Authorization check failed'
            });
        }
    };
};

module.exports = authorizationMiddleware;
