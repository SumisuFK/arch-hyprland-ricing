#!/bin/bash

set -Eeuo pipefail

# PATHS
SCRIPT_DIR="$(pwd)"

# TEXT COLORS
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
BOLD='\033[1m'
RESET='\033[0m'

info() {
    echo -e "${CYAN}${BOLD}[INFO]${RESET} $*"
}

ok() {
    echo -e "${GREEN}${BOLD}[OK]${RESET} $*"
}

warn() {
    echo -e "${YELLOW}${BOLD}[WARN]${RESET} $*"
}

err() {
    echo -e "${RED}${BOLD}[ERR]${RESET} $*"
}

# VARIABLES



# BACKUP_MODE=""

# ask_backup() {
#     echo "Если в системе уже есть такие же файлы/директории, нужен ли бэкап?"
#     echo "1 - сделать бэкап и заменить"
#     echo "2 - заменить без бэкапа"
#     echo "3 - отменить установку"

#     read -r -p "Введите 1, 2 или 3: " choice

#     case "$choice" in
# 	1)
# 	    BACKUP_MODE="backup"
# 	    ;;
# 	2)
# 	    BACKUP_MODE="replace"
# 	    ;;
# 	3)
# 	    echo "Установка отменена"
# 	    exit 1
# 	    ;;
# 	*)
# 	    echo "Неверный ввод."
# 	    exit 1
# 	    ;;
#     esac
# }

#   ---------- CHECKS----------
start_confirmation() {
    warn "Скрипт перезапишет существующие конфиги"
    warn "Рекомендуется запускать на чистой системе"
    
    read -rp "Продолжить? [Y/N]: " choice

    case "$choice" in
    Y|y)
        info "Продолжение установки"
        ;;
    N|n)
        echo "Установка отменена"
        exit 1
        ;;
    *)
        err "Неверный ввод"
        exit 1
        ;;
    esac
}

check_status() {
    if [ $? -eq 0 ]; then
	echo -e "${GREEN}${BOLD}[OK] $1${RESET}"
    else
	echo -e "${RED}${BOLD}[ERROR] Error:${RESET} $2"
	exit 1
    fi
}

check_arch() {
    if [[ -f /etc/arch-release ]]; then
    	ok "Arch Linux обнаружен"
    else
	    err "Этот скрипт поддерживает только Arch Linux"
        exit 1
    fi
}

check_not_root() {
    if [[ "$(id -u)" -ne 0 ]]; then
	    ok "Скрипт запущен от обычного юзера"
   else
        err "Не запускайте скрипт от рута"
        exit 1
   fi
}

check_sudo() {
    if command -v sudo >/dev/null 2>&1; then
	    ok "sudo найден"
    else
        err "sudo не установлен"
	exit 1
    fi
}

check_pacman() {
    if command -v pacman >/dev/null 2>&1; then
	    ok "pacman найден"
    else
	    err "pacman не установлен"
	exit 1
    fi
}

check_internet() {
    info "Проверка интернет соединения..."
    if ping -c 1 yandex.ru >/dev/null 2>&1; then
	    ok "Интернет соединение работает"
    else
	    err "Нет интернет соединения"
        exit 1
    fi
}

run_checks() {
    info "Запуск системных проверок..."

    check_arch
    check_not_root
    check_sudo
    check_pacman
    check_internet

    ok "Все проверки успешно прошли"
}

# backup_file() {
#     local file="$1"
#     local backup="${file}.bak.$(date +%Y%m%d_%H%M%S)"
#     warn "Backing up ${file} to ${backup}"
#     mv "$file" "$backup"
#     check_status "Бэкап создан" "Ошибка бэкапа"
# }

install_yay() {
    local tmp_dir

    if command -v yay >/dev/null 2>&1; then
	    ok "yay уже установлен"
    else
	    info "Установка yay..."
        
        sudo pacman -Syu --noconfirm
	    sudo pacman -S --needed --noconfirm git base-devel
	    check_status "git и base-devel установлены" "Не удалось установить git и base-devel"

	    tmp_dir="$(mktemp -d)"

	    git clone https://aur.archlinux.org/yay.git "$tmp_dir/yay"
	    check_status "Репозиторий yay клонирован" "Не удалось клонировать репозиторий yay"

	    cd "$tmp_dir/yay"
	    makepkg -si --noconfirm
	    check_status "yay установлен" "Не удалось установить yay"

	    cd "$SCRIPT_DIR"
	    rm -rf "$tmp_dir"

	    if command -v yay >/dev/null 2>&1; then
	        ok "Установка yay завершена"
	    else
	        err "yay не найден после установки"
	        exit 1
	    fi
    fi
}

pacman_packages=(
    bash-completion
    blueman
    bluez
    bluez-utils
    brightnessctl
    curl
    fastfetch
    ffmpegthumbnailer
    file-roller
    geoclue
    grim
    htop
    hyprland
    hyprpaper
    jq
    kitty
    lsof
    lxappearance
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    orchis-theme
    pacman-contrib
    pamixer
    pavucontrol
    pipewire-alsa
    pipewire-pulse
    playerctl
    polkit-gnome
    qt6-multimedia-ffmpeg
    quickshell
    rofi
    slurp
    swappy
    swaync
    thunar
    thunar-archive-plugin
    ttf-dejavu
    ttf-jetbrains-mono-nerd
    ttf-liberation
    ttf-roboto
    tumbler
    vim
    waybar
    wayland
    wayland-protocols
    wireplumber
    wl-clipboard
    xdg-desktop-portal
    xdg-desktop-portal-gtk
    xdg-desktop-portal-hyprland
    xdg-user-dirs
    zsh
    sddm
    network-manager-applet
)

