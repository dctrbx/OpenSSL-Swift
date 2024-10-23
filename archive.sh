#!/bin/sh

# -------------- config --------------

# Uncomment for debugging
set -x

# Set bash script to exit immediately if any commands fail
set -e

# Variables
FRAMEWORK_NAME="OpenSSL_iOS"
TEMP_BUILD_PATH="./Build"
SIMULATOR_ARCHIVE_PATH="./Build/simulator.xcarchive"
DEVICE_ARCHIVE_PATH="./Build/device.xcarchive"
OUTPUT_PATH_DIR="./Product"

# For debugging
echo "Framework name: ${FRAMEWORK_NAME}"
echo "Build dir: ${TEMP_BUILD_PATH}"
echo "Simulator arch dir: ${SIMULATOR_ARCHIVE_PATH}"
echo "Device arch dir: ${DEVICE_ARCHIVE_PATH}"

# Remove product folder from previous version of framework
rm -rf "${OUTPUT_PATH_DIR}"

# Archive
xcodebuild archive -scheme ${FRAMEWORK_NAME} \
                    -configuration "release_iOS" \
                    -destination="simulator" \
                    -archivePath ${SIMULATOR_ARCHIVE_PATH} \
                    -sdk iphonesimulator \
                    SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES

xcodebuild archive -scheme ${FRAMEWORK_NAME} \
                    -configuration "release_iOS" \
                    -destination="device" \
                    -archivePath ${DEVICE_ARCHIVE_PATH} \
                    -sdk iphoneos \
                    SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES

# XCFramework
mkdir "${OUTPUT_PATH_DIR}"
xcodebuild  -create-xcframework \
            -framework ${SIMULATOR_ARCHIVE_PATH}/Products/Library/Frameworks/OpenSSL.framework \
            -framework ${DEVICE_ARCHIVE_PATH}/Products/Library/Frameworks/OpenSSL.framework \
            -output ${OUTPUT_PATH_DIR}/${FRAMEWORK_NAME}.xcframework

codesign --timestamp -v --sign "Apple Distribution: DOCTORBOX GmbH (RP55G543LZ)" ${OUTPUT_PATH_DIR}/${FRAMEWORK_NAME}.xcframework

# Cleanup
rm -rf "${TEMP_BUILD_PATH}"
open "${OUTPUT_PATH_DIR}"
