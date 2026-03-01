import re

def extract_aadhaar_details(text: str) -> dict:
    details = {"aadhaar_number": None, "name": None, "dob": None, "gender": None}
    match = re.search(r'\b\d{4}\s\d{4}\s\d{4}\b', text)
    if match:
        details["aadhaar_number"] = match.group().replace(" ", "")
    dob = re.search(r'\b\d{2}[/-]\d{2}[/-]\d{4}\b', text)
    if dob:
        details["dob"] = dob.group()
    if "MALE" in text.upper():
        details["gender"] = "Male"
    elif "FEMALE" in text.upper():
        details["gender"] = "Female"
    lines = text.split('\n')
    for i, line in enumerate(lines):
        if "Government of India" in line or "GOVERNMENT OF INDIA" in line:
            if i + 1 < len(lines):
                details["name"] = lines[i + 1].strip()
            break
    return details


def extract_pan_details(text: str) -> dict:
    details = {"pan_number": None, "name": None, "dob": None, "father_name": None}
    match = re.search(r'\b[A-Z]{5}[0-9]{4}[A-Z]{1}\b', text)
    if match:
        details["pan_number"] = match.group()
    dob = re.search(r'\b\d{2}[/-]\d{2}[/-]\d{4}\b', text)
    if dob:
        details["dob"] = dob.group()
    lines = text.split('\n')
    name_index = None
    for i, line in enumerate(lines):
        if "Name" in line or "NAME" in line:
            if i + 1 < len(lines):
                details["name"] = lines[i + 1].strip()
                name_index = i + 1
            break
    if name_index:
        for i in range(name_index + 1, len(lines)):
            if lines[i].strip() and not re.search(r'\d', lines[i]):
                details["father_name"] = lines[i].strip()
                break
    return details


def calculate_emi(principal: float, annual_rate: float, months: int) -> float:
    R = (annual_rate / 100) / 12
    N = months
    if R == 0:
        return principal / N
    return principal * R * ((1 + R) ** N) / (((1 + R) ** N) - 1)
