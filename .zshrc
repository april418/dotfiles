#            _
#    _______| |__  _ __ ___
#   |_  / __| '_ \| '__/ __|
#  _ / /\__ \ | | | | | (__
# (_)___|___/_| |_|_|  \___|
#


# ========================================
# 色
# ========================================
# 色のセット
autoload colors
colors
local DEFAULT=%{$reset_color%}
local RED=%{$fg[red]%}
local LIGHT_RED="%{[38;5;009m%}"
local GREEN=%{$fg[green]%}
local LIGHT_GREEN="%{[38;5;010m%}"
local YELLOW=%{$fg[yellow]%}
local LIGHT_YELLOW="%{[38;5;011m%}"
local LIGHT_BLUE="%{[38;5;033m%}"
local SKY_BLUE="%{[38;5;081m%}"
local BLUE=%{$fg[blue]%}
local PURPLE=%{$fg[purple]%}
local CYAN=%{$fg[cyan]%}
local WHITE=%{$fg[white]%}
local CHERRY_BLOSSOM="%{[38;5;212m%}"
local ORANGE="%{[38;5;208m%}"
# LS_COLORSを設定
eval $(dircolors ~/dircolors/solarized/dircolors.ansi-universal)


# ========================================
# 表示
# ========================================
# 右側まで入力がきたら時間表示を消す
setopt transient_rprompt
# 変数展開など便利なプロント
setopt prompt_subst
# viライクなキーバインド
bindkey -v
# 日本語環境
export LANG=ja_JP.UTF-8
# エディタはvi
export EDITOR=vim

autoload -Uz add-zsh-hook
autoload -U promptinit; promptinit
autoload -Uz vcs_info
autoload -Uz is-at-least


# ========================================
# prompt
# ========================================
# begin VCS
zstyle ":vcs_info:*" enable git svn hg bzr
zstyle ":vcs_info:*" formats "(%s)-[%b]"
zstyle ":vcs_info:*" actionformats "(%s)-[%b|%a]"
zstyle ":vcs_info:(svn|bzr):*" branchformat "%b:r%r"
zstyle ":vcs_info:bzr:*" use-simple true
zstyle ":vcs_info:*" max-exports 6

if is-at-least 4.3.10; then
  zstyle ":vcs_info:git:*" check-for-changes true # commitしていないのをチェック
  zstyle ":vcs_info:git:*" stagedstr "<S>"
  zstyle ":vcs_info:git:*" unstagedstr "<U>"
  zstyle ":vcs_info:git:*" formats "(%b) %c%u"
  zstyle ":vcs_info:git:*" actionformats "(%s)-[%b|%a] %c%u"
fi
# end VCS

function _update_vcs_info_msg() {
  psvar=()
  LANG=en_US.UTF-8 vcs_info
  [[ -n "$vcs_info_msg_0_" ]] && psvar[1]="$vcs_info_msg_0_"
}

# Linux bashと同じ形式
1="${SKY_BLUE}[@${HOST%%.*} %1~]%(!.#.$) $DEFAULT"
PS1="[$ORANGE%n$DEFAULT@$SKY_BLUE%m$DEFAULT $LIGHT_BLUE%1~$DEFAULT]%(!.#.$) "
PROMPT="[$ORANGE%n$DEFAULT@$SKY_BLUE%m$DEFAULT $LIGHT_BLUE%1~$DEFAULT]%(!.#.$) "
SPROMPT="correct: $LIGHT_RED%R$DEFAULT -> $LIGHT_GREEN%r$DEFAULT ? [No/Yes/Abort/Edit]"
RPROMPT="["
RPROMPT+="$LIGHT_BLUE%~$DEFAULT"
add-zsh-hook precmd _update_vcs_info_msg
RPROMPT+="%1(v|$LIGHT_GREEN%1v|)$DEFAULT"
RPROMPT+="]"


# ========================================
# 補完
# ========================================
# 補完機能
autoload -U compinit
# 補完を賢くする
compinit -u
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
bindkey "^I" menu-complete
# 補完候補を ←↓↑→ でも選択出来るようにする
zstyle ':completion:*:default' menu select=2
# 補完関数の表示を過剰にする編
zstyle ':completion:*' verbose yes
zstyle ':completion:*' completer _expand _complete _match _prefix _approximate _list _history
zstyle ':completion:*:messages' format $LIGHT_YELLOW'%d'$DEFAULT
zstyle ':completion:*:warnings' format $LIGHT_RED'No matches for:'$LIGHT_YELLOW' %d'$DEFAULT
zstyle ':completion:*:descriptions' format $LIGHT_YELLOW'completing %B%d%b'$DEFAULT
zstyle ':completion:*:corrections' format $LIGHT_YELLOW'%B%d '$LIGHT_RED'(errors: %e)%b'$DEFAULT
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
# cdr, add-zsh-hook を有効にする
autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
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
autoload -Uz history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^P" history-beginning-search-backward-end
bindkey "^N" history-beginning-search-forward-end


# ========================================
# history 操作
# ========================================
autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^P" history-beginning-search-backward-end
bindkey "^N" history-beginning-search-forward-end


# ========================================
# alias
# ========================================
alias -g ...='../..'
alias -g ....='../../..'

