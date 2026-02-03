#!/bin/bash
# create-xcode-project.sh - Create Xcode project from source files

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_NAME="OpenClawShieldMenuBar"

echo "🔨 Creating Xcode project..."

cd "$PROJECT_DIR"

# Create Xcode project using xcodegen if available, otherwise provide instructions
if command -v xcodegen &> /dev/null; then
    cat > project.yml << EOF
name: $APP_NAME
options:
  bundleIdPrefix: com.artificialguven
  deploymentTarget:
    macOS: "13.0"
targets:
  $APP_NAME:
    type: application
    platform: macOS
    sources:
      - OpenClawShieldMenuBar
    info:
      path: Info.plist
      properties:
        LSUIElement: true
        CFBundleShortVersionString: "1.0"
        CFBundleVersion: "1"
    settings:
      PRODUCT_BUNDLE_IDENTIFIER: com.artificialguven.openclawshield.menubar
      MARKETING_VERSION: "1.0"
      CURRENT_PROJECT_VERSION: "1"
      MACOSX_DEPLOYMENT_TARGET: "13.0"
      SWIFT_VERSION: "5.9"
      ENABLE_PREVIEWS: YES
EOF
    
    xcodegen generate
    echo "✅ Xcode project created!"
    echo "📂 Open: open $APP_NAME.xcodeproj"
else
    echo "⚠️  xcodegen not found. Install with: brew install xcodegen"
    echo ""
    echo "Or create manually in Xcode:"
    echo "1. Open Xcode"
    echo "2. File → New → Project → macOS App"
    echo "3. Name: $APP_NAME"
    echo "4. Interface: SwiftUI, Language: Swift"
    echo "5. Replace generated files with our source files"
    echo "6. Set LSUIElement = true in Info.plist"
    echo ""
    echo "See SETUP.md for detailed instructions."
fi
