#!/bin/bash
#           _                    _
#  ___  ___| |_ _   _ _ __   ___| |__
# / __|/ _ \ __| | | | '_ \ / __| '_ \
# \__ \  __/ |_| |_| | |_) |\__ \ | | |
# |___/\___|\__|\__,_| .__(_)___/_| |_|
#                    |_|
#

# ostype returns the lowercase OS name
ostype() {
  uname | tr "A-Z" "a-z"
}

# os_detect export the PLATFORM variable as you see fit
os_detect() {
  export PLATFORM
  case "$(ostype)" in
    *'linux'*)
      PLATFORM='linux'
      ;;
    *'darwin'*)
      PLATFORM='osx'
      ;;
    *'bsd'*)
      PLATFORM='bsd'
      ;;
    *)
      PLATFORM='unknown'
      ;;
  esac
}

# is_osx returns true if running OS is Macintosh
is_osx() {
  os_detect
  if [ "$PLATFORM" = "osx" ]; then
    return 0
  else
    return 1
  fi
}
alias is_mac=is_osx

# is_linux returns true if running OS is GNU/Linux
is_linux() {
  os_detect
  if [ "$PLATFORM" = "linux" ]; then
    return 0
  else
    return 1
  fi
}

# is_bsd returns true if running OS is FreeBSD
is_bsd() {
  os_detect
  if [ "$PLATFORM" = "bsd" ]; then
    return 0
  else
    return 1
  fi
}

# get_os returns OS name of the platform that is running
get_os() {
  local os
  for os in osx linux bsd; do
    if is_$os; then
      echo $os
    fi
  done
}

# is_exists returns true if executable $1 exists in $PATH
is_exists() {
  which "$1" >/dev/null 2>&1
  return $?
}

e_newline() {
  printf "\n"
}

e_header() {
  printf " \033[37;1m%s\033[m\n" "$*"
}

e_error() {
  printf " \033[31m%s\033[m\n" "✖ $*" 1>&2
}

e_warning() {
  printf " \033[31m%s\033[m\n" "$*"
}

e_done() {
  printf " \033[37;1m%s\033[m...\033[32mOK\033[m\n" "✔ $*"
}

e_arrow() {
  printf " \033[37;1m%s\033[m\n" "-> $*"
}

e_indent() {
  for ((i=0; i<${1:-4}; i++)); do
    echon " "
  done

  if [ -n "$2" ]; then
    echo "$2"
  else
    cat <&0
  fi
}

e_success() {
  printf " \033[37;1m%s\033[m%s...\033[32mOK\033[m\n" "✔ " "$*"
}

e_failure() {
  die "${1:-$FUNCNAME}"
}

ink() {
  if [ "$#" -eq 0 -o "$#" -gt 2 ]; then
    echo "Usage: ink <color> <text>"
    echo "Colors:"
    echo "  black, white, red, green, yellow, blue, purple, cyan, gray"
    return 1
  fi

  local open="\033["
  local close="${open}0m"
  local black="0;30m"
  local red="1;31m"
  local green="1;32m"
  local yellow="1;33m"
  local blue="1;34m"
  local purple="1;35m"
  local cyan="1;36m"
  local gray="0;37m"
  local white="$close"

  local text="$1"
  local color="$close"

  if [ "$#" -eq 2 ]; then
    text="$2"
    case "$1" in
      black | red | green | yellow | blue | purple | cyan | gray | white)
        eval color="\$$1"
        ;;
    esac
  fi

  printf "${open}${color}${text}${close}"
}

logging() {
  if [ "$#" -eq 0 -o "$#" -gt 2 ]; then
    echo "Usage: ink <fmt> <msg>"
    echo "Formatting Options:"
    echo "  TITLE, ERROR, WARN, INFO, SUCCESS"
    return 1
  fi

  local color=
  local text="$2"

  case "$1" in
    TITLE)
      color=yellow
      ;;
    ERROR | WARN)
      color=red
      ;;
    INFO)
      color=blue
      ;;
    SUCCESS)
      color=green
      ;;
    *)
      text="$1"
  esac

  timestamp() {
    ink gray "["
    ink purple "$(date +%H:%M:%S)"
    ink gray "] "
  }

  timestamp; ink "$color" "$text"; echo
}

log_pass() {
  logging SUCCESS "$1"
}

log_fail() {
  logging ERROR "$1" 1>&2
}

log_fail() {
  logging WARN "$1"
}

log_info() {
  logging INFO "$1"
}

log_echo() {
  logging TITLE "$1"
}

# die returns exit code error and echo error message
die() {
  e_error "$1" 1>&2
  exit "${2:-1}"
}

# is_debug returns true if $DEBUG is set
is_debug() {
  if [ "$DEBUG" = 1 ]; then
    return 0
  else
    return 1
  fi
}

