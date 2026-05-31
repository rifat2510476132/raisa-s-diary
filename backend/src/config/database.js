import pg from 'pg';
import { config } from './index.js';

const { Pool } = pg;

export const pool = new Pool({
  connectionString: config.databaseUrl,
  ssl: config.nodeEnv === 'production' ? { rejectUnauthorized: false } : false,
  max: 20,
  idleTimeoutMillis: 30000,
});

pool.on('error', (err) => {
  console.error('Unexpected database error', err);
});

export async function query(text, params) {
  const start = Date.now();
  const result = await pool.query(text, params);
  if (config.nodeEnv === 'development') {
    const duration = Date.now() - start;
    if (duration > 200) {
      console.log('Slow query', { text: text.substring(0, 80), duration });
    }
  }
  return result;
}
