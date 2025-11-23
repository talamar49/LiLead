# LiLead API Documentation

Base URL: `http://localhost:3000/api`

## Authentication

All protected endpoints require a Bearer token in the Authorization header:
```
Authorization: Bearer <token>
```

### Register
**POST** `/auth/register`

Request:
```json
{
  "email": "user@example.com",
  "name": "John Doe",
  "password": "password123"
}
```

Response:
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "clx...",
      "email": "user@example.com",
      "name": "John Doe",
      "avatarUrl": null,
      "createdAt": "2024-01-01T00:00:00.000Z"
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  },
  "message": "User registered successfully"
}
```

### Login
**POST** `/auth/login`

Request:
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

Response: Same as register

### Get Current User
**GET** `/auth/me`

Response:
```json
{
  "success": true,
  "data": {
    "id": "clx...",
    "email": "user@example.com",
    "name": "John Doe",
    "avatarUrl": null
  }
}
```

## Leads

### Get All Leads
**GET** `/leads?status=NEW&source=FACEBOOK`

Query Parameters:
- `status` (optional): NEW | IN_PROCESS | CLOSED | NOT_RELEVANT
- `source` (optional): FACEBOOK | INSTAGRAM | WHATSAPP | TIKTOK | MANUAL | WEBHOOK

Response:
```json
{
  "success": true,
  "data": [
    {
      "id": "clx...",
      "name": "Jane",
      "lastName": "Doe",
      "phone": "+1234567890",
      "email": "jane@example.com",
      "status": "NEW",
      "source": "FACEBOOK",
      "customFields": null,
      "createdAt": "2024-01-01T00:00:00.000Z",
      "updatedAt": "2024-01-01T00:00:00.000Z",
      "userId": "clx...",
      "notes": []
    }
  ]
}
```

### Create Lead
**POST** `/leads`

Request:
```json
{
  "name": "Jane",
  "lastName": "Doe",
  "phone": "+1234567890",
  "email": "jane@example.com",
  "source": "MANUAL",
  "customFields": {
    "company": "Acme Inc"
  }
}
```

### Get Single Lead
**GET** `/leads/:id`

### Update Lead
**PATCH** `/leads/:id`

Request:
```json
{
  "status": "IN_PROCESS",
  "customFields": {
    "notes": "Follow up next week"
  }
}
```

### Delete Lead
**DELETE** `/leads/:id`

## Notes

### Get Lead Notes
**GET** `/leads/:id/notes`

Response:
```json
{
  "success": true,
  "data": [
    {
      "id": "clx...",
      "content": "Called customer, interested in product",
      "createdAt": "2024-01-01T00:00:00.000Z",
      "updatedAt": "2024-01-01T00:00:00.000Z",
      "leadId": "clx...",
      "userId": "clx...",
      "user": {
        "id": "clx...",
        "name": "John Doe",
        "avatarUrl": null
      }
    }
  ]
}
```

### Add Note to Lead
**POST** `/leads/:id/notes`

Request:
```json
{
  "content": "Customer requested callback tomorrow"
}
```

## Profile

### Get Profile
**GET** `/profile`

### Update Profile
**PATCH** `/profile`

Request:
```json
{
  "name": "John Smith",
  "avatarUrl": "https://example.com/avatar.jpg",
  "currentPassword": "oldpassword",
  "newPassword": "newpassword123"
}
```

## Upload

### Upload Avatar
**POST** `/upload/avatar`

Content-Type: `multipart/form-data`

Form Data:
- `avatar` (File): Image file (JPEG, PNG, or WebP, max 5MB)

Response:
```json
{
  "success": true,
  "data": {
    "avatarUrl": "/uploads/avatars/avatar-clx...-1234567890.jpg"
  },
  "message": "Avatar uploaded successfully"
}
```

## Statistics

### Get Dashboard Stats
**GET** `/stats`

Response:
```json
{
  "success": true,
  "data": {
    "byStatus": {
      "new": 10,
      "inProcess": 5,
      "closed": 3,
      "notRelevant": 2
    },
    "bySource": {
      "facebook": 8,
      "instagram": 4,
      "whatsapp": 3,
      "tiktok": 2,
      "manual": 3,
      "webhook": 0
    },
    "total": 20,
    "conversionRate": 15.0,
    "recentLeads": 7
  }
}
```

## Webhook

### Receive Lead from External Source
**POST** `/webhook/lead`

No authentication required.

Request:
```json
{
  "name": "Jane",
  "lastName": "Smith",
  "phone": "+1234567890",
  "email": "jane@example.com",
  "source": "FACEBOOK",
  "userId": "clx..." // optional
}
```

## Error Responses

All endpoints return errors in this format:
```json
{
  "success": false,
  "error": "Error message here"
}
```

Common HTTP status codes:
- `200` - Success
- `400` - Bad Request (validation error)
- `401` - Unauthorized (missing or invalid token)
- `404` - Not Found
- `500` - Internal Server Error

## Notifications

### Register Device Token
**POST** `/notifications/register`

Register a device token for push notifications.

Request:
```json
{
  "token": "fcm_device_token_here",
  "platform": "android"  // or "ios" or "web"
}
```

Response:
```json
{
  "success": true,
  "data": {
    "registered": true
  },
  "message": "Device token registered successfully"
}
```

### Unregister Device Token
**DELETE** `/notifications/register`

Unregister a device token.

Request:
```json
{
  "token": "fcm_device_token_here"
}
```

Response:
```json
{
  "success": true,
  "data": {
    "unregistered": true
  },
  "message": "Device token unregistered successfully"
}
```

---

## Push Notifications

The system automatically sends push notifications for:
- **Note Reminders**: When a note's `reminderAt` time is reached, a notification is sent to all registered devices of the user
- Notifications are checked and sent every minute by the backend scheduler
- To receive notifications, ensure you:
  1. Have registered a device token via `/notifications/register`
  2. Have proper Firebase configuration set up
  3. Have notification permissions enabled on your device

For setup instructions, see `NOTIFICATIONS_SETUP.md`.

