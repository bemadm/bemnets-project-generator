#!/bin/bash

# Post-Deployment Verification Script
# Target: Production URL

if [ -z "$1" ]; then
    echo "Usage: ./verify.sh <production_url>"
    exit 1
fi

URL=$1

echo "🔍 Verifying Deployment at $URL..."

# 1. Check if Frontend is accessible
echo "🌐 Checking Frontend..."
STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$URL")
if [ "$STATUS" -eq 200 ]; then
    echo "✅ Frontend is UP (Status: $STATUS)"
else
    echo "❌ Frontend is DOWN (Status: $STATUS)"
    exit 1
fi

# 2. Check for Synthesis UI title
echo "🏷️ Checking Synthesis UI title..."
if curl -s "$URL" | grep -q "Enum PROJECT SYNTHESIS ENGINE"; then
    echo "✅ Synthesis UI title detected"
else
    echo "❌ Synthesis UI title NOT detected"
    exit 1
fi

# 3. Check for API Endpoint (if configured)
echo "🔌 Checking API Endpoint..."
API_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$URL/api/health" || echo "404")
if [ "$API_STATUS" -eq 200 ]; then
    echo "✅ API Endpoint is responsive (Status: $API_STATUS)"
else
    echo "⚠️ API Endpoint is not configured or not responsive (Status: $API_STATUS)"
fi

echo "✅ Verification Complete!"
