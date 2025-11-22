# LiLead Backend API

Modern Next.js 14 backend for the LiLead CRM mobile application.

## Features

- 🔐 **JWT Authentication** - Secure user authentication with bcrypt password hashing
- 📊 **Lead Management** - Full CRUD operations for leads
- 📝 **Notes System** - Add timestamped notes to leads
- 🔔 **Webhook Integration** - Receive leads from external sources (Facebook, Instagram, etc.)
- 📈 **Analytics API** - Dashboard statistics and insights
- 👤 **User Profiles** - Manage user information and avatars
- 🗄️ **PostgreSQL Database** - Powered by Prisma ORM

## Tech Stack

- **Framework**: Next.js 14 (App Router)
- **Database**: PostgreSQL with Prisma ORM
- **Authentication**: JWT with bcryptjs
- **Validation**: Zod
- **Language**: TypeScript

## Getting Started

### Prerequisites

- Node.js 18+ 
- PostgreSQL database (or use SQLite for development)

### Installation

1. Install dependencies:
```bash
npm install
```

2. Configure environment variables:
```bash
# Copy .env and update with your database credentials
cp .env .env.local
```

3. Update `.env` with your database URL:
```env
DATABASE_URL="postgresql://user:password@localhost:5432/lilead"
JWT_SECRET="your-secret-key"
```

### Database Setup

1. Generate Prisma client:
```bash
npx prisma generate
```

2. Run database migrations:
```bash
npx prisma migrate dev --name init
```

3. (Optional) Seed the database:
```bash
npx prisma db seed
```

### Development

Run the development server:
```bash
npm run dev
```

The API will be available at `http://localhost:3000`

## API Endpoints

### Authentication

- `POST /api/auth/register` - Register a new user
- `POST /api/auth/login` - Login user
- `GET /api/auth/me` - Get current user

### Leads

- `GET /api/leads` - Get all leads (supports filtering by status and source)
- `POST /api/leads` - Create a new lead
- `GET /api/leads/[id]` - Get a specific lead
- `PATCH /api/leads/[id]` - Update a lead
- `DELETE /api/leads/[id]` - Delete a lead

### Notes

- `GET /api/leads/[id]/notes` - Get all notes for a lead
- `POST /api/leads/[id]/notes` - Add a note to a lead

### Profile

- `GET /api/profile` - Get user profile
- `PATCH /api/profile` - Update user profile

### Statistics

- `GET /api/stats` - Get dashboard statistics

### Webhook

- `POST /api/webhook/lead` - Receive leads from external sources

## Authentication

All protected endpoints require a JWT token in the Authorization header:

```
Authorization: Bearer <your-jwt-token>
```

### Example: Register & Login

**Register:**
```bash
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "name": "John Doe",
    "password": "password123"
  }'
```

**Login:**
```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "password123"
  }'
```

## Database Schema

### User
- `id` - Unique identifier
- `email` - User email (unique)
- `name` - User name
- `password` - Hashed password
- `avatarUrl` - Profile picture URL (optional)

### Lead
- `id` - Unique identifier
- `name` - Lead first name
- `lastName` - Lead last name (optional)
- `phone` - Phone number
- `email` - Email address (optional)
- `status` - NEW | IN_PROCESS | CLOSED | NOT_RELEVANT
- `source` - FACEBOOK | INSTAGRAM | WHATSAPP | TIKTOK | MANUAL | WEBHOOK
- `customFields` - JSON object for flexible data
- `userId` - Reference to user

### Note
- `id` - Unique identifier
- `content` - Note text
- `leadId` - Reference to lead
- `userId` - Reference to user who created the note
- `createdAt` - Timestamp

## Webhook Integration

To receive leads from external sources, send a POST request to `/api/webhook/lead`:

```bash
curl -X POST http://localhost:3000/api/webhook/lead \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Jane",
    "lastName": "Smith",
    "phone": "+1234567890",
    "email": "jane@example.com",
    "source": "FACEBOOK"
  }'
```

## Prisma Studio

View and edit your database with Prisma Studio:

```bash
npx prisma studio
```

## Production Deployment

1. Set production environment variables
2. Build the application:
```bash
npm run build
```

3. Start the production server:
```bash
npm start
```

## License

MIT
