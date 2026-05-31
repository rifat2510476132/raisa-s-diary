import { Router } from 'express';
import { body } from 'express-validator';
import { asyncHandler } from '../utils/errors.js';
import { validate } from '../middleware/validate.js';
import { authenticate } from '../middleware/auth.js';
import * as settingsController from '../controllers/settingsController.js';

const router = Router();
router.use(authenticate);

router.get('/', asyncHandler(settingsController.get));
router.patch('/', asyncHandler(settingsController.update));
router.get('/streak', asyncHandler(settingsController.getStreak));
router.get('/achievements', asyncHandler(settingsController.getAchievements));
router.post('/pin', [body('pin').isLength({ min: 4, max: 6 })], validate, asyncHandler(settingsController.setPin));
router.post('/pin/verify', [body('pin').notEmpty()], validate, asyncHandler(settingsController.verifyPin));
router.delete('/pin', asyncHandler(settingsController.removePin));

export default router;
