#!/bin/sh
set -eu

# Function to install Gemini CLI
install_gemini_cli() {
    echo "Installing Gemini CLI..."
    # Use a root-owned cache dir to avoid seeding the user's ~/.npm with root-owned files
    npm install -g @google/gemini-cli --cache /root/.npm

    if command -v gemini >/dev/null; then
        echo "Gemini CLI installed successfully!"
        gemini --version
        return 0
    else
        echo "ERROR: Gemini CLI installation failed!"
        return 1
    fi
}

# Function to fix permissions for non-root users
fix_permissions() {
    local username="${1:-root}"

    if [ "${username}" = "root" ]; then
        return 0
    fi

    # Fix NVM permissions
    # The node devcontainer feature installs NVM as root. Give the container user
    # ownership of the entire NVM directory so NVM can manage versions on terminal open.
    # Without this: "rm: cannot remove .../nvm/current: Permission denied"
    local nvm_dir="${NVM_DIR:-/usr/local/share/nvm}"
    if [ -d "${nvm_dir}" ]; then
        echo "Fixing NVM permissions for user ${username}..."
        chown -R "${username}:" "${nvm_dir}"
    fi

    # Fix npm cache ownership
    # npm install -g (run as root) can seed the user's ~/.npm cache with root-owned files,
    # breaking npm for the non-root user.
    local user_home
    user_home=$(eval echo "~${username}" 2>/dev/null || echo "/home/${username}")
    if [ -d "${user_home}/.npm" ]; then
        echo "Fixing npm cache ownership for user ${username}..."
        chown -R "${username}:" "${user_home}/.npm"
    fi
}

# Print error message about requiring Node.js feature
print_nodejs_requirement() {
    cat <<EOF

ERROR: Node.js and npm are required but not found!
Please add the Node.js feature to your devcontainer.json:

  "features": {
    "ghcr.io/devcontainers/features/node:1": {},
    "./.devcontainer/features/gemini-cli": { "username": "your-user" }
  }

EOF
    exit 1
}

# Main script starts here
main() {
    echo "Activating feature 'gemini-cli'"

    # Verify Node.js and npm are available (should be installed by node feature)
    if ! command -v node >/dev/null || ! command -v npm >/dev/null; then
        print_nodejs_requirement
    fi

    # Install Gemini CLI
    install_gemini_cli || exit 1

    # Fix permissions for non-root users
    fix_permissions "${USERNAME:-root}"
}

# Execute main function
main
