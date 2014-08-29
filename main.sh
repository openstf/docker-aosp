#!/usr/bin/env bash

set -euo pipefail

AOSP_PATH=${AOSP_PATH:-/aosp}
APP_PATH=${APP_PATH:-/app}
ARTIFACTS_PATH=${ARTIFACTS_PATH:-/artifacts}
MIRROR_PATH=${MIRROR_PATH:-/mirror}

usage() {
  cat <<USAGE
Usage: $0 <command>

Commands:

  create-mirror [sync-options]
    Creates a mirror of the AOSP source tree into /mirror.

  checkout-branch <branch> [sync-options]
    Checks out a specific branch from /mirror into /aosp.

  build-all <target> [make-options]
    Builds everything in the /aosp source tree for <target> (see \`lunch\`).

  build <target> <local-module> [make-options]
    Builds <local-module> for <target> (see \`lunch\`) after adding /app
    to /aosp/external/<local-module>.

  help
    Shows this.
USAGE
}

command="$1"

case "$command" in
  create-mirror)
    source="https://android.googlesource.com/mirror/manifest"
    shift
    cd "$MIRROR_PATH"
    test -d .repo || repo init -u "$source" --mirror
    repo sync "$@"
    ;;
  checkout-branch)
    branch="$2"
    shift; shift
    cd "$AOSP_PATH"
    test -d .repo || repo init -u "$MIRROR_PATH/platform/manifest.git" -b "$branch"
    repo sync "$@"
    ;;
  build-all)
    target="$2"
    shift; shift
    cd "$AOSP_PATH"
    set +u
    source build/envsetup.sh
    lunch "$target"
    set -u
    make -j $(nproc) "$@"
    ;;
  build)
    target="$2"; module="$3"
    shift; shift; shift
    cd "$AOSP_PATH"
    set +u
    source build/envsetup.sh
    lunch "$target"
    set -u
    module_path="$AOSP_PATH/external/NOCONFLICT-$module/"
    rm -rf "$module_path"
    trap '{ rm -rf "$module_path"; }' EXIT
    cp -R "$APP_PATH/" "$module_path"
    make "$module" -j $(nproc) "$@"
    artifacts=(
      "$OUT/obj/STATIC_LIBRARIES/${module}_intermediates/${module}.a"
      "$OUT/system/lib/${module}.so"
      "$OUT/system/bin/$module"
    )
    for file in "${artifacts[@]}"; do
      if test -f "$file"; then
        cp "$file" "$ARTIFACTS_PATH/"
      fi
    done
    ;;
  help | "--help" | "-h")
    usage
    ;;
  *)
    usage
    exit 1
    ;;
esac
