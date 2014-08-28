#!/usr/bin/env bash

set -euo pipefail

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
    cd /mirror
    test -d .repo || repo init -u "$source" --mirror
    repo sync "$@"
    ;;
  checkout-branch)
    branch="$2"
    shift; shift
    test -d .repo || repo init -u /mirror/platform/manifest.git -b "$branch"
    repo sync "$@"
    ;;
  build-all)
    target="$2"
    shift; shift
    set +u
    source build/envsetup.sh
    lunch "$target"
    set -u
    make "$@"
    ;;
  build)
    target="$2"; module="$3"
    shift; shift; shift
    set +u
    source build/envsetup.sh
    lunch "$target"
    set -u
    module_path="/aosp/external/NOCONFLICT-$module/"
    rm -rf "$module_path"
    trap '{ rm -rf "$module_path"; }' EXIT
    cp -R /app/ "$module_path"
    make "$module" "$@"
    artifacts=(
      "$OUT/obj/STATIC_LIBRARIES/lib${module}_intermediates/lib${module}.a"
      "$OUT/system/lib/lib${module}.so"
      "$OUT/system/bin/$module"
    )
    for file in "${artifacts[@]}"; do
      if test -f "$file"; then
        cp "$file" /artifacts/
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
