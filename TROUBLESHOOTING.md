# CI/CD Pipeline - Troubleshooting Guide

This guide helps you diagnose and fix common issues with the GitHub Actions CI/CD pipeline.

## 🚨 Quick Diagnostics

### Pipeline Not Triggering

**Symptom**: Pushed to main but no workflow appears in Actions tab

**Diagnosis checklist**:
- [ ] Is code pushed to **main** branch (not master or other)?
- [ ] Is `.github/workflows/deploy.yml` file in repository?
- [ ] Are GitHub Actions enabled?
- [ ] Is the repository public or do Actions have permissions?

**Fixes**:

```bash
# Verify you're on main branch
git branch
# output: * main (should have * next to main)

# Verify workflow file exists
git show HEAD:.github/workflows/deploy.yml | head -5

# Check recent commits
git log --oneline | head -5

# Force re-push if needed
git push origin main --force-with-lease
```

To enable Actions:
1. Go to https://github.com/YOUR_USERNAME/ml3/settings/actions
2. Select "Allow all actions and reusable workflows"
3. Click Save

---

### ❌ Job 1: Lint and Test Fails

#### **Problem: Tests Failing**

**Symptom**: Red X next to "lint-and-test job", pytest shows failures

**Check**:
```bash
# Run tests locally to see exact error
pytest tests/ -v

# Example output might show:
# FAILED tests/test_app.py::test_index_route - AssertionError: assert 404 == 200
```

**Common causes**:

| Error | Solution |
|-------|----------|
| `ModuleNotFoundError: No module named 'cyber'` | Install dependencies: `pip install -r cyber/requirements.txt` |
| `AssertionError: assert X == Y` | Test expectation wrong; fix test or code |
| `FAILED tests/test_app.py - SyntaxError` | Python syntax error in test file; fix and recommit |
| `ImportError: cannot import name 'app'` | Check `cyber/app.py` exists and is valid |

**Fix template**:
```bash
# 1. Diagnose locally
pytest tests/ -v

# 2. Fix the issue (either in code or test)
# Example: fix syntax error
nano cyber/app.py

# 3. Verify fix works
pytest tests/ -v

# 4. Commit and push
git add .
git commit -m "fix: resolve test failure"
git push origin main
```

#### **Problem: Linting Fails**

**Symptom**: Red X in lint step, flake8 shows errors

**Check**:
```bash
# Run flake8 locally
flake8 cyber/ tests/

# Example output:
# cyber/app.py:15:3: E302 expected 2 blank lines, found 1
```

**Common Flake8 Errors**:

| Code | Issue | Fix |
|------|-------|-----|
| E302 | Missing blank lines | Add blank lines |
| E501 | Line too long | Split line or use `# noqa` |
| F821 | Undefined name | Import missing module |
| E501 | Line too long (>120 chars) | Refactor or extend limit |

**Fix template**:
```bash
# 1. See all linting issues
flake8 cyber/ tests/

# 2. Fix issues (or suppress with # noqa)
# Option A: Fix the code
nano cyber/app.py

# Option B: Suppress if acceptable
code_line  # noqa: E501

# 3. Verify fixes
flake8 cyber/ tests/

# 4. Commit and push
git add .
git commit -m "style: fix flake8 violations"
git push origin main
```

#### **Problem: Missing Dependencies**

**Symptom**: `ModuleNotFoundError` or `ImportError` in logs

**Fix**:
```bash
# 1. Install locally to test
pip install -r cyber/requirements.txt

# 2. Verify dependency works
python -c "import pandas; print(pandas.__version__)"

# 3. If adding new dependency:
pip freeze | grep newmodule >> cyber/requirements.txt
# (or manually add it)

# 4. Commit
git add cyber/requirements.txt
git commit -m "deps: add newmodule"
git push origin main
```

---

## 🐳 Job 2: Build and Push Issues

### **Problem: Docker Build Fails**

**Symptom**: Red X at "Build Docker image" step

**Diagnosis**:
```bash
# Test Docker build locally
docker build .

# Common error messages and causes:
```

| Error Message | Cause | Solution |
|---|---|---|
| `failed to solve with frontend dockerfile.v0` | Dockerfile syntax error | Check Dockerfile at root |
| `COPY failed: file not found` | File path wrong in COPY | Verify file exists; check path |
| `python: command not found` | Base image issue | Ensure base image correct |
| `pip: no such file or directory` | Python not in image | Use correct base image |

**Fix**:
```bash
# 1. Check Dockerfile exists
ls -la Dockerfile

# 2. Validate syntax
docker build --dry-run .  # if supported

# 3. Test locally
docker build -t forensecure:test .

# 4. View full logs
docker build -t forensecure:test . --progress=plain

# 5. If issue found, fix Dockerfile
nano Dockerfile
docker build .

# 6. Commit fix
git add Dockerfile
git commit -m "fix: docker build error"
git push origin main
```

