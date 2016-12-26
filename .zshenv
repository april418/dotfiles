#            _
#    _______| |__   ___ _ ____   __
#   |_  / __| '_ \ / _ \ '_ \ \ / /
#  _ / /\__ \ | | |  __/ | | \ V /
# (_)___|___/_| |_|\___|_| |_|\_/
#


# ========================================
# zshの環境設定
# ========================================
# 日本語環境
export LANG=ja_JP.UTF-8

# エディタはvi
export EDITOR=vim

# xtermを256色表示可能にする
if [ "$TERM"="xterm" ]
then
  export TERM="xterm-256color"
fi


# ========================================
# rbenv設定
# ========================================
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"


# ========================================
# screen設定
# ========================================
if [ "$TERM"="screen-bce" ]
then
  export SHELL_NAME="$(basename $SHELL)"
fi


# ========================================
# oh-my-zsh設定
# ========================================
# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=~/.oh-my-zsh

