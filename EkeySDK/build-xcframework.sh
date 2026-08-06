#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")"

rm -rf build "../EkeySDK.xcframework"

build_platform() {
  platform_name="$1"
  destination="$2"
  config="$3"
  derived_data="build/DerivedData-${platform_name}"

  xcodebuild archive \
    -scheme EkeySDK \
    -destination "$destination" \
    -archivePath "build/EkeySDK-${platform_name}" \
    -derivedDataPath "$derived_data" \
    SKIP_INSTALL=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES

  # xcodebuild archive on an SPM library target emits the .swiftmodule into DerivedData's
  # BuildProductsPath rather than inside EkeySDK.framework's own Modules/ folder, unlike a
  # native Xcode Framework target. Without it nested there, the framework bundle has no
  # module interface and consumers get "no such module 'EkeySDK'" on import. Each platform
  # gets its own -derivedDataPath above: sharing one across both archives left only the
  # most-recently-built platform's BuildProductsPath entry in place.
  framework="build/EkeySDK-${platform_name}.xcarchive/Products/usr/local/lib/EkeySDK.framework"
  swiftmodule="$derived_data/Build/Intermediates.noindex/ArchiveIntermediates/EkeySDK/BuildProductsPath/${config}/EkeySDK.swiftmodule"

  if [ ! -d "$swiftmodule" ]; then
    echo "ERROR: expected EkeySDK.swiftmodule not found at $swiftmodule — aborting before touching $framework/Modules" >&2
    exit 1
  fi
  if [ ! -d "$framework" ]; then
    echo "ERROR: expected framework not found at $framework — aborting" >&2
    exit 1
  fi

  mkdir -p "$framework/Modules"
  cp -R "$swiftmodule/." "$framework/Modules/EkeySDK.swiftmodule/"
}

build_platform "iOS" "generic/platform=iOS" "Release-iphoneos"
build_platform "iOSSimulator" "generic/platform=iOS Simulator" "Release-iphonesimulator"

xcodebuild -create-xcframework \
  -framework "build/EkeySDK-iOS.xcarchive/Products/usr/local/lib/EkeySDK.framework" \
  -debug-symbols "$(pwd)/build/EkeySDK-iOS.xcarchive/dSYMs/EkeySDK.framework.dSYM" \
  -framework "build/EkeySDK-iOSSimulator.xcarchive/Products/usr/local/lib/EkeySDK.framework" \
  -debug-symbols "$(pwd)/build/EkeySDK-iOSSimulator.xcarchive/dSYMs/EkeySDK.framework.dSYM" \
  -output "build/EkeySDK.xcframework"

mv build/EkeySDK.xcframework ..
rm -rf build

echo "Done: EkeySDK.xcframework generated at $(cd .. && pwd)/EkeySDK.xcframework"
