import * as mediaService from '../services/mediaService.js';

export async function upload(req, res) {
  if (!req.file) {
    return res.status(400).json({ success: false, error: { message: 'No file uploaded' } });
  }
  const mediaType = req.body.mediaType || 'photo';
  const media = await mediaService.uploadMedia(req.user.id, req.file, mediaType);
  res.status(201).json({ success: true, data: media });
}

export async function remove(req, res) {
  await mediaService.deleteMedia(req.user.id, req.params.id);
  res.json({ success: true });
}
