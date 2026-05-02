@echo off
echo Starting PCB Defect Detection Backend...
echo.

cd /d "%~dp0"

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo Error: Python is not installed or not in PATH
    echo Please install Python 3.8+ from https://python.org
    pause
    exit /b 1
)

REM Check if virtual environment exists, create if not
if not exist venv (
    echo Creating virtual environment...
    python -m venv venv
)

REM Activate virtual environment
call venv\Scripts\activate.bat

REM Install requirements
echo Installing dependencies...
pip install -r requirements.txt

REM Start the server
echo.
echo Starting FastAPI server...
echo API will be available at: http://localhost:8000
echo Health check: http://localhost:8000/health
echo Prediction endpoint: http://localhost:8000/predict
echo.
echo Press Ctrl+C to stop the server
echo.

python main.py