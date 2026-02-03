# Contributing Guide

OpenClaw Shield Menu Bar - Development Lifecycle

---

## 🎯 Development Philosophy

**Quality over speed.** Every feature goes through the full SDLC:

1. **Analyst** - Scope & enhance requirements
2. **Developer** - Implement with unit tests
3. **Tester** - Manual QA checklist
4. **Security** - Vulnerability review
5. **Merge** - Only after all approvals

---

## 🔄 Full Development Lifecycle

### Phase 1: Planning (Analyst Agent)

**Inputs:**
- Feature description from FEATURES.md
- User stories
- Acceptance criteria (draft)

**Analyst Responsibilities:**
- Enhance requirements with edge cases
- Clarify ambiguities
- Add technical considerations
- Review for UX issues
- Define test scenarios
- Estimate effort more accurately

**Outputs:**
- Enhanced feature spec (create `docs/features/F{N}-{name}.md`)
- Detailed acceptance criteria
- Test scenarios
- UX mockups (if applicable)
- Technical design notes

**Example:**
```markdown
# Feature: F2 - macOS Notifications

## Enhanced Requirements
[Analyst adds edge cases]
- What if notification permission denied?
- What if Do Not Disturb is on?
- What if user clicks notification while app already open?
- How to handle notification spam (multiple scans finding same issue)?

## Test Scenarios
1. Happy path: permission granted, issue found, notification sent
2. Permission denied: graceful degradation, no crash
3. DND mode: notification queued for later
...
```

---

### Phase 2: Development (Developer Agent / Coder)

**Inputs:**
- Enhanced feature spec from Phase 1
- Acceptance criteria
- Test scenarios

**Developer Responsibilities:**
- Implement feature following Swift best practices
- Write unit tests (if applicable)
- Self-review against security checklist
- Document any deviations from spec
- Update CHANGELOG.md

**Outputs:**
- Feature branch: `feature/F{N}-{name}`
- Code implementation
- Unit tests (for logic-heavy features)
- Updated documentation

**Code Quality Standards:**
- Use Swift 5.9+ features (async/await, actors if needed)
- Follow SwiftUI best practices
- No force unwraps unless truly safe
- Proper error handling (no silent failures)
- Memory safety (weak self in closures)
- Threading safety (MainActor for UI updates)

---

### Phase 3: Testing (Tester Agent / QA)

**Inputs:**
- Feature branch
- Test scenarios from Phase 1
- Acceptance criteria

**Tester Responsibilities:**
- Run all test scenarios manually
- Test edge cases
- Test error paths
- Performance testing (memory, CPU)
- Integration testing (does it work with other features?)
- Regression testing (did we break anything?)

**Outputs:**
- Test report (create `test-reports/F{N}-test-report.md`)
- Bug list (if any)
- Performance metrics
- Screenshots/recordings (if applicable)

**Test Report Template:**
```markdown
# Test Report: F2 - macOS Notifications

## Test Environment
- macOS: 14.2
- Xcode: 15.1
- Build: Debug

## Test Results

### Scenario 1: Happy Path
✅ PASS - Notification sent when critical issue detected
✅ PASS - Click notification opens popover
⚠️  PARTIAL - Notification title truncated (>50 chars)

### Scenario 2: Permission Denied
❌ FAIL - App crashes when permission denied
Issue: Force unwrap on line 45

...

## Summary
- Pass: 8/10
- Fail: 2/10
- Blockers: 1 (crash on permission denied)
```

---

### Phase 4: Security Review (Reviewer Agent / Security)

**Inputs:**
- Feature branch
- Code implementation
- Test report

**Security Responsibilities:**
- Two-pass taint analysis (if applicable)
- Shell injection review (if executing commands)
- Path traversal review (if file operations)
- Memory safety review
- Thread safety review
- Privilege escalation review
- Data leakage review (logs, errors)

**Outputs:**
- Security review report (create `security-reviews/F{N}-security.md`)
- Issue list (Critical / Important / Minor)
- Approval status (Approve / Request Changes / Reject)

