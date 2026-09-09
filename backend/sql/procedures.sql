USE secure_document_manager;

DELIMITER $$

/* ============================================================
   1. ROLES
   ============================================================ */

DROP PROCEDURE IF EXISTS sp_create_role$$

CREATE PROCEDURE sp_create_role(
    IN p_name VARCHAR(50),
    IN p_description VARCHAR(255)
)
BEGIN
    IF p_name IS NULL OR TRIM(p_name) = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Role name cannot be empty';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM roles
        WHERE name = TRIM(p_name)
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Role already exists';
    END IF;

    INSERT INTO roles (name, description)
    VALUES (TRIM(p_name), p_description);

    SELECT LAST_INSERT_ID() AS role_id;
END$$


DROP PROCEDURE IF EXISTS sp_update_role$$

CREATE PROCEDURE sp_update_role(
    IN p_role_id INT UNSIGNED,
    IN p_name VARCHAR(50),
    IN p_description VARCHAR(255)
)
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM roles WHERE id = p_role_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Role not found';
    END IF;

    IF p_name IS NULL OR TRIM(p_name) = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Role name cannot be empty';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM roles
        WHERE name = TRIM(p_name)
          AND id <> p_role_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Another role already uses this name';
    END IF;

    UPDATE roles
    SET
        name = TRIM(p_name),
        description = p_description
    WHERE id = p_role_id;
END$$


DROP PROCEDURE IF EXISTS sp_delete_role$$

CREATE PROCEDURE sp_delete_role(
    IN p_role_id INT UNSIGNED
)
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM roles WHERE id = p_role_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Role not found';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM users
        WHERE role_id = p_role_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot delete a role assigned to users';
    END IF;

    DELETE FROM roles
    WHERE id = p_role_id;
END$$


DROP PROCEDURE IF EXISTS sp_get_all_roles$$

CREATE PROCEDURE sp_get_all_roles()
BEGIN
    SELECT
        r.id,
        r.name,
        r.description,
        r.created_at,
        r.updated_at,
        COUNT(u.id) AS user_count
    FROM roles r
    LEFT JOIN users u
        ON u.role_id = r.id
    GROUP BY
        r.id,
        r.name,
        r.description,
        r.created_at,
        r.updated_at
    ORDER BY r.name;
END$$


/* ============================================================
   2. USERS
   ============================================================ */

DROP PROCEDURE IF EXISTS sp_create_user$$

CREATE PROCEDURE sp_create_user(
    IN p_firebase_uid VARCHAR(128),
    IN p_email VARCHAR(255),
    IN p_first_name VARCHAR(100),
    IN p_last_name VARCHAR(100),
    IN p_display_name VARCHAR(150),
    IN p_profile_image VARCHAR(500),
    IN p_role_id INT UNSIGNED
)
BEGIN
    IF p_firebase_uid IS NULL OR TRIM(p_firebase_uid) = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Firebase UID cannot be empty';
    END IF;

    IF p_email IS NULL OR TRIM(p_email) = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Email cannot be empty';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM roles WHERE id = p_role_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Role does not exist';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM users
        WHERE firebase_uid = TRIM(p_firebase_uid)
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Firebase UID already exists';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM users
        WHERE LOWER(email) = LOWER(TRIM(p_email))
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Email already exists';
    END IF;

    INSERT INTO users (
        firebase_uid,
        email,
        first_name,
        last_name,
        display_name,
        profile_image,
        role_id
    )
    VALUES (
        TRIM(p_firebase_uid),
        LOWER(TRIM(p_email)),
        p_first_name,
        p_last_name,
        p_display_name,
        p_profile_image,
        p_role_id
    );

    SELECT LAST_INSERT_ID() AS user_id;
END$$


DROP PROCEDURE IF EXISTS sp_get_user_by_id$$

CREATE PROCEDURE sp_get_user_by_id(
    IN p_user_id INT UNSIGNED
)
BEGIN
    SELECT
        u.id,
        u.firebase_uid,
        u.email,
        u.first_name,
        u.last_name,
        u.display_name,
        u.profile_image,
        u.role_id,
        r.name AS role_name,
        u.status,
        u.last_login_at,
        u.created_at,
        u.updated_at
    FROM users u
    INNER JOIN roles r
        ON r.id = u.role_id
    WHERE u.id = p_user_id;
END$$


DROP PROCEDURE IF EXISTS sp_get_user_by_firebase_uid$$

CREATE PROCEDURE sp_get_user_by_firebase_uid(
    IN p_firebase_uid VARCHAR(128)
)
BEGIN
    SELECT
        u.id,
        u.firebase_uid,
        u.email,
        u.first_name,
        u.last_name,
        u.display_name,
        u.profile_image,
        u.role_id,
        r.name AS role_name,
        u.status,
        u.last_login_at,
        u.created_at,
        u.updated_at
    FROM users u
    INNER JOIN roles r
        ON r.id = u.role_id
    WHERE u.firebase_uid = p_firebase_uid;
