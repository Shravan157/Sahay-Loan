from pydantic import BaseModel
from typing import Optional
from app.core.config import ROLE_USER

class RegisterInput(BaseModel):
    email: str
    password: str
    name: str
    phone: str
    role: str = ROLE_USER           # "user", "sahay_admin", "provider_admin"
    company_id: Optional[str] = None  # required if role is provider_admin (for existing companies)
    
    # Self-registration fields for providers (when company_id is null)
    company_type: Optional[str] = None      # e.g., "NBFC", "Bank", "Fintech"
    cin: Optional[str] = None               # Company Identification Number
    gstin: Optional[str] = None             # GST Number
    pan: Optional[str] = None               # Company PAN
    registered_address: Optional[str] = None
    website: Optional[str] = None

class LoginInput(BaseModel):
    email: str
    password: str

class KYCInput(BaseModel):
    name: str
    age: int
    occupation: str
    annual_income: float
    monthly_inhand_salary: float
    phone: str
    email: str
    aadhaar_number: str
    pan_number: str

class OCRRequest(BaseModel):
    image_base64: str
    doc_type: str                   # "aadhaar" or "pan"
    file_extension: str = "jpg"     # "jpg", "jpeg", "png", "pdf"

class CreditScoreInput(BaseModel):
    Annual_Income: float
    Monthly_Inhand_Salary: float
    Num_Bank_Accounts: float
    Num_Credit_Card: float
    Interest_Rate: float
    Num_of_Loan: float
    Delay_from_due_date: float
    Num_of_Delayed_Payment: float
    Changed_Credit_Limit: float
    Num_Credit_Inquiries: float
    Outstanding_Debt: float
    Credit_History_Age: float
    Total_EMI_per_month: float
    Amount_invested_monthly: float
    Monthly_Balance: float
    Credit_Mix_label: int
    Payment_of_Min_Amount_label: int
    Type_of_Loan_label: int

class LoanApplication(BaseModel):
    loan_amount: float
    loan_duration_months: int
    purpose: str
    rate_of_interest: float
    disclaimer_accepted: bool

class EMIPayment(BaseModel):
    loan_id: str
    month: int
    amount: float

class AddCompanyInput(BaseModel):
    name: str                       # e.g. "HDFC Bank"
    email: str                      # company admin email
    password: str                   # company admin password
    phone: str
    description: Optional[str] = ""

class SharePhase1Input(BaseModel):
    loan_id: str
    company_id: str                 # which company to share with

class SharePhase2Input(BaseModel):
    share_id: str                   # the phase1 share document ID
    company_id: str

class RequestFullDetailsInput(BaseModel):
    share_id: str
    reason: str                     # why full details are needed

class LoanDecisionInput(BaseModel):
    share_id: str
    decision: str                   # "approved" or "rejected"
    reason: Optional[str] = ""
    offered_interest_rate: Optional[float] = None  # if approved

# Stripe Payment Schemas
class CreatePaymentIntentInput(BaseModel):
    loan_id: str
    month: int

class ConfirmEMIPaymentInput(BaseModel):
    loan_id: str
    month: int
    payment_intent_id: str  # returned by Stripe after Flutter confirms payment

class ProviderDocumentUpdate(BaseModel):
    document_type: str              # e.g., "gst_certificate"
    document_name: str              # e.g., "GST Registration Certificate"
    file_base64: str                # document content
    file_extension: str = "pdf"     # "pdf", "jpg", "png"

class VerificationStatusChange(BaseModel):
    company_id: str
    status: str                     # "verified", "rejected", "pending"
    reason: Optional[str] = ""
