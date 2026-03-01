from fastapi import APIRouter, HTTPException, Depends, BackgroundTasks
from datetime import datetime
from app.core.config import db, settings
from app.core.security import verify_firebase_token
from app.models.schemas import CreatePaymentIntentInput, ConfirmEMIPaymentInput
import stripe

router = APIRouter()

# Initialize Stripe
stripe.api_key = settings.STRIPE_SECRET_KEY


@router.post("/create-payment-intent")
def create_payment_intent(data: CreatePaymentIntentInput, user=Depends(verify_firebase_token)):
    """
    Step 1 of payment — create a Stripe PaymentIntent for EMI.
    Flutter receives client_secret and uses it to show Stripe payment sheet.
    Test card: 4242 4242 4242 4242 | any future date | any CVC
    """
    try:
        doc_id = f"{data.loan_id}_month_{data.month}"
        emi_doc = db.collection("repayments").document(doc_id).get()

        if not emi_doc.exists:
            raise HTTPException(status_code=404, detail="EMI record not found.")

        emi_data = emi_doc.to_dict()

        if emi_data["uid"] != user["uid"]:
            raise HTTPException(status_code=403, detail="Unauthorized.")

        if emi_data["status"] == "paid":
            raise HTTPException(status_code=400, detail="This EMI is already paid.")

        # Stripe amount is in smallest currency unit
        # For INR: amount in paise (1 INR = 100 paise)
        amount_paise = int(emi_data["amount"] * 100)

        # Create Stripe PaymentIntent
        intent = stripe.PaymentIntent.create(
            amount=amount_paise,
            currency="inr",
            metadata={
                "loan_id": data.loan_id,
                "month": str(data.month),
                "user_uid": user["uid"]
            },
            description=f"SAHAY EMI Payment - Loan {data.loan_id} - Month {data.month}"
        )

        # Save payment intent ID to Firestore
        db.collection("repayments").document(doc_id).update({
            "stripe_payment_intent_id": intent.id,
            "payment_initiated_at": datetime.now().isoformat()
        })

        return {
            "status": "success",
            "client_secret": intent.client_secret,   # Flutter needs this
            "payment_intent_id": intent.id,
            "amount": emi_data["amount"],
            "amount_paise": amount_paise,
            "currency": "inr",
            "month": data.month,
            "loan_id": data.loan_id,
            "publishable_key": settings.STRIPE_PUBLISHABLE_KEY  # Flutter needs this to init Stripe
        }

    except stripe.error.StripeError as e:
        raise HTTPException(status_code=400, detail=f"Stripe error: {str(e)}")
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/confirm-emi-payment")
def confirm_emi_payment(data: ConfirmEMIPaymentInput, background_tasks: BackgroundTasks, user=Depends(verify_firebase_token)):
    """
    Step 2 of payment — called after Flutter confirms payment with Stripe.
    Verifies payment status directly with Stripe, then marks EMI as paid.
    """
    try:
        # Verify with Stripe that payment actually succeeded
        intent = stripe.PaymentIntent.retrieve(data.payment_intent_id)

        if intent.status != "succeeded":
            raise HTTPException(
                status_code=400,
                detail=f"Payment not completed. Stripe status: {intent.status}"
            )

        # Double check metadata matches
        if intent.metadata.get("loan_id") != data.loan_id or \
           intent.metadata.get("month") != str(data.month):
            raise HTTPException(status_code=400, detail="Payment details mismatch.")

        doc_id = f"{data.loan_id}_month_{data.month}"
        doc_ref = db.collection("repayments").document(doc_id)
        doc = doc_ref.get()

        if not doc.exists:
            raise HTTPException(status_code=404, detail="EMI record not found.")

        emi_data = doc.to_dict()

        if emi_data["uid"] != user["uid"]:
            raise HTTPException(status_code=403, detail="Unauthorized.")

        if emi_data["status"] == "paid":
            raise HTTPException(status_code=400, detail="EMI already paid.")

        # Mark EMI as paid
        doc_ref.update({
            "status": "paid",
            "paid_at": datetime.now().isoformat(),
            "stripe_payment_intent_id": data.payment_intent_id,
            "stripe_amount_received": intent.amount_received
        })

        # Send confirmation email in background
        from app.services.email import email_emi_paid
        user_doc = db.collection("users").document(user["uid"]).get().to_dict()
        background_tasks.add_task(
            email_emi_paid,
            user_doc["name"],
            user_doc["email"],
            data.month,
            emi_data["amount"],
            data.payment_intent_id
        )

        return {
            "status": "success",
            "message": f"EMI for month {data.month} paid successfully!",
            "payment_intent_id": data.payment_intent_id,
            "amount_paid": emi_data["amount"]
        }

    except stripe.error.StripeError as e:
        raise HTTPException(status_code=400, detail=f"Stripe error: {str(e)}")
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/payment-status/{loan_id}/{month}")
def payment_status(loan_id: str, month: int, user=Depends(verify_firebase_token)):
    """Check payment status of a specific EMI month"""
    try:
        doc_id = f"{loan_id}_month_{month}"
        doc = db.collection("repayments").document(doc_id).get()

        if not doc.exists:
            raise HTTPException(status_code=404, detail="EMI record not found.")

        emi_data = doc.to_dict()

        if emi_data["uid"] != user["uid"]:
            raise HTTPException(status_code=403, detail="Unauthorized.")

        return {
            "loan_id": loan_id,
            "month": month,
            "amount": emi_data["amount"],
            "status": emi_data["status"],
            "due_date": emi_data["due_date"],
            "paid_at": emi_data.get("paid_at"),
            "payment_intent_id": emi_data.get("stripe_payment_intent_id")
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
