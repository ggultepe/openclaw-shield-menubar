# Manual Test Checklist: Update Checker

Use this checklist after code changes to verify everything works.

---

## 🧪 Pre-Test Setup

```bash
# Verify environment
which openclaw  # Should return path
openclaw --version  # Note current version

which npm
npm --version

# Check gateway status
openclaw gateway status
```

---

## ✅ Basic Functionality Tests

### Test 1: App Launch & Initial Check
- [ ] Open app (menubar icon appears)
- [ ] Click icon → popover opens
- [ ] Update section shows:
  - [ ] Installed version (matches `openclaw --version`)
  - [ ] Latest version (from npm registry)
  - [ ] Last check time ("Just now")
- [ ] "Update Now" button state:
  - [ ] Enabled if update available
  - [ ] Disabled if versions match

**Expected:** No crashes, versions shown correctly

---

### Test 2: Manual Check
- [ ] Click "Check Now" button
- [ ] Button shows spinner
- [ ] "Last checked" updates to "Just now"
- [ ] Versions refresh

**Expected:** Check completes in <10 seconds

---

### Test 3: Update Installation (If Available)
**⚠️ Only test if a real update exists!**

- [ ] Click "Update Now" button
- [ ] Progress indicator shows
- [ ] Button disabled during update
- [ ] Update completes (or shows error)
- [ ] Success message appears
- [ ] Gateway warning shown if applicable

**Expected:** Update completes in <60 seconds

---

### Test 4: Notification
**Setup:** Trigger an update check when update available

- [ ] macOS notification appears:
  - Title: "OpenClaw Update Available"
  - Body: "Version X.Y.Z is now available (you have A.B.C)"
- [ ] Click notification → app opens
- [ ] Click "Update Now" action → update triggers

**Expected:** Notification appears once per version

---

### Test 5: Timer (Long Test)
**Setup:** Leave app running for 4+ hours OR modify timer interval to 2 minutes for testing

```swift
// In UpdateChecker.swift (for testing only!)
private let checkInterval: TimeInterval = 120 // 2 minutes
```

- [ ] Wait for timer interval
- [ ] Check runs automatically
- [ ] "Last checked" updates
- [ ] No UI glitches

**Expected:** Automatic check runs on schedule

---

## 🐛 Edge Case Tests

### Test 6: Network Offline
**Setup:** Disconnect from internet (turn off Wi-Fi)

- [ ] Click "Check Now"
- [ ] Error message: "Check failed (offline?)"
- [ ] App doesn't crash
- [ ] Installed version still shown

**Expected:** Graceful degradation

---

### Test 7: npm Not Found
**Setup:** Temporarily rename npm

```bash
sudo mv /usr/local/bin/npm /usr/local/bin/npm.bak
```

- [ ] Click "Check Now"
- [ ] Error message: "npm not found. Install from nodejs.org..."
- [ ] No crash

**Cleanup:**
```bash
sudo mv /usr/local/bin/npm.bak /usr/local/bin/npm
```

**Expected:** Helpful error message

---

### Test 8: openclaw Not Installed
**Setup:** Temporarily rename openclaw

```bash
sudo mv /usr/local/bin/openclaw /usr/local/bin/openclaw.bak
```

- [ ] Click "Check Now"
- [ ] Installed version shows: "Not installed"
- [ ] Latest version still fetched
- [ ] No crash

**Cleanup:**
```bash
sudo mv /usr/local/bin/openclaw.bak /usr/local/bin/openclaw
```

**Expected:** "Not installed" shown correctly

---

### Test 9: Rapid Clicks
- [ ] Click "Check Now" 10 times rapidly
- [ ] Only one check runs
- [ ] Button disabled during check
- [ ] No crashes or UI glitches

**Expected:** Concurrent checks prevented

---

### Test 10: Gateway Running Warning
**Setup:** Start gateway

```bash
openclaw gateway start
openclaw gateway status  # Verify running
```

- [ ] Click "Update Now" (if update available)
- [ ] Update completes
- [ ] Warning message: "⚠️ Gateway was running - restart it..."

**Cleanup:**
```bash
openclaw gateway restart  # If needed
```

**Expected:** User warned to restart gateway

---

## 🔬 Version Comparison Tests (Issue #1)

### Test 11: Pre-release Version Comparison
**Setup:** Mock version strings (modify code temporarily OR create unit test)

Test these comparisons:

