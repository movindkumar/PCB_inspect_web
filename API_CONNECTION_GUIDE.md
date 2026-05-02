# API Connection Guide - Complete Integration

## Overview
The Flutter app is now fully integrated with the FastAPI backend for vehicle damage assessment. All API calls are logged with detailed debugging information.

## API Endpoint Configuration

### Current Setup
```dart
static const String baseUrl = 'http://127.0.0.1:8000';
```

### For Different Environments

**Option 1: Local Development (Default)**
```dart
static const String baseUrl = 'http://127.0.0.1:8000';
```
- Requires FastAPI running on your machine
- Command: `python backend/main.py`
- Works on Desktop/Web

**Option 2: Android Emulator**
```dart
static const String baseUrl = 'http://10.0.2.2:8000';
```
- Use `10.0.2.2` instead of `localhost` in Android emulator
- FastAPI should run on host machine

**Option 3: Physical Device**
```dart
static const String baseUrl = 'http://YOUR_MACHINE_IP:8000';
```
- Replace `YOUR_MACHINE_IP` with your machine's actual IP
- Example: `http://192.168.1.100:8000`
- Get IP using: `ipconfig` (Windows) or `ifconfig` (Mac/Linux)

**Option 4: Production Server**
```dart
static const String baseUrl = 'https://your-api.com';
```
- Use HTTPS in production
- Must be a valid domain/IP

## API Endpoints Reference

### 1. Health Check
Verifies backend is running and responding.

```
GET http://127.0.0.1:8000/health
```

**Response:**
```json
{
  "status": "healthy",
  "service": "vehicle_damage_assessment_api",
  "model_ready": true,
  "timestamp": "2026-04-05T14:32:18.123456"
}
```

### 2. Model Information
Get information about available damage classes.

```
GET http://127.0.0.1:8000/model-info
```

**Response:**
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
  "model_loaded": true,
  "total_classes": 4
}
```

### 3. Image Prediction (Main Endpoint)
Analyze a single vehicle image for damage.

```
POST http://127.0.0.1:8000/predict
Content-Type: multipart/form-data

Body:
  file: <binary image data>
