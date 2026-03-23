from fastapi import APIRouter, HTTPException, Depends, UploadFile, File, Form
from datetime import datetime
from typing import List, Optional
from app.core.config import db
from app.core.security import verify_firebase_token, require_provider_admin
from app.models.schemas import ProviderDocumentUpdate
import json

router = APIRouter()

@router.get("/{company_id}")
def get_provider_documents(company_id: str, user=Depends(verify_firebase_token)):
    """Get all documents for a lending company"""
    try:
        doc_ref = db.collection("provider_documents").document(company_id)
        doc = doc_ref.get()
        
        if not doc.exists:
            # Create empty document if not exists
            initial_data = {
                "uid": user["uid"],
                "company_id": company_id,
                "verification_status": "not_submitted",
                "created_at": datetime.now().isoformat()
            }
            doc_ref.set(initial_data)
            return initial_data
            
        return doc.to_dict()
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/upload")
async def upload_provider_document(
    company_id: str = Form(...),
    document_type: str = Form(...),
    document_name: str = Form(...),
    file_base64: str = Form(...),
    file_name: str = Form(...),
    extracted_text: Optional[str] = Form(None),
    extracted_data: Optional[str] = Form(None),
    user=Depends(require_provider_admin)
):
    """Upload a single business document (base64)"""
    try:
        # In a real app, we would upload to Cloud Storage and save URL
        # For this test phase, we'll store a mock URL
        mock_file_url = f"https://storage.googleapis.com/sahay-provider-docs/{company_id}/{document_type}_{file_name}"
        
        doc_data = {
            "document_type": document_type,
            "document_name": document_name,
            "file_url": mock_file_url,
            "file_name": file_name,
            "file_base64": file_base64, # In real app, don't store base64 in Firestore
            "status": "pending",
            "uploaded_at": datetime.now().isoformat()
        }
        
        if extracted_text:
            doc_data["extracted_text"] = extracted_text
        if extracted_data:
            doc_data["extracted_data"] = json.loads(extracted_data)

        # Update the specific document type in the provider_documents collection
        db.collection("provider_documents").document(company_id).update({
            document_type: doc_data,
            "updated_at": datetime.now().isoformat()
        })

        return {"status": "success", "message": f"{document_name} uploaded successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.delete("/{company_id}/{document_type}")
def delete_provider_document(company_id: str, document_type: str, user=Depends(require_provider_admin)):
    """Delete a specific document"""
    try:
        from firebase_admin import firestore
        db.collection("provider_documents").document(company_id).update({
            document_type: firestore.DELETE_FIELD,
            "updated_at": datetime.now().isoformat()
        })
        return {"status": "success", "message": "Document deleted"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/{company_id}/submit")
def submit_provider_documents(company_id: str, user=Depends(require_provider_admin)):
    """Submit all documents for verification"""
    try:
        db.collection("provider_documents").document(company_id).update({
            "verification_status": "pending",
            "submitted_at": datetime.now().isoformat()
        })
        
        # Also update company status in companies collection
        db.collection("companies").document(company_id).update({
            "verification_status": "pending"
        })
        
        return {"status": "success", "message": "Documents submitted for verification"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/pending-verifications")
def get_pending_verifications(user=Depends(verify_firebase_token)):
    """Admin: Get all providers waiting for document verification"""
    try:
        # In real app, check if user is admin
        docs = db.collection("provider_documents").where("verification_status", "==", "pending").get()
        return {"documents": [d.to_dict() for d in docs]}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/verify-status")
def verify_provider_status(data: dict, user=Depends(verify_firebase_token)):
    """Admin: Approve or reject provider documents"""
    try:
        company_id = data.get("company_id")
        status = data.get("status")
        reason = data.get("reason", "")
        
        # Update provider_documents collection
        db.collection("provider_documents").document(company_id).update({
            "verification_status": status,
            "rejection_reason": reason,
            "verified_at": datetime.now().isoformat(),
            "verified_by": user["uid"]
        })
        
        # Update companies collection
        db.collection("companies").document(company_id).update({
            "verification_status": status,
            "kyc_verified": status == "verified",
            "active": status == "verified"
        })
        
        return {"status": "success", "message": f"Provider status updated to {status}"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