# echon is a script to emulate the -n flag functionality with 'echo'
# for Unix systems that don't have that available.
echon() {
  echo "$*" | tr -d '\n'
}

# noecho is the same as echon
noecho() {
  if [ "$(echo -n)" = "-n" ]; then
    echo "${*:-> }\c"
  else
    echo -n "${@:-> }"
  fi
}

# Set DOTPATH as default variable
if [ -z "${DOTPATH:-}" ]; then
  DOTPATH=~/.dotfiles
  export DOTPATH
fi

DOTFILES_ROOT="https://github.com/april418/dotfiles"
DOTFILES_GIT="$DOTFILES_ROOT.git"
DOTFILES_TAR="$DOTFILES_ROOT/archive/master.tar.gz"
export DOTFILES_GIT
export DOTFILES_TAR

EXCLUSIONS=(".DS_Store" ".git" ".gitmodules" ".travis.yml")

dotfiles_logo='
  ====================================
        _       _    __ _ _
     __| | ___ | |_ / _(_) | ___  ___
    / _` |/ _ \| __| |_| | |/ _ \/ __|
   | (_| | (_) | |_|  _| | |  __/\__ \
  (_)__,_|\___/ \__|_| |_|_|\___||___/

  ====================================
  Copyright (c) 2017 @april418
  Licensed under the MIT license.

  Use @b4b4r07 dotfiles as reference.
  Thanks a lot!
  ====================================
'

# clone or pull --rebase dotfiles repository
clone_or_update_dotfiles() {
  if [ -d "$DOTPATH" ]; then
    cd "$DOTPATH"
    git pull --rebase
  else
    git clone "$DOTFILES_GIT" "$DOTPATH"
  fi
}

# returns true if EXCLUSIONS conrains an argument
is_exclusion() {
  local e

  for e in $EXCLUSIONS
  do
    if [ "$e" == "$1" ]; then
      return 0
    fi
  done

  return 1
}

# create symbollinks for all dotfiles
create_symbollinks() {
  local file
  local src
  local dist

  for file in .??*
  do
    if [ -f $file ]; then
      src="$DOTPATH/$file"
      dist="$HOME/$file"

      if is_debug; then
        :
      else
        if [ -e $dist ]; then
          mv -f "$dist" "$dist.old"
        fi
        ln -s "$src" "$dist"
      fi
      echo "$src $(e_arrow "$dist")"
    fi
  done
}

dotfiles_download() {
  e_newline
  e_header "Downloading dotfiles..."

  if is_debug; then
    :
  else
    if is_exists "git"; then
      clone_or_update_dotfiles
    elif is_exists "curl" || is_exists "wget"; then
      if is_exists "curl"; then
        curl -L "$DOTFILES_TAR"
      elif is_exists "wget"; then
        wget -O - "$DOTFILES_TAR"
      fi | tar xvz

      if [ ! -d dotfiles-master ]; then
        log_fail "dotfiles-master: not found"
        exit 1
      fi

      command mv -f dotfiles-master "$DOTPATH"
    else
      log_fail "curl or wget required"
      exit 1
    fi
  fi
  e_newline && e_done "Download"
}

dotfiles_deploy() {
  e_newline
  e_header "Deploying dotfiles..."

  if [ ! -d $DOTPATH ]; then
    log_fail "$DOTPATH: not found"
    exit 1
  fi

  cd "$DOTPATH"

  if is_debug; then
    :
  else
    create_symbollinks
  fi && e_newline && e_done "Deploy"
}

dotfiles_initialize() {
  local init_path
  e_newline
  e_header "Initializing dotfiles..."

  if is_debug; then
    :
  else
    init_path="$DOTPATH/etc/init/$(get_os)/init.sh"
    if [ -e $init_path ]; then
      bash $init_path
    else
      e_warning "Init file not found."
    fi
  fi && e_newline && e_done "Initialize"
}

# A script for the file named "install"
dotfiles_install() {
  # 1. Download the repository
  # ==> downloading
  #
  # Priority: git > curl > wget
  dotfiles_download &&

  # 2. Deploy dotfiles to your home directory
  # ==> deploying
  dotfiles_deploy &&

  # 3. Execute all sh files within etc/init/
  # ==> initializing
  dotfiles_initialize
}

trap "e_error 'terminated'; exit 1" INT ERR
echo "$dotfiles_logo"
dotfiles_install

# Restart shell if specified "bash -c $(curl -L {URL})"
# not restart:
#   curl -L {URL} | bash
if [ -p /dev/stdin ]; then
  e_warning "Now continue with Rebooting your shell"
else
  e_newline
  e_arrow "Restarting your shell..."
  exec "${SHELL:-/bin/zsh}"
fi

