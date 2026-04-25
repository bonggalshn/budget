# Submodule Management Scripts

This directory contains scripts for managing git submodules in the Budget project.

## Project Structure

The Budget project uses git submodules to manage the backend and frontend as separate repositories:

- **budget-be** (`https://github.com/bonggalshn/budget-be.git`): Backend service (Go + PostgreSQL)
- **budget-fe** (`https://github.com/bonggalshn/budget-fe.git`): Frontend application

## Scripts

### `init-submodules.ps1` (Windows/PowerShell)

Initialize and fetch all submodules on Windows systems.

**Usage:**
```powershell
.\scripts\init-submodules.ps1
```

**What it does:**
1. Checks if `.gitmodules` file exists
2. Initializes any uninitialized submodules (`git submodule update --init --recursive`)
3. Fetches latest from all submodule remotes (`git submodule foreach 'git fetch origin'`)
4. Updates submodules to their tracked commits (`git submodule update --recursive`)
5. Displays final submodule status

**Prerequisites:**
- Git installed and in PATH
- PowerShell 5.0 or higher

### `init-submodules.sh` (Linux/Mac/Bash)

Initialize and fetch all submodules on Linux/Mac systems.

**Usage:**
```bash
bash scripts/init-submodules.sh
# or
chmod +x scripts/init-submodules.sh
./scripts/init-submodules.sh
```

**What it does:**
Same as PowerShell version (1-5 above).

**Prerequisites:**
- Git installed and in PATH
- Bash 3.0 or higher

## Common Submodule Workflows

### Initial Clone with Submodules

Clone the repository with all submodules initialized:
```bash
git clone --recurse-submodules https://github.com/bonggalshn/budget.git
```

Or after cloning normally, initialize submodules:
```bash
git submodule update --init --recursive
```

### Update Submodules to Latest Remote

Fetch the latest commits from all submodule repositories:
```bash
git submodule foreach --recursive 'git fetch origin'
git submodule update --recursive
```

Or use the convenience script:
```bash
# Windows
.\scripts\init-submodules.ps1

# Linux/Mac
bash scripts/init-submodules.sh
```

### Check Submodule Status

View the current commit of each submodule:
```bash
git submodule status --recursive
```

### Update Specific Submodule

Move a specific submodule to a different commit:
```bash
cd budget-be
git checkout <commit-hash>
cd ..
git add budget-be
git commit -m "chore: update budget-be submodule to <commit-hash>"
```

### Pull Latest Changes for All Modules

Update parent repository and all submodules:
```bash
git pull origin main
git submodule update --recursive
```

## Important Notes

- **Submodule Commits**: Each submodule reference is pinned to a specific commit. Use `git submodule update --init --recursive` to move to the tracked commit.
- **Working in Submodules**: When working inside a submodule directory (e.g., `cd budget-be`), remember you're working in a separate git repository. Create/checkout branches there as needed.
- **Pushing Submodule Changes**: Push changes within a submodule to its own repository first, then update the parent repository's submodule reference.

## Troubleshooting

### Submodule not initializing

Ensure `.gitmodules` file exists in the repository root and contains valid configuration:
```bash
cat .gitmodules
```

### "fatal: no submodule mapping found"

This usually means the submodule wasn't properly initialized. Run:
```bash
git submodule update --init --recursive
```

### Submodule stuck at old commit

Update the submodule to the latest:
```bash
cd <submodule-path>
git fetch origin
git checkout origin/main  # or your default branch
cd ..
git add <submodule-path>
git commit -m "chore: update <submodule-path> to latest"
```

## More Information

- [Git Submodules Documentation](https://git-scm.com/book/en/v2/Git-Tools-Submodules)
- [GitHub Help - Configuring submodules](https://docs.github.com/en/github/working-with-github/about-submodules)
