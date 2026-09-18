require('dotenv').config();

const email = process.env.TEST_FIREBASE_EMAIL;
const password = process.env.TEST_FIREBASE_PASSWORD;
const apiKey = process.env.FIREBASE_WEB_API_KEY;

async function getFirebaseToken() {
    try {
        const response = await fetch(
            `https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${apiKey}`,
            {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    email,
                    password,
                    returnSecureToken: true
                })
            }
        );

        const data = await response.json();

        if (!response.ok) {
            console.error('Firebase login failed:');
            console.error(data);
            process.exit(1);
        }

        console.log('');
        console.log('Firebase ID Token:');
        console.log('');
        console.log(data.idToken);
        console.log('');
    } catch (error) {
        console.error('Error connecting to Firebase:');
        console.error(error.message);
        process.exit(1);
    }
}

getFirebaseToken();