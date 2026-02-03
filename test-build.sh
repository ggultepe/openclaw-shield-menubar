#!/bin/bash
set -e

echo "🔨 Testing OpenClaw Shield MenuBar build..."
echo ""

cd "$(dirname "$0")"

# Ensure xcode-select points to full Xcode
if [[ "$(xcode-select -p)" != "/Applications/Xcode.app/Contents/Developer" ]]; then
    echo "⚠️  Switching xcode-select to full Xcode..."
    sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
    echo "✅ xcode-select updated"
    echo ""
fi

# Clean previous build
echo "🧹 Cleaning previous build..."
xcodebuild -project OpenClawShieldMenuBar.xcodeproj \
  -scheme OpenClawShieldMenuBar \
  -configuration Debug \
  clean > /dev/null 2>&1

echo "✅ Clean complete"
echo ""

# Build
echo "🔨 Building..."
xcodebuild -project OpenClawShieldMenuBar.xcodeproj \
  -scheme OpenClawShieldMenuBar \
  -configuration Debug \
  build 2>&1 | tee build.log

# Check result
if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo ""
    echo "✅ ✅ ✅ BUILD SUCCESSFUL ✅ ✅ ✅"
    echo ""
    echo "App built at:"
    echo "$(find ~/Library/Developer/Xcode/DerivedData -name "OpenClawShieldMenuBar.app" -type d 2>/dev/null | head -1)"
    exit 0
else
    echo ""
    echo "❌ ❌ ❌ BUILD FAILED ❌ ❌ ❌"
    echo ""
    echo "Errors from build.log:"
    grep "error:" build.log | head -10
    exit 1
fi
