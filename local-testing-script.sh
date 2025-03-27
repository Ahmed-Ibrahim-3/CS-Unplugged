#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "Setting up local test environment..."
rm -rf iOSTestResults.xcresult
rm -rf tvOSTestResults.xcresult

# Build for tvOS
echo "Building and testing for tvOS..."
xcodebuild test -scheme unpluggedCS  -enableCodeCoverage YES -destination 'platform=tvOS Simulator,name=Apple TV' \
  -resultBundlePath tvOSTestResults.xcresult

#  
## Build for iOS
#echo "Building and testing for iOS..."
#xcodebuild test -scheme unpluggedCS -enableCodeCoverage YES -destination "platform=iOS Simulator,name=iPad Air 11-inch (M2)"\
#  -resultBundlePath iOSTestResults.xcresult
#


echo "All tests passed!"
