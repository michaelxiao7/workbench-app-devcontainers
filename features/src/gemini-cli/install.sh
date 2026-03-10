#!/usr/bin/env bash

# install.sh installs the Gemini CLI in the devcontainer

set -o errexit
set -o nounset
set -o pipefail
set -o xtrace

export DEBIAN_FRONTEND=noninteractive
export TZ=Etc/UTC

apt-get update -y
apt-get install -y --no-install-recommends curl ca-certificates

# Gemini CLI requires Node.js v20+. Use the NVM-managed node if available so
# we don't accidentally pick up an older system node (e.g. v18) from PATH.
NVM_DIR="${NVM_DIR:-/usr/local/share/nvm}"
if [ -s "${NVM_DIR}/nvm.sh" ]; then
    # shellcheck source=/dev/null
    . "${NVM_DIR}/nvm.sh"
fi

echo "Installing Gemini CLI..."
npm install -g @google/gemini-cli

USERNAME="${USERNAME:-root}"

# Fix NVM ownership so the container user can manage the active-version symlink.
# Without this, opening a new terminal prints a permission denied error.
chown -R "${USERNAME}:${USERNAME}" "${NVM_DIR}" 2>/dev/null || true
