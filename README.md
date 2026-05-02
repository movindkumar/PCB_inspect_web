# PCB Damage Detection App

A Flutter application for detecting and analyzing car damage using AI and Firebase.

## Features

- 🔍 **AI-Powered Damage Detection**: Upload images and get instant damage analysis
- 📊 **Detailed Classification**: Get confidence scores and risk assessments
- ☁️ **Firebase Integration**: Store predictions and user data in the cloud
- 📱 **Cross-Platform**: Works on Android, iOS, Web, and Desktop
- 🔐 **User Management**: Login system with user profiles

## Quick Start

### Prerequisites
- Flutter SDK (^3.11.4)
- Dart SDK
- Google account (for Firebase)

### 1. Clone and Setup
```bash
git clone <your-repo-url>
cd flutter_application_1
flutter pub get
```

### 2. Firebase Setup
**IMPORTANT**: Follow the complete Firebase setup guide:

1. 📖 Read `FIREBASE_SETUP.md` for detailed instructions
2. 🔥 Create Firebase project at [Firebase Console](https://console.firebase.google.com/)
3. 📱 Add Android and Web apps to your Firebase project
4. ⚙️ Update `lib/firebase_options.dart` with your Firebase config
5. 🗄️ Enable Firestore Database
6. 📁 Place `google-services.json` in `android/app/`

### 3. Run Setup Script
```bash
# Windows
setup_firebase.bat

# Linux/Mac
./setup_firebase.sh
```

### 4. Run the App
```bash
# Web (recommended for testing)
flutter run -d chrome --web-port=8082 --web-browser-flag="--disable-web-security"

# Android
flutter run

# iOS (macOS only)
flutter run
```

## Project Structure

```
lib/
├── main.dart                 # App entry point with Firebase init
├── login_page.dart           # User authentication
├── prediction_page.dart      # Main damage detection UI
├── ai_results_page.dart      # Results display
└── services/
    ├── api_service.dart      # Backend API communication
    ├── firebase_service.dart # Firebase database operations
    └── firebase_test_service.dart # Firebase connection testing

backend/
├── main.py                  # Python Flask API server
├── config.py                # API configuration
└── requirements.txt         # Python dependencies
```

## Firebase Features

- **Firestore Database**: Store prediction results and user data
- **Realtime Database**: Real-time data synchronization
- **User Profiles**: Track user activity and preferences
- **Prediction History**: Save all damage analysis results
- **Analytics**: Monitor app usage and performance

## API Integration

The app connects to a Python backend for AI processing:
- **Endpoint**: `http://localhost:5000/predict`
- **Input**: Image file (JPEG/PNG)
- **Output**: JSON with classification, confidence, and recommendations

## Development

### Adding New Features
1. Create feature branch: `git checkout -b feature/new-feature`
2. Implement changes
3. Test Firebase integration
4. Submit pull request

### Testing Firebase
The app automatically tests Firebase connection on startup. Check console for:
```
[App] ✓ Firebase initialized successfully
[App] ✓ Firebase connection test passed
```

### Building for Production
```bash
# Android APK
flutter build apk --release

# Web
flutter build web

# iOS (macOS only)
flutter build ios
```

## Troubleshooting

### Firebase Issues
- Check `FIREBASE_SETUP.md` for configuration steps
- Verify `firebase_options.dart` has correct values
- Ensure Firestore security rules allow read/write

### Build Issues
```bash
flutter clean
flutter pub get
flutter doctor
```

### API Issues
- Start backend server: `cd backend && python main.py`
- Check API logs for errors
- Verify image format compatibility

## Contributing

1. Fork the repository
2. Create feature branch
3. Commit changes
4. Push to branch
5. Create Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For issues and questions:
1. Check `FIREBASE_SETUP.md` and `SETUP_GUIDE.md`
2. Review console logs for error messages
3. Test with Firebase examples
4. Open GitHub issue with detailed description
