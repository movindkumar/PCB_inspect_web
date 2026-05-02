# PCB AI Defect Detection System - Complete Setup Guide

## System Architecture
```
┌─────────────────────────────────────────────────────────────┐
│                    Flutter Mobile App                        │
│  (Login → Results Dashboard → Image Prediction)             │
└─────────────────────────────────────────────────────────────┘
                           ↓ (API Calls)
┌─────────────────────────────────────────────────────────────┐
│              FastAPI Backend (Python)                        │
│  • Image Upload Processing                                  │
│  • AI Model Inference (TensorFlow/Keras)                   │
│  • Prediction & Risk Assessment                             │
└─────────────────────────────────────────────────────────────┘
```

## Project Structure
```
flutter_application_1/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── login_page.dart          # Authentication (admin/123)
│   ├── ai_results_page.dart     # Training results dashboard
│   ├── prediction_page.dart     # Image analysis interface
│   └── services/
│       └── api_service.dart     # API client for backend
├── backend/
│   ├── main.py                  # FastAPI server
│   ├── config.py                # Configuration settings
│   ├── requirements.txt          # Python dependencies
│   ├── models/                  # Trained AI models storage
│   └── README.md                # Backend documentation
├── pubspec.yaml                 # Flutter dependencies
└── android/ios/web/...          # Platform-specific code
```

## Step-by-Step Setup

### Phase 1: Backend Setup

#### 1.1 Install Python Dependencies
```bash
cd backend
pip install -r requirements.txt
```

**What's installed:**
- `fastapi==0.104.1` - Web framework
- `uvicorn==0.24.0` - ASGI server
- `tensorflow==2.14.0` - AI/ML framework
- `numpy==1.24.3` - Numerical computing
- `pillow==10.0.1` - Image processing
- `python-multipart==0.0.6` - File uploads

#### 1.2 Prepare Your AI Model
```bash
# Create models directory
mkdir models

# Place your trained model here
# Supported formats: .h5, .pb, .pth (after conversion)
```

#### 1.3 Update Backend Configuration

Edit `backend/main.py` line ~20:
```python
# Replace this:
model = tf.keras.models.load_model('models/pcb_detection_model.h5')

# With your actual model path:
model = tf.keras.models.load_model('models/your_trained_model.h5')
```

#### 1.4 Run Backend Server
```bash
# Option A: Direct Python
python backend/main.py

# Option B: Using Uvicorn with auto-reload
uvicorn main:app --reload --host 0.0.0.0 --port 8000

# Output should show:
# INFO:     Uvicorn running on http://0.0.0.0:8000
# INFO:     Application startup complete
```

#### 1.5 Verify Backend is Running
Open your browser and navigate to:
- **Health Check:** http://localhost:8000
- **API Docs (Swagger):** http://localhost:8000/docs
- **Alternative Docs:** http://localhost:8000/redoc

### Phase 2: Flutter App Setup

#### 2.1 Get Flutter Dependencies
```bash
flutter pub get
```

This fetches:
- `http` - HTTP client for API communication
- `image_picker` - Camera/gallery image selection

#### 2.2 Configure API Endpoint

Edit `lib/services/api_service.dart` line ~15:

```dart
// Local Development (Default)
static const String baseUrl = 'http://localhost:8000';

// For Android Emulator (if testing on emulator):
// static const String baseUrl = 'http://10.0.2.2:8000';

// For Physical Device (replace with your machine IP):
// static const String baseUrl = 'http://192.168.x.x:8000';
```

#### 2.3 Update Android Permissions

Edit `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.INTERNET" />
```

#### 2.4 Update iOS Permissions

Edit `ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access for PCB image analysis</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>We need library access to select PCB images</string>
```

#### 2.5 Run Flutter App
```bash
flutter run

# Or with specific device:
flutter run -d chrome           # Web
flutter run -d emulator-5554    # Android Emulator
```

### Phase 3: System Testing

#### 3.1 Test Login Page
```
Username: admin
Password: 123
```

Expected behavior:
- ✓ Successful authentication shows snackbar
- ✓ Navigates to AI Results page
- ✓ User info displayed in app bar

#### 3.2 Test AI Results Dashboard
Navigate using tabs:
- **Overview Tab:** Training statistics and metrics
- **Metrics Tab:** Loss curves and validation data
- **Data Tab:** Dataset information and feature importance

Click the **prediction icon** (upper right) to go to image analysis.

#### 3.3 Test Image Prediction
1. Select image from camera or gallery
2. Click **ANALYZE IMAGE**
3. Backend processes and returns:
   - Classification (No/Minor/Major/Critical Defect)
   - Confidence score (0-100%)
   - Risk assessment
   - Recommendations
   - All class probabilities

#### 3.4 Verify API Communication
Check backend logs:
```
INFO:     127.0.0.1:35728 - "POST /predict HTTP/1.1" 200 OK
```

### Phase 4: Production Deployment

#### 4.1 Docker Deployment

