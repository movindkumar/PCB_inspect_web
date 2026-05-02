@echo off
REM PCB AI Application - Quick Start Script for Windows
REM This script helps set up and run the entire application

echo.
echo ============================================
echo  PCB AI Defect Detection System - Quick Start
echo ============================================
echo.

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Python is not installed or not in PATH
    echo Please install Python 3.9+ from https://www.python.org
    pause
    exit /b 1
)

echo [✓] Python found
echo.

REM Check if Flutter is installed
flutter --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Flutter is not installed or not in PATH
    echo Please install Flutter from https://flutter.dev
    pause
    exit /b 1
)

echo [✓] Flutter found
echo.

REM Menu
echo Select an option:
echo.
echo 1. Install dependencies
echo 2. Start backend server (FastAPI)
echo 3. Run Flutter app
echo 4. Start both backend and app
echo 5. API Documentation (http://localhost:8000/docs)
echo 6. Clean and reinstall
echo 0. Exit
echo.

set /p choice="Enter your choice (0-6): "

if "%choice%"=="1" goto install_deps
if "%choice%"=="2" goto start_backend
if "%choice%"=="3" goto start_flutter
if "%choice%"=="4" goto start_both
if "%choice%"=="5" goto api_docs
if "%choice%"=="6" goto clean_install
if "%choice%"=="0" goto end
echo Invalid choice. Please try again.
pause
cls
goto menu

:install_deps
echo.
echo [*] Installing dependencies...
echo.
cd backend
echo [*] Installing Python dependencies...
pip install -r requirements.txt
cd ..
echo.
echo [*] Installing Flutter dependencies...
flutter pub get
echo.
echo [✓] Installation complete!
pause
cls
goto menu

:start_backend
echo.
echo [*] Starting FastAPI backend server...
echo [*] Server will run on http://localhost:8000
echo [*] API docs: http://localhost:8000/docs
echo [*] Press Ctrl+C to stop the server
echo.
cd backend
python main.py
cd ..
pause
cls
goto menu

:start_flutter
echo.
echo [*] Starting Flutter app...
echo [*] Make sure backend is running on localhost:8000
echo.
flutter run
pause
cls
goto menu

:start_both
echo.
echo [*] Starting both backend and Flutter app...
echo [*] Backend will run in a new window
echo.
start cmd /k "cd backend && python main.py"
echo [*] Waiting 5 seconds for backend to start...
timeout /t 5 /nobreak
echo [*] Starting Flutter app...
flutter run
pause
cls
goto menu

:api_docs
echo.
echo [*] Opening API documentation...
echo [*] Make sure backend is running!
echo.
start http://localhost:8000/docs
pause
cls
goto menu

:clean_install
echo.
echo [*] Cleaning and reinstalling...
echo.
echo [!] This will delete installed dependencies and rebuild
set /p confirm="Are you sure? (y/n): "
if /i "%confirm%"=="y" (
    echo [*] Cleaning Flutter...
    flutter clean
    echo [*] Cleaning Python cache...
    cd backend
    if exist __pycache__ rmdir /s /q __pycache__
    cd ..
    echo [*] Reinstalling dependencies...
    call :install_deps
) else (
    echo [*] Cancelled.
)
pause
cls
goto menu

:end
echo.
echo Thank you for using PCB AI System!
echo For more information, see SETUP_GUIDE.md
echo.
exit /b 0
