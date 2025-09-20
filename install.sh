#!/bin/bash

# Script de instalación para OCR Screenshot
# Instala las dependencias necesarias y configura el script

set -e

echo "🔧 Instalando OCR Screenshot..."

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para imprimir mensajes con color
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Detectar el gestor de paquetes
if command -v apt-get &> /dev/null; then
    PKG_MANAGER="apt"
elif command -v yum &> /dev/null; then
    PKG_MANAGER="yum"
elif command -v dnf &> /dev/null; then
    PKG_MANAGER="dnf"
elif command -v pacman &> /dev/null; then
    PKG_MANAGER="pacman"
elif command -v zypper &> /dev/null; then
    PKG_MANAGER="zypper"
else
    print_error "No se pudo detectar el gestor de paquetes. Instala manualmente: flameshot, tesseract-ocr, xclip/wl-clipboard, libnotify-bin"
    exit 1
fi

print_status "Gestor de paquetes detectado: $PKG_MANAGER"

# Instalar dependencias
print_status "Instalando dependencias..."

case $PKG_MANAGER in
    "apt")
        sudo apt update
        sudo apt install -y flameshot tesseract-ocr tesseract-ocr-spa xclip libnotify-bin
        if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
            sudo apt install -y wl-clipboard
        fi
        ;;
    "yum"|"dnf")
        sudo $PKG_MANAGER install -y flameshot tesseract tesseract-langpack-spa xclip libnotify
        if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
            sudo $PKG_MANAGER install -y wl-clipboard
        fi
        ;;
    "pacman")
        sudo pacman -S --noconfirm flameshot tesseract tesseract-data-spa xclip libnotify
        if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
            sudo pacman -S --noconfirm wl-clipboard
        fi
        ;;
    "zypper")
        sudo zypper install -y flameshot tesseract tesseract-langpack-spa xclip libnotify
        if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
            sudo zypper install -y wl-clipboard
        fi
        ;;
esac

# Hacer el script ejecutable
chmod +x ocr.sh

# Crear enlace simbólico en /usr/local/bin para uso global
if [ -w /usr/local/bin ]; then
    sudo ln -sf "$(pwd)/ocr.sh" /usr/local/bin/ocr-screenshot
    print_success "Script instalado globalmente como 'ocr-screenshot'"
else
    print_warning "No se pudo instalar globalmente. Ejecuta: ./ocr.sh"
fi

# Verificar instalación
print_status "Verificando instalación..."

if command -v flameshot &> /dev/null; then
    print_success "✅ Flameshot instalado"
else
    print_error "❌ Flameshot no encontrado"
fi

if command -v tesseract &> /dev/null; then
    print_success "✅ Tesseract instalado"
else
    print_error "❌ Tesseract no encontrado"
fi

if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
    if command -v wl-copy &> /dev/null; then
        print_success "✅ wl-copy instalado (Wayland)"
    else
        print_error "❌ wl-copy no encontrado (Wayland)"
    fi
else
    if command -v xclip &> /dev/null; then
        print_success "✅ xclip instalado (X11)"
    else
        print_error "❌ xclip no encontrado (X11)"
    fi
fi

if command -v notify-send &> /dev/null; then
    print_success "✅ notify-send instalado"
else
    print_error "❌ notify-send no encontrado"
fi

echo ""
print_success "🎉 Instalación completada!"
echo ""
echo "📖 Uso:"
echo "  ocr-screenshot    # Si se instaló globalmente"
echo "  ./ocr.sh          # Si no se instaló globalmente"
echo ""
echo "🔧 El script detecta automáticamente si usas X11 o Wayland"
echo "📝 Soporta reconocimiento de texto en español e inglés"
