import os
import io
from fastapi import FastAPI, File, UploadFile
from fastapi.middleware.cors import CORSMiddleware
import uvicorn
import json
from datetime import datetime
from PIL import Image
from ultralytics import YOLO

app = FastAPI(title="PCB Defect Detection API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

SAVE_DIR = "saved_pcb_images"

# 1. Load your trained YOLOv8 model once when the server starts
# Make sure "best.pt" is in the exact same folder as this script!
print("Loading YOLOv8 model...")
try:
    model = YOLO("best.pt") 
    model.to('cpu')
    print("Model loaded successfully!")
    # Add this line in main.py after model = YOLO("best.pt")
    print(f"Model classes: {model.names}")
except Exception as e:
    print(f"Failed to load model: {e}. Make sure best.pt is in the directory.")

@app.get("/health")
async def health_check():
    return {"status": "healthy", "timestamp": datetime.now().isoformat()}

@app.post("/predict")
async def predict_image(file: UploadFile = File(...)):
    try:
        contents = await file.read()
        
        # 2. Convert the uploaded bytes into a readable image format for YOLO
        image = Image.open(io.BytesIO(contents)).convert("RGB")

        # 3. Run the image through your real AI model!
        # conf=0.25 ignores any weak guesses below 25% confidence
        results = model(image, conf=0.25)
        result = results[0] # Get the results for the first (and only) image

        # 4. Parse the YOLOv8 output
        class_scores = {}
        
        # If YOLO found ZERO bounding boxes, the board is perfectly fine
        if len(result.boxes) == 0:
            classification = "pass"
            confidence = 1.0
            risk_level = "Low"
            recommendation = "PCB appears to be defect-free"
            is_defective = False
            
        else:
            is_defective = True
            # Find the bounding box with the highest confidence
            best_box = max(result.boxes, key=lambda box: float(box.conf[0]))
            
            # Extract the class ID and look up the name (e.g., "mouse_bite")
            class_id = int(best_box.cls[0])
            classification = model.names[class_id]
            confidence = float(best_box.conf[0])
            
            risk_level = "High" if confidence > 0.85 else "Medium"
            recommendation = f"Inspect {classification.replace('_', ' ')} area manually"
            
            # Populate class scores based on everything the model saw
            for box in result.boxes:
                c_name = model.names[int(box.cls[0])]
                c_conf = float(box.conf[0])
                if c_name not in class_scores or c_conf > class_scores[c_name]:
                    class_scores[c_name] = c_conf

        # 5. Save the image to the correct local folder
        if not is_defective:
            target_folder = os.path.join(SAVE_DIR, "pass")
        else:
            # Replaces spaces with underscores just in case your class names have spaces
            clean_class = classification.lower().replace(" ", "_")
            target_folder = os.path.join(SAVE_DIR, "fail", clean_class)

        os.makedirs(target_folder, exist_ok=True)
        file_path = os.path.join(target_folder, file.filename)
        
        with open(file_path, "wb") as f:
            f.write(contents)

        # 6. Format the JSON response
        response_data = {
            "filename": file.filename,
            "classification": classification,
            "confidence": confidence,
            "risk_level": risk_level,
            "recommendation": recommendation,
            "class_scores": class_scores,
            "timestamp": datetime.now().isoformat()
        }

        print(f"Prediction result: {json.dumps(response_data, indent=2)}")
        print(f"Image saved locally at: {file_path}")
        return response_data

    except Exception as e:
        print(f"Error processing prediction: {e}")
        return {
            "error": str(e),
            "filename": file.filename if file else "unknown"
        }

if __name__ == "__main__":
    print("Starting PCB Defect Detection API...")
    # Read the port assigned by Render, or default to 8000 locally
    port = int(os.environ.get("PORT", 8000))
    uvicorn.run(app, host="0.0.0.0", port=port)