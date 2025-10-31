#!/usr/bin/env bash
set -euo pipefail

echo "$(nproc)"
DIRECTORY="$(pwd)"
export DEBIAN_FRONTEND=noninteractive

[[ -f "$DIRECTORY/commit.txt" ]] && LATESTCOMMIT_BOX64="$(cat "$DIRECTORY/commit.txt")" || LATESTCOMMIT_BOX64=""
[[ -f "$DIRECTORY/commit_box86.txt" ]] && LATESTCOMMIT_BOX86="$(cat "$DIRECTORY/commit_box86.txt")" || LATESTCOMMIT_BOX86=""

error() {
  echo -e "\e[91m$1\e[39m"
  rm -rf "$DIRECTORY/box64" "$DIRECTORY/box86" || true
  exit 1
}

apt-get update
apt-get install -y \
  wget git build-essential python3 make gettext \
  pinentry-tty devscripts dpkg-dev cmake checkinstall \
  autoconf automake pkg-config ca-certificates jq file binutils || error "Failed to install dependencies."

git config --global --add safe.directory '*'

mkdir -p "$DIRECTORY/debian" "$DIRECTORY/out"

###############################################################################
# BOX64
###############################################################################
rm -rf "$DIRECTORY/box64"
git clone https://github.com/ptitSeb/box64 "$DIRECTORY/box64" || error "Failed to download box64 repo"

cd "$DIRECTORY/box64"
commit_box64="$(git rev-parse HEAD | cut -c 1-7)"

if [[ -n "$LATESTCOMMIT_BOX64" && "$commit_box64" == "$LATESTCOMMIT_BOX64" ]]; then
  cd "$DIRECTORY"
  rm -rf "box64"
  echo "Box64 is already up to date."
  touch exited_successfully.txt
else
  echo "$commit_box64" > "$DIRECTORY/commit.txt"
  echo "Box64 is not the latest version, compiling now."

  targets=(ARM64)

  for target in "${targets[@]}"; do
    echo "Building $target"
    cd "$DIRECTORY/box64"
    rm -rf build && mkdir build && cd build || error "Could not move to build directory"

    cmake .. -D"$target"=1 \
      -DCMAKE_BUILD_TYPE=RelWithDebInfo \
      -DCMAKE_C_COMPILER=gcc \
      -DARM_DYNAREC=ON -DBOX32=1 -DBOX32_BINFMT=1 \
      -DCMAKE_C_FLAGS="-O2 -pipe -march=armv8-a" \
      -DCMAKE_EXE_LINKER_FLAGS="" || error "Failed to run cmake."

    make -j"$(nproc)" || error "Failed to run make."

    MAJ="$(grep -Eo 'BOX64_MAJOR[[:space:]]+[0-9]+' ../src/box64version.h | awk '{print $2}' || true)"
    MIN="$(grep -Eo 'BOX64_MINOR[[:space:]]+[0-9]+' ../src/box64version.h | awk '{print $2}' || true)"
    REV="$(grep -Eo 'BOX64_REVISION[[:space:]]+[0-9]+' ../src/box64version.h | awk '{print $2}' || true)"
    [[ -z "${MAJ:-}" || -z "${MIN:-}" || -z "${REV:-}" ]] && BOX64VER="0.0.0" || BOX64VER="${MAJ}.${MIN}.${REV}"
    DEBVER="${BOX64VER}+$(date +'%Y%m%d').${commit_box64}"

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
    mv box64/build/*.deb "$DIRECTORY/debian/" || error "Failed to move deb."
    cp "$DIRECTORY/debian/"*.deb "$DIRECTORY/out/" || true
  done
fi

###############################################################################
# BOX86
###############################################################################
rm -rf "$DIRECTORY/box86"
git clone https://github.com/ptitSeb/box86 "$DIRECTORY/box86" || error "Failed to download box86 repo"

cd "$DIRECTORY/box86"
commit_box86="$(git rev-parse HEAD | cut -c 1-7)"

if [[ -n "$LATESTCOMMIT_BOX86" && "$commit_box86" == "$LATESTCOMMIT_BOX86" ]]; then
  cd "$DIRECTORY"
  rm -rf "box86"
  echo "Box86 is already up to date."
  touch exited_successfully_box86.txt
else
  echo "$commit_box86" > "$DIRECTORY/commit_box86.txt"
  echo "Box86 is not the latest version, compiling now."

  # build per ARM aarch64 host con dynarec
  rm -rf build && mkdir build && cd build || error "Could not move to box86 build directory"

  cmake .. \
    -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    -DCMAKE_C_COMPILER=gcc \
    -DARM_DYNAREC=ON \
    -DCMAKE_C_FLAGS="-O2 -pipe -march=armv8-a" \
    -DCMAKE_EXE_LINKER_FLAGS="" || error "Failed to run cmake for box86."

  make -j"$(nproc)" || error "Failed to run make for box86."

  MAJ86="$(grep -Eo 'BOX86_MAJOR[[:space:]]+[0-9]+' ../src/box86version.h | awk '{print $2}' || true)"
  MIN86="$(grep -Eo 'BOX86_MINOR[[:space:]]+[0-9]+' ../src/box86version.h | awk '{print $2}' || true)"
  REV86="$(grep -Eo 'BOX86_REVISION[[:space:]]+[0-9]+' ../src/box86version.h | awk '{print $2}' || true)"
  [[ -z "${MAJ86:-}" || -z "${MIN86:-}" || -z "${REV86:-}" ]] && BOX86VER="0.0.0" || BOX86VER="${MAJ86}.${MIN86}.${REV86}"
  DEBVER86="${BOX86VER}+$(date +'%Y%m%d').${commit_box86}"

  mkdir doc-pak || error "Failed to create doc-pak dir for box86."
  cp ../README.md ./doc-pak/ || true
  cp ../docs/CHANGELOG.md ./doc-pak/ || true
  cp ../docs/USAGE.md ./doc-pak/ || true
  cp ../LICENSE ./doc-pak/ || true
  printf '%s\n' "Box86 lets you run x86 Linux programs on non x86 Linux, such as ARM." > description-pak

  cat > postinstall-pak <<'EOF'
#!/bin/bash
echo 'Restarting systemd-binfmt...'
systemctl restart systemd-binfmt || true
EOF
  chmod +x postinstall-pak

  conflict_list86="qemu-user-static"
  PKGNAME86="box86"
  checkinstall -y -D --pkgversion="$DEBVER86" --arch="armhf" \
    --provides="box86" --conflicts="$conflict_list86" \
    --maintainer="Ryan Fortner <ryankfortner@gmail.com>" \
    --pkglicense="MIT" --pkgsource="https://github.com/ptitSeb/box86" \
    --pkggroup="utils" --pkgname="$PKGNAME86" --install="no" make install || error "Checkinstall failed for box86."

  cd "$DIRECTORY"
  mv box86/build/*.deb "$DIRECTORY/debian/" || error "Failed to move box86 deb."
  cp "$DIRECTORY/debian/"*.deb "$DIRECTORY/out/" || true
fi

###############################################################################
# CLEANUP E ROTAZIONE
###############################################################################
cd "$DIRECTORY"
if compgen -G "./debian/box64*.deb" > /dev/null; then
  ls ./debian/box64*.deb | sort -t '+' -k 2 | head -n -24 | xargs -r rm
fi
if compgen -G "./debian/box86*.deb" > /dev/null; then
  ls ./debian/box86*.deb | sort -t '+' -k 2 | head -n -24 | xargs -r rm
fi

rm -rf "$DIRECTORY/box64" "$DIRECTORY/box86"
echo "Script complete."
