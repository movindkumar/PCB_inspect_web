@echo off
echo Starting PCB Defect Detection Backend...
echo.

:: Ensure the script runs in the directory where the .bat file is located
cd /d "%~dp0"

:: Activate the Anaconda virtual environment
echo Activating Anaconda environment 'fyp_env'...
:: Tell Windows exactly where Anaconda lives to activate the environment
call "C:\Apps\ANACONDA\Scripts\activate.bat" fyp_env
if errorlevel 1 (
    echo.
    echo [ERROR] Could not activate conda environment 'fyp_env'.
    echo Please ensure Anaconda is installed and added to your system PATH.
    pause
    exit /b 1
)

:: Note: If you ever add new packages to requirements.txt, remove the "::" from the line below to install them automatically.
:: pip install -r requirements.txt

:: Start the server
echo.
echo ========================================================
echo Starting FastAPI server...
echo API will be available at:   http://localhost:8000
echo Health check endpoint:      http://localhost:8000/health
echo Prediction endpoint:        http://localhost:8000/predict
echo ========================================================
echo Press Ctrl+C to stop the server
echo.

:: Launch the backend script
python main.py

:: Prevent the terminal window from closing immediately if there is an error
pause