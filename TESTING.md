# Testing Guide

## ✅ Manual Testing Checklist

### Basic Functionality

**1. App Launch**
- [ ] App launches without errors
- [ ] Shield icon appears in menu bar
- [ ] Icon shows gray (unknown) initially

**2. Initial Scan**
- [ ] Scan runs automatically on launch
- [ ] Icon updates to green/yellow/red based on results
- [ ] Status shown in terminal if run from Xcode

**3. Click Icon**
- [ ] Popover appears below icon
- [ ] UI renders correctly (no layout issues)
- [ ] Status summary shows correct counts
- [ ] Issue list (if any) displays properly

**4. Manual Refresh**
- [ ] Click refresh button (circular arrow)
- [ ] Scan runs (shows loading state)
- [ ] Results update after scan completes
- [ ] Last scan time updates

**5. Periodic Scans**
- [ ] Wait 30 minutes (or modify timer interval for testing)
- [ ] Scan runs automatically
- [ ] UI updates if status changes

**6. Quit**
- [ ] Click "Quit" button
- [ ] App exits cleanly
- [ ] No zombie processes (check Activity Monitor)

---

### Edge Cases & Error Handling

**7. Missing Scripts**
```bash
# Temporarily rename script
mv ~/clawd/scripts/monitor-skills.sh ~/clawd/scripts/monitor-skills.sh.bak

# Launch app
# Expected: Critical issue "Monitor script not found"

# Restore
mv ~/clawd/scripts/monitor-skills.sh.bak ~/clawd/scripts/monitor-skills.sh
```

**8. Missing Baseline**
```bash
# Temporarily rename baseline
mv ~/clawd/memory/skills-baseline.txt ~/clawd/memory/skills-baseline.txt.bak

# Refresh scan
# Expected: Critical issue "Cannot read baseline"

# Restore
mv ~/clawd/memory/skills-baseline.txt.bak ~/clawd/memory/skills-baseline.txt
```

**9. Script Timeout**
```bash
# Create a hanging script (for testing only!)
cat > /tmp/hang-test.sh << 'EOF'
#!/bin/bash
sleep 60  # Hang for 60 seconds
EOF
chmod +x /tmp/hang-test.sh

# Temporarily modify SecurityScanner.swift scriptsPath to point to /tmp/hang-test.sh
# Expected: Script terminates after 30 seconds, app doesn't hang
```

**10. Large Output**
```bash
# Create script with massive output
cat > /tmp/spam-test.sh << 'EOF'
#!/bin/bash
for i in {1..100000}; do
  echo "Line $i"
done
EOF
chmod +x /tmp/spam-test.sh

# Test with modified scriptsPath
# Expected: Output limited to 1MB, no memory spike
```

**11. Permission Denied**
```bash
# Remove execute permission
chmod -x ~/clawd/scripts/monitor-skills.sh

# Refresh scan
# Expected: Error reported (exit code -1 or error message)

# Restore
chmod +x ~/clawd/scripts/monitor-skills.sh
```

**12. Custom CLAWD_HOME**
```bash
# Set custom path
export CLAWD_HOME=/tmp/test-clawd
mkdir -p /tmp/test-clawd/scripts
mkdir -p /tmp/test-clawd/memory

# Copy scripts
cp ~/clawd/scripts/monitor-skills.sh /tmp/test-clawd/scripts/
cp ~/clawd/memory/skills-baseline.txt /tmp/test-clawd/memory/

# Launch app with env var
# Expected: Uses /tmp/test-clawd paths instead of ~/clawd
```

---

### Issue Tracking

**13. New Skill Detected**
```bash
# Add a fake skill to trigger detection
mkdir -p /usr/local/lib/node_modules/openclaw/skills/test-skill
echo "---\nname: test\n---\n# Test" > /usr/local/lib/node_modules/openclaw/skills/test-skill/SKILL.md

# Refresh scan
# Expected: Warning "New skill detected: test-skill"

# Cleanup
rm -rf /usr/local/lib/node_modules/openclaw/skills/test-skill
```

**14. Modified Skill**
```bash
# Modify an existing skill to trigger detection
echo "# Modified" >> /usr/local/lib/node_modules/openclaw/skills/github/SKILL.md

# Refresh scan
# Expected: Critical issue "Modified skill: github"

# Restore (or update baseline)
~/clawd/scripts/monitor-skills.sh --init
```

