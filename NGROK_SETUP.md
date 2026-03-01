# Access SAHAY App on Your Phone Using ngrok

## What is ngrok?
ngrok creates a secure tunnel from the internet to your local computer, allowing you to access your Flutter web app from any phone or device anywhere in the world.

## Quick Start (Automatic)

1. **Open PowerShell as Administrator**

2. **Run the setup script:**
   ```powershell
   cd c:\Users\Shravan\Desktop\sahay_loan_app
   .\run_with_ngrok.ps1
   ```

3. **Get your free ngrok authtoken:**
   - Go to: https://dashboard.ngrok.com/get-started/your-authtoken
   - Sign up for free (if not already)
   - Copy your authtoken
   - Paste it when the script asks

4. **Access the URL on your phone:**
   - The script will show a URL like: `https://abc123-def.ngrok-free.app`
   - Open this URL on your phone's browser
   - The SAHAY app will load!

## Manual Steps (If Script Doesn't Work)

### Step 1: Start Flutter Web Server
```powershell
cd c:\Users\Shravan\Desktop\sahay_loan_app
flutter run -d web-server --web-port 8080 --web-hostname 0.0.0.0
```

### Step 2: Start ngrok (In Another Terminal)
```powershell
C:\ngrok\ngrok.exe http 8080
```

### Step 3: Get the Public URL
- ngrok will display a URL like:
  ```
  Forwarding: https://abc123-def.ngrok-free.app -> http://localhost:8080
  ```
- Open this URL on your phone!

## Important Notes

### Backend Connection
Your phone needs to connect to the backend too. Update the API base URL:

**Option A: Use ngrok for backend too**
```powershell
# Terminal 1: Start backend
cd c:\Users\Shravan\Desktop\sahay_loan_app\backend
python main.py

# Terminal 2: Expose backend via ngrok
C:\ngrok\ngrok.exe http 8000
```
Then update `lib/core/constants/api_endpoints.dart`:
```dart
static const String baseUrl = 'https://your-backend-ngrok-url.ngrok-free.app';
```

**Option B: Use your computer's IP**
1. Find your IP: `ipconfig` (look for IPv4 Address)
2. Update `api_endpoints.dart`:
   ```dart
   static const String baseUrl = 'http://192.168.1.5:8000'; // Your IP
   ```

### Free ngrok Limitations
- URLs change every time you restart ngrok
- 1 concurrent tunnel on free plan
- Rate limits apply

### Paid ngrok (Optional)
- Static subdomain: `https://sahay-yourname.ngrok.io`
- Multiple tunnels
- No rate limits

## Troubleshooting

**"ngrok not found"**
- Make sure ngrok is extracted to `C:\ngrok\ngrok.exe`

**"Failed to start Flutter server"**
- Check if port 8080 is already in use
- Try a different port: `--web-port 8081`

**"Backend not connecting"**
- Ensure backend is running on port 8000
- Check Windows Firewall settings
- Use ngrok for backend too (Option A above)

**"Site can't be reached" on phone**
- Make sure phone has internet
- Check if ngrok URL is correct
- Try refreshing the page

## Alternative: Same WiFi Network
If your phone and computer are on the same WiFi:

1. Find your computer's IP: `ipconfig`
2. Start Flutter: `flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080`
3. On phone browser: `http://192.168.1.5:8080` (your computer's IP)

This is faster but only works on the same network.
