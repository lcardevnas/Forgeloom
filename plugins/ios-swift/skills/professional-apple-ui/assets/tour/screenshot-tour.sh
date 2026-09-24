#!/usr/bin/env bash
# Runs ScreenshotTourUITests and exports its screenshots to screenshots/<timestamp>/.
# Copied from Forgeloom's professional-apple-ui skill; set the four values below once per project.
#
# Usage: scripts/screenshot-tour.sh [-m modes] [section ...]
#   -m      comma-separated modes: light, dark, locale (second language, light), ax (largest
#           Dynamic Type, iOS). Default: light,dark.
#   section the sections listed in ScreenshotTourUITests.sections. Default: all.
#           Run only the sections whose screens the change touched.
# Examples:
#   scripts/screenshot-tour.sh settings
#   scripts/screenshot-tour.sh -m light,dark,locale home library
set -euo pipefail
cd "$(dirname "$0")/.."

PROJECT="MyApp/MyApp.xcodeproj"          # or use WORKSPACE="…xcworkspace" and change the xcodebuild line
SCHEME="MyApp"
UI_TEST_TARGET="MyAppUITests"
DESTINATION="platform=macOS"             # iOS: "platform=iOS Simulator,name=iPhone 17 Pro"

modes="light,dark"
if [[ "${1:-}" == "-m" ]]; then modes="$2"; shift 2; fi
sections=$(IFS=,; echo "$*")

only=()
for mode in ${modes//,/ }; do
  case "$mode" in
    light) only+=("-only-testing:$UI_TEST_TARGET/ScreenshotTourUITests/testTourLight") ;;
    dark) only+=("-only-testing:$UI_TEST_TARGET/ScreenshotTourUITests/testTourDark") ;;
    locale) only+=("-only-testing:$UI_TEST_TARGET/ScreenshotTourUITests/testTourSecondLanguage") ;;
    ax) only+=("-only-testing:$UI_TEST_TARGET/ScreenshotTourUITests/testTourLargestText") ;;
    *) echo "Unknown mode: $mode" >&2; exit 1 ;;
  esac
done

out="screenshots/$(date +%Y%m%d-%H%M%S)"
result="$out/tour.xcresult"
mkdir -p "$out"

# TEST_RUNNER_ variables reach the UI test runner without the prefix.
TEST_RUNNER_TOUR_SECTIONS="$sections" xcodebuild -project "$PROJECT" -scheme "$SCHEME" \
  -destination "$DESTINATION" "${only[@]}" \
  -resultBundlePath "$result" test >"$out/xcodebuild.log" 2>&1 || echo "Tour finished with failures; see $out/xcodebuild.log"

xcrun xcresulttool export attachments --path "$result" --output-path "$out" >/dev/null
# Name each exported file after its attachment.
python3 - "$out" <<'PY'
import json, os, sys
out = sys.argv[1]
manifest = json.load(open(os.path.join(out, "manifest.json")))
for test in manifest:
    for a in test.get("attachments", []):
        src = os.path.join(out, a["exportedFileName"])
        name = a.get("suggestedHumanReadableName", a["exportedFileName"])
        base = name.split("_0_")[0] if "_0_" in name else os.path.splitext(name)[0]
        if os.path.exists(src):
            os.rename(src, os.path.join(out, base + ".png"))
PY
rm -rf "$result"
echo "$out"
