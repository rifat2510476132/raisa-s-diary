import { Router } from 'express';
import multer from 'multer';
import { asyncHandler } from '../utils/errors.js';
import { authenticate } from '../middleware/auth.js';
import * as mediaController from '../controllers/mediaController.js';

const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 50 * 1024 * 1024 },
});

const router = Router();
router.use(authenticate);

router.post('/upload', upload.single('file'), asyncHandler(mediaController.upload));
router.delete('/:id', asyncHandler(mediaController.remove));

export default router;
