# Setup Instructions

## Quick Start (Xcode)

1. **Open Xcode**
2. **File → New → Project**
3. Choose **macOS → App**
4. Project settings:
   - Product Name: `OpenClawShieldMenuBar`
   - Bundle Identifier: `com.artificialguven.openclawshield.menubar`
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Save to: `~/Projects/openclaw-shield-menubar/`

5. **Replace files:**
   - Delete the generated `OpenClawShieldMenuBarApp.swift`, `ContentView.swift`
   - Copy our files from `OpenClawShieldMenuBar/` folder into the Xcode project:
     - `OpenClawShieldMenuBarApp.swift`
     - `ContentView.swift`
     - `SecurityScanner.swift`

6. **Update Info.plist:**
   - In Xcode project navigator, select the project
   - Go to "Info" tab
   - Add: `Application is agent (UIElement)` = `YES`
     (This makes it a menu bar-only app with no Dock icon)

7. **Build & Run** (⌘R)

## Features

✅ **Status Monitoring**
- Green: All checks passed
- Yellow: Warnings found
- Red: Critical issues

✅ **Click to View**
- Full security report in popover
- Issue details with suggested fixes
- Skill tracking count

✅ **Auto-Scan**
- Runs every 30 minutes
- Manual refresh button
- Checks for skill changes

## Requirements

- macOS 13.0+ (Ventura)
- Xcode 14.0+
- Scripts installed at `~/clawd/scripts/`
- Baseline created: `~/clawd/scripts/monitor-skills.sh --init`

## Troubleshooting

**App doesn't appear in menu bar:**
- Check Info.plist has `LSUIElement = YES`
- Try restarting app

**Scripts not found:**
- Verify scripts exist: `ls ~/clawd/scripts/monitor-skills.sh`
- Make executable: `chmod +x ~/clawd/scripts/*.sh`

**No baseline:**
- Run: `~/clawd/scripts/monitor-skills.sh --init`
