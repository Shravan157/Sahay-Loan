# SAHAY App - Run with ngrok for Phone Access
# This script starts the Flutter web server and exposes it via ngrok

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  SAHAY App - ngrok Phone Access Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if ngrok is configured
$ngrokPath = "C:\ngrok\ngrok.exe"
if (-not (Test-Path $ngrokPath)) {
    Write-Host "ERROR: ngrok not found at C:\ngrok" -ForegroundColor Red
    Write-Host "Please run the installation steps first." -ForegroundColor Yellow
    exit 1
}

# Check if ngrok authtoken is set
Write-Host "Step 1: Checking ngrok authentication..." -ForegroundColor Yellow
$authtokenCheck = & $ngrokPath config check 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "ngrok requires an authtoken to work." -ForegroundColor Red
    Write-Host ""
    Write-Host "Get your free authtoken from: https://dashboard.ngrok.com/get-started/your-authtoken" -ForegroundColor Cyan
    Write-Host ""
    $authtoken = Read-Host "Enter your ngrok authtoken"
    
    if ($authtoken) {
        & $ngrokPath config add-authtoken $authtoken
        Write-Host "Authtoken configured successfully!" -ForegroundColor Green
    } else {
        Write-Host "No authtoken provided. Exiting..." -ForegroundColor Red
        exit 1
    }
}

Write-Host "ngrok is configured!" -ForegroundColor Green
Write-Host ""

# Start Flutter web server in background
Write-Host "Step 2: Starting Flutter web server..." -ForegroundColor Yellow
$flutterJob = Start-Job -ScriptBlock {
    Set-Location "C:\Users\Shravan\Desktop\sahay_loan_app"
    flutter run -d web-server --web-port 8080 --web-hostname 0.0.0.0
}

# Wait for Flutter to start
Write-Host "Waiting for Flutter server to start..." -ForegroundColor Gray
Start-Sleep -Seconds 15

# Check if Flutter is running
$flutterRunning = Get-Job -Id $flutterJob.Id | Select-Object -ExpandProperty State
if ($flutterRunning -eq "Running") {
    Write-Host "Flutter server is running on http://localhost:8080" -ForegroundColor Green
} else {
    Write-Host "Failed to start Flutter server. Check the logs:" -ForegroundColor Red
    Receive-Job -Id $flutterJob.Id
    exit 1
}

Write-Host ""
Write-Host "Step 3: Starting ngrok tunnel..." -ForegroundColor Yellow
Write-Host ""

# Start ngrok
& $ngrokPath http 8080

# Cleanup when ngrok exits
Stop-Job -Id $flutterJob.Id
Remove-Job -Id $flutterJob.Id

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Server stopped. Goodbye!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
