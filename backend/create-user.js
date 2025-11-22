const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcryptjs');

const prisma = new PrismaClient({});

async function main() {
    const email = 'talamar49@gmail.com';
    const password = 'Talamar49!';
    const name = 'Tal Amar';

    console.log(`Creating user ${email}...`);

    const hashedPassword = await bcrypt.hash(password, 10);

    try {
        const user = await prisma.user.upsert({
            where: { email },
            update: {
                password: hashedPassword,
                name,
            },
            create: {
                email,
                name,
                password: hashedPassword,
            },
        });
        console.log('User created/updated successfully:', user.id);
    } catch (e) {
        console.error('Error creating user:', e);
    } finally {
        await prisma.$disconnect();
    }
}

main();
