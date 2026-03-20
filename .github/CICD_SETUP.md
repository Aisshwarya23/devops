# CI/CD Pipeline Setup Guide

This guide explains how to set up and configure the automated CI/CD pipeline for ForenSecure using GitHub Actions.

## Overview

The CI/CD pipeline consists of three main jobs that run sequentially:

1. **Lint and Test** - Checks code quality and runs automated tests
2. **Build and Push** - Builds Docker image and pushes to GitHub Container Registry
3. **Deploy** - Runs Ansible playbook to deploy the application

## Prerequisites

- GitHub repository with Actions enabled
- Docker installed on deployment target
- Ansible installed on deployment target (for local deployment)
- Python 3.11+

## Setup Steps

### 1. Enable GitHub Actions

1. Go to your repository on GitHub
2. Click **Settings** → **Actions** → **General**
3. Ensure "Allow all actions and reusable workflows" is selected
4. Save

### 2. Configure GitHub Secrets

For Docker image push to work, ensure you have the proper permissions:

1. Go to **Settings** → **Secrets and variables** → **Actions**
2. GitHub automatically provides `GITHUB_TOKEN` for authentication
3. No additional secrets are required for GitHub Container Registry

### 3. Pipeline Configuration

#### Environment Variables

The workflow uses the following environment variables:
- `REGISTRY`: Set to `ghcr.io` (GitHub Container Registry)
- `IMAGE_NAME`: Automatically set to your repository name

#### Container Registry

The pipeline automatically builds and pushes images to:
```
ghcr.io/your-username/ml3:main
ghcr.io/your-username/ml3:main-<commit-sha>
```

### 4. Ansible Deployment Configuration

#### Updated Inventory

The `ansible/inventory.ini` file should point to your deployment target:

```ini
[local]
localhost ansible_connection=local

# For remote deployment:
# [production]
# your-server.com

# [production:vars]
# ansible_user=ubuntu
# ansible_key_file=~/.ssh/id_rsa
```

#### Updated Playbook

The `ansible/playbook.yml` now supports:
- Dynamic Docker image URL from CI/CD
- Port configuration
- Volume mounting for data persistence
- Health checks

#### Run Deployment Locally

To test the Ansible deployment locally:

```bash
ansible-playbook ansible/playbook.yml \
  -i ansible/inventory.ini \
  -e "docker_image=ghcr.io/your-username/ml3:main"
```

## Pipeline Workflow Details

### Lint and Test Job

**Trigger**: Runs on every push to `main` and pull requests

**Steps**:
1. Checks out code
2. Sets up Python 3.11
3. Installs dependencies from `cyber/requirements.txt`
4. Runs flake8 linting (with selected error filters)
5. Runs pytest for all tests

**Failure Criteria**:
- Syntax errors (E9, F63, F7, F82)
- Test failures
- Missing dependencies

### Build and Push Job

**Trigger**: Only runs if lint-and-test job succeeds

**Steps**:
1. Sets up Docker BuildX for multi-platform builds
2. Logs in to GitHub Container Registry
3. Extracts image metadata and version tags
4. Builds and pushes Docker image with caching

**Output**:
- Docker image pushed to `ghcr.io/your-username/ml3`
- Multiple tags: `main`, `main-<sha>`, `semver`

### Deploy Job

**Trigger**: Only runs if build-and-push job succeeds

**Steps**:
1. Checks out code
2. Sets up Python
3. Installs Ansible
4. Runs Ansible playbook with image details
5. Playbook pulls image and starts container

## Writing Tests

Tests should be placed in `tests/` directory and use pytest format:

```python
import pytest
from cyber.app import app

@pytest.fixture
def client():
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

def test_index_route(client):
    response = client.get('/')
    assert response.status_code == 200
```

Run tests locally:
```bash
pytest tests/ -v
```

## Code Quality

### Linting

The pipeline runs flake8 with the following configuration:
- **Stop errors**: E9, F63, F7, F82 (stops on these)
- **Warnings**: All other issues printed but don't stop the build
- **Max complexity**: 10
- **Max line length**: 120

To lint locally:
```bash
flake8 cyber/ tests/ --count --select=E9,F63,F7,F82
```

## Viewing Pipeline Status

1. Go to your repository
2. Click **Actions** tab
3. See all workflow runs with their status
4. Click on a run to see detailed logs
5. Each job logs can be expanded for debugging

## Troubleshooting

### Pipeline Fails at Lint Step

- Check for Python syntax errors
- Run `flake8 cyber/ tests/` locally to see issues
- Fix errors and push again

### Pipeline Fails at Test Step

- Run `pytest tests/ -v` locally
- Check for missing test dependencies
- Update `cyber/requirements.txt` if needed

### Docker Build Fails

- Verify Dockerfile exists in repository root
- Check Docker base image compatibility
- Review Docker build logs in GitHub Actions

### Ansible Deployment Fails

- Verify `ansible/playbook.yml` syntax: `ansible-playbook --syntax-check ansible/playbook.yml`
- Ensure Docker is installed on target
- Check target host connectivity
- Review Ansible logs in GitHub Actions

### Image Push Fails

- Verify `GITHUB_TOKEN` has `write:packages` permission
- Check repository visibility (must be at least internal for Private GitHub)
- Ensure container registry authentication works locally

## Customizing the Pipeline

### Change Python Version

Edit `.github/workflows/deploy.yml`:
```yaml
- name: Set up Python
  uses: actions/setup-python@v4
  with:
    python-version: '3.12'  # Change version here
```

### Change Deployment Target

Edit `.github/workflows/deploy.yml` in the Deploy job:
```yaml
- name: Run Ansible Deployment
  env:
    ANSIBLE_INVENTORY: ansible/production.ini  # Change inventory
  run: |
    ansible-playbook ansible/playbook.yml \
      -i ${{ env.ANSIBLE_INVENTORY }}
```

### Skip Steps

To skip the deploy step for testing:
1. Add `if: false` to the Deploy job
2. Commit and push
3. Remove when ready to deploy

## Best Practices

1. **Always test locally first** before pushing
2. **Keep dependencies minimal** - remove unused packages from `requirements.txt`
3. **Write meaningful tests** - aim for >70% code coverage
4. **Review logs** - always check pipeline logs for warnings
5. **Version your images** - use semantic versioning tags
6. **Secure secrets** - never hardcode credentials in workflows or code

## Security Considerations

- `GITHUB_TOKEN` is automatically provided and scoped to the current repository
- Docker images are pushed to private registry by default (repository visibility dependent)
- Ansible playbook runs with elevated privileges - review commands carefully
- No sensitive data should be committed to the repository

## Next Steps

1. Verify GitHub Actions is enabled
2. Create a test commit to trigger the pipeline
3. Monitor the first run in the Actions tab
4. Debug any issues using the detailed logs
5. Customize deployment variables as needed

For more information:
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Ansible Documentation](https://docs.ansible.com/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
