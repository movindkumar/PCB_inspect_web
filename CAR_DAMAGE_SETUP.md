# Car Damage Assessment System - Quick Setup

## Configuration Updated ✓

Your system has been updated to work with your car damage dataset at:
```
C:\Users\movin\car_damage_dataset
```

## What Changed

### Backend Updates
- **Model Path:** Now points to `C:\Users\movin\car_damage_dataset`
- **Classifications:** Updated to car damage levels:
  - No Damage
  - Minor Damage
  - Moderate Damage
  - Severe Damage
- **Recommendations:** Changed from PCB to vehicle damage context
- **API Title:** "Vehicle Damage Assessment API"

### Flutter Updates
- **Image Selection:** Added 3 ways to select images:
  1. **Camera** - Capture image with device camera
  2. **Gallery** - Select from photo library
  3. **Browse** - Browse filesystem to directly select image files

## Quick Start

### 1. Install Dependencies
```bash
# Install Python packages
cd backend
pip install -r requirements.txt

# Install Flutter packages
cd ..
flutter pub get
```

### 2. Prepare Your Model
Place your trained car damage model in: `C:\Users\movin\car_damage_dataset`

The backend will automatically detect and load:
- `model.h5`
- `model.keras`
- `saved_model/saved_model.pb`

### 3. Start Backend
```bash
cd backend
python main.py
```

Expected output:
```
INFO:     Uvicorn running on http://0.0.0.0:8000
INFO:     Model successfully loaded from: C:\Users\movin\car_damage_dataset\model.h5
```

### 4. Start Flutter App
```bash
flutter run
```

### 5. Login
- **Username:** `admin`
- **Password:** `123`

### 6. Navigate to Image Analysis
1. Click the prediction icon in top-right of results page
2. You'll see 3 image selection buttons:
   - **Camera** - Take new photo
   - **Gallery** - Select from phone/computer galleries
   - **Browse** - Browse filesystem directly to your dataset

## Using Browse Files Feature

The "Browse" button now opens your file system, allowing you to:
- Navigate to your `car_damage_dataset` folder
- Select specific images for analysis
- Test multiple images quickly

This is especially useful for testing since you can directly access your training/test images.

## API Endpoints

### Single Image Prediction
```bash
curl -X POST "http://localhost:8000/predict" \
  -F "file=@car_damage_image.jpg"
```

Response:
```json
{
  "status": "success",
  "classification": "Minor Damage",
  "confidence": 0.9245,
  "filename": "car_damage_image.jpg",
  "class_scores": {
    "No Damage": 0.0125,
    "Minor Damage": 0.9245,
    "Moderate Damage": 0.0512,
    "Severe Damage": 0.0118
  },
  "risk_level": "Low-Medium (High Confidence)",
  "recommendation": "Minor repairs recommended - Can be driven with caution"
}
```

### Health Check
```bash
curl http://localhost:8000/health
```

### Model Info
```bash
curl http://localhost:8000/model-info
```

## Troubleshooting

### Issue: "Model not found" in backend logs
**Solution:**
1. Check that your model file exists in `C:\Users\movin\car_damage_dataset`
2. Verify the filename matches one of:
   - `model.h5`
   - `model.keras`
   - `saved_model/saved_model.pb`
3. If using different name, copy to one of these names

### Issue: Browse button doesn't work on Android
**Solution:**
This is expected - browse files works on:
- Windows (desktop)
- Mac (desktop)
- iOS
Stick to Camera or Gallery on Android.

### Issue: "Backend unavailable" in Flutter app
**Solution:**
1. Ensure backend Python server is running
2. Check backend URL in `lib/services/api_service.dart`:
   - For local: `http://localhost:8000`
   - For Android emulator: `http://10.0.2.2:8000`
   - For physical device: Use your machine's IP address

## Next Steps

1. **Train Your Model**
   - Use your car damage dataset
   - Save as `model.h5` in `C:\Users\movin\car_damage_dataset`

2. **Test System**
   - Login
   - Navigate to Image Prediction
   - Use Browse to select test images
   - Verify predictions are correct

3. **Deploy (Optional)**
   - Use FastAPI + Docker for production
   - Deploy to cloud (AWS, GCP, Azure)
   - Update API URL in Flutter

## File Structure
```
C:\Users\movin
└── car_damage_dataset/
    ├── model.h5                    # Your trained model
    ├── train_images/               # Training images
    ├── test_images/                # Test images
    └── validation_images/          # Validation images

flutter_application_1/
├── backend/
│   ├── main.py
│   ├── requirements.txt
│   └── config.py
├── lib/
│   ├── prediction_page.dart        # Image selection UI
│   ├── services/api_service.dart   # API communication
│   └── ...
└── pubspec.yaml
```

## Support Files
- `SETUP_GUIDE.md` - Complete technical documentation
- `backend/README.md` - API documentation
- `quickstart.bat` - Windows automation script
- `quickstart.sh` - Linux/Mac automation script

Good luck with your car damage detection system! 🚗
