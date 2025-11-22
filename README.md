# LiLead CRM

LiLead is a comprehensive CRM application consisting of a Next.js backend and a Flutter mobile application.

## Prerequisites

Before running the project, ensure you have the following installed:

- **Docker**: For running the PostgreSQL database.
- **Node.js**: For the backend.
- **Flutter SDK**: For the mobile application.
- **Android Studio** (optional but recommended): For Android emulator support.

## Quick Start

The easiest way to run the entire stack is using the master script:

```bash
./start-all.sh
```

This script will:
1. Start the PostgreSQL database (requires `sudo` for Docker).
2. Launch the Backend server.
3. Launch the Mobile app (on a connected device or emulator).

> **Note**: If the Android emulator fails to launch, ensure you have the required System Images installed via Android Studio Device Manager.

## Manual Setup

If you prefer to run services individually:

### 1. Database
```bash
cd backend
docker compose up -d
```

### 2. Backend
```bash
cd backend
npm install
npm run dev
```
The backend runs on `http://localhost:3000`.

### 3. Mobile App
```bash
cd mobile
flutter pub get
flutter run
```

## Project Structure

- `backend/`: Next.js application (API & Database).
- `mobile/`: Flutter application (iOS & Android).
- `start-all.sh`: Orchestration script.
