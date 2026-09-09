const express = require('express');
const authMiddleware = require('../middleware/authMiddleware');

const router = express.Router();

router.get('/me', authMiddleware, (req, res) => {
    res.json({
        success: true,
        message: 'Authentication successful',
        user: {
            uid: req.user.uid,
            email: req.user.email
        }
    });
});

module.exports = router;