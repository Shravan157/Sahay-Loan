from fastapi import APIRouter, HTTPException, Depends, BackgroundTasks
from firebase_admin import auth
import httpx
from datetime import datetime
from app.core.config import db, settings, ROLE_USER, ROLE_PROVIDER_ADMIN
from app.core.security import verify_firebase_token
from app.models.schemas import RegisterInput, LoginInput
from app.services.notification_service import send_welcome_notification

router = APIRouter()

@router.post("/register")
async def register(data: RegisterInput, background_tasks: BackgroundTasks):
    """
    Register new user.
    Roles: user / sahay_admin / provider_admin
    For provider_admin: either company_id (existing) OR company details (new registration)
    """
    try:
        user_record = auth.create_user(
            email=data.email,
            password=data.password,
            display_name=data.name
        )

        user_doc = {
            "uid": user_record.uid,
            "name": data.name,
            "email": data.email,
            "phone": data.phone,
            "role": data.role,
            "kyc_verified": False,
            "created_at": datetime.now().isoformat()
        }

        # If provider admin — handle company linking
        if data.role == ROLE_PROVIDER_ADMIN:
            if data.company_id:
                # Link to existing company
                company = db.collection("companies").document(data.company_id).get()
                if not company.exists:
                    raise HTTPException(status_code=404, detail="Company not found.")
                user_doc["company_id"] = data.company_id
            else:
                # Self-registration: Create new company
                if not all([data.company_type, data.cin, data.gstin, data.pan, data.registered_address]):
                    raise HTTPException(
                        status_code=400, 
                        detail="For provider registration, company_type, cin, gstin, pan, and registered_address are required."
                    )
                
                # Create company document
                company_ref = db.collection("companies").document()
                company_id = company_ref.id
                
                company_ref.set({
                    "company_id": company_id,
                    "name": data.name,
                    "email": data.email,
                    "phone": data.phone,
                    "company_type": data.company_type,
                    "cin": data.cin,
                    "gstin": data.gstin,
                    "pan": data.pan,
                    "registered_address": data.registered_address,
                    "website": data.website or "",
                    "admin_uid": user_record.uid,
                    "active": True,
                    "kyc_verified": False,  # Requires admin approval
                    "added_at": datetime.now().isoformat()
                })
                
                user_doc["company_id"] = company_id
                user_doc["kyc_verified"] = True  # Provider admin is pre-verified

        db.collection("users").document(user_record.uid).set(user_doc)

        # Send welcome email for regular users only
        from app.services.email import email_welcome
        if data.role == ROLE_USER:
            background_tasks.add_task(email_welcome, data.name, data.email)

        return {
            "status": "success",
            "message": "Registration successful!" + (" Your company profile is pending admin approval." if data.role == ROLE_PROVIDER_ADMIN and not data.company_id else ""),
            "uid": user_record.uid,
            "role": data.role
        }

    except auth.EmailAlreadyExistsError:
        raise HTTPException(status_code=400, detail="Email already registered.")
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/login")
async def login(data: LoginInput, background_tasks: BackgroundTasks):
    """
    Login user — works for all roles.
    Returns id_token to use as Bearer token.
    """
    try:
        async with httpx.AsyncClient() as client:
            response = await client.post(
                f"https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key={settings.FIREBASE_WEB_API_KEY}",
                json={
                    "email": data.email,
                    "password": data.password,
                    "returnSecureToken": True
                }
            )
            result = response.json()

        if "error" in result:
            error_msg = result["error"].get("message", "Login failed")
            if error_msg == "EMAIL_NOT_FOUND":
                raise HTTPException(status_code=404, detail="Email not registered.")
            elif error_msg in ["INVALID_PASSWORD", "INVALID_LOGIN_CREDENTIALS"]:
                raise HTTPException(status_code=401, detail="Invalid email or password.")
            else:
                raise HTTPException(status_code=401, detail=error_msg)

        id_token = result["idToken"]
        uid = result["localId"]

        doc = db.collection("users").document(uid).get()
        if not doc.exists:
            raise HTTPException(status_code=404, detail="User profile not found.")

        user_data = doc.to_dict()
        
        # Send welcome notification on login
        if user_data.get("role") == ROLE_USER:
            background_tasks.add_task(
                send_welcome_notification, 
                uid, 
                user_data["name"]
            )

        return {
            "status": "success",
            "message": "Login successful!",
            "id_token": id_token,
            "uid": uid,
            "user": {
                "uid": uid,
                "name": user_data["name"],
                "email": user_data["email"],
                "role": user_data["role"],
                "kyc_verified": user_data.get("kyc_verified", False),
                "company_id": user_data.get("company_id", None)
            }
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/logout")
async def logout(user=Depends(verify_firebase_token)):
    try:
        auth.revoke_refresh_tokens(user["uid"])
        return {"status": "success", "message": "Logged out successfully."}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/profile")
async def get_profile(user=Depends(verify_firebase_token)):
    try:
        doc = db.collection("users").document(user["uid"]).get()
        if not doc.exists:
            raise HTTPException(status_code=404, detail="User profile not found.")
        return {"status": "success", "user": doc.to_dict()}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/update-fcm-token")
async def update_fcm_token(token: str, user=Depends(verify_firebase_token)):
    """Update user's FCM token for push notifications"""
    try:
        db.collection("users").document(user["uid"]).update({
            "fcm_token": token,
            "fcm_token_updated_at": datetime.now().isoformat()
        })
        return {"status": "success", "message": "FCM token updated."}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
