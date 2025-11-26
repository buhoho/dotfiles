# 🥳  理屈が通れば、それでいい  😜

typeset -U path # 環境変数の重複排除

# 履歴系
HISTFILE=~/.zsh_history
HISTSIZE=99999999
SAVEHIST=99999999
setopt hist_ignore_dups  # 履歴の重複を無視する
setopt share_history     # 履歴共有
setopt HIST_IGNORE_SPACE # スペースで始まるコマンドを履歴に残さない

# cd 履歴
setopt autocd extendedglob
setopt auto_cd
setopt auto_pushd # 自動PUSH。`cd -<TAB>` で候補補間

# 補完
fpath=(~/.zsh/completions $fpath)
# キャッシュ(-C)を使うか、セキュリティチェックを真面目にするかの実利的な分岐
# (24時間に1回だけ真面目にチェックし、それ以外はキャッシュを使う)
autoload -Uz compinit # 補完の初期化
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi
autoload bashcompinit && bashcompinit
setopt list_packed                         # 補完候補の表示を詰める
setopt noautoremoveslash                   # 補間後に末尾の/を削除しない(ディレクトリ補間で楽)
setopt nolistbeep                          # 補間終了時のビープオン抑制
setopt correct                             # スペルミス推測して対応する
zstyle ':completion:*' list-colors 'di=34' # 補完表示のディレクトリは青色
zstyle ':completion:*' menu select         # 補完表示補完を矢印キーで選べる

# キーバインド
bindkey -v        # vimスタイル
# 履歴検索操作でカーソルを行末にいい感じに移動します
#
# Zsh Line Edit (ZLE) で、履歴キーバインドを作成
# 3つセットアップを通じて使えるようにしている。
# 詳細: https://linux.die.net/man/1/zshcontrib
# 1. ZLEの関数であるhistory-search-endは、
#    履歴検索操作でカーソルを行末にいい感じに移動してくれるラップ関数
#    この関数は実行時にカーソル操作をしつつビルトインの関数
#    history-beginning-search-(backward|forward) の処理を実行する
autoload -U history-search-end
# 2. ZLEで1を使うために専用のウィジェット名で定義する
#    ウィジェット: zshで「キーボード操作に反応して動く機能」のこと
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
# 3. 2を任意のキーストロークCtrlにバインド
bindkey "^p" history-beginning-search-backward-end
bindkey "^n" history-beginning-search-forward-end

echo ".zshrc FIXME: 説明を直して。"
autoload zed # zle 関数を操作するためのエディタらしが不明

# 環境変数
# 2025-11-06a これ現代でも必要？
# PATH="/usr/local/bin:$(getconf PATH)"
PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin" # getconf 速度。優先のhardcode
export PATH=$PATH:$HOME/bin
#export TIMEFORMAT=$'\nreal %3R\tuser %3U\tsys %3S\tpcpu %P\n'
export HISTTIMEFORMAT="%H:%M > "
#export HISTIGNORE="&:bg:fg:ll:h"
export HOSTFILE=$HOME/.hosts    # Put list of remote hosts in ~/.hosts ...
export WWW_HOME="https://duckduckgo.com"
export BAT_THEME="Nord"
export BAT_STYLE="plain"
export FZF_DEFAULT_OPTS="-m --color=light,bg+:236,fg:250,fg+:255,hl:31,hl+:123 --history=${HOME}/.fzf.history"
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=plain --line-range=:200 --theme=Nord {} 2>/dev/null || cat {} || tree -C {}'"
export FZF_CTRL_R_OPTS="--reverse"
[[ $TMUX != "" ]] && alias fzf=fzf-tmux # tmux環境ではそれで開く

# メッセージ
red='[0;31m'
RED='[1;31m'
blue='[0;34m'
BLUE='[1;34m'
cyan='[0;36m'
CYAN='[1;36m'
NC='[0m'              # No Color
# --> Nice. Has the same effect as using "ansi.sys" in DOS.
# Looks best on a terminal with black background.....
#echo -e "${CYAN}This is ZSH ${RED}${BASH_VERSION%.*} ${CYAN} - DISPLAY on ${RED}$DISPLAY${NC}\n"
#date
function _exit()        # Function to run upon exit of shell.
{
    #echo -e "${RED}Hasta la vista, baby${NC}"
}
trap _exit EXIT

