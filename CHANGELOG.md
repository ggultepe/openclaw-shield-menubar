# Changelog

All notable changes to OpenClaw Shield Menu Bar will be documented in this file.

## [1.1.1] - 2026-02-10

### 🐛 UI Bug Fixes

**Issue #1: Version shows 'Unknown' on startup**
- Fixed: Now checks version immediately on app launch

**Issue #2: 'Update Now' button incorrectly styled**
- Fixed: Replaced with "Up to date" badge when no update available
- Blue "Update Now" button only appears when there's an actual update

**Issue #3: Security 'Check Now' has no feedback**
- Fixed: Shows "Done! ✓" with green checkmark for 1.5 seconds after scan
- State moved to SecurityScanner singleton for reliable UI updates

---

## [1.1.0] - 2026-02-10

### ✨ New Feature: OpenClaw Update Checker

Automatically checks for OpenClaw updates and notifies you when a new version is available.

**Features:**
- 📦 Version monitoring — Checks every 4 hours automatically
- 🔔 macOS notifications — Alert when update is available
- ⬆️ One-click update — "Update Now" button in the UI
- 🛡️ Gateway awareness — Warns if gateway is running during update
- 🔐 Permission handling — Guides user with sudo command if needed
- 🏠 NVM support — Detects npm in NVM installations (~/.nvm/versions/node/)

**Security (5/5 rating):**
- ✅ No command injection — Uses Process API with args array
- ✅ Path traversal protection — Semver regex validation for NVM directories
- ✅ Error output sanitization — 200 char limit, newlines stripped
- ✅ Precise permission detection — Only triggers on actual EACCES errors
- ✅ Gateway state captured once — No race conditions during update

**Development Process:**
- Full 4-phase SDLC pipeline: Analyst → Coder → QA → Reviewer
- 2 iteration loops (QA fixes + security fixes)
- 8 sub-agent passes total
- Final security rating: ⭐⭐⭐⭐⭐ (5/5)

**Files Added:**
- `UpdateChecker.swift` — Version checking, update installation, notifications

**Files Modified:**
- `ContentView.swift` — Added version display section and update buttons
- `OpenClawShieldMenuBarApp.swift` — Initialize UpdateChecker, request notification permissions

---

## [1.0.0] - 2026-02-03

### 🎉 Initial Release

Native macOS menu bar app for continuous OpenClaw security monitoring.

**Features:**
- 🟢🟡🔴 Status indicator in menu bar
- Click to view detailed security report
- Periodic background scans (every 30 minutes)
- Manual refresh button
- Skill tracking count display
- Native Swift/SwiftUI design

---

## [1.0.0-rc2] - 2026-02-03 (Post-Review)

### 🔒 Security & Bug Fixes (Reviewer Audit)

**Critical Fixes:**
- Fixed issue accumulation bug (issues never cleared between scans)
- Added 30-second timeout to prevent app hanging if script hangs
- Fixed memory leak from timer not being invalidated

**Important Fixes:**
- Added error reporting for missing/unreadable baseline file
- Made script paths configurable via CLAWD_HOME env var
- Added 1MB output buffer limit to prevent memory exhaustion
- Improved emoji and whitespace handling in parsing

**Minor Improvements:**
- Removed unused @Published property in AppDelegate
- Removed non-functional "Fix" button (will add back when implemented)
- Better error messages with actionable suggested fixes

**Security Rating:** 4/5 → 5/5  
**Code Quality:** 3/5 → 4/5

---

## [1.0.0-rc1] - 2026-02-03 (Initial Build)

### Added
- Initial project structure
- AppDelegate with NSStatusItem management
- ContentView with SwiftUI popover UI
- SecurityScanner for running monitor-skills.sh
- Issue detection and parsing
- Status icon updates (green/yellow/red)
- Timer for periodic scans

### Known Issues (Fixed in rc2)
- Issue accumulation bug
- No timeout on shell execution
- Timer not cleaned up
- Silent baseline read failure
- Hardcoded script paths

---

## Future Roadmap

### v1.1.0 ✅ COMPLETE
- [x] OpenClaw Update Checker (version monitoring + notifications)
- [x] macOS notifications (for updates)
- [x] NVM npm detection support

### v1.2.0 (Planned)
- [ ] Integration with audit-skill.sh for per-skill scanning
- [ ] Settings panel (scan frequency, enable/disable checks)
- [ ] Detailed logs viewer
- [ ] Auto-fix actions (baseline update, etc.)

### v1.3.0 (Planned)
- [ ] JSON output parsing (more robust than text parsing)
- [ ] Persistent logging with os_log
- [ ] Export report to file
- [ ] Historical trend tracking

### v2.0.0 (Future)
- [ ] CLI tool integration (full openclaw-shield checks)
- [ ] Dependency vulnerability scanning
- [ ] Credential exposure checks
- [ ] Network exposure checks
- [ ] Real-time monitoring (inotify/FSEvents)

---

## Version History

| Version | Date | Status | Notes |
|---------|------|--------|-------|
| 1.0.0-rc1 | 2026-02-03 | ⚠️ Not released | Initial build, had critical bugs |
| 1.0.0-rc2 | 2026-02-03 | ✅ Production ready | All critical issues fixed |
| 1.0.0 | 2026-02-03 | 🚀 Release | Finalized after testing |
| 1.1.0 | 2026-02-10 | 🚀 Release | Update Checker feature |

---

## Breaking Changes

None yet (first release).

---

## Deprecations

None yet.

---

## Security Advisories

None yet.

---

## Acknowledgments

- **Reviewer Agent:** Comprehensive security audit that caught 2 critical bugs before release
- **Güven Gültepe:** Product vision and proper QA workflow enforcement
- **OpenClaw Project:** Scripts and security tooling that this app monitors

---

## License

Copyright © 2026 Artificial Güven. All rights reserved.

Part of the openclaw-shield security suite.
