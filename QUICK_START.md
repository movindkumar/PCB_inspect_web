# 🚗 Vehicle Damage Assessment API - Quick Reference

## ✅ SETUP COMPLETE!

Your FastAPI backend is **RUNNING** and ready for image analysis.

---

## 🌐 Access Points

### Web Interface (Image Upload & Analysis)
```
http://localhost:8000/index          ← Use from this computer
http://10.12.167.59:8000/index       ← Use from other laptops
```

### API Health Check
```
http://localhost:8000/               ← Returns: {"status":"online", ...}
```

### API Documentation (Swagger UI)
```
http://localhost:8000/docs           ← Interactive API testing
http://10.12.167.59:8000/docs        ← From other computers
```

---

## 📱 For Flutter App

### Update Connection
Edit file: `lib/services/api_service.dart`

```dart
// Change this line:
static const String baseUrl = 'http://127.0.0.1:8000';

// To this:
static const String baseUrl = 'http://10.12.167.59:8000';
```

---

## 📤 Upload Image & Analyze

### Option 1: Web Interface
1. Open `http://10.12.167.59:8000/index` in your browser
2. Drag & drop or click to upload image
3. Click "Analyze Image"
4. See results immediately

### Option 2: Flutter Mobile App
1. Update API URL (see above)
2. Run: `flutter run`
3. Use the app to select images
4. View predictions in real-time

### Option 3: Command Line
```bash
CURL POST http://10.12.167.59:8000/predict \
  -F "file=@your_image.jpg"
```

---

## 🎯 Features Included

✅ Single image analysis
✅ Batch processing (multiple images)
✅ CORS enabled (works with Flutter/Web)
✅ Demo mode with realistic predictions
✅ Web interface for easy testing
✅ API documentation (Swagger UI)
✅ Health checks and status monitoring

---

## 🔧 Current Config

| Setting | Value |
|---------|-------|
| **Host** | 0.0.0.0 (all interfaces) |
| **Port** | 8000 |
| **Your IP** | 10.12.167.59 |
| **Model Status** | Demo Mode ✓ |
| **Running** | Yes ✓ |

---

## 📊 API Endpoints

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/` | GET | Health check |
| `/model-info` | GET | Model information |
| `/predict` | POST | Analyze single image |
| `/batch-predict` | POST | Analyze multiple images |
| `/docs` | GET | Swagger API docs |
| `/index` | GET | Web interface |

---

## 🖥️ Server Terminal

The server is running in this terminal:
```
PS C:\Users\movin\Downloads\PCB\flutter_application_1\backend>
python -m uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

✅ **Status**: Running
✅ **Auto-reload**: Enabled (changes auto-apply)
✅ **All interfaces**: Listening on 0.0.0.0:8000

---

## 📝 Response Example

```json
{
  "status": "success",
  "classification": "Minor Damage",
  "confidence": 0.8524,
  "filename": "car_image.jpg",
  "class_scores": {
    "No Damage": 0.0123,
    "Minor Damage": 0.8524,
    "Moderate Damage": 0.1203,
    "Severe Damage": 0.0150
  },
  "risk_level": "Low",
  "recommendation": "Minor repair recommended"
}
```

---

## 🚀 Next Steps

1. **Test Web Interface**: Open `http://10.12.167.59:8000/index`
2. **Upload Images**: Try uploading a test image
3. **Configure Flutter App**: Update the API URL
4. **Run Flutter App**: Execute `flutter run`
5. **Analyze Images**: Use the app to analyze vehicle damage

---

## 📞 Troubleshooting

**Can't access from another computer?**
- Check if both are on same WiFi
- Firewall might block port 8000
- Try adding Python to Windows Firewall exceptions

**API not responding?**
- Server terminal should show "Application startup complete"
- Wait 5 seconds for full initialization
- Check if any errors in terminal

**Image upload fails?**
- Image must be JPG or PNG
- Maximum size: 50 MB
- Ensure image file isn't corrupted

---

## 💾 Project Structure

```
flutter_application_1/
├── backend/
│   ├── main.py              ← FastAPI server ✅ Running
│   ├── config.py            ← Configuration
│   ├── requirements.txt      ← Dependencies ✅ Installed
│   ├── README.md
│   └── index.html           ← Web interface ✅ Added
├── lib/
│   ├── main.dart
│   ├── login_page.dart
│   ├── prediction_page.dart
│   ├── ai_results_page.dart
│   └── services/
│       └── api_service.dart  ← Update baseUrl here
└── CONNECTION_SETUP.md      ← Detailed guide
```

---

**Your API is ready! Happy analyzing! 🎉**
