# Feature Roadmap

OpenClaw Shield Menu Bar - Enhancement Features

---

## 🎯 Priority Framework

**P0** - Critical (security, data loss, crashes)  
**P1** - High (core functionality, UX blockers)  
**P2** - Medium (nice to have, polish)  
**P3** - Low (future consideration)

---

## 📋 Feature Backlog

### P1 - High Priority

#### F1: Audit-Skill.sh Integration
**Status:** 🆕 Planned  
**Effort:** M (3-5 days)  
**Value:** High

**Description:**  
Integrate `audit-skill.sh` to scan individual skills for security issues (dangerous patterns, external links, obfuscation).

**User Story:**  
As a user, I want to see not just baseline changes, but actual security issues within skills (malware patterns, suspicious links), so I can catch malicious skills before they execute.

**Acceptance Criteria:**
- [ ] Run `audit-skill.sh` on each skill in baseline
- [ ] Parse exit codes (0=safe, 1=warnings, 2=critical)
- [ ] Show per-skill security status in UI
- [ ] Allow drill-down to see specific issues per skill
- [ ] Cache results (don't re-scan unchanged skills)

**Technical Notes:**
- Run in parallel for performance (52 skills)
- Store results in SecurityScanner state
- New issue type: `SkillSecurityIssue` with skillName + findings

---

#### F2: macOS Notifications
**Status:** 🆕 Planned  
**Effort:** S (1-2 days)  
**Value:** High

**Description:**  
Send macOS notification when critical issues are detected during background scans.

**User Story:**  
As a user, I want to be notified immediately when critical security issues are found, so I don't have to manually check the menu bar icon.

**Acceptance Criteria:**
- [ ] Notification when critical issues detected (not just warnings)
- [ ] Notification title shows issue count
- [ ] Click notification → opens popover with details
- [ ] Respect Do Not Disturb mode
- [ ] User preference to enable/disable notifications

**Technical Notes:**
- Use `UNUserNotificationCenter`
- Request permission on first launch
- Only notify on state change (safe → critical)
- Don't spam if already showing critical

---

#### F3: Settings Panel
**Status:** 🆕 Planned  
**Effort:** M (2-3 days)  
**Value:** Medium

**Description:**  
Add settings panel for configuration (scan frequency, notifications, checks to run).

**User Story:**  
As a user, I want to configure scan frequency and which checks to run, so I can balance security vs performance.

**Acceptance Criteria:**
- [ ] Settings window (⌘,) or menu item
- [ ] Scan interval slider (10min - 2hr, default 30min)
- [ ] Toggle: Enable/disable notifications
- [ ] Toggle: Enable/disable auto-scan on launch
- [ ] Toggle: Enable/disable baseline checking
- [ ] Toggle: Enable/disable skill security scanning (when F1 done)
- [ ] Save preferences to UserDefaults
- [ ] Apply settings without restart

**Technical Notes:**
- SwiftUI Settings scene
- Bind to @AppStorage for persistence
- Update timer interval dynamically

---

#### F4: Detailed Logs Viewer
**Status:** 🆕 Planned  
**Effort:** M (2-3 days)  
**Value:** Medium

**Description:**  
View full script output and scan history for debugging.

**User Story:**  
As a developer debugging issues, I want to see raw script output and scan history, so I can understand why a check failed.

**Acceptance Criteria:**
- [ ] "View Logs" button in popover
- [ ] Show last N scans with timestamps
- [ ] Expand to see full script stdout/stderr
- [ ] Filter by: all / errors only / warnings only
- [ ] Export logs to file
- [ ] Persistent logging with `os_log`

**Technical Notes:**
- New `ScanHistory` model (timestamp, output, issues)
- Store last 50 scans in-memory
- Log to system with subsystem: "com.artificialguven.openclawshield"

---

### P2 - Medium Priority

#### F5: Auto-Fix Actions
**Status:** 🆕 Planned  
**Effort:** M (3-4 days)  
**Value:** Medium

**Description:**  
One-click fixes for common issues (update baseline, ignore skill, etc.).

**User Story:**  
As a user, I want to fix common issues with one click, so I don't have to manually run terminal commands.

**Acceptance Criteria:**
- [ ] "Fix" button for baseline-related issues
- [ ] Action: Update baseline (`monitor-skills.sh --init`)
- [ ] Action: Ignore specific skill (add to ignore list)
- [ ] Confirmation dialog before destructive actions
- [ ] Show result (success/failure) with feedback
- [ ] Update UI immediately after fix

**Technical Notes:**
- Run scripts with proper error handling
- Async execution (don't block UI)
- Show progress indicator during fix
- Re-scan after successful fix

---

#### F6: JSON Output Parsing
**Status:** 🆕 Planned  
**Effort:** S (1-2 days)  
**Value:** Low (nice to have)

**Description:**  
Use JSON output from scripts instead of text parsing for robustness.

**User Story:**  
As a maintainer, I want structured output from scripts, so parsing is less fragile to format changes.

**Acceptance Criteria:**
- [ ] Modify `monitor-skills.sh` to support `--json` flag
- [ ] Parse JSON instead of text in SecurityScanner
- [ ] More robust to format changes
- [ ] Extract richer data (file paths, hash changes, etc.)
- [ ] Backward compatible with text output (fallback)

**Technical Notes:**
- Add JSON mode to monitor-skills.sh
- Use `Codable` for parsing in Swift
- Keep text parsing as fallback for old scripts

---

#### F7: Export Report
**Status:** 🆕 Planned  
**Effort:** S (1 day)  
**Value:** Low

**Description:**  
Export current security report to file (text, JSON, HTML).

**User Story:**  
As a user, I want to export the report, so I can share with team or archive for compliance.

**Acceptance Criteria:**
- [ ] "Export" button in popover
- [ ] Format options: TXT, JSON, HTML
- [ ] Include: timestamp, status, all issues, suggested fixes
- [ ] Save file dialog with default name (openclawshield-YYYY-MM-DD.txt)
- [ ] Feedback on success

**Technical Notes:**
- Use NSSavePanel for save dialog
- HTML export with styled template
- JSON export matches script output format

---

### P3 - Low Priority (Future)

#### F8: Historical Trend Tracking
**Status:** 💡 Idea  
**Effort:** L (5-7 days)  
**Value:** Low

**Description:**  
Track security status over time, show graphs/trends.

**User Story:**  
As a user, I want to see trends (how many issues over time), so I can track if security is improving or degrading.

**Acceptance Criteria:**
- [ ] Store scan results to SQLite/Core Data
- [ ] Charts: issues over time (line graph)
- [ ] Stats: average issues per week, most common issue types
- [ ] Trend view in separate window
- [ ] Date range filter

---

#### F9: Real-Time Monitoring (FSEvents)
**Status:** 💡 Idea  
**Effort:** L (5-7 days)  
**Value:** Low

**Description:**  
Watch skills directory for changes in real-time (no timer needed).

**User Story:**  
As a user, I want instant detection of skill changes, not waiting for the next 30-minute scan.

**Acceptance Criteria:**
- [ ] Use FSEvents to watch `/usr/local/lib/node_modules/openclaw/skills/`
- [ ] Trigger scan immediately on file change
- [ ] Debounce rapid changes (wait 2s before scan)
- [ ] Optional: disable timer-based scans when FSEvents active
- [ ] Handle permissions properly

---

#### F10: Multi-Instance Detection
**Status:** 💡 Idea  
**Effort:** S (1 day)  
**Value:** Low

**Description:**  
Detect if app is already running, prevent duplicate instances.

**User Story:**  
As a user, I don't want multiple menu bar icons if I accidentally launch twice.

**Acceptance Criteria:**
- [ ] Check for existing instance on launch
- [ ] If found, focus existing instance and quit new one
- [ ] Use shared file lock or IPC

---

## 🎯 Release Planning

### v1.1.0 (Next Release)
**Target:** Q1 2026  
**Features:** F1, F2, F3  
**Focus:** Core enhancements (security scanning + notifications + settings)

### v1.2.0
**Target:** Q2 2026  
**Features:** F4, F5, F6  
**Focus:** Power user features (logs, auto-fix, robustness)

### v2.0.0
**Target:** Q3 2026  
**Features:** F7, F8, F9, F10  
**Focus:** Advanced features (export, trends, real-time, polish)

---

## 📊 Effort Estimates

- **Small (S):** 1-2 days
- **Medium (M):** 2-5 days
- **Large (L):** 5-7+ days

---

## 🔄 Process

For each feature:
1. **Analyst** reviews and enhances requirements
2. **Developer** implements with tests
3. **Tester** runs manual test checklist
4. **Security** reviews for vulnerabilities
5. **Merge** to main after all approvals

See CONTRIBUTING.md for full SDLC.