END$$


DROP PROCEDURE IF EXISTS sp_get_all_users$$

CREATE PROCEDURE sp_get_all_users()
BEGIN
    SELECT
        u.id,
        u.firebase_uid,
        u.email,
        u.first_name,
        u.last_name,
        u.display_name,
        u.profile_image,
        u.role_id,
        r.name AS role_name,
        u.status,
        u.last_login_at,
        u.created_at,
        u.updated_at
    FROM users u
    INNER JOIN roles r
        ON r.id = u.role_id
    ORDER BY u.created_at DESC;
END$$


DROP PROCEDURE IF EXISTS sp_update_user$$

CREATE PROCEDURE sp_update_user(
    IN p_user_id INT UNSIGNED,
    IN p_email VARCHAR(255),
    IN p_first_name VARCHAR(100),
    IN p_last_name VARCHAR(100),
    IN p_display_name VARCHAR(150),
    IN p_profile_image VARCHAR(500)
)
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM users WHERE id = p_user_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'User not found';
    END IF;

    IF p_email IS NULL OR TRIM(p_email) = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Email cannot be empty';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM users
        WHERE LOWER(email) = LOWER(TRIM(p_email))
          AND id <> p_user_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Email already belongs to another user';
    END IF;

    UPDATE users
    SET
        email = LOWER(TRIM(p_email)),
        first_name = p_first_name,
        last_name = p_last_name,
        display_name = p_display_name,
        profile_image = p_profile_image
    WHERE id = p_user_id;
END$$


DROP PROCEDURE IF EXISTS sp_update_user_role$$

CREATE PROCEDURE sp_update_user_role(
    IN p_user_id INT UNSIGNED,
    IN p_role_id INT UNSIGNED
)
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM users WHERE id = p_user_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'User not found';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM roles WHERE id = p_role_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Role not found';
    END IF;

    UPDATE users
    SET role_id = p_role_id
    WHERE id = p_user_id;
END$$


DROP PROCEDURE IF EXISTS sp_update_user_status$$

CREATE PROCEDURE sp_update_user_status(
    IN p_user_id INT UNSIGNED,
    IN p_status VARCHAR(20)
)
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM users WHERE id = p_user_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'User not found';
    END IF;

    IF p_status NOT IN ('active', 'inactive', 'suspended') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid user status';
    END IF;

    UPDATE users
    SET status = p_status
    WHERE id = p_user_id;
END$$


DROP PROCEDURE IF EXISTS sp_update_last_login$$

CREATE PROCEDURE sp_update_last_login(
    IN p_user_id INT UNSIGNED
)
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM users WHERE id = p_user_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'User not found';
    END IF;

    UPDATE users
    SET last_login_at = CURRENT_TIMESTAMP
    WHERE id = p_user_id;
END$$


/* ============================================================
   3. PERMISSIONS
   ============================================================ */

DROP PROCEDURE IF EXISTS sp_create_permission$$

CREATE PROCEDURE sp_create_permission(
    IN p_name VARCHAR(100),
    IN p_description VARCHAR(255)
)
BEGIN
    IF p_name IS NULL OR TRIM(p_name) = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Permission name cannot be empty';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM permissions
        WHERE name = TRIM(p_name)
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Permission already exists';
    END IF;

    INSERT INTO permissions (
        name,
        description
    )
    VALUES (
        TRIM(p_name),
        p_description
    );

    SELECT LAST_INSERT_ID() AS permission_id;
END$$


DROP PROCEDURE IF EXISTS sp_get_all_permissions$$

CREATE PROCEDURE sp_get_all_permissions()
BEGIN
    SELECT
        id,
        name,
        description,
        created_at
    FROM permissions
    ORDER BY name;
END$$


DROP PROCEDURE IF EXISTS sp_assign_permission_to_role$$

CREATE PROCEDURE sp_assign_permission_to_role(
    IN p_role_id INT UNSIGNED,
    IN p_permission_id INT UNSIGNED
)
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM roles WHERE id = p_role_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Role not found';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM permissions WHERE id = p_permission_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Permission not found';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM role_permissions
        WHERE role_id = p_role_id
          AND permission_id = p_permission_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Permission is already assigned to this role';
    END IF;

    INSERT INTO role_permissions (
        role_id,
        permission_id
    )
    VALUES (
        p_role_id,
        p_permission_id
    );
END$$


DROP PROCEDURE IF EXISTS sp_remove_permission_from_role$$

CREATE PROCEDURE sp_remove_permission_from_role(
    IN p_role_id INT UNSIGNED,
    IN p_permission_id INT UNSIGNED
)
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM role_permissions
        WHERE role_id = p_role_id
          AND permission_id = p_permission_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Permission is not assigned to this role';
    END IF;

    DELETE FROM role_permissions
    WHERE role_id = p_role_id
      AND permission_id = p_permission_id;
END$$


DROP PROCEDURE IF EXISTS sp_get_role_permissions$$

