import { Router } from 'express';
import authRoutes from './authRoutes.js';
import userRoutes from './userRoutes.js';
import diaryRoutes from './diaryRoutes.js';
import emotionRoutes from './emotionRoutes.js';
import notificationRoutes from './notificationRoutes.js';
import settingsRoutes from './settingsRoutes.js';
import mediaRoutes from './mediaRoutes.js';
import aiRoutes from './aiRoutes.js';

const router = Router();

router.get('/health', (_req, res) => {
  res.json({
    success: true,
    app: "Jannatul Maowa Raisa's Diary",
    version: '1.0.0',
    tahsin: 'online 💕',
  });
});

router.use('/auth', authRoutes);
router.use('/users', userRoutes);
router.use('/diary', diaryRoutes);
router.use('/emotions', emotionRoutes);
router.use('/notifications', notificationRoutes);
router.use('/settings', settingsRoutes);
router.use('/media', mediaRoutes);
router.use('/ai', aiRoutes);

export default router;
