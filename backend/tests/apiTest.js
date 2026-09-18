
require('dotenv').config();

const BASE_URL = `http://localhost:${process.env.PORT || 3000}`;
const TEST_TOKEN = process.env.TEST_FIREBASE_TOKEN;

let testRoleId = null;
let testPermissionId = null;
let testUserId = null;
let testFolderId = null;
let testFileId = null;
let testSharePermissionId = null;

let passed = 0;
let failed = 0;


const request = async (method, path, body = null, authenticated = true) => {
    const headers = {
        'Content-Type': 'application/json'
    };

    if (authenticated && TEST_TOKEN) {
        headers.Authorization = `Bearer ${TEST_TOKEN}`;
    }

    const response = await fetch(`${BASE_URL}${path}`, {
        method,
        headers,
        body: body ? JSON.stringify(body) : undefined
    });

    let data;

    try {
        data = await response.json();
    } catch {
        data = {};
    }

    return {
        status: response.status,
        data
    };
};


const test = async (name, callback) => {
    try {
        await callback();

        console.log(`✓ ${name}`);
        passed++;
    } catch (error) {
        console.log(`✗ ${name}`);
        console.log(`  ${error.message}`);
        failed++;
    }
};


const expectStatus = (response, expected) => {
    if (response.status !== expected) {
        throw new Error(
            `Expected status ${expected}, received ${response.status}. Response: ${JSON.stringify(response.data)}`
        );
    }
};


const expectSuccess = (response) => {
    if (response.status < 200 || response.status >= 300) {
        throw new Error(
            `Request failed with status ${response.status}. Response: ${JSON.stringify(response.data)}`
        );
    }
};


const getId = (data, possibleNames) => {
    for (const name of possibleNames) {
        if (data?.[name] !== undefined && data?.[name] !== null) {
            return data[name];
        }

        if (data?.result?.[name] !== undefined && data?.result?.[name] !== null) {
            return data.result[name];
        }

        if (data?.user?.[name] !== undefined && data?.user?.[name] !== null) {
            return data.user[name];
        }

        if (data?.role?.[name] !== undefined && data?.role?.[name] !== null) {
            return data.role[name];
        }

        if (data?.permission?.[name] !== undefined && data?.permission?.[name] !== null) {
            return data.permission[name];
        }

        if (data?.folder?.[name] !== undefined && data?.folder?.[name] !== null) {
            return data.folder[name];
        }

        if (data?.file?.[name] !== undefined && data?.file?.[name] !== null) {
            return data.file[name];
        }
    }

    return null;
};


