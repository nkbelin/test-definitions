#!/bin/sh -ex

# shellcheck disable=SC1091
. ../../lib/sh-test-lib
# shellcheck disable=SC1091
. ../../lib/android-test-lib

export PATH=$PWD/platform-tools:$PATH
TIMEOUT="300"
TEST_URL="http://testdata.validation.linaro.org/cts/android-cts-7.1_r1.zip"
TEST_PARAMS="cts -m CtsBionicTestCases --abi arm64-v8a --disable-reboot --skip-preconditions --skip-device-info"
TEST_PATH="android-cts"
RESULT_FORMAT="aggregated"
RESULT_FILE="$(pwd)/output/result.txt"
export RESULT_FILE
# the default number of failed test cases to be printed
FAILURES_PRINTED="0"
# WIFI AP SSID
AP_SSID=""
# WIFI AP KEY
AP_KEY=""
DURATION="0"

usage() {
    echo "Usage: $0 [-o timeout] [-n serialno] [-c cts_url] [-t test_params] [-p test_path] [-r <aggregated|atomic>] [-f failures_printed] [-a <ap_ssid>] [-k <ap_key>]" 1>&2
    exit 1
}

while getopts ':o:n:c:t:p:r:f:a:k:d:' opt; do
    case "${opt}" in
        o) TIMEOUT="${OPTARG}" ;;
        n) export ANDROID_SERIAL="${OPTARG}" ;;
        c) TEST_URL="${OPTARG}" ;;
        t) TEST_PARAMS="${OPTARG}" ;;
        p) TEST_PATH="${OPTARG}" ;;
        r) RESULT_FORMAT="${OPTARG}" ;;
        f) FAILURES_PRINTED="${OPTARG}" ;;
        a) AP_SSID="${OPTARG}" ;;
        k) AP_KEY="${OPTARG}" ;;
        d) DURATION="${OPTARG}" ;;
        *) usage ;;
    esac
done

if [ -e "/home/testuser" ]; then
    export HOME=/home/testuser
fi

wait_boot_completed_fatal "${TIMEOUT}"

if [ $? -eq 0 ]; then
    lava-test-case "wait_booted" --result "pass"
    info_msg "Target booted up completely."
else
    lava-test-case "wait_booted" --result "fail"
    error_fatal "wait_boot_completed timed out."
fi
