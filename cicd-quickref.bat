@echo off
REM Quick reference for CI/CD Pipeline - Windows version

echo.
echo ================================================
echo ForenSecure CI/CD Pipeline - Quick Reference
echo ================================================
echo.
echo [94mPipeline Stages (Sequential):[0m
echo   1. Lint and Test (runs on all pushes to main)
echo   2. Build and Push (only if tests pass)
echo   3. Deploy (only if build succeeds)
echo.
echo [94mPipeline Components:[0m
echo.
echo Lint and Test:
echo   - Python 3.11 environment setup
echo   - Dependency installation from requirements.txt
echo   - Flake8 code quality checks
echo   - Pytest test execution
echo.
echo Build and Push:
echo   - Docker BuildX setup for multi-platform builds
echo   - GitHub Container Registry authentication
echo   - Docker image build with caching
echo   - Image push to ghcr.io
echo.
echo Deploy:
echo   - Ansible installation
echo   - Docker pull from registry
echo   - Container stop/remove (if exists)
echo   - New container deployment
echo   - Health verification
echo.
echo [92mQuick Commands:[0m
echo.
echo Trigger Pipeline:
echo   1. git add .
echo   2. git commit -m "your message"
echo   3. git push origin main
echo   4. View: GitHub Actions tab
echo.
echo Test Locally:
echo   python -m pytest tests/ -v
echo.
echo Lint Locally:
echo   flake8 cyber/ tests/
echo.
echo Build Docker Locally:
echo   docker build -t forensecure:test .
echo.
echo Test Ansible Locally:
echo   ansible-playbook ansible/playbook.yml -i ansible/inventory.ini
echo.
echo [94mFor detailed setup: See .github/CICD_SETUP.md[0m
echo ================================================
echo.