CREATE PROCEDURE sp_get_role_permissions(
    IN p_role_id INT UNSIGNED
)
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM roles WHERE id = p_role_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Role not found';
    END IF;

    SELECT
        p.id,
        p.name,
        p.description
    FROM permissions p
    INNER JOIN role_permissions rp
        ON rp.permission_id = p.id
    WHERE rp.role_id = p_role_id
    ORDER BY p.name;
END$$


/* ============================================================
   4. FOLDERS
   ============================================================ */

DROP PROCEDURE IF EXISTS sp_create_folder$$

CREATE PROCEDURE sp_create_folder(
    IN p_name VARCHAR(255),
    IN p_parent_id BIGINT UNSIGNED,
    IN p_owner_id INT UNSIGNED
)
BEGIN
    DECLARE v_folder_id BIGINT UNSIGNED;

    IF p_name IS NULL OR TRIM(p_name) = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Folder name cannot be empty';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM users WHERE id = p_owner_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Folder owner does not exist';
    END IF;

    IF p_parent_id IS NOT NULL THEN

        IF NOT EXISTS (
            SELECT 1
            FROM folders
            WHERE id = p_parent_id
              AND deleted_at IS NULL
        ) THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Parent folder not found';
        END IF;

    END IF;

    INSERT INTO folders (
        name,
        parent_id,
        owner_id
    )
    VALUES (
        TRIM(p_name),
        p_parent_id,
        p_owner_id
    );

    SET v_folder_id = LAST_INSERT_ID();

    SELECT v_folder_id AS folder_id;
END$$


DROP PROCEDURE IF EXISTS sp_get_folder_by_id$$

CREATE PROCEDURE sp_get_folder_by_id(
    IN p_folder_id BIGINT UNSIGNED
)
BEGIN
    SELECT
        f.id,
        f.name,
        f.parent_id,
        f.owner_id,
        u.display_name AS owner_name,
        u.email AS owner_email,
        f.created_at,
        f.updated_at,
        f.deleted_at
    FROM folders f
    INNER JOIN users u
        ON u.id = f.owner_id
    WHERE f.id = p_folder_id;
END$$


DROP PROCEDURE IF EXISTS sp_get_root_folders$$

CREATE PROCEDURE sp_get_root_folders(
    IN p_owner_id INT UNSIGNED
)
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM users WHERE id = p_owner_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'User not found';
    END IF;

    SELECT
        f.id,
        f.name,
        f.parent_id,
        f.owner_id,
        f.created_at,
        f.updated_at
    FROM folders f
    WHERE f.owner_id = p_owner_id
      AND f.parent_id IS NULL
      AND f.deleted_at IS NULL
    ORDER BY f.name;
END$$


DROP PROCEDURE IF EXISTS sp_get_subfolders$$

CREATE PROCEDURE sp_get_subfolders(
    IN p_parent_id BIGINT UNSIGNED
)
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM folders
        WHERE id = p_parent_id
          AND deleted_at IS NULL
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Parent folder not found';
    END IF;

    SELECT
        f.id,
        f.name,
        f.parent_id,
        f.owner_id,
        f.created_at,
        f.updated_at
    FROM folders f
    WHERE f.parent_id = p_parent_id
      AND f.deleted_at IS NULL
    ORDER BY f.name;
END$$


DROP PROCEDURE IF EXISTS sp_update_folder$$

CREATE PROCEDURE sp_update_folder(
    IN p_folder_id BIGINT UNSIGNED,
    IN p_name VARCHAR(255),
    IN p_parent_id BIGINT UNSIGNED
)
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM folders
        WHERE id = p_folder_id
          AND deleted_at IS NULL
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Folder not found';
    END IF;

    IF p_name IS NULL OR TRIM(p_name) = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Folder name cannot be empty';
    END IF;

    IF p_parent_id = p_folder_id THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'A folder cannot be its own parent';
    END IF;

    IF p_parent_id IS NOT NULL THEN

        IF NOT EXISTS (
            SELECT 1
            FROM folders
            WHERE id = p_parent_id
              AND deleted_at IS NULL
        ) THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Parent folder not found';
        END IF;

    END IF;

    UPDATE folders
    SET
        name = TRIM(p_name),
        parent_id = p_parent_id
    WHERE id = p_folder_id;
END$$


DROP PROCEDURE IF EXISTS sp_delete_folder$$

CREATE PROCEDURE sp_delete_folder(
    IN p_folder_id BIGINT UNSIGNED
)
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM folders
        WHERE id = p_folder_id
          AND deleted_at IS NULL
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Folder not found';
    END IF;

    /*
      Soft delete.
      The folder remains in the database for history/audit purposes.
    */

    UPDATE folders
    SET deleted_at = CURRENT_TIMESTAMP
    WHERE id = p_folder_id;
END$$


/* ============================================================
   5. FILES
   ============================================================ */

DROP PROCEDURE IF EXISTS sp_create_file$$

