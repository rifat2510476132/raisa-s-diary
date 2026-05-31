import { Router } from 'express';
import { body } from 'express-validator';
import { asyncHandler } from '../utils/errors.js';
import { validate } from '../middleware/validate.js';
import { authenticate } from '../middleware/auth.js';
import * as notificationController from '../controllers/notificationController.js';

const router = Router();
router.use(authenticate);

router.get('/', asyncHandler(notificationController.list));
router.patch('/read-all', asyncHandler(notificationController.markAllRead));
router.patch('/:id/read', asyncHandler(notificationController.markRead));
router.post('/device', [body('token').notEmpty()], validate, asyncHandler(notificationController.registerDevice));

export default router;
