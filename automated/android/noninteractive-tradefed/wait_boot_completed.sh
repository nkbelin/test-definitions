#!/bin/sh -ex

# shellcheck disable=SC1091
. ../../lib/sh-test-lib
# shellcheck disable=SC1091
. ../../lib/android-test-lib

export PATH=$PWD/platform-tools:$PATH
TIMEOUT="300"

usage() {
    echo "Usage: $0 [-o timeout] [-n serialno]" 1>&2
    exit 1
}

while getopts ':o:n:' opt; do
    case "${opt}" in
        o) TIMEOUT="${OPTARG}" ;;
        n) export ANDROID_SERIAL="${OPTARG}" ;;
        *) usage ;;
    esac
done

timeout="${TIMEOUT}"
# shellcheck disable=SC2039
end=$(( $(date +%s) + timeout ))

# shellcheck disable=SC2039
boot_completed=false
while [ "$(date +%s)" -lt "$end" ]; do
    if adb shell getprop sys.boot_completed | grep "1"; then
        boot_completed=true
        break
    else
        sleep 3
    fi
done

if "${boot_completed}"; then
    info_msg "Target booted up completely."
    exit 0
else
    lava-test-case "wait_booted" --result "fail"
    info_msg "wait_boot_completed timed out."
    exit 1
fi
