import { Router } from 'express';
import { asyncHandler } from '../utils/errors.js';
import { authenticate } from '../middleware/auth.js';
import * as emotionController from '../controllers/emotionController.js';

const router = Router();

router.use(authenticate);

router.get('/stats', asyncHandler(emotionController.getStats));
router.get('/recent', asyncHandler(emotionController.getRecent));
router.get('/entry/:entryId', asyncHandler(emotionController.getByEntry));

export default router;
