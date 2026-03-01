import os
import firebase_admin
from firebase_admin import credentials, firestore
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

class Settings:
    PROJECT_NAME: str = "SAHAY Loan App API"
    
    # Firebase
    FIREBASE_WEB_API_KEY: str = os.getenv("FIREBASE_WEB_API_KEY", "AIzaSyCuz4MX4w1AJ43t8Ii_hUi3adWf9Mc3egw")
    GOOGLE_VISION_API_KEY: str = os.getenv("GOOGLE_VISION_API_KEY", "")
    
    @property
    def VISION_API_URL(self) -> str:
        return f"https://vision.googleapis.com/v1/images:annotate?key={self.GOOGLE_VISION_API_KEY}"
    
    # Email Configuration
    GMAIL_SENDER_EMAIL: str = os.getenv("GMAIL_SENDER_EMAIL", "YOUR_GMAIL@gmail.com")
    GMAIL_APP_PASSWORD: str = os.getenv("GMAIL_APP_PASSWORD", "YOUR_16_DIGIT_APP_PASSWORD")
    
    # Business Logic
    MAX_LOAN_AMOUNT: int = int(os.getenv("MAX_LOAN_AMOUNT", 5000))
    
    # Stripe Configuration
    STRIPE_SECRET_KEY: str = os.getenv("STRIPE_SECRET_KEY", "sk_test_YOUR_STRIPE_SECRET_KEY")
    STRIPE_PUBLISHABLE_KEY: str = os.getenv("STRIPE_PUBLISHABLE_KEY", "pk_test_YOUR_STRIPE_PUBLISHABLE_KEY")
    
    # Paths
    BASE_DIR: str = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
    SERVICE_ACCOUNT_KEY_PATH: str = os.path.join(BASE_DIR, "serviceAccountKey.json")

settings = Settings()

# ================================================================
# FIREBASE SETUP
# ================================================================
if not firebase_admin._apps:
    cred = credentials.Certificate(settings.SERVICE_ACCOUNT_KEY_PATH)
    firebase_admin.initialize_app(cred)

db = firestore.client()

# ================================================================
# ROLES
# ================================================================
ROLE_USER = "user"
ROLE_SAHAY_ADMIN = "sahay_admin"
ROLE_PROVIDER_ADMIN = "provider_admin"
