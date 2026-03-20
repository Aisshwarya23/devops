# GitHub Actions Workflows

This directory contains automated CI/CD pipeline configurations for ForenSecure.

## Files

### `deploy.yml` - Main CI/CD Pipeline

**Triggers:**
- Every push to the `main` branch
- Every pull request to `main`

**Jobs:**

#### 1. `lint-and-test`
- Checks Python code quality with flake8
- Runs automated tests with pytest
- **Status**: Required to pass before build

#### 2. `build-and-push`
- Builds Docker image with caching
- Pushes to GitHub Container Registry (ghcr.io)
- **Dependencies**: Requires `lint-and-test` to succeed
- **Permissions**: Uses automatic `GITHUB_TOKEN`

#### 3. `deploy`
- Pulls Docker image from registry
- Stops and removes old containers
- Starts new container with image
- Performs health check
- **Dependencies**: Requires `build-and-push` to succeed

## Configuration

### Environment Variables

```yaml
REGISTRY: ghcr.io
IMAGE_NAME: ${{ github.repository }}
```

### Permissions

The workflow requires the following GitHub Actions permissions:
- `contents: read` - To checkout repository
- `packages: write` - To push Docker images to Container Registry

These are automatically configured in the workflow file.

## Image Tags

Docker images are pushed with multiple tags:

1. **Branch reference**: `ghcr.io/owner/repo:main`
2. **Commit SHA**: `ghcr.io/owner/repo:main-<commit-sha>`
3. **Semantic version**: `ghcr.io/owner/repo:1.0.0` (if using git tags)

## Prerequisites

### Repository Setup

1. **Branch protection** (optional but recommended):
   - Settings → Branches → Add rule
   - Require status checks to pass before merging
   - Select `lint-and-test` as required check

2. **Enable Actions**:
   - Settings → Actions → General
   - Select "Allow all actions and reusable workflows"

### Local Setup

```bash
# Install Python dependencies
pip install -r cyber/requirements.txt

# Test locally before pushing
pytest tests/ -v
flake8 cyber/ tests/

# Build Docker image locally
docker build -t forensecure:dev .

# Test Ansible deployment
ansible-playbook ansible/playbook.yml -i ansible/inventory.ini
```

## Usage

### Automatic Triggers

The pipeline automatically runs when you push to main:

```bash
git add .
git commit -m "Feature: Add new analysis module"
git push origin main
```

### View Pipeline Status

1. Go to your repository on GitHub
2. Click **Actions** tab
3. See all workflow runs listed
4. Click on a run to see job details
5. Click on a job to see step logs

### Monitoring Builds

Each job produces logs:

- **Lint and Test**: View code quality issues and test results
- **Build and Push**: View Docker build logs and layer caching info
- **Deploy**: View Ansible playbook execution and deployment output

## Customization

### Change Python Version

File: `deploy.yml` (lines 25-27)

```yaml
- name: Set up Python
  uses: actions/setup-python@v4
  with:
    python-version: '3.12'  # Update version
```

### Add More Test Environments

Create `test-matrix.yml` for testing multiple Python versions:

```yaml
name: Test Matrix

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: ['3.9', '3.10', '3.11', '3.12']
    
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v4
        with:
          python-version: ${{ matrix.python-version }}
      # ... rest of jobs
```

### Add Code Coverage Reports

Add to `lint-and-test` job:

```yaml
- name: Generate coverage report
  run: |
    pip install pytest-cov
    pytest tests/ --cov=cyber --cov-report=xml

- name: Upload coverage to Codecov
  uses: codecov/codecov-action@v3
  with:
    files: ./coverage.xml
```

### Skip Specific Steps

Add `if` condition to any step:

```yaml
- name: Deploy
  if: ${{ github.ref == 'refs/heads/main' && github.event_name == 'push' }}
  run: ansible-playbook ansible/playbook.yml
```

## Troubleshooting

### Pipeline Stuck or Not Running

1. Check if Actions are enabled: Settings → Actions
2. Verify workflow file syntax (YAML indentation)
3. Check for branch filters in `on:` section

### Test Failures

1. Check test logs in GitHub Actions
2. Run `pytest tests/ -v` locally
3. Ensure all dependencies in `cyber/requirements.txt`

### Docker Build Failures

1. Verify Dockerfile syntax: `docker build --help`
2. Test locally: `docker build .`
3. Check for missing files in COPY commands

### Authentication Errors

1. For GitHub Container Registry: `GITHUB_TOKEN` is automatic
2. Check repository visibility settings
3. Verify user has Actions permissions

### Deployment Fails

1. Test Ansible playbook locally: `ansible-playbook --syntax-check`
2. Verify inventory.ini points to correct hosts
3. Check Ansible logs for connection errors
4. Ensure target host has Docker installed

## Best Practices

1. **Keep workflows simple** - Complex workflows are hard to debug
2. **Use caching** - Cache dependencies to speed up builds (already implemented)
3. **Test locally first** - Run tests and linting locally before pushing
4. **Review logs regularly** - Check for warnings even if build passes
5. **Secure secrets properly** - Never hardcode credentials
6. **Version your images** - Use semantic versioning for releases

## Security

- `GITHUB_TOKEN` has minimal necessary permissions
- Token is scoped to current repository only
- Container images not leaked to public unless repository is public
- Ansible playbook executes with least privilege where possible

## Related Files

- `.github/CICD_SETUP.md` - Detailed setup and configuration guide
- `cyber/requirements.txt` - Python dependencies
- `Dockerfile` - Container image definition
- `ansible/playbook.yml` - Deployment automation
- `ansible/inventory.ini` - Target hosts configuration
- `tests/` - Automated test suite

## Support

For GitHub Actions documentation: https://docs.github.com/en/actions

For workflow syntax: https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions
