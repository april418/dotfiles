#!/bin/zsh
#            _
#    _______| |__  _ __ ___
#   |_  / __| '_ \| '__/ __|
#  _ / /\__ \ | | | | | (__
# (_)___|___/_| |_|_|  \___|
#


# ========================================
# zplugの設定
# ========================================
source ~/.zplug/init.zsh

# zsh上でvimのvisual modeっぽい動作をさせる
zplug "b4b4r07/zsh-vimode-visual"

# 未インストール項目をインストールする
if ! zplug check --verbose; then
  printf "Install zsh plugins? [Yes/No]: "
  if read -q; then
    echo; zplug install
  fi
fi

# コマンドをリンクして、PATH に追加し、プラグインは読み込む
zplug load --verbose


# ========================================
# モジュール読み込み
# ========================================
# イベントに関数をバインドできるようにする
autoload -Uz add-zsh-hook
# プロンプト
#autoload -Uz promptinit; promptinit
# バージョン管理情報を取得できるようにする
autoload -Uz vcs_info
# zshのバージョンごとに挙動を変えられるようにする
autoload -Uz is-at-least
# 端末情報を取得できるようにする
autoload -Uz terminfo
# 色を詳細に設定できるようにする
autoload -Uz colors; colors
# 補完機能を使用できるようにする
autoload -Uz compinit; compinit -u
# cdr を有効にする
autoload -Uz chpwd_recent_dirs cdr
# 履歴検索
autoload -Uz history-search-end


# ========================================
# 色
# ========================================
local DEFAULT=%{$reset_color%}
local RED=%{$fg[red]%}
local GREEN="%{[38;5;006m%}"
local YELLOW="%{[38;5;002m%}"
local YAMABUKI="%{[38;5;003m%}"
local BLUE=%{$fg[blue]%}
local PURPLE="%{[38;5;013m%}"
local WHITE=%{$fg[white]%}
local ORANGE="%{[38;5;009m%}"
local PINK="%{[38;5;005m%}"


# ========================================
# キー設定
# ========================================
# viライクなキーバインド
bindkey -v

terminfo_down_sc=$terminfo[cud1]$terminfo[cuu1]$terminfo[sc]$terminfo[cud1]
left_down_prompt_preexec() {
  print -rn -- $terminfo[el]
}
add-zsh-hook preexec left_down_prompt_preexec

function _update_input_mode() {
  case $KEYMAP in
    main|viins)
      INPUT_MODE="${BLUE}-- INSERT --$DEFAULT" ;;
    vicmd)
      INPUT_MODE="${WHITE}-- NORMAL --$DEFAULT" ;;
    vivis|vivli)
      INPUT_MODE="${ORANGE}-- VISUAL --$DEFAULT" ;;
  esac
}

# 入力モード変更時にプロンプト内容を更新
function zle-keymap-select zle-line-init zle-line-finish {
  _update_input_mode
  _update_main_prompt
  zle reset-prompt
}
zle -N zle-line-init
zle -N zle-line-finish
zle -N zle-keymap-select
zle -N edit-command-line

# Helper function
# use 'zle -la' option
# zsh -la option returns true if the widget exists
function has_widgets() {
  if [[ -z $1 ]]; then
    return 1
  fi
  zle -la "$1"
  return $?
}

# Helper function
# use bindkey -l
function has_keymap() {
  if [[ -z $1 ]]; then
    return 1
  fi
  bindkey -l "$1" >/dev/null 2>&1
  return $?
}

# Easy to escape
bindkey -M viins 'jj' vi-cmd-mode
has_keymap "vivis" && bindkey -M vivis 'jj' vi-visual-exit

