#!/usr/bin/env bash
# One-time setup before `docker compose up`:
#   - downloads LFS binary files (fastq.gz, Kraken2 databases)
#   - generates .env with ODIN_PIPELINE_ROOT set to the pipeline/ subdirectory
#
#   bash setup.sh

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
ENV_FILE="${REPO_ROOT}/.env"
PIPELINE_ROOT="${REPO_ROOT}/pipeline"

# ── Colors ────────────────────────────────────────────────────────────────────
RED='\033[0;31m'; YELLOW='\033[1;33m'; GREEN='\033[0;32m'; NC='\033[0m'

# ── Git LFS ───────────────────────────────────────────────────────────────────
echo "==> Checking Git LFS..."
if command -v git-lfs &>/dev/null || git lfs version &>/dev/null 2>&1; then
    # If LFS is not yet configured for this repo, do a one-time install and pull.
    if ! git -C "${REPO_ROOT}" config --local filter.lfs.smudge >/dev/null 2>&1; then
        echo "    Configuring Git LFS for this repository..."
        git -C "${REPO_ROOT}" lfs install --local
        echo "    Downloading large files (this may take a while)..."
        git -C "${REPO_ROOT}" lfs pull
        echo -e "    ${GREEN}LFS files downloaded.${NC}"
    else
        echo "    Git LFS is already configured."
        echo "    If you see 'Not in GZIP format' errors later, run 'git lfs pull' manually."
    fi
else
    echo -e "    ${RED}WARNING: git-lfs not found.${NC}"
    echo "    Large files (fastq.gz, Kraken2 DBs) will be missing or corrupted."
    echo "    1. Install it (e.g. 'sudo apt install git-lfs' or 'brew install git-lfs')"
    echo "    2. Run 'git lfs install' and 'git lfs pull' in this directory."
fi

# ── .env ──────────────────────────────────────────────────────────────────────
if [[ -f "$ENV_FILE" ]]; then
    echo ".env already exists — overwrite? [y/N] "
    read -r answer
    [[ "$answer" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 0; }
fi

# ── Corporate CA Certificate ──────────────────────────────────────────────────
# Auto-detect corporate certificates from common environment variables.
# This ensures that if the host is already configured for a corporate firewall,
# the backend container will also have the certificate for Nextflow/CURL tasks.
CA_DIR="${REPO_ROOT}/pipeline/ca"
mkdir -p "$CA_DIR"

for var in REQUESTS_CA_BUNDLE CURL_CA_BUNDLE SSL_CERT_FILE; do
    # Use variable indirection to get value of $REQUESTS_CA_BUNDLE etc.
    CERT_VAL="${!var:-}"
    if [[ -f "$CERT_VAL" ]]; then
        echo "==> Corporate CA detected via \$$var..."
        DEST="$CA_DIR/$(basename "$CERT_VAL")"
        if [[ ! -f "$DEST" ]]; then
            cp "$CERT_VAL" "$DEST"
            echo -e "    ${GREEN}Copied certificate to pipeline/ca/${NC}"
        else
            echo "    Certificate already exists in pipeline/ca/"
        fi
        break # Only need one
    fi
done

cat > "$ENV_FILE" <<EOF
ODIN_PIPELINE_ROOT=${PIPELINE_ROOT}

# ── RECOMMENDED ON WINDOWS/WSL2 ───────────────────────────────────────────────
# Set ODIN_WORK_DIR to a WSL2-native Linux path to avoid I/O failures when
# Nextflow task containers access work directories on a Windows filesystem.
# docker-compose.yml mounts this path identically (host:container) so that
# sibling pipeline containers can reach it via the Docker socket.
# Docker auto-creates the directory on first launch — no mkdir needed.
# Default when unset: /tmp/odin_work (also auto-created).
# ODIN_WORK_DIR=/home/<your-wsl-user>/odin_work

# ── OPTIONAL ──────────────────────────────────────────────────────────────────
# ODIN_TMP_DIR=/var/tmp
# ODIN_LOG_DIR=/home/<your-wsl-user>/odin_logs
EOF

echo "Created .env:"
cat "$ENV_FILE"