aur_packages=(
    swaylock-effects
    tela-icon-theme
    wlogout 
)

# ---------- INSTALL PACKAGES ----------
install_pacman_packages() {
    info "Установка pacman пакетов..."
    sudo pacman -S --needed --noconfirm "${pacman_packages[@]}"
    check_status "Pacman пакеты установлены успешно" "Ошибка при установке pacman пакетов"
}

install_aur_packages() {
    info "Установка aur пакетов..."
    yay -S --needed --noconfirm "${aur_packages[@]}"
    check_status "AUR пакеты установлены успешно" "Ошибка при установке AUR пакетов"
}

enable_services() {
    info "Включение сервисов..."

    sudo systemctl enable bluetooth
    check_status "Bluetooth добавлен в автозапуск" "Не удалось включить Bluetooth"

    sudo systemctl enable sddm
    check_status "SDDM добавлен в автозапуск" "Не удалось включить SDDM"
}

install_oh_my_zsh() {
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        ok "Oh My Zsh уже установлен"
    else
        info "Установка Oh My Zsh..."

        if RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL --retry 3 --retry-delay 5 --retry-all-errors --connect-timeout 30 https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"; then
            ok "Oh My Zsh установлен"
        else
            err "Не удалось установить Oh My Zsh"
            err "Проверьте интернет, DNS или доступ к raw.gihubusercontent.com"
        fi
        zsh
        ok "Настройка zsh завершена"
    fi
}

copy_config_dir() {
    local dir_name="$1"
    local src="$SCRIPT_DIR/$dir_name"
    local dest="$HOME/.config/$dir_name"

    if [[ -e "$src" ]]; then
        info "Копирование конфига $dir_name"
        
        if [[ -e "$dest" ]]; then
            warn "Удаление старого конфига $dest"
            rm -rf "$dest"
            check_status "Старый конфиг $dir_name удалён" "Не удалось удалить старый конфиг $dir_name"
        fi

        cp -r "$src" "$dest"
        check_status "Конфиг $dir_name скопирован" "Не удалось скопировать конфиг $dir_name"
    else
        warn "Папка $src не найдена, пропускаю"
    fi
}

copy_configs() {
    info "Копирование конфигов..."

    mkdir -p "$HOME/.config"
    check_status "Директория ~/.config подготовлена" "Не удалось создать ~/.config"

    copy_config_dir "hypr"
    copy_config_dir "waybar"
    copy_config_dir "kitty"
    copy_config_dir "rofi"
    copy_config_dir "swaync"
    copy_config_dir "quickshell"
    copy_config_dir "fastfetch"
    copy_config_dir "swaylock"
    copy_config_dir "wlogout"

    ok "Конфиги скопированы"
}

copy_home_files() {
    info "Копирование файлов в домашнюю директорию..."

    if [[ -f "$SCRIPT_DIR/.bashrc" ]]; then
        cp "$SCRIPT_DIR/.bashrc" "$HOME/.bashrc"
        check_status ".bashrc скопирован" "Не удалось скопировать .bashrc"
    else
        warn ".bashrc не найден, пропускаю"
    fi
}

copy_pictures() {
    info "Копирование изображений..."

    if [[ -d "$SCRIPT_DIR/Pictures" ]]; then
        mkdir -p "$HOME/Pictures"
        check_status "Директория ~/Pictures подготовлена" "Не удалось создать ~/Pictures"

        cp -r "$SCRIPT_DIR/Pictures"* "$HOME/Pictures/"
        check_status "Изображения скопированы" "Не удалось скопировать изображения"
    else
        warn "Папка Pictures не найдена, пропускаю"
    fi
}

final_summary() {
    echo
    echo -e "${GREEN}${BOLD}=====================================${RESET}"
    echo -e "${GREEN}${BOLD}Установка успешно завершена${RESET}"
    echo -e "${GREEN}${BOLD}=====================================${RESET}"
    echo
}

reboot_system() {
    local choice

    while true; do
        echo
        warn "Для применения всех изменений требуется перезагрузка"

        read -rp "Перезагрузить систему сейчас? [Y/N]: " choice
        case "$choice" in
            Y|y)
                info "Перезагрузка системы..."
                sudo reboot
                ;;
            N|n)
                echo "Перезагрузка отменена"
                ;;
            *)
                warn "Введите Y или N"
                ;;
        esac
    done
}

main() {
    # ask_backup
    start_confirmation
    run_checks
    install_yay
    install_pacman_packages
    install_aur_packages
    ok "Установка пакетов завершена"
    
    enable_services

    install_oh_my_zsh
    

    copy_configs
    copy_home_files
    copy_pictures
    ok "Копирование файлов завершено"

    final_summary
    reboot_system
}

main "$@"
