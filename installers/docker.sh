#!/bin/bash
# docker.sh - Install Docker from official repository

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

install_docker() {
    _echo "installing Docker from official repository"
    if [[ "$pkgmgr" == "apt" ]]; then
        # ─── Docker for Debian/Ubuntu ───
        if should_run; then
            # Add Docker's official GPG key
            curl -fsSL "https://download.docker.com/linux/$DISTRO_ID/gpg" -o /etc/apt/keyrings/docker.asc
            chmod a+r /etc/apt/keyrings/docker.asc

            # Add Docker repository
            local distro
            distro=$(lsb_release -c | awk '{print $2}')
            echo "deb [arch=$ARCH_DEB signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/$DISTRO_ID $distro stable" | tee /etc/apt/sources.list.d/docker.list >/dev/null

            # Install Docker Engine
            apt update && apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
            systemctl enable --now docker
            log_message "SUCCESS" "Docker installed from official repository"
        else
            dry_print "Would add Docker GPG key and repository for $DISTRO_ID"
            dry_print "Would install: docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin"
            dry_print "Would enable docker service"
        fi
    elif [[ "$pkgmgr" == "dnf" ]]; then
        # ─── Docker for Fedora ───
        if should_run; then
            dnf config-manager addrepo --from-repofile https://download.docker.com/linux/fedora/docker-ce.repo
            dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
            systemctl enable --now docker
            log_message "SUCCESS" "Docker installed from official repository"
        else
            dry_print "Would add Docker CE repository for Fedora"
            dry_print "Would install: docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin"
            dry_print "Would enable docker service"
        fi
    else
        log_message "WARNING" "Docker installation not configured for $pkgmgr" "true"
    fi
}

# ─── Standalone mode ───
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    parse_installer_args "$@"
    init_installer_env
    install_docker
    log_message "SUCCESS" "Docker installation complete" "true"
fi
