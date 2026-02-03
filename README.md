# OpenClaw Shield Menu Bar

Native macOS menu bar app for continuous OpenClaw security monitoring.

## Features
- 🟢🟡🔴 Status indicator in menu bar
- Click to view detailed security report
- One-click fixes for common issues
- Periodic background scans
- Native Swift/SwiftUI

## Status Colors
- 🟢 Green: All checks passed
- 🟡 Yellow: Warnings found (review recommended)
- 🔴 Red: Critical issues (action required)

## Architecture
- Swift/SwiftUI native app
- Runs audit-skill.sh + monitor-skills.sh
- Parses JSON output
- Local-first, no network calls
