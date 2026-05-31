import { v2 as cloudinary } from 'cloudinary';
import { query } from '../config/database.js';
import { config } from '../config/index.js';
import { AppError } from '../utils/errors.js';

if (config.cloudinary.cloudName) {
  cloudinary.config({
    cloud_name: config.cloudinary.cloudName,
    api_key: config.cloudinary.apiKey,
    api_secret: config.cloudinary.apiSecret,
  });
}

export async function uploadMedia(userId, file, mediaType) {
  if (!config.cloudinary.cloudName) {
    const localUrl = `/uploads/${file.filename}`;
    const result = await query(
      `INSERT INTO media_files (user_id, media_type, url, file_size_bytes)
       VALUES ($1, $2, $3, $4) RETURNING *`,
      [userId, mediaType, localUrl, file.size]
    );
    return result.rows[0];
  }

  const resourceType = mediaType === 'video' ? 'video' : mediaType === 'voice' ? 'video' : 'image';

  const uploadResult = await new Promise((resolve, reject) => {
    const stream = cloudinary.uploader.upload_stream(
      { folder: 'raisa-diary', resource_type: resourceType },
      (err, result) => (err ? reject(err) : resolve(result))
    );
    stream.end(file.buffer);
  });

  const dbResult = await query(
    `INSERT INTO media_files (user_id, media_type, url, public_id, file_size_bytes)
     VALUES ($1, $2, $3, $4, $5) RETURNING *`,
    [userId, mediaType, uploadResult.secure_url, uploadResult.public_id, uploadResult.bytes]
  );

  return dbResult.rows[0];
}

export async function deleteMedia(userId, mediaId) {
  const result = await query(
    'SELECT * FROM media_files WHERE id = $1 AND user_id = $2',
    [mediaId, userId]
  );

  if (!result.rows.length) {
    throw new AppError('Media not found', 404, 'NOT_FOUND');
  }

  const media = result.rows[0];
  if (media.public_id && config.cloudinary.cloudName) {
    await cloudinary.uploader.destroy(media.public_id);
  }

  await query('DELETE FROM media_files WHERE id = $1', [mediaId]);
  return { deleted: true };
}
