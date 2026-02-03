# Build Guide

## ✅ Option 1: Automated (xcodegen - Recommended)

```bash
# Install xcodegen (one-time setup)
brew install xcodegen

# Generate Xcode project
cd ~/Projects/openclaw-shield-menubar
./create-xcode-project.sh

# Open in Xcode
open OpenClawShieldMenuBar.xcodeproj

# Build & Run (⌘R in Xcode)
```

## 📝 Option 2: Manual (Xcode)

### Step 1: Create New Project

1. Open **Xcode**
2. **File → New → Project...**
3. Select **macOS → App**
4. Click **Next**

### Step 2: Configure Project

- **Product Name:** `OpenClawShieldMenuBar`
- **Team:** (your Apple Developer account, or leave as None)
- **Organization Identifier:** `com.artificialguven` (or your own)
- **Bundle Identifier:** `com.artificialguven.openclawshield.menubar`
- **Interface:** **SwiftUI**
- **Language:** **Swift**
- **Storage:** None
- **Create Git repository:** ☐ (unchecked, we already have git)

Click **Next**, save to `~/Projects/openclaw-shield-menubar/`

### Step 3: Add Source Files

1. In Xcode **Project Navigator** (left sidebar):
   - Delete the generated `OpenClawShieldMenuBarApp.swift`
   - Delete the generated `ContentView.swift`

2. Right-click the `OpenClawShieldMenuBar` group
   - **Add Files to "OpenClawShieldMenuBar"...**
   - Navigate to `~/Projects/openclaw-shield-menubar/OpenClawShieldMenuBar/`
   - Select all 3 files:
     - `OpenClawShieldMenuBarApp.swift`
     - `ContentView.swift`
     - `SecurityScanner.swift`
   - ✅ **Copy items if needed**
   - ✅ **Create groups**
   - Click **Add**

### Step 4: Configure as Menu Bar App

1. Select the **project** (blue icon) in Project Navigator
2. Select the **target** (`OpenClawShieldMenuBar`)
3. Go to **Info** tab
4. Under **Custom macOS Application Target Properties**:
   - Find or add: `Application is agent (UIElement)`
   - Set value: **YES**
   
   *(This makes it a menu bar-only app with no Dock icon)*

Alternatively, right-click `Info.plist` in Project Navigator:
- **Open As → Source Code**
- Add this inside the main `<dict>`:

```xml
<key>LSUIElement</key>
<true/>
```

### Step 5: Build & Run

1. Select the run destination: **My Mac** (top toolbar)
2. Click **Run** button (▶) or press **⌘R**
3. Look for the shield icon in your menu bar! 🛡️

---

## 🎨 What You'll See

**Menu Bar Icon:**
- 🟢 Green checkmark shield = All secure
- 🟡 Yellow exclamation shield = Warnings
- 🔴 Red X shield = Critical issues
- ⚪ Gray question circle = Scanning/unknown

**Click the icon to see:**
- Security status summary
- List of issues (if any)
- Skill tracking count
- Manual refresh button
- Quit button

---

## 🔧 Troubleshooting

### App doesn't appear in menu bar
- Verify `LSUIElement = YES` in Info.plist
- Try **Product → Clean Build Folder** (⌘⇧K)
- Rebuild and run

### "Scripts not found" error
```bash
# Verify scripts exist
ls -la ~/clawd/scripts/monitor-skills.sh

# Make executable
chmod +x ~/clawd/scripts/*.sh
```

### "No baseline found" warning
```bash
# Initialize baseline
~/clawd/scripts/monitor-skills.sh --init
```

### Build errors
- Check minimum deployment target: **macOS 13.0+**
- Check Swift version: **5.9+**
- Clean build folder: **⌘⇧K**
- Delete Derived Data: **Xcode → Settings → Locations → Derived Data**

---

## 📦 Distribution (Future)

To distribute the app:

1. **Archive:**
   - **Product → Archive** in Xcode
   - Export as **macOS App** (not signed, for personal use)

2. **Or build from command line:**
```bash
xcodebuild -project OpenClawShieldMenuBar.xcodeproj \
  -scheme OpenClawShieldMenuBar \
  -configuration Release \
  build
```

3. Find the built app:
```bash
~/Library/Developer/Xcode/DerivedData/.../Build/Products/Release/OpenClawShieldMenuBar.app
```

---

## 🚀 Next Steps

1. **Add more checks:** Integrate audit-skill.sh for skill-level scanning
2. **Auto-fix buttons:** Implement safe auto-fixes for common issues
3. **Notifications:** Alert on critical findings
4. **Settings panel:** Configure scan frequency, enable/disable checks
5. **Detailed logs:** View full script output for debugging

---

Happy building! 🛡️
