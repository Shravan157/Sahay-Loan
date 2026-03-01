# SAHAY - Micro-Loan Platform for Underserved Communities

[![Flutter Version](https://img.shields.io/badge/Flutter-3.10+-blue.svg)](https://flutter.dev)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.100+-green.svg)](https://fastapi.tiangolo.com)
[![Firebase](https://img.shields.io/badge/Firebase-Cloud%20Firestore-orange.svg)](https://firebase.google.com)

SAHAY is a comprehensive fintech mobile application designed to provide micro-loans up to ₹1,00,000 to underserved communities in India. Built with Flutter for cross-platform compatibility and FastAPI for a robust backend.

![SAHAY App Banner](assets/images/banner.png)

## 🌟 Features

### For Users
- 🔐 **Secure Authentication** - Firebase Auth with email/password
- 📋 **KYC Verification** - Aadhaar & PAN card OCR using Tesseract
- 🤖 **AI Credit Scoring** - Machine learning-based credit assessment
- 💰 **Loan Application** - Apply for loans up to ₹1,00,000
- 📊 **EMI Calculator** - Calculate monthly installments
- 💳 **Online Repayment** - Stripe integration for EMI payments
- 🔔 **Real-time Notifications** - Track loan status updates
- 📱 **Cross-Platform** - Works on Android, iOS, Web, and Desktop

### For Admins
- 📈 **Dashboard Analytics** - View statistics and charts
- 👥 **User Management** - Manage all registered users
- 💼 **Loan Management** - Approve/reject loan applications
- 🏦 **Provider Management** - Manage lending partners

### For Loan Providers
- 📋 **Shared Profiles** - Access borrower information
- ✅ **Loan Decisions** - Approve or reject applications
- 📊 **Portfolio View** - Track disbursed loans

## 🛠️ Tech Stack

### Frontend
- **Flutter** - Cross-platform UI framework
- **Provider** - State management
- **Firebase Auth** - Authentication
- **Google Fonts** - Typography (Inter)
- **fl_chart** - Data visualization

### Backend
- **FastAPI** - Python web framework
- **Firebase Firestore** - NoSQL database
- **Tesseract OCR** - Document text extraction
- **scikit-learn** - Machine learning for credit scoring
- **Stripe** - Payment processing

### DevOps
- **GitHub Actions** - CI/CD (optional)
- **ngrok** - Local development tunneling

## 📱 Screenshots

| Splash Screen | Onboarding | Login | Register |
|--------------|------------|-------|----------|
| ![Splash](screenshots/splash.png) | ![Onboarding](screenshots/onboarding.png) | ![Login](screenshots/login.png) | ![Register](screenshots/register.png) |

| Home | KYC | Loan Apply | Profile |
|------|-----|------------|---------|
| ![Home](screenshots/home.png) | ![KYC](screenshots/kyc.png) | ![Loan](screenshots/loan.png) | ![Profile](screenshots/profile.png) |

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (^3.10.0)
- Python 3.9+
- Firebase Account
- Android Studio / Xcode (for mobile)
- Tesseract OCR (for document scanning)

### Installation

#### 1. Clone the Repository
```bash
git clone https://github.com/Shravan157/Sahay-Loan.git
cd Sahay-Loan
```

#### 2. Setup Flutter Frontend
```bash
# Install dependencies
flutter pub get

# For web development
flutter run -d chrome

# For Android
flutter run -d <device_id>
```

#### 3. Setup Python Backend
```bash
cd backend

# Create virtual environment
python -m venv venv

# Activate virtual environment
# Windows:
venv\Scripts\activate
# macOS/Linux:
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Run the server
python main.py
```

#### 4. Configure Environment Variables

Create `.env` file in `backend/` directory:
```env
# Firebase Configuration
FIREBASE_WEB_API_KEY=your_firebase_web_api_key
GOOGLE_VISION_API_KEY=your_google_vision_api_key

# Email Configuration
GMAIL_SENDER_EMAIL=your_email@gmail.com
GMAIL_APP_PASSWORD=your_app_password

# Business Logic
MAX_LOAN_AMOUNT=5000

# Stripe (Optional)
STRIPE_SECRET_KEY=sk_test_your_key
STRIPE_PUBLISHABLE_KEY=pk_test_your_key
```

#### 5. Configure Firebase

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Download `google-services.json` for Android
3. Place it in `android/app/`
4. Download `serviceAccountKey.json` for backend
5. Place it in `backend/`

#### 6. Install Tesseract OCR (Windows)
```powershell
# Download from: https://github.com/UB-Mannheim/tesseract/wiki
# Or use Chocolatey:
choco install tesseract
```

## 📁 Project Structure

```
sahay_loan_app/
├── android/                  # Android-specific files
├── ios/                      # iOS-specific files
├── lib/                      # Flutter source code
│   ├── core/                 # Core utilities
│   │   ├── constants/        # App constants
│   │   ├── services/         # API services
│   │   └── widgets/          # Reusable widgets
│   ├── models/               # Data models
│   ├── providers/            # State management
│   ├── screens/              # UI screens
│   │   ├── admin/            # Admin screens
│   │   ├── onboarding/       # Onboarding flow
│   │   ├── provider/         # Loan provider screens
│   │   └── user/             # User screens
│   └── main.dart             # App entry point
├── backend/                  # FastAPI backend
│   ├── app/
│   │   ├── api/              # API endpoints
│   │   ├── core/             # Core config
│   │   ├── models/           # Pydantic models
│   │   └── services/         # Business logic
│   ├── main.py               # Server entry point
│   └── requirements.txt      # Python dependencies
├── assets/                   # Images and fonts
└── test/                     # Unit tests
```

## 🔧 Configuration

### API Base URL

The app automatically switches between localhost (web) and IP address (mobile):

```dart
// lib/core/constants/api_endpoints.dart
static String get baseUrl {
  if (kIsWeb) {
    return 'http://localhost:8000';      // Web/Chrome
  } else {
    return 'http://192.168.1.5:8000';    // Mobile/Emulator
  }
}
```

Update the IP address to match your computer's local network IP.

### Running on Mobile Device

1. Ensure phone and computer are on the **same WiFi network**
2. Find your computer's IP: `ipconfig` (Windows) or `ifconfig` (Mac/Linux)
3. Update `baseUrl` in `api_endpoints.dart`
4. Run: `flutter run -d <device_id>`

### Using ngrok for Remote Testing

```powershell
# Terminal 1: Start Flutter web
flutter run -d web-server --web-port 8080

# Terminal 2: Expose via ngrok
ngrok http 8080

# Use the ngrok URL on any device
```

## 🧪 Testing

### Run Flutter Tests
```bash
flutter test
```

### Run Backend Tests
```bash
cd backend
pytest
```

## 📦 Building for Production

### Android APK
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle
```bash
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Flutter](https://flutter.dev) for the amazing UI framework
- [FastAPI](https://fastapi.tiangolo.com) for the high-performance backend
- [Firebase](https://firebase.google.com) for authentication and database
- [Tesseract OCR](https://github.com/tesseract-ocr/tesseract) for document scanning
- [Stripe](https://stripe.com) for payment processing

## 📞 Support

For support, email sahayloanapp@gmail.com or join our Slack channel.

## 🔗 Links

- [Live Demo](https://your-demo-link.com)
- [Documentation](https://your-docs-link.com)
- [Issue Tracker](https://github.com/Shravan157/Sahay-Loan/issues)

---

Made with ❤️ for underserved communities in India
