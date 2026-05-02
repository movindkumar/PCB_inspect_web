@echo off
echo ========================================
echo  PCB Damage Detection - Firebase Setup
echo ========================================
echo.

echo Step 1: Installing Flutter dependencies...
flutter pub get
if %errorlevel% neq 0 (
    echo ERROR: Failed to install dependencies
    pause
    exit /b 1
)
echo ✓ Dependencies installed successfully
echo.

echo Step 2: Checking Firebase configuration...
if not exist "lib\firebase_options.dart" (
    echo ERROR: firebase_options.dart not found
    echo Please create this file with your Firebase config
    pause
    exit /b 1
)
echo ✓ Firebase options file found
echo.

echo Step 3: Checking Android config...
if not exist "android\app\google-services.json" (
    echo WARNING: google-services.json not found
    echo Please download this from Firebase console
    echo Continuing anyway...
) else (
    echo ✓ Android config file found
)
echo.

echo Step 4: Building app...
flutter build apk --debug
if %errorlevel% neq 0 (
    echo ERROR: Build failed
    pause
    exit /b 1
)
echo ✓ Build successful
echo.

echo ========================================
echo  Setup Complete!
echo ========================================
echo.
echo Next steps:
echo 1. Create Firebase project at https://console.firebase.google.com/
echo 2. Add Android app and download google-services.json
echo 3. Add Web app and copy config to firebase_options.dart
echo 4. Enable Firestore Database
echo 5. Run the app: flutter run
echo.
echo For detailed instructions, see FIREBASE_SETUP.md
echo.
pause