import { Router } from 'express';
import { body } from 'express-validator';
import { asyncHandler } from '../utils/errors.js';
import { validate } from '../middleware/validate.js';
import { authenticate } from '../middleware/auth.js';
import * as userController from '../controllers/userController.js';

const router = Router();

router.use(authenticate);

router.get('/me', asyncHandler(userController.getMe));
router.patch(
  '/me',
  [
    body('displayName').optional().trim().isLength({ min: 1, max: 100 }),
    body('avatarUrl').optional({ nullable: true }).isString(),
  ],
  validate,
  asyncHandler(userController.updateMe)
);
router.post(
  '/device-token',
  [body('token').notEmpty(), body('platform').optional().isIn(['android', 'ios', 'web'])],
  validate,
  asyncHandler(userController.registerDevice)
);

export default router;