const runTests = async () => {
    console.log('');
    console.log('======================================');
    console.log(' Secure Document Manager API Tests');
    console.log('======================================');
    console.log(`Base URL: ${BASE_URL}`);
    console.log('');


    await test('Server is running', async () => {
        const response = await request(
            'GET',
            '/',
            null,
            false
        );

        expectStatus(response, 200);
    });


    await test('MySQL connection', async () => {
        const response = await request(
            'GET',
            '/db-test',
            null,
            false
        );

        expectStatus(response, 200);

        if (!response.data.success) {
            throw new Error('Database test did not return success');
        }
    });


    if (!TEST_TOKEN) {
        console.log('');
        console.log('⚠ TEST_FIREBASE_TOKEN is not configured.');
        console.log('Protected API tests will be skipped.');
        console.log('');
    } else {

        await test('Firebase authentication', async () => {
            const response = await request(
                'GET',
                '/api/auth/me'
            );

            expectStatus(response, 200);

            if (!response.data.success) {
                throw new Error(
                    'Authentication was not successful'
                );
            }
        });


        await test('Get all roles', async () => {
            const response = await request(
                'GET',
                '/api/roles'
            );

            expectSuccess(response);
        });


        await test('Create test role', async () => {
            const response = await request(
                'POST',
                '/api/roles',
                {
                    name: `API Test Role ${Date.now()}`,
                    description: 'Temporary role created by automated API test'
                }
            );

            expectSuccess(response);

            testRoleId = getId(response.data, [
                'role_id',
                'roleId',
                'id'
            ]);

            if (!testRoleId) {
                throw new Error(
                    `Could not find role ID in response: ${JSON.stringify(response.data)}`
                );
            }
        });


        await test('Get all permissions', async () => {
            const response = await request(
                'GET',
                '/api/permissions'
            );

            expectSuccess(response);
        });


        await test('Create test permission', async () => {
            const response = await request(
                'POST',
                '/api/permissions',
                {
                    name: `api_test_permission_${Date.now()}`,
                    description: 'Temporary permission created by automated API test'
                }
            );

            expectSuccess(response);

            testPermissionId = getId(response.data, [
                'permission_id',
                'permissionId',
                'id'
            ]);

            if (!testPermissionId) {
                throw new Error(
                    `Could not find permission ID in response: ${JSON.stringify(response.data)}`
                );
            }
        });


        await test('Assign permission to role', async () => {
            if (!testRoleId || !testPermissionId) {
                throw new Error(
                    'Role or permission ID is missing'
                );
            }

            /*
             * Check whether the permission is already assigned
             * to the test role.
             */
            const permissionsResponse = await request(
                'GET',
                `/api/permissions/role/${testRoleId}`
            );

            expectSuccess(permissionsResponse);

            const permissions =
                permissionsResponse.data.permissions || [];

            const alreadyAssigned = permissions.some((permission) => {
                const permissionId =
                    permission.permission_id ??
                    permission.permissionId ??
                    permission.id;

                return Number(permissionId) === Number(testPermissionId);
            });


            /*
             * If the relationship already exists,
             * remove it first so that we can properly
             * test the assignment endpoint.
             */
            if (alreadyAssigned) {
                const removeResponse = await request(
                    'DELETE',
                    `/api/permissions/role/${testRoleId}/${testPermissionId}`
                );

                expectSuccess(removeResponse);
            }


            /*
             * Now test the actual assignment.
             */
            const response = await request(
                'POST',
                `/api/permissions/role/${testRoleId}`,
                {
                    permissionId: testPermissionId
                }
            );

            expectSuccess(response);
        });


        await test('Get role permissions', async () => {
            if (!testRoleId) {
                throw new Error(
                    'Role ID is missing'
                );
            }

            const response = await request(
                'GET',
                `/api/permissions/role/${testRoleId}`
            );

            expectSuccess(response);
        });


        await test('Create test user', async () => {
            if (!testRoleId) {
                throw new Error(
                    'Role ID is missing'
                );
            }

            const timestamp = Date.now();

            const response = await request(
                'POST',
                '/api/users',
                {
                    firebaseUid: `api-test-${timestamp}`,
                    email: `api-test-${timestamp}@example.com`,
                    firstName: 'API',
                    lastName: 'Test',
                    displayName: 'API Test User',
                    profileImage: null,
                    roleId: testRoleId
                }
            );

            expectSuccess(response);

            testUserId = getId(response.data, [
                'user_id',
                'userId',
                'id'
            ]);

            if (!testUserId) {
                throw new Error(
                    `Could not find user ID in response: ${JSON.stringify(response.data)}`
                );
            }
        });


        await test('Get all users', async () => {
            const response = await request(
                'GET',
                '/api/users'
            );

            expectSuccess(response);
        });


        await test('Get test user', async () => {
            if (!testUserId) {
                throw new Error(
                    'User ID is missing'
                );
            }

            const response = await request(
                'GET',
                `/api/users/${testUserId}`
            );

            expectSuccess(response);
        });


        await test('Create root folder', async () => {
            if (!testUserId) {
                throw new Error(
                    'User ID is missing'
                );
            }

            const response = await request(
                'POST',
                '/api/folders',
                {
                    name: `API Test Folder ${Date.now()}`,
                    parentId: null,
                    ownerId: testUserId
                }
            );

            expectSuccess(response);

            testFolderId = getId(response.data, [
                'folder_id',
                'folderId',
                'id'
            ]);

            if (!testFolderId) {
                throw new Error(
                    `Could not find folder ID in response: ${JSON.stringify(response.data)}`
                );
            }
        });


        await test('Get root folders', async () => {
            if (!testUserId) {
                throw new Error(
                    'User ID is missing'
                );
            }

            const response = await request(
                'GET',
                `/api/folders/root?ownerId=${testUserId}`
            );

            expectSuccess(response);
        });


        await test('Get folder by ID', async () => {
            if (!testFolderId) {
                throw new Error(
                    'Folder ID is missing'
                );
            }

            const response = await request(
                'GET',
                `/api/folders/${testFolderId}`
            );

            expectSuccess(response);
        });


        await test('Create file metadata', async () => {
            if (!testFolderId || !testUserId) {
                throw new Error(
                    'Folder ID or user ID is missing'
                );
            }

            const timestamp = Date.now();

            const response = await request(
                'POST',
                '/api/files',
                {
                    folderId: testFolderId,
                    ownerId: testUserId,
                    originalName: 'api-test.txt',
                    storedName: `api-test-${timestamp}.txt`,
                    mimeType: 'text/plain',
                    fileSize: 100,
                    s3Bucket: 'test-bucket',
                    s3Key: `api-tests/${timestamp}/api-test.txt`,
                    checksum: 'api-test-checksum'
                }
            );

            expectSuccess(response);

            testFileId = getId(response.data, [
                'file_id',
                'fileId',
                'id'
            ]);

            if (!testFileId) {
                throw new Error(
                    `Could not find file ID in response: ${JSON.stringify(response.data)}`
                );
            }
        });


        await test('Get folder files', async () => {
            if (!testFolderId) {
                throw new Error(
                    'Folder ID is missing'
                );
            }

            const response = await request(
                'GET',
                `/api/files/folder/${testFolderId}`
            );

            expectSuccess(response);
        });


        await test('Get file by ID', async () => {
            if (!testFileId) {
                throw new Error(
                    'File ID is missing'
                );
            }

            const response = await request(
                'GET',
                `/api/files/${testFileId}`
            );

            expectSuccess(response);
        });


        await test('Create file version', async () => {
            if (!testFileId || !testUserId) {
                throw new Error(
                    'File ID or user ID is missing'
                );
            }

            const response = await request(
                'POST',
                '/api/file-versions',
                {
                    fileId: testFileId,
                    s3Key: `api-tests/${Date.now()}/version-2.txt`,
                    fileSize: 150,
                    checksum: 'api-test-version-checksum',
                    uploadedBy: testUserId
                }
            );

            expectSuccess(response);
        });


        await test('Get file versions', async () => {
            if (!testFileId) {
                throw new Error(
                    'File ID is missing'
                );
            }

            const response = await request(
                'GET',
                `/api/file-versions/file/${testFileId}`
            );

            expectSuccess(response);
        });


        await test('Get share permissions', async () => {
            const response = await request(
                'GET',
                '/api/share-permissions'
            );

            expectSuccess(response);
        });


        await test('Create share permission', async () => {
            const response = await request(
                'POST',
                '/api/share-permissions',
                {
                    name: `api_test_share_${Date.now()}`,
                    description: 'Temporary share permission for API test'
                }
            );

            expectSuccess(response);

            testSharePermissionId = getId(response.data, [
                'permission_id',
                'permissionId',
                'id'
            ]);

            if (!testSharePermissionId) {
                throw new Error(
                    `Could not find share permission ID in response: ${JSON.stringify(response.data)}`
                );
            }
        });


        await test('Get folder shares', async () => {
            if (!testFolderId) {
                throw new Error(
                    'Folder ID is missing'
                );
            }

            const response = await request(
                'GET',
                `/api/folder-shares/folder/${testFolderId}`
            );

            expectSuccess(response);
        });


        await test('Get file shares', async () => {
            if (!testFileId) {
                throw new Error(
                    'File ID is missing'
                );
            }

            const response = await request(
                'GET',
                `/api/file-shares/file/${testFileId}`
            );

            expectSuccess(response);
        });


        await test('Create audit log', async () => {
            if (!testUserId) {
                throw new Error(
                    'User ID is missing'
                );
            }

            const response = await request(
                'POST',
                '/api/audit-logs',
                {
                    userId: testUserId,
                    action: 'API_TEST',
                    resourceType: 'test',
                    resourceId: testFileId,
                    description: 'Automated API test',
                    ipAddress: '127.0.0.1',
                    userAgent: 'Node API Test'
                }
            );

            expectSuccess(response);
        });


        await test('Get user audit logs', async () => {
            if (!testUserId) {
                throw new Error(
                    'User ID is missing'
                );
            }

            const response = await request(
                'GET',
                `/api/audit-logs/user/${testUserId}`
            );

            expectSuccess(response);
        });


        await test('Get all audit logs', async () => {
            const response = await request(
                'GET',
                '/api/audit-logs'
            );

            expectSuccess(response);
        });


        await test('Create notification', async () => {
            if (!testUserId) {
                throw new Error(
                    'User ID is missing'
                );
            }

            const response = await request(
                'POST',
                '/api/notifications',
                {
                    userId: testUserId,
                    type: 'API_TEST',
                    title: 'API Test',
                    message: 'Automated API test notification',
                    resourceType: 'file',
                    resourceId: testFileId
                }
            );

            expectSuccess(response);
        });


        await test('Get user notifications', async () => {
            if (!testUserId) {
                throw new Error(
                    'User ID is missing'
                );
            }

            const response = await request(
                'GET',
                `/api/notifications/user/${testUserId}`
            );

            expectSuccess(response);
        });


        await test('Get dashboard storage summary', async () => {
            if (!testUserId) {
                throw new Error(
                    'User ID is missing'
                );
            }

            const response = await request(
                'GET',
                `/api/dashboard/storage/${testUserId}`
            );

            expectSuccess(response);
        });
    }


    console.log('');
    console.log('======================================');
    console.log(' Test Results');
    console.log('======================================');
    console.log(`Passed: ${passed}`);
    console.log(`Failed: ${failed}`);
    console.log('======================================');
    console.log('');


    if (failed > 0) {
        process.exitCode = 1;
    }
};


runTests().catch((error) => {
    console.error('');
    console.error('Test runner crashed:');
    console.error(error);
    process.exitCode = 1;
});
