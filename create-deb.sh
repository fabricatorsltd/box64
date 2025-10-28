#!/usr/bin/env bash
set -euo pipefail

echo "$(nproc)"

DIRECTORY="$(pwd)"
export DEBIAN_FRONTEND=noninteractive

# read last compiled commit if present
if [[ -f "$DIRECTORY/commit.txt" ]]; then
  LATESTCOMMIT="$(cat "$DIRECTORY/commit.txt")"
else
  LATESTCOMMIT=""
fi

error() {
  echo -e "\e[91m$1\e[39m"
  rm -rf "$DIRECTORY/box64" || true
  exit 1
}

# Dependencies (Focal / glibc 2.31)
apt-get update
apt-get install -y \
  wget git build-essential python3 make gettext \
  pinentry-tty devscripts dpkg-dev cmake checkinstall \
  autoconf automake pkg-config ca-certificates jq file binutils || error "Failed to install dependencies."

git config --global --add safe.directory '*'

rm -rf "$DIRECTORY/box64"
cd "$DIRECTORY"
git clone https://github.com/ptitSeb/box64 || error "Failed to download box64 repo"

cd box64
commit="$(git rev-parse HEAD | cut -c 1-7)"

if [[ -n "$LATESTCOMMIT" && "$commit" == "$LATESTCOMMIT" ]]; then
  cd "$DIRECTORY"
  rm -rf "box64"
  echo "Box64 is already up to date. Exiting."
  touch exited_successfully.txt
  exit 0
fi

echo "Box64 is not the latest version, compiling now."
echo "$commit" > "$DIRECTORY/commit.txt"

targets=(ARM64 SDORYON1 SD888 ANDROID RPI4ARM64 RPI3ARM64 TEGRAX1 RK3399 RK3588 RPI5ARM64 RPI5ARM64PS16K LX2160A TEGRA_T194 M1)

for target in "${targets[@]}"; do
  echo "Building $target"
  cd "$DIRECTORY/box64"
  rm -rf build && mkdir build && cd build || error "Could not move to build directory"

  if [[ $target == "ANDROID" ]]; then
    cmake .. -DBAD_SIGNAL=ON -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_C_COMPILER=gcc -DARM_DYNAREC=ON -DBOX32=1 -DBOX32_BINFMT=1 || error "Failed to run cmake."
  else
    cmake .. -D"$target"=1 -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_C_COMPILER=gcc -DARM_DYNAREC=ON -DBOX32=1 -DBOX32_BINFMT=1 || error "Failed to run cmake."
  fi

  make -j"$(nproc)" || error "Failed to run make."

  # Version string
  MAJ="$(grep -Eo 'BOX64_MAJOR[[:space:]]+[0-9]+' ../src/box64version.h | awk '{print $2}' || true)"
  MIN="$(grep -Eo 'BOX64_MINOR[[:space:]]+[0-9]+' ../src/box64version.h | awk '{print $2}' || true)"
  REV="$(grep -Eo 'BOX64_REVISION[[:space:]]+[0-9]+' ../src/box64version.h | awk '{print $2}' || true)"
  if [[ -z "${MAJ:-}" || -z "${MIN:-}" || -z "${REV:-}" ]]; then
    BOX64VER="0.0.0"
  else
    BOX64VER="${MAJ}.${MIN}.${REV}"
  fi
  BOX64COMMIT="$commit"
  DEBVER="${BOX64VER}+$(date +'%Y%m%d').${BOX64COMMIT}"

  mkdir doc-pak || error "Failed to create doc-pak dir."
  cp ../README.md ./doc-pak/ || true
  cp ../docs/CHANGELOG.md ./doc-pak/ || true
  cp ../docs/USAGE.md ./doc-pak/ || true
  cp ../LICENSE ./doc-pak/ || true
  cat > description-pak <<'EOF'
Box64 lets you run x86_64 Linux programs (such as games) on non-x86_64 Linux systems, like ARM (host system needs to be 64bit little-endian)
EOF

  cat > postinstall-pak <<'EOF'
#!/bin/bash
echo 'Restarting systemd-binfmt...'
systemctl restart systemd-binfmt || true
EOF
  chmod +x postinstall-pak

  conflict_list="qemu-user-static"
  for value in "${targets[@]}"; do
    [[ $value != $target ]] && conflict_list+=", box64-$(echo "$value" | tr '[:upper:]' '[:lower:]' | tr _ -)"
  done

  PKGNAME="box64"
  [[ $target != "ARM64" ]] && PKGNAME="box64-$(echo "$target" | tr '[:upper:]' '[:lower:]' | tr _ -)"

  checkinstall -y -D --pkgversion="$DEBVER" --arch="arm64" \
    --provides="box64" --conflicts="$conflict_list" \
    --maintainer="Ryan Fortner <ryankfortner@gmail.com>" \
    --pkglicense="MIT" --pkgsource="https://github.com/ptitSeb/box64" \
    --pkggroup="utils" --pkgname="$PKGNAME" --install="no" make install || error "Checkinstall failed."

  cd "$DIRECTORY"
  mkdir -p "$DIRECTORY/debian"
  mv box64/build/*.deb "$DIRECTORY/debian/" || error "Failed to move deb."
done

cd "$DIRECTORY"
# keep only the latest 24 packages (approx. 2 per target); ignore if fewer
if compgen -G "./debian/box64*.deb" > /dev/null; then
  ls ./debian/box64*.deb | sort -t '+' -k 2 | head -n -24 | xargs -r rm
fi

rm -rf "$DIRECTORY/box64"
echo "Script complete."
