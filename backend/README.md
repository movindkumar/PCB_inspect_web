# PCB Defect Detection Backend

This is a mock backend API for PCB defect detection using FastAPI.

## Setup

1. Install Python dependencies:
```bash
pip install -r requirements.txt
```

2. Start the server:
```bash
python main.py
```

The API will be available at:
- Health check: http://localhost:8000/health
- Prediction: http://localhost:8000/predict (POST with file upload)

## API Endpoints

### GET /health
Returns server health status.

### POST /predict
Accepts an image file and returns a mock prediction result.

**Request:** Multipart form data with `file` field containing the image.

**Response:**
```json
{
  "filename": "image.jpg",
  "classification": "open_circuit",
  "confidence": 0.87,
  "risk_level": "High",
  "recommendation": "Inspect open circuit area manually",
  "class_scores": {
    "open_circuit": 0.87,
    "missing_hole": 0.12,
    "mouse_bite": 0.01
  },
  "timestamp": "2026-04-12T10:30:00"
}
```

## Mock Behavior

The backend currently returns random mock predictions for testing purposes:
- 50% chance of "good" (pass)
- 50% chance of defect (fail) with random defect type
- Realistic confidence scores and recommendations

Replace the prediction logic in `main.py` with your actual CNN model when ready.