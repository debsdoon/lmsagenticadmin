# Development Environment Setup Guide

This guide will help you set up all the required tools and dependencies for developing the Agentic Admin LMS platform.

## Prerequisites Checklist

- [ ] Node.js 18+ and npm
- [ ] Python 3.10+ (optional, for Python backend)
- [ ] PostgreSQL 14+
- [ ] Redis 7+
- [ ] Git (already installed ✓)
- [ ] Docker (optional, for containerized services)
- [ ] Code Editor (Cursor/VS Code)

## Installation Instructions

### 1. Node.js and npm

Node.js is required for the frontend (React/Next.js) and TypeScript backend.

#### Windows Installation

**Option A: Using Node Version Manager (nvm-windows) - Recommended**

1. Download nvm-windows from: https://github.com/coreybutler/nvm-windows/releases
2. Install the latest `nvm-setup.exe`
3. Open a new PowerShell/Command Prompt as Administrator
4. Install Node.js LTS:
   ```powershell
   nvm install lts
   nvm use lts
   ```
5. Verify installation:
   ```powershell
   node --version  # Should show v18.x.x or higher
   npm --version   # Should show 9.x.x or higher
   ```

**Option B: Direct Installation**

1. Download Node.js LTS from: https://nodejs.org/
2. Run the installer and follow the setup wizard
3. Verify installation:
   ```powershell
   node --version
   npm --version
   ```

#### macOS Installation

```bash
# Using Homebrew
brew install node

# Or using nvm (recommended)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
nvm install --lts
nvm use --lts
```

#### Linux Installation

```bash
# Using nvm (recommended)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
source ~/.bashrc
nvm install --lts
nvm use --lts

# Or using package manager (Ubuntu/Debian)
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs
```

### 2. Python 3.10+ (Optional)

Python is optional if you choose to use Python for the backend instead of Node.js/TypeScript.

#### Windows Installation

1. Download Python 3.10+ from: https://www.python.org/downloads/
2. **Important**: Check "Add Python to PATH" during installation
3. Verify installation:
   ```powershell
   python --version
   pip --version
   ```

#### macOS Installation

```bash
# Using Homebrew
brew install python@3.11

# Verify
python3 --version
pip3 --version
```

#### Linux Installation

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install python3.11 python3-pip

# Verify
python3 --version
pip3 --version
```

### 3. PostgreSQL

PostgreSQL is the primary database for the LMS platform.

#### Windows Installation

**Option A: Using Installer**

1. Download PostgreSQL from: https://www.postgresql.org/download/windows/
2. Run the installer
3. Remember the password you set for the `postgres` user
4. Default port: 5432
5. Verify installation:
   ```powershell
   psql --version
   ```

**Option B: Using Docker (Recommended for Development)**

```powershell
docker run --name postgres-lms -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=lms -p 5432:5432 -d postgres:14
```

#### macOS Installation

```bash
# Using Homebrew
brew install postgresql@14
brew services start postgresql@14

# Create database
createdb lms

# Verify
psql --version
```

#### Linux Installation

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install postgresql-14 postgresql-contrib

# Start service
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Create database
sudo -u postgres createdb lms

# Verify
psql --version
```

#### Docker Alternative (All Platforms)

```bash
docker run --name postgres-lms \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=lms \
  -p 5432:5432 \
  -d postgres:14
```

### 4. Redis

Redis is used for caching and task queues.

#### Windows Installation

**Option A: Using WSL2 (Recommended)**

1. Install WSL2: https://learn.microsoft.com/en-us/windows/wsl/install
2. In WSL2 terminal:
   ```bash
   sudo apt update
   sudo apt install redis-server
   sudo service redis-server start
   ```

**Option B: Using Memurai (Windows Native)**

1. Download from: https://www.memurai.com/
2. Install and start the service
3. Default port: 6379

**Option C: Using Docker (Recommended)**

```powershell
docker run --name redis-lms -p 6379:6379 -d redis:7-alpine
```

#### macOS Installation

```bash
# Using Homebrew
brew install redis
brew services start redis

# Verify
redis-cli ping  # Should return PONG
```

#### Linux Installation

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install redis-server
sudo systemctl start redis-server
sudo systemctl enable redis-server

# Verify
redis-cli ping  # Should return PONG
```

#### Docker Alternative (All Platforms)

```bash
docker run --name redis-lms \
  -p 6379:6379 \
  -d redis:7-alpine
