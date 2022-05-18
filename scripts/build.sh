#!/bin/bash

set -e

ROOT=$(git rev-parse --show-toplevel)

usage_exit() {
    echo "Usage: $0 [-r] [-o dir]" 1>&2
    exit 1
}

VERSION=debug
TARGET=x86_64-unknown-linux-gnu
while getopts ro:h OPT; do
    case $OPT in
        o) output=${OPTARG}
            ;;
        r) VERSION=release
            ;;
        h) usage_exit
            ;;
        \?) usage_exit
            ;;
    esac
done

shift $((OPTIND - 1))

OPTION=""
if [ ${VERSION} = release ]; then
    OPTION="--${VERSION}"
fi

OUTPUT=${output:-$ROOT/bin}
[ ! -d $OUTPUT ] && mkdir -p $OUTPUT

cargo build --target ${TARGET} ${OPTION} --bin youki
cargo build --target ${TARGET} ${OPTION} --bin integration_test
RUSTFLAGS="-Ctarget-feature=+crt-static" cargo build --target ${TARGET} ${OPTION} --bin runtimetest

mv ${ROOT}/target/${TARGET}/${VERSION}/{youki,integration_test,runtimetest} ${OUTPUT}/

exit 0
