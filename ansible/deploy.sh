#!/bin/bash
set -e

# Configuration
readonly MAIN_PLAYBOOK="playbooks/main-playbook.yml"
readonly NVIDIA_PLAYBOOK="playbooks/nvidia-drivers-toolkit.yml"
readonly DOCKER_PLAYBOOK="playbooks/docker.yml"
readonly OPENRAG_PLAYBOOK="playbooks/openrag.yml"
readonly INVENTORY_FILE="inventory.ini"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { printf "${GREEN}[INFO]${NC} %s\n" "$1"; }
warn() { printf "${YELLOW}[WARN]${NC} %s\n" "$1"; }
error() { printf "${RED}[ERROR]${NC} %s\n" "$1"; exit 1; }
header() { printf "${BLUE}%s${NC}\n" "$1"; }

# Check ansible
if ! command -v ansible &> /dev/null; then
    error "Ansible not installed. Install with: sudo apt install ansible"
fi

# Create inventory
create_inventory() {
    local type=$1
    cat > "$INVENTORY_FILE" << EOF
[gpu_servers]
$([ "$type" = "gpu" ] && echo "localhost ansible_connection=local")

[cpu_servers]
$([ "$type" = "cpu" ] && echo "localhost ansible_connection=local")

[openrag_servers:vars]
ansible_python_interpreter=/usr/bin/python3
EOF
    log "Created $type inventory"
}

# Deploy functions
deploy_local() {
    header "Deploy OpenRAG locally"
    echo "1) CPU-only  2) GPU-enabled"
    read -p "Choice: " choice
    [ "$choice" = "1" ] && create_inventory cpu || create_inventory gpu
    ansible-playbook -i "$INVENTORY_FILE" "$MAIN_PLAYBOOK" --ask-become-pass
}

deploy_remote() {
    [ ! -f "$INVENTORY_FILE" ] && error "$INVENTORY_FILE not found"
    ansible-playbook -i "$INVENTORY_FILE" "$MAIN_PLAYBOOK" --ask-become-pass
}

deploy_nvidia() {
    [ ! -f "$INVENTORY_FILE" ] && error "$INVENTORY_FILE not found"
    ansible-playbook -i "$INVENTORY_FILE" "$NVIDIA_PLAYBOOK" --ask-become-pass
}

deploy_docker() {
    [ ! -f "$INVENTORY_FILE" ] && error "$INVENTORY_FILE not found"
    ansible-playbook -i "$INVENTORY_FILE" "$DOCKER_PLAYBOOK" --ask-become-pass
}

deploy_openrag() {
    [ ! -f "$INVENTORY_FILE" ] && error "$INVENTORY_FILE not found"
    ansible-playbook -i "$INVENTORY_FILE" "$OPENRAG_PLAYBOOK" --ask-become-pass
}

# Service management
status() {
    ansible all -i "$INVENTORY_FILE" -m command -a "docker ps" 2>/dev/null || echo "No services running"
}

stop() {
    ansible all -i "$INVENTORY_FILE" -m shell -a "cd ~/openrag && docker compose down" 2>/dev/null || echo "Nothing to stop"
}

start() {
    ansible all -i "$INVENTORY_FILE" -m shell -a "cd ~/openrag && docker compose up -d" 2>/dev/null || echo "Deploy first"
}

# Menu
show_menu() {
    header "OpenRAG Deployment"
    echo "1) Deploy locally"
    echo "2) Deploy remotely"
    echo "3) Install NVIDIA only"
    echo "4) Install Docker only"
    echo "5) Deploy OpenRAG only"
    echo "6) Status"
    echo "7) Stop"
    echo "8) Start"
    echo "9) Exit"
    read -p "Choice [1-9]: " choice
}

main() {
    cd "$(dirname "$0")"
    
    if [ $# -eq 0 ]; then
        while true; do
            show_menu
            case $choice in
                1) deploy_local ;;
                2) deploy_remote ;;
                3) deploy_nvidia ;;
                4) deploy_docker ;;
                5) deploy_openrag ;;
                6) status ;;
                7) stop ;;
                8) start ;;
                9) log "Goodbye!"; exit 0 ;;
                *) warn "Invalid option" ;;
            esac
            read -p "Press Enter..."
        done
    else
        case $1 in
            local) deploy_local ;;
            remote) deploy_remote ;;
            nvidia) deploy_nvidia ;;
            docker) deploy_docker ;;
            openrag) deploy_openrag ;;
            status) status ;;
            stop) stop ;;
            start) start ;;
            *) echo "Usage: $0 [local|remote|nvidia|docker|openrag|status|stop|start]"; exit 1 ;;
        esac
    fi
}

main "$@"