```

### 5. Docker (Optional but Recommended)

Docker makes it easy to run PostgreSQL and Redis without local installation.

#### Windows Installation

1. Download Docker Desktop from: https://www.docker.com/products/docker-desktop/
2. Install and restart your computer
3. Verify:
   ```powershell
   docker --version
   docker-compose --version
   ```

#### macOS Installation

```bash
# Download from Docker Desktop website or
brew install --cask docker
```

#### Linux Installation

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install docker.io docker-compose
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
# Log out and log back in
```

## Quick Setup Scripts

### Windows PowerShell Setup Script

Create and run `setup-windows.ps1`:

```powershell
# Check Node.js
if (!(Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "Node.js not found. Please install from https://nodejs.org/" -ForegroundColor Yellow
} else {
    Write-Host "Node.js: $(node --version)" -ForegroundColor Green
}

# Check Python
if (!(Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Host "Python not found. Optional - install from https://www.python.org/" -ForegroundColor Yellow
} else {
    Write-Host "Python: $(python --version)" -ForegroundColor Green
}

# Check PostgreSQL
if (!(Get-Command psql -ErrorAction SilentlyContinue)) {
    Write-Host "PostgreSQL not found. Install or use Docker." -ForegroundColor Yellow
} else {
    Write-Host "PostgreSQL: $(psql --version)" -ForegroundColor Green
}

# Check Redis
if (!(Get-Command redis-cli -ErrorAction SilentlyContinue)) {
    Write-Host "Redis not found. Install or use Docker." -ForegroundColor Yellow
} else {
    Write-Host "Redis: $(redis-cli --version)" -ForegroundColor Green
}

# Check Docker
if (!(Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "Docker not found. Optional but recommended." -ForegroundColor Yellow
} else {
    Write-Host "Docker: $(docker --version)" -ForegroundColor Green
}

Write-Host "`nSetup check complete!" -ForegroundColor Cyan
```

### Docker Compose Setup (All Platforms)

Create `docker-compose.yml` in project root:

```yaml
version: '3.8'

services:
  postgres:
    image: postgres:14
    container_name: postgres-lms
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: lms
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    container_name: redis-lms
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5

volumes:
  postgres_data:
  redis_data:
```

Start services:
```bash
docker-compose up -d
```

## Verification Steps

After installation, verify everything is working:

```powershell
# Check Node.js
node --version    # Should be v18.x.x or higher
npm --version     # Should be 9.x.x or higher

# Check Python (optional)
python --version  # Should be 3.10.x or higher

# Check PostgreSQL
psql --version    # Should show PostgreSQL version
# Test connection
psql -U postgres -h localhost -c "SELECT version();"

# Check Redis
redis-cli --version
# Test connection
redis-cli ping    # Should return PONG

# Check Docker (optional)
docker --version
docker-compose --version
```

## Project Setup

Once all tools are installed:

1. **Clone/Navigate to project**:
   ```bash
   cd agenticadmin
   ```

2. **Install Node.js dependencies**:
   ```bash
   npm install
   ```

3. **Set up environment variables**:
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

4. **Set up database**:
   ```bash
   npm run migrate
   # or
   python manage.py migrate
   ```

5. **Start development server**:
   ```bash
   npm run dev
   # or
   python manage.py runserver
   ```

## Troubleshooting

### Node.js Issues

- **Command not found**: Restart terminal after installation
- **Version mismatch**: Use nvm to manage multiple Node.js versions
- **Permission errors**: Run terminal as Administrator (Windows) or use sudo (Linux/macOS)

### PostgreSQL Issues

- **Connection refused**: Ensure PostgreSQL service is running
- **Authentication failed**: Check username/password in .env file
- **Port already in use**: Change port in postgresql.conf or use different port

### Redis Issues

- **Connection refused**: Ensure Redis service is running
- **Windows**: Use WSL2 or Docker for Redis on Windows
- **Permission denied**: Check Redis configuration file permissions

### Docker Issues

- **Cannot connect**: Ensure Docker Desktop is running
- **Port conflicts**: Stop existing services using the same ports
- **WSL2 backend**: On Windows, ensure WSL2 is properly configured

## Next Steps

After setup is complete:

1. Review [README.md](./README.md) for project overview
2. Check [DESIGN.md](./DESIGN.md) for architecture details
3. Read [docs/AGENTS.md](./docs/AGENTS.md) for agent development
4. Set up your IDE/editor with appropriate extensions
5. Configure your LLM API keys in `.env` file

## Additional Resources

- [Node.js Documentation](https://nodejs.org/docs/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Redis Documentation](https://redis.io/docs/)
- [Docker Documentation](https://docs.docker.com/)

---

**Last Updated**: January 26, 2026