**Security Report Template:**
```markdown
# Security Review: F2 - macOS Notifications

## Review Summary
- Verdict: ✅ Approved with minor notes
- Security: ⭐⭐⭐⭐⭐ (5/5)

## Findings

### 🟡 Important
- Line 67: Notification body includes raw script output
  - Impact: Could leak sensitive paths
  - Fix: Sanitize or use generic message

### 🔵 Minor
- Consider rate limiting notifications (max 1/min)

## Approval
✅ Approved for merge after minor fix applied.
```

---

### Phase 5: Merge & Release

**Pre-Merge Checklist:**
- [ ] Analyst approved (enhanced spec complete)
- [ ] Developer self-reviewed
- [ ] Tester approved (all tests pass, no blockers)
- [ ] Security approved (no critical issues)
- [ ] CHANGELOG.md updated
- [ ] Documentation updated (if applicable)

**Merge Process:**
```bash
git checkout main
git pull origin main
git merge --no-ff feature/F{N}-{name}
git push origin main
git tag -a v1.{X}.0 -m "Release v1.{X}.0: {Feature Name}"
git push origin v1.{X}.0
```

---

## 🏷️ Branch Naming

- `feature/F{N}-{name}` - New features (e.g., `feature/F2-notifications`)
- `bugfix/{issue-id}-{desc}` - Bug fixes
- `hotfix/{desc}` - Critical production fixes
- `docs/{desc}` - Documentation only
- `refactor/{desc}` - Code refactoring

---

## 💬 Commit Messages

Follow conventional commits:

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation
- `test:` - Tests
- `refactor:` - Code refactoring
- `perf:` - Performance improvement
- `security:` - Security fix
- `chore:` - Maintenance

**Examples:**
```
feat(notifications): Add macOS notification support

- Request permission on first launch
- Send notification on critical issues only
- Click notification opens popover

Closes #F2
```

---

## 📊 Reporting & Tracking

### Feature Progress

Track in GitHub Issues with labels:
- `phase:planning` - Analyst working
- `phase:development` - Developer working
- `phase:testing` - Tester working
- `phase:security` - Security reviewing
- `phase:ready-to-merge` - All approvals complete

### Metrics

Track per feature:
- Time spent in each phase
- Bugs found in testing
- Security issues found
- Rework cycles

---

## 🎯 Priority & Scheduling

See FEATURES.md for priority framework and roadmap.

**Sprint Planning:**
- Sprint length: 1 week
- Capacity: 1-2 features per sprint (depends on size)
- Daily standup: Not applicable (async agent-based work)

---

## 🚀 Release Process

### Release Checklist

Before tagging release:
- [ ] All planned features merged
- [ ] All tests pass
- [ ] Security review complete
- [ ] CHANGELOG.md updated
- [ ] README.md updated (if needed)
- [ ] Build successful (./test-build.sh)
- [ ] Manual smoke test

### Versioning

Semantic versioning: `MAJOR.MINOR.PATCH`

- **MAJOR:** Breaking changes
- **MINOR:** New features (backward compatible)
- **PATCH:** Bug fixes

---

## 🐛 Bug Reports

Use GitHub Issues with template:

```markdown
## Bug Description
[Clear description]

## Steps to Reproduce
1. Launch app
2. Click refresh
3. ...

## Expected Behavior
[What should happen]

## Actual Behavior
[What actually happened]

## Environment
- macOS: 14.x
- App version: 1.x.x
- Logs: [paste relevant logs]

## Screenshots
[If applicable]
```

---

## 📚 Documentation Standards

- README.md - Overview, quick start
- BUILD.md - Build instructions
- TESTING.md - Test procedures
- FEATURES.md - Feature roadmap
- CHANGELOG.md - Version history

**Per-feature docs:**
- `docs/features/F{N}-{name}.md` - Enhanced spec (Analyst output)
- `test-reports/F{N}-test-report.md` - Test results (Tester output)
- `security-reviews/F{N}-security.md` - Security review (Security output)

---

## 🙏 Code of Conduct

- Be respectful (agents and humans!)
- Quality over speed
- Always follow the full SDLC (no shortcuts)
- Document decisions
- Test thoroughly
- Security first

---

## 🆘 Getting Help

- **Questions:** Open GitHub Discussion
- **Bugs:** GitHub Issues
- **Security:** Email artificialguven@gmail.com (do not open public issue)

---

**Built with 🧠 by Artificial Güven**
