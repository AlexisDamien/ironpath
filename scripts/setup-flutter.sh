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
if [ -d "$SDK_DIR" ]; then
  rm -rf "$SDK_DIR"
  if [ -d "$SDK_DIR" ]; then
    echo "Erreur : impossible de supprimer entièrement $SDK_DIR (fichier verrouillé par un" >&2
    echo "processus en cours, ou permissions insuffisantes). Fermez tout terminal/IDE utilisant" >&2
    echo "Flutter, puis relancez ce script. Abandon pour éviter un mélange d'anciens et de" >&2
    echo "nouveaux fichiers SDK." >&2
    rm -f "$TMP_ARCHIVE"
    exit 1
  fi
fi
case "$ARCHIVE" in
  *.tar.xz) tar -xJf "$TMP_ARCHIVE" -C "$INSTALL_DIR" ;;
  *.zip)    unzip -q "$TMP_ARCHIVE" -d "$INSTALL_DIR" ;;
esac
rm -f "$TMP_ARCHIVE"

echo
echo "=================================================================="
echo "== Flutter $REQUIRED_VERSION installé dans $SDK_DIR =="
echo "=================================================================="
echo
echo "!! ATTENTION : ce PATH n'est actif QUE dans ce terminal, pour cette"
echo "!! session. Si vous fermez cette fenêtre et en ouvrez une nouvelle,"
echo "!! 'flutter' pointera de nouveau vers une autre installation si vous"
echo "!! en avez une, ou ne sera plus trouvé du tout."
echo
echo "ETAPE OBLIGATOIRE pour une utilisation permanente :"
echo
case "$PLATFORM" in
  windows)
    echo "  Windows : ajoutez ce chemin à vos Variables d'environnement (PATH) :"
    echo "    $SDK_DIR/bin" | sed 's#/#\\\\#g'
    echo "  (Panneau de configuration > Variables d'environnement > PATH utilisateur)"
    echo "  Fermez ENSUITE tous vos terminaux et rouvrez-en un nouveau."
    ;;
  *)
    echo "  export PATH=\"$SDK_DIR/bin:\$PATH\""
    echo "  A ajouter à votre ~/.bashrc ou ~/.zshrc, puis rouvrez un terminal."
    ;;
esac
echo

export PATH="$SDK_DIR/bin:$PATH"
flutter --version

INSTALLED_VERSION="$(flutter --version 2>/dev/null | head -n1 | awk '{print $2}')"
if [ "$INSTALLED_VERSION" != "$REQUIRED_VERSION" ]; then
  echo
  echo "ATTENTION : version installée ($INSTALLED_VERSION) différente de celle attendue" >&2
  echo "($REQUIRED_VERSION). L'archive téléchargée ou l'extraction semble incorrecte." >&2
  echo "Supprimez $SDK_DIR manuellement et relancez ce script." >&2
  exit 1
fi