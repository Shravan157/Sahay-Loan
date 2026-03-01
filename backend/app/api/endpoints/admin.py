from fastapi import APIRouter, HTTPException, Depends, BackgroundTasks
from firebase_admin import auth
from datetime import datetime
from app.core.config import db, ROLE_USER, ROLE_PROVIDER_ADMIN
from app.core.security import require_sahay_admin
from app.models.schemas import AddCompanyInput, SharePhase1Input, SharePhase2Input

router = APIRouter()

@router.post("/add-company")
def add_company(data: AddCompanyInput, user=Depends(require_sahay_admin)):
    """
    SAHAY Admin — Add a new loan provider company.
    Also creates a provider_admin account for the company.
    """
    try:
        # Create company document
        company_ref = db.collection("companies").document()
        company_id = company_ref.id

        company_ref.set({
            "company_id": company_id,
            "name": data.name,
            "email": data.email,
            "phone": data.phone,
            "description": data.description,
            "active": True,
            "added_by": user["uid"],
            "added_at": datetime.now().isoformat()
        })

        # Create provider admin account for this company
        provider_record = auth.create_user(
            email=data.email,
            password=data.password,
            display_name=data.name
        )

        db.collection("users").document(provider_record.uid).set({
            "uid": provider_record.uid,
            "name": data.name,
            "email": data.email,
            "phone": data.phone,
            "role": ROLE_PROVIDER_ADMIN,
            "company_id": company_id,
            "kyc_verified": True,
            "created_at": datetime.now().isoformat()
        })

        # Link company to its admin
        company_ref.update({"admin_uid": provider_record.uid})

        return {
            "status": "success",
            "message": f"Company '{data.name}' added successfully!",
            "company_id": company_id,
            "provider_admin_uid": provider_record.uid
        }
    except auth.EmailAlreadyExistsError:
        raise HTTPException(status_code=400, detail="Email already registered.")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/all-companies")
def all_companies(user=Depends(require_sahay_admin)):
    """SAHAY Admin — View all registered loan provider companies"""
    try:
        companies = db.collection("companies").get()
        return {"companies": [c.to_dict() for c in companies]}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/all-users")
def sahay_all_users(user=Depends(require_sahay_admin)):
    """SAHAY Admin — View all registered users with full details"""
    try:
        users = db.collection("users").where("role", "==", ROLE_USER).get()
        result = []
        for u in users:
            user_data = u.to_dict()
            # Attach KYC details
            kyc = db.collection("kyc").document(user_data["uid"]).get()
            if kyc.exists:
                user_data["kyc"] = kyc.to_dict()
            # Attach credit score
            score = db.collection("credit_scores").document(user_data["uid"]).get()
            if score.exists:
                user_data["credit_score"] = score.to_dict()
            result.append(user_data)
        return {"users": result}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/all-loans")
def sahay_all_loans(user=Depends(require_sahay_admin)):
    """SAHAY Admin — View all loan applications"""
    try:
        loans = db.collection("loans").get()
        return {"loans": [l.to_dict() for l in loans]}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/share-phase1")
