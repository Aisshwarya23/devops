# CI/CD Pipeline Architecture & Visual Guide

## 📊 Complete Pipeline Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        GIT REPOSITORY                            │
│                                                                   │
│  ┌──────────────────────────────────────────────────────────────┤│
│  │  File Changes:                                                ││
│  │  - cyber/app.py                                               ││
│  │  - cyber/modules/                                             ││
│  │  - tests/test_app.py                                          ││
│  │  - etc.                                                       ││
│  └──────────────────────────────────────────────────────────────┤│
│                          ⬇️                                        │
│                   git push origin main                            │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
                            ⬇️
┌─────────────────────────────────────────────────────────────────┐
│              GITHUB ACTIONS WORKFLOW TRIGGERED                   │
│                                                                   │
│              🟡 Pipeline Status: Running                         │
│                                                                   │
│ ┌────────────────────────────────────────────────────────────┐ │
│ │ JOB 1: LINT AND TEST (Required - Must Pass)                │ │
│ ├────────────────────────────────────────────────────────────┤ │
│ │                                                              │ │
│ │ ✓ Checkout Code                                              │ │
│ │ ✓ Setup Python 3.11                                          │ │
│ │ ✓ Install Dependencies (with caching)                        │ │
│ │ ✓ Run Flake8 Linting                                         │ │
│ │ ✓ Run Pytest Tests                                           │ │
│ │                                                              │ │
│ │ ⏱️  Duration: ~30-60 seconds                                 │ │
│ │ 🟢 Status: PASS (if no errors)                              │ │
│ │                                                              │ │
│ └────────────────────────────────────────────────────────────┘ │
│                            ⬇️                                    │
│ ┌────────────────────────────────────────────────────────────┐ │
│ │ JOB 2: BUILD AND PUSH (Depends on Job 1)                   │ │
│ ├────────────────────────────────────────────────────────────┤ │
│ │                                                              │ │
│ │ ✓ Setup Docker BuildX                                        │ │
│ │ ✓ Login to ghcr.io (GitHub Container Registry)               │ │
│ │ ✓ Build Docker Image (with layer caching)                    │ │
│ │   └─ Base: python:3.11-slim                                  │ │
│ │   └─ Layers: dependencies, app code, user setup              │ │
│ │ ✓ Tag Image with multiple tags:                              │ │
│ │   └─ ghcr.io/username/ml3:main (latest)                      │ │
│ │   └─ ghcr.io/username/ml3:main-sha123... (commit)            │ │
│ │ ✓ Push to Registry                                            │ │
│ │                                                              │ │
│ │ ⏱️  Duration: ~2-5 minutes (first build) or 30s (cached)     │ │
│ │ 🟢 Status: PASS (if build succeeds)                          │ │
│ │                                                              │ │
│ └────────────────────────────────────────────────────────────┘ │
│                            ⬇️                                    │
│ ┌────────────────────────────────────────────────────────────┐ │
│ │ JOB 3: DEPLOY (Depends on Job 2)                           │ │
│ ├────────────────────────────────────────────────────────────┤ │
│ │                                                              │ │
│ │ ✓ Install Ansible                                             │ │
│ │ ✓ Pull Docker Image from ghcr.io                              │ │
│ │ ✓ Stop Old Container (if running)                             │ │
│ │ ✓ Remove Old Container                                        │ │
│ │ ✓ Start New Container                                         │ │
│ │   └─ Port: 8501                                               │ │
│ │   └─ Volume: /tmp/forensecure-data                            │ │
│ │ ✓ Verify Health                                               │ │
│ │                                                              │ │
│ │ ⏱️  Duration: ~1-2 minutes                                    │ │
│ │ 🟢 Status: PASS (if deployment succeeds)                     │ │
│ │                                                              │ │
│ └────────────────────────────────────────────────────────────┘ │
│                                                                   │
│ 🟢 PIPELINE COMPLETE: All jobs passed!                           │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
                            ⬇️
┌─────────────────────────────────────────────────────────────────┐
│         ARTIFACTS & OUTPUTS CREATED                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│ 🐳 Docker Artifacts:                                              │
│    └─ Image: ghcr.io/username/ml3:main                           │
│    └─ Registry: GitHub Container Registry                        │
│    └─ Size: ~300-400 MB                                          │
│                                                                   │
│ 🖥️  Deployed Container:                                           │
│    └─ Status: Running                                            │
│    └─ Port: 8501                                                 │
│    └─ Address: http://localhost:8501                             │
│                                                                   │
│ 📊 Logs & Reports:                                                │
│    └─ GitHub Actions: Full execution logs                        │
│    └─ Test Results: pytest output                                │
│    └─ Linting: flake8 warnings/errors                            │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
```

## 🔀 Failure Flow

```
Scenario: Tests fail (syntax errors detected)

    git push origin main
            ⬇️
    [Job 1: Lint and Test]
    ✓ Syntax check: OK
    ✓ Dependencies: OK
    ❌ Pytest: FAILED
          │
          └─ Error: Test assertion failed
             Example: assert response.status_code == 200
                      but got 500
          │
          └─ Pipeline STOPS
    ❌ Job 2: BUILD AND PUSH - SKIPPED
    ❌ Job 3: DEPLOY - SKIPPED

    ⚠️  Developer gets GitHub notification
    ⚠️  Actions tab shows red X
    
    Developer action: Fix code → Commit → Push
