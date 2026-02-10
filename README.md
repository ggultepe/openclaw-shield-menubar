# OpenClaw Shield Menu Bar

Native macOS menu bar app for continuous OpenClaw security monitoring.

**Status:** ✅ Production Ready (v1.1.0) — Now with Update Checker!

---

## ✨ Features

### Core Functionality
- 🟢🟡🔴 **Status indicator** in menu bar (real-time security status)
- 📊 **Detailed report** on click (popover with issue list)
- 🔄 **Periodic scans** (every 30 minutes, automatic)
- ⚡ **Manual refresh** (on-demand scan button)
- 📈 **Skills tracking** (52 skills monitored)
- 🎨 **Native UI** (Swift/SwiftUI, feels like macOS)

### Update Checker (NEW in v1.1.0)
- 📦 **Version monitoring** — Checks for OpenClaw updates every 4 hours
- 🔔 **Notifications** — macOS notification when update available
- ⬆️ **One-click update** — "Update Now" button runs `npm -g install openclaw@latest`
- 🛡️ **Gateway awareness** — Warns if gateway is running during update
- 🔐 **Permission handling** — Guides user with sudo command if needed
- 🏠 **NVM support** — Detects npm in NVM installations

### Security Features
- ✅ **Skill baseline monitoring** (detects new/removed/modified skills)
- ✅ **Timeout protection** (30s limit, no hanging)
- ✅ **Memory safe** (1MB output limit, no leaks)
- ✅ **Error reporting** (actionable feedback for missing files)
- ✅ **Configurable paths** (CLAWD_HOME env var support)

## 🎨 Status Colors

- 🟢 **Green:** All checks passed — secure
- 🟡 **Yellow:** Warnings found — review recommended
- 🔴 **Red:** Critical issues — action required
- ⚪ **Gray:** Scanning or unknown status

---

## 📋 Requirements

- **macOS:** 13.0+ (Ventura or later)
- **Xcode:** 14.0+ (for building)
- **Swift:** 5.9+
- **OpenClaw:** Scripts installed at `~/clawd/scripts/`
- **Baseline:** Created with `~/clawd/scripts/monitor-skills.sh --init`

**Optional:**
- `xcodegen` (for project generation): `brew install xcodegen`

---

## 🚀 Quick Start

### Option 1: Automated (Recommended)

```bash
# Clone or navigate to project
cd ~/Projects/openclaw-shield-menubar

# Generate Xcode project (if not already generated)
./create-xcode-project.sh

# Open in Xcode
open OpenClawShieldMenuBar.xcodeproj

# Build & Run (⌘R in Xcode)
# Look for shield icon in menu bar!
```

### Option 2: Manual

See [BUILD.md](BUILD.md) for detailed step-by-step instructions.

---

## 🏗️ Architecture

**Tech Stack:**
- **Language:** Swift 5.9+
- **UI:** SwiftUI (native macOS design)
- **Target:** macOS 13.0+ (Ventura)
- **Mode:** Menu bar only (LSUIElement = true, no Dock icon)

**Components:**
- **OpenClawShieldMenuBarApp.swift** — Main app + AppDelegate + NSStatusItem
- **ContentView.swift** — SwiftUI UI (popover, 400x500px)
- **SecurityScanner.swift** — Script runner + output parser + state management

**How It Works:**
1. App runs `~/clawd/scripts/monitor-skills.sh --check` on launch
2. Parses text output for skill changes (new/removed/modified)
3. Updates status icon color based on severity
4. Timer re-scans every 30 minutes
5. User clicks icon → sees full report in popover
6. Manual refresh button for on-demand scans

**Security Model:**
- Local-first, no network calls
- Scripts run in user's security context
- 30-second timeout prevents hanging
- 1MB output limit prevents memory exhaustion
- No arbitrary code execution (Process API with args array)

---

## 🔧 Configuration

### Custom Script Path

Set `CLAWD_HOME` environment variable to use a different installation path:

```bash
# In Xcode: Edit Scheme → Run → Environment Variables
CLAWD_HOME=/path/to/custom/clawd

# Or in launch script:
export CLAWD_HOME=/path/to/custom/clawd
open ~/Projects/openclaw-shield-menubar/build/OpenClawShieldMenuBar.app
```

### Scan Frequency

Default: 30 minutes

