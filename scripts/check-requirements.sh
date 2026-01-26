#!/bin/bash
# Requirements Check Script for Linux/macOS
# This script checks if all required development tools are installed

echo "========================================"
echo "  Agentic Admin LMS - Requirements Check"
echo "========================================"
echo ""

ALL_INSTALLED=true

# Check Node.js
echo "Checking Node.js..."
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    echo "  ✓ Node.js installed: $NODE_VERSION"
    # Check if version is 18 or higher
    NODE_MAJOR=$(echo $NODE_VERSION | sed 's/v\([0-9]*\).*/\1/')
    if [ "$NODE_MAJOR" -lt 18 ]; then
        echo "  ⚠ Warning: Node.js version should be 18 or higher"
    fi
else
    echo "  ✗ Node.js NOT installed"
    echo "    Install from: https://nodejs.org/ or use nvm"
    ALL_INSTALLED=false
fi

# Check npm
echo "Checking npm..."
if command -v npm &> /dev/null; then
    NPM_VERSION=$(npm --version)
    echo "  ✓ npm installed: v$NPM_VERSION"
else
    echo "  ✗ npm NOT installed"
    echo "    npm comes with Node.js"
    ALL_INSTALLED=false
fi

echo ""

# Check Python (Optional)
echo "Checking Python (optional)..."
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version)
    echo "  ✓ Python installed: $PYTHON_VERSION"
    # Check if version is 3.10 or higher
    PYTHON_MAJOR=$(python3 -c 'import sys; print(sys.version_info.major)')
    PYTHON_MINOR=$(python3 -c 'import sys; print(sys.version_info.minor)')
    if [ "$PYTHON_MAJOR" -lt 3 ] || ([ "$PYTHON_MAJOR" -eq 3 ] && [ "$PYTHON_MINOR" -lt 10 ]); then
        echo "  ⚠ Warning: Python version should be 3.10 or higher"
    fi
elif command -v python &> /dev/null; then
    PYTHON_VERSION=$(python --version)
    echo "  ✓ Python installed: $PYTHON_VERSION"
else
    echo "  ⚠ Python not installed (optional)"
    echo "    Install from: https://www.python.org/ if using Python backend"
fi

echo ""

# Check PostgreSQL
echo "Checking PostgreSQL..."
if command -v psql &> /dev/null; then
    PG_VERSION=$(psql --version)
    echo "  ✓ PostgreSQL installed: $PG_VERSION"
else
    echo "  ✗ PostgreSQL NOT installed"
    echo "    Options:"
    echo "    1. Install via package manager (apt/yum/brew)"
    echo "    2. Use Docker: docker run --name postgres-lms -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=lms -p 5432:5432 -d postgres:14"
    ALL_INSTALLED=false
fi

echo ""

# Check Redis
echo "Checking Redis..."
if command -v redis-cli &> /dev/null; then
    REDIS_VERSION=$(redis-cli --version)
    echo "  ✓ Redis installed: $REDIS_VERSION"
    # Test connection
    if redis-cli ping &> /dev/null; then
        echo "  ✓ Redis is running"
    else
        echo "  ⚠ Redis is installed but not running"
        echo "    Start with: sudo systemctl start redis or brew services start redis"
    fi
else
    echo "  ✗ Redis NOT installed"
    echo "    Options:"
    echo "    1. Install via package manager (apt/yum/brew)"
    echo "    2. Use Docker: docker run --name redis-lms -p 6379:6379 -d redis:7-alpine"
    ALL_INSTALLED=false
fi

echo ""

# Check Docker (Optional)
echo "Checking Docker (optional)..."
if command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version)
    echo "  ✓ Docker installed: $DOCKER_VERSION"
    if command -v docker-compose &> /dev/null; then
        DOCKER_COMPOSE_VERSION=$(docker-compose --version)
        echo "  ✓ Docker Compose installed: $DOCKER_COMPOSE_VERSION"
    fi
else
    echo "  ⚠ Docker not installed (optional but recommended)"
    echo "    Install from: https://docs.docker.com/get-docker/"
fi

echo ""

# Check Git
echo "Checking Git..."
if command -v git &> /dev/null; then
    GIT_VERSION=$(git --version)
    echo "  ✓ Git installed: $GIT_VERSION"
else
    echo "  ✗ Git NOT installed"
    echo "    Install via package manager"
    ALL_INSTALLED=false
fi

echo ""
echo "========================================"

if [ "$ALL_INSTALLED" = true ]; then
    echo "  ✓ All required tools are installed!"
    echo "  You can proceed with project setup."
else
    echo "  ✗ Some required tools are missing"
    echo "  Please install missing tools before proceeding."
    echo ""
    echo "  See SETUP.md for detailed installation instructions."
fi

echo "========================================"
echo ""
