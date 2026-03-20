# GitHub Actions Secrets Configuration

This guide explains how to configure GitHub Secrets if you want to use alternative container registries or additional deployment options.

## Quick Start (Default - GitHub Container Registry)

**No secrets required!** The pipeline uses `GITHUB_TOKEN` which is automatically provided.

Simply:
1. Push to `main` branch
2. Go to Actions tab to see pipeline run
3. Images automatically push to `ghcr.io/your-username/ml3`

## Alternative: Docker Hub

If you prefer Docker Hub instead of GitHub Container Registry:

### 1. Get Docker Hub Credentials

- Create Docker Hub account: https://hub.docker.com/
- Go to Account Settings → Security
- Create a Personal Access Token (recommended over password)
- Copy the token

### 2. Add GitHub Secrets

1. Go to GitHub repository
2. Settings → Secrets and variables → Actions
3. Click "New repository secret"
4. Add two secrets:
   - **Name**: `DOCKER_USERNAME` | **Value**: Your Docker Hub username
   - **Name**: `DOCKER_PASSWORD` | **Value**: Your Docker Hub PAT

### 3. Update Workflow

Edit `.github/workflows/deploy.yml`:

```yaml
build-and-push:
  needs: lint-and-test
  runs-on: ubuntu-latest

  steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v2

    - name: Log in to Docker Hub
      uses: docker/login-action@v2
      with:
        username: ${{ secrets.DOCKER_USERNAME }}
        password: ${{ secrets.DOCKER_PASSWORD }}

    # Continue with build/push using docker.io registry
```

## Alternative: Azure Container Registry

### 1. Create ACR Instance

```bash
az acr create --resource-group myGroup --name myRegistry --sku Basic
```

### 2. Get Credentials

```bash
az acr credential show --name myRegistry
```

### 3. Add GitHub Secrets

1. Go to GitHub repository
2. Settings → Secrets and variables → Actions
3. Add three secrets:
   - **Name**: `REGISTRY_LOGIN_SERVER` | **Value**: `myregistry.azurecr.io`
   - **Name**: `REGISTRY_USERNAME` | **Value**: From credential output
   - **Name**: `REGISTRY_PASSWORD` | **Value**: From credential output

### 4. Update Workflow

```yaml
- name: Log in to ACR
  uses: docker/login-action@v2
  with:
    registry: ${{ secrets.REGISTRY_LOGIN_SERVER }}
    username: ${{ secrets.REGISTRY_USERNAME }}
    password: ${{ secrets.REGISTRY_PASSWORD }}
```

## SSH Keys for Ansible Deployment

If deploying to remote servers, add SSH key:

### 1. Generate SSH Key

```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/github-deploy
```

### 2. Add Public Key to Servers

```bash
# For each target server:
ssh-copy-id -i ~/.ssh/github-deploy.pub user@server.com
```

### 3. Add Private Key to GitHub

1. Go to GitHub repository
2. Settings → Secrets and variables → Actions
3. Click "New repository secret"
4. **Name**: `SSH_DEPLOY_KEY`
5. **Value**: Contents of `~/.ssh/github-deploy` (PRIVATE key)

### 4. Update Workflow

```yaml
deploy:
  needs: build-and-push
  runs-on: ubuntu-latest

  steps:
    # ... previous steps ...
    
    - name: Setup SSH
      run: |
        mkdir -p ~/.ssh
        echo "${{ secrets.SSH_DEPLOY_KEY }}" > ~/.ssh/id_rsa
        chmod 600 ~/.ssh/id_rsa
        ssh-keyscan -H your-server.com >> ~/.ssh/known_hosts

    - name: Run Ansible
      run: |
        ansible-playbook ansible/playbook.yml \
          -i ansible/production.ini \
          -u deploy_user \
          -e "docker_image=${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:main"
```

## Slack Notifications

Add Slack notifications when pipeline completes:

### 1. Create Slack Webhook

1. Go to https://api.slack.com/apps
2. Create New App
3. Enable Incoming Webhooks
4. Create New Webhook URL
5. Copy the webhook URL