# Merge emacs mode to viins mode
bindkey -M viins '\er' history-incremental-pattern-search-forward
bindkey -M viins '^?'  backward-delete-char
bindkey -M viins '^A'  beginning-of-line
bindkey -M viins '^B'  backward-char
bindkey -M viins '^D'  delete-char-or-list
bindkey -M viins '^E'  end-of-line
bindkey -M viins '^F'  forward-char
bindkey -M viins '^G'  send-break
bindkey -M viins '^H'  backward-delete-char
bindkey -M viins '^K'  kill-line
bindkey -M viins '^N'  down-line-or-history
bindkey -M viins '^P'  up-line-or-history
bindkey -M viins '^R'  history-incremental-pattern-search-backward
bindkey -M viins '^U'  backward-kill-line
bindkey -M viins '^W'  backward-kill-word
bindkey -M viins '^Y'  yank

# HOMEキー
bindkey "^[OH" beginning-of-line
# ENDキー
bindkey "^[OF" end-of-line
# DELETEキー
bindkey "^[[3~" delete-char

# Make more vim-like behaviors
bindkey -M vicmd 'gg' beginning-of-line
bindkey -M vicmd 'G'  end-of-line

# User-defined widgets
function peco-select-history() {
  # Check if peco is installed
  if type "peco" >/dev/null 2>&1; then
    # BUFFER is editing buffer contents string
    BUFFER=$(history 1 | sort -k1,1nr | perl -ne 'BEGIN { my @lines = (); } s/^\s*\d+\s*//; $in=$_; if (!(grep {$in eq $_} @lines)) { push(@lines, $in); print $in; }' | peco --query "$LBUFFER")
    # CURSOR is your key cursor position integer
    CURSOR=${#BUFFER}

    # just run
    zle accept-line
    # clear displat
    zle clear-screen
  else
    if is-at-least 4.3.9; then
      # Check if history-incremental-pattern-search-forward is available
      has_widgets "history-incremental-pattern-search-backward" && bindkey "^r" history-incremental-pattern-search-backward
    else
      history-incremental-search-backward
    fi
  fi
}
# Regist shell function as widget
zle -N peco-select-history
# Assign keybind
bindkey '^r' peco-select-history

# Enter
function do-enter() {
  if [ -n "$BUFFER" ]; then
    zle accept-line
    return
  fi

  /bin/ls -F
  zle reset-prompt
}
zle -N do-enter
bindkey '^m' do-enter

# https://github.com/zsh-users/zsh-history-substring-search
has_widgets 'history-substring-search-up' && bindkey -M emacs '^P' history-substring-search-up
has_widgets 'history-substring-search-down' && bindkey -M emacs '^N' history-substring-search-down
has_widgets 'history-substring-search-up' && bindkey -M viins '^P' history-substring-search-up
has_widgets 'history-substring-search-down' && bindkey -M viins '^N' history-substring-search-down
has_widgets 'history-substring-search-up' && bindkey -M vicmd 'k' history-substring-search-up
has_widgets 'history-substring-search-down' && bindkey -M vicmd 'j' history-substring-search-down

if is-at-least 5.0.8; then
  autoload -Uz surround
  zle -N delete-surround surround
  zle -N change-surround surround
  zle -N add-surround surround

  bindkey -a cs change-surround
  bindkey -a ds delete-surround
  bindkey -a ys add-surround
  bindkey -a S add-surround

  # if you want to use
  #
  #autoload -U select-bracketed
  #zle -N select-bracketed
  #for m in vivis viopp; do
  #    for c in {a,i}${(s..)^:-'()[]{}<>bB'}; do
  #        bindkey -M $m $c select-bracketed
  #    done
  #done

  #autoload -U select-quoted
  #zle -N select-quoted
  #for m in vivis viopp; do
  #    for c in {a,i}{\',\",\`}; do
  #        bindkey -M $m $c select-quoted
  #    done
  #done
fi


# ========================================
# プロンプト
# ========================================
# 右側まで入力がきたら時間表示を消す
setopt transient_rprompt
# 変数展開など便利なプロント
setopt prompt_subst

zstyle ":vcs_info:*" enable git svn hg bzr
zstyle ":vcs_info:*" formats "(%s)-[%b]"
zstyle ":vcs_info:*" actionformats "(%s)-[%b|%a]"
zstyle ":vcs_info:(svn|bzr):*" branchformat "%b:r%r"
zstyle ":vcs_info:bzr:*" use-simple true
zstyle ":vcs_info:*" max-exports 6

if is-at-least 4.3.10; then
  # %cと%uが使えるようになる
  # %c : ステージングされていて未コミットのファイルがあるときに展開
  # %u : アンステージドファイルがあるときに展開
  zstyle ":vcs_info:git:*" check-for-changes true
  # %cの内容
  zstyle ":vcs_info:git:*" stagedstr "$YELLOW<S> "
  # %uの内容
  zstyle ":vcs_info:git:*" unstagedstr "$RED<U> "
  # 表示内容
  zstyle ":vcs_info:git:*" formats "($GREEN%c%u%b%f)"
  # 特別な状況(merge/rebase)用の表示内容
  zstyle ":vcs_info:git:*" actionformats "(%s - $GREEN%c%u[%b|%a]%f)"
fi

# solarizedのテーマ設定に合わせて背景色を変える
case ${SOLARIZED_THEME:-dark} in
  light) bkg=white;;
  *)     bkg=black;;
