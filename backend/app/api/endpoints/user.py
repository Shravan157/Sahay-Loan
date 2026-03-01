from fastapi import APIRouter, HTTPException, Depends, BackgroundTasks
import httpx
import numpy as np
import os
import platform
from datetime import datetime, date
from dateutil.relativedelta import relativedelta
from app.core.config import db, settings
from app.core.security import verify_firebase_token
from app.core.ml_models import credit_model, credit_scaler
from app.models.schemas import OCRRequest, KYCInput, CreditScoreInput, LoanApplication, EMIPayment
from app.utils.helpers import extract_aadhaar_details, extract_pan_details, calculate_emi
import re

router = APIRouter()

# ================================================================
# OCR ENDPOINTS
# ================================================================
# OCR using Tesseract (Free alternative to Google Vision)
# Install: pip install pytesseract pillow pdf2image
# Also install Tesseract OCR: https://github.com/UB-Mannheim/tesseract/wiki
# ================================================================
@router.post("/ocr-scan")
async def ocr_scan(request: OCRRequest, user=Depends(verify_firebase_token)):
    try:
        import base64
        import io
        import re
        from PIL import Image
        
        # Decode base64
        try:
            image_bytes = base64.b64decode(request.image_base64)
        except Exception:
            raise HTTPException(status_code=400, detail="Invalid image data. Please try again.")
        
        # Check if it's a PDF and convert first page to image
        if request.file_extension.lower() == 'pdf':
            try:
                from pdf2image import convert_from_bytes
                images = convert_from_bytes(image_bytes, first_page=1, last_page=1)
                if images:
                    img_byte_arr = io.BytesIO()
                    images[0].save(img_byte_arr, format='JPEG')
                    image_bytes = img_byte_arr.getvalue()
                else:
                    raise HTTPException(status_code=400, detail="Could not read PDF. Please try a different file.")
            except ImportError:
                raise HTTPException(status_code=400, detail="PDF processing not available. Please upload an image (JPEG/PNG).")
            except Exception as e:
                raise HTTPException(status_code=400, detail=f"Could not process PDF: {str(e)}")
        
        # Open image with PIL
        try:
            img = Image.open(io.BytesIO(image_bytes))
            # Convert to RGB if necessary
            if img.mode in ('RGBA', 'LA', 'P'):
                img = img.convert('RGB')
        except Exception as e:
            raise HTTPException(status_code=400, detail=f"Could not open image: {str(e)}")
        
        # Try using Tesseract OCR (free, local)
        try:
            import pytesseract
            
            # Configure Tesseract path for Windows
            if platform.system() == 'Windows':
                # Common installation paths
                possible_paths = [
                    r'C:\Program Files\Tesseract-OCR\tesseract.exe',
                    r'C:\Program Files (x86)\Tesseract-OCR\tesseract.exe',
                ]
                for path in possible_paths:
                    if os.path.exists(path):
                        pytesseract.pytesseract.tesseract_cmd = path
                        break
            
            # Configure Tesseract for better accuracy with documents
            # --oem 3: Use LSTM neural network mode
            # --psm 6: Assume a single uniform block of text
            custom_config = r'--oem 3 --psm 6 -l eng+hin'
            raw_text = pytesseract.image_to_string(img, config=custom_config)
            
            if not raw_text.strip():
                # Try with different page segmentation mode (sparse text)
                custom_config = r'--oem 3 --psm 3 -l eng+hin'
                raw_text = pytesseract.image_to_string(img, config=custom_config)
                
        except ImportError:
            # Tesseract not installed, fallback to simple message
            print("Tesseract not installed. Please install it or use Google Vision API.")
            raise HTTPException(
                status_code=500, 
                detail="OCR engine not available. Please install Tesseract OCR or configure Google Vision API."
            )
        except Exception as e:
            print(f"Tesseract error: {e}")
            raise HTTPException(status_code=400, detail=f"Could not read text from image: {str(e)}")

        if not raw_text.strip():
            raise HTTPException(status_code=400, detail="No text detected in the image. Please try with a clearer image.")

        # Process extracted text
        if request.doc_type == "aadhaar":
            extracted = extract_aadhaar_details(raw_text)
            return {
                "doc_type": "aadhaar",
                "extracted": extracted,
                "success": extracted["aadhaar_number"] is not None,
                "message": "Aadhaar scanned successfully!" if extracted["aadhaar_number"] else "Could not detect Aadhaar number. The image was read but Aadhaar number pattern not found."
            }
        elif request.doc_type == "pan":
            extracted = extract_pan_details(raw_text)
            return {
                "doc_type": "pan",
                "extracted": extracted,
                "success": extracted["pan_number"] is not None,
                "message": "PAN scanned successfully!" if extracted["pan_number"] else "Could not detect PAN number. The image was read but PAN number pattern not found."
            }
        else:
            raise HTTPException(status_code=400, detail="doc_type must be 'aadhaar' or 'pan'")

    except HTTPException:
        raise
    except Exception as e:
        print(f"OCR Error: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Processing error: {str(e)}")


