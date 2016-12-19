#            _
#    _______| |__   ___ _ ____   __
#   |_  / __| '_ \ / _ \ '_ \ \ / /
#  _ / /\__ \ | | |  __/ | | \ V /
# (_)___|___/_| |_|\___|_| |_|\_/
#


# ========================================
# terminal
# ========================================
if [ $TERM = "xterm" ]
then
  export TERM="xterm-256color"
fi


# ========================================
# rbenvの設定
# ========================================
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"


# ========================================
# screenのstatusbarにディレクトリ名/コマンド名を表示させる
# ========================================
if [ $TERM = 'screen-bce' ]
then
  export SHELL_NAME="$(basename $SHELL)"
  preexec() {
    echo -n "$*" | tr -s ' ' '\n' | tail -n 1 | echo -ne "\ek$1\e\\"
  }
  precmd() {
    echo -ne "\ek$(basename $(pwd))\e\\"
  }
fi