### **Problem: Image Push Fails**

**Symptom**: Build succeeds but push fails with auth error

**Typical error**: `denied: permission_denied`

**Diagnosis checklist**:
- [ ] Is repository public?
- [ ] Does `GITHUB_TOKEN` have write permissions?
- [ ] Is repository name correct in workflow?

**Fix**:
```bash
# 1. Check workflow file
grep "IMAGE_NAME\|REGISTRY" .github/workflows/deploy.yml

# 2. Verify image was built
docker images | grep forensecure

# 3. Test push locally (if authenticated)
docker tag forensecure:latest ghcr.io/YOUR_USERNAME/ml3:test
docker push ghcr.io/YOUR_USERNAME/ml3:test

# 4. Check repository visibility
# Settings → Visibility → Ensure "Public" or "Internal"

# 5. Check permissions (if repeats)
# Settings → Actions → General → Workflow permissions
# Ensure "Read and write permissions" is selected
```

---

## 🚀 Job 3: Deploy Issues

### **Problem: Deployment Fails**

**Symptom**: Docker image pushed successfully but deploy job fails

**Diagnosis**:
```bash
# Check Ansible syntax
ansible-playbook ansible/playbook.yml --syntax-check

# Typical error output:
# ERROR! We were unable to parse /path/to/playbook.yml as an
# inventory source...
```

**Common issues**:

| Issue | Solution |
|-------|----------|
| `playbook.yml not found` | Verify file path is correct |
| YAML indentation error | Fix YAML spacing (2 spaces) |
| Undefined variables | Check `-e` variable passing |
| Connection refused | Check target host is reachable |

**Fix**:
```bash
# 1. Check playbook syntax
ansible-playbook ansible/playbook.yml --syntax-check

# 2. View playbook
cat ansible/playbook.yml

# 3. Test locally
ansible-playbook ansible/playbook.yml -i ansible/inventory.ini -e "docker_image=test:latest"

# 4. If issues found, fix playbook
nano ansible/playbook.yml

# 5. Test again
ansible-playbook ansible/playbook.yml --syntax-check

# 6. Commit fix
git add ansible/playbook.yml
git commit -m "fix: ansible playbook issue"
git push origin main
```

### **Problem: Container Won't Start**

**Symptom**: Deployment completes but container keeps crashing

**Diagnosis**:
```bash
# Check what image is being used
grep docker_image .github/workflows/deploy.yml

# Verify image exists
docker images | grep forensecure

# Manually try running container
docker run -p 8501:8501 ghcr.io/YOUR_USERNAME/ml3:main

# Check container logs
docker logs forensecure-app

# Expected log output (Streamlit):
# Collecting usage statistics...
# (success message appears after 5-10 seconds)
```

**Common container issues**:

| Symptom | Cause | Fix |
|---------|-------|-----|
| Port already in use | Another service on port 8501 | Change port in playbook |
| Permission denied | Container user issues | Check Dockerfile USER |
| Module import error | Missing dependency | Update requirements.txt |
| Config file not found | Wrong mount path | Check volume mounts |

**Fix**:
```bash
# 1. Stop any existing container
docker ps -a | grep forensecure
docker stop forensecure-app
docker rm forensecure-app

# 2. Rebuild locally
docker build -t forensecure:dev .

# 3. Run with debug output
docker run -it -p 8501:8501 \
  --name forensecure-test \
  forensecure:dev

# 4. In another terminal, check logs
docker logs forensecure-test

# 5. If fixed, commit changes
git add .
git commit -m "fix: container startup issue"
git push origin main
```

---

## ⚠️ Workflow File Issues

### **Problem: Workflow File Has Syntax Errors**

**Symptom**: Actions tab shows orange/red but no details

**Verify YAML**:
```bash
# GitHub CI recognizes basic issues, but validator is helpful
# Use online YAML validator: https://www.yamllint.com/

# Or check locally:
python -c "import yaml; yaml.safe_load(open('.github/workflows/deploy.yml'))"

# If error, python will show line number
# Example: yaml.scanner.ScannerError: mapping values are not allowed here
```

**Common YAML errors**:

| Error | Cause | Example | Fix |
|-------|-------|---------|-----|
| Indentation | Spaces/tabs | `run: echo hi` (3 spaces) | Use 2-4 spaces consistently |
| Missing colon | Key format | `steps key` | `steps:` (add colon) |
| Invalid character | Special char | `run: pip install' flask` | Proper quoting/escaping |
| Duplicate key | Same key twice | Two `- name:` entries | Rename one |