```

## 📁 Repository Structure

```
ml3/
├── .github/
│   ├── workflows/
│   │   ├── deploy.yml ................. Main CI/CD Pipeline
│   │   └── README.md .................. Workflow documentation
│   ├── CICD_SETUP.md .................. Detailed setup guide
│   ├── SECRETS_SETUP.md ............... Secrets configuration
│   └── codespaces/
│       └── devcontainer.json ......... (optional)
│
├── cyber/
│   ├── app.py ......................... Flask application
│   ├── config.py ...................... Configuration
│   ├── dashboard.py ................... Streamlit dashboard
│   ├── login.py ....................... Login logic
│   ├── train_model.py ................. ML training
│   ├── requirements.txt ............... Python dependencies
│   ├── modules/ ....................... Analysis modules
│   ├── models/ ........................ ML models
│   ├── utils/ ......................... Utilities
│   ├── static/ ........................ Web assets
│   ├── templates/ ..................... HTML templates
│   └── data/ .......................... Sample data
│
├── tests/
│   ├── test_app.py .................... Application tests
│   └── __init__.py
│
├── ansible/
│   ├── playbook.yml ................... Deployment playbook
│   └── inventory.ini .................. Target hosts
│
├── Dockerfile ......................... Container image definition
├── docker-compose.yml ................. Docker Compose config
├── prometheus.yml ..................... Prometheus config
│
├── PIPELINE_SETUP.md .................. Pipeline overview
├── PIPELINE_CHECKLIST.md .............. Setup verification
├── LOCAL_SETUP.md ..................... Local environment setup
├── cicd-quickref.sh ................... Quick reference (Linux/Mac)
├── cicd-quickref.bat .................. Quick reference (Windows)
│
└── README.md .......................... Main documentation
```

## 🔄 Event Flow Diagram

```
EVENT: git push origin main
│
├─ Trigger: Push to main branch
│
└─ WORKFLOW: CI-CD Pipeline Starts
   │
   ├─ JOB 1: lint-and-test
   │  ├─ runs-on: ubuntu-latest
   │  └─ steps:
   │     ├─ Checkout code
   │     ├─ Setup Python 3.11
   │     ├─ Cache dependencies
   │     ├─ Install requirements
   │     ├─ Lint (flake8)
   │     └─ Test (pytest)
   │
   ├─ (Wait for Job 1 to complete)
   │
   ├─ JOB 2: build-and-push (if Job 1 passed)
   │  ├─ runs-on: ubuntu-latest
   │  └─ steps:
   │     ├─ Checkout code
   │     ├─ Setup Docker Buildx
   │     ├─ Login to ghcr.io
   │     ├─ Extract image metadata
   │     └─ Build and push Docker image
   │
   ├─ (Wait for Job 2 to complete)
   │
   └─ JOB 3: deploy (if Job 2 passed)
      ├─ runs-on: ubuntu-latest
      └─ steps:
         ├─ Checkout code
         ├─ Setup Python
         ├─ Install Ansible
         └─ Run Ansible playbook
            ├─ Pull image
            ├─ Stop old container
            ├─ Start new container
            └─ Verify health
```

## 🎯 Status Indicators

```
In GitHub Actions Tab:

Job Status Indicators:
  🟢 Green   = Success (no issues)
  🟡 Yellow  = In Progress (running)
  🔴 Red     = Failed (error occurred)
  ⚪ Gray    = Skipped (condition not met)
  ⊘ White   = Neutral (not started)

Step Status:
  ✓ Check mark  = Step completed
  ⊘ Circle      = Step not run
  ✕ Cross       = Step failed
  ⏳ Hour glass  = Step in progress

Overall Pipeline Status:
  ✅ All Pass   = Ready to use (success)
  ⚠️  Warnings  = Passed but check logs
  ❌ Failed    = Fix required before use
```

## 📈 Timing Breakdown

```
Typical Pipeline Execution Time:

First Build (full from scratch):
├─ Job 1 (Lint & Test): ⏱️ 45 seconds
│  ├─ Setup: 10s
│  ├─ Install deps: 20s
│  ├─ Lint: 5s
│  └─ Test: 10s
│
├─ Job 2 (Build & Push): ⏱️ 4 minutes
│  ├─ Setup Docker: 30s
│  ├─ Build image: 2m 30s
│  └─ Push: 60s
│
└─ Job 3 (Deploy): ⏱️ 1 minute 30s
   ├─ Setup Ansible: 20s
   ├─ Pull image: 30s
   ├─ Restart container: 30s
   └─ Health check: 10s
   
