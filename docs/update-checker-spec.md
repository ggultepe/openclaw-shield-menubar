# Feature Specification: OpenClaw Update Checker

## Overview

Add OpenClaw version monitoring and update triggering capabilities to the openclaw-shield menubar app.

## Requirements

### Functional Requirements

1. **Version Checking**
   - Check for OpenClaw updates every 4 hours automatically
   - Compare installed version vs latest available on npm
   - Store last check timestamp

2. **UI Display**
   - Show current installed OpenClaw version
   - Show latest available version
   - Show last check timestamp
   - Visual indicator when update is available (e.g., badge, different icon color)

3. **Notifications**
   - Push macOS notification when new version is detected
   - Notification should appear without user opening the app
   - Notification should be non-intrusive but visible

4. **Update Action**
   - "Update Now" button in the app UI
   - Button triggers `npm i -g openclaw@latest`
   - Show progress/status during update
   - Refresh version display after update completes

### Non-Functional Requirements

1. **Performance**
   - Version check should be lightweight (single npm registry call)
   - Should not block UI during check or update
   - Background timer should be efficient (not drain battery)

2. **Error Handling**
   - Handle offline scenarios gracefully
   - Handle npm registry timeouts
   - Handle permission errors during update

3. **Security**
   - No credentials stored
   - Update command runs with user permissions (may need sudo for global npm)
   - Validate version strings

## Technical Approach

### Version Check Method

```bash
# Get installed version
openclaw --version

# Get latest version from npm
npm show openclaw version
```

### Timer Implementation

- Use Swift `Timer` or `DispatchSourceTimer`
- 4-hour interval = 14400 seconds
- Persist last check time to UserDefaults
- Check on app launch if >4 hours since last check

### Notification Implementation

- Use `UserNotifications` framework
- Request notification permission on first launch
- Notification action: "Update Now" button

### Update Trigger

- Run update in background process
- Capture stdout/stderr for status
- Notify on completion (success/failure)

## UI Mockup (Text)

```
┌─────────────────────────────────────┐
│ OpenClaw Shield                     │
├─────────────────────────────────────┤
│ 🛡️ Security Status: ✅ All Clear   │
│ Skills tracked: 52                  │
├─────────────────────────────────────┤
│ 📦 OpenClaw Version                 │
│ Installed: 2026.2.6-3               │
│ Latest:    2026.2.9    🔴 Update!   │
│ Last check: 5 min ago               │
│                                     │
│ [🔄 Check Now]  [⬆️ Update Now]     │
├─────────────────────────────────────┤
│ [🔄 Refresh Security]  [⚙️ Settings]│
└─────────────────────────────────────┘
```

## Files to Modify/Create

1. **UpdateChecker.swift** (NEW)
   - Version checking logic
   - Timer management
   - Update execution

2. **ContentView.swift** (MODIFY)
   - Add version display section
   - Add update button
   - Add check now button

3. **OpenClawShieldMenuBarApp.swift** (MODIFY)
   - Initialize UpdateChecker
   - Request notification permissions

4. **Info.plist** (MODIFY)
   - Add notification entitlements if needed

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| npm not in PATH | Check for npm, show helpful error if missing |
| Update needs sudo | Detect if global npm needs elevated permissions, guide user |
| Rate limiting by npm registry | Cache results, respect rate limits |
| App sandbox restrictions | May need to run outside sandbox for shell access |

## Success Criteria

1. ✅ Version check runs every 4 hours automatically
2. ✅ UI shows current/latest version and last check time
3. ✅ macOS notification appears when update available
4. ✅ Update button successfully updates OpenClaw
5. ✅ All existing functionality still works (security scanning)

## Out of Scope

- Auto-update without user interaction
- Rollback to previous versions
- Beta/nightly channel support
- Update history tracking
