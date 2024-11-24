#!/usr/bin/env bash
# shellcheck shell=bash

# This file generates secrets for files that do not exist yet, it will not
# overwrite existing secrets files.
set -euf -o pipefail

PROGDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROGDIR

# Get the tag for the base image.
# shellcheck source=/dev/null
source .env

BASE_IMAGE="islandora/base:${ISLANDORA_TAG}"
readonly BASE_IMAGE

# Drupal salt is a special case, treat it as such.
SALT_FILE="${PROGDIR}/secrets/DRUPAL_DEFAULT_SALT"
readonly SALT_FILE
if [ ! -f "${SALT_FILE}" ]; then
  echo "Creating: ${SALT_FILE}" >&2
  bash -c "(grep -ao '[A-Za-z0-9_-]' </dev/urandom || true) | head -74 | tr -d '\n'" >"${SALT_FILE}"
fi

# Use openssl to generate certificates.
PRIVATE_KEY_FILE="${PROGDIR}/secrets/JWT_PRIVATE_KEY"
readonly PRIVATE_KEY_FILE
if [ ! -f "${PRIVATE_KEY_FILE}" ]; then
  echo "Creating: ${PRIVATE_KEY_FILE}" >&2
  openssl genrsa 2048 >"${PRIVATE_KEY_FILE}" 2>/dev/null
fi

# static host keys for SSH
# to let OS upgrades happen without issue
if [ ! -d "${PROGDIR}/secrets/etc/ssh" ]; then
  mkdir -p "${PROGDIR}/secrets/etc/ssh"
  apk update && apk add openssh
  ssh-keygen -A -f "${PROGDIR}/secrets"
fi

# Public key is derived from the private key.
PUBLIC_KEY_FILE="${PROGDIR}/secrets/JWT_PUBLIC_KEY"
readonly PUBLIC_KEY_FILE
if [ ! -f "${PUBLIC_KEY_FILE}" ]; then
  echo "Creating: ${PUBLIC_KEY_FILE}" >&2
  openssl rsa -pubout <"${PRIVATE_KEY_FILE}" >"${PUBLIC_KEY_FILE}" 2>/dev/null
fi

# The snippet below list all the secret files referenced by the docker-compose.yml file.
# For each it will generate a random password.
readonly CHARACTERS='[A-Za-z0-9]'
readonly LENGTH=32

declare -a SECRETS
LINES=$(yq '.secrets[].file' docker-compose.yml)
while IFS= read -r line; do
  SECRETS+=("$line")
done <<< "$LINES"

for secret in "${SECRETS[@]}"; do
  if [ ! -f "${secret}" ]; then
    echo "Creating: ${secret}" >&2
    bash -c "(grep -ao '${CHARACTERS}' </dev/urandom || true) | head '-${LENGTH}' | tr -d '\n'" >"${secret}"
  fi
done
