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

npm install -g @google/gemini-cli

# Make it accessible to the specified user
if [ "${USERNAME}" != "root" ]; then
    chown -R "${USERNAME}:${USERNAME}" "$(npm root -g)" 2>/dev/null || true
fi

# Set TERM in the user's shell profile so TUI apps (like gemini) work correctly
# in web-based terminals (e.g. code-server, JupyterLab). Without this, browser
# terminals may swallow raw-mode keypresses and leave the TUI unresponsive.
BASHRC="${USER_HOME_DIR}/.bashrc"
if [ -f "${BASHRC}" ] && ! grep -q 'TERM=xterm-256color' "${BASHRC}"; then
    echo 'export TERM=xterm-256color' >> "${BASHRC}"
fi

# Fix NVM permissions so non-root users can manage the active-version symlink.
chmod -R a+rwX /usr/local/share/nvm 2>/dev/null || true
