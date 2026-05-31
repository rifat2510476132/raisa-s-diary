import nodemailer from 'nodemailer';
import { config } from '../config/index.js';

let transporter = null;

function getTransporter() {
  if (!config.email.host || !config.email.user) return null;
  if (!transporter) {
    transporter = nodemailer.createTransport({
      host: config.email.host,
      port: config.email.port,
      secure: false,
      auth: { user: config.email.user, pass: config.email.pass },
    });
  }
  return transporter;
}

export async function sendVerificationEmail(email, token) {
  const transport = getTransporter();
  if (!transport) {
    console.log(`[DEV] Verification link: ${config.frontendUrl}/verify?token=${token}`);
    return;
  }

  const link = `${config.apiBaseUrl}/api/auth/verify/${token}`;
  await transport.sendMail({
    from: config.email.from,
    to: email,
    subject: 'Verify your diary — Tahsin is waiting 💌',
    html: `
      <div style="font-family: Georgia, serif; max-width: 480px; margin: auto; padding: 24px;">
        <h2 style="color: #e91e8c;">Welcome to Raisa's Diary</h2>
        <p>Verify your email to start writing with Tahsin by your side.</p>
        <a href="${link}" style="display:inline-block;padding:12px 24px;background:#e91e8c;color:white;border-radius:24px;text-decoration:none;">Verify Email</a>
      </div>
    `,
  });
}

export async function sendPasswordResetEmail(email, token) {
  const transport = getTransporter();
  if (!transport) {
    console.log(`[DEV] Reset token: ${token}`);
    return;
  }

  await transport.sendMail({
    from: config.email.from,
    to: email,
    subject: 'Reset your password',
    html: `<p>Use this token in the app: <strong>${token}</strong></p><p>Expires in 1 hour.</p>`,
  });
}