CREATE PROCEDURE sp_create_file(
    IN p_folder_id BIGINT UNSIGNED,
    IN p_owner_id INT UNSIGNED,
    IN p_original_name VARCHAR(255),
    IN p_stored_name VARCHAR(255),
    IN p_mime_type VARCHAR(150),
    IN p_file_size BIGINT UNSIGNED,
    IN p_s3_bucket VARCHAR(255),
    IN p_s3_key VARCHAR(768),
    IN p_checksum VARCHAR(128)
)
BEGIN
    DECLARE v_file_id BIGINT UNSIGNED;

    START TRANSACTION;

    IF p_original_name IS NULL OR TRIM(p_original_name) = '' THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Original file name cannot be empty';
    END IF;

    IF p_stored_name IS NULL OR TRIM(p_stored_name) = '' THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Stored file name cannot be empty';
    END IF;

    IF p_file_size IS NULL THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'File size is required';
    END IF;

    IF p_s3_bucket IS NULL OR TRIM(p_s3_bucket) = '' THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'S3 bucket cannot be empty';
    END IF;

    IF p_s3_key IS NULL OR TRIM(p_s3_key) = '' THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'S3 key cannot be empty';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM users WHERE id = p_owner_id
    ) THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'File owner does not exist';
    END IF;

    IF p_folder_id IS NOT NULL THEN

        IF NOT EXISTS (
            SELECT 1
            FROM folders
            WHERE id = p_folder_id
              AND deleted_at IS NULL
        ) THEN
            ROLLBACK;
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Folder not found';
        END IF;

    END IF;

    IF EXISTS (
        SELECT 1
        FROM files
        WHERE s3_key = TRIM(p_s3_key)
    ) THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'S3 key already exists';
    END IF;

    INSERT INTO files (
        folder_id,
        owner_id,
        original_name,
        stored_name,
        mime_type,
        file_size,
        s3_bucket,
        s3_key,
        current_version,
        checksum
    )
    VALUES (
        p_folder_id,
        p_owner_id,
        TRIM(p_original_name),
        TRIM(p_stored_name),
        p_mime_type,
        p_file_size,
        TRIM(p_s3_bucket),
        TRIM(p_s3_key),
        1,
        p_checksum
    );

    SET v_file_id = LAST_INSERT_ID();

    /*
      The initial upload is also version 1.
    */

    INSERT INTO file_versions (
        file_id,
        version_number,
        s3_key,
        file_size,
        checksum,
        uploaded_by
    )
    VALUES (
        v_file_id,
        1,
        TRIM(p_s3_key),
        p_file_size,
        p_checksum,
        p_owner_id
    );

    COMMIT;

    SELECT v_file_id AS file_id;
END$$


DROP PROCEDURE IF EXISTS sp_get_file_by_id$$

CREATE PROCEDURE sp_get_file_by_id(
    IN p_file_id BIGINT UNSIGNED
)
BEGIN
    SELECT
        f.id,
        f.folder_id,
        f.owner_id,
        u.display_name AS owner_name,
        u.email AS owner_email,
        f.original_name,
        f.stored_name,
        f.mime_type,
        f.file_size,
        f.s3_bucket,
        f.s3_key,
        f.current_version,
        f.checksum,
        f.status,
        f.created_at,
        f.updated_at,
        f.deleted_at
    FROM files f
    INNER JOIN users u
        ON u.id = f.owner_id
    WHERE f.id = p_file_id;
END$$


DROP PROCEDURE IF EXISTS sp_get_folder_files$$

CREATE PROCEDURE sp_get_folder_files(
    IN p_folder_id BIGINT UNSIGNED
)
BEGIN
    IF p_folder_id IS NOT NULL THEN

        IF NOT EXISTS (
            SELECT 1
            FROM folders
            WHERE id = p_folder_id
              AND deleted_at IS NULL
        ) THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Folder not found';
        END IF;

    END IF;

    SELECT
        f.id,
        f.folder_id,
        f.owner_id,
        f.original_name,
        f.stored_name,
        f.mime_type,
        f.file_size,
        f.current_version,
        f.checksum,
        f.status,
        f.created_at,
        f.updated_at
    FROM files f
    WHERE
        (
            p_folder_id IS NULL
            OR f.folder_id = p_folder_id
        )
        AND f.deleted_at IS NULL
        AND f.status <> 'deleted'
    ORDER BY f.updated_at DESC;
END$$


DROP PROCEDURE IF EXISTS sp_update_file$$

CREATE PROCEDURE sp_update_file(
    IN p_file_id BIGINT UNSIGNED,
    IN p_original_name VARCHAR(255),
    IN p_folder_id BIGINT UNSIGNED,
    IN p_status VARCHAR(20)
)
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM files
        WHERE id = p_file_id
          AND deleted_at IS NULL
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'File not found';
    END IF;

    IF p_original_name IS NULL OR TRIM(p_original_name) = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'File name cannot be empty';
    END IF;

    IF p_status NOT IN ('active', 'archived', 'deleted') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid file status';
    END IF;

    IF p_folder_id IS NOT NULL THEN

        IF NOT EXISTS (
            SELECT 1
            FROM folders
            WHERE id = p_folder_id
              AND deleted_at IS NULL
        ) THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Folder not found';
        END IF;

    END IF;

    UPDATE files
    SET
        original_name = TRIM(p_original_name),
        folder_id = p_folder_id,
        status = p_status
    WHERE id = p_file_id;
