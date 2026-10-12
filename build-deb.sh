#!/usr/bin/env bash
set -o pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$PROJECT_DIR/build-logs"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
LOG_FILE="$LOG_DIR/build-$TIMESTAMP.txt"

mkdir -p "$LOG_DIR"
cd "$PROJECT_DIR" || exit 1

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