Create `backend/Dockerfile`:
```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

Build and run:
```bash
docker build -t pcb-ai-api:latest .
docker run -p 8000:8000 -v $(pwd)/models:/app/models pcb-ai-api:latest
```

#### 4.2 Cloud Deployment Options

**AWS Lambda + API Gateway:**
```bash
pip install -r backend/requirements.txt -t backend/
zip -r backend.zip backend/
# Upload to Lambda
```

**Google Cloud Run:**
```bash
gcloud run deploy pcb-ai-api \
  --source . \
  --platform managed \
  --region us-central1
```

**Azure App Service:**
```bash
az webapp up --name pcb-ai-api --resource-group myResourceGroup
```

#### 4.3 Environment Configuration

Create `backend/.env`:
```env
MODEL_PATH=models/pcb_detection_model.h5
BACKEND_URL=https://your-production-api.com
ALLOWED_ORIGINS=https://your-flutter-app.com,https://app.yourcompany.com
LOG_LEVEL=INFO
DEBUG=False
```

#### 4.4 Update Flutter for Production

Edit `lib/services/api_service.dart`:
```dart
static const String baseUrl = 'https://your-production-api.com';
```

## API Endpoint Reference

### Authentication (Flutter)
| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/` | GET | Health check |
| `/health` | GET | Detailed status |
| `/model-info` | GET | Model information |

### Prediction Services
| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/predict` | POST | Single image prediction |
| `/batch-predict` | POST | Multiple images |

### Request/Response Examples

**Single Prediction Request:**
```bash
curl -X POST "http://localhost:8000/predict" \
  -H "accept: application/json" \
  -F "file=@pcb_image.jpg"
```

**Response:**
```json
{
  "status": "success",
  "classification": "No Defect",
  "confidence": 0.9483,
  "filename": "pcb_image.jpg",
  "class_scores": {
    "No Defect": 0.9483,
    "Minor Defect": 0.0312,
    "Major Defect": 0.0151,
    "Critical Defect": 0.0054
  },
  "risk_level": "Low (High Confidence)",
  "recommendation": "Unit approved for production"
}
```

## Troubleshooting Guide

### Issue: "Backend unavailable" message in app

**Causes & Solutions:**
```
1. Backend not running
   → Run: python backend/main.py

2. Wrong API URL in Flutter
   → Check lib/services/api_service.dart baseUrl
   → For local dev: http://localhost:8000
   → For emulator: http://10.0.2.2:8000

3. Firewall blocking port 8000
   → Open port 8000 in firewall settings
   → Or use different port: uvicorn main:app --port 5000
```

### Issue: Image upload fails

**Causes & Solutions:**
```
1. Missing permissions
   → Check AndroidManifest.xml or Info.plist
   → Grant app permissions in system settings

2. Image too large
   → Max size: 50 MB
   → Compress: Use image_picker compress option

3. Unsupported format
   → Supported: JPEG, PNG
   → Convert other formats first
```

### Issue: Slow predictions

**Optimization Tips:**
```
1. Use GPU acceleration
   → Install: pip install tensorflow[and-cuda]
   → Set GPU memory: 
     gpus = tf.config.list_physical_devices('GPU')
     
2. Optimize model
   → Quantize: TensorFlow Lite conversion
   → Prune: Remove unnecessary weights
   
3. Batch processing
   → Process multiple images together
   → Use /batch-predict endpoint
```

### Issue: CORS errors

**Solution:**
Edit `backend/main.py`:
```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:8000"],  # Add your app URL
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

## Performance Metrics

**Expected Performance (CPU):**
- Prediction Time: 2-5 seconds
- Memory Usage: 500-800 MB
- Model Size: 100-500 MB

**Expected Performance (GPU):**
- Prediction Time: 0.5-1 second
- Memory Usage: 1-2 GB
- Throughput: 10-20 predictions/second

## Security Best Practices

1. **Authentication**
   - Implement JWT tokens for production
   - Use OAuth2 for user management

2. **API Security**
   - Rate limiting: `pip install slowapi`
   - Input validation: Use pydantic
   - HTTPS only in production

3. **Model Security**
   - Encrypt model files
   - Version control models
   - Monitor model drift

## Next Steps

1. **Train Your Models**
   - Prepare PCB defect dataset
   - Train CNN model
   - Save as .h5 file
   - Place in `/backend/models`

2. **Customize Configuration**
   - Update class names in `config.py`
   - Adjust risk thresholds
   - Define recommendation logic

3. **Deploy to Cloud**
   - Choose cloud provider
   - Set up CI/CD pipeline
   - Configure monitoring/logging

4. **Monitor & Maintain**
   - Track prediction accuracy
   - Monitor inference time
   - Update models regularly

## Support & Resources

- **FastAPI Docs:** https://fastapi.tiangolo.com
- **Flutter Docs:** https://flutter.dev/docs
- **TensorFlow Guide:** https://www.tensorflow.org/guide
- **Image Picker Plugin:** https://pub.dev/packages/image_picker
- **HTTP Client Docs:** https://pub.dev/packages/http

## License
MIT License - Free to use and modify
