
#!/usr/bin/env bash

set -Eeuo pipefail

# ============================================================
# browser:e8y6 - Local Development Utility
# Build, install, run, and inspect version
# ============================================================

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$PROJECT_DIR/build"
INSTALL_DIR="$PROJECT_DIR/local-install"
BROWSER_BIN="$INSTALL_DIR/bin/browser:e8y6"

PROFILE="browser-e8y6-dev"
BUILD_JOBS=4

cd "$PROJECT_DIR"

info() {
    printf '\n[ browser:e8y6 ] %s\n' "$*"
}

fail() {
    printf '\n[ browser:e8y6 ] ERROR: %s\n' "$*" >&2
    exit 1
}

check_tools() {
    for tool in cmake ninja git; do
        command -v "$tool" >/dev/null 2>&1 ||
            fail "Missing required tool: $tool"
    done

    [[ -f "$PROJECT_DIR/CMakeLists.txt" ]] ||
        fail "CMakeLists.txt not found."
}

configure() {
    info "Configuring project..."

    cmake -S "$PROJECT_DIR" \
          -B "$BUILD_DIR" \
          -G Ninja \
          -DCMAKE_BUILD_TYPE=Release \
          -DCMAKE_INSTALL_PREFIX="$INSTALL_DIR" \
          -DBUILD_TESTING=OFF \
          -DBUILD_PYTHON_SUPPORT=OFF
}

build() {
    check_tools
    configure

    info "Compiling with $BUILD_JOBS parallel jobs..."

    cmake --build "$BUILD_DIR" \
          --parallel "$BUILD_JOBS"

    info "Installing to $INSTALL_DIR..."

    cmake --install "$BUILD_DIR"

    info "Build and installation completed successfully."
}

version() {
    info "Version information"

    printf 'Project: browser:e8y6\n'

    if [[ -x "$BROWSER_BIN" ]]; then
        printf '\nApplication version:\n'
        "$BROWSER_BIN" --version
    else
        printf 'Application: Not yet built\n'
    fi

    if command -v git >/dev/null 2>&1; then
        printf '\nGit revision:\n'
        git -C "$PROJECT_DIR" describe \
            --tags --always --dirty 2>/dev/null || true

        printf '\nGit branch:\n'
        git -C "$PROJECT_DIR" branch \
            --show-current 2>/dev/null || true
    fi
}

run() {
    [[ -x "$BROWSER_BIN" ]] ||
        fail "Browser not found. Run ./dev.sh build first."

    export XDG_DATA_DIRS="$INSTALL_DIR/share:${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"

    version

    info "Launching browser:e8y6..."
    info "Profile: $PROFILE"

    exec "$BROWSER_BIN" --profile "$PROFILE"
}

clean() {
    info "Clean generated build files?"
    printf 'Directories:\n  %s\n  %s\n' \
        "$BUILD_DIR" "$INSTALL_DIR"

    read -r -p "Type YES to confirm: " answer

    if [[ "$answer" != "YES" ]]; then
        info "Cancelled."
        return
    fi

    rm -rf -- "$BUILD_DIR" "$INSTALL_DIR"

    info "Build files removed."
    info "Source code and browser profile preserved."
}

usage() {
    cat <<EOF

browser:e8y6 - Development Utility

Usage:
  ./dev.sh [command]

Commands:
  all       Configure, build, install, print version, run
  build     Configure, build and install
  run       Run the existing installed build
  version   Display application and Git version
  clean     Remove generated build and installation files
  help      Display this help

Default:
  ./dev.sh  Same as ./dev.sh all

EOF
}

case "${1:-all}" in
    all)
        build
        run
        ;;
    build)
        build
        version
        ;;
    run)
        run
        ;;
    version)
        version
        ;;
    clean)
        clean
        ;;
    help|-h|--help)
        usage
        ;;
    *)
        usage
        fail "Unknown command: $1"
        ;;
esac
