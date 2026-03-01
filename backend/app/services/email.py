import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from app.core.config import settings

def send_email(to_email: str, subject: str, body: str):
    """Send email via Gmail SMTP — works for any email address"""
    try:
        msg = MIMEMultipart("alternative")
        msg["Subject"] = subject
        msg["From"] = settings.GMAIL_SENDER_EMAIL
        msg["To"] = to_email

        text_part = MIMEText(body, "plain")
        html_part = MIMEText(f"""
        <html>
          <body style="font-family: Arial, sans-serif; padding: 20px; color: #333;">
            <div style="max-width: 600px; margin: auto; border: 1px solid #ddd;
                 border-radius: 10px; padding: 30px;">
              <h2 style="color: #1565C0;">SAHAY Loan App</h2>
              <hr/>
              <p>{body.replace(chr(10), '<br/>')}</p>
              <hr/>
              <p style="font-size: 12px; color: #999;">
                This is an automated email from SAHAY Loan App.<br/>
                Please do not reply to this email.
              </p>
            </div>
          </body>
        </html>
        """, "html")

        msg.attach(text_part)
        msg.attach(html_part)

        with smtplib.SMTP_SSL("smtp.gmail.com", 465) as server:
            server.login(settings.GMAIL_SENDER_EMAIL, settings.GMAIL_APP_PASSWORD)
            server.sendmail(settings.GMAIL_SENDER_EMAIL, to_email, msg.as_string())

        print(f"✅ Email sent to {to_email}: {subject}")
        return True

    except Exception as e:
        print(f"❌ Email failed: {str(e)}")
        return False


def email_welcome(name: str, email: str):
    send_email(email, "Welcome to SAHAY Loan App! 🎉", f"""
Dear {name},

Welcome to SAHAY Loan App!

Your account has been created successfully.
You can now login and apply for a loan of up to ₹{settings.MAX_LOAN_AMOUNT}.

Next Steps:
1. Complete your KYC verification
2. Check your credit score
3. Apply for a loan

Thank you for choosing SAHAY!

Best Regards,
SAHAY Team
    """)

def email_kyc_submitted(name: str, email: str):
    send_email(email, "KYC Submitted Successfully ✅", f"""
Dear {name},

Your KYC details have been submitted and verified successfully!

You can now proceed to check your credit score and apply for a loan.

Best Regards,
SAHAY Team
    """)

def email_loan_applied(name: str, email: str, loan_amount: float, loan_id: str):
    send_email(email, "Loan Application Received 📋", f"""
Dear {name},

Your loan application has been received successfully!

Loan Details:
- Loan Amount : ₹{loan_amount}
- Loan ID     : {loan_id}
- Status      : Under Review by SAHAY Team

We will review your application and forward it to our loan provider partners.
You will be notified at every step.

Best Regards,
SAHAY Team
    """)

def email_loan_under_review(name: str, email: str, company_name: str, loan_amount: float):
    send_email(email, "Loan Application Forwarded to Bank 🏦", f"""
Dear {name},

Great news! Your loan application has been forwarded to {company_name} for review.

Loan Amount : ₹{loan_amount}
Status      : Under Review by {company_name}

The bank will review your application and may request additional details.
You will be notified once a decision is made.

Best Regards,
SAHAY Team
    """)

def email_phase2_requested(name: str, email: str, company_name: str):
    send_email(email, "Additional Verification Required 🔍", f"""
Dear {name},

{company_name} has requested additional verification details for your loan application.

Our SAHAY team is reviewing this request.
Your complete details will be shared only after our approval.

You will be notified once the review is complete.

Best Regards,
SAHAY Team
    """)

def email_loan_approved(name: str, email: str, loan_amount: float,
                        company_name: str, interest_rate: float, monthly_emi: float):
    send_email(email, "🎉 Loan Approved! Congratulations!", f"""
Dear {name},

Congratulations! Your loan application has been APPROVED!

Loan Details:
- Approved Amount : ₹{loan_amount}
- Approved by     : {company_name}
- Interest Rate   : {interest_rate}% per annum
- Monthly EMI     : ₹{monthly_emi}

The loan amount will be disbursed to your registered bank account shortly.
Please check your SAHAY app for the repayment schedule.

Best Regards,
SAHAY Team
    """)

def email_loan_rejected(name: str, email: str, company_name: str, reason: str):
    send_email(email, "Loan Application Update", f"""
Dear {name},

We regret to inform you that your loan application has been reviewed by {company_name}.

Decision : Not Approved
Reason   : {reason}

You may apply again after 3 months or improve your credit score for better chances.

Best Regards,
SAHAY Team
    """)

def email_emi_paid(name: str, email: str, month: int, amount: float):
    send_email(email, f"EMI Payment Confirmed ✅ - Month {month}", f"""
Dear {name},

Your EMI payment has been received successfully!

Payment Details:
- Month       : {month}
- Amount Paid : ₹{amount}
- Status      : Paid ✅

Thank you for your timely payment.

Best Regards,
SAHAY Team
    """)

def email_notify_user(name: str, email: str, message: str):
    send_email(email, "Loan Update from SAHAY 📢", f"""
Dear {name},

{message}

Best Regards,
SAHAY Team
    """)

def email_loan_disbursed(name: str, email: str, loan_amount: float,
                         company_name: str, monthly_emi: float,
                         duration_months: int, loan_id: str):
    send_email(email, "💰 Loan Amount Disbursed!", f"""
Dear {name},

Great news! Your loan amount has been disbursed successfully!

Disbursement Details:
- Loan Amount Disbursed : ₹{loan_amount}
- Disbursed by          : {company_name}
- Monthly EMI           : ₹{monthly_emi}
- Duration              : {duration_months} months
- Loan ID               : {loan_id}

Your EMI schedule is now active.
Please pay your EMIs on time to maintain a good credit score.

Open the SAHAY app to view your repayment schedule.

Best Regards,
SAHAY Team
    """)
