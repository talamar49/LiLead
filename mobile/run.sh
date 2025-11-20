#!/bin/bash

# LiLead - Quick Start Script

echo "🚀 Starting LiLead CRM..."
echo ""

# Check if backend is running
if ! lsof -Pi :3000 -sTCP:LISTEN -t >/dev/null 2>&1; then
    echo "⚠️  Backend is not running!"
    echo "Please start the backend in another terminal:"
    echo "  cd /home/talam1/Desktop/Personal/lilead/backend"
    echo "  npm run dev"
    echo ""
    read -p "Press Enter when backend is ready..."
fi

echo "📱 Checking for connected devices..."
if ! /home/talam1/develop/flutter/bin/flutter devices | grep -q "android"; then
    echo "🤖 No Android device found. Launching emulator..."
    /home/talam1/develop/flutter/bin/flutter emulators --launch Medium_Phone_API_36.1
    echo "Waiting for emulator to start..."
    sleep 10
fi

echo "🚀 Starting Flutter app..."
echo ""
echo "Hot Reload Commands:"
echo "  r  - Hot reload"
echo "  R  - Hot restart"
echo "  q  - Quit"
echo ""

cd /home/talam1/Desktop/Personal/lilead/mobile
/home/talam1/develop/flutter/bin/flutter run
