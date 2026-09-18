const userService = require('../services/userService');

// Get the currently authenticated user
const getCurrentUser = async (req, res) => {
    try {
        const firebaseUid = req.user.uid;

        const user = await userService.getUserByFirebaseUid(firebaseUid);

        if (!user) {
            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }

        return res.status(200).json({
            success: true,
            user
        });

    } catch (error) {
        console.error('Get current user error:', error.message);

        return res.status(500).json({
            success: false,
            message: 'Failed to get current user'
        });
    }
};


// Get a user by MySQL user ID
const getUserById = async (req, res) => {
    try {
        const userId = req.params.id;

        const user = await userService.getUserById(userId);

        if (!user) {
            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }

        return res.status(200).json({
            success: true,
            user
        });

    } catch (error) {
        console.error('Get user error:', error.message);

        return res.status(500).json({
            success: false,
            message: 'Failed to get user'
        });
    }
};


// Get all users
const getAllUsers = async (req, res) => {
    try {
        const users = await userService.getAllUsers();

        return res.status(200).json({
            success: true,
            users
        });

    } catch (error) {
        console.error('Get all users error:', error.message);

        return res.status(500).json({
            success: false,
            message: 'Failed to get users'
        });
    }
};


// Create a user
const createUser = async (req, res) => {
    try {
        const {
            firstName,
            lastName,
            displayName,
            profileImage
        } = req.body;

        const firebaseUid = req.user.uid;
        const email = req.user.email;

        if (!email) {
            return res.status(400).json({
                success: false,
                message:
                    'Firebase account does not contain an email'
            });
        }

        const existingUser =
            await userService.getUserByFirebaseUid(
                firebaseUid
            );

        if (existingUser) {
            return res.status(200).json({
                success: true,
                message: 'User already exists',
                user: existingUser
            });
        }

        const user = await userService.createUser({
            firebaseUid,
            email,
            firstName,
            lastName,
            displayName,
            profileImage,
            roleId: 2
        });

        return res.status(201).json({
            success: true,
            message: 'User created successfully',
            user
        });

    } catch (error) {
        console.error(
            'Create user error:',
            error.message
        );

        return res.status(500).json({
            success: false,
            message: 'Failed to create user'
        });
    }
};


// Update user information
const updateUser = async (req, res) => {
    try {
        const userId = req.params.id;

        const {
            email,
            firstName,
            lastName,
            displayName,
            profileImage
        } = req.body;

        const user = await userService.updateUser({
            userId,
            email,
            firstName,
            lastName,
            displayName,
            profileImage
        });

        return res.status(200).json({
            success: true,
            message: 'User updated successfully',
            user
        });

    } catch (error) {
        console.error('Update user error:', error.message);

        return res.status(500).json({
            success: false,
            message: 'Failed to update user'
        });
    }
};


// Update user's role
const updateUserRole = async (req, res) => {
    try {
        const userId = req.params.id;
        const { roleId } = req.body;

        const user = await userService.updateUserRole(
            userId,
            roleId
        );

        return res.status(200).json({
            success: true,
            message: 'User role updated successfully',
            user
        });

    } catch (error) {
        console.error('Update user role error:', error.message);

        return res.status(500).json({
            success: false,
            message: 'Failed to update user role'
        });
    }
};


// Update user's status
const updateUserStatus = async (req, res) => {
    try {
        const userId = req.params.id;
        const { status } = req.body;

        const user = await userService.updateUserStatus(
            userId,
            status
        );

        return res.status(200).json({
            success: true,
            message: 'User status updated successfully',
            user
        });

    } catch (error) {
        console.error('Update user status error:', error.message);

        return res.status(500).json({
            success: false,
            message: 'Failed to update user status'
        });
    }
};


// Update user's last login
const updateLastLogin = async (req, res) => {
    try {
        const userId = req.params.id;

        const user = await userService.updateLastLogin(userId);

        return res.status(200).json({
            success: true,
            message: 'Last login updated successfully',
            user
        });

    } catch (error) {
        console.error('Update last login error:', error.message);

        return res.status(500).json({
            success: false,
            message: 'Failed to update last login'
        });
    }
};


module.exports = {
    getCurrentUser,
    getUserById,
    getAllUsers,
    createUser,
    updateUser,
    updateUserRole,
    updateUserStatus,
    updateLastLogin
};