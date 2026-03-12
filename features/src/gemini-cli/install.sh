#!/bin/sh
set -eu

# install.sh installs the Gemini CLI in the devcontainer

echo "Activating feature 'gemini-cli'"

# Verify Node.js and npm are available (should be installed by node feature)
if ! command -v node >/dev/null || ! command -v npm >/dev/null; then
    echo "ERROR: Node.js and npm are required but not found!"
    echo "Please add the Node.js feature before gemini-cli in your devcontainer.json"
    exit 1
fi

# Install Gemini CLI
# Use a root-owned cache dir to avoid seeding the user's ~/.npm with root-owned files
echo "Installing Gemini CLI..."
npm install -g @google/gemini-cli --cache /root/.npm

# Verify installation
if command -v gemini >/dev/null; then
    echo "Gemini CLI installed successfully!"
    gemini --version
else
    echo "ERROR: Gemini CLI installation failed!"
    exit 1
fi

# Fix NVM permissions for non-root users
# The node devcontainer feature installs NVM as root. Give the container user
# ownership of the entire NVM directory so NVM can manage versions on terminal open.
# Without this: "rm: cannot remove .../nvm/current: Permission denied"
USERNAME="${USERNAME:-root}"
if [ "${USERNAME}" != "root" ]; then
    if [ -n "${NVM_DIR:-}" ] && [ -d "${NVM_DIR}" ]; then
        echo "Fixing NVM permissions for user ${USERNAME}..."
        chown -R "${USERNAME}:" "${NVM_DIR}"
    elif [ -d "/usr/local/share/nvm" ]; then
        echo "Fixing NVM permissions for user ${USERNAME}..."
        chown -R "${USERNAME}:" "/usr/local/share/nvm"
    fi

    # Fix npm cache ownership: npm install -g (run as root) can seed the user's
    # ~/.npm cache with root-owned files, breaking npm for the non-root user.
    USER_HOME=$(eval echo "~${USERNAME}" 2>/dev/null || echo "/home/${USERNAME}")
    if [ -d "${USER_HOME}/.npm" ]; then
        echo "Fixing npm cache ownership for user ${USERNAME}..."
        chown -R "${USERNAME}:" "${USER_HOME}/.npm"
    fi
fi
