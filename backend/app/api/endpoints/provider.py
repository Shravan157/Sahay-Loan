from fastapi import APIRouter, HTTPException, Depends, BackgroundTasks
from datetime import datetime
from app.core.config import db
from app.core.security import require_provider_admin
from app.models.schemas import RequestFullDetailsInput, LoanDecisionInput

router = APIRouter()

@router.get("/shared-profiles")
def provider_shared_profiles(user=Depends(require_provider_admin)):
    """
    Loan Provider Admin — View profiles shared with their company.
    Only sees Phase 1 data until Phase 2 is approved by SAHAY.
    """
    try:
        # Get provider's company_id
        provider_doc = db.collection("users").document(user["uid"]).get()
        company_id = provider_doc.to_dict().get("company_id")

        profiles = db.collection("shared_profiles")\
            .where("company_id", "==", company_id).get()

        result = []
        for p in profiles:
            profile = p.to_dict()
            # Only show phase2 data if approved by SAHAY admin
            if not profile.get("phase2_approved"):
                profile.pop("phase2_data", None)
            result.append(profile)

        return {"shared_profiles": result}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/request-full-details")
def request_full_details(data: RequestFullDetailsInput, user=Depends(require_provider_admin)):
    """
    Loan Provider Admin — Request Phase 2 (full details) from SAHAY Admin.
    SAHAY Admin must approve before full details are visible.
    """
    try:
        share_doc = db.collection("shared_profiles").document(data.share_id).get()
        if not share_doc.exists:
            raise HTTPException(status_code=404, detail="Shared profile not found.")

        share = share_doc.to_dict()

        # Verify this company owns this profile
        provider_doc = db.collection("users").document(user["uid"]).get()
        company_id = provider_doc.to_dict().get("company_id")
        if share["company_id"] != company_id:
            raise HTTPException(status_code=403, detail="Unauthorized.")

        if share.get("phase2_requested"):
            raise HTTPException(status_code=400, detail="Phase 2 already requested.")

        db.collection("shared_profiles").document(data.share_id).update({
            "phase2_requested": True,
            "phase2_request_reason": data.reason,
            "phase2_requested_by": user["uid"],
            "phase2_requested_at": datetime.now().isoformat()
        })

        return {
            "status": "success",
            "message": "Full details requested. Waiting for SAHAY Admin approval."
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/loan-decision")
def loan_decision(data: LoanDecisionInput, background_tasks: BackgroundTasks, user=Depends(require_provider_admin)):
    """
    Loan Provider Admin — Approve or reject a loan application.
    Decision is sent back to SAHAY Admin who notifies the user.
    """
    try:
        share_doc = db.collection("shared_profiles").document(data.share_id).get()
        if not share_doc.exists:
            raise HTTPException(status_code=404, detail="Shared profile not found.")

        share = share_doc.to_dict()

        # Verify this company owns this profile
        provider_doc = db.collection("users").document(user["uid"]).get()
        company_id = provider_doc.to_dict().get("company_id")
        if share["company_id"] != company_id:
            raise HTTPException(status_code=403, detail="Unauthorized.")

        if data.decision not in ["approved", "rejected"]:
            raise HTTPException(status_code=400, detail="Decision must be 'approved' or 'rejected'.")

        # Update shared profile with decision
        db.collection("shared_profiles").document(data.share_id).update({
            "status": data.decision,
            "decision": data.decision,
            "decision_reason": data.reason,
            "offered_interest_rate": data.offered_interest_rate,
            "decided_by": user["uid"],
            "decided_at": datetime.now().isoformat()
        })

        # Update loan status — waiting for SAHAY admin to notify user
        db.collection("loans").document(share["loan_id"]).update({
            "status": f"provider_{data.decision}",
            "provider_decision": data.decision,
            "provider_decision_reason": data.reason,
            "offered_interest_rate": data.offered_interest_rate
        })

        # Send rejection email immediately to user
        if data.decision == "rejected":
            from app.services.email import email_loan_rejected
            user_doc = db.collection("users").document(share["user_uid"]).get().to_dict()
            company_doc = db.collection("companies").document(company_id).get()
            company_name = company_doc.to_dict().get("name", "Bank") if company_doc.exists else "Bank"
            background_tasks.add_task(email_loan_rejected, user_doc["name"], user_doc["email"], company_name, data.reason)

        return {
            "status": "success",
            "message": f"Loan {data.decision}. SAHAY Admin will notify the user.",
            "decision": data.decision
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/my-decisions")
def provider_decisions(user=Depends(require_provider_admin)):
    """Loan Provider Admin — View all decisions made by this company"""
    try:
        provider_doc = db.collection("users").document(user["uid"]).get()
        company_id = provider_doc.to_dict().get("company_id")
        profiles = db.collection("shared_profiles")\
            .where("company_id", "==", company_id)\
            .where("status", "in", ["approved", "rejected"]).get()
        return {"decisions": [p.to_dict() for p in profiles]}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
