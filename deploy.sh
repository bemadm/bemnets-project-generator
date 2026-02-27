#!/bin/bash

# Deployment Script for Enum PROJECT SYNTHESIS ENGINE
# Target: Linux Server with Nginx

set -e

echo "🚀 Starting Deployment..."

# 1. Build Frontend
echo "📦 Building Frontend..."
cd Forge-UI
npm install
npm run build
cd ..

# 2. Prepare Destination
echo "📁 Preparing Destination..."
DEST_DIR="/var/www/synthesis-engine"
sudo mkdir -p $DEST_DIR
sudo cp -r Forge-UI/dist/* $DEST_DIR/

# 3. Configure Nginx
echo "⚙️ Configuring Nginx..."
sudo cp nginx.conf /etc/nginx/sites-available/synthesis-engine
sudo ln -sf /etc/nginx/sites-available/synthesis-engine /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx

# 4. Set Permissions
echo "🔐 Setting Permissions..."
sudo chown -R www-data:www-data $DEST_DIR
sudo chmod -R 755 $DEST_DIR

echo "✅ Deployment Successful!"
