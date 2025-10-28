#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

# Install dependencies
apt-get update
apt-get install -y \
  software-properties-common lsb-release \
  wget curl build-essential jq autoconf automake \
  pkg-config ca-certificates rpm apt-utils \
  python3 make gettext pinentry-tty devscripts dpkg-dev \
  git cmake

# Fix ownership warning
git config --global --add safe.directory '*'

# Build packages
./create-deb.sh
