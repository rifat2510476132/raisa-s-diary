import { Router } from 'express';
import { body } from 'express-validator';
import { asyncHandler } from '../utils/errors.js';
import { validate } from '../middleware/validate.js';
import { authenticate } from '../middleware/auth.js';
import * as diaryController from '../controllers/diaryController.js';

const router = Router();

router.use(authenticate);

router.post(
  '/',
  [body('content').trim().isLength({ min: 1, max: 10000 })],
  validate,
  asyncHandler(diaryController.createEntry)
);

router.get('/', asyncHandler(diaryController.listEntries));
router.get('/tahsin-message', asyncHandler(diaryController.getTahsinMessage));
router.get('/emotions/stats', asyncHandler(diaryController.getEmotionStats));
router.get('/mood-calendar', asyncHandler(diaryController.getMoodCalendar));
router.get('/:id', asyncHandler(diaryController.getEntry));
router.delete('/:id', asyncHandler(diaryController.deleteEntry));

export default router;
