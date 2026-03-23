"""
Notification Service for sending push notifications via FCM
"""
import os
from firebase_admin import messaging, firestore
from app.core.config import db

def send_notification(
    fcm_token: str,
    title: str,
    body: str,
    data: dict = None
) -> bool:
    """
    Send a push notification to a specific device
    
    Args:
        fcm_token: The FCM token of the target device
        title: Notification title
        body: Notification body
        data: Optional data payload
        
    Returns:
        True if successful, False otherwise
    """
    try:
        message = messaging.Message(
            notification=messaging.Notification(
                title=title,
                body=body,
            ),
            data=data or {},
            token=fcm_token,
        )
        
        response = messaging.send(message)
        print(f"Successfully sent notification: {response}")
        return True
        
    except Exception as e:
        print(f"Error sending notification: {e}")
        return False


def send_notification_to_user(
    user_id: str,
    title: str,
    body: str,
    notification_type: str = None,
    data: dict = None
) -> bool:
    """
    Send notification to a user (looks up their FCM token)
    
    Args:
        user_id: The user's UID
        title: Notification title
        body: Notification body
        notification_type: Type of notification for routing
        data: Optional additional data
        
    Returns:
        True if successful, False otherwise
    """
    try:
        # Get user's FCM token from Firestore
        user_doc = db.collection("users").document(user_id).get()
        
        if not user_doc.exists:
            print(f"User {user_id} not found")
            return False
            
        user_data = user_doc.to_dict()
        fcm_token = user_data.get("fcm_token")
        
        if not fcm_token:
            print(f"No FCM token for user {user_id}")
            return False
        
        # Prepare notification data
        notification_data = {
            "type": notification_type or "general",
            **(data or {}),
            "timestamp": str(int(datetime.now().timestamp())),
        }
        
        # Store notification in Firestore
        db.collection("users").document(user_id).collection("notifications").add({
            "title": title,
            "body": body,
            "type": notification_type,
            "data": data,
            "read": False,
            "created_at": datetime.now().isoformat(),
        })
        
        # Send push notification
        return send_notification(fcm_token, title, body, notification_data)
        
    except Exception as e:
        print(f"Error sending notification to user: {e}")
        return False


def send_welcome_notification(user_id: str, user_name: str):
    """Send welcome notification after login"""
    send_notification_to_user(
        user_id=user_id,
        title=f"Welcome to SAHAY, {user_name}! 🎉",
        body="Your trusted loan partner is here to help you achieve your dreams.",
        notification_type="welcome",
        data={"action": "dashboard"}
    )


def send_kyc_submitted_notification(user_id: str):
    """Send notification when KYC is submitted"""
    send_notification_to_user(
        user_id=user_id,
        title="KYC Documents Submitted 📄",
        body="Your documents are under review. We'll notify you once verified.",
        notification_type="kyc_submitted",
        data={"action": "kyc_status"}
    )


def send_kyc_verified_notification(user_id: str):
    """Send notification when KYC is verified"""
    send_notification_to_user(
        user_id=user_id,
        title="KYC Verified ✅",
        body="Congratulations! Your KYC has been verified. You can now apply for loans.",
        notification_type="kyc_verified",
        data={"action": "apply_loan"}
    )


def send_kyc_rejected_notification(user_id: str, reason: str = None):
    """Send notification when KYC is rejected"""
    body = f"Your KYC was rejected. {reason if reason else 'Please re-submit your documents.'}"
    send_notification_to_user(
        user_id=user_id,
        title="KYC Rejected ❌",
        body=body,
        notification_type="kyc_rejected",
        data={"action": "kyc"}
    )


def send_loan_applied_notification(user_id: str, loan_amount: float):
    """Send notification when loan is applied"""
    send_notification_to_user(
        user_id=user_id,
        title="Loan Application Submitted 💰",
        body=f"Your loan application for ₹{loan_amount:,.0f} has been received.",
        notification_type="loan_applied",
        data={"action": "my_loans"}
    )


def send_loan_approved_notification(user_id: str, loan_amount: float, interest_rate: float = None):
    """Send notification when loan is approved"""
    body = f"Great news! Your loan of ₹{loan_amount:,.0f} has been approved."
    if interest_rate:
        body += f" Interest rate: {interest_rate}%"
    
    send_notification_to_user(
        user_id=user_id,
        title="Loan Approved! 🎉",
        body=body,
        notification_type="loan_approved",
        data={"action": "my_loans"}
    )


def send_loan_rejected_notification(user_id: str, reason: str = None):
    """Send notification when loan is rejected"""
    body = f"Your loan application was rejected. {reason if reason else 'Please contact support for details.'}"
    send_notification_to_user(
        user_id=user_id,
        title="Loan Application Update",
        body=body,
        notification_type="loan_rejected",
        data={"action": "my_loans"}
    )


def send_loan_disbursed_notification(user_id: str, loan_amount: float):
    """Send notification when loan is disbursed"""
    send_notification_to_user(
        user_id=user_id,
        title="Loan Disbursed! 💸",
        body=f"₹{loan_amount:,.0f} has been credited to your account. Check your repayment schedule.",
        notification_type="loan_disbursed",
        data={"action": "repayment_schedule"}
    )


def send_emi_due_notification(user_id: str, amount: float, due_date: str):
    """Send EMI due reminder"""
    send_notification_to_user(
        user_id=user_id,
        title="EMI Reminder 📅",
        body=f"Your EMI of ₹{amount:,.0f} is due on {due_date}. Pay now to avoid late fees.",
        notification_type="emi_due",
        data={"action": "pay_emi"}
    )


def send_payment_success_notification(user_id: str, amount: float, month: int):
    """Send notification on successful EMI payment"""
    send_notification_to_user(
        user_id=user_id,
        title="Payment Successful ✅",
        body=f"₹{amount:,.0f} paid for Month {month} EMI. Thank you for your payment!",
        notification_type="payment_success",
        data={"action": "payment_history"}
    )


def send_payment_failed_notification(user_id: str, amount: float):
    """Send notification on failed payment"""
    send_notification_to_user(
        user_id=user_id,
        title="Payment Failed ❌",
        body=f"Your payment of ₹{amount:,.0f} failed. Please try again.",
        notification_type="payment_failed",
        data={"action": "pay_emi"}
    )


# Import datetime
from datetime import datetime
