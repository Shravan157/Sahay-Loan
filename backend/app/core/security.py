from fastapi import HTTPException, Depends
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from firebase_admin import auth
from app.core.config import db, ROLE_USER, ROLE_SAHAY_ADMIN, ROLE_PROVIDER_ADMIN

security = HTTPBearer()

def verify_firebase_token(credentials: HTTPAuthorizationCredentials = Depends(security)):
    """Verify Firebase ID token"""
    token = credentials.credentials
    try:
        decoded = auth.verify_id_token(token)
        return decoded
    except Exception:
        raise HTTPException(status_code=401, detail="Invalid or expired token. Please login again.")


def get_user_role(uid: str) -> str:
    """Get role of a user from Firestore"""
    doc = db.collection("users").document(uid).get()
    if not doc.exists:
        raise HTTPException(status_code=404, detail="User not found.")
    return doc.to_dict().get("role", ROLE_USER)


def require_sahay_admin(user=Depends(verify_firebase_token)):
    """Only SAHAY App Admin can access"""
    role = get_user_role(user["uid"])
    if role != ROLE_SAHAY_ADMIN:
        raise HTTPException(status_code=403, detail="SAHAY Admin access only.")
    return user


def require_provider_admin(user=Depends(verify_firebase_token)):
    """Only Loan Provider Admin can access"""
    role = get_user_role(user["uid"])
    if role != ROLE_PROVIDER_ADMIN:
        raise HTTPException(status_code=403, detail="Loan Provider Admin access only.")
    return user


def require_user(user=Depends(verify_firebase_token)):
    """Only regular users can access"""
    role = get_user_role(user["uid"])
    if role != ROLE_USER:
        raise HTTPException(status_code=403, detail="User access only.")
    return user