**Fix**:
```bash
# 1. Validate locally
python3 << 'EOF'
import yaml
try:
    with open('.github/workflows/deploy.yml', 'r') as f:
        yaml.safe_load(f)
    print("✓ YAML is valid")
except yaml.YAMLError as e:
    print(f"✗ YAML error: {e}")
EOF

# 2. Use online validator
# Go to: https://www.yamllint.com/
# Paste contents of deploy.yml
# Fix reported issues

# 3. Common fix: Check indentation
nano .github/workflows/deploy.yml

# 4. Commit fix
git add .github/workflows/deploy.yml
git commit -m "fix: workflow YAML syntax"
git push origin main
```

---

## 🔍 Debugging Techniques

### Enable Debug Logging in Workflow

Add this step to any job to see environment details:

```yaml
- name: Debug Information
  run: |
    echo "=== Environment ==="
    echo "GitHub Actor: ${{ github.actor }}"
    echo "GitHub Ref: ${{ github.ref }}"
    echo "GitHub SHA: ${{ github.sha }}"
    echo "Runner OS: ${{ runner.os }}"
    
    echo "=== File System ==="
    pwd
    ls -la .github/workflows/
    
    echo "=== Docker ==="
    docker --version
    
    echo "=== Python ==="
    python --version
    
    echo "=== Git ==="
    git log --oneline | head -5
```

### Enable Debug Logging for Runner

Add secrets:
1. Go to Settings → Secrets and variables → Actions
2. Create new secret: `ACTIONS_STEP_DEBUG` with value `true`
3. Re-run workflow

This enables more detailed logging for troubleshooting.

---

## 📋 Verification Checklist

When everything seems broken:

```bash
# 1. Verify basic setup
[ -d .github/workflows ] && echo "✓ Workflows dir exists" || echo "✗ Missing"
[ -f .github/workflows/deploy.yml ] && echo "✓ Workflow file exists" || echo "✗ Missing"
[ -f cyber/requirements.txt ] && echo "✓ Requirements exist" || echo "✗ Missing"
[ -f Dockerfile ] && echo "✓ Dockerfile exists" || echo "✗ Missing"
[ -d tests ] && echo "✓ Tests dir exists" || echo "✗ Missing"

# 2. Test locally
pytest tests/ -v 2>/dev/null && echo "✓ Tests pass" || echo "✗ Tests fail"
flake8 cyber/ 2>/dev/null && echo "✓ Linting OK" || echo "✗ Lint errors"
docker build . >/dev/null 2>&1 && echo "✓ Docker builds" || echo "✗ Build fails"

# 3. Check git
git status | head -3
git log --oneline | head -3

# 4. Commit and push
git add -A
git commit -m "fix: all issues resolved"
git push origin main

# 5. Watch Actions tab
echo "Go to GitHub Actions tab and monitor pipeline..."
```

---

## 🆘 Still Having Issues?

### Check These Documentation Files

1. **For setup help**: [PIPELINE_SETUP.md](PIPELINE_SETUP.md)
2. **For detailed guide**: [.github/CICD_SETUP.md](.github/CICD_SETUP.md)
3. **For local testing**: [LOCAL_SETUP.md](LOCAL_SETUP.md)
4. **For workflow details**: [.github/workflows/README.md](.github/workflows/README.md)
5. **For visual guide**: [PIPELINE_ARCHITECTURE.md](PIPELINE_ARCHITECTURE.md)

### Getting Help

**Step 1**: Gather information
```bash
# Collect error details
# 1. Screenshot of error in Actions tab
# 2. Output of git status
# 3. Output of local test failures
```

**Step 2**: Search known issues
- GitHub Actions troubleshooting: https://docs.github.com/en/actions/troubleshooting
- Flake8 error codes: https://www.flake8rules.com/
- Docker issues: https://docs.docker.com/config/
- Ansible debugging: https://docs.ansible.com/ansible/latest/user_guide/playbook_debugger.html

**Step 3**: Test with minimal example
```bash
# Create simple test to isolate issue
echo 'def test_simple(): assert True' > tests/test_debug.py
pytest tests/test_debug.py -v
```

---

## 📞 Quick Reference Links

| Resource | URL |
|----------|-----|
| GitHub Actions Docs | https://docs.github.com/en/actions |
| Workflow Syntax | https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions |
| Status Badge | https://docs.github.com/en/actions/monitoring-and-troubleshooting-workflows/adding-a-workflow-status-badge |
| Debug Logging | https://docs.github.com/en/actions/monitoring-and-troubleshooting-workflows/enabling-debug-logging |
| Flake8 Rules | https://www.flake8rules.com/ |
| Pytest Docs | https://docs.pytest.org/ |
| Docker Docs | https://docs.docker.com/ |
| Ansible Docs | https://docs.ansible.com/ |

---

**Remember**: Always test locally before pushing to main!

```bash
# The 3-step rule:
1. pytest tests/ -v      # Test locally
2. flake8 cyber/ tests/  # Lint locally
3. git push origin main  # Push with confidence
```
