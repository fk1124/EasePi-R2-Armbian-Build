#!/bin/bash
# ============================================================================
#  EasePi-R2 Armbian reproducible build helper
#
#  Usage:
#    bash build.sh [current|edge|vendor] [trixie|bookworm] [minimal|server|desktop]
#
#  Examples:
#    bash build.sh current trixie minimal
#    bash build.sh vendor bookworm minimal
#    BRANCH=edge RELEASE=trixie IMAGE_TYPE=server bash build.sh
#
#  Prerequisite:
#    Copy this kit's userpatches/ into the Armbian build directory, or place
#    this kit beside the build/ directory.
# ============================================================================

set -euo pipefail

BOARD="${BOARD:-easepi-r2}"
BRANCH="${1:-${BRANCH:-current}}"
RELEASE="${2:-${RELEASE:-trixie}}"
IMAGE_TYPE="${3:-${IMAGE_TYPE:-minimal}}"

case "${BRANCH}" in
    current|edge|vendor)
        ;;
    legacy)
        echo "ERROR: legacy branch is not supported by this EasePi-R2 kit yet."
        exit 1
        ;;
    *)
        echo "ERROR: unsupported BRANCH: ${BRANCH}"
        echo "Usage: bash build.sh [current|edge|vendor] [trixie|bookworm] [minimal|server|desktop]"
        exit 1
        ;;
esac

case "${IMAGE_TYPE}" in
    minimal)
        BUILD_DESKTOP=no
        BUILD_MINIMAL=yes
        ;;
    server)
        BUILD_DESKTOP=no
        BUILD_MINIMAL=no
        ;;
    desktop)
        BUILD_DESKTOP=yes
        BUILD_MINIMAL=no
        ;;
    *)
        echo "ERROR: unsupported IMAGE_TYPE: ${IMAGE_TYPE}"
        echo "Usage: bash build.sh [current|edge|vendor] [trixie|bookworm] [minimal|server|desktop]"
        exit 1
        ;;
esac

# ---- Locate Armbian build directory ----
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR=""

if [ -n "${ARMBIAN_BUILD_DIR:-}" ] && [ -f "${ARMBIAN_BUILD_DIR}/compile.sh" ]; then
    BUILD_DIR="${ARMBIAN_BUILD_DIR}"
elif [ -d "${SCRIPT_DIR}/../build" ] && [ -f "${SCRIPT_DIR}/../build/compile.sh" ]; then
    BUILD_DIR="${SCRIPT_DIR}/../build"
elif [ -d "${HOME}/rk3588_build/build" ] && [ -f "${HOME}/rk3588_build/build/compile.sh" ]; then
    BUILD_DIR="${HOME}/rk3588_build/build"
fi

if [ -z "${BUILD_DIR}" ] || [ ! -f "${BUILD_DIR}/compile.sh" ]; then
    echo "ERROR: Cannot find Armbian build directory."
    echo "Set ARMBIAN_BUILD_DIR or place this kit beside an Armbian 'build/' directory."
    echo "Example:"
    echo "  export ARMBIAN_BUILD_DIR=/home/user/rk3588_build/build"
    exit 1
fi

# ---- Ensure userpatches are available in build tree ----
if [ ! -f "${BUILD_DIR}/userpatches/config/boards/easepi-r2.conf" ]; then
    echo "ERROR: easepi-r2.conf not found in ${BUILD_DIR}/userpatches/."
    echo "Copy this kit's userpatches/ into the Armbian build directory first:"
    echo "  rsync -a ${SCRIPT_DIR}/userpatches/ ${BUILD_DIR}/userpatches/"
    exit 1
fi

cd "${BUILD_DIR}"

# ---- Build environment safety defaults ----
export PESTER_TERMINAL=no
export WT_SESSION=1
export ALLOW_ROOT=yes
export GIT_TERMINAL_PROMPT=0
export SKIP_ORAS=yes

git config --global core.askPass '' 2>/dev/null || true
git config --global credential.helper '' 2>/dev/null || true

# ---- Clean broken U-Boot worktree, if a previous build failed midway ----
if [ -f "cache/git-bare/u-boot/.git/armbian-bare-tree-done" ]; then
    if [ ! -d "cache/git-bare/u-boot/.git/worktrees/v2025.10" ] || \
       [ ! -f "cache/git-bare/u-boot/.git/worktrees/v2025.10/gitdir" ]; then
        echo "Detected broken U-Boot worktree, cleaning..."
        rm -rf cache/git-bare/u-boot
        rm -rf cache/sources/u-boot-worktree
        rm -rf cache/memoize/git2info/*
    fi
fi

echo "============================================"
echo "  EasePi-R2 Armbian Firmware Build"
echo "============================================"
echo "Build directory: ${BUILD_DIR}"
echo "Build Configuration:"
echo "  BOARD       = ${BOARD}"
echo "  BRANCH      = ${BRANCH}"
echo "  RELEASE     = ${RELEASE}"
echo "  IMAGE_TYPE  = ${IMAGE_TYPE}"
echo "  DESKTOP     = ${BUILD_DESKTOP}"
echo "  MINIMAL     = ${BUILD_MINIMAL}"
echo "  U-Boot      = mainline v2025.10 for current/edge, vendor default for vendor"
echo "  Kernel Git  = shallow"
echo "  ORAS        = disabled"
echo "  ccache      = enabled"
echo "  Threads     = $(nproc)"
echo ""

echo "Starting build..."
echo ""

set +e
yes "" | ./compile.sh \
    BOARD="${BOARD}" \
    BRANCH="${BRANCH}" \
    RELEASE="${RELEASE}" \
    BUILD_DESKTOP="${BUILD_DESKTOP}" \
    BUILD_MINIMAL="${BUILD_MINIMAL}" \
    KERNEL_CONFIGURE=no \
    KERNEL_GIT=shallow \
    SKIP_ORAS=yes \
    USE_CCACHE=yes \
    CPUTHREADS="$(nproc)" \
    UBOOT_MIRROR=github \
    REGIONAL_MIRROR=china
BUILD_EXIT=$?
set -e

echo ""
echo "============================================"
if [ "${BUILD_EXIT}" -eq 0 ]; then
    echo "  BUILD SUCCESS!"
    echo "============================================"
    echo "Output images:"
    ls -lh output/images/ 2>/dev/null | grep -v "^total" || true
    echo ""
    echo "Output debs:"
    ls -lh output/debs/ 2>/dev/null | grep -v "^total" || true
else
    echo "  BUILD FAILED (exit code: ${BUILD_EXIT})"
    echo "============================================"
    echo "Recent logs:"
    ls -lt output/logs/*.log 2>/dev/null | head -3 || true
fi

exit "${BUILD_EXIT}"
