#            _
#    _______| |__   ___ _ ____   __
#   |_  / __| '_ \ / _ \ '_ \ \ / /
#  _ / /\__ \ | | |  __/ | | \ V /
# (_)___|___/_| |_|\___|_| |_|\_/
#


# ========================================
#   環境設定
# ========================================
# 言語を日本語にする
export LANG=ja_JP.UTF-8

# エディタをvimにする
export EDITOR=vim

# xtermを256色表示可能にする
if [ "$TERM"="xterm" ]; then
  export TERM="xterm-256color"
fi

# $HOME/binにパスを通す
export PATH=$HOME/bin:$PATH

# localのzshenvを読み込む
if [ -f ~/.zshenv.local ]; then
  source ~/.zshenv.local
fi


# ========================================
#   rbenv設定
# ========================================
if [ -d ~/.rbenv ]; then
  export PATH="$HOME/.rbenv/bin:$PATH"
  eval "$($HOME/.rbenv/bin/rbenv init -)"
fi


# ========================================
#   screen設定
# ========================================
if [ ! -z "$STY" ]; then
  export SHELL_NAME="$(basename $SHELL)"
fi

