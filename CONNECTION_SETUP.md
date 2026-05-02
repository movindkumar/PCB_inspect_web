# 🚀 API Setup & Connection Guide

## ✅ API Status
Your FastAPI backend is now **RUNNING** and ready for image analysis!

### Server Details
- **Status**: ✅ Online
- **Host**: `0.0.0.0` (all network interfaces)
- **Port**: `8000`
- **Your IP**: `10.12.167.59`
- **API Base URL**: `http://10.12.167.59:8000`

---

## 🌐 Accessing the Web Interface

### Option 1: From This Computer
1. Open your browser
2. Go to: `http://localhost:8000/index`
3. You'll see the image upload interface

### Option 2: From Another Laptop (Same Network)
1. Open your browser on another laptop
2. Go to: `http://10.12.167.59:8000/index`
3. Upload and analyze images remotely

---

## 📱 Flutter App Configuration

### Step 1: Update the API Base URL
Open [lib/services/api_service.dart](../lib/services/api_service.dart) and change:

```dart
// OLD:
static const String baseUrl = 'http://127.0.0.1:8000';

// NEW:
static const String baseUrl = 'http://10.12.167.59:8000';
```

### Step 2: Verify Network Connection
- Ensure your phone/emulator is on the **same network** as your laptop
- For Android Emulator: Use `10.0.2.2:8000` to access host machine
- For Physical Device: Use `http://10.12.167.59:8000`

### Step 3: Run the Flutter App
```bash
flutter run
```

---

## 📊 API Endpoints Reference

### 1. **Health Check**
```
GET http://10.12.167.59:8000/
```
**Response**: Server status and model info
```json
{
  "status": "online",
  "service": "Vehicle Damage Assessment API",
  "version": "1.0.0",
  "model_loaded": false
}
```

### 2. **Analyze Single Image** (Main Endpoint)
```
POST http://10.12.167.59:8000/predict
Content-Type: multipart/form-data

Body:
  file: <binary image data>
```

**Response**:
```json
{
  "status": "success",
  "classification": "Minor Damage",
  "confidence": 0.8524,
  "filename": "car_damage.jpg",
  "class_scores": {
    "No Damage": 0.0123,
    "Minor Damage": 0.8524,
    "Moderate Damage": 0.1203,
    "Severe Damage": 0.015
  },
  "risk_level": "Low",
  "recommendation": "Minor repair recommended"
}
```

### 3. **Batch Analyze Multiple Images**
```
POST http://10.12.167.59:8000/batch-predict
Content-Type: multipart/form-data

Body:
  files: [image1.jpg, image2.jpg, image3.jpg, ...]
```

**Response**:
```json
{
  "status": "success",
  "total_processed": 3,
  "results": [
    {
      "filename": "image1.jpg",
      "classification": "Minor Damage",
      "confidence": 0.8524
    },
    ...
  ]
}
```

### 4. **Get Model Information**
```
GET http://10.12.167.59:8000/model-info
```

**Response**:
```json
{
  "status": "success",
  "classes": [
    "No Damage",
    "Minor Damage",
    "Moderate Damage",
    "Severe Damage"
  ],
  "input_size": [224, 224],
  "model_loaded": false,
  "total_classes": 4
}
```

### 5. **Interactive API Documentation**
```
http://10.12.167.59:8000/docs
```
(Swagger UI - Test endpoints directly in browser)

---

## 🖥️ Web Interface Features

### Upload Image
1. Click or drag-drop an image
2. Click "Analyze Image" button
3. View detailed classification results

### Results Display
- **Classification**: Damage type (No/Minor/Moderate/Severe)
- **Confidence**: Accuracy percentage
- **Risk Level**: Overall risk assessment
- **Class Scores**: Breakdown of all classifications
- **Recommendation**: Suggested action

---

## 🔧 Troubleshooting

### Connection Issues
**Problem**: Can't reach `http://10.12.167.59:8000`
- ✅ Check if both devices are on same WiFi network
- ✅ Check Windows Firewall allows port 8000
- ✅ Try with `http://localhost:8000` if on same computer

**Solution**: Open Windows Defender Firewall
1. Go to Settings → Firewall → Allow apps through firewall
2. Click "Allow another app"
3. Find `python.exe` and click Add
4. Check both Private and Public checkboxes

### API Not Responding
**Problem**: 502 Bad Gateway or Connection Refused
- ✅ Verify the server is running (check terminal)
- ✅ Wait a moment for the server to fully start
- ✅ Try refreshing the page

### Image Upload Fails
**Problem**: 400 Error or file type error
- ✅ Ensure image is JPG or PNG format
- ✅ File size should be under 50 MB
- ✅ Check image isn't corrupted

---

## 🤖 AI Model Integration (Optional)

Currently, the API runs in **Demo Mode** (random predictions). To use real AI predictions:

### Step 1: Place Your Model
Copy your trained model to:
```
C:\Users\movin\car_damage_dataset\model.h5
```
or
```
C:\Users\movin\car_damage_dataset\model.keras
```

### Step 2: Verify TensorFlow Installation
```bash
cd backend
pip install tensorflow --upgrade
```

### Step 3: Update Model Path (if needed)
Edit `main.py` line 47-56 to point to your model location.

### Step 4: Restart the Server
Stop current server (Ctrl+C) and restart:
```bash
python -m uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

The API will automatically load your model on startup!

---

## 📝 Quick Start Commands

**Start the backend (from project root)**:
```bash
cd backend
python -m uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

**Run Flutter app**:
```bash
flutter run
```

**Test API from command line**:
```bash
# Health check
curl http://10.12.167.59:8000/

# Get model info
curl http://10.12.167.59:8000/model-info

# Upload and analyze image
curl -X POST -F "file=@image.jpg" http://10.12.167.59:8000/predict
```

---

## 🎯 Network Diagram

```
┌─────────────────────────────────────────┐
│         Your Laptop (Server)            │
│  IP: 10.12.167.59                       │
│  ┌─────────────────────────────────┐    │
│  │  FastAPI Backend (Port 8000)    │    │
│  │  ✓ Health check (/              │    │
│  │  ✓ Image upload (/predict)      │    │
│  │  ✓ Batch processing             │    │
│  │  ✓ Web UI (/index)              │    │
│  └─────────────────────────────────┘    │
└──────────────┬──────────────────────────┘
               │ WiFi Network
       ┌───────┴────────┐
       │                │
┌──────▼──────┐  ┌──────▼──────┐
│  Other PC   │  │  Flutter    │
│ (Browser)   │  │    App      │
│ :8000/index │  │  (Phone)    │
└─────────────┘  └─────────────┘
```

---

## 📞 Support & Next Steps

1. **Test the API**: Visit `http://10.12.167.59:8000/index` in your browser
2. **Upload test images**: Use the web interface to verify it works
3. **Configure Flutter**: Update the API URL in the app
4. **Run the app**: Test image analysis from your device

**Server Terminal Output Example**:
```
INFO:     Will watch for changes in these directories: [...]
INFO:     Uvicorn running on http://0.0.0.0:8000
INFO:     Started server process [18128]
INFO:     Application startup complete.
```

When you see "Application startup complete", your API is ready! 🎉
