# Changelog

All notable changes to OpenClaw Shield Menu Bar will be documented in this file.

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

### v1.1.0 (Planned)
- [ ] Integration with audit-skill.sh for per-skill scanning
- [ ] macOS notifications for critical findings
- [ ] Settings panel (scan frequency, enable/disable checks)
- [ ] Detailed logs viewer
- [ ] Auto-fix actions (baseline update, etc.)

### v1.2.0 (Planned)
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
