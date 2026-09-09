const express = require('express');
const cors = require('cors');
require('dotenv').config();

const pool = require('./config/db');

const app = express();

app.use(cors());
app.use(express.json());

const authRoutes = require('./routes/authRoutes');

app.get('/', (req, res) => {
    res.json({
        message: 'Secure Document Manager API is running'
    });
});

app.get('/db-test', async (req, res) => {
    try {
        const [rows] = await pool.query('SELECT 1 AS result');

        res.json({
            success: true,
            message: 'MySQL connection successful',
            result: rows[0]
        });
    } catch (error) {
        console.error(error);

        res.status(500).json({
            success: false,
            message: 'MySQL connection failed'
        });
    }
});

const PORT = process.env.PORT || 3000;
app.use('/api/auth', authRoutes);

app.listen(PORT, () => {
    console.log(`Server running on http://localhost:${PORT}`);
});