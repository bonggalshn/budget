---
description: "Commit changes after a Spec Kit command completes"
---

# Commit Changes

Stage and commit changes after a Spec Kit command completes.

## Behavior

This command is invoked as a hook after (or before) core commands. It:

1. Determines the event name from the hook context (e.g., if invoked as an `after_specify` hook, the event is `after_specify`; if `before_plan`, the event is `before_plan`)
2. Checks `.specify/extensions/git/git-config.yml` for the `auto_commit` section
3. Looks up the specific event key to see if auto-commit is enabled
4. **Requires user approval before committing** (user must explicitly say "yes" or "proceed")
5. Uses the per-command `message` if configured, otherwise a default message
6. If enabled and there are uncommitted changes, shows what will be committed and **waits for user confirmation**

## **IMPORTANT: User Approval Required**

- **NEVER** auto-commit without asking the user first
- Always display `git diff --stat` to show what will be committed
- Use this format:
  ```
  ## Ready to Commit

  Changes to be committed:
  (shows git status output)

  Do you want to commit these changes? (yes/no)
  ```
- Only proceed with commit after user explicitly confirms with "yes"
- If user says "no" or "wait", output manual git commands they can run:
  ```
  # To commit manually:
  git add -A
  git commit -m "<message>"
  git push
  ```

## Execution

Determine the event name from the hook that triggered this command, then run the script:

- **Bash**: `.specify/extensions/git/scripts/bash/auto-commit.sh <event_name>`
- **PowerShell**: `.specify/extensions/git/scripts/powershell/auto-commit.ps1 <event_name>`

Replace `<event_name>` with the actual hook event (e.g., `after_specify`, `before_plan`, `after_implement`).

## Configuration

In `.specify/extensions/git/git-config.yml`:

```yaml
auto_commit:
  default: false          # Global toggle — set true to enable for all commands (still requires approval)
  after_specify:
    enabled: true          # Override per-command (still requires approval)
    message: "[Spec Kit] Add specification"
  after_plan:
    enabled: false
    message: "[Spec Kit] Add implementation plan"
```

## Graceful Degradation

- If Git is not available or the current directory is not a repository: skips with a warning
- If no config file exists: prompts user anyway (never auto-commit)
- If no changes to commit: output message with no changes to commit
