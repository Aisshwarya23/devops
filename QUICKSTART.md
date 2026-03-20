# 🚀 Quick Start: Run Your First Pipeline

This guide gets your CI/CD pipeline running in **less than 10 minutes**.

## ⚡ The 5-Minute Path

### Step 1: Commit Everything (2 min)

```bash
# Go to your project directory
cd /path/to/ml3

# Stage all new files
git add .

# See what's being committed
git status

# Commit
git commit -m "ci: add complete GitHub Actions CI/CD pipeline"
```

### Step 2: Push to GitHub (1 min)

```bash
# Push to main branch
git push origin main

# Expected output:
# To github.com:USERNAME/ml3.git
#    main -> main
```

### Step 3: Watch It Run (2 min)

1. Go to: https://github.com/YOUR_USERNAME/ml3/actions
2. You should see a workflow running
3. Click on it to see details
4. Watch the 3 jobs execute:
   - 🟡 Lint and Test (running)
   - ⏳ Build and Push (waiting)
   - ⏳ Deploy (waiting)

### Expected Results

✅ All jobs should pass with green ✓ checkmarks

🔴 If any job fails, see [TROUBLESHOOTING.md](TROUBLESHOOTING.md)

---

## 🏃 Running Your First Pipeline

### Pre-Requisites Check

```bash
# Verify everything is ready
echo "Checking prerequisites..."

# 1. Check git
git --version          # Should show version 2.x or higher
git status              # Should show "On branch main"

# 2. Check repository
ls .github/workflows/deploy.yml && echo "✓ Workflow file found" || echo "✗ Missing"
ls Dockerfile && echo "✓ Dockerfile found" || echo "✗ Missing"
ls cyber/requirements.txt && echo "✓ Requirements found" || echo "✗ Missing"

# 3. Check test file
ls tests/test_app.py && echo "✓ Tests found" || echo "✗ Missing"
```

All checks should show ✓

### Execute the First Run

```bash
# 1. Create a test commit to trigger pipeline
echo "" >> README.md
git add README.md
git commit -m "chore: trigger CI/CD pipeline"

# 2. Push it
git push origin main

# 3. Monitor (copy URL from terminal or click link)
# Open in browser: https://github.com/YOUR_USERNAME/ml3/actions
```

### Watch the Dashboard

```
GitHub Actions Dashboard
├─ Workflow: CI-CD Pipeline
│  └─ Run: chore: trigger CI/CD pipeline (#1)
│     └─ Commit: abc123def
│        ├─ 🟡 lint-and-test (In Progress)
│        │  ├─ ✓ Checkout code
│        │  ├─ ✓ Set up Python
│        │  ├─ ⏳ Install dependencies
│        │  └─ ...
│        │
│        ├─ ⏳ build-and-push (Waiting)
│        └─ ⏳ deploy (Waiting)
```

After ~60 seconds:
```
├─ ✓ lint-and-test (Passed - 45s)
├─ 🟡 build-and-push (In Progress)
└─ ⏳ deploy (Waiting)
```

After ~5 minutes total:
```
├─ ✓ lint-and-test (Passed)
├─ ✓ build-and-push (Passed)
└─ ✓ deploy (Passed)
```

## ✅ Success Indicators

You'll know it worked when:

1. ✅ **No red X** in Actions tab
2. ✅ **All jobs show green** with ✓ checkmarks
3. ✅ **Duration is reasonable**:
   - Job 1: ~30-60 seconds
   - Job 2: ~2-5 minutes
   - Job 3: ~1-2 minutes
   - Total: ~5-10 minutes first run
4. ✅ **Docker image created** (check GitHub Packages)
5. ✅ **Container is running** (if deployment target available)

## 🐛 If Something Fails

### Red X in Pipeline?

