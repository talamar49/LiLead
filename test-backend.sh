#!/bin/bash

echo "🔧 Testing LiLead Backend..."
echo ""

# Test backend health
echo "1. Testing backend connection..."
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000)

if [ "$RESPONSE" == "000" ]; then
    echo "   ❌ Backend is NOT running!"
    echo "   💡 Start it with: cd backend && npm run dev"
    exit 1
elif [ "$RESPONSE" == "500" ]; then
    echo "   ⚠️  Backend is running but has errors"
    echo "   💡 Check the backend logs for error details"
    exit 1
else
    echo "   ✅ Backend is running (HTTP $RESPONSE)"
fi

# Test auth endpoint
echo ""
echo "2. Testing auth endpoint..."
AUTH_RESPONSE=$(curl -s http://localhost:3000/api/auth/me)

if echo "$AUTH_RESPONSE" | grep -q "success"; then
    echo "   ✅ Auth endpoint working"
elif echo "$AUTH_RESPONSE" | grep -q "error"; then
    echo "   ⚠️  Auth endpoint responding (needs authentication)"
else
    echo "   ❌ Auth endpoint has issues"
fi

# Initialize notification scheduler
echo ""
echo "3. Initializing notification scheduler..."
NOTIF_RESPONSE=$(curl -s http://localhost:3000/api/notifications/status)

if echo "$NOTIF_RESPONSE" | grep -q "running"; then
    echo "   ✅ Notification scheduler initialized"
elif echo "$NOTIF_RESPONSE" | grep -q "failed"; then
    echo "   ⚠️  Notification scheduler failed (Firebase not configured?)"
else
    echo "   ℹ️  Notification scheduler status unknown"
fi

echo ""
echo "✨ Backend test complete!"
echo ""
echo "Next steps:"
echo "  1. If all green, start mobile app: cd mobile && flutter run"
echo "  2. Use Android/iOS (not web) for notifications"
echo "  3. Web doesn't support push notifications yet"