| Installed | Latest | Expected Result | Your Result |
|-----------|--------|----------------|-------------|
| 2026.2.6 | 2026.2.7 | Update available | |
| 2026.2.6-beta.1 | 2026.2.6 | Update available | |
| 2026.2.6 | 2026.2.6-rc.1 | No update (release > pre) | |
| 2026.2.6+build.1 | 2026.2.6 | No update (equal) | |
| 2026.2.6-alpha | 2026.2.6-beta | Update available | |

**Expected:** All comparisons handle pre-release tags correctly

---

### Test 12: Unusual Version Formats
Test with:
- Version with 4+ parts: `2026.2.6.1`
- Version with letters: `2026.2.6a`
- Empty version: `""`
- Malformed: `v2026-02-06`

**Expected:** No crashes, sensible handling

---

## 🔒 Security Tests

### Test 13: Command Injection Attempt (Negative Test)
**Goal:** Verify no injection possible

These should NOT be testable via UI (no user input fields), but verify in code:

- [ ] Version strings are never passed to shell
- [ ] npm path is validated before use
- [ ] pgrep args are static (no interpolation)

**Expected:** No injection vectors found

---

### Test 14: Permission Denied
**Setup:** Make npm non-executable

```bash
sudo chmod -x /usr/local/bin/npm
```

- [ ] Click "Check Now"
- [ ] Error shown (not crash)

**Cleanup:**
```bash
sudo chmod +x /usr/local/bin/npm
```

**Expected:** Graceful error handling

---

### Test 15: Timeout Test
**Setup:** Create hanging script (simulate slow npm)

```bash
# Create fake npm that hangs
cat > /tmp/fake-npm << 'EOF'
#!/bin/bash
sleep 120  # Hang for 2 minutes
EOF
chmod +x /tmp/fake-npm

# Temporarily modify UpdateChecker to use /tmp/fake-npm
```

- [ ] Click "Check Now"
- [ ] Operation times out after ~10 seconds
- [ ] Error message shown
- [ ] No zombie processes (`ps aux | grep fake-npm`)

**Expected:** Timeout works, no hangs

---

## 📊 Regression Tests

### Test 16: Security Scanner Still Works
- [ ] Security scan runs on app launch
- [ ] Shield icon updates (green/yellow/red)
- [ ] Issue list populates
- [ ] "Refresh" button works

**Expected:** No interference from update checker

---

### Test 17: Memory Leak Test (Long Run)
**Setup:** Run app for 1 hour, check memory periodically

1. Launch app, note memory usage (Activity Monitor)
2. Trigger 10+ manual checks
3. Wait 1 hour (with periodic checks)
4. Check memory again

**Expected:**
- Memory < 100 MB throughout
- No gradual increase (leak)

---

### Test 18: App Quit During Update
**Setup:** Trigger update, then quit immediately

- [ ] Click "Update Now"
- [ ] Immediately: `Cmd+Q` or click "Quit"
- [ ] App quits
- [ ] Verify: npm process terminates (`ps aux | grep npm`)
- [ ] No corrupted files

**Expected:** Clean shutdown, no zombies

---

## ✨ UI/UX Tests

### Test 19: Layout & Styling
- [ ] Update section visually distinct (background color)
- [ ] Versions use monospace font
- [ ] "Update Available" badge shows when applicable
- [ ] Buttons aligned properly
- [ ] No text overflow or truncation

**Expected:** Professional appearance

---

### Test 20: Accessibility
- [ ] Button tooltips present
- [ ] VoiceOver can navigate UI
- [ ] Sufficient color contrast
- [ ] Icons have accessibility descriptions

**Expected:** Meets macOS accessibility standards

---

## 📝 Test Results Log

**Date:** ___________  
**Tester:** ___________  
**Build Version:** ___________

| Test # | Pass/Fail | Notes |
|--------|-----------|-------|
| 1 | ⬜ | |
| 2 | ⬜ | |
| 3 | ⬜ | |
| 4 | ⬜ | |
| 5 | ⬜ | |
| 6 | ⬜ | |
| 7 | ⬜ | |
| 8 | ⬜ | |
| 9 | ⬜ | |
| 10 | ⬜ | |
| 11 | ⬜ | |
| 12 | ⬜ | |
| 13 | ⬜ | |
| 14 | ⬜ | |
| 15 | ⬜ | |
| 16 | ⬜ | |
| 17 | ⬜ | |
| 18 | ⬜ | |
| 19 | ⬜ | |
| 20 | ⬜ | |

**Overall Pass Rate:** ___ / 20 (___%)

**Issues Found:**

**Verdict:**  ⬜ PASS  ⬜ PASS WITH CONCERNS  ⬜ FAIL

---

**Sign-off:** ___________________  Date: ___________
