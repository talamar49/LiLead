require('dotenv').config();
const { Client } = require('pg');
const { nanoid } = require('nanoid');

async function run() {
  const client = new Client({ connectionString: process.env.DATABASE_URL });
  await client.connect();

  const id = 'user_' + nanoid();
  const email = 'talamar49@gmail.com';
  const name = 'Tal Amar';
  const passwordHash = '$2a$10$w4H5Jqr6T/w93AGp0jpKCeTz5TLz6wfdnzS3XWapehMQIKWWcUTVm';

  // Insert or update
  const query = `INSERT INTO users (id, email, name, password, "createdAt", "updatedAt") 
  VALUES ($1, $2, $3, $4, NOW(), NOW())
  ON CONFLICT (email) DO UPDATE SET password = EXCLUDED.password, name = EXCLUDED.name, "updatedAt" = NOW()
  RETURNING id`;

  const res = await client.query(query, [id, email, name, passwordHash]);
  console.log('Inserted/updated user id:', res.rows[0].id);

  await client.end();
}

run().catch(err => { console.error(err); process.exit(1); });