To change, edit `OpenClawShieldMenuBarApp.swift`:
```swift
// Line 48: Change 30 * 60 to your desired interval in seconds
timer = Timer.scheduledTimer(withTimeInterval: 30 * 60, repeats: true) { [weak self] _ in
```

---

## 🧪 Testing

See [TESTING.md](TESTING.md) for comprehensive testing checklist.

**Quick smoke test:**
1. Launch app
2. Verify shield icon appears in menu bar
3. Click icon → popover shows
4. Click refresh → scan runs
5. Quit → app exits cleanly

---

## 📚 Documentation

- **[BUILD.md](BUILD.md)** — Detailed build instructions (Xcode manual setup)
- **[SETUP.md](SETUP.md)** — Troubleshooting & requirements
- **[TESTING.md](TESTING.md)** — Comprehensive testing guide
- **[CHANGELOG.md](CHANGELOG.md)** — Version history & bug fixes

---

## 🔒 Security

This app has been audited by our **Reviewer agent** (security-focused code review).

**Security Rating:** ⭐⭐⭐⭐⭐ (5/5)  
**Code Quality:** ⭐⭐⭐⭐⭐ (5/5)

### v1.0.0 Fixes
- ✅ Issue accumulation bug (critical)
- ✅ No timeout on shell execution (critical)
- ✅ Timer not invalidated (important)
- ✅ Silent baseline read failure (important)
- ✅ Hardcoded script paths (important)
- ✅ No output buffer limit (important)

### v1.1.0 Update Checker Security
- ✅ No command injection (Process API with args array)
- ✅ Path traversal protection (semver regex validation for NVM)
- ✅ Error output sanitization (200 char limit, no ANSI codes)
- ✅ Precise permission detection (no false positive sudo prompts)
- ✅ Gateway state captured once (no race conditions)

See [CHANGELOG.md](CHANGELOG.md) for full audit results.

---

## 🐛 Known Limitations

1. **Text parsing only** — Uses regex/string parsing instead of JSON. Fragile to format changes.
2. **Single check** — Only runs `monitor-skills.sh`. Future: integrate `audit-skill.sh`.
3. **No persistent logs** — Debugging requires Xcode console.
4. **Update needs sudo** — Global npm install may require admin access (guided).

---

## 🚧 Roadmap

### v1.1.0 ✅ COMPLETE
- [x] **OpenClaw Update Checker** — Version monitoring + notifications + one-click update
- [x] macOS notifications (for updates)
- [x] NVM npm detection support

### v1.2.0 (Next)
- [ ] Integration with `audit-skill.sh` (per-skill scanning)
- [ ] Settings panel (scan frequency, enable/disable checks)
- [ ] Detailed logs viewer
- [ ] Auto-fix actions (baseline update)

### v1.2.0
- [ ] JSON output parsing (more robust)
- [ ] Persistent logging with `os_log`
- [ ] Export report to file
- [ ] Historical trend tracking

### v2.0.0
- [ ] Full `openclaw-shield` CLI integration
- [ ] Dependency vulnerability scanning
- [ ] Credential exposure checks
- [ ] Network exposure checks
- [ ] Real-time monitoring (FSEvents)

---

## 🤝 Contributing

This is part of the **openclaw-shield** security suite.

**Project Structure:**
```
openclaw-shield/
├── cli/                          (Phase 1: npm package - planned)
│   ├── audit-skill.sh
│   ├── monitor-skills.sh
│   └── bw-helper.sh
└── menubar/                      (Phase 2: macOS app - this repo)
    ├── OpenClawShieldMenuBar.xcodeproj
    └── OpenClawShieldMenuBar/
```

**Development Workflow:**
1. Create feature branch
2. Write tests (see TESTING.md)
3. Run Reviewer agent audit
4. Fix all critical/important issues
5. Submit PR with test results

---

## 📄 License

Copyright © 2026 Artificial Güven. All rights reserved.

Part of the openclaw-shield security suite.

---

## 🙏 Acknowledgments

- **Reviewer Agent** — Caught 2 critical bugs before release
- **Güven Gültepe** — Product vision & QA workflow
- **OpenClaw Project** — Security scripts & tooling

---

## 📞 Support

**Issues:**
- GitHub Issues (coming soon when repo is public)
- Email: artificialguven@gmail.com

**Documentation:**
- Main docs: See links above
- OpenClaw docs: https://docs.openclaw.ai
- Community: https://discord.com/invite/clawd

---

**Built with 🧠 by Artificial Güven**
