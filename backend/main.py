import os
import io
from fastapi import FastAPI, File, UploadFile, HTTPException
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
print("Loading YOLOv8 model...")
try:
    model = YOLO("best.pt") 
    model.to('cpu')
    print("Model loaded successfully!")
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
        results = model(image, conf=0.25)
        result = results[0]

        # 4. Parse the YOLOv8 output
        class_scores = {}
        
        if len(result.boxes) == 0:
            classification = "pass"
            confidence = 1.0
            risk_level = "Low"
            recommendation = "PCB appears to be defect-free"
            is_defective = False
        else:
            is_defective = True
            best_box = max(result.boxes, key=lambda box: float(box.conf[0]))
            class_id = int(best_box.cls[0])
            classification = model.names[class_id]
            confidence = float(best_box.conf[0])
            
            risk_level = "High" if confidence > 0.85 else "Medium"
            recommendation = f"Inspect {classification.replace('_', ' ')} area manually"
            
            for box in result.boxes:
                c_name = model.names[int(box.cls[0])]
                c_conf = float(box.conf[0])
                if c_name not in class_scores or c_conf > class_scores[c_name]:
                    class_scores[c_name] = c_conf

        # 5. Save the image to the correct local folder
        if not is_defective:
            target_folder = os.path.join(SAVE_DIR, "pass")
        else:
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

# =====================================================================
# NEW ENDPOINT: Delete the physical image from the server
# =====================================================================
@app.delete("/api/delete_record/{filename}")
async def delete_pcb_record(filename: str):
    # 1. Force Python to use the absolute path to your folder
    BASE_DIR = os.path.dirname(os.path.abspath(__file__))
    FULL_SAVE_DIR = os.path.join(BASE_DIR, SAVE_DIR)
    
    file_to_delete = None
    
    # 2. Deep Search: Look through all subfolders (pass, fail, missing_hole, etc.)
    for root, dirs, files in os.walk(FULL_SAVE_DIR):
        if filename in files:
            file_to_delete = os.path.join(root, filename)
            break

    # 3. If we found it, delete it!
    if file_to_delete and os.path.exists(file_to_delete):
        try:
            os.remove(file_to_delete)
            print(f"SUCCESS: Physical file deleted from {file_to_delete}")
            return {"status": "success", "message": "File permanently deleted from server."}
        except Exception as e:
            print(f"ERROR: Could not delete file: {e}")
            raise HTTPException(status_code=500, detail=f"Failed to delete: {str(e)}")
    
    # 4. If it was already deleted or missing, don't crash! Let Flutter continue.
    else:
        print(f"WARNING: File {filename} not found. It may have already been deleted.")
        return {"status": "not_found", "message": "File not on server. Safe to delete from database."}

if __name__ == "__main__":
    print("Starting PCB Defect Detection API...")
    port = int(os.environ.get("PORT", 8000))
    uvicorn.run(app, host="0.0.0.0", port=port)