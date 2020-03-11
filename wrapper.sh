#!/usr/bin/env bash
set -o errexit          # Exit on most errors (see the manual)
set -o errtrace         # Make sure any error trap is inherited
set -o nounset          # Disallow expansion of unset variables
set -o pipefail         # Use last non-zero exit code in a pipeline

readonly SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

function main() {
    info "You have to create a file _run.sh and create this 'function main () {}' where you run your commands !"
}

function info() {
    echo "$( date )" "$*" >&2;
}

function error() {
    info "An Error occured"
}

function script_exit() {
    if [[ -d ${SCRIPT_LOCK} ]]; then
        info "Remove Lock"
        rmdir "$SCRIPT_LOCK"
    fi
    info "Exit"
}

# Load the script that ill be runing
source "$SCRIPT_DIR/_run.sh"

# Set Script Name if it is not set
if [[ ! -v SCRIPT_NAME ]]
then
    SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
fi

# Set Logpath to /tmp if it was not set
if [[ ! -v LOG_PATH ]]
then
    LOG_PATH="/tmp/${SCRIPT_NAME}.log"
fi
info "Log Path: ${LOG_PATH}"

# Output the log to the logfile
exec > >(tee -i -a ${LOG_PATH})
exec 2>&1

echo
echo
info "################# Starting ${SCRIPT_NAME} ####################"

# Set Error Handling
trap error ERR
trap script_exit EXIT

# Set Lock to prevent script from running twice
LOCK_DIR="/tmp/$SCRIPT_NAME.lock"
SCRIPT_LOCK=
if mkdir "$LOCK_DIR" 2> /dev/null; then
    readonly SCRIPT_LOCK="$LOCK_DIR"
    info "Set Lock: $SCRIPT_LOCK"
else
    info "Script already runnig."
    exit
fi

main