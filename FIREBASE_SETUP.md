# 🚀 Firebase Setup Guide - PCB Damage Detection App

## 📋 Prerequisites

Before setting up Firebase, make sure you have:
- ✅ Flutter app running
- ✅ Google account
- ✅ Internet connection

---

## 🔥 Step 1: Create Firebase Project

### 1.1 Go to Firebase Console
1. Open [Firebase Console](https://console.firebase.google.com/)
2. Click **"Create a project"** or **"Add project"**
3. Enter project name: `pcb-damage-detection`
4. Enable Google Analytics (optional but recommended)
5. Choose Google Analytics account
6. Click **"Create project"**

### 1.2 Wait for project creation
- This takes 1-2 minutes
- You'll see "Your new project is ready" message

---

## 📱 Step 2: Add Android App

### 2.1 Register Android app
1. Click the **Android icon** in "Get started by adding Firebase to your app"
2. **Android package name**: `com.example.flutter_application_1`
3. **App nickname**: `PCB Damage Detection`
4. Click **"Register app"**

### 2.2 Download config file
1. Download `google-services.json`
2. Place it in: `android/app/google-services.json`

### 2.3 Add Firebase SDK
The dependencies are already added to `pubspec.yaml`:
```yaml
firebase_core: ^3.1.0
firebase_database: ^11.0.0
cloud_firestore: ^5.0.0
```

---

## 🌐 Step 3: Add Web App

### 3.1 Register web app
1. Click the **Web icon** (`</>`) in Firebase console
2. **App nickname**: `PCB Web App`
3. Check **"Also set up Firebase Hosting"** (optional)
4. Click **"Register app"**

### 3.2 Copy Firebase config
You'll see Firebase config like this:
```javascript
const firebaseConfig = {
  apiKey: "AIzaSyC...",
  authDomain: "pcb-damage-detection.firebaseapp.com",
  projectId: "pcb-damage-detection",
  storageBucket: "pcb-damage-detection.appspot.com",
  messagingSenderId: "123456789",
  appId: "1:123456789:web:abcdef123456",
  measurementId: "G-ABCDEFGHIJ"
};
```

---

## ⚙️ Step 4: Update Firebase Configuration

### 4.1 Update `lib/firebase_options.dart`

Replace the placeholder values with your actual Firebase config:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'your-actual-web-api-key',
  appId: 'your-actual-web-app-id',
  messagingSenderId: 'your-actual-sender-id',
  projectId: 'your-actual-project-id',
  authDomain: 'your-project-id.firebaseapp.com',
  storageBucket: 'your-project-id.appspot.com',
  measurementId: 'your-actual-measurement-id',
);

static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'your-actual-android-api-key',
  appId: 'your-actual-android-app-id',
  messagingSenderId: 'your-actual-sender-id',
  projectId: 'your-actual-project-id',
  storageBucket: 'your-project-id.appspot.com',
);
```

### 4.2 Find your config values

**From Firebase Console:**
- **Project ID**: Found in project settings
- **Web API Key**: In web app settings
- **Android API Key**: In Android app settings
- **App IDs**: In respective app settings

---

## 🗄️ Step 5: Enable Database Services

### 5.1 Enable Firestore
1. Go to **Firestore Database** in Firebase console
2. Click **"Create database"**
3. Choose **"Start in test mode"** (for development)
4. Select location (choose closest to your users)
5. Click **"Done"**

### 5.2 Enable Realtime Database (Optional)
1. Go to **Realtime Database** in Firebase console
2. Click **"Create database"**
3. Choose **"Start in test mode"**
4. Select location
5. Click **"Done"**

---

## 🚀 Step 6: Run the App

### 6.1 Install dependencies
```bash
flutter pub get
```

### 6.2 Run the app
```bash
# For web
flutter run -d chrome --web-port=8082 --web-browser-flag="--disable-web-security"

# For Android
flutter run
```

### 6.3 Test Firebase connection
The app will automatically test Firebase connection on startup. Check console for:
```
[Firebase] ✓ Firebase initialized successfully
[Firebase] ✓ Firebase connection test successful
```

---

## 📊 Step 7: Test Database Features

### 7.1 Make a prediction
1. Upload an image in the app
2. Click "ANALYZE IMAGE"
3. Check console for Firebase save confirmation:
```
[Firebase] ✓ Prediction saved to Firestore
```

### 7.2 Check Firebase Console
1. Go to **Firestore Database** in Firebase console
2. You should see collections:
   - `users` - User profiles
   - `predictions` - Prediction history

### 7.3 View data structure
```
Firestore:
├── users/
│   └── {userId}/
│       ├── username: "testuser"
│       ├── email: "user@example.com"
│       ├── totalPredictions: 5
│       └── lastLogin: timestamp
│
└── predictions/
    └── {predictionId}/
        ├── userId: "testuser"
        ├── imageName: "car_damage.jpg"
        ├── classification: "Minor Damage"
        ├── confidence: 0.85
        ├── riskLevel: "Low"
        ├── recommendation: "Minor repair recommended"
        ├── classScores: { ... }
        └── timestamp: timestamp
```

---

## 🔧 Troubleshooting

### Issue: "Firebase not initialized"
**Solution**: Check that `firebase_options.dart` has correct values

### Issue: "Permission denied"
**Solution**: Make sure Firestore is in "test mode" or set proper security rules

### Issue: "Platform not supported"
**Solution**: Check that all platforms are configured in Firebase console

### Issue: "Build failed"
**Solution**: Run `flutter clean` then `flutter pub get`

---

## 📈 Firebase Features Added

### ✅ **User Management**
- Save user profiles
- Track prediction counts
- Store user preferences

### ✅ **Prediction History**
- Save all predictions to database
- Retrieve user's prediction history
- Real-time synchronization

### ✅ **Analytics**
- Track total predictions
- Classification statistics
- User activity metrics

### ✅ **Cross-Platform**
- Works on Web, Android, iOS
- Real-time data sync
- Offline capabilities

---

## 🎯 Next Steps

1. **Set up authentication** (optional)
2. **Add data validation** in security rules
3. **Implement offline support**
4. **Add push notifications**
5. **Create admin dashboard**

---

## 📞 Support

If you encounter issues:
1. Check Firebase console for error messages
2. Verify configuration values
3. Test with Firebase's online examples
4. Check Flutter Firebase documentation

**Your app now has full Firebase database integration! 🎉**