# ================================================================
# KYC ENDPOINTS
# ================================================================
@router.post("/submit-kyc")
def submit_kyc(data: KYCInput, background_tasks: BackgroundTasks, user=Depends(verify_firebase_token)):
    if not re.match(r'^\d{12}$', data.aadhaar_number):
        raise HTTPException(status_code=400, detail="Invalid Aadhaar number. Must be 12 digits.")
    if not re.match(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$', data.pan_number):
        raise HTTPException(status_code=400, detail="Invalid PAN number. Format: AAAAA9999A")
    try:
        db.collection("kyc").document(user["uid"]).set({
            "uid": user["uid"],
            "name": data.name,
            "age": data.age,
            "occupation": data.occupation,
            "annual_income": data.annual_income,
            "monthly_inhand_salary": data.monthly_inhand_salary,
            "phone": data.phone,
            "email": data.email,
            "aadhaar_number": data.aadhaar_number,
            "pan_number": data.pan_number,
            "kyc_verified": True,
            "submitted_at": datetime.now().isoformat()
        })
        db.collection("users").document(user["uid"]).update({"kyc_verified": True})
        
        # Send KYC confirmation email
        from app.services.email import email_kyc_submitted
        background_tasks.add_task(email_kyc_submitted, data.name, data.email)

        return {
            "status": "success",
            "message": "KYC submitted successfully!",
            "kyc_verified": True
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/kyc-status")
def kyc_status(user=Depends(verify_firebase_token)):
    try:
        doc = db.collection("kyc").document(user["uid"]).get()
        if not doc.exists:
            return {"kyc_verified": False, "message": "KYC not submitted yet."}
        return {"kyc_verified": True, "message": "KYC verified.", "kyc": doc.to_dict()}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.put("/update-kyc")
async def update_kyc(data: KYCInput, user=Depends(verify_firebase_token)):
    try:
        doc_ref = db.collection("kyc").document(user["uid"])
        doc = doc_ref.get()
        
        if not doc.exists:
            raise HTTPException(status_code=404, detail="KYC not found. Please submit KYC first.")
        
        # Update the KYC data
        update_data = {
            "name": data.name,
            "age": data.age,
            "occupation": data.occupation,
            "annual_income": data.annual_income,
            "monthly_inhand_salary": data.monthly_inhand_salary,
            "phone": data.phone,
            "email": data.email,
            "aadhaar_number": data.aadhaar_number,
            "pan_number": data.pan_number,
            "updated_at": datetime.now().isoformat(),
        }
        
        doc_ref.update(update_data)
        
        return {
            "success": True,
            "message": "KYC updated successfully!",
            "kyc": {**doc.to_dict(), **update_data}
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# ================================================================
# CREDIT SCORE
# ================================================================
@router.post("/predict-credit-score")
def predict_credit_score(data: CreditScoreInput, user=Depends(verify_firebase_token)):
    if not credit_model or not credit_scaler:
        raise HTTPException(status_code=500, detail="ML models not loaded.")
        
    try:
        input_array = np.array([[
            data.Annual_Income, data.Monthly_Inhand_Salary,
            data.Num_Bank_Accounts, data.Num_Credit_Card,
            data.Interest_Rate, data.Num_of_Loan,
            data.Delay_from_due_date, data.Num_of_Delayed_Payment,
            data.Changed_Credit_Limit, data.Num_Credit_Inquiries,
            data.Outstanding_Debt, data.Credit_History_Age,
            data.Total_EMI_per_month, data.Amount_invested_monthly,
            data.Monthly_Balance, data.Credit_Mix_label,
            data.Payment_of_Min_Amount_label, data.Type_of_Loan_label
        ]])

        scaled_input = credit_scaler.transform(input_array)
        prediction = credit_model.predict(scaled_input)[0]
        label_map = {0: "Good", 1: "Poor", 2: "Standard"}
        credit_score = label_map[int(prediction)]

        if credit_score == "Good":
            eligible, message, color = True, "Congratulations! You are eligible for a loan.", "green"
        elif credit_score == "Standard":
            eligible, message, color = True, "You are conditionally eligible for a loan.", "orange"
        else:
            eligible, message, color = False, "Sorry, you are not eligible for a loan.", "red"

        db.collection("credit_scores").document(user["uid"]).set({
            "uid": user["uid"],
            "credit_score": credit_score,
            "eligible": eligible,
            "calculated_at": datetime.now().isoformat()
        })

        return {"credit_score": credit_score, "eligible": eligible, "message": message, "color": color}

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# ================================================================
# LOAN ENDPOINTS
# ================================================================
@router.post("/apply-loan")
def apply_loan(data: LoanApplication, background_tasks: BackgroundTasks, user=Depends(verify_firebase_token)):
    try:
        # Enforce max loan limit from settings
        if data.loan_amount > settings.MAX_LOAN_AMOUNT:
            raise HTTPException(
                status_code=400,
                detail=f"Maximum loan amount is ₹{settings.MAX_LOAN_AMOUNT}. Please reduce your loan amount."
            )

        score_doc = db.collection("credit_scores").document(user["uid"]).get()
        if not score_doc.exists:
            raise HTTPException(status_code=400, detail="Please check your credit score first.")
        if not score_doc.to_dict().get("eligible"):
            raise HTTPException(status_code=403, detail="You are not eligible for a loan.")
        if not data.disclaimer_accepted:
            raise HTTPException(status_code=400, detail="You must accept the disclaimer.")

        emi = calculate_emi(data.loan_amount, data.rate_of_interest, data.loan_duration_months)
        total_payable = emi * data.loan_duration_months
        total_interest = total_payable - data.loan_amount

        loan_ref = db.collection("loans").document()
        loan_id = loan_ref.id

        loan_ref.set({
            "loan_id": loan_id,
            "uid": user["uid"],
            "loan_amount": data.loan_amount,
            "duration_months": data.loan_duration_months,
            "purpose": data.purpose,
            "rate_of_interest": data.rate_of_interest,
            "monthly_emi": round(emi, 2),
            "total_payable": round(total_payable, 2),
            "total_interest": round(total_interest, 2),
            "status": "pending_sahay_review",
            "disclaimer_accepted": True,
            "applied_at": datetime.now().isoformat()
        })

        today = date.today()
        for month in range(1, data.loan_duration_months + 1):
            due_date = today + relativedelta(months=month)
            db.collection("repayments").document(f"{loan_id}_month_{month}").set({
                "loan_id": loan_id,
                "uid": user["uid"],
                "month": month,
                "amount": round(emi, 2),
                "due_date": due_date.strftime("%Y-%m-%d"),
                "status": "upcoming",
                "penalty": 0
            })

        # Send loan application confirmation email
        from app.services.email import email_loan_applied
        user_doc = db.collection("users").document(user["uid"]).get().to_dict()
        background_tasks.add_task(email_loan_applied, user_doc["name"], user_doc["email"], data.loan_amount, loan_id)

        return {
            "status": "pending_sahay_review",
            "message": "Loan application submitted! SAHAY team will review and forward to a loan provider.",
            "loan_id": loan_id,
            "loan_details": {
                "loan_amount": data.loan_amount,
                "duration_months": data.loan_duration_months,
                "rate_of_interest": data.rate_of_interest,
                "monthly_emi": round(emi, 2),
                "total_payable": round(total_payable, 2),
                "total_interest": round(total_interest, 2),
                "purpose": data.purpose
            }
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/loan-status/{loan_id}")
def loan_status(loan_id: str, user=Depends(verify_firebase_token)):
    try:
        doc = db.collection("loans").document(loan_id).get()
        if not doc.exists:
            raise HTTPException(status_code=404, detail="Loan not found.")
        loan = doc.to_dict()
        if loan["uid"] != user["uid"]:
            raise HTTPException(status_code=403, detail="Unauthorized.")
        return {"status": loan["status"], "loan": loan}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/my-loans")
def my_loans(user=Depends(verify_firebase_token)):
    try:
        loans = db.collection("loans").where("uid", "==", user["uid"]).get()
        return {"loans": [l.to_dict() for l in loans]}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# ================================================================
# REPAYMENT ENDPOINTS
# ================================================================
@router.get("/repayment-schedule/{loan_id}")
def repayment_schedule(loan_id: str, user=Depends(verify_firebase_token)):
    try:
        emis = db.collection("repayments")\
            .where("loan_id", "==", loan_id)\
            .where("uid", "==", user["uid"]).get()
        schedule = sorted([e.to_dict() for e in emis], key=lambda x: x["month"])
        return {"loan_id": loan_id, "schedule": schedule}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/pay-emi")
def pay_emi(data: EMIPayment, background_tasks: BackgroundTasks, user=Depends(verify_firebase_token)):
    try:
        doc_id = f"{data.loan_id}_month_{data.month}"
        doc_ref = db.collection("repayments").document(doc_id)
        doc = doc_ref.get()
        if not doc.exists:
            raise HTTPException(status_code=404, detail="EMI record not found.")
        emi_data = doc.to_dict()
        if emi_data["uid"] != user["uid"]:
            raise HTTPException(status_code=403, detail="Unauthorized.")
        if emi_data["status"] == "paid":
            raise HTTPException(status_code=400, detail="This EMI is already paid.")
        doc_ref.update({"status": "paid", "paid_at": datetime.now().isoformat()})

        # Send EMI payment confirmation email
        from app.services.email import email_emi_paid
        user_doc = db.collection("users").document(user["uid"]).get().to_dict()
        background_tasks.add_task(email_emi_paid, user_doc["name"], user_doc["email"], data.month, emi_data["amount"])

        return {"status": "success", "message": f"EMI for month {data.month} paid successfully!"}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# ================================================================
# USER NOTIFICATIONS
# ================================================================
@router.get("/my-notifications")
def my_notifications(user=Depends(verify_firebase_token)):
    """User — Get all notifications sent by SAHAY Admin"""
    try:
        loans = db.collection("loans").where("uid", "==", user["uid"]).get()
        notifications = []
        for loan in loans:
            loan_data = loan.to_dict()
            if loan_data.get("user_notification"):
                notifications.append({
                    "loan_id": loan_data["loan_id"],
                    "message": loan_data["user_notification"],
                    "status": loan_data["status"],
                    "notified_at": loan_data.get("notified_at")
                })
        return {"notifications": notifications}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
