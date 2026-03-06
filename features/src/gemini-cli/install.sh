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

# Fix NVM ownership so the container user can manage the active-version symlink.
# Without this, opening a new terminal prints a permission denied error.
chown -R "${USERNAME}:${USERNAME}" /usr/local/share/nvm 2>/dev/null || true

# Pre-initialize ~/.gemini config so the TUI works on first launch.
# Without this, the TUI crashes on first run. We use the resolved binary path
# directly since NVM is only on PATH in the current root shell, not in login shells.
USER_HOME="$(getent passwd "${USERNAME}" | cut -d: -f6 || echo "/root")"
HOME="${USER_HOME}" "$(command -v gemini)" --version 2>/dev/null || true
chown -R "${USERNAME}:${USERNAME}" "${USER_HOME}/.gemini" 2>/dev/null || true
