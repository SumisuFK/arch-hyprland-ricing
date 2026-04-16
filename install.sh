#!/bin/bash

set -Eeuo pipefail

# PATHS
SCRIPT_DIR="$(pwd)"

PACMAN_LIST="$SCRIPT_DIR/pkglist_pacman.txt"
AUR_LIST="$SCRIPT_DIR/pkglist_aur.txt"

# TEXT COLORS
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
BOLD='\033[1m'
RESET='\033[0m'

# VARIABLES
BACKUP_MODE=""

ask_backup() {
    echo "Если в системе уже есть такие же файлы/директории, нужен ли бэкап?"
    echo "1 - сделать бэкап и заменить"
    echo "2 - заменить без бэкапа"
    echo "3 - отменить установку"

    read -r -p "Введите 1, 2 или 3: " choice

    case "$choice" in
	1)
	    BACKUP_MODE="backup"
	    ;;
	2)
	    BACKUP_MODE="replace"
	    ;;
	3)
	    echo "Установка отменена"
	    exit 1
	    ;;
	*)
	    echo "Неверный ввод."
	    exit 1
	    ;;
    esac
}

# CHECKS
check_status() {
    if [ $? -eq 0 ]; then
	echo -e "${GREEN}${BOLD}$1${RESET}"
    else
	echo -e "${RED}${BOLD}Error:${RESET} $2"
	exit 1
    fi
}

check_arch() {
    if [[ -f /etc/arch-release ]]; then
	echo -e "${GREEN}${BOLD}Arch Linux обнаружен${RESET}"
    else
	echo -e "${RED}${BOLD}Этот скрипт поддерживает только Arch Linux${RESET}"
        exit 1
    fi
}

check_not_root() {
    if [[ "$(id -u)" -ne 0 ]]; then
	echo -e "${GREEN}${BOLD}Скрипт запущен от обычного юзера${RESET}"
   else
        echo -e "${RED}${BOLD}Не запускайте скрипт от рута${RESET}"
        exit 1
   fi
}

check_sudo() {
    if command -v sudo >/dev/null 2>&1; then
	echo -e "${GREEN}${BOLD}sudo найден${RESET}"
    else
        echo -e "${RED}${BOLD}sudo не установлен${RESET}"
	exit 1
    fi
}

check_pacman() {
    if command -v pacman >/dev/null 2>&1; then
	echo -e "${GREEN}${BOLD}pacman найден${RESET}"
    else
	echo -e "${RED}${BOLD}pacman не установлен${RESET}"
	exit 1
    fi
}

check_internet() {
    echo -e "${CYAN}${BOLD}Проверка интернет соединения...${RESET}"
    if ping -c 1 yandex.ru >/dev/null 2>&1; then
	echo -e "${GREEN}${BOLD}Интернет соединение работает${RESET}"
    else
	echo -e "${RED}${BOLD}Нет интернет соединения${RESET}"
        exit 1
    fi
}

run_checks() {
    echo -e "${CYAN}${BOLD}Запуск системных проверок...${RESET}"

    check_arch
    check_not_root
    check_sudo
    check_pacman
    check_internet

    echo -e "${GREEN}${BOLD}Все проверки прошли успешно${RESET}"
}

backup_file() {
    local file="$1"
    local backup="${file}.bak.$(date +%Y%m%d_%H%M%S)"
    echo -e "${YELLOW}${BOLD}Backing up ${file} to ${backup}${RESET}"
    mv "$file" "$backup"
    check_status "Бэкап создан" "Ошибка бэкапа"
}

install_yay() {
    local tmp_dir

    if command -v yay >/dev/null 2>&1; then
	echo -e "${GREEN}${BOLD}yay уже установлен${RESET}"
    else
	echo -e "${CYAN}${BOLD}Установка yay...${RESET}"

	sudo pacman -S --needed --noconfirm git base-devel
	check_status "git и base-devel установлены" "Не удалось установить git и base-devel"

	tmp_dir="$(mktemp -d)"

	git clone https://aur/archlinux.org/yay.git "$tmp_dir/yay"
	check_status "Репозиторий yay склонирован" "Не удалось клонировать репозиторий yay"

	cd "$tmp_dir/yay"
	makepkg -si --noconfirm
	check_status "yay установлен" "Не удалось установить yay"

	cd "$SCRIPT_DIR"
	rm -rf "$tmp_dir"

	if command -v yay >/dev/null 2>&1; then
	    echo -e "${GREEN}${BOLD}Установка yay завершена${RESET}"
	else
	    echo -e "${RED}${BOLD}yay не найден после установки${RESET}"
	    exit 1
	fi
    fi
}

pacman_packages=(
    bash-competition
    blueman    
)

aur_packages=(
    
)

# INSTALL PACKAGES
echo -e "${CYAN}${BOLD}Установка pacman пакетов...${RESET}"
sudo pacman -S --needed --noconfirm "${pacman_packages[@]}"
check_status "Pacman пакеты установлены успешно" "Ошибка при установке pacman пакетов"


