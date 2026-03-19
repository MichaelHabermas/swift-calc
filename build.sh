#!/usr/bin/env bash
# build.sh — Archive, export, notarize, and create a DMG.
#
# Required env vars:
#   VERSION            e.g. 1.0.0
#   SIGNING_IDENTITY   e.g. "Developer ID Application: Your Name (TEAMID)"
#   NOTARYTOOL_PROFILE Apple notarytool stored credential profile name
#
# Usage:
#   VERSION=1.0.0 SIGNING_IDENTITY="Developer ID Application: ..." \
#   NOTARYTOOL_PROFILE=my-profile ./build.sh

set -euo pipefail

VERSION="${VERSION:?VERSION env var is required}"
SIGNING_IDENTITY="${SIGNING_IDENTITY:?SIGNING_IDENTITY env var is required}"
NOTARYTOOL_PROFILE="${NOTARYTOOL_PROFILE:-notarytool-profile}"

SCHEME="TitleRedactedCalc"
PROJECT="TitleRedactedCalc.xcodeproj"
ARCHIVE_PATH="dist/${SCHEME}.xcarchive"
EXPORT_PATH="dist/export"
APP_PATH="${EXPORT_PATH}/${SCHEME}.app"
DMG_NAME="${SCHEME}-${VERSION}.dmg"
DMG_PATH="dist/${DMG_NAME}"

mkdir -p dist

echo "==> Archiving ${SCHEME} v${VERSION}…"
xcodebuild archive \
  -project "${PROJECT}" \
  -scheme "${SCHEME}" \
  -configuration Release \
  -archivePath "${ARCHIVE_PATH}" \
  CODE_SIGN_IDENTITY="${SIGNING_IDENTITY}" \
  DEVELOPMENT_TEAM="" \
  OTHER_CODE_SIGN_FLAGS="--timestamp" \
  | xcpretty || true

echo "==> Exporting archive…"
xcodebuild -exportArchive \
  -archivePath "${ARCHIVE_PATH}" \
  -exportPath "${EXPORT_PATH}" \
  -exportOptionsPlist ExportOptions.plist

echo "==> Creating DMG…"
hdiutil create \
  -volname "${SCHEME}" \
  -srcfolder "${APP_PATH}" \
  -ov \
  -format UDZO \
  "${DMG_PATH}"

echo "==> Signing DMG…"
codesign --sign "${SIGNING_IDENTITY}" --timestamp "${DMG_PATH}"

echo "==> Submitting for notarization…"
xcrun notarytool submit "${DMG_PATH}" \
  --keychain-profile "${NOTARYTOOL_PROFILE}" \
  --wait

echo "==> Stapling notarization ticket…"
xcrun stapler staple "${DMG_PATH}"

echo "==> Done: ${DMG_PATH}"
ls -lh "${DMG_PATH}"
