# Deployment & Testing Plan

This plan outlines the steps to host your backend at `lilead.stbamar.space` and verify the connection with your mobile app.

## 1. Server-Side Configuration (stbamar.space)

### A. Cloudflare Tunnel Setup
1.  **Edit Config**: Open your `cloudflared` config file (usually `~/.cloudflared/config.yml` or `/etc/cloudflared/config.yml`).
2.  **Add Ingress Rule**: Insert the following rule **before** the final catch-all (`- service: http_status:404`):
    ```yaml
    ingress:
      - hostname: lilead.stbamar.space
        service: http://localhost:56744
      # ... existing rules ...
    ```
3.  **Restart Tunnel**:
    ```bash
    sudo systemctl restart cloudflared
    ```

### B. Backend Deployment
1.  **Prepare Backend**:
    ```bash
    cd /path/to/lilead/backend
    npm install
    npm run build
    ```
2.  **Run with PM2** (Recommended for production):
    ```bash
    # Install PM2
    npm install -g pm2
    
    # Start Backend on port 56744
    pm2 start npm --name "lilead-backend" -- start -- -p 56744
    
    # Ensure it restarts on reboot
    pm2 save
    pm2 startup
    ```

---

## 2. Mobile App Configuration

### A. Build Configuration
You don't need to change code if you use build flags.

**Option 1: Build with Flag (Recommended)**
```bash
flutter build apk --release --dart-define=API_BASE_URL=https://lilead.stbamar.space/api
```

**Option 2: Hardcode Default**
Modify `lib/config/constants.dart`:
```dart
static String get baseUrl {
  const env = String.fromEnvironment('API_BASE_URL');
  if (env.isNotEmpty) return env;
  if (kReleaseMode) return 'https://lilead.stbamar.space/api'; // Add this
  // ...
}
```

---

## 3. Testing Plan

### A. Verify Server Accessibility
**Goal**: Ensure the backend is reachable via the public URL.

1.  **Browser/Curl Check**:
    Open `https://lilead.stbamar.space` in a browser. You should see the Next.js default landing page.
    
    Or use curl:
    ```bash
    curl -I https://lilead.stbamar.space
    # Expected: HTTP/2 200
    ```

2.  **API Health Check**:
    Since we don't have a dedicated health endpoint yet, check a standard Next.js path:
    ```bash
    curl https://lilead.stbamar.space/api/auth/session
    # Expected: JSON response (likely empty object {})
    ```

### B. Verify App Connection
**Goal**: Ensure the app can communicate with the server.

1.  **Run in Release Mode**:
    Connect a physical device and run:
    ```bash
    flutter run --release --dart-define=API_BASE_URL=https://lilead.stbamar.space/api
    ```
    *Note: `debug` mode might have issues with SSL/HTTPS on some devices without extra config, so `release` is better for "real" testing.*

2.  **Functional Test**:
    *   **Login**: Try to log in. If it succeeds, the API is reachable.
    *   **Data Fetch**: Check if leads load on the dashboard.
    *   **Logs**: If it fails, check the device logs:
        ```bash
        flutter logs
        ```