**Quick fix**:
1. Click on failed job to see logs
2. Look for error message
3. Search [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for that error
4. Apply fix
5. Commit and push again

### Common First-Run Failures

| Failure | Usual Cause | Solution |
|---------|------------|----------|
| Tests fail | Syntax error in Python | Fix error locally: `pytest tests/ -v` |
| Linting fails | Code style issue | Run: `flake8 cyber/` to see issues |
| Docker fails | Dockerfile issue | Test locally: `docker build .` |
| Deployment fails | Ansible issue | Check: `ansible-playbook --syntax-check` |

---

## 📊 Understanding the Pipeline Flow

```
Your Changes
    ↓
git push origin main
    ↓
GitHub Actions Triggered
    ↓
Job 1: Lint & Test
├─ Install dependencies
├─ Check code quality (flake8)
├─ Run tests (pytest)
└─ ✓ Pass? Continue to Job 2
    ↓
Job 2: Build & Push
├─ Build Docker image
├─ Push to ghcr.io
└─ ✓ Success? Continue to Job 3
    ↓
Job 3: Deploy
├─ Install Ansible
├─ Pull Docker image
├─ Start container
└─ ✓ Done!
    ↓
🎉 Application is Live
```

---

## 📈 Monitor Your Build

### In GitHub Web Interface

```
Path: GitHub.com → Your Repo → Actions Tab

What you'll see:
├─ Workflow name: CI-CD Pipeline
├─ Trigger: "chore: trigger CI/CD pipeline"  (your message)
├─ Branch: main
├─ Status: [🟢 Passed] or [🔴 Failed]
└─ Duration: 5m 23s

Click to see details:
├─ Job 1: lint-and-test (✓ Passed 45s)
├─ Job 2: build-and-push (✓ Passed 3m 15s)
└─ Job 3: deploy (✓ Passed 1m 23s)
```

### Using GitHub CLI (Optional)

```bash
# List all workflow runs
gh run list --repo USERNAME/ml3

# View specific run
gh run view <run-id> --repo USERNAME/ml3

# Watch live output
gh run watch <run-id> --repo USERNAME/ml3
```

---

## 🔧 Customizing Your First Run (Optional)

### Change Python Version
Edit `.github/workflows/deploy.yml`, line 27:
```yaml
python-version: '3.12'  # Change from 3.11 to 3.12
```

### Change Container Port
Edit `ansible/playbook.yml`, line 9:
```yaml
app_port: "9000"  # Change from 8501 to 9000
```

### Change Docker Registry
Edit `.github/workflows/deploy.yml`, line 11:
```yaml
REGISTRY: docker.io  # Change from ghcr.io to docker.io
```

After any changes:
```bash
git add .
git commit -m "ci: customize pipeline"
git push origin main
```

---

## 🎯 What Happens After First Success

### Automatic from Now On

Every time you push to `main`:
1. Tests automatically run
2. Docker image automatically builds
3. Application automatically deploys
4. **You get notified** if anything fails

### For Pull Requests

When you create a PR to `main`:
1. Tests automatically run
2. **PR is blocked** if tests fail
3. Tests must pass before merge
4. Build/deploy only happens on main

---

## 📱 Getting Notifications

### GitHub Notifications (Automatic)

1. Go to Settings → Notifications
2. Choose when to notify:
   - Workflow failures
   - Workflow completions
   - etc.

### Email Notifications

Check your email inbox for:
- Workflow failure alerts
- Workflow completion summaries

### Optional: Slack Integration

Setup Slack notifications (see [.github/SECRETS_SETUP.md](.github/SECRETS_SETUP.md)):
```bash
# You'll get Slack messages for build failures
"Pipeline failed: Test failed at 3:45 PM"
```

---

## 🚨 Emergency: Stop Everything!

If you need to halt the pipeline while it's running:

```bash
# Go to https://github.com/YOUR_USERNAME/ml3/actions
# Click the workflow run
# Click "Cancel workflow run" button
```

This stops immediately without deploying.

---

## 📚 After Your First Success

### Now You Can:

1. ✅ **Make code changes** freely (pipeline validates each push)
2. ✅ **Create pull requests** (tests run automatically)
3. ✅ **Deploy safely** (multiple stages catch errors)
4. ✅ **Track deployments** (full history in Actions tab)

### Next Learning Steps:

1. **Customize the pipeline** → [.github/workflows/README.md](.github/workflows/README.md)
2. **Add more tests** → [LOCAL_SETUP.md](LOCAL_SETUP.md)
3. **Set up notifications** → [.github/SECRETS_SETUP.md](.github/SECRETS_SETUP.md)
4. **Understand architecture** → [PIPELINE_ARCHITECTURE.md](PIPELINE_ARCHITECTURE.md)

---

## ✨ Congratulations!

Your CI/CD pipeline is now:
- ✅ **Automated** - Runs on every push
- ✅ **Tested** - Catches errors early
- ✅ **Containerized** - Uses Docker
- ✅ **Deployed** - With Ansible
- ✅ **Monitored** - Full visibility in GitHub

**You're doing DevOps! 🎉**

---

## 🆘 Quick Troubleshooting

| Issue | Fix |
|-------|-----|
| Can't find Actions tab | Ensure GitHub Actions are enabled (Settings → Actions) |
| Workflow doesn't start | Verify commit was pushed to **main** (not other branches) |
| All jobs fail immediately | Check `.github/workflows/deploy.yml` YAML syntax |
| Tests pass locally but fail in pipeline | Different Python version? Check python-version in workflow |
| Docker not pushing | Verify `GITHUB_TOKEN` has write permissions |

For detailed troubleshooting: [TROUBLESHOOTING.md](TROUBLESHOOTING.md)

---

## 📞 Need Help?

- **General questions** → Read [PIPELINE_SETUP.md](PIPELINE_SETUP.md)
- **Detailed setup** → Read [.github/CICD_SETUP.md](.github/CICD_SETUP.md)
- **Something broken** → Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
- **Visual guide** → See [PIPELINE_ARCHITECTURE.md](PIPELINE_ARCHITECTURE.md)
- **Local environment** → Follow [LOCAL_SETUP.md](LOCAL_SETUP.md)

---

## 🎬 You're Ready!

```bash
# This is all you need:
git add .
git commit -m "ci: add CI/CD pipeline"
git push origin main

# Then watch: https://github.com/YOUR_USERNAME/ml3/actions
```

**Go! 🚀**
