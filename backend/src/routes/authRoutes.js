import { Router } from 'express';
import { body } from 'express-validator';
import { asyncHandler } from '../utils/errors.js';
import { validate } from '../middleware/validate.js';
import { authenticate } from '../middleware/auth.js';
import * as authController from '../controllers/authController.js';

const router = Router();

router.post(
  '/register',
  [
    body('email').isEmail().normalizeEmail(),
    body('password').isLength({ min: 8 }),
    body('displayName').optional().trim().isLength({ max: 100 }),
  ],
  validate,
  asyncHandler(authController.register)
);

router.post(
  '/login',
  [body('email').isEmail(), body('password').notEmpty()],
  validate,
  asyncHandler(authController.login)
);

router.post('/refresh', [body('refreshToken').notEmpty()], validate, asyncHandler(authController.refresh));

router.post('/forgot-password', [body('email').isEmail()], validate, asyncHandler(authController.forgotPassword));

router.post(
  '/reset-password',
  [body('token').notEmpty(), body('password').isLength({ min: 8 })],
  validate,
  asyncHandler(authController.resetPassword)
);

router.get('/verify/:token', asyncHandler(authController.verifyEmail));

router.get('/profile', authenticate, asyncHandler(authController.getProfile));

export default router;
