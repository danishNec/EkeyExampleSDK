#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")"

rm -rf build "../EkeySDK.xcframework"

xcodebuild archive \
  -scheme EkeySDK \
  -destination "generic/platform=iOS" \
  -archivePath "build/EkeySDK-iOS" \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES

xcodebuild archive \
  -scheme EkeySDK \
  -destination "generic/platform=iOS Simulator" \
  -archivePath "build/EkeySDK-iOSSimulator" \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES

xcodebuild -create-xcframework \
  -framework "build/EkeySDK-iOS.xcarchive/Products/usr/local/lib/EkeySDK.framework" \
  -debug-symbols "$(pwd)/build/EkeySDK-iOS.xcarchive/dSYMs/EkeySDK.framework.dSYM" \
  -framework "build/EkeySDK-iOSSimulator.xcarchive/Products/usr/local/lib/EkeySDK.framework" \
  -debug-symbols "$(pwd)/build/EkeySDK-iOSSimulator.xcarchive/dSYMs/EkeySDK.framework.dSYM" \
  -output "build/EkeySDK.xcframework"

mv build/EkeySDK.xcframework ..
rm -rf build

echo "Done: EkeySDK.xcframework generated at $(cd .. && pwd)/EkeySDK.xcframework"