TOTAL FIRST BUILD: ~6 minutes 15 seconds

Subsequent Builds (with caching):
├─ Job 1 (Lint & Test): ⏱️ 20 seconds (deps cached)
├─ Job 2 (Build & Push): ⏱️ 1 minute (layers cached)
└─ Job 3 (Deploy): ⏱️ 1 minute 30s
   
TOTAL CACHED BUILD: ~2 minutes 50 seconds
```

## 🔐 Security Architecture

```
┌─────────────────────────────────────────────────────────┐
│  GitHub Repository (Private or Public)                   │
│                                                           │
│  ┌───────────────────────────────────────────────────┐  │
│  │ Source Code                                        │  │
│  │ - No credentials hardcoded ✓                       │  │
│  │ - Secrets in GitHub Secrets only ✓                │  │
│  └───────────────────────────────────────────────────┘  │
│                          ⬇️                              │
│  ┌───────────────────────────────────────────────────┐  │
│  │ GitHub Actions (Runs on GitHub servers)           │  │
│  │ - GITHUB_TOKEN scoped to repo ✓                   │  │
│  │ - Minimal permissions required ✓                  │  │
│  └───────────────────────────────────────────────────┘  │
│                          ⬇️                              │
│  ┌───────────────────────────────────────────────────┐  │
│  │ GitHub Container Registry (ghcr.io)               │  │
│  │ - Private registry (by default) ✓                 │  │
│  │ - Authentication via GITHUB_TOKEN ✓               │  │
│  │ - No credentials exposed in logs ✓                │  │
│  └───────────────────────────────────────────────────┘  │
│                          ⬇️                              │
│  ┌───────────────────────────────────────────────────┐  │
│  │ Deployment Target (Local/Docker)                  │  │
│  │ - Container runs as non-root user ✓               │  │
│  │ - Volume mounts for data isolation ✓              │  │
│  │ - Health checks enabled ✓                         │  │
│  └───────────────────────────────────────────────────┘  │
│                                                           │
└─────────────────────────────────────────────────────────┘
```

## 📊 Data Flow

```
Code Changes
    │
    ⬇️
Repository
    │
    ├─ File: cyber/app.py ────────┐
    ├─ File: tests/test_app.py ───┼─ Git Push
    ├─ File: Dockerfile ──────────┤
    └─ File: ansible/playbook.yml─┘
    │
    ⬇️
GitHub Webhook
    │
    ⬇️
GitHub Actions Workflow Triggered
    │
    ├─ Lint & Test Job
    │  └─ Input: Source Code
    │  └─ Output: Test Report, Linting Report
    │
    ├─ Build & Push Job
    │  ├─ Input: Linting Report (pass/fail)
    │  ├─ Input: Source Code
    │  └─ Output: Docker Image URI
    │
    └─ Deploy Job
       ├─ Input: Docker Image URI
       ├─ Input: Ansible Playbook
       └─ Output: Running Container
```

## 🛠️ Configuration Points

```
Customizable Elements:

┌─ Python Version
│  └─ .github/workflows/deploy.yml (line 27)
│     Change: python-version: '3.12'
│
├─ Linting Rules
│  └─ .github/workflows/deploy.yml (flake8 section)
│     Add: --max-line-length=140
│
├─ Test Framework
│  └─ .github/workflows/deploy.yml (pytest section)
│     Change: pytest tests/ -v --cov
│
├─ Docker Image Base
│  └─ Dockerfile (line 1)
│     Change: FROM python:3.12-slim
│
├─ Container Port
│  └─ ansible/playbook.yml (line 9)
│     Change: app_port: 9000
│
└─ Registry
   └─ .github/workflows/deploy.yml (line 11)
      Change: REGISTRY: docker.io
```

## 🎓 Key Concepts

**Workflow**: An automated process that runs on GitHub
**Job**: A set of steps that run on the same runner
**Step**: An individual task within a job
**Runner**: A GitHub-hosted or self-hosted server that executes jobs
**Artifact**: Files or data produced by workflow runs
**Matrix**: Running jobs with different configurations (versions, OSes)

## 📞 Where to Find Information

```
For Question About:              Look In:
─────────────────────────────────────────────────────
General Setup                    PIPELINE_SETUP.md
Workflow Details                 .github/workflows/README.md
Local Development                LOCAL_SETUP.md
Secrets Configuration            .github/SECRETS_SETUP.md
Quick Commands                   cicd-quickref.sh/.bat
Verification Checklist           PIPELINE_CHECKLIST.md
GitHub Actions Syntax            https://docs.github.com/en/actions
Docker Documentation             https://docs.docker.com/
Ansible Documentation            https://docs.ansible.com/
```

---

**Visual Guide Complete** ✅

Use this guide to understand the overall architecture and flow of your CI/CD pipeline.
