# XcodeBuildMCP Setup Guide for Claude Code

## What is XcodeBuildMCP?

XcodeBuildMCP is a Model Context Protocol (MCP) server that gives Claude Code the ability to interact directly with Xcode projects. Instead of just reading and writing code files, Claude can:

- Build your project and see/fix errors automatically
- Run unit and UI tests
- Launch the iOS Simulator
- Run your app in the simulator
- Capture screenshots of your running app
- Interact with simulator features

This transforms Claude from a code assistant into a development partner that can actually see and test what it builds.

---

## Installation Steps

### Prerequisites
- macOS with Xcode 16+ installed
- Claude Code CLI installed (`npm install -g @anthropic-ai/claude-code`)
- Node.js 18+ (for running the MCP server)

### Step 1: Add XcodeBuildMCP to Claude Code

Open Terminal and run:

```bash
claude mcp add XcodeBuildMCP -- npx xcodebuildmcp@latest
```

This registers XcodeBuildMCP as an MCP server that Claude Code can use.

### Step 2: Verify Installation

Check that it was added:

```bash
claude mcp list
```

You should see `XcodeBuildMCP` in the list.

### Step 3: Grant Xcode Command Line Tools Access

Make sure Xcode command line tools are configured:

```bash
xcode-select --install  # If not already installed
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
```

---

## Using XcodeBuildMCP in Claude Code

### Starting a Session

1. Open Terminal
2. Navigate to your Xcode project folder:
   ```bash
   cd ~/Projects/PermitReady
   ```
3. Start Claude Code:
   ```bash
   claude
   ```

### Key Commands Claude Can Now Execute

Once XcodeBuildMCP is active, Claude can run these operations:

#### Building Your Project
Claude will automatically use `xcodebuild` with proper flags:
```
"Build the project for iPhone 16 simulator"
"Build and fix any errors"
"Do a clean build"
```

#### Running in Simulator
```
"Boot the iPhone 16 simulator"
"Run the app in the simulator"
"Take a screenshot of the current screen"
```

#### Testing
```
"Run all unit tests"
"Run UI tests"
"Run tests and show me failures"
```

---

## Best Practices for Your Project

### 1. Create CLAUDE.md Files

CLAUDE.md files give Claude persistent context about your project. Create them at key locations:

**Root CLAUDE.md** (`/PermitReady/CLAUDE.md`):
```markdown
# PermitReady - iOS Drivers Ed App

## Build Commands
- Build: `xcodebuild -scheme PermitReady -destination 'platform=iOS Simulator,name=iPhone 16' build --quiet`
- Test: `xcodebuild -scheme PermitReady -destination 'platform=iOS Simulator,name=iPhone 16' test --quiet`
- Clean: `xcodebuild clean --quiet`

## Project Structure
- Uses xcodegen - regenerate with `xcodegen generate`
- MVVM architecture
- SwiftData for persistence
- iOS 17.0 minimum

## Key Directories
- Features/: Feature modules (Quiz, Progress, etc.)
- Core/Data/: Models and question banks
- Core/Services/: Business logic

## Coding Standards
- Swift 6 with strict concurrency
- SwiftUI for all views
- Prefer @Observable over ObservableObject
```

**Features CLAUDE.md** (`/PermitReady/Features/CLAUDE.md`):
```markdown
# Feature Modules

Each feature follows MVVM:
- Views/: SwiftUI views
- ViewModels/: @Observable classes
- No UIKit

## Creating New Features
1. Create folder: FeatureName/Views, FeatureName/ViewModels
2. ViewModel should be @Observable
3. Views use @State for view-only state, ViewModel for business logic
```

### 2. Use xcodegen for Project Management

Never edit `.xcodeproj` directly. Instead:

1. Make changes in `project.yml`
2. Run `xcodegen generate`
3. The `.xcodeproj` file is regenerated cleanly

Add to `.gitignore`:
```
*.xcodeproj
```

### 3. Use --quiet Flag for Builds

Always include `--quiet` in build commands to prevent Xcode's verbose output from filling Claude's context window:

```bash
xcodebuild -scheme PermitReady build --quiet
```

### 4. Request Screenshots After UI Changes

After Claude makes UI changes, ask it to:
```
"Run the app and take a screenshot of the quiz screen"
```

This lets Claude see the visual result and make adjustments.

---

## Example Workflow Session

Here's how a typical development session might look:

**You:** "Let's start building the quiz feature. Create the QuizView and QuizViewModel."

**Claude:** Creates the files, then:
- Builds the project to check for errors
- Fixes any compilation issues
- Boots the simulator
- Runs the app
- Takes a screenshot to verify the UI

**You:** "The answer buttons look too small. Make them larger and add more padding."

**Claude:** 
- Modifies the view code
- Rebuilds
- Runs and captures new screenshot
- Shows you the result

**You:** "Perfect. Now write tests for the QuizViewModel."

**Claude:**
- Creates test file
- Runs tests
- Reports pass/fail results

---

## Troubleshooting

### "Simulator not found"
```bash
xcrun simctl list devices
```
Pick a valid device name from the list.

### "Build failed with signing error"
In `project.yml`, ensure your team ID is set:
```yaml
settings:
  base:
    DEVELOPMENT_TEAM: YOUR_TEAM_ID
```

### "MCP server not responding"
Restart Claude Code:
```bash
claude --mcp-debug
```
This shows MCP server logs for troubleshooting.

### Context window filling up
If builds produce too much output, ensure `--quiet` is being used. You can also ask Claude to "clean up context" periodically.

---

## Quick Reference Card

| Task | Ask Claude |
|------|------------|
| Build project | "Build the project" |
| Build + run | "Build and run in simulator" |
| Fix errors | "Build and fix any errors" |
| Run tests | "Run unit tests" |
| Screenshot | "Take a screenshot" |
| Boot simulator | "Boot iPhone 16 simulator" |
| Clean build | "Do a clean build" |
| Regenerate project | "Run xcodegen generate" |

---

## Getting Started with PermitReady

1. Copy the starter files to your project folder
2. Open Terminal: `cd ~/Projects/PermitReady`
3. Generate project: `xcodegen generate`
4. Start Claude: `claude`
5. Say: "Read the PROJECT_PROMPT.md and let's start with Phase 1"

Claude will read the prompt, understand the project structure, and begin building your drivers ed app with full Xcode integration.
