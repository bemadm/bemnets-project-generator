# 🚀 Enum PROJECT SYNTHESIS ENGINE - Deployment Guide

This guide provides comprehensive instructions for deploying the **Enum PROJECT SYNTHESIS ENGINE** (Synthesis UI and Backend Modules) to various platforms.

## 📋 Table of Contents

- [Environment Configuration](#-environment-configuration)
- [Frontend Deployment (Static)](#-frontend-deployment-static)
- [Containerized Deployment (Docker)](#-containerized-deployment-docker)
- [Self-Hosted (Linux/Nginx)](#-self-hosted-linuxnginx)
- [Security Best Practices](#-security-best-practices)
- [Post-Deployment Verification](#-post-deployment-verification)
- [Rollback Plan](#-rollback-plan)

---

## 🔧 Environment Configuration

The engine requires several environment variables for full functionality.

### 1. Create .env file
Copy the placeholder file:
```bash
cp Forge-UI/.env.example Forge-UI/.env
```

### 2. Required Variables
- `VITE_API_URL`: The URL where the PowerShell backend bridge is hosted.
- `VITE_GITHUB_CLIENT_ID`: Your GitHub OAuth App Client ID.
- `VITE_GITHUB_REDIRECT_URI`: The authorized redirect URI for GitHub OAuth.

---

## 🖥️ Frontend Deployment (Static)

The Synthesis UI can be hosted on any static site hosting provider.

### Vercel / Netlify
1. Connect your repository to Vercel/Netlify.
2. Set the **Build Command** to `npm run build`.
3. Set the **Publish Directory** to `dist`.
4. Configure environment variables in the provider's dashboard.
5. The project includes `vercel.json` and `netlify.toml` for automatic routing and security headers.

---

## 🐳 Containerized Deployment (Docker)

Use Docker to package the entire engine, including the PowerShell backend.

### 1. Build the Image
```bash
docker build -t synthesis-engine .
```

### 2. Run with Docker Compose
```bash
docker-compose up -d
```
The UI will be accessible at `http://localhost:5173`.

---

## 🐧 Self-Hosted (Linux/Nginx)

For manual deployment on a Linux server:

### 1. Build the project
```bash
cd Forge-UI
npm install
npm run build
```

### 2. Use the deployment script
```bash
chmod +x deploy.sh
./deploy.sh
```

### 3. Configure Nginx
The `nginx.conf` file is provided in the root directory. It handles:
- Static file serving from `/dist`.
- SPA routing for React.
- Security headers (CSP, X-Frame-Options, etc.).
- API proxying for the backend bridge.

---

## 🔐 Security Best Practices

1. **Secrets Management**: NEVER hardcode secrets in the repository. Use environment variables.
2. **HTTPS**: Always serve the engine over HTTPS. Use [Let's Encrypt](https://letsencrypt.org/) or platform-provided SSL.
3. **HTTP Headers**: The provided configurations (`vercel.json`, `netlify.toml`, `nginx.conf`) include secure headers:
   - **CSP**: Restricts script/style sources.
   - **HSTS**: Enforces HTTPS for a year.
   - **X-Frame-Options**: Prevents clickjacking.
4. **OAuth Security**: Ensure your `GITHUB_CLIENT_SECRET` is only used in server-side logic (not exposed in the browser).

---

## ✅ Post-Deployment Verification

After deploying, run the verification script:
```bash
chmod +x verify.sh
./verify.sh https://your-production-url.com
```

---

## 🔄 Rollback Plan

If a deployment fails or introduces critical bugs:

1. **Docker**: Revert to a previous image tag:
   ```bash
   docker-compose stop
   docker-compose up -d --image synthesis-engine:v2.0.0
   ```
2. **Static Hosting**: Use Vercel/Netlify's "Instant Rollback" to a previous successful deployment.
3. **Manual**: Keep a backup of the previous `dist` folder:
   ```bash
   mv /var/www/synthesis-engine/dist /var/www/synthesis-engine/dist_backup
   cp -r /var/www/synthesis-engine/dist_old /var/www/synthesis-engine/dist
   ```