END$$


DROP PROCEDURE IF EXISTS sp_delete_file$$

CREATE PROCEDURE sp_delete_file(
    IN p_file_id BIGINT UNSIGNED
)
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM files
        WHERE id = p_file_id
          AND deleted_at IS NULL
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'File not found';
    END IF;

    /*
      Soft delete.
      The physical S3 object should be handled by Node.js.
    */

    UPDATE files
    SET
        status = 'deleted',
        deleted_at = CURRENT_TIMESTAMP
    WHERE id = p_file_id;
END$$


/* ============================================================
   6. FILE VERSIONS
   ============================================================ */

DROP PROCEDURE IF EXISTS sp_create_file_version$$

CREATE PROCEDURE sp_create_file_version(
    IN p_file_id BIGINT UNSIGNED,
    IN p_s3_key VARCHAR(768),
    IN p_file_size BIGINT UNSIGNED,
    IN p_checksum VARCHAR(128),
    IN p_uploaded_by INT UNSIGNED
)
BEGIN
    DECLARE v_current_version INT UNSIGNED;
    DECLARE v_new_version INT UNSIGNED;

    START TRANSACTION;

    IF NOT EXISTS (
        SELECT 1
        FROM files
        WHERE id = p_file_id
          AND deleted_at IS NULL
    ) THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'File not found';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM users
        WHERE id = p_uploaded_by
          AND status = 'active'
    ) THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Uploader does not exist or is inactive';
    END IF;

    IF p_s3_key IS NULL OR TRIM(p_s3_key) = '' THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'S3 key cannot be empty';
    END IF;

    IF p_file_size IS NULL THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'File size is required';
    END IF;

    SELECT current_version
    INTO v_current_version
    FROM files
    WHERE id = p_file_id
    FOR UPDATE;

    SET v_new_version = v_current_version + 1;

    IF EXISTS (
        SELECT 1
        FROM file_versions
        WHERE s3_key = TRIM(p_s3_key)
    ) THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'S3 key already exists';
    END IF;

    INSERT INTO file_versions (
        file_id,
        version_number,
        s3_key,
        file_size,
        checksum,
        uploaded_by
    )
    VALUES (
        p_file_id,
        v_new_version,
        TRIM(p_s3_key),
        p_file_size,
        p_checksum,
        p_uploaded_by
    );

    UPDATE files
    SET
        current_version = v_new_version,
        s3_key = TRIM(p_s3_key),
        file_size = p_file_size,
        checksum = p_checksum
    WHERE id = p_file_id;

    COMMIT;

    SELECT v_new_version AS version_number;
END$$


DROP PROCEDURE IF EXISTS sp_get_file_versions$$

CREATE PROCEDURE sp_get_file_versions(
    IN p_file_id BIGINT UNSIGNED
)
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM files
        WHERE id = p_file_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'File not found';
    END IF;

    SELECT
        fv.id,
        fv.file_id,
        fv.version_number,
        fv.s3_key,
        fv.file_size,
        fv.checksum,
        fv.uploaded_by,
        u.display_name AS uploaded_by_name,
        u.email AS uploaded_by_email,
        fv.created_at
    FROM file_versions fv
    INNER JOIN users u
        ON u.id = fv.uploaded_by
    WHERE fv.file_id = p_file_id
    ORDER BY fv.version_number DESC;
END$$


/* ============================================================
   7. SHARE PERMISSIONS
   ============================================================ */

DROP PROCEDURE IF EXISTS sp_create_share_permission$$

CREATE PROCEDURE sp_create_share_permission(
    IN p_name VARCHAR(50),
    IN p_description VARCHAR(255)
)
BEGIN
    IF p_name IS NULL OR TRIM(p_name) = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Share permission name cannot be empty';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM share_permissions
        WHERE name = TRIM(p_name)
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Share permission already exists';
    END IF;

    INSERT INTO share_permissions (
        name,
        description
    )
    VALUES (
        TRIM(p_name),
        p_description
    );

    SELECT LAST_INSERT_ID() AS permission_id;
END$$


DROP PROCEDURE IF EXISTS sp_get_share_permissions$$

CREATE PROCEDURE sp_get_share_permissions()
BEGIN
    SELECT
        id,
        name,
        description,
        created_at
    FROM share_permissions
    ORDER BY name;
END$$


/* ============================================================
   8. FOLDER SHARING
   ============================================================ */

DROP PROCEDURE IF EXISTS sp_share_folder$$

