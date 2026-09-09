
CREATE DATABASE IF NOT EXISTS secure_document_manager;

USE secure_document_manager;


-- ============================================================
-- 1. ROLES
-- ============================================================

CREATE TABLE roles (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    name VARCHAR(50) NOT NULL UNIQUE,

    description VARCHAR(255),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP
);


-- ============================================================
-- 2. USERS
-- ============================================================

CREATE TABLE users (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    firebase_uid VARCHAR(128) NOT NULL UNIQUE,

    email VARCHAR(255) NOT NULL UNIQUE,

    first_name VARCHAR(100),

    last_name VARCHAR(100),

    display_name VARCHAR(150),

    profile_image VARCHAR(500),

    role_id INT UNSIGNED NOT NULL,

    status ENUM(
        'active',
        'inactive',
        'suspended'
    ) NOT NULL DEFAULT 'active',

    last_login_at TIMESTAMP NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_users_role
        FOREIGN KEY (role_id)
        REFERENCES roles(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);


-- ============================================================
-- 3. PERMISSIONS
-- ============================================================

CREATE TABLE permissions (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    name VARCHAR(100) NOT NULL UNIQUE,

    description VARCHAR(255),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================
-- 4. ROLE PERMISSIONS
-- ============================================================

CREATE TABLE role_permissions (
    role_id INT UNSIGNED NOT NULL,

    permission_id INT UNSIGNED NOT NULL,

    PRIMARY KEY (role_id, permission_id),

    CONSTRAINT fk_role_permissions_role
        FOREIGN KEY (role_id)
        REFERENCES roles(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_role_permissions_permission
        FOREIGN KEY (permission_id)
        REFERENCES permissions(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);


-- ============================================================
-- 5. FOLDERS
-- ============================================================

CREATE TABLE folders (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    name VARCHAR(255) NOT NULL,

    parent_id BIGINT UNSIGNED NULL,

    owner_id INT UNSIGNED NOT NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    deleted_at TIMESTAMP NULL,

    CONSTRAINT fk_folders_parent
        FOREIGN KEY (parent_id)
        REFERENCES folders(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_folders_owner
        FOREIGN KEY (owner_id)
        REFERENCES users(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);


-- ============================================================
-- 6. FILES
-- ============================================================

CREATE TABLE files (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    folder_id BIGINT UNSIGNED NULL,

    owner_id INT UNSIGNED NOT NULL,

    original_name VARCHAR(255) NOT NULL,

    stored_name VARCHAR(255) NOT NULL,

    mime_type VARCHAR(150),

    file_size BIGINT UNSIGNED NOT NULL,

    s3_bucket VARCHAR(255) NOT NULL,

    s3_key VARCHAR(768) NOT NULL UNIQUE,

    current_version INT UNSIGNED NOT NULL DEFAULT 1,

    checksum VARCHAR(128),

    status ENUM(
        'active',
        'archived',
        'deleted'
    ) NOT NULL DEFAULT 'active',

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    deleted_at TIMESTAMP NULL,

    CONSTRAINT fk_files_folder
        FOREIGN KEY (folder_id)
        REFERENCES folders(id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,

    CONSTRAINT fk_files_owner
        FOREIGN KEY (owner_id)
        REFERENCES users(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    INDEX idx_files_folder (folder_id),

    INDEX idx_files_owner (owner_id),

    INDEX idx_files_status (status)
);


-- ============================================================
-- 7. FILE VERSIONS
-- ============================================================

CREATE TABLE file_versions (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    file_id BIGINT UNSIGNED NOT NULL,

    version_number INT UNSIGNED NOT NULL,

    s3_key VARCHAR(768) NOT NULL UNIQUE,

    file_size BIGINT UNSIGNED NOT NULL,

    checksum VARCHAR(128),

    uploaded_by INT UNSIGNED NOT NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_file_versions_file
        FOREIGN KEY (file_id)
        REFERENCES files(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_file_versions_uploader
        FOREIGN KEY (uploaded_by)
        REFERENCES users(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    UNIQUE KEY uq_file_version (
        file_id,
        version_number
    ),

    INDEX idx_file_versions_file (file_id)
);


-- ============================================================
-- 8. SHARE PERMISSIONS
-- ============================================================

CREATE TABLE share_permissions (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    name VARCHAR(50) NOT NULL UNIQUE,

    description VARCHAR(255),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================
-- 9. FOLDER SHARES
-- ============================================================

CREATE TABLE folder_shares (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    folder_id BIGINT UNSIGNED NOT NULL,

    user_id INT UNSIGNED NOT NULL,

    permission_id INT UNSIGNED NOT NULL,

    shared_by INT UNSIGNED NOT NULL,

    expires_at TIMESTAMP NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_folder_shares_folder
        FOREIGN KEY (folder_id)
        REFERENCES folders(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_folder_shares_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_folder_shares_permission
        FOREIGN KEY (permission_id)
        REFERENCES share_permissions(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_folder_shares_shared_by
        FOREIGN KEY (shared_by)
        REFERENCES users(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    UNIQUE KEY uq_folder_share (
        folder_id,
        user_id
    ),

    INDEX idx_folder_shares_user (user_id)
);


-- ============================================================
-- 10. FILE SHARES
-- ============================================================

CREATE TABLE file_shares (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    file_id BIGINT UNSIGNED NOT NULL,

    user_id INT UNSIGNED NOT NULL,

    permission_id INT UNSIGNED NOT NULL,

    shared_by INT UNSIGNED NOT NULL,

    expires_at TIMESTAMP NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_file_shares_file
        FOREIGN KEY (file_id)
        REFERENCES files(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_file_shares_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_file_shares_permission
        FOREIGN KEY (permission_id)
        REFERENCES share_permissions(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_file_shares_shared_by
        FOREIGN KEY (shared_by)
        REFERENCES users(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    UNIQUE KEY uq_file_share (
        file_id,
        user_id
    ),

    INDEX idx_file_shares_user (user_id)
);


-- ============================================================
-- 11. AUDIT LOGS
-- ============================================================

CREATE TABLE audit_logs (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    user_id INT UNSIGNED NULL,

    action VARCHAR(100) NOT NULL,

    resource_type VARCHAR(50),

    resource_id BIGINT UNSIGNED NULL,

    description TEXT,

    ip_address VARCHAR(45),

    user_agent TEXT,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_audit_logs_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,

    INDEX idx_audit_logs_user (user_id),

    INDEX idx_audit_logs_resource (
        resource_type,
        resource_id
    ),

    INDEX idx_audit_logs_created_at (created_at)
);


-- ============================================================
-- 12. NOTIFICATIONS
-- ============================================================

CREATE TABLE notifications (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    user_id INT UNSIGNED NOT NULL,

    type VARCHAR(50) NOT NULL,

    title VARCHAR(255) NOT NULL,

    message TEXT NOT NULL,

    resource_type VARCHAR(50),

    resource_id BIGINT UNSIGNED NULL,

    is_read BOOLEAN NOT NULL DEFAULT FALSE,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_notifications_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    INDEX idx_notifications_user (user_id),

    INDEX idx_notifications_read (is_read)
);