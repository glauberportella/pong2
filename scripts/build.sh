#!/bin/sh
# Gera bin/pong2.love e os binarios de macOS, Windows e Linux.
#
# Uso: scripts/build.sh
#
# Requisitos:
#   - zip e unzip
#   - curl (so na primeira vez, para baixar o LOVE de Windows e Linux em love2d/)
#   - Linux: unsquashfs e mksquashfs (pacote squashfs-tools) ou Docker
#
# O app de macOS em bin/macos/pong2.app ja existe no repositorio;
# o script so troca o jogo dentro dele.

set -e

LOVE_VERSION=11.5
ROOT=$(cd "$(dirname "$0")/.." && pwd)
BUILD="$ROOT/build"
LOVE_DIR="$ROOT/love2d"
WIN_DIR="$LOVE_DIR/love-$LOVE_VERSION-win64"
LINUX_APPIMAGE="$LOVE_DIR/love-$LOVE_VERSION-linux/love-$LOVE_VERSION-x86_64.AppImage"
RELEASES="https://github.com/love2d/love/releases/download/$LOVE_VERSION"

cd "$ROOT"
rm -rf "$BUILD"
mkdir -p "$BUILD"

size_of() {
  wc -c < "$1" | tr -d ' '
}

# Confere que o arquivo termina com o pong2.love gerado
check_fused() {
  tail -c "$(size_of "$BUILD/pong2.love")" "$1" | cmp -s - "$BUILD/pong2.love" || {
    echo "ERRO: $1 nao contem o pong2.love novo" >&2
    exit 1
  }
}

echo "== pong2.love (versao $(cat VERSION))"
zip -9 -q -X -r "$BUILD/pong2.love" main.lua conf.lua VERSION src \
  assets/Pong-Game.ttf assets/powerups/spritesheet_24x24.png assets/bg -x "*.DS_Store"
cp "$BUILD/pong2.love" bin/pong2.love

echo "== macOS"
cp "$BUILD/pong2.love" bin/macos/pong2.app/Contents/Resources/game.love

echo "== Windows"
if [ ! -f "$WIN_DIR/love.exe" ]; then
  echo "baixando LOVE $LOVE_VERSION para Windows"
  mkdir -p "$LOVE_DIR"
  curl -sSfL -o "$BUILD/love-win64.zip" "$RELEASES/love-$LOVE_VERSION-win64.zip"
  unzip -q "$BUILD/love-win64.zip" -d "$LOVE_DIR"
fi
mkdir -p "$BUILD/windows/pong2"
cat "$WIN_DIR/love.exe" "$BUILD/pong2.love" > "$BUILD/windows/pong2/pong2.exe"
for dll in love.dll lua51.dll mpg123.dll msvcp120.dll msvcr120.dll OpenAL32.dll SDL2.dll; do
  cp "$WIN_DIR/$dll" "$BUILD/windows/pong2/"
done
(cd "$BUILD/windows" && zip -9 -q -X -r pong2.zip pong2)
check_fused "$BUILD/windows/pong2/pong2.exe"
cp "$BUILD/windows/pong2.zip" bin/windows/pong2.zip

echo "== Linux"
if [ ! -f "$LINUX_APPIMAGE" ]; then
  echo "baixando LOVE $LOVE_VERSION para Linux"
  mkdir -p "$(dirname "$LINUX_APPIMAGE")"
  curl -sSfL -o "$LINUX_APPIMAGE" "$RELEASES/love-$LOVE_VERSION-x86_64.AppImage"
fi

# Um AppImage e um executavel pequeno (runtime) seguido de uma imagem squashfs.
# O squashfs comeca onde termina o ELF: e_shoff + e_shentsize * e_shnum.
OFFSET=$(python3 -c '
import struct, sys
d = open(sys.argv[1], "rb").read(64)
shoff = struct.unpack_from("<Q", d, 0x28)[0]
shentsize, shnum = struct.unpack_from("<HH", d, 0x3A)
print(shoff + shentsize * shnum)
' "$LINUX_APPIMAGE")

mkdir -p "$BUILD/linux"
cp "$LINUX_APPIMAGE" "$BUILD/linux/love.AppImage"
cp "$BUILD/pong2.love" "$BUILD/linux/"

# Extrai, junta o jogo ao executavel do LOVE e monta o AppImage de novo
cat > "$BUILD/linux/build.sh" <<EOF
set -e
cd "\$(dirname "\$0")"
head -c $OFFSET love.AppImage > runtime
unsquashfs -q -o $OFFSET -d squashfs-root love.AppImage > /dev/null
cat squashfs-root/bin/love pong2.love > love.fused
mv love.fused squashfs-root/bin/love
chmod 755 squashfs-root/bin/love
printf "[Desktop Entry]\nName=Pong2\nComment=Pong com power-ups\nExec=love\nType=Application\nCategories=Game;\nTerminal=false\nIcon=love\n" > squashfs-root/love.desktop
mksquashfs squashfs-root fs.squashfs -comp gzip -b 131072 -root-owned -noappend -quiet > /dev/null
cat runtime fs.squashfs > pong2-x86_64.AppImage
chmod 755 pong2-x86_64.AppImage
unsquashfs -q -o $OFFSET -d check pong2-x86_64.AppImage > /dev/null
EOF

if command -v unsquashfs > /dev/null && command -v mksquashfs > /dev/null; then
  sh "$BUILD/linux/build.sh"
elif command -v docker > /dev/null; then
  docker run --rm -v "$BUILD/linux:/work" ubuntu:22.04 sh -c \
    "apt-get update -qq > /dev/null && apt-get install -y -qq squashfs-tools > /dev/null 2>&1 && sh /work/build.sh"
else
  echo "ERRO: instale squashfs-tools ou Docker para gerar o binario de Linux" >&2
  exit 1
fi
check_fused "$BUILD/linux/check/bin/love"
cp "$BUILD/linux/pong2-x86_64.AppImage" bin/linux/pong2-x86_64.AppImage
chmod 755 bin/linux/pong2-x86_64.AppImage

rm -rf "$BUILD"
echo "== pronto: binarios em bin/"