def share_phase1(data: SharePhase1Input, background_tasks: BackgroundTasks, user=Depends(require_sahay_admin)):
    """
    SAHAY Admin — Phase 1: Share basic + financial details with loan provider.
    Does NOT include: Aadhaar, PAN, phone, email, monthly balance.
    """
    try:
        # Get loan details
        loan_doc = db.collection("loans").document(data.loan_id).get()
        if not loan_doc.exists:
            raise HTTPException(status_code=404, detail="Loan not found.")
        loan = loan_doc.to_dict()

        # Get user KYC details
        kyc_doc = db.collection("kyc").document(loan["uid"]).get()
        if not kyc_doc.exists:
            raise HTTPException(status_code=404, detail="KYC not found for this user.")
        kyc = kyc_doc.to_dict()

        # Get credit score
        score_doc = db.collection("credit_scores").document(loan["uid"]).get()
        score = score_doc.to_dict() if score_doc.exists else {}

        # Verify company exists
        company_doc = db.collection("companies").document(data.company_id).get()
        if not company_doc.exists:
            raise HTTPException(status_code=404, detail="Company not found.")

        # Build Phase 1 — safe data only (no sensitive IDs)
        phase1_data = {
            "name": kyc.get("name"),
            "age": kyc.get("age"),
            "occupation": kyc.get("occupation"),
            "annual_income": kyc.get("annual_income"),
            "monthly_inhand_salary": kyc.get("monthly_inhand_salary"),
            "credit_score": score.get("credit_score"),
            "credit_eligible": score.get("eligible"),
            "outstanding_debt": None,
            "loan_amount": loan.get("loan_amount"),
            "duration_months": loan.get("duration_months"),
            "purpose": loan.get("purpose"),
            "requested_interest_rate": loan.get("rate_of_interest"),
            "monthly_emi": loan.get("monthly_emi"),
        }

        # Create shared profile document
        share_ref = db.collection("shared_profiles").document()
        share_id = share_ref.id

        share_ref.set({
            "share_id": share_id,
            "loan_id": data.loan_id,
            "user_uid": loan["uid"],
            "company_id": data.company_id,
            "phase": 1,
            "phase1_data": phase1_data,
            "phase2_data": None,
            "phase2_requested": False,
            "phase2_approved": False,
            "status": "pending",            # pending / approved / rejected
            "decision": None,
            "decision_reason": None,
            "offered_interest_rate": None,
            "shared_by": user["uid"],
            "shared_at": datetime.now().isoformat()
        })

        # Update loan status
        db.collection("loans").document(data.loan_id).update({
            "status": "shared_with_provider",
            "shared_with_company": data.company_id,
            "share_id": share_id
        })

        # Send email to user that loan is under review
        from app.services.email import email_loan_under_review
        user_doc = db.collection("users").document(loan["uid"]).get().to_dict()
        company_doc = db.collection("companies").document(data.company_id).get()
        company_name = company_doc.to_dict().get("name", "Bank") if company_doc.exists else "Bank"
        background_tasks.add_task(email_loan_under_review, user_doc["name"], user_doc["email"], company_name, loan["loan_amount"])

        return {
            "status": "success",
            "message": f"Phase 1 data shared with company successfully!",
            "share_id": share_id,
            "shared_data": phase1_data
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/approve-phase2")
def approve_phase2(data: SharePhase2Input, background_tasks: BackgroundTasks, user=Depends(require_sahay_admin)):
    """
    SAHAY Admin — Approve Phase 2 request from loan provider.
    Shares full details including Aadhaar, PAN, phone, email.
    """
    try:
        share_doc = db.collection("shared_profiles").document(data.share_id).get()
        if not share_doc.exists:
            raise HTTPException(status_code=404, detail="Shared profile not found.")

        share = share_doc.to_dict()

        if not share.get("phase2_requested"):
            raise HTTPException(status_code=400, detail="Phase 2 not requested by provider yet.")

        # Get full KYC details
        kyc_doc = db.collection("kyc").document(share["user_uid"]).get()
        kyc = kyc_doc.to_dict()

        # Build Phase 2 — full sensitive data
        phase2_data = {
            "phone": kyc.get("phone"),
            "email": kyc.get("email"),
            "aadhaar_number": kyc.get("aadhaar_number"),
            "pan_number": kyc.get("pan_number"),
            "monthly_balance": None,
        }

        # Update shared profile with phase 2 data
        db.collection("shared_profiles").document(data.share_id).update({
            "phase": 2,
            "phase2_data": phase2_data,
            "phase2_approved": True,
            "phase2_approved_at": datetime.now().isoformat(),
            "phase2_approved_by": user["uid"]
        })

        # Notify user about phase 2 verification
        from app.services.email import email_phase2_requested
        company_doc = db.collection("companies").document(share["company_id"]).get()
        company_name = company_doc.to_dict().get("name", "Bank") if company_doc.exists else "Bank"
        user_doc = db.collection("users").document(share["user_uid"]).get().to_dict()
        background_tasks.add_task(email_phase2_requested, user_doc["name"], user_doc["email"], company_name)

        return {
            "status": "success",
            "message": "Phase 2 approved! Full details shared with provider.",
            "phase2_data": phase2_data
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/all-shared-profiles")
def all_shared_profiles(user=Depends(require_sahay_admin)):
    """SAHAY Admin — View all shared profiles and their status"""
    try:
        profiles = db.collection("shared_profiles").get()
        return {"shared_profiles": [p.to_dict() for p in profiles]}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/notify-user/{loan_id}")
def notify_user(loan_id: str, message: str, background_tasks: BackgroundTasks, user=Depends(require_sahay_admin)):
    """SAHAY Admin — Send notification/decision to user"""
    try:
        db.collection("notifications").document().set({
            "loan_id": loan_id,
            "message": message,
            "sent_by": user["uid"],
            "sent_at": datetime.now().isoformat(),
            "read": False
        })
        # Update loan with final message
        db.collection("loans").document(loan_id).update({
            "user_notification": message,
            "notified_at": datetime.now().isoformat()
        })

        # Send email notification to user
        from app.services.email import email_notify_user
        loan_doc = db.collection("loans").document(loan_id).get()
        loan_data = loan_doc.to_dict()
        user_doc = db.collection("users").document(loan_data["uid"]).get().to_dict()
        background_tasks.add_task(email_notify_user, user_doc["name"], user_doc["email"], message)

        return {"status": "success", "message": "User notified successfully."}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/defaulters")
def sahay_defaulters(user=Depends(require_sahay_admin)):
    """SAHAY Admin — View users with 3+ overdue EMIs"""
    try:
        overdue = db.collection("repayments").where("status", "==", "overdue").get()
        defaulters = {}
        for emi in overdue:
            data = emi.to_dict()
            uid = data["uid"]
            defaulters[uid] = defaulters.get(uid, 0) + 1
        result = [{"uid": uid, "missed_emis": count, "flagged": count >= 3}
                  for uid, count in defaulters.items()]
        return {"defaulters": result}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/disburse-loan/{loan_id}")
def disburse_loan(loan_id: str, background_tasks: BackgroundTasks, user=Depends(require_sahay_admin)):
    """
    SAHAY Admin — Mock disbursal of approved loan amount to user.
    In real world this would trigger a bank transfer.
    For demo: updates loan status + activates EMI schedule + emails user.

    Flow:
    provider_approved → SAHAY Admin calls this → disbursed
    """
    try:
        # Get loan details
        loan_doc = db.collection("loans").document(loan_id).get()
        if not loan_doc.exists:
            raise HTTPException(status_code=404, detail="Loan not found.")
        loan = loan_doc.to_dict()

        # Only disburse if provider has approved
        if loan["status"] != "provider_approved":
            raise HTTPException(
                status_code=400,
                detail=f"Loan cannot be disbursed. Current status: {loan['status']}. Must be 'provider_approved'."
            )

        # Get user details
        user_doc = db.collection("users").document(loan["uid"]).get().to_dict()
        company_id = loan.get("shared_with_company")
        company_doc = db.collection("companies").document(company_id).get()
        company_name = company_doc.to_dict().get("name", "Loan Provider") if company_doc.exists else "Loan Provider"

        # Update loan status to disbursed
        db.collection("loans").document(loan_id).update({
            "status": "disbursed",
            "disbursed_at": datetime.now().isoformat(),
            "disbursed_by": user["uid"],
            "disbursal_note": f"₹{loan['loan_amount']} mock disbursed to user account"
        })

        # Activate EMI schedule — change all upcoming → pending
        emis = db.collection("repayments").where("loan_id", "==", loan_id).get()
        for emi in emis:
            emi.reference.update({"status": "pending"})

        # Send disbursal email in background
        from app.services.email import email_loan_disbursed
        background_tasks.add_task(
            email_loan_disbursed,
            user_doc["name"],
            user_doc["email"],
            loan["loan_amount"],
            company_name,
            loan["monthly_emi"],
            loan["duration_months"],
            loan_id
        )

        return {
            "status": "success",
            "message": f"₹{loan['loan_amount']} disbursed to {user_doc['name']} successfully!",
            "loan_id": loan_id,
            "disbursed_amount": loan["loan_amount"],
            "disbursed_to": user_doc["name"],
            "disbursed_at": datetime.now().isoformat(),
            "emi_activated": True,
            "monthly_emi": loan["monthly_emi"],
            "note": "Mock disbursal — in production this triggers a real bank transfer"
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
