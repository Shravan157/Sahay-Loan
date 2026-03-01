# SAHAY - Detailed Setup Guide

This guide will walk you through setting up the SAHAY application from scratch.

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Firebase Setup](#firebase-setup)
3. [Backend Setup](#backend-setup)
4. [Frontend Setup](#frontend-setup)
5. [Mobile Device Setup](#mobile-device-setup)
6. [Troubleshooting](#troubleshooting)

## Prerequisites

### Required Software
- **Flutter SDK** (3.10 or higher): https://docs.flutter.dev/get-started/install
- **Python** (3.9 or higher): https://www.python.org/downloads/
- **Git**: https://git-scm.com/downloads
- **Android Studio** (for Android): https://developer.android.com/studio
- **Xcode** (for iOS, macOS only): https://developer.apple.com/xcode/

### Optional but Recommended
- **VS Code**: https://code.visualstudio.com/
- **Postman**: https://www.postman.com/ (for API testing)

## Firebase Setup

### 1. Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Add Project"
3. Name it "sahay-loan-app" (or your preferred name)
4. Enable Google Analytics (optional)
5. Click "Create Project"

### 2. Enable Authentication
1. Go to "Authentication" in the left sidebar
2. Click "Get Started"
3. Enable "Email/Password" provider
4. Save

### 3. Create Firestore Database
1. Go to "Firestore Database" in the left sidebar
2. Click "Create Database"
3. Choose "Start in production mode"
4. Select a location closest to your users (e.g., `asia-south1` for India)
5. Click "Enable"

### 4. Get Firebase Config Files

#### For Android:
1. Click the Android icon (</>) to add an Android app
2. Register app with package name: `com.example.sahay_loan_app`
3. Download `google-services.json`
4. Place it in: `android/app/google-services.json`

#### For Web:
1. Click the Web icon (</>) to add a web app
2. Register app with nickname: "SAHAY Web"
3. Copy the Firebase config object
4. You'll need the `apiKey` for the backend `.env` file

### 5. Get Service Account Key (Backend)
1. Go to Project Settings (gear icon) → Service Accounts
2. Click "Generate new private key"
3. Download the JSON file
4. Rename it to `serviceAccountKey.json`
5. Place it in: `backend/serviceAccountKey.json`

## Backend Setup

### 1. Navigate to Backend Directory
```bash
cd backend
```

### 2. Create Virtual Environment
```bash
# Windows
python -m venv venv
venv\Scripts\activate

# macOS/Linux
python3 -m venv venv
source venv/bin/activate
```

### 3. Install Dependencies
```bash
pip install -r requirements.txt
```

### 4. Configure Environment Variables
```bash
# Copy the example file
copy .env.example .env

# Edit .env with your credentials
notepad .env
```

Fill in the `.env` file:
```env
FIREBASE_WEB_API_KEY=AIzaSy...your_key_here
GOOGLE_VISION_API_KEY=AIzaSy...your_key_here
GMAIL_SENDER_EMAIL=your_email@gmail.com
GMAIL_APP_PASSWORD=your_16_digit_password
MAX_LOAN_AMOUNT=5000
```

**Note:** For Gmail App Password:
1. Go to https://myaccount.google.com
2. Security → 2-Step Verification → App Passwords
3. Generate password for "Mail"
4. Copy the 16-digit password

### 5. Install Tesseract OCR

#### Windows:
```powershell
# Option 1: Using Chocolatey
choco install tesseract

# Option 2: Manual download
# Download from: https://github.com/UB-Mannheim/tesseract/wiki
# Install and add to PATH
```

#### macOS:
```bash
brew install tesseract
```

#### Linux:
```bash
sudo apt-get install tesseract-ocr
```

### 6. Run the Backend Server
```bash
python main.py
```

You should see:
```
INFO:     Uvicorn running on http://0.0.0.0:8000
```

Test the API:
```bash
curl http://localhost:8000/kyc-status
```

## Frontend Setup

### 1. Install Flutter Dependencies
```bash
flutter pub get
```

### 2. Configure API Base URL

Edit `lib/core/constants/api_endpoints.dart`:

```dart
// For web development (Chrome)
static String get baseUrl {
  if (kIsWeb) {
    return 'http://localhost:8000';
  } else {
    // For mobile - use your computer's IP address
    return 'http://192.168.1.5:8000';  // Change this to your IP
  }
}
```

Find your IP address:
- Windows: `ipconfig` → Look for "IPv4 Address"
- macOS/Linux: `ifconfig` or `ip addr`

### 3. Run the App

#### On Chrome (Web):
```bash
flutter run -d chrome
```

#### On Android Emulator:
```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d emulator-5554
```

#### On Physical Android Device:
```bash
# Connect device via USB
# Enable USB debugging on device
flutter run -d <device_id>
```

#### On iOS Simulator (macOS only):
```bash
flutter run -d ios
```

## Mobile Device Setup

### For Physical Android Device

#### 1. Enable Developer Options
1. Go to Settings → About Phone
2. Tap "Build Number" 7 times
3. Go back → Developer Options
4. Enable "USB Debugging"

#### 2. Connect Device
1. Connect phone via USB
2. Allow USB debugging when prompted
3. Verify connection:
   ```bash
   flutter devices
   ```

#### 3. Configure Network
Both phone and computer must be on the **same WiFi network**.

Update `api_endpoints.dart` with your computer's IP:
```dart
return 'http://192.168.1.5:8000';  // Your computer's IP
```

#### 4. Run the App
```bash
flutter run -d <your_device_id>
```

### For Android Emulator

The emulator uses a special IP to reach the host computer:
```dart
return 'http://10.0.2.2:8000';  // Special IP for emulator
```

### Build APK for Distribution
```bash
flutter build apk --release
```

The APK will be at:
```
build/app/outputs/flutter-apk/app-release.apk
```

## Troubleshooting

### Issue: "No Internet Connection" on Mobile

**Solution 1: Check IP Address**
```bash
ipconfig
# Use the IPv4 address from your WiFi adapter
```

**Solution 2: Windows Firewall**
1. Open Windows Defender Firewall
2. Click "Allow an app through firewall"
3. Add Python/python.exe
4. Or temporarily disable firewall for testing

**Solution 3: Same Network**
Ensure phone and computer are on the same WiFi network.

### Issue: "Failed to load resources" in Chrome

**Solution:**
Run Chrome with disabled web security (development only):
```bash
flutter run -d chrome --web-renderer html
```

### Issue: Tesseract OCR not working

**Solution:**
1. Verify Tesseract is installed:
   ```bash
   tesseract --version
   ```
2. Add to PATH if not found
3. Restart your terminal/IDE

### Issue: Firebase Auth errors

**Solution:**
1. Check `google-services.json` is in correct location
2. Verify package name matches Firebase config
3. Clean and rebuild:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

### Issue: Backend won't start

**Solution:**
1. Check port 8000 is not in use:
   ```bash
   netstat -ano | findstr :8000
   ```
2. Kill process if needed or use different port
3. Verify Python dependencies are installed:
   ```bash
   pip list
   ```

## Development Tips

### Hot Reload
Press `r` in the terminal where Flutter is running to hot reload.

### Hot Restart
Press `R` to restart the app (resets state).

### View Logs
```bash
flutter logs
```

### Debug Mode
```bash
flutter run --debug
```

### Profile Mode (Performance)
```bash
flutter run --profile
```

## Next Steps

1. Create test accounts in Firebase Authentication
2. Test KYC flow with sample documents
3. Test loan application and repayment
4. Set up admin accounts for dashboard access
5. Configure Stripe for production payments

## Support

If you encounter issues:
1. Check the [FAQ](FAQ.md)
2. Search [existing issues](https://github.com/Shravan157/Sahay-Loan/issues)
3. Create a new issue with:
   - Error message
   - Steps to reproduce
   - Your environment details

Happy coding! 🚀
