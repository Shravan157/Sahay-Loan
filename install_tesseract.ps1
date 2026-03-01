# Tesseract Installation Helper Script
# Run this after installing Tesseract OCR

$tesseractPath = "C:\Program Files\Tesseract-OCR"

# Check if Tesseract is installed
if (Test-Path "$tesseractPath\tesseract.exe") {
    Write-Host "Tesseract found at: $tesseractPath" -ForegroundColor Green
    
    # Get current user PATH
    $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
    
    # Check if already in PATH
    if ($currentPath -like "*$tesseractPath*") {
        Write-Host "Tesseract is already in your PATH" -ForegroundColor Green
    } else {
        # Add to PATH
        $newPath = $currentPath + ";" + $tesseractPath
        [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
        Write-Host "Added Tesseract to your PATH" -ForegroundColor Green
        Write-Host "Please restart your terminal/PowerShell for changes to take effect" -ForegroundColor Yellow
    }
    
    # Test Tesseract
    Write-Host "Testing Tesseract installation..." -ForegroundColor Cyan
    & "$tesseractPath\tesseract.exe" --version
    
} else {
    Write-Host "Tesseract not found at: $tesseractPath" -ForegroundColor Red
    Write-Host "Please install Tesseract first from: https://github.com/UB-Mannheim/tesseract/wiki" -ForegroundColor Yellow
}

Write-Host "Press Enter to exit..."
Read-Host
