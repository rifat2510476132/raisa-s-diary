import { Router } from 'express';
import { body } from 'express-validator';
import { asyncHandler } from '../utils/errors.js';
import { validate } from '../middleware/validate.js';
import { authenticate } from '../middleware/auth.js';
import * as aiController from '../controllers/aiController.js';

const router = Router();

router.use(authenticate);

router.get('/chat', asyncHandler(aiController.listChat));
router.post(
  '/chat',
  [body('message').trim().isLength({ min: 1, max: 4000 })],
  validate,
  asyncHandler(aiController.sendChat)
);
router.delete('/chat', asyncHandler(aiController.clearChat));
router.get('/daily-message', asyncHandler(aiController.dailyMessage));

export default router;
