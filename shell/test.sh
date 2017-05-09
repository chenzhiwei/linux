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

if app::has_ping; then
    echo there is ping
fi

app::component::stdout
app::component::stderr
