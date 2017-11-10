#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

ROOT_PATH="$(cd "$(dirname "${BASH_SOURCE}")" && pwd -P)"
SUB_PATH="${SUB_PATH:-sub}"
FULL_PATH="${ROOT_PATH}/${SUB_PATH}"

readonly SERVICE_PORT=5600

function app::component::action() {
    local version=1.1.0
    if [[ "$version" == "1.1.0" ]]; then
        return $version
    fi
    return 0.0
}

function app::component::stdout() {
    cat <<EOF >&1

Hello stdout!

This is the FULL_PATH: ${FULL_PATH}

EOF
}

function app::component::stderr() {
    cat <<EOF >&2

Hello stderr!

This is the FULL_PATH: ${FULL_PATH}

EOF
}

function app::has_ping() {
    which ping &>/dev/null
}

function app::string_operation() {
    echo
    # string in array
    local str="are"
    local arr=(how are you)
    regx_arr=$(echo ${arr[@]} | sed 's/ /|/g')
    if [[ $str =~ ($regx_arr) ]]; then
        echo string is in an array
    fi
    if [[ $str =~ (how|are|you) ]]; then
        echo string is in an array
    fi
    echo
}

function app::array_operation() {
    local factor=(0:9 1:8 2:7 3:6 4:5)
    for fact in ${factor[@]}; do
        key=${fact%:*}
        value=${fact##*:}
        echo "key: $key, value: $value"
    done
    echo
    for fact in ${factor[@]}; do
        arr=(${fact//:/ })
        key=${arr[0]}
        value=${arr[1]}
        echo "key: $key, value: $value"
    done
    echo
    for fact in ${factor[@]}; do
        arr=${fact//:/ }
        set -- $arr
        key=$1
        value=$2
        echo "key: $key, value: $value"
    done
}


if app::has_ping; then
    echo there is ping
fi

app::component::stdout
app::component::stderr
app::array_operation
app::string_operation