esac

# git管理下のディレクトリにいるときは記号を表示(いるかこれ？)
function _prompt_char() {
  if $(git rev-parse --is-inside-work-tree >/dev/null 2>&1); then
    echo "$BLUE±$DEFAULT%k%b"
  else
    echo ' '
  fi
}

# メインプロンプトの定義
function _update_main_prompt() {
  vcs_info
  PROMPT="$DEFAULT%k%b
%K{$BKG}[%B$PURPLE%n$DEFAULT%K{$BKG}%B@%B$PURPLE%m %b$YAMABUKI%K{$BKG}%~$DEFAULT%K{$BKG}$vcs_info_msg_0_] [$INPUT_MODE%K{$BKG}]%E$DEFAULT%k%b
%K{$BKG}$(_prompt_char)%K{$BKG} %#$DEFAULT%k%b "
}

# 右プロンプト
#RPROMPT="!%{%B$CYAN%}%!%{$DEFAULT%b%}"
# 入力訂正プロンプト
SPROMPT="%K{$BKG}${WHITE}correct: $RED%R$DEFAULT%K{$BKG} -> $GREEN%r$DEFAULT%K{$BKG} ? [No/Yes/Abort/Edit]%E$DEFAULT%k%b
%K{$BKG}$(_prompt_char)%K{$BKG} %#$DEFAULT%k%b "

# プロンプト表示直前にプロンプト内容を更新
add-zsh-hook precmd _update_main_prompt


# ========================================
# 補完
# ========================================
# ディレクトリ名のみでcd
setopt auto_cd
# リストを詰めて表示
setopt list_packed
# ディレクトリ名の補完で末尾の / を自動的に付加し、次の補完に備える
setopt auto_param_slash
# ファイル名の展開でディレクトリにマッチした場合 末尾に / を付加
setopt mark_dirs
# 補完候補一覧でファイルの種別を識別マーク表示 (ls -F の記号)
setopt list_types
# 補完キー連打で順に補完候補を自動で補完
setopt auto_menu
# カッコの対応などを自動的に補完
setopt auto_param_keys
# コマンドラインでも # 以降をコメントと見なす
setopt interactive_comments
# コマンドラインの引数で --prefix=/usr などの = 以降でも補完できる
setopt magic_equal_subst
# 語の途中でもカーソル位置で補完
setopt complete_in_word
# カーソル位置は保持したままファイル名一覧を順次その場で表示
setopt always_last_prompt
# 日本語ファイル名等8ビットを通す
setopt print_eight_bit
# 拡張グロブで補完(~とか^とか。例えばless *.txt~memo.txt ならmemo.txt 以外の *.txt にマッチ)
setopt extended_glob
# 明確なドットの指定なしで.から始まるファイルをマッチ
setopt globdots
# 展開する前に補完候補を出させる(Ctrl-iで補完するようにする)
#bindkey "^I" menu-complete
# 補完候補を ←↓↑→ でも選択出来るようにする
zstyle ':completion:*:default' menu select=2
# 補完関数の表示を過剰にする編
zstyle ':completion:*' verbose yes
zstyle ':completion:*' completer _expand _complete _match _prefix _approximate _list _history
zstyle ':completion:*:messages' format $YELLOW'%d'$DEFAULT
zstyle ':completion:*:warnings' format $RED'No matches for:'$YELLOW' %d'$DEFAULT
zstyle ':completion:*:descriptions' format $YELLOW'completing: '$WHITE'%B%d%b'$DEFAULT
zstyle ':completion:*:corrections' format $YELLOW'%B%d '$RED'(errors: %e)%b'$DEFAULT
zstyle ':completion:*:options' description 'yes'
# グループ名に空文字列を指定すると，マッチ対象のタグ名がグループ名に使われる。
# したがって，すべての マッチ種別を別々に表示させたいなら以下のようにする
zstyle ':completion:*' group-name ''
# ファイル補完候補に色を付ける
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}


