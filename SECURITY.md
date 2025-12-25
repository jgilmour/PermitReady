# Security Policy

## Public Repository Notice

**This is a PUBLIC repository.** All commits, files, and history are visible to anyone on the internet.

## Reporting a Vulnerability

If you discover a security vulnerability in this project, please email:
**jgilmour@techsmog.com**

Please do NOT open a public issue for security vulnerabilities.

## Sensitive Information Guidelines

### ❌ NEVER Commit

The following should NEVER be committed to this repository:

- API keys, tokens, or secrets
- Passwords or credentials
- Private keys or certificates (.pem, .p12, .key)
- OAuth client secrets
- Database connection strings with credentials
- Personal information (phone numbers, addresses, SSNs)
- Real Apple Developer Team IDs
- App Store Connect API keys
- Firebase configuration files (GoogleService-Info.plist)
- .env files with production secrets
- Provisioning profiles or certificates

### ✅ Safe to Commit

The following are safe to include:

- Source code without hardcoded secrets
- Public configuration files
- Placeholder values (e.g., `YOUR_API_KEY_HERE`, `com.yourname`)
- Documentation and README files
- Public DMV test questions (educational content)
- App UI assets and icons
- Test files with mock data

## Best Practices

### 1. Use Environment Variables

```swift
// ❌ WRONG
let apiKey = "sk_live_1234567890"

// ✅ CORRECT
let apiKey = ProcessInfo.processInfo.environment["API_KEY"] ?? ""
```

### 2. Use .xcconfig Files (Gitignored)

Create `Config.xcconfig` (automatically ignored):
```
API_KEY = your_key_here
TEAM_ID = your_team_id
```

### 3. Review Before Committing

Always run before committing:
```bash
git diff --cached
```

Check for:
- API keys or tokens
- Passwords or credentials
- Real team IDs or bundle identifiers

### 4. Use Pre-Commit Hooks

Consider adding a pre-commit hook to scan for secrets:
```bash
# .git/hooks/pre-commit
#!/bin/bash
if git diff --cached | grep -iE '(api[_-]?key|secret|password|token).*=.*["\047][a-zA-Z0-9]{20,}'; then
    echo "⚠️  WARNING: Possible secret detected in commit!"
    echo "Please review and remove before committing."
    exit 1
fi
```

## If You Accidentally Commit a Secret

**DO NOT panic, but act quickly:**

1. **Immediately revoke/rotate the exposed secret** at its source (API provider, etc.)
2. **Do NOT just delete and re-commit** - the secret is still in git history
3. Contact the repository owner
4. Use tools to remove from history:
   - [BFG Repo-Cleaner](https://rtyley.github.io/bfg-repo-cleaner/)
   - `git filter-branch`
5. Force push to rewrite history (requires coordination)

## .gitignore Protection

The `.gitignore` file is configured to automatically exclude:

- Configuration files (*.xcconfig)
- Environment files (.env, .env.*)
- Secret files (secrets.json, credentials.json)
- Certificate files (*.pem, *.p12, *.mobileprovision)
- API key Swift files (APIKeys.swift, Secrets.swift)
- Firebase config (GoogleService-Info.plist)
- App Store keys (AuthKey_*.p8)

## Questions?

If you're unsure whether something should be committed, ask yourself:

1. Would I be comfortable with this being on the front page of a newspaper?
2. Could someone use this information to access my accounts or services?
3. Is this a production secret or credential?

**When in doubt, leave it out.** Use environment variables or gitignored config files instead.

## Maintaining Security

- Regularly audit the repository for accidentally committed secrets
- Keep dependencies up to date
- Use GitHub's secret scanning (automatically enabled for public repos)
- Enable Dependabot alerts
- Review all pull requests for security issues

---

Last updated: 2025-12-24
