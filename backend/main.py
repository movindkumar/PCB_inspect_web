from fastapi import FastAPI, File, UploadFile
from fastapi.middleware.cors import CORSMiddleware
import uvicorn
import json
import random
from datetime import datetime

app = FastAPI(title="PCB Defect Detection API")

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify your frontend URL
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Mock defect types
DEFECT_TYPES = [
    "open_circuit",
    "missing_hole",
    "mouse_bite",
]

@app.get("/health")
async def health_check():
    return {"status": "healthy", "timestamp": datetime.now().isoformat()}

@app.post("/predict")
async def predict_image(file: UploadFile = File(...)):
    try:
        # Read file content
        contents = await file.read()

        # Mock prediction logic
        # In a real implementation, this would use your CNN model
        is_defective = random.choice([True, False])

        if is_defective:
            classification = random.choice(DEFECT_TYPES)
            confidence = random.uniform(0.7, 0.95)
            risk_level = "High" if confidence > 0.85 else "Medium"
            recommendation = f"Inspect {classification.replace('_', ' ')} area manually"
        else:
            classification = "good"
            confidence = random.uniform(0.85, 0.98)
            risk_level = "Low"
            recommendation = "PCB appears to be defect-free"

        # Create class scores
        class_scores = {}
        if is_defective:
            class_scores[classification] = confidence
            # Add some other scores
            remaining_defects = [d for d in DEFECT_TYPES if d != classification]
            for defect in random.sample(remaining_defects, min(2, len(remaining_defects))):
                class_scores[defect] = random.uniform(0.1, 0.3)
        else:
            class_scores["good"] = confidence
            for defect in random.sample(DEFECT_TYPES, 2):
                class_scores[defect] = random.uniform(0.01, 0.1)

        result = {
            "filename": file.filename,
            "classification": classification,
            "confidence": confidence,
            "risk_level": risk_level,
            "recommendation": recommendation,
            "class_scores": class_scores,
            "timestamp": datetime.now().isoformat()
        }

        print(f"Prediction result: {json.dumps(result, indent=2)}")
        return result

    except Exception as e:
        print(f"Error processing prediction: {e}")
        return {
            "error": str(e),
            "filename": file.filename if file else "unknown"
        }

if __name__ == "__main__":
    print("Starting PCB Defect Detection API...")
    print("Health check: http://localhost:8000/health")
    print("Prediction endpoint: http://localhost:8000/predict")
    uvicorn.run(app, host="0.0.0.0", port=8000)