# ========================================
# 補正
# ========================================
# コマンドのスペルチェックを有効に
setopt correct


# ========================================
# pushd
# ========================================
# cdの履歴表示、cd - で一つ前のディレクトリへ
setopt autopushd
# 同ディレクトリを履歴に追加しない
setopt pushd_ignore_dups


# ========================================
# cdr
# ========================================
add-zsh-hook chpwd chpwd_recent_dirs
# cdr の設定
zstyle ':completion:*' recent-dirs-insert both
zstyle ':chpwd:*' recent-dirs-max 500
zstyle ':chpwd:*' recent-dirs-default true
zstyle ':chpwd:*' recent-dirs-file "$HOME/.cache/shell/chpwd-recent-dirs"
zstyle ':chpwd:*' recent-dirs-pushd true


# ========================================
# 履歴
# ========================================
# historyファイル
HISTFILE=~/.zsh_history
# ファイルサイズ
HISTFILESIZE=1000000
HISTSIZE=1000000
# saveする量
SAVEHIST=1000000
# 重複を記録しない
setopt hist_ignore_dups
# スペース排除
setopt hist_reduce_blanks
# 履歴ファイルを共有
setopt share_history
# zshの開始終了を記録
setopt EXTENDED_HISTORY
# 重複するコマンドが記憶されるとき、古い方を削除する
setopt hist_ignore_all_dups
# 重複するコマンドが保存されるとき、古い方を削除する。
setopt hist_save_no_dups
# コマンド履歴呼び出し
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^P" history-beginning-search-backward-end
bindkey "^N" history-beginning-search-forward-end


# ========================================
# alias
# ========================================
alias -g ...='../..'
alias -g ....='../../..'
alias printcolors='for c in {000..255}; do echo -n "\e[38;5;${c}m $c" ; [ $(($c%16)) -eq 15 ] && echo;done;echo'


# ========================================
# ターミナルがscreenのとき最終行に常に
# ディレクトリ名/コマンド名を表示させる
# ========================================
# screenの現在表示しているタブに実行されたコマンドを引数付きでセットする
function _set_executed_command_to_current_screen_tab() {
  echo -n "$*" | tr -s ' ' '\n' | tail -n 1 | echo -ne "\ek$1\e\\"
}

# screenの現在表示しているタブに現在のディレクトリをセットする
function _set_current_directory_to_current_screen_tab() {
  echo -ne "\ek$(basename $(pwd))\e\\"
}

# ターミナルがscreenならイベントに関数をバインド
if [ "$TERM"="screen-bce" ]
then
  add-zsh-hook preexec _set_executed_command_to_current_screen_tab
  add-zsh-hook precmd _set_current_directory_to_current_screen_tab
fi

