
const nodemailer = require('nodemailer');

const transporter = nodemailer.createTransport({
    host: process.env.EMAIL_HOST,
    port: Number(process.env.EMAIL_PORT),
    secure: process.env.EMAIL_SECURE === 'true',
    auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASSWORD
    }
});

const sendVerificationEmail = async ({
    email,
    verificationCode
}) => {
    await transporter.sendMail({
        from: `"Secure Document Manager" <${process.env.EMAIL_USER}>`,
        to: email,
        subject: 'Verify your email address',
        text: `Your Secure Document Manager verification code is ${verificationCode}. This code will expire in 5 minutes.`,
        html: `
            <div style="
                font-family: Arial, sans-serif;
                max-width: 600px;
                margin: auto;
                padding: 30px;
            ">
                <h2>Verify Your Email</h2>

                <p>
                    Thank you for creating your Secure Document Manager account.
                </p>

                <p>
                    Enter the following verification code in the app:
                </p>

                <div style="
                    font-size: 32px;
                    font-weight: bold;
                    letter-spacing: 8px;
                    margin: 25px 0;
                ">
                    ${verificationCode}
                </div>

                <p>
                    This code will expire in 5 minutes.
                </p>

                <p>
                    If you did not create this account, you can ignore this email.
                </p>
            </div>
        `
    });
};

module.exports = {
    sendVerificationEmail
};