CREATE PROCEDURE sp_share_folder(
    IN p_folder_id BIGINT UNSIGNED,
    IN p_user_id INT UNSIGNED,
    IN p_permission_id INT UNSIGNED,
    IN p_shared_by INT UNSIGNED,
    IN p_expires_at TIMESTAMP
)
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM folders
        WHERE id = p_folder_id
          AND deleted_at IS NULL
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Folder not found';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM users
        WHERE id = p_user_id
          AND status = 'active'
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Target user does not exist or is inactive';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM users WHERE id = p_shared_by
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Sharing user does not exist';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM share_permissions
        WHERE id = p_permission_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Share permission not found';
    END IF;

    IF p_expires_at IS NOT NULL
       AND p_expires_at <= CURRENT_TIMESTAMP THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Expiration date must be in the future';
    END IF;

    /*
      If the folder is already shared with this user,
      update the existing share instead of creating a duplicate.
    */

    INSERT INTO folder_shares (
        folder_id,
        user_id,
        permission_id,
        shared_by,
        expires_at
    )
    VALUES (
        p_folder_id,
        p_user_id,
        p_permission_id,
        p_shared_by,
        p_expires_at
    )
    ON DUPLICATE KEY UPDATE
        permission_id = VALUES(permission_id),
        shared_by = VALUES(shared_by),
        expires_at = VALUES(expires_at);
END$$


DROP PROCEDURE IF EXISTS sp_remove_folder_share$$

CREATE PROCEDURE sp_remove_folder_share(
    IN p_folder_id BIGINT UNSIGNED,
    IN p_user_id INT UNSIGNED
)
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM folder_shares
        WHERE folder_id = p_folder_id
          AND user_id = p_user_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Folder share not found';
    END IF;

    DELETE FROM folder_shares
    WHERE folder_id = p_folder_id
      AND user_id = p_user_id;
END$$


DROP PROCEDURE IF EXISTS sp_get_folder_shares$$

CREATE PROCEDURE sp_get_folder_shares(
    IN p_folder_id BIGINT UNSIGNED
)
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM folders
        WHERE id = p_folder_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Folder not found';
    END IF;

    SELECT
        fs.id,
        fs.folder_id,
        fs.user_id,
        u.display_name AS user_name,
        u.email AS user_email,
        fs.permission_id,
        sp.name AS permission_name,
        fs.shared_by,
        sb.display_name AS shared_by_name,
        fs.expires_at,
        fs.created_at
    FROM folder_shares fs
    INNER JOIN users u
        ON u.id = fs.user_id
    INNER JOIN share_permissions sp
        ON sp.id = fs.permission_id
    INNER JOIN users sb
        ON sb.id = fs.shared_by
    WHERE fs.folder_id = p_folder_id
    ORDER BY fs.created_at DESC;
END$$


/* ============================================================
   9. FILE SHARING
   ============================================================ */

DROP PROCEDURE IF EXISTS sp_share_file$$

CREATE PROCEDURE sp_share_file(
    IN p_file_id BIGINT UNSIGNED,
    IN p_user_id INT UNSIGNED,
    IN p_permission_id INT UNSIGNED,
    IN p_shared_by INT UNSIGNED,
    IN p_expires_at TIMESTAMP
)
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM files
        WHERE id = p_file_id
          AND deleted_at IS NULL
          AND status <> 'deleted'
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'File not found';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM users
        WHERE id = p_user_id
          AND status = 'active'
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Target user does not exist or is inactive';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM users
        WHERE id = p_shared_by
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Sharing user does not exist';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM share_permissions
        WHERE id = p_permission_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Share permission not found';
    END IF;

    IF p_expires_at IS NOT NULL
       AND p_expires_at <= CURRENT_TIMESTAMP THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Expiration date must be in the future';
    END IF;

    INSERT INTO file_shares (
        file_id,
        user_id,
        permission_id,
        shared_by,
        expires_at
    )
    VALUES (
        p_file_id,
        p_user_id,
        p_permission_id,
        p_shared_by,
        p_expires_at
    )
    ON DUPLICATE KEY UPDATE
        permission_id = VALUES(permission_id),
        shared_by = VALUES(shared_by),
        expires_at = VALUES(expires_at);
END$$


DROP PROCEDURE IF EXISTS sp_remove_file_share$$

CREATE PROCEDURE sp_remove_file_share(
    IN p_file_id BIGINT UNSIGNED,
    IN p_user_id INT UNSIGNED
)
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM file_shares
        WHERE file_id = p_file_id
          AND user_id = p_user_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'File share not found';
    END IF;

    DELETE FROM file_shares
    WHERE file_id = p_file_id
      AND user_id = p_user_id;
END$$


DROP PROCEDURE IF EXISTS sp_get_file_shares$$

