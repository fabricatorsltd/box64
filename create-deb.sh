#!/usr/bin/env bash
set -euo pipefail

echo "$(nproc)"
DIRECTORY="$(pwd)"
export DEBIAN_FRONTEND=noninteractive

[[ -f "$DIRECTORY/commit.txt" ]] && LATESTCOMMIT="$(cat "$DIRECTORY/commit.txt")" || LATESTCOMMIT=""

error() {
  echo -e "\e[91m$1\e[39m"
  rm -rf "$DIRECTORY/box64" || true
  exit 1
}

apt-get update
apt-get install -y \
  wget git build-essential python3 make gettext \
  pinentry-tty devscripts dpkg-dev cmake checkinstall \
  autoconf automake pkg-config ca-certificates jq file binutils || error "Failed to install dependencies."

git config --global --add safe.directory '*'

rm -rf "$DIRECTORY/box64"
git clone https://github.com/ptitSeb/box64 "$DIRECTORY/box64" || error "Failed to download box64 repo"

cd "$DIRECTORY/box64"
commit="$(git rev-parse HEAD | cut -c 1-7)"

if [[ -n "$LATESTCOMMIT" && "$commit" == "$LATESTCOMMIT" ]]; then
  cd "$DIRECTORY"
  rm -rf "box64"
  echo "Box64 is already up to date. Exiting."
  touch exited_successfully.txt
  exit 0
fi

echo "$commit" > "$DIRECTORY/commit.txt"
echo "Box64 is not the latest version, compiling now."

# SOLO target generico per evitare -march armv8.6
targets=(ARM64)

for target in "${targets[@]}"; do
  echo "Building $target"
  cd "$DIRECTORY/box64"
  rm -rf build && mkdir build && cd build || error "Could not move to build directory"

  # Forziamo flags compatibili con GCC 9 (armv8-a baseline)
  cmake .. -D"$target"=1 -D ARM_DYNAREC=ON -D CMAKE_BUILD_TYPE=RelWithDebInfo -D BOX32=ON -D BOX32_BINFMT=ON || error "Failed to run cmake."

  make -j"$(nproc)" || error "Failed to run make."

  # Version
  MAJ="$(grep -Eo 'BOX64_MAJOR[[:space:]]+[0-9]+' ../src/box64version.h | awk '{print $2}' || true)"
  MIN="$(grep -Eo 'BOX64_MINOR[[:space:]]+[0-9]+' ../src/box64version.h | awk '{print $2}' || true)"
  REV="$(grep -Eo 'BOX64_REVISION[[:space:]]+[0-9]+' ../src/box64version.h | awk '{print $2}' || true)"
  [[ -z "${MAJ:-}" || -z "${MIN:-}" || -z "${REV:-}" ]] && BOX64VER="0.0.0" || BOX64VER="${MAJ}.${MIN}.${REV}"
  BOX64COMMIT="$commit"
  DEBVER="${BOX64VER}+$(date +'%Y%m%d').${BOX64COMMIT}"

  mkdir doc-pak || error "Failed to create doc-pak dir."
  cp ../README.md ./doc-pak/ || true
  cp ../docs/CHANGELOG.md ./doc-pak/ || true
  cp ../docs/USAGE.md ./doc-pak/ || true
  cp ../LICENSE ./doc-pak/ || true
  printf '%s\n' "Box64 lets you run x86_64 Linux programs (such as games) on non-x86_64 Linux systems, like ARM (host system needs to be 64bit little-endian)" > description-pak

  cat > postinstall-pak <<'EOF'
#!/bin/bash
echo 'Restarting systemd-binfmt...'
systemctl restart systemd-binfmt || true
EOF
  chmod +x postinstall-pak

  conflict_list="qemu-user-static"
  PKGNAME="box64"
  checkinstall -y -D --pkgversion="$DEBVER" --arch="arm64" \
    --provides="box64" --conflicts="$conflict_list" \
    --maintainer="Ryan Fortner <ryankfortner@gmail.com>" \
    --pkglicense="MIT" --pkgsource="https://github.com/ptitSeb/box64" \
    --pkggroup="utils" --pkgname="$PKGNAME" --install="no" make install || error "Checkinstall failed."

  cd "$DIRECTORY"
  mkdir -p "$DIRECTORY/debian" "$DIRECTORY/out"
  mv box64/build/*.deb "$DIRECTORY/debian/" || error "Failed to move deb."
  cp "$DIRECTORY/debian/"*.deb "$DIRECTORY/out/" || true
done

cd "$DIRECTORY"
if compgen -G "./debian/box64*.deb" > /dev/null; then
  ls ./debian/box64*.deb | sort -t '+' -k 2 | head -n -24 | xargs -r rm
fi

rm -rf "$DIRECTORY/box64"
echo "Script complete."
