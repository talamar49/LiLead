const { Client } = require('pg');
const bcrypt = require('bcryptjs');

async function main() {
    const client = new Client({
        connectionString: 'postgresql://postgres:postgres@localhost:5432/lilead?schema=public',
    });

    try {
        await client.connect();
        console.log('Connected to database');

        const email = 'talamar49@gmail.com';
        const password = 'Talamar49!';
        const name = 'Tal Amar';
        const hash = await bcrypt.hash(password, 10);

        // Check if user exists
        const res = await client.query('SELECT id FROM users WHERE email = $1', [email]);

        if (res.rows.length > 0) {
            console.log('User exists, updating password...');
            await client.query('UPDATE users SET password = $1 WHERE email = $2', [hash, email]);
        } else {
            console.log('Creating user...');
            // Try gen_random_uuid()
            try {
                await client.query(`
          INSERT INTO users (id, email, name, password, "createdAt", "updatedAt")
          VALUES (gen_random_uuid(), $1, $2, $3, NOW(), NOW())
        `, [email, name, hash]);
            } catch (e) {
                // Fallback if gen_random_uuid() fails (e.g. older postgres)
                // Use a simple random string or uuid lib if available. 
                // Since I don't want to install uuid, I'll use a simple random string.
                const id = Math.random().toString(36).substring(2) + Date.now().toString(36);
                await client.query(`
          INSERT INTO users (id, email, name, password, "createdAt", "updatedAt")
          VALUES ($1, $2, $3, $4, NOW(), NOW())
        `, [id, email, name, hash]);
            }
        }
        console.log('User seeded successfully.');
    } catch (e) {
        console.error('Error seeding user:', e);
    } finally {
        await client.end();
    }
}

main();
