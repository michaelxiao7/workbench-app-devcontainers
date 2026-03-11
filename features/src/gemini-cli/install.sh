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

echo "Installing Gemini CLI..."
npm install -g @google/gemini-cli

USERNAME="${USERNAME:-root}"

# The node devcontainer feature installs NVM as root. Give the container user
# ownership of the active-version symlink so NVM can update it on terminal open.
# Without this: "rm: cannot remove .../nvm/current: Permission denied"
chown "${USERNAME}" "${NVM_DIR:-/usr/local/share/nvm}/current" 2>/dev/null || true

# Gemini CLI's /ide install command looks for 'code' on PATH to install its
# companion extension. code-server uses a different binary name, so we create
# a 'code' shim that delegates to it. This suppresses the "VS Code CLI not
# found" error on first launch. Only created if code-server is present.
if [ -f /app/code-server/bin/code-server ] && [ ! -f /usr/local/bin/code ]; then
    ln -s /app/code-server/bin/code-server /usr/local/bin/code
fi
