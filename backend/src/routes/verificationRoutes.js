const express = require('express');

const {
    sendVerificationCode,
    verifyEmail,
    resendVerificationCode
} = require('../controllers/verificationController');

const router = express.Router();

router.post(
    '/send',
    sendVerificationCode
);

router.post(
    '/verify',
    verifyEmail
);

router.post(
    '/resend',
    resendVerificationCode
);

module.exports = router;