**15. Issue Persistence**
```bash
# Create an issue (add fake skill)
mkdir -p /usr/local/lib/node_modules/openclaw/skills/fake-skill

# Refresh scan
# Expected: Warning appears

# Remove the fake skill
rm -rf /usr/local/lib/node_modules/openclaw/skills/fake-skill

# Refresh scan again
# Expected: Warning DISAPPEARS (not accumulated)
# This tests the critical bug fix!
```

---

### Memory & Performance

**16. Memory Leaks**
- [ ] Run app for 1 hour
- [ ] Check memory usage in Activity Monitor
- [ ] Memory should stay constant (not grow indefinitely)
- [ ] No retain cycles

**17. CPU Usage**
- [ ] Idle CPU usage should be near 0%
- [ ] CPU spike during scan is acceptable
- [ ] CPU returns to 0% after scan

**18. Multiple Scans**
- [ ] Run 10+ scans manually (click refresh repeatedly)
- [ ] Memory usage stays stable
- [ ] No crashes or hangs
- [ ] Issue counts reset properly each time

---

### UI/UX

**19. Status Icons**
- [ ] Green icon when no issues
- [ ] Yellow icon when warnings only
- [ ] Red icon when critical issues
- [ ] Gray icon during initial scan

**20. Popover Layout**
- [ ] All text readable (no truncation)
- [ ] Scrolling works for long issue lists
- [ ] Buttons clickable
- [ ] Colors match status (red/orange/green)

**21. Empty State**
- [ ] When no issues, shows checkmark + "All checks passed!"
- [ ] Last scan time displayed
- [ ] Professional appearance

**22. Loading State**
- [ ] Progress spinner shows during scan
- [ ] "Scanning..." text visible
- [ ] UI doesn't freeze

---

## 🧪 Automated Testing (Future)

### Unit Tests
```swift
// SecurityScanner tests
- testParseMonitorOutput_newSkill()
- testParseMonitorOutput_modifiedSkill()
- testParseMonitorOutput_removedSkill()
- testParseMonitorOutput_noChanges()
- testRunShellCommand_timeout()
- testRunShellCommand_largeOutput()
- testIssueAccumulation_cleared()

// Status calculation tests
- testUpdateOverallStatus_critical()
- testUpdateOverallStatus_warning()
- testUpdateOverallStatus_safe()
```

### Integration Tests
```swift
- testFullScan_withRealScript()
- testFullScan_scriptMissing()
- testFullScan_baselineMissing()
- testPeriodicScan_timer()
```

---

## 📊 Performance Benchmarks

### Expected Performance
- **App launch:** < 1 second
- **Initial scan:** 1-3 seconds (depends on script)
- **Memory (idle):** < 50 MB
- **Memory (peak):** < 100 MB
- **CPU (idle):** 0%
- **CPU (scanning):** < 20% for < 5 seconds

### Red Flags
- ❌ App launch > 5 seconds
- ❌ Memory > 200 MB
- ❌ CPU > 50% while idle
- ❌ Scan hangs forever (timeout not working)

---

## 🐛 Known Limitations

1. **Text parsing** - If `monitor-skills.sh` output format changes significantly, parsing may break. Future: use JSON output.

2. **No notifications** - App doesn't send macOS notifications on critical findings. Manual check required.

3. **Single check** - Only runs `monitor-skills.sh`. Future: integrate `audit-skill.sh` for per-skill scanning.

4. **No logs** - No persistent logging. Debugging requires running from Xcode. Future: use `os_log`.

---

## ✅ Definition of Done

Before shipping:

- [ ] All manual tests pass
- [ ] No critical or important issues from Reviewer audit
- [ ] Memory stays < 100 MB after 1 hour
- [ ] CPU returns to 0% after scans
- [ ] No crashes or hangs during testing
- [ ] UI looks professional on multiple screen sizes
- [ ] Documentation complete (README, BUILD, SETUP, TESTING)
- [ ] Git history clean with meaningful commits

---

## 🚀 Ready for Production

Once all tests pass:

1. **Build release version:**
   ```bash
   xcodebuild -project OpenClawShieldMenuBar.xcodeproj \
     -scheme OpenClawShieldMenuBar \
     -configuration Release \
     clean build
   ```

2. **Test release build:**
   - Run from `~/Library/Developer/Xcode/DerivedData/.../Release/`
   - Verify all functionality works
   - Check code signing (if applicable)

3. **Package for distribution:**
   - Archive in Xcode (Product → Archive)
   - Export as macOS App
   - Create DMG or zip for distribution

4. **Final verification:**
   - Install on clean macOS system
   - Run through test checklist
   - Get user feedback
