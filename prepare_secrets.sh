#!/bin/bash

# Script to prepare secrets for GitHub Actions
# This script helps you encode your secrets file for use in GitHub Secrets

set -e

echo "🔐 Secrets Preparation Tool for Monorepo CI/CD"
echo "============================================="
echo ""

# Check if .secrets.unified exists
if [ ! -f ".secrets.unified" ]; then
    echo "❌ Error: .secrets.unified file not found!"
    echo ""
    echo "Please create .secrets.unified file with your credentials."
    echo "You can use .secrets.unified.example as a template:"
    echo "  cp .secrets.unified.example .secrets.unified"
    echo ""
    exit 1
fi

# Validate that required variables are set
echo "📋 Validating required secrets..."
required_vars=(
    "AWS_REGION"
    "AWS_ADMIN_ACCESS_KEY_ID"
    "AWS_ADMIN_SECRET_ACCESS_KEY"
    "AWS_RESOURCES_CREATOR_ACCESS_KEY_ID"
    "AWS_RESOURCES_CREATOR_SECRET_ACCESS_KEY"
    "TF_VAR_PREFIX"
    "TF_VAR_RESOURCES_CREATOR_PROFILE"
    "TF_VAR_DB_PASSWORD"
    "OPENAI_API_KEY"
)

missing_vars=()
while IFS= read -r line; do
    # Skip empty lines and comments
    [[ -z "$line" || "$line" =~ ^# ]] && continue
    
    # Extract variable name
    var_name=$(echo "$line" | cut -d'=' -f1)
    var_value=$(echo "$line" | cut -d'=' -f2-)
    
    # Check if it's a required variable and if it's empty
    for req_var in "${required_vars[@]}"; do
        if [[ "$var_name" == "$req_var" && -z "$var_value" ]]; then
            missing_vars+=("$req_var")
        fi
    done
done < ".secrets.unified"

if [ ${#missing_vars[@]} -gt 0 ]; then
    echo ""
    echo "❌ The following required variables are not set:"
    for var in "${missing_vars[@]}"; do
        echo "  - $var"
    done
    echo ""
    echo "Please edit .secrets.unified and set all required values."
    exit 1
fi

echo "✅ All required secrets are present"
echo ""

# Create base64 encoded version
echo "🔄 Encoding secrets file..."
ENCODED_SECRETS=$(base64 -w 0 < .secrets.unified 2>/dev/null || base64 < .secrets.unified)

# Save to a temporary file for easy copying
echo "$ENCODED_SECRETS" > .secrets.unified.b64

echo "✅ Secrets encoded successfully!"
echo ""
echo "📝 Next Steps:"
echo "============="
echo ""
echo "1. Copy the encoded secrets from .secrets.unified.b64"
echo ""
echo "2. Go to your GitHub repository settings:"
echo "   https://github.com/YOUR_USERNAME/YOUR_REPO/settings/secrets/actions"
echo ""
echo "3. Create a new repository secret named: UNIFIED_SECRETS_B64"
echo ""
echo "4. Paste the entire content of .secrets.unified.b64 as the value"
echo ""
echo "5. Save the secret"
echo ""
echo "⚠️  Security Notes:"
echo "  - Never commit .secrets.unified or .secrets.unified.b64 to Git"
echo "  - Delete .secrets.unified.b64 after adding to GitHub"
echo "  - Keep .secrets.unified in a secure location as backup"
echo ""
echo "🧹 Cleanup command (after adding to GitHub):"
echo "  rm .secrets.unified.b64"
echo ""

# Check if files are in .gitignore
if [ -f ".gitignore" ]; then
    if ! grep -q "^.secrets" .gitignore; then
        echo "⚠️  Warning: .secrets* files are not in .gitignore!"
        echo "  Adding them now..."
        echo "" >> .gitignore
        echo "# Secrets files" >> .gitignore
        echo ".secrets*" >> .gitignore
        echo "!.secrets*.example" >> .gitignore
        echo "appsettings.Production.json" >> .gitignore
        echo "✅ Added to .gitignore"
    fi
fi