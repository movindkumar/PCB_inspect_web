#!/bin/bash

# PCB AI Application - Quick Start Script for Linux/macOS
# This script helps set up and run the entire application

clear

echo "============================================"
echo "  PCB AI Defect Detection System - Quick Start"
echo "============================================"
echo ""

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "[ERROR] Python 3 is not installed or not in PATH"
    echo "Please install Python 3.9+ from https://www.python.org"
    exit 1
fi

python3 --version
echo "[✓] Python found"
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "[ERROR] Flutter is not installed or not in PATH"
    echo "Please install Flutter from https://flutter.dev"
    exit 1
fi

flutter --version
echo "[✓] Flutter found"
echo ""

# Menu function
show_menu() {
    echo "Select an option:"
    echo ""
    echo "1. Install dependencies"
    echo "2. Start backend server (FastAPI)"
    echo "3. Run Flutter app"
    echo "4. Start both backend and app"
    echo "5. Open API Documentation"
    echo "6. Test API endpoints"
    echo "7. Clean and reinstall"
    echo "0. Exit"
    echo ""
}

# Helper functions
install_dependencies() {
    echo ""
    echo "[*] Installing dependencies..."
    echo ""
    
    echo "[*] Installing Python dependencies..."
    cd backend
    pip3 install -r requirements.txt
    cd ..
    
    echo ""
    echo "[*] Installing Flutter dependencies..."
    flutter pub get
    
    echo ""
    echo "[✓] Installation complete!"
    echo ""
}

start_backend() {
    echo ""
    echo "[*] Starting FastAPI backend server..."
    echo "[*] Server will run on http://localhost:8000"
    echo "[*] API docs: http://localhost:8000/docs"
    echo "[*] Press Ctrl+C to stop the server"
    echo ""
    
    cd backend
    python3 main.py
    cd ..
}

start_flutter() {
    echo ""
    echo "[*] Starting Flutter app..."
    echo "[*] Make sure backend is running on localhost:8000"
    echo ""
    
    flutter run
}

start_both() {
    echo ""
    echo "[*] Starting backend server..."
    
    # Start backend in background
    cd backend
    python3 main.py &
    BACKEND_PID=$!
    cd ..
    
    echo "[*] Backend started (PID: $BACKEND_PID)"
    echo "[*] Waiting 5 seconds for backend to initialize..."
    sleep 5
    
    echo "[*] Starting Flutter app..."
    flutter run
    
    # Kill backend when done
    kill $BACKEND_PID 2>/dev/null
}

test_api() {
    echo ""
    echo "[*] Testing API endpoints..."
    echo ""
    
    # Health check
    echo "[*] Testing health endpoint..."
    curl -s http://localhost:8000/health | python3 -m json.tool
    echo ""
    
    # Model info
    echo "[*] Testing model info endpoint..."
    curl -s http://localhost:8000/model-info | python3 -m json.tool
    echo ""
    
    echo "[✓] API tests completed!"
    echo ""
}

clean_install() {
    echo ""
    echo "[*] Cleaning and reinstalling..."
    echo "[!] This will delete installed dependencies and rebuild"
    
    read -p "Are you sure? (y/n): " confirm
    
    if [[ $confirm == "y" || $confirm == "Y" ]]; then
        echo "[*] Cleaning Flutter..."
        flutter clean
        
        echo "[*] Cleaning Python cache..."
        cd backend
        find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null
        rm -rf .venv env venv 2>/dev/null
        cd ..
        
        echo "[*] Reinstalling dependencies..."
        install_dependencies
    else
        echo "[*] Cancelled."
    fi
    
    echo ""
}

# Main loop
while true; do
    show_menu
    read -p "Enter your choice (0-7): " choice
    
    case $choice in
        1) install_dependencies ;;
        2) start_backend ;;
        3) start_flutter ;;
        4) start_both ;;
        5) 
            echo ""
            echo "[*] Opening API documentation..."
            if command -v xdg-open &> /dev/null; then
                xdg-open http://localhost:8000/docs
            elif command -v open &> /dev/null; then
                open http://localhost:8000/docs
            else
                echo "[*] Please open http://localhost:8000/docs in your browser"
            fi
            echo ""
            ;;
        6) test_api ;;
        7) clean_install ;;
        0) 
            echo ""
            echo "Thank you for using PCB AI System!"
            echo "For more information, see SETUP_GUIDE.md"
            echo ""
            exit 0
            ;;
        *)
            echo "[ERROR] Invalid choice. Please try again."
            echo ""
            ;;
    esac
    
    read -p "Press Enter to continue..."
    clear
done