CREATE PROCEDURE sp_get_file_shares(
    IN p_file_id BIGINT UNSIGNED
)
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM files
        WHERE id = p_file_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'File not found';
    END IF;

    SELECT
        fs.id,
        fs.file_id,
        fs.user_id,
        u.display_name AS user_name,
        u.email AS user_email,
        fs.permission_id,
        sp.name AS permission_name,
        fs.shared_by,
        sb.display_name AS shared_by_name,
        fs.expires_at,
        fs.created_at
    FROM file_shares fs
    INNER JOIN users u
        ON u.id = fs.user_id
    INNER JOIN share_permissions sp
        ON sp.id = fs.permission_id
    INNER JOIN users sb
        ON sb.id = fs.shared_by
    WHERE fs.file_id = p_file_id
    ORDER BY fs.created_at DESC;
END$$


/* ============================================================
   10. AUDIT LOGS
   ============================================================ */

DROP PROCEDURE IF EXISTS sp_create_audit_log$$

CREATE PROCEDURE sp_create_audit_log(
    IN p_user_id INT UNSIGNED,
    IN p_action VARCHAR(100),
    IN p_resource_type VARCHAR(50),
    IN p_resource_id BIGINT UNSIGNED,
    IN p_description TEXT,
    IN p_ip_address VARCHAR(45),
    IN p_user_agent TEXT
)
BEGIN
    IF p_action IS NULL OR TRIM(p_action) = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Audit action cannot be empty';
    END IF;

    IF p_user_id IS NOT NULL THEN

        IF NOT EXISTS (
            SELECT 1 FROM users WHERE id = p_user_id
        ) THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Audit user does not exist';
        END IF;

    END IF;

    INSERT INTO audit_logs (
        user_id,
        action,
        resource_type,
        resource_id,
        description,
        ip_address,
        user_agent
    )
    VALUES (
        p_user_id,
        TRIM(p_action),
        p_resource_type,
        p_resource_id,
        p_description,
        p_ip_address,
        p_user_agent
    );

    SELECT LAST_INSERT_ID() AS audit_log_id;
END$$


DROP PROCEDURE IF EXISTS sp_get_user_audit_logs$$

CREATE PROCEDURE sp_get_user_audit_logs(
    IN p_user_id INT UNSIGNED
)
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM users WHERE id = p_user_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'User not found';
    END IF;

    SELECT
        al.id,
        al.user_id,
        al.action,
        al.resource_type,
        al.resource_id,
        al.description,
        al.ip_address,
        al.user_agent,
        al.created_at
    FROM audit_logs al
    WHERE al.user_id = p_user_id
    ORDER BY al.created_at DESC;
END$$


DROP PROCEDURE IF EXISTS sp_get_all_audit_logs$$

CREATE PROCEDURE sp_get_all_audit_logs()
BEGIN
    SELECT
        al.id,
        al.user_id,
        u.display_name AS user_name,
        u.email AS user_email,
        al.action,
        al.resource_type,
        al.resource_id,
        al.description,
        al.ip_address,
        al.user_agent,
        al.created_at
    FROM audit_logs al
    LEFT JOIN users u
        ON u.id = al.user_id
    ORDER BY al.created_at DESC;
END$$


/* ============================================================
   11. NOTIFICATIONS
   ============================================================ */

DROP PROCEDURE IF EXISTS sp_create_notification$$

CREATE PROCEDURE sp_create_notification(
    IN p_user_id INT UNSIGNED,
    IN p_type VARCHAR(50),
    IN p_title VARCHAR(255),
    IN p_message TEXT,
    IN p_resource_type VARCHAR(50),
    IN p_resource_id BIGINT UNSIGNED
)
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM users
        WHERE id = p_user_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Notification user not found';
    END IF;

    IF p_type IS NULL OR TRIM(p_type) = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Notification type cannot be empty';
    END IF;

    IF p_title IS NULL OR TRIM(p_title) = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Notification title cannot be empty';
    END IF;

    IF p_message IS NULL OR TRIM(p_message) = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Notification message cannot be empty';
    END IF;

    INSERT INTO notifications (
        user_id,
        type,
        title,
        message,
        resource_type,
        resource_id
    )
    VALUES (
        p_user_id,
        TRIM(p_type),
        TRIM(p_title),
        p_message,
        p_resource_type,
        p_resource_id
    );

    SELECT LAST_INSERT_ID() AS notification_id;
END$$


DROP PROCEDURE IF EXISTS sp_get_user_notifications$$

CREATE PROCEDURE sp_get_user_notifications(
    IN p_user_id INT UNSIGNED
)
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM users WHERE id = p_user_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'User not found';
    END IF;

    SELECT
        id,
        user_id,
        type,
        title,
        message,
        resource_type,
        resource_id,
        is_read,
        created_at
    FROM notifications
    WHERE user_id = p_user_id
    ORDER BY created_at DESC;
END$$


DROP PROCEDURE IF EXISTS sp_mark_notification_read$$

CREATE PROCEDURE sp_mark_notification_read(
    IN p_notification_id BIGINT UNSIGNED,
    IN p_user_id INT UNSIGNED
)
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM notifications
        WHERE id = p_notification_id
          AND user_id = p_user_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Notification not found for this user';
    END IF;

    UPDATE notifications
    SET is_read = TRUE
    WHERE id = p_notification_id
      AND user_id = p_user_id;
