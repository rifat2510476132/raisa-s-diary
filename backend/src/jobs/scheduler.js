import cron from 'node-cron';
import * as notificationService from '../services/notificationService.js';

export function startScheduler() {
  cron.schedule('0 9,14,20 * * *', async () => {
    try {
      const result = await notificationService.scheduleDailyReminders();
      console.log(`Scheduled reminders for ${result.sent} users`);
    } catch (err) {
      console.error('Scheduler error:', err.message);
    }
  });

  console.log('Notification scheduler started');
}
