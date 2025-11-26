#!/usr/bin/env bash

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default values
PLAYBOOK=""
VERBOSE="-v"
DRY_RUN=false

# Help message
usage() {
    cat << EOF
Usage: $0 [OPTIONS] PLAYBOOK

Simplified Ansible playbook execution with environment setup.

OPTIONS:
  -h, --help              Show this help message
  -vv, --very-verbose     Enable verbose output (shows all task details)
  -q, --quiet             Minimal output
  --dry-run              Run playbook in check mode (no changes)
  
ARGUMENTS:
  PLAYBOOK               Path to playbook (required)

EXAMPLES:
  $0 playbooks/integrations/my_playbook.yml
  $0 -vv playbooks/integrations/my_playbook.yml
  $0 --dry-run playbooks/integrations/my_playbook.yml

EOF
    exit 0
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            ;;
        -vv|--very-verbose)
            VERBOSE="-vv"
            shift
            ;;
        -q|--quiet)
            VERBOSE=""
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        -*)
            echo -e "${RED}Error: Unknown option $1${NC}" >&2
            usage
            ;;
        *)
            PLAYBOOK="$1"
            shift
            ;;
    esac
done

# Check if playbook is provided
if [[ -z "$PLAYBOOK" ]]; then
    echo -e "${RED}Error: Playbook argument is required${NC}" >&2
    usage
fi

# Verify playbook exists
if [[ ! -f "$SCRIPT_DIR/$PLAYBOOK" ]]; then
    echo -e "${RED}Error: Playbook not found: $SCRIPT_DIR/$PLAYBOOK${NC}" >&2
    exit 1
fi

# Verify .env file exists
if [[ ! -f "$SCRIPT_DIR/.env" ]]; then
    echo -e "${YELLOW}Warning: .env file not found at $SCRIPT_DIR/.env${NC}" >&2
fi

# Print startup info
echo -e "${GREEN}Ansible Playbook Runner${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Playbook:  $PLAYBOOK"
echo "Directory: $SCRIPT_DIR"
echo -e "Mode:      $([ "$DRY_RUN" = true ] && echo "CHECK (dry-run)" || echo "NORMAL")"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Build command
CMD="set -a && source '$SCRIPT_DIR/.env' && set +a"
CMD="$CMD && export ANSIBLE_COLLECTIONS_PATH='$SCRIPT_DIR/dev_collection'"
CMD="$CMD && export ANSIBLE_CONFIG='$SCRIPT_DIR/ansible.cfg'"
CMD="$CMD && cd '$SCRIPT_DIR'"
CMD="$CMD && uv run ansible-playbook '$PLAYBOOK' $VERBOSE"

# Add check flag if dry-run
if [[ "$DRY_RUN" = true ]]; then
    CMD="$CMD --check"
fi

# Create dev_collection symlink if it doesn't exist
if [[ ! -d "$SCRIPT_DIR/dev_collection/ansible_collections/cortex/xsoar" ]]; then
    echo -e "${YELLOW}Creating local Ansible collection structure...${NC}"
    mkdir -p "$SCRIPT_DIR/dev_collection/ansible_collections/cortex"
    ln -sf "$SCRIPT_DIR" "$SCRIPT_DIR/dev_collection/ansible_collections/cortex/xsoar"
    echo -e "${GREEN}✓ Collection structure ready${NC}"
    echo ""
fi

# Execute playbook
echo -e "${GREEN}Executing playbook...${NC}"
echo ""
eval "$CMD"
EXIT_CODE=$?

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [[ $EXIT_CODE -eq 0 ]]; then
    echo -e "${GREEN}✓ Playbook completed successfully${NC}"
else
    echo -e "${RED}✗ Playbook failed with exit code $EXIT_CODE${NC}"
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

exit $EXIT_CODE
