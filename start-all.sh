#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Starting LiLead All-in-One Script...${NC}"

# Function to cleanup background processes on exit
cleanup() {
    echo -e "\n${YELLOW}🛑 Shutting down services...${NC}"
    
    if [ ! -z "$BACKEND_PID" ]; then
        echo "Stopping Backend (PID: $BACKEND_PID)..."
        kill $BACKEND_PID
    fi
    
    echo "Stopping Database..."
    cd backend
    if docker compose stop > /dev/null 2>&1; then
        :
    else
        sudo docker compose stop
    fi
    
    echo -e "${GREEN}✅ All services stopped.${NC}"
    exit
}

# Trap SIGINT (Ctrl+C)
trap cleanup SIGINT

# 1. Start Database
echo -e "\n${BLUE}🗄️  Starting Database...${NC}"
cd backend

# Try running docker compose, if it fails, try with sudo
if docker compose up -d; then
    DOCKER_CMD="docker compose"
    echo -e "${GREEN}✅ Database started.${NC}"
elif sudo docker compose up -d; then
    DOCKER_CMD="sudo docker compose"
    echo -e "${GREEN}✅ Database started (with sudo).${NC}"
else
    echo -e "${RED}❌ Failed to start database. Please check your docker installation and permissions.${NC}"
    exit 1
fi

# Wait for DB to be ready
echo "Waiting for database to be ready..."
until $DOCKER_CMD exec -T postgres pg_isready -U postgres > /dev/null 2>&1; do
    echo -n "."
    sleep 1
done
echo -e "\n${GREEN}✅ Database is ready!${NC}"

# 2. Start Backend
echo -e "\n${BLUE}🔙 Starting Backend...${NC}"
# We are already in backend dir
npm run dev > ../backend.log 2>&1 &
BACKEND_PID=$!
echo -e "${GREEN}✅ Backend started in background (PID: $BACKEND_PID). Logs: backend.log${NC}"

# 3. Start Mobile App
echo -e "\n${BLUE}📱 Starting Mobile App...${NC}"
cd ../mobile

# Check for devices
if ! flutter devices | grep -q "android"; then
    echo -e "${YELLOW}🤖 No Android device found. Launching emulator...${NC}"
    
    # Get the first available emulator
    EMULATOR_ID=$(flutter emulators | grep "android" | head -n 1 | cut -d "•" -f 1 | xargs)
    
    if [ -z "$EMULATOR_ID" ]; then
        echo -e "${RED}❌ No emulator found. Please create one or connect a device.${NC}"
    else
        echo "Launching emulator: $EMULATOR_ID"
        flutter emulators --launch "$EMULATOR_ID" &
        
        # Wait a bit for it to start
        echo "Waiting for emulator to initialize..."
        sleep 15
    fi
fi

echo -e "${GREEN}🚀 Launching Flutter App...${NC}"
echo 'Interact with the app here (r: hot reload, R: hot restart, q: quit)'
flutter run

# When flutter run exits, cleanup
cleanup