# シェルプロンプト
function precmd() {
    # 1. ホームディレクトリを ~ に置換
    local p="${PWD/#$HOME/~}"

    # 2. 特例: ルートとホームは固定色で見やすく
    if [[ "$p" == "/" ]]; then
        psvar[1]="%B%F{196}/%b%f"
        return
    elif [[ "$p" == "~" ]]; then
        psvar[1]="%B%F{39}~%b%f"
        return
    fi

    # 3. 一般ディレクトリ: / の数を数えて色を回転させる
    # ${p//[^\/]/} でスラッシュ以外を削除してカウント
    # (( n % 6 + 1 )) で 1〜6 (赤緑黄青紫水) の色番号を算出
    local c=$(( ${#p//[^\/]/} % 14 + 1 ))

    # 4. セット: 算出した色 + 末尾のディレクトリ名(:t)
    psvar[1]="%F{$c}${p:t}%f"
}
function middle_prompt() {
	# 日本語サイトググるよりここ読んだほうが一発でした
	# http://zsh.sourceforge.net/Doc/Release/Prompt-Expansion.html#Simple-Prompt-Escapes
	PS1=""
	# dir name
	PS1+='${psvar[1]} '
	# branch
	PS1+='%F{203}${vcs_info_msg_0_}%f'
	#PS1+='%(1j,%F{magenta}⏸,)%f'
	# PS1+='%(1j,%F{magenta}†,)%f'
	PS1+='%(1j,%F{magenta}𝄐,)%f' # フェルマータ音楽での一時停止記号
	
	# $|# 直前のコマンドが失敗したら赤
	PS1+="%(?,%F{green},%F{red})"
	# λ,❯,≫,»,%,∴,➜,●,◆
	# ⊨ 真である
	PS1+="%B%#%b"
	#PS1+="%(#,#,●)"
	#    background job によって色を変える
	# PS1+='${(l:${#jobstates}::❯:)}'
	#PS1+="%(2j,%F{magenta}%f,)"
	PS1+="%f "
}
autoload -Uz add-zsh-hook # ブランチ名をRPROMPTで表示
autoload -Uz vcs_info
setopt PROMPT_SUBST    # プロンプト表示ごとに変数を展開する
zstyle ':vcs_info:*' formats '%b%c%u '
zstyle ':vcs_info:*' actionformats '%b%c%u|%a '
add-zsh-hook precmd vcs_info  # 上の関数をプロンプト表示前に実行させる
middle_prompt

###############################
# ****👽️ ALIAS SECTION ****** #
###############################
alias vi='vim'

# ls
alias ll='ls -Fhltr'           # 時系列表示が好みなので tr で時系列昇順。一番下に新しいファイルが来る
alias la='ls -AFhltr'
alias lx='ls -lhXBtr'          # 拡張子ソート
alias lk='ls -lhSr'            # サイズソート
if [[ $OSTYPE == darwin* ]];then # Mac X
	alias ls='ls -htr -G'
	alias df='df -h'
fi

# chmod
alias 777='chmod 777'
alias 766='chmod 766'
alias 744='chmod 744'
alias 700='chmod 700'
alias 666='chmod 666'
alias 644='chmod 644'
alias 000='chmod 000'

alias less='less -R'
alias clisp='clisp -E UTF-8'
alias ln='ln -s'
alias rm='trash'
alias mv='mv -i'
alias mkdir='mkdir -p'
alias h='history 0:'
alias p='ps ax'
alias j='jobs -l'
alias which='type -a'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
alias .......='cd ../../../../../..'
alias ........='cd ../../../../../../..'
alias path='echo -e ${PATH//:/\\n}'
alias du='du -kh'
alias yt-dlp-mp3='yt-dlp -f bestaudio --output "%(title)s.%(ext)s" --extract-audio --audio-format mp3'
alias down='ranger ~/Downloads'
alias donw=down

# Bare Git dotfiles
alias config='/usr/bin/git --git-dir ~/.cfg --work-tree ~ '
compdef _git config
zstyle ':completion:*:*:config:*:*' command 'git'

# MacVIM
MAC_VIM='/Applications/MacVim.app/Contents/MacOS'
MAC_VIM_BIN='/Applications/MacVim.app/Contents/bin '
if [ -d $MAC_VIM ];then
	# 香り屋バンドルのツールを使こう
	alias vim="$MAC_VIM/Vim"
	alias vi="$MAC_VIM/Vim"
	alias MacVim="$MAC_VIM/MacVim"
	# gvim 系
	alias gvim="$MAC_VIM_BIN/mvim"
	alias gview="$MAC_VIM_BIN/gview"
	alias gvim="$MAC_VIM_BIN/gvim"
	alias gvimdiff="$MAC_VIM_BIN/gvimdiff"
	alias mview="$MAC_VIM_BIN/mview"
	alias gvim="$MAC_VIM_BIN/mvim"
	alias mvimdiff="$MAC_VIM_BIN/mvimdiff"
	alias view="$MAC_VIM_BIN/view"
	alias vimdiff="$MAC_VIM_BIN/vimdiff '+syntax off'"
	#
	export EDITOR="$MAC_VIM/Vim"
	export RTV_EDITOR="$MAC_VIM/Vim"
	export SVN_EDITOR="$MAC_VIM/Vim"
	# tigで開くときに別窓にしたい
	# 別のターミナルでgit commitのコメント編集に入ると動かなくなるので...
	#export GIT_EDITOR="tmux split-window -h -p 80 $MAC_VIM/Vim"
else
	export EDITOR=vim
	export RTV_EDITOR=vim
	export SVN_EDITOR=vim
fi


# 拡張子の関連付
type atool >/dev/null 2>&1 && {
	alias -s {zip,lzhtar,arj,7z}=aunpack
	alias -s {gz,tgz,bz2,tbz,Z,xz}=acat
}
function execjava() {javac $1 && java `basename $1 .java`}
alias -s java=execjava
alias -s {c,txt}=head
alias -s {h,C,cpp,php,tpl,css,js}=head
alias -s xml='xmllint --format | head -n 20'
alias -s sh=sh
alias -s json='jq .'
alias -s {xhtml,html}=w3m
# OS X
alias -s {gif,jpg,jpeg,png,bmp}='open -a'
#alias -s {mp3,m4a,ogg}=amarok
#alias -s {mpg,mpeg,avi.mp4v}=svlc

# 𝒇 関数
lazynvm() {
  # zshの起動がくっそ遅いのは nvm 処理を起動時に毎回実行しているからとのこと。
  # 対応として、遅延評価で実行するようにします。
  # 参考: https://til-engineering.nulogy.com/Slow-Terminal-Startup-Tip-Lazy-Load-NVM/
  unset -f nvm node npm npx
  export NVM_DIR=~/.nvm
  [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh" # This loads nvm
  if [ -f "$NVM_DIR/bash_completion" ]; then
    [ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion" # This loads nvm bash_completion
  fi
}
nvm() {
  lazynvm 
  nvm $@
}
node() {
  lazynvm
  node $@
}
npm() {
  lazynvm
  npm $@
}
npx() {
  lazynvm
  npx $@
}

# 2024/01/31 12:14作成(ChatGPTによる)
# tmuxのセッション一覧を取得する関数
_tmux_sessions() {
  local sessions=$(tmux list-sessions -F '#{session_name}' 2>/dev/null)
  _describe 'session' sessions
}
# tmuxのattach-sessionとkill-sessionコマンドに対して補完を設定
compdef _tmux_sessions 'tmux attach-session -t'
compdef _tmux_sessions 'tmux kill-session -t'
# 2025/04/22 13:32 docker-composeのよく使うサブコマンドでサービス名を動的補完する(ChatGPT)
_docker_compose_services_dynamic_completion() {
  local -a existing_services
  existing_services=(${(@f)$(docker-compose ps --services 2>/dev/null)})

  if [[ -z "$existing_services" ]]; then
    return
  fi

  _arguments '*:services:->services'

  case $state in
    services)
      _describe 'docker-compose services' existing_services
      ;;
  esac
}
# docker-composeサブコマンドごとの補完処理
_docker_compose_subcommand_completion() {
  case $words[2] in
    (stop|start|restart|up|logs|rm|exec)
      _docker_compose_services_dynamic_completion
      ;;
    (*)
      _docker-compose "$@"
      ;;
  esac
}
# docker-composeの元の補完を維持しつつ、特定のサブコマンドで動的補完を有効化
compdef _docker_compose_subcommand_completion docker-compose
# Ctrl-f で rg fzf 検索
function fzf-rg-insert-widget() {
  local selected
  local awk_pattern
  
  # rgコマンド設定
  # --line-number: 行番号付き
  # --no-heading: ファイル名を各行の先頭に (fzfでパースしやすくするため)
  # --color=always: 色情報を維持
  # --smart-case: 大文字小文字をいい感じに判別
  local rg_cmd="rg --line-number --no-heading --color=always --smart-case ."

  # awk: 結果を "ファイルパス +行番号" に整形
  if [[ "${LBUFFER%% *}" =~ ^(vi|vim|nvim)$ ]]; then
    awk_pattern='{print $1 " +" $2}'  # 行番号付き
  else
    awk_pattern='{print $1}'          # それ以外はパスのみ
  fi

  # fzf実行
  selected=$(eval "$rg_cmd" | fzf --reverse --ansi \
    --delimiter : \
    | awk -F: "${awk_pattern}")

  # 選択された場合、カーソル位置に挿入
  if [[ -n "$selected" ]]; then
    LBUFFER="${LBUFFER}${selected}"
  fi
  
  # プロンプト再描画
  zle reset-prompt
}
# ウィジェットとして登録
zle -N fzf-rg-insert-widget
# キーバインド設定 (Ctrl-f) vi 挿入モード対象
bindkey -M viins '^f' fzf-rg-insert-widget

# 外部リソース
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ -f ~/.cargo/evn ] && source ~/.cargo/env
#ハイライト (zshrcの最後に書く必要があるとのこと)
[ -f ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] &&
	  source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)
