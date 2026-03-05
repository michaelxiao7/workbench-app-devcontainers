#!/usr/bin/env bash

# install.sh installs the Gemini CLI in the devcontainer

set -o errexit
set -o nounset
set -o pipefail
set -o xtrace

readonly USERNAME="${USERNAME:-"root"}"
USER_HOME_DIR="${USERHOMEDIR:-"/home/${USERNAME}"}"
if [[ "${USER_HOME_DIR}" == "/home/root" ]]; then
    USER_HOME_DIR="/root"
fi
readonly USER_HOME_DIR

export DEBIAN_FRONTEND=noninteractive
export TZ=Etc/UTC

function apt_get_update() {
    if [ "$(find /var/lib/apt/lists/* | wc -l)" = "0" ]; then
        apt-get update -y
    fi
}

function check_packages() {
    if ! dpkg -s "$@" > /dev/null 2>&1; then
        apt_get_update
        apt-get -y install --no-install-recommends "$@"
    fi
}

check_packages curl ca-certificates tmux

npm install -g @google/gemini-cli

# Wrap gemini in tmux so its TUI works in browser-based terminals (code-server,
# JupyterLab). No-op if already in a tmux session.
BASHRC="${USER_HOME_DIR}/.bashrc"
if [ -f "${BASHRC}" ] && ! grep -q 'function gemini' "${BASHRC}"; then
    cat >> "${BASHRC}" << 'EOF'
function gemini() {
    if [ -z "$TMUX" ]; then
        tmux new-session -A -s "gemini" -- "$(command -v gemini)" "$@"
    else
        command gemini "$@"
    fi
}
EOF
fi

# Fix NVM ownership so the container user can manage the active-version symlink.
chown -R "${USERNAME}:${USERNAME}" /usr/local/share/nvm 2>/dev/null || true
