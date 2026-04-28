Param(
    [switch]$WithDocker
)

Write-Host "[1/4] Backend virtual environment setup"
Push-Location "../backend"
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install --upgrade pip
pip install -r requirements.txt
Pop-Location

Write-Host "[2/4] Flutter dependency setup"
Push-Location "../frontend"
flutter pub get
Pop-Location

if ($WithDocker) {
    Write-Host "[3/4] Starting PostgreSQL with Docker"
    docker compose -f ../infra/docker-compose.yml up -d db
}

Write-Host "[4/4] Setup complete"
