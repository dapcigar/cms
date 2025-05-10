// Notification service for sending emails via Resend.com
// Replace 'YOUR_RESEND_API_KEY' with your actual API key in production

// Reads the Resend API key from the .env file
const RESEND_API_KEY = import.meta.env.VITE_RESEND_KEY || 'YOUR_RESEND_API_KEY'
const RESEND_API_URL = 'https://api.resend.com/emails'

export async function sendEmailNotification({ to, subject, html }: { to: string, subject: string, html: string }) {
  const response = await fetch(RESEND_API_URL, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${RESEND_API_KEY}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      to,
      subject,
      html,
      from: 'noreply@yourdomain.com',
    }),
  })
  if (!response.ok) {
    throw new Error('Failed to send email notification')
  }
  return response.json()
}
