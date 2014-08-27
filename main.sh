#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<USAGE
Usage: $0 <command>

Commands:

  create-mirror [sync-options]
    Creates a mirror of the AOSP source tree into /mirror.

  clone-branch <branch> [sync-options]
    Clone a specific branch from /mirror into /aosp.

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
    cd /mirror
    test -d .repo || repo init -u /mirror/platform/manifest.git -b "$branch"
    repo sync "$@"
    ;;
  build-all)
    target="$2"
    shift; shift
    source build/envsetup.sh
    lunch "$target"
    make "$@"
    ;;
  build)
    target="$2"; module="$3"
    shift; shift; shift
    source build/envsetup.sh
    lunch "$target"
    trap "{ rm -f /aosp/external/$module; exit 1 }" EXIT
    ln -s /app /aosp/external/"$module"
    make "$module" "$@"
    ;;
  help | "--help" | "-h")
    usage
    ;;
  *)
    usage
    exit 1
    ;;
esac
