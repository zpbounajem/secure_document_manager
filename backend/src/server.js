const express = require('express');
const cors = require('cors');
require('dotenv').config();

const pool = require('./config/db');

const authRoutes = require('./routes/authRoutes');
const userRoutes = require('./routes/userRoutes');
const roleRoutes = require('./routes/roleRoutes');
const permissionRoutes = require('./routes/permissionRoutes');
const folderRoutes = require('./routes/folderRoutes');
const fileRoutes = require('./routes/fileRoutes');
const fileVersionRoutes = require('./routes/fileVersionRoutes');
const sharePermissionRoutes = require('./routes/sharePermissionRoutes');
const folderShareRoutes = require('./routes/folderShareRoutes');
const fileShareRoutes = require('./routes/fileShareRoutes');
const auditLogRoutes = require('./routes/auditLogRoutes');
const notificationRoutes = require('./routes/notificationRoutes');
const dashboardRoutes = require('./routes/dashboardRoutes');
const verificationRoutes = require('./routes/verificationRoutes');

const app = express();

app.use(cors());
app.use(express.json());

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

app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/roles', roleRoutes);
app.use('/api/permissions', permissionRoutes);
app.use('/api/folders', folderRoutes);
app.use('/api/files', fileRoutes);
app.use('/api/file-versions', fileVersionRoutes);
app.use('/api/share-permissions', sharePermissionRoutes);
app.use('/api/folder-shares', folderShareRoutes);
app.use('/api/file-shares', fileShareRoutes);
app.use('/api/audit-logs', auditLogRoutes);
app.use('/api/notifications', notificationRoutes);
app.use('/api/dashboard', dashboardRoutes);
app.use('/api/verification', verificationRoutes);

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
    console.log(`Server running on http://localhost:${PORT}`);
});