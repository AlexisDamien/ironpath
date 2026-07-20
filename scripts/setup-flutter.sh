#!/usr/bin/env bash
# Installe automatiquement le SDK Flutter dans la version requise par le projet,
# s'il est absent ou dans une version différente.
# Compatible : Windows (Git Bash / MINGW), Linux, macOS.
set -euo pipefail

REQUIRED_VERSION="3.44.2"
INSTALL_DIR="${FLUTTER_INSTALL_DIR:-$HOME/dev}"
SDK_DIR="$INSTALL_DIR/flutter"

echo "== Vérification du SDK Flutter (version requise : $REQUIRED_VERSION) =="

version_ok() {
  command -v flutter >/dev/null 2>&1 || return 1
  local current
  # Ligne type : "Flutter 3.44.2 • channel stable • ..."
  current="$(flutter --version 2>/dev/null | head -n1 | awk '{print $2}')"
  [ "$current" = "$REQUIRED_VERSION" ]
}

if version_ok; then
  echo "Flutter $REQUIRED_VERSION déjà installé et actif : $(command -v flutter)"
  exit 0
fi

if command -v flutter >/dev/null 2>&1; then
  echo "Flutter trouvé mais version différente ($(flutter --version | head -n1))."
  echo "Installation d'une version dédiée au projet dans $SDK_DIR, sans toucher à votre install existante."
fi

# --- Détection de la plateforme ---
OS_TYPE="$(uname -s)"
case "$OS_TYPE" in
  Linux*)   PLATFORM="linux" ;;
  Darwin*)  PLATFORM="macos" ;;
  MINGW*|MSYS*|CYGWIN*) PLATFORM="windows" ;;
  *)
    echo "Plateforme non reconnue : $OS_TYPE" >&2
    echo "Installez Flutter manuellement : https://docs.flutter.dev/get-started/install" >&2
    exit 1
    ;;
esac

BASE_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable"

case "$PLATFORM" in
  linux)
    ARCHIVE="flutter_linux_${REQUIRED_VERSION}-stable.tar.xz"
    URL="$BASE_URL/linux/$ARCHIVE"
    ;;
  macos)
    ARCH="$(uname -m)"
    if [ "$ARCH" = "arm64" ]; then
      ARCHIVE="flutter_macos_arm64_${REQUIRED_VERSION}-stable.zip"
    else
      ARCHIVE="flutter_macos_${REQUIRED_VERSION}-stable.zip"
    fi
    URL="$BASE_URL/macos/$ARCHIVE"
    ;;
  windows)
    ARCHIVE="flutter_windows_${REQUIRED_VERSION}-stable.zip"
    URL="$BASE_URL/windows/$ARCHIVE"
    ;;
esac

mkdir -p "$INSTALL_DIR"
TMP_ARCHIVE="$INSTALL_DIR/$ARCHIVE"

echo "Téléchargement de $ARCHIVE depuis $URL ..."
curl --fail --location --progress-bar -o "$TMP_ARCHIVE" "$URL"

echo "Extraction dans $INSTALL_DIR ..."
rm -rf "$SDK_DIR"
case "$ARCHIVE" in
  *.tar.xz) tar -xJf "$TMP_ARCHIVE" -C "$INSTALL_DIR" ;;
  *.zip)    unzip -q "$TMP_ARCHIVE" -d "$INSTALL_DIR" ;;
esac
rm -f "$TMP_ARCHIVE"

echo
echo "== Flutter $REQUIRED_VERSION installé dans $SDK_DIR =="
echo
echo "Pour l'utiliser dans ce terminal :"
echo "  export PATH=\"$SDK_DIR/bin:\$PATH\""
echo
echo "Pour le rendre permanent, ajoutez la ligne ci-dessus à votre ~/.bashrc, ~/.zshrc"
echo "(ou, sous Windows, ajoutez $SDK_DIR\\bin aux variables d'environnement PATH)."
echo

export PATH="$SDK_DIR/bin:$PATH"
flutter --version
