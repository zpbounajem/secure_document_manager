const verificationService = require('../services/verificationService');
const emailService = require('../services/emailService');

const sendVerificationCode = async (req, res) => {
    try {
        const { email } = req.body;

        if (!email || typeof email !== 'string') {
            return res.status(400).json({
                success: false,
                message: 'Email is required'
            });
        }

        const normalizedEmail = email.trim().toLowerCase();

        const user =
            await verificationService.getUserByEmail(
                normalizedEmail
            );

        if (!user) {
            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }

        if (user.email_verified) {
            return res.status(400).json({
                success: false,
                message: 'Email is already verified'
            });
        }

        const verification =
            await verificationService.createAndStoreVerificationCode(
                user.id
            );

        try {
            await emailService.sendVerificationEmail({
                email: normalizedEmail,
                verificationCode:
                    verification.verificationCode
            });
        } catch (emailError) {
            await verificationService.clearVerificationCode(
                user.id
            );

            throw emailError;
        }

        return res.status(200).json({
            success: true,
            message: 'Verification code sent successfully',
            expiresAt: verification.expiresAt
        });

    } catch (error) {
        console.error(
            'Send verification code error:',
            error
        );

        return res.status(500).json({
            success: false,
            message: 'Failed to send verification code'
        });
    }
};

const verifyEmail = async (req, res) => {
    try {
        const {
            email,
            verificationCode
        } = req.body;

        if (!email || typeof email !== 'string') {
            return res.status(400).json({
                success: false,
                message: 'Email is required'
            });
        }

        if (
            !verificationCode ||
            typeof verificationCode !== 'string'
        ) {
            return res.status(400).json({
                success: false,
                message: 'Verification code is required'
            });
        }

        const normalizedEmail = email.trim().toLowerCase();
        const normalizedCode = verificationCode.trim();

        if (!/^\d{6}$/.test(normalizedCode)) {
            return res.status(400).json({
                success: false,
                message:
                    'Verification code must contain 6 digits'
            });
        }

        const result =
            await verificationService.verifyEmailCode({
                email: normalizedEmail,
                verificationCode: normalizedCode
            });

        return res.status(200).json({
            success: true,
            message: 'Email verified successfully',
            user: result
        });

    } catch (error) {
        console.error(
            'Verify email error:',
            error
        );

        return res.status(400).json({
            success: false,
            message: error.message
        });
    }
};

const resendVerificationCode = async (req, res) => {
    try {
        const { email } = req.body;

        if (!email || typeof email !== 'string') {
            return res.status(400).json({
                success: false,
                message: 'Email is required'
            });
        }

        const normalizedEmail = email.trim().toLowerCase();

        const user =
            await verificationService.getUserByEmail(
                normalizedEmail
            );

        if (!user) {
            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }

        if (user.email_verified) {
            return res.status(400).json({
                success: false,
                message: 'Email is already verified'
            });
        }

        const verification =
            await verificationService.createAndStoreVerificationCode(
                user.id
            );

        try {
            await emailService.sendVerificationEmail({
                email: normalizedEmail,
                verificationCode:
                    verification.verificationCode
            });
        } catch (emailError) {
            await verificationService.clearVerificationCode(
                user.id
            );

            throw emailError;
        }

        return res.status(200).json({
            success: true,
            message:
                'Verification code resent successfully',
            expiresAt: verification.expiresAt
        });

    } catch (error) {
        console.error(
            'Resend verification code error:',
            error
        );

        return res.status(500).json({
            success: false,
            message:
                'Failed to resend verification code'
        });
    }
};

module.exports = {
    sendVerificationCode,
    verifyEmail,
    resendVerificationCode
};