# Development Requirements Status

**Generated**: January 26, 2026

## Current Status Summary

Based on the system check, here's the status of required development tools:

| Tool | Status | Version | Action Required |
|------|--------|---------|----------------|
| **Git** | ✅ Installed | 2.52.0.windows.1 | None |
| **Docker** | ✅ Installed | 28.5.2 | None |
| **Node.js** | ❌ Not Installed | - | **REQUIRED** - Install Node.js 18+ |
| **npm** | ❌ Not Installed | - | **REQUIRED** - Comes with Node.js |
| **Python** | ❌ Not Installed | - | Optional - Install if using Python backend |
| **PostgreSQL** | ❌ Not Installed | - | **REQUIRED** - Install or use Docker |
| **Redis** | ❌ Not Installed | - | **REQUIRED** - Install or use Docker |

## Quick Installation Guide

### ✅ Already Installed
- **Git**: Version control system ✓
- **Docker**: Container platform ✓ (can be used for PostgreSQL and Redis)

### 🔴 Required - Not Installed

#### 1. Node.js 18+ and npm

**Windows Installation:**
1. Download Node.js LTS from: https://nodejs.org/
2. Run the installer
3. Verify installation:
   ```powershell
   node --version
   npm --version
   ```

**Alternative - Using nvm-windows:**
1. Download from: https://github.com/coreybutler/nvm-windows/releases
2. Install `nvm-setup.exe`
3. Run:
   ```powershell
   nvm install lts
   nvm use lts
   ```

#### 2. PostgreSQL 14+

**Option A: Using Docker (Recommended)**
Since Docker is already installed, you can use it:

```powershell
# Start PostgreSQL using Docker Compose
cd c:\devendra\learning\cursor\agenticadmin
docker-compose up -d postgres

# Or manually:
docker run --name postgres-lms `
  -e POSTGRES_PASSWORD=postgres `
  -e POSTGRES_DB=lms `
  -p 5432:5432 `
  -d postgres:14
```

**Option B: Direct Installation**
1. Download from: https://www.postgresql.org/download/windows/
2. Run the installer
3. Remember the password for `postgres` user
4. Default port: 5432

#### 3. Redis 7+

**Option A: Using Docker (Recommended)**
```powershell
# Start Redis using Docker Compose
cd c:\devendra\learning\cursor\agenticadmin
docker-compose up -d redis

# Or manually:
docker run --name redis-lms `
  -p 6379:6379 `
  -d redis:7-alpine
```

**Option B: Using WSL2**
1. Install WSL2: https://learn.microsoft.com/en-us/windows/wsl/install
2. In WSL2 terminal:
   ```bash
   sudo apt update
   sudo apt install redis-server
   sudo service redis-server start
   ```

**Option C: Using Memurai (Windows Native)**
1. Download from: https://www.memurai.com/
2. Install and start the service

### 🟡 Optional - Not Installed

#### Python 3.10+ (Optional)
Only needed if you plan to use Python for the backend instead of Node.js/TypeScript.

**Windows Installation:**
1. Download from: https://www.python.org/downloads/
2. **Important**: Check "Add Python to PATH" during installation
3. Verify:
   ```powershell
   python --version
   ```

## Recommended Setup Path

Since Docker is already installed, the fastest way to get started:

### Step 1: Install Node.js
```powershell
# Download and install from https://nodejs.org/
# Or use nvm-windows for version management
```

### Step 2: Start Database Services with Docker
```powershell
cd c:\devendra\learning\cursor\agenticadmin
docker-compose up -d
```

This will start:
- PostgreSQL on port 5432
- Redis on port 6379

### Step 3: Verify Installation
Run the requirements check script:
```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\check-requirements.ps1
```

### Step 4: Install Project Dependencies
```powershell
npm install
```

## Next Steps After Installation

1. **Set up environment variables:**
   ```powershell
   cp .env.example .env
   # Edit .env with your configuration
   ```

2. **Run database migrations:**
   ```powershell
   npm run migrate
   ```

3. **Start development server:**
   ```powershell
   npm run dev
   ```

## Verification Commands

After installation, verify everything:

```powershell
# Check Node.js
node --version    # Should be v18.x.x or higher
npm --version     # Should be 9.x.x or higher

# Check Docker services
docker ps         # Should show postgres-lms and redis-lms

# Test PostgreSQL connection
docker exec -it postgres-lms psql -U postgres -c "SELECT version();"

# Test Redis connection
docker exec -it redis-lms redis-cli ping  # Should return PONG
```

## Troubleshooting

### Node.js Issues
- **Command not found**: Restart terminal after installation
- **Version mismatch**: Use nvm-windows to manage versions

### Docker Issues
- **Cannot connect**: Ensure Docker Desktop is running
- **Port conflicts**: Stop existing services using ports 5432 or 6379

### Database Connection Issues
- **Connection refused**: Ensure Docker containers are running (`docker ps`)
- **Authentication failed**: Check password in `.env` file (default: `postgres`)

## Additional Resources

- [SETUP.md](./SETUP.md) - Detailed installation guide
- [README.md](./README.md) - Project overview
- [DESIGN.md](./DESIGN.md) - Architecture documentation

---

**Note**: Run `.\scripts\check-requirements.ps1` anytime to check your setup status.