### 2. Add to GitHub Secrets

**Name**: `SLACK_WEBHOOK` | **Value**: Your webhook URL

### 3. Add Notification Step

```yaml
- name: Notify Slack
  if: always()  # Run even if previous steps fail
  run: |
    curl -X POST ${{ secrets.SLACK_WEBHOOK }} \
      -H 'Content-Type: application/json' \
      -d "{\"text\":\"Pipeline ${{ job.status }}: ${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }}\"}"
```

## Email Notifications

GitHub Actions can send email notifications automatically:

1. Go to repository Settings
2. Email notifications settings
3. Choose when to be notified:
   - Workflow run failures
   - Workflow run completions
   - etc.

## Managing Secrets Safely

### ✅ DO:
- Use personal access tokens (not passwords)
- Rotate credentials regularly
- Use environment-specific secrets
- Document sensitivity levels
- Review who has access to secrets

### ❌ DON'T:
- Test secrets locally with credentials in code
- Store secrets in version control
- Share secret values in chat/emails
- Use overly permissive credentials
- Log secret values in output

## Viewing Secrets

```bash
# Only repository admins can view secrets
# Settings → Secrets → Cannot view values (security feature)

# But you can see which secrets are configured:
gh secret list  # Using GitHub CLI
```

## Revoking Secrets

If a secret is compromised:

1. **Immediately revoke** the credential (password, token, key, etc.)
2. **Delete from GitHub** (Settings → Secrets → Delete)
3. **Create new credential**
4. **Update GitHub Secret**
5. **Review access logs** if available

## Secrets Best Practices

1. **Use fine-grained tokens** - GitHub tokens with minimal permissions
2. **Set expiration dates** - Where supported
3. **Rotate regularly** - At least quarterly
4. **Use separate credentials** - For each environment (dev, staging, prod)
5. **Audit access** - Review who can access secrets
6. **Document dependencies** - Which secrets each workflow needs

## Troubleshooting

### Secret Not Found

```yaml
# Make sure you reference the exact name
${{ secrets.SECRET_NAME }}  # ✅ Correct
${{ secrets.secret_name }}  # ❌ Secrets are case-sensitive
${{ SECRET_NAME }}          # ❌ Wrong syntax
```

### Authentication Failed

1. Verify secret value is current (not revoked)
2. Check credential formatting (no extra spaces/newlines)
3. Ensure permissions are correct for the credential
4. Try creating a new credential if old one expires

### Secrets Not Available in Fork

Forks don't have access to repository secrets by default:
- Manually add same secrets to forked repository, OR
- Use branch protection to require approval for secrets

## Default Environment Variables

These are provided automatically (no secrets needed):

```
GITHUB_ACTION        # Action name
GITHUB_ACTOR         # User who triggered action
GITHUB_EVENT_NAME    # Event type (push, pull_request, etc)
GITHUB_REF           # Git reference
GITHUB_REPOSITORY    # Repository name
GITHUB_SHA           # Commit SHA
GITHUB_TOKEN         # Authentication token
GITHUB_WORKSPACE     # Workflow workspace path
```

## Security Audit

Periodically review:

1. Settings → Secrets for stale/unused entries
2. Settings → Collaborators for unexpected access
3. Settings → Branches → Protection rules
4. Security → Secret scanning alerts

## Next Steps

1. ✅ Determine which registry you'll use (default: ghcr.io)
2. ✅ Add required secrets if using Docker Hub or custom registry
3. ✅ Test with a test push
4. ✅ Verify images appear in your registry
5. ✅ Monitor first few deployments

## Additional Resources

- [GitHub Secrets Documentation](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [GitHub Security Best Practices](https://docs.github.com/en/actions/security-guides)
- [Docker Hub Tokens](https://docs.docker.com/docker-hub/access-tokens/)
- [Azure Container Registry Auth](https://docs.microsoft.com/en-us/azure/container-registry/container-registry-auth-github-actions)