```

**Response:**
```json
{
  "status": "success",
  "classification": "Minor Damage",
  "confidence": 0.9245,
  "filename": "car_image.jpg",
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

### 4. Batch Prediction
Process multiple images at once.

```
POST http://127.0.0.1:8000/batch-predict
Content-Type: multipart/form-data

Body:
  files: [<binary image 1>, <binary image 2>, ...]
```

**Response:**
```json
{
  "status": "success",
  "total_processed": 3,
  "results": [
    {
      "filename": "car1.jpg",
      "classification": "No Damage",
      "confidence": 0.9823
    },
    {
      "filename": "car2.jpg",
      "classification": "Moderate Damage",
      "confidence": 0.8756
    }
  ]
}
```

## Debugging & Logs

### Console Logs
The app logs API calls with `[API]` and `[UI]` prefixes:

```
[API] Performing health check to http://127.0.0.1:8000/health
[API] Health check SUCCESS: 200
[API] Starting image prediction for: /path/to/image.jpg
[API] Endpoint: http://127.0.0.1:8000/predict
[API] Image file size: 2.45 MB
[API] Multipart request created, sending to server...
[API] Response received: 200
[API] ✓ Prediction successful!
[API] Classification: Minor Damage
[API] Confidence: 92.45%
[UI] ✓ Backend is available and responding
```

### Debug Information Panel
The app includes a collapsible "Debug Information" section at the bottom of the prediction page showing:
- API Endpoint being used
- Backend connection status
- Image selection status
- File path information

### Error Messages

**Error: "Backend Unavailable"**
```
Cause: FastAPI server not running
Solution: 
  1. Open terminal
  2. Navigate to backend folder: cd backend
  3. Run: python main.py
  4. Should see: Uvicorn running on http://0.0.0.0:8000
```

**Error: "Network Error (SocketException)"**
```
Cause: Cannot reach backend server
Possible reasons:
  1. Server not running
  2. Wrong IP address
  3. Firewall blocking port 8000
  4. Network connectivity issue
```

**Error: "Request timeout (>30 seconds)"**
```
Cause: Server too slow to respond
Possible reasons:
  1. Image too large
  2. Model inference slow
  3. Server under heavy load
Solution: Try with smaller image or check server logs
```

**Error: "Invalid response JSON"**
```
Cause: Server returned malformed response
Solution: Check backend logs for errors
```

## Integration Code Pattern

The Flutter app uses this pattern for API calls:

```dart
// 1. Import the service
import 'services/api_service.dart';

// 2. Check backend availability
bool available = await ApiService.healthCheck();

// 3. Get model information
final modelInfo = await ApiService.getModelInfo();
print('Classes: ${modelInfo['classes']}');

// 4. Predict from image
final result = await ApiService.predictImage(imageFile);
if (result != null) {
  print('Classification: ${result.classification}');
  print('Confidence: ${result.confidence}');
  print('Recommendation: ${result.recommendation}');
}

// 5. Batch predict
final results = await ApiService.batchPredict([file1, file2, file3]);
```

## Development Checklist

- [ ] FastAPI backend installed (`pip install -r backend/requirements.txt`)
- [ ] Model placed in `C:\Users\movin\car_damage_dataset`
- [ ] Backend server running (`python backend/main.py`)
- [ ] Flutter dependencies installed (`flutter pub get`)
- [ ] API endpoint configured correctly in `api_service.dart`
- [ ] Image picker permissions granted (Android/iOS)
- [ ] Test health check endpoint from app
- [ ] Select image and test prediction
- [ ] Verify results display correctly
- [ ] Check console logs for debugging

## Testing the API Directly

### Using cURL (Command Line)

**Health Check:**
```bash
curl http://127.0.0.1:8000/health
```

**Get Model Info:**
```bash
curl http://127.0.0.1:8000/model-info
```

**Single Image Prediction:**
```bash
curl -X POST http://127.0.0.1:8000/predict \
  -F "file=@path/to/car_image.jpg"
```

**Batch Prediction:**
```bash
curl -X POST http://127.0.0.1:8000/batch-predict \
  -F "files=@image1.jpg" \
  -F "files=@image2.jpg" \
  -F "files=@image3.jpg"
```

### Using Python

```python
import requests
from pathlib import Path

# Single prediction
with open('car_image.jpg', 'rb') as f:
    files = {'file': f}
    response = requests.post('http://127.0.0.1:8000/predict', files=files)
    print(response.json())

# Batch prediction
files = [
    ('files', open('car1.jpg', 'rb')),
    ('files', open('car2.jpg', 'rb')),
]
response = requests.post('http://127.0.0.1:8000/batch-predict', files=files)
print(response.json())
```

## Performance Optimization

### Image Optimization
- **Max File Size:** 50 MB
- **Recommended:** Compress images to 1-5 MB
- **Format:** JPEG or PNG
- **Resolution:** 224x224 minimum (auto-resized by backend)

### Request Timeouts
- **Health Check:** 5 seconds
- **Single Prediction:** 30 seconds
- **Batch Prediction:** 60 seconds

### Optimization Tips
1. Compress images before upload
2. Use batch processing for multiple images
3. Ensure sufficient network bandwidth
4. Monitor backend logs for slow predictions

## Connection Flow Diagram

```
Flutter App
    │
    ├─→ [1. Health Check]
    │   ├─→ GET /health
    │   └─← {status: healthy}
    │
    ├─→ [2. Get Model Info]
    │   ├─→ GET /model-info
    │   └─← {classes: [...]}
    │
    ├─→ [3. Image Selection]
    │   └─ User selects image
    │
    └─→ [4. Prediction]
        ├─→ POST /predict (multipart/form-data)
        │   ├─ Image processing
        │   ├─ Model inference
        │   └─ Result generation
        └─← {classification, confidence, recommendation}
```

## Troubleshooting Checklist

### Problem: Backend shows "Unavailable"
- [ ] Is `python backend/main.py` running?
- [ ] Is port 8000 open?
- [ ] Check Windows Firewall/Antivirus
- [ ] Try `python -m uvicorn main:app --reload --port 8000`

### Problem: Image upload fails
- [ ] Image file exists?
- [ ] Image format is JPG/PNG?
- [ ] File size < 50 MB?
- [ ] Storage permissions granted?

### Problem: Prediction is slow
- [ ] Check backend console for errors
- [ ] Try with smaller image
- [ ] Check CPU/Memory usage
- [ ] Verify model is loaded (check logs)

### Problem: Wrong predictions
- [ ] Is the model trained correctly?
- [ ] Is image in correct format for model?
- [ ] Check model input size (224x224)
- [ ] Verify preprocessing matches training

## Next Steps

1. **Test Connection:**
   ```
   Login → Prediction Page → Click "Browse"
   Select test image → Click "ANALYZE IMAGE"
   Check console logs for API calls
   ```

2. **Check Logs:**
   - Watch Flutter console for `[API]` messages
   - Watch backend console for request logs
   - Cross-reference request/response timing

3. **Debug Issues:**
   - Use Debug Information panel in UI
   - Check console logs with `[API]` prefix
   - Test endpoints with cURL
   - Check backend error logs

4. **Production Deployment:**
   - Change baseUrl to production server
   - Use HTTPS instead of HTTP
   - Implement authentication/authorization
   - Set up monitoring and logging
   - Load balance for high volume

## Support Resources

- **Backend Logs:** Terminal running `python backend/main.py`
- **Flutter Logs:** Flutter console or `flutter logs`
- **API Docs:** http://127.0.0.1:8000/docs (Swagger UI)
- **API Docs:** http://127.0.0.1:8000/redoc (ReDoc UI)
- **FastAPI Guide:** https://fastapi.tiangolo.com
