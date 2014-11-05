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

    Required volumes:
      /mirror     For the AOSP mirror (see create-mirror)

    Creates a mirror of the AOSP source tree into /mirror.

  checkout-branch [--no-mirror] <branch> [sync-options]

    Required volumes:
      /mirror     For the AOSP mirror (see create-mirror), unless
                  the --no-mirror option is given
      /aosp       For the AOSP branch checkout

    Checks out a specific branch from /mirror into /aosp.

  build-all <target> [make-options]

    Required volumes:
      /aosp       For the AOSP branch checkout (see checkout-branch)

    Builds everything in the /aosp source tree for <target> (use
    \`source build/envsetup.sh && lunch\` to check for available targets,
    which may change between SDK levels).

  build <target> <local-module> [make-options]

    Required volumes:
      /app        For your app code (i.e. an Android.mk containing folder)
      /aosp       For the AOSP branch checkout (see checkout-branch)
      /artifacts  For build artifacts

    Builds <local-module> for <target> (see \`lunch\`) after copying /app
    to /aosp/external/MY_<local-module>. <local-module> must not conflict
    with with any built-in project or your module will not build. The
    prefix is added so that even if you accidentally do use a built-in
    name, at the very least you won't overwrite the files. Note that
    <local-module> must match the LOCAL_MODULE value in your Android.mk
    exactly. You will also need to set `LOCAL_MODULE_TAGS := optional` in
    your Android.mk because the build system requires it.

    After a successful build any produced shared/static libraries
    and executables are copied to /artifacts.

    The first build may take a very, very long time as many dependencies
    may have to be built before <local-module>.

    You should use the 'jdk6' tag for Android 4.4 and lower. For newer
    versions you have to use the 'jdk7' tag.

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
    if [ "$2" == "--no-mirror" ]; then
      manifest="https://android.googlesource.com/platform/manifest"
      shift
    else
      manifest="$MIRROR_PATH/platform/manifest.git"
    fi
    branch="$2"
    shift; shift
    cd "$AOSP_PATH"
    test -d .repo || repo init -u "$manifest" -b "$branch"
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
    module_path="$AOSP_PATH/external/MY_$module/"
    rm -rf "$module_path"
    cp -R "$APP_PATH/" "$module_path"
    make "$module" -j $(nproc) "$@"
    artifacts=(
      "$OUT/obj/STATIC_LIBRARIES/${module}_intermediates/${module}.a"
      "$OUT/system/lib/${module}.so"
      "$OUT/system/lib64/${module}.so"
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
