#!/usr/bin/env bash
set -o pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$PROJECT_DIR/build-logs"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
LOG_FILE="$LOG_DIR/build-$TIMESTAMP.txt"

mkdir -p "$LOG_DIR"
cd "$PROJECT_DIR" || exit 1

# Synchronize Debian package version with the authoritative VERSION file.
APP_VERSION="$(head -n 1 "$PROJECT_DIR/VERSION" | tr -d '\r')"

if [[ ! "$APP_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "ERROR: Invalid VERSION file: $APP_VERSION" >&2
    exit 1
fi

# Debian packaging revision, independent of application version.
DEB_REVISION="$(cat "$PROJECT_DIR/DEB_REVISION" 2>/dev/null || echo 1)"

if [[ ! "$DEB_REVISION" =~ ^[1-9][0-9]*$ ]]; then
    echo "ERROR: Invalid DEB_REVISION: $DEB_REVISION" >&2
    exit 1
fi

PACKAGE_VERSION="${APP_VERSION}-${DEB_REVISION}"
CURRENT_PACKAGE_VERSION="$(dpkg-parsechangelog -S Version)"

if [[ "$CURRENT_PACKAGE_VERSION" != "$PACKAGE_VERSION" ]]; then
    export PACKAGE_VERSION
    python3 - <<'CHANGELOG'
from pathlib import Path
from datetime import datetime
from email.utils import format_datetime
import os

path = Path("debian/changelog")
content = path.read_text()
version = os.environ["PACKAGE_VERSION"]

if not content.startswith("browser-e8y6 ("):
    raise SystemExit("Unexpected Debian changelog format")

entry = (
    f"browser-e8y6 ({version}) noble; urgency=medium\n\n"
    f"  * Release browser:e8y6 {version.rsplit('-', 1)[0]}.\n\n"
    f" -- jpeevi <jpeevi@hotmail.com>  "
    f"{format_datetime(datetime.now().astimezone())}\n\n"
)

path.write_text(entry + content)
CHANGELOG
fi

echo "Application version: $APP_VERSION"
echo "Debian package version: $PACKAGE_VERSION"

echo "========================================"
echo " browser:e8y6 Debian Package Builder"
echo "========================================"
echo "Date: $(date)"
echo "Project: $PROJECT_DIR"
echo "OS: $(lsb_release -ds)"
echo "Architecture: $(dpkg --print-architecture)"
echo "Git commit: $(git rev-parse --short HEAD)"
echo "Log: $LOG_FILE"
echo

{
    echo "browser:e8y6 Build Log"
    echo "Date: $(date)"
    echo "OS: $(lsb_release -ds)"
    echo "Git commit: $(git rev-parse --short HEAD)"
    echo "========================================"

    dpkg-buildpackage -us -uc -b -j2
} > "$LOG_FILE" 2>&1

RESULT=$?

echo
if [ "$RESULT" -eq 0 ]; then
    echo "BUILD SUCCESSFUL"
    echo
    echo "Generated packages:"
    find "$PROJECT_DIR/.." -maxdepth 1 -name 'browser-e8y6*.deb' -printf '%f\n'
else
    echo "BUILD FAILED (exit code: $RESULT)"
    echo
    echo "Last 30 log lines:"
    tail -30 "$LOG_FILE"
fi

echo
echo "Complete build log: $LOG_FILE"

exit "$RESULT"