END$$


DROP PROCEDURE IF EXISTS sp_mark_all_notifications_read$$

CREATE PROCEDURE sp_mark_all_notifications_read(
    IN p_user_id INT UNSIGNED
)
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM users WHERE id = p_user_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'User not found';
    END IF;

    UPDATE notifications
    SET is_read = TRUE
    WHERE user_id = p_user_id
      AND is_read = FALSE;
END$$


/* ============================================================
   12. SHARED FILES / FOLDERS FOR A USER
   Useful for "Shared With Me" screen
   ============================================================ */

DROP PROCEDURE IF EXISTS sp_get_shared_folders_for_user$$

CREATE PROCEDURE sp_get_shared_folders_for_user(
    IN p_user_id INT UNSIGNED
)
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM users WHERE id = p_user_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'User not found';
    END IF;

    SELECT
        fs.id AS share_id,
        f.id AS folder_id,
        f.name AS folder_name,
        f.parent_id,
        f.owner_id,
        owner_user.display_name AS owner_name,
        fs.permission_id,
        sp.name AS permission_name,
        fs.shared_by,
        sharer.display_name AS shared_by_name,
        fs.expires_at,
        fs.created_at
    FROM folder_shares fs
    INNER JOIN folders f
        ON f.id = fs.folder_id
    INNER JOIN users owner_user
        ON owner_user.id = f.owner_id
    INNER JOIN users sharer
        ON sharer.id = fs.shared_by
    INNER JOIN share_permissions sp
        ON sp.id = fs.permission_id
    WHERE fs.user_id = p_user_id
      AND f.deleted_at IS NULL
      AND (
          fs.expires_at IS NULL
          OR fs.expires_at > CURRENT_TIMESTAMP
      )
    ORDER BY fs.created_at DESC;
END$$


DROP PROCEDURE IF EXISTS sp_get_shared_files_for_user$$

CREATE PROCEDURE sp_get_shared_files_for_user(
    IN p_user_id INT UNSIGNED
)
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM users WHERE id = p_user_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'User not found';
    END IF;

    SELECT
        fs.id AS share_id,
        f.id AS file_id,
        f.original_name,
        f.folder_id,
        f.owner_id,
        owner_user.display_name AS owner_name,
        f.mime_type,
        f.file_size,
        f.current_version,
        f.status,
        fs.permission_id,
        sp.name AS permission_name,
        fs.shared_by,
        sharer.display_name AS shared_by_name,
        fs.expires_at,
        fs.created_at
    FROM file_shares fs
    INNER JOIN files f
        ON f.id = fs.file_id
    INNER JOIN users owner_user
        ON owner_user.id = f.owner_id
    INNER JOIN users sharer
        ON sharer.id = fs.shared_by
    INNER JOIN share_permissions sp
        ON sp.id = fs.permission_id
    WHERE fs.user_id = p_user_id
      AND f.deleted_at IS NULL
      AND f.status <> 'deleted'
      AND (
          fs.expires_at IS NULL
          OR fs.expires_at > CURRENT_TIMESTAMP
      )
    ORDER BY fs.created_at DESC;
END$$


/* ============================================================
   13. DASHBOARD / STATISTICS
   ============================================================ */

DROP PROCEDURE IF EXISTS sp_get_user_storage_summary$$

CREATE PROCEDURE sp_get_user_storage_summary(
    IN p_user_id INT UNSIGNED
)
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM users WHERE id = p_user_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'User not found';
    END IF;

    SELECT
        p_user_id AS user_id,

        (
            SELECT COUNT(*)
            FROM folders
            WHERE owner_id = p_user_id
              AND deleted_at IS NULL
        ) AS folder_count,

        (
            SELECT COUNT(*)
            FROM files
            WHERE owner_id = p_user_id
              AND deleted_at IS NULL
              AND status <> 'deleted'
        ) AS file_count,

        (
            SELECT COALESCE(SUM(file_size), 0)
            FROM files
            WHERE owner_id = p_user_id
              AND deleted_at IS NULL
              AND status <> 'deleted'
        ) AS total_storage_bytes,

        (
            SELECT COUNT(*)
            FROM file_shares
            WHERE user_id = p_user_id
              AND (
                  expires_at IS NULL
                  OR expires_at > CURRENT_TIMESTAMP
              )
        ) AS shared_file_count,

        (
            SELECT COUNT(*)
            FROM folder_shares
            WHERE user_id = p_user_id
              AND (
                  expires_at IS NULL
                  OR expires_at > CURRENT_TIMESTAMP
              )
        ) AS shared_folder_count,

        (
            SELECT COUNT(*)
            FROM notifications
            WHERE user_id = p_user_id
              AND is_read = FALSE
        ) AS unread_notification_count;
END$$


/* ============================================================
   FINISH
   ============================================================ */

DELIMITER ;