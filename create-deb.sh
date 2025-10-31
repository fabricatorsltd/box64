#!/usr/bin/env bash
set -euo pipefail

DIRECTORY="$(pwd)"
export DEBIAN_FRONTEND=noninteractive

# leggo i commit solo per log, NON per uscire
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

#####################################
# BOX64
#####################################
rm -rf "$DIRECTORY/box64"
git clone https://github.com/ptitSeb/box64 "$DIRECTORY/box64" || error "Failed to download box64 repo"

cd "$DIRECTORY/box64"
commit_box64="$(git rev-parse HEAD | cut -c 1-7)"
echo "$commit_box64" > "$DIRECTORY/commit.txt"
echo "Building Box64 commit $commit_box64 (prev: ${LATESTCOMMIT_BOX64:-none})"

rm -rf build && mkdir build && cd build || error "Could not move to build directory"

cmake .. -DARM64=1 \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  -DCMAKE_C_COMPILER=gcc \
  -DARM_DYNAREC=ON -DBOX32=ON -DBOX32_BINFMT=ON \
  -DCMAKE_C_FLAGS="-O2 -pipe -march=armv8-a" \
  -DCMAKE_EXE_LINKER_FLAGS="" || error "Failed to run cmake (box64)."

make -j"$(nproc)" || error "Failed to run make (box64)."

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
printf '%s\n' "Box64 lets you run x86_64 Linux programs on ARM64 hosts." > description-pak

cat > postinstall-pak <<'EOF'
#!/bin/bash
echo 'Restarting systemd-binfmt...'
systemctl restart systemd-binfmt || true
EOF
chmod +x postinstall-pak

checkinstall -y -D --pkgversion="$DEBVER" --arch="arm64" \
  --provides="box64" --conflicts="qemu-user-static" \
  --maintainer="Ryan Fortner <ryankfortner@gmail.com>" \
  --pkglicense="MIT" --pkgsource="https://github.com/ptitSeb/box64" \
  --pkggroup="utils" --pkgname="box64" --install="no" make install || error "Checkinstall failed (box64)."

cd "$DIRECTORY"
mv box64/build/*.deb "$DIRECTORY/debian/" || error "Failed to move deb (box64)."
cp "$DIRECTORY/debian/"*.deb "$DIRECTORY/out/" || true

#####################################
# BOX86
#####################################
rm -rf "$DIRECTORY/box86"
git clone https://github.com/ptitSeb/box86 "$DIRECTORY/box86" || error "Failed to download box86 repo"

cd "$DIRECTORY/box86"
commit_box86="$(git rev-parse HEAD | cut -c 1-7)"
echo "$commit_box86" > "$DIRECTORY/commit_box86.txt"
echo "Building Box86 commit $commit_box86 (prev: ${LATESTCOMMIT_BOX86:-none})"

rm -rf build && mkdir build && cd build || error "Could not move to box86 build directory"

cmake .. \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  -DCMAKE_C_COMPILER=gcc \
  -DARM_DYNAREC=ON \
  -DCMAKE_C_FLAGS="-O2 -pipe -march=armv8-a" \
  -DCMAKE_EXE_LINKER_FLAGS="" || error "Failed to run cmake (box86)."

make -j"$(nproc)" || error "Failed to run make (box86)."

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
printf '%s\n' "Box86 lets you run x86 Linux programs on ARM hosts." > description-pak

cat > postinstall-pak <<'EOF'
#!/bin/bash
echo 'Restarting systemd-binfmt...'
systemctl restart systemd-binfmt || true
EOF
chmod +x postinstall-pak

checkinstall -y -D --pkgversion="$DEBVER86" --arch="armhf" \
  --provides="box86" --conflicts="qemu-user-static" \
  --maintainer="Ryan Fortner <ryankfortner@gmail.com>" \
  --pkglicense="MIT" --pkgsource="https://github.com/ptitSeb/box86" \
  --pkggroup="utils" --pkgname="box86" --install="no" make install || error "Checkinstall failed (box86)."

cd "$DIRECTORY"
mv box86/build/*.deb "$DIRECTORY/debian/" || error "Failed to move deb (box86)."
cp "$DIRECTORY/debian/"*.deb "$DIRECTORY/out/" || true

#####################################
# ROTAZIONE
#####################################
cd "$DIRECTORY"
if compgen -G "./debian/box64*.deb" > /dev/null; then
  ls ./debian/box64*.deb | sort -t '+' -k 2 | head -n -24 | xargs -r rm
fi
if compgen -G "./debian/box86*.deb" > /dev/null; then
  ls ./debian/box86*.deb | sort -t '+' -k 2 | head -n -24 | xargs -r rm
fi

rm -rf "$DIRECTORY/box64" "$DIRECTORY/box86"
echo "Script complete."
