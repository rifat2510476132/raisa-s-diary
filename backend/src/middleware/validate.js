import { validationResult } from 'express-validator';
import { AppError } from '../utils/errors.js';

export function validate(req, _res, next) {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    const err = new AppError('Validation failed', 400, 'VALIDATION_ERROR');
    err.array = () => errors.array();
    return next(err);
  }
  next();
}
