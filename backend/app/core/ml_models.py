import os
import joblib
from app.core.config import settings

# ================================================================
# ML MODEL + SCALER
# ================================================================
MODEL_PATH = os.path.join(settings.BASE_DIR, "credit_model.pkl")
SCALER_PATH = os.path.join(settings.BASE_DIR, "credit_scaler.pkl")

# Load models if they exist
try:
    credit_model = joblib.load(MODEL_PATH)
    credit_scaler = joblib.load(SCALER_PATH)
except Exception as e:
    print(f"Warning: Could not load ML models: {e}")
    credit_model = None
    credit_scaler = None
