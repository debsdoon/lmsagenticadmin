# Requirements Check Script for Windows
# This script checks if all required development tools are installed

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Agentic Admin LMS - Requirements Check" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$allInstalled = $true

# Check Node.js
Write-Host "Checking Node.js..." -ForegroundColor Yellow
$nodeCheck = Get-Command node -ErrorAction SilentlyContinue
if ($nodeCheck) {
    $nodeVersion = node --version
    Write-Host "  [OK] Node.js installed: $nodeVersion" -ForegroundColor Green
    $versionNumber = [int]($nodeVersion -replace 'v(\d+)\..*', '$1')
    if ($versionNumber -lt 18) {
        Write-Host "  [WARN] Warning: Node.js version should be 18 or higher" -ForegroundColor Yellow
    }
} else {
    Write-Host "  [X] Node.js NOT installed" -ForegroundColor Red
    Write-Host "    Install from: https://nodejs.org/" -ForegroundColor Gray
    $allInstalled = $false
}

# Check npm
Write-Host "Checking npm..." -ForegroundColor Yellow
$npmCheck = Get-Command npm -ErrorAction SilentlyContinue
if ($npmCheck) {
    $npmVersion = npm --version
    Write-Host "  [OK] npm installed: v$npmVersion" -ForegroundColor Green
} else {
    Write-Host "  [X] npm NOT installed" -ForegroundColor Red
    Write-Host "    npm comes with Node.js" -ForegroundColor Gray
    $allInstalled = $false
}

Write-Host ""

# Check Python (Optional)
Write-Host "Checking Python (optional)..." -ForegroundColor Yellow
$pythonCheck = Get-Command python -ErrorAction SilentlyContinue
if ($pythonCheck) {
    $pythonVersion = python --version 2>&1
    Write-Host "  [OK] Python installed: $pythonVersion" -ForegroundColor Green
} else {
    Write-Host "  [OPT] Python not installed (optional)" -ForegroundColor Yellow
    Write-Host "    Install from: https://www.python.org/ if using Python backend" -ForegroundColor Gray
}

Write-Host ""

# Check PostgreSQL
Write-Host "Checking PostgreSQL..." -ForegroundColor Yellow
$pgCheck = Get-Command psql -ErrorAction SilentlyContinue
if ($pgCheck) {
    $pgVersion = psql --version
    Write-Host "  [OK] PostgreSQL installed: $pgVersion" -ForegroundColor Green
} else {
    Write-Host "  [X] PostgreSQL NOT installed" -ForegroundColor Red
    Write-Host "    Options:" -ForegroundColor Gray
    Write-Host "    1. Install from: https://www.postgresql.org/download/windows/" -ForegroundColor Gray
    Write-Host "    2. Use Docker: docker-compose up -d postgres" -ForegroundColor Gray
    $allInstalled = $false
}

Write-Host ""

# Check Redis
Write-Host "Checking Redis..." -ForegroundColor Yellow
$redisCheck = Get-Command redis-cli -ErrorAction SilentlyContinue
if ($redisCheck) {
    $redisVersion = redis-cli --version
    Write-Host "  [OK] Redis installed: $redisVersion" -ForegroundColor Green
} else {
    Write-Host "  [X] Redis NOT installed" -ForegroundColor Red
    Write-Host "    Options:" -ForegroundColor Gray
    Write-Host "    1. Use WSL2: sudo apt install redis-server" -ForegroundColor Gray
    Write-Host "    2. Use Docker: docker-compose up -d redis" -ForegroundColor Gray
    Write-Host "    3. Use Memurai: https://www.memurai.com/" -ForegroundColor Gray
    $allInstalled = $false
}

Write-Host ""

# Check Docker (Optional)
Write-Host "Checking Docker (optional)..." -ForegroundColor Yellow
$dockerCheck = Get-Command docker -ErrorAction SilentlyContinue
if ($dockerCheck) {
    $dockerVersion = docker --version
    Write-Host "  [OK] Docker installed: $dockerVersion" -ForegroundColor Green
} else {
    Write-Host "  [OPT] Docker not installed (optional but recommended)" -ForegroundColor Yellow
    Write-Host "    Install from: https://www.docker.com/products/docker-desktop/" -ForegroundColor Gray
}

Write-Host ""

# Check Git
Write-Host "Checking Git..." -ForegroundColor Yellow
$gitCheck = Get-Command git -ErrorAction SilentlyContinue
if ($gitCheck) {
    $gitVersion = git --version
    Write-Host "  [OK] Git installed: $gitVersion" -ForegroundColor Green
} else {
    Write-Host "  [X] Git NOT installed" -ForegroundColor Red
    Write-Host "    Install from: https://git-scm.com/download/win" -ForegroundColor Gray
    $allInstalled = $false
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan

if ($allInstalled) {
    Write-Host "  [OK] All required tools are installed!" -ForegroundColor Green
    Write-Host "  You can proceed with project setup." -ForegroundColor Green
} else {
    Write-Host "  [X] Some required tools are missing" -ForegroundColor Red
    Write-Host "  Please install missing tools before proceeding." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  See SETUP.md for detailed installation instructions." -ForegroundColor Cyan
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
