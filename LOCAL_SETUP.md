# Local Development Environment Setup

This guide helps you set up your local environment to match the CI/CD pipeline.

## System Requirements

- **OS**: Windows, macOS, or Linux
- **Python**: 3.11+ (same as pipeline)
- **Docker**: Latest stable version
- **Git**: Latest version
- **Ansible**: 2.9+

## Step-by-Step Setup

### 1. Clone Repository

```bash
git clone https://github.com/your-username/ml3.git
cd ml3
```

### 2. Create Virtual Environment

**Windows (PowerShell):**
```powershell
python -m venv venv
.\venv\Scripts\Activate.ps1
```

**Windows (Command Prompt):**
```cmd
python -m venv venv
venv\Scripts\activate.bat
```

**macOS/Linux:**
```bash
python3 -m venv venv
source venv/bin/activate
```

### 3. Install Dependencies

```bash
pip install --upgrade pip
pip install -r cyber/requirements.txt
```

### 4. Install Development Tools

```bash
# Already in requirements.txt, but explicitly for clarity
pip install pytest pytest-cov flake8 ansible
```

### 5. Verify Installation

```bash
python --version      # Should be 3.11+
pytest --version
flake8 --version
docker --version
ansible --version
```

## Running Tests

### Run All Tests
```bash
pytest tests/ -v
```

### Run with Coverage Report
```bash
pytest tests/ -v --cov=cyber --cov-report=html
# View report: htmlcov/index.html
```

### Run Specific Test
```bash
pytest tests/test_app.py::test_index_route -v
```

### Watch Mode (auto-run on file changes)
```bash
pip install pytest-watch
ptw tests/
```

## Code Quality Checks

### Run Flake8
```bash
flake8 cyber/ tests/
```

### Strict Flake8 (stop on errors)
```bash
flake8 cyber/ tests/ --select=E9,F63,F7,F82
```

### Auto-format Code (optional)
```bash
pip install black autopep8
black cyber/ tests/  # Black formatter
# or
autopep8 --in-place --aggressive --aggressive cyber/*.py
```

## Docker Setup

### Build Locally
```bash
docker build -t forensecure:dev .
```

### Run Container
```bash
docker run -it -p 8501:8501 forensecure:dev
```

### Access Application
- Open browser: http://localhost:8501

### Clean Up
```bash
docker stop $(docker ps -q -f ancestor=forensecure:dev)
docker rmi forensecure:dev
```

## Ansible Testing

### Check Playbook Syntax
```bash
ansible-playbook ansible/playbook.yml --syntax-check
```

### Dry Run (no changes)
```bash
ansible-playbook ansible/playbook.yml -i ansible/inventory.ini --check -v
```

### Run Locally
```bash
ansible-playbook ansible/playbook.yml -i ansible/inventory.ini -e "docker_image=forensecure:dev"
```

## Git Workflow

### Before Pushing

1. **Create a feature branch**
   ```bash
   git checkout -b feature/my-feature
   ```

2. **Make changes and commit**
   ```bash
   git add .
   git commit -m "Add feature description"
   ```

3. **Run local checks**
   ```bash
   pytest tests/ -v
   flake8 cyber/ tests/
   ```

4. **Push to GitHub**
   ```bash
   git push origin feature/my-feature
   ```

5. **Create Pull Request on GitHub**

### After CI/CD Completes

- Review pipeline results in GitHub Actions
- Check for test failures or lint warnings
- Address any issues and push fixes
- Merge to main after approval

## Troubleshooting

### Python Version Issues

```bash
# Check Python version
python --version  # or python3 --version

# Use specific version (if multiple installed)
python3.11 -m venv venv
```

### Virtual Environment Not Activating

Try explicit path:
```bash
# Windows
.\venv\Scripts\python.exe --version

# macOS/Linux
./venv/bin/python --version
```

### Dependencies Not Installing

```bash
# Upgrade pip
pip install --upgrade pip

# Install with verbose output
pip install -r cyber/requirements.txt -v

# Check for conflicts
pip check
```

### Docker Permission Denied

**Linux only:**
```bash
# Add user to docker group
sudo usermod -aG docker $USER
# Log out and back in for changes to take effect
newgrp docker
```

### Tests Fail with Import Errors

```bash
# Ensure virtual environment is activated
# Windows: .\venv\Scripts\Activate.ps1
# macOS/Linux: source venv/bin/activate

# Reinstall dependencies
pip install -r cyber/requirements.txt --force-reinstall
```

## Useful Commands Reference

```bash
# Activate virtual environment
source venv/bin/activate              # macOS/Linux
.\venv\Scripts\Activate.ps1           # Windows PowerShell
venv\Scripts\activate.bat             # Windows CMD

# Deactivate virtual environment
deactivate

# Update dependencies
pip install -r cyber/requirements.txt --upgrade

# Freeze current dependencies
pip freeze > requirements-current.txt

# Run specific test file
pytest tests/test_app.py -v

# Show test coverage
pytest tests/ --cov=cyber --cov-report=term-missing

# Build and run Docker
docker build -t forensecure:dev .
docker run -it -p 8501:8501 forensecure:dev

# List running containers
docker ps

# View container logs
docker logs <container-id>
```

## IDE/Editor Setup

### VS Code Setup

1. **Install Python Extension**
   - Python (by Microsoft)
   - Pylance (optional)

2. **Select Interpreter**
   - Ctrl+Shift+P → "Python: Select Interpreter"
   - Choose `./venv/bin/python`

3. **Add Test Settings** (`.vscode/settings.json`)
   ```json
   {
     "python.linting.enabled": true,
     "python.linting.flake8Enabled": true,
     "python.linting.flake8Args": ["--max-line-length=120"],
     "python.testing.pytestEnabled": true,
     "python.testing.pytestArgs": ["tests"]
   }
   ```

### PyCharm Setup

1. **Configure Python Interpreter**
   - File → Settings → Project → Python Interpreter
   - Add Interpreter → Add Local Interpreter → Existing Environment
   - Select `venv/bin/python`

2. **Enable pytest**
   - File → Settings → Tools → Python Integrated Tools
   - Set "Default test runner" to "pytest"

## Next Steps

1. ✅ Set up virtual environment
2. ✅ Install dependencies
3. ✅ Run tests locally: `pytest tests/ -v`
4. ✅ Check code quality: `flake8 cyber/ tests/`
5. ✅ Build Docker image: `docker build .`
6. ✅ Make your first commit and push

## Additional Resources

- [Python Virtual Environments](https://docs.python.org/3/tutorial/venv.html)
- [Pytest Documentation](https://docs.pytest.org/)
- [Flake8 Documentation](https://flake8.pycqa.org/)
- [Docker Documentation](https://docs.docker.com/)
- [Ansible Documentation](https://docs.ansible.com/)
- [Git Documentation](https://git-scm.com/doc)

## Quick Start Copy-Paste

**macOS/Linux:**
```bash
git clone https://github.com/your-username/ml3.git && cd ml3
python3 -m venv venv && source venv/bin/activate
pip install --upgrade pip && pip install -r cyber/requirements.txt
pytest tests/ -v && flake8 cyber/ tests/
```

**Windows PowerShell:**
```powershell
git clone https://github.com/your-username/ml3.git
cd ml3
python -m venv venv
.\venv\Scripts\Activate.ps1
pip install --upgrade pip
pip install -r cyber/requirements.txt
pytest tests/ -v
flake8 cyber/ tests/
```
