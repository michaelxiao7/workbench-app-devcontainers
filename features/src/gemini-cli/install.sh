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

# Fix NVM directory permissions so non-root users can update the active-version
# symlink on terminal open. The node devcontainer feature installs NVM as root,
# causing "Permission denied" errors in the user's shell profile otherwise.
chmod -R a+rwX /usr/local/share/nvm 2>/dev/null || true
