#!/bin/bash

# Script to prepare secrets for GitHub Actions
# This script helps you encode your secrets files for use in GitHub Secrets

set -e

echo "🔐 Secrets Preparation Tool for Monorepo CI/CD"
echo "============================================="
echo ""

# Check if .initial_secrets exists
if [ ! -f ".initial_secrets" ]; then
    echo "❌ Error: .initial_secrets file not found!"
    echo ""
    echo "Please create .initial_secrets file with your temporary AWS credentials."
    echo "You can use .initial_secrets.example as a template:"
    echo "  cp .initial_secrets.example .initial_secrets"
    echo ""
    exit 1
fi

# Check if .secrets exists
if [ ! -f ".secrets" ]; then
    echo "❌ Error: .secrets file not found!"
    echo ""
    echo "Please create .secrets file with your project configuration."
    echo "You can use .secrets.example as a template:"
    echo "  cp .secrets.example .secrets"
    echo ""
    exit 1
fi

# Validate that required variables are set
echo "📋 Validating required secrets..."

# Required variables in .initial_secrets
initial_required_vars=(
    "TEMP_AWS_ACCESS_KEY_ID"
    "TEMP_AWS_SECRET_ACCESS_KEY"
)

# Required variables in .secrets
secrets_required_vars=(
  # GitHub Configuration
  "GITHUB_ORG"
  "GITHUB_REPO"
  # AWS Configuration
  "AWS_REGION"
  "AWS_ACCOUNT_ID"
  # Project Configuration
  "TF_VAR_PREFIX"
  # Database Configuration
  "TF_VAR_DB_PASSWORD"
  "DB_NAME"
  "DB_USERNAME"
)

# Function to validate a file
validate_file() {
    local file_path="$1"
    local required_vars_ref="$2[@]"
    local required_vars=("${!required_vars_ref}")
    local missing_vars=()
    
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
    done < "$file_path"
    
    if [ ${#missing_vars[@]} -gt 0 ]; then
        echo ""
        echo "❌ The following required variables are not set in $file_path:"
        for var in "${missing_vars[@]}"; do
            echo "  - $var"
        done
        echo ""
        echo "Please edit $file_path and set all required values."
        return 1
    fi
    
    return 0
}

# Validate .initial_secrets
echo "🔍 Validating .initial_secrets..."
if ! validate_file ".initial_secrets" "initial_required_vars"; then
    exit 1
fi
echo "✅ .initial_secrets validation passed"

# Validate .secrets
echo "🔍 Validating .secrets..."
if ! validate_file ".secrets" "secrets_required_vars"; then
    exit 1
fi
echo "✅ .secrets validation passed"

echo ""
echo "✅ All required secrets are present in both files"
echo ""

# Create base64 encoded versions
echo "🔄 Encoding secrets files..."

# Encode .initial_secrets
ENCODED_INITIAL_SECRETS=$(base64 -w 0 < .initial_secrets 2>/dev/null || base64 < .initial_secrets)
echo "$ENCODED_INITIAL_SECRETS" > .initial_secrets.b64

# Encode .secrets
ENCODED_SECRETS=$(base64 -w 0 < .secrets 2>/dev/null || base64 < .secrets)
echo "$ENCODED_SECRETS" > .secrets.b64

echo "✅ Both secrets files encoded successfully!"
echo ""
echo "📝 Next Steps:"
echo "============="
echo ""
echo "1. Copy the encoded secrets from the generated files:"
echo "   📄 .initial_secrets.b64 → GitHub Secret: INITIAL_SECRETS_B64"
echo "   📄 .secrets.b64 → GitHub Secret: SECRETS_B64"
echo ""
echo "2. Go to your GitHub repository settings:"
echo "   https://github.com/YOUR_USERNAME/YOUR_REPO/settings/secrets/actions"
echo ""
echo "3. Create these two repository secrets:"
echo "   🔑 Secret Name: INITIAL_SECRETS_B64"
echo "      Value: Contents of .initial_secrets.b64"
echo ""
echo "   🔑 Secret Name: SECRETS_B64"
echo "      Value: Contents of .secrets.b64"
echo ""
echo "4. Save both secrets"
echo ""
echo "⚠️  Security Notes:"
echo "  - Never commit .initial_secrets, .secrets, or their .b64 files to Git"
echo "  - Delete .initial_secrets.b64 and .secrets.b64 after adding to GitHub"
echo "  - Keep .initial_secrets and .secrets in secure locations as backups"
echo "  - Remove .initial_secrets after Infrastructure deploy is complete"
echo ""
echo "🧹 Cleanup commands (after adding to GitHub):"
echo "  rm .initial_secrets.b64 .secrets.b64"
echo "  # After OIDC setup: rm .initial_secrets"
echo ""

# Check if files are in .gitignore
if [ -f ".gitignore" ]; then
    if ! grep -q "^.secrets" .gitignore || ! grep -q "^.initial_secrets" .gitignore; then
        echo "⚠️  Warning: Secret files are not properly in .gitignore!"
        echo "  Adding them now..."
        echo "" >> .gitignore
        echo "# Secrets files" >> .gitignore
        echo ".secrets*" >> .gitignore
        echo "!.secrets*.example" >> .gitignore
        echo ".initial_secrets*" >> .gitignore
        echo "!.initial_secrets*.example" >> .gitignore
        echo "appsettings.Production.json" >> .gitignore
        echo "✅ Added secret files to .gitignore"
    fi
fi