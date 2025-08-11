# Safe Step-by-Step Monorepo Setup

## Current State Verification

First, let's confirm your backup is properly restored:

```bash
# Check your current directory structure
ls -la

# Verify you have the three separate repositories
ls -la infra/.git
ls -la server/.git  
ls -la web/.git

# Check you're in the parent directory
pwd
# Should show: .../nlw20Agents
```

Expected structure:
```
nlw20Agents/
├── infra/ 
├── server/  
└── web/   
```

## Step 1: Initialize New Monorepo with Initial Commit

```bash
# Initialize Git in the parent directory
git init

# Set default branch name
git branch -m main

# Create a basic .gitignore for the monorepo
cat > .gitignore << 'EOF'
# OS generated files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# IDE
.idea/
.vscode/

# Environment files
.env
.env.local
.env.*.local
EOF

# Create initial README
cat > README.md << 'EOF'
# NLW20 Agents - Monorepo

This monorepo contains three main components:

- **infra/**: AWS infrastructure using Terraform
- **server/**: Backend API (.NET)
- **web/**: Frontend application (Next.js)

## Structure
- Each component maintains its own development workflow
- Shared deployment pipeline coordinates all services
- Infrastructure outputs are used to configure dependent services
EOF

# Stage and commit initial files
git add .gitignore README.md
git commit -m "Initial commit: Setup monorepo structure"

# Verify initial state
git log --oneline
git status
```

**🛡️ CHECKPOINT 1**: You should see one commit and clean working directory. If something's wrong:
```bash
# ROLLBACK: Delete .git and start over
rm -rf .git
```

## Step 2: Add Infrastructure Repository

```bash
# Add infra as a remote
git remote add infra-origin ./infra

# Fetch its history
git fetch infra-origin

# Create a backup tag before merge (safety measure)
git tag backup-before-infra

# IMPORTANT: Move the existing infra directory out of the way temporarily
mv infra infra_temp

# Merge infra into infra/ subdirectory
git merge -s ours --no-commit --allow-unrelated-histories infra-origin/main
git read-tree --prefix=infra/ -u infra-origin/main
git commit -m "Add infrastructure repository to monorepo"

# Remove the temporary directory (we don't need it anymore)
rm -rf infra_temp

# Verify structure
ls -la infra/
git log --oneline -3
```

**🛡️ CHECKPOINT 2**: You should see infra files in `infra/` directory and new commits. If something's wrong:
```bash
# ROLLBACK: Reset to before infra merge
git reset --hard backup-before-infra
git clean -fd
git tag -d backup-before-infra
```

## Step 3: Add Server Repository  

```bash
# Add server as a remote
git remote add server-origin ./server

# Fetch its history
git fetch server-origin

# Create backup tag before merge
git tag backup-before-server

# IMPORTANT: Move the existing server directory out of the way temporarily
mv server server_temp

# Merge server into server/ subdirectory
git merge -s ours --no-commit --allow-unrelated-histories server-origin/main
git read-tree --prefix=server/ -u server-origin/main
git commit -m "Add server repository to monorepo"

# Remove the temporary directory
rm -rf server_temp

# Verify structure
ls -la server/
git log --oneline -3
```

**🛡️ CHECKPOINT 3**: You should see server files in `server/` directory. If something's wrong:
```bash
# ROLLBACK: Reset to before server merge
git reset --hard backup-before-server
git clean -fd
git tag -d backup-before-server
```

## Step 4: Add Web Repository

```bash
# Add web as a remote
git remote add web-origin ./web

# Fetch its history  
git fetch web-origin

# Create backup tag before merge
git tag backup-before-web

# IMPORTANT: Move the existing web directory out of the way temporarily
mv web web_temp

# Merge web into web/ subdirectory
git merge -s ours --no-commit --allow-unrelated-histories web-origin/main
git read-tree --prefix=web/ -u web-origin/main
git commit -m "Add web repository to monorepo"

# Remove the temporary directory
rm -rf web_temp

# Verify structure
ls -la web/
git log --oneline -5
```

**🛡️ CHECKPOINT 4**: You should see web files in `web/` directory. If something's wrong:
```bash
# ROLLBACK: Reset to before web merge
git reset --hard backup-before-web
git clean -fd
git tag -d backup-before-web
```

## Step 5: Clean Up and Finalize

```bash
# Remove the nested .git directories from the merged directories
find infra/ server/ web/ -name ".git" -type d -exec rm -rf {} + 2>/dev/null

# Remove the temporary remotes
git remote remove infra-origin
git remote remove server-origin
git remote remove web-origin

# Remove backup tags (cleanup)
git tag -d backup-before-infra backup-before-server backup-before-web

# Verify final structure
tree -L 2 -la
# OR if you don't have tree:
find . -maxdepth 2 -type d | sort
```

## Step 6: Final Verification

```bash
# Check Git status (should be clean)
git status

# Verify repository structure
ls -la

# Check commit history (should show all merged histories)
git log --oneline --graph -10

# Verify each directory has its files
ls -la infra/
ls -la server/
ls -la web/

# Check that we have preserved commit history
git log --oneline infra/ | head -5
git log --oneline server/ | head -5  
git log --oneline web/ | head -5
```

## Expected Final Structure

```
nlw20Agents/
├── .git/                    # Main monorepo git
├── .gitignore              # Root gitignore
├── README.md               # Root README  
├── infra/                  # Infrastructure code (no .git)
│   ├── .github/
│   ├── 1-admin/
│   ├── 2-resources/
│   ├── 3-apprunner/
│   └── ...
├── server/                 # Server code (no .git)
│   ├── .github/
│   ├── Dockerfile
│   ├── server.API/
│   ├── server.sln
│   └── ...
└── web/                    # Web code (no .git)
    ├── package.json
    ├── src/
    ├── next.config.ts
    └── ...
```

## Emergency Full Rollback

If anything goes completely wrong at any point:

```bash
# Nuclear option: Delete everything and restore from backup
rm -rf .git .gitignore README.md

# Your original directories should still be intact:
ls -la
# Should show: infra/, server/, web/ (with their .git directories)
```

## Success Indicators

✅ **Structure**: Three directories (infra/, server/, web/) with all their original files  
✅ **History**: `git log` shows commits from all three original repositories  
✅ **Clean**: `git status` shows no uncommitted changes  
✅ **No nested .git**: No .git directories inside infra/, server/, or web/  
✅ **Remote cleanup**: `git remote -v` shows no temporary remotes

Once we confirm success at each step, we can proceed to the next one. Let's start with Step 1!
