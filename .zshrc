#-------------------------------------------------------------
# 🥳  理屈が通れば、それでいい  😜
#-------------------------------------------------------------

################ 👁️ 基本設定

# 環境変数の重複排除
typeset -U path
# 色を使う
autoload -U colors && colors

### 履歴系

HISTFILE=~/.zsh_history
HISTSIZE=99999999
SAVEHIST=99999999
# 履歴の重複を無視する
setopt hist_ignore_dups
# 履歴共有
setopt share_history

### cd 履歴

setopt autocd extendedglob
setopt auto_cd
setopt auto_pushd # 自動PUSH。`cd -<TAB>` で候補補間

### 補完

# 補完の初期化
autoload bashcompinit && bashcompinit
autoload -Uz compinit && compinit
# 補完候補の表示を詰める
setopt list_packed
# 補間後に末尾の/を削除しない(ディレクトリ補間で楽)
setopt noautoremoveslash
# 補間終了時のビープオン抑制
setopt nolistbeep
# スペルミス推測して対応する
setopt correct
# 補完表示のディレクトリは青色
zstyle ':completion:*' list-colors 'di=34'
# 補完表示補完を矢印キーで選べる
zstyle ':completion:*' menu select

### キーバインド

# vimスタイル
bindkey -v

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

autoload zed




################ 📔 定義

### 色制御文字

red='[0;31m'
RED='[1;31m'
blue='[0;34m'
BLUE='[1;34m'
cyan='[0;36m'
CYAN='[1;36m'
# No Color
NC='[0m'

### 環境変数

#export TIMEFORMAT=$'\nreal %3R\tuser %3U\tsys %3S\tpcpu %P\n'
export HISTTIMEFORMAT="%H:%M > "
#export HISTIGNORE="&:bg:fg:ll:h"
export HOSTFILE=$HOME/.hosts    # Put list of remote hosts in ~/.hosts ...
export WWW_HOME="https://duckduckgo.com"

### fzf configuretion

export FZF_DEFAULT_OPTS="-m --color=light,bg+:255,fg+:92,hl:198 --history=${HOME}/.fzf.history"
export FZF_CTRL_T_OPTS="--preview '(highlight -O ansi -l {} 2> /dev/null || cat {} || tree -C {}) 2> /dev/null | head -200'"

# tmux環境ではそれで開く
[[ $TMUX != "" ]] && alias fzf=fzf-tmux

# シェルのネスト呼び出しでnvm のエラーが出るのを回避するため
# https://github.com/creationix/nvm/issues/1652
#export PATH="$PATH:$(getconf PATH)"
# 2025-11-06a これ現代でも必要？
PATH="/usr/local/bin:$(getconf PATH)"

# --> Nice. Has the same effect as using "ansi.sys" in DOS.
# Looks best on a terminal with black background.....
#echo -e "${CYAN}This is ZSH ${RED}${BASH_VERSION%.*} ${CYAN} - DISPLAY on ${RED}$DISPLAY${NC}\n"
#date
function _exit()        # Function to run upon exit of shell.
{
    #echo -e "${RED}Hasta la vista, baby${NC}"
}
trap _exit EXIT




################ 💰️ シェルプロンプト

case ($UID) in
    0)
    PROMPT_MARK='#'
    ;;
    501)
    PROMPT_MARK='%'
    ;;
    *)
    PROMPT_MARK='$'
    ;;
esac

if [[ "${DISPLAY%%:0*}" != "" ]]; then  
    HILIT="${red}"   # remote machine: prompt will be partly red
else
    HILIT="${cyan}"  # local machine: prompt will be partly cyan
fi

#  --> Replace instances of \W with \w in prompt functions below
#+ --> to get display of full path name.

function precmd() {
	psvar[1]=$(pwd | sed "s#$HOME#~#" | awk '{
	eol = split($0, a, "/");
	# 7番目に白が入っていて見えにくいので7で丸めます
	pt = "%F{" eol % 7 "}" a[eol] "%f";
	if (a[2] == "") pt = "/"
	if ($0 == "~") pt = "~"
	print pt
	}')
}
function middle_prompt() {
	# 日本語サイトググるよりここ読んだほうが一発でした
	# http://zsh.sourceforge.net/Doc/Release/Prompt-Expansion.html#Simple-Prompt-Escapes
	PS1=""
	# dir name
	PS1+="%B"
	PS1+='${psvar[1]}'
	PS1+="%b "
	# branch
	PS1+='%F{5}${vcs_info_msg_0_}%f'
	# $|# 直前のコマンドが失敗したら赤
	PS1+="%(?,%F{green},%F{red})%#%f"
	#  >  background job によって色を変える
	PS1+="%(1j,%F{magenta},%F{green})>%f"
	PS1+=" "
}
function minimal_prompt() {
	# http://dotshare.it/dots/25/
	# %(?.true.false)
	# %# POSIX prompt
	# %f folder
	#PS1='%(?.%F{green}.%F{red})%#%f '
	# (#|%)
	PS1="%(1j,[%j],)%(?.%F{green}.%F{red})>%f " # [ジョブ数]%
#
}

# hookに登録してプロンプト表示される毎に実行する
#_pwdseparat () {
#	# セパレーターの色変更
#	#PSVAR[2]=$( pwd | sed -e 's@/@%F{1}/%f@g' )
#
#	PSVAR[2]=
#}

# vcs_info関数を呼び出す。vcs情報はformatsで整形され vcs_info_msg_0_ に挿入される
#function fastprompt()
#{
#    unset PROMPT_COMMAND
#    case $TERM in
#        *term* | rxvt )
#            PS1="${HILIT}[\h]$NC \W > \[\033]0;\${TERM} [\u@\h] \w\007\]" ;;
#        linux )
#            PS1="${HILIT}[\h]$NC \W > " ;;
#        *)
#            PS1="[\h] \W > " ;;
#    esac
#}

_powerprompt() {
    LOAD=$(uptime|sed -e "s/.*: \([^,]*\).*/\1/" -e "s/ //g")
}

function powerprompt()
{
    PROMPT_COMMAND=_powerprompt
    case $TERM in
        *term | rxvt  )
            #PS1="[\u@\h]$PROMPT " ;;
            PROMPT="${HILIT}[\A - \$LOAD]$NC\n[\u@\h \#] \W > \
                 #\[\033]0;\${TERM} [\u@\h] \w\007\]" ;;
            #RPROMPT="[%h:%?]"
            #;;
        linux )
            PS1="${HILIT}[\A - \$LAD]$NC\n[\u@\h \#] \W $PROMPT_MARK " ;;
        * )
            PS1="[\A - \$LOAD]\n[\u@\h \#] \W $PROMPT_MARK " ;;
    esac
}

### ブランチ名をRPROMPTで表示
autoload -Uz add-zsh-hook
autoload -Uz vcs_info
# プロンプト表示ごとに変数を展開する
setopt PROMPT_SUBST
zstyle ':vcs_info:*' formats '%b%c%u '
zstyle ':vcs_info:*' actionformats '%b%c%u|%a '
add-zsh-hook precmd vcs_info  # 上の関数をプロンプト表示前に実行させる
#add-zsh-hook precmd  _pwdseparat # 上の関数をプロンプト表示前に実行させる

#function git-branch-prompt() {
#	# 
#	autoload -Uz _vcs_info
#	#zstyle ':vcs_info:*' enable git svn
#	#zstyle ':vcs_info:*' max-exports 6 # format
#	#--
#	zstyle ':vcs_info:git:*' check-for-changes true
#	zstyle ':vcs_info:git:*' formats '%b@%r' '%c' '%u'
#	zstyle ':vcs_info:git:*' actionformats '%b@%r|%a' '%c' '%u'
#	setopt prompt_subst
#	function _vcs_echo {
#		local st branch color
#		STY= LANG=ja_JP.UTF-8 vcs_info
#		st=`git status 2> /dev/null`
#		if -z "$st"; then return; fi
#		branch="$vcs_info_msg_0_"
#		if   echo "$st" | grep "Changes not staged"; then
#			color=${fg[red]} # unstaged
#		elif echo "$st" | grep "Changes to be committed"; then
#			color=${fg[yellow]} #uncommit
#		elif echo "$st" | grep "^Untracked"; then
#			color=${fg[cyan]} #untracked
#		else
#			color=${fg[green]}
#		fi
#		echo ":$color$branch$reset_color"
#	}
#	#PROMPT='%1~`_vcs_echo`%# '
#}

#ToDo: git プロンプト対応したい

#zstyle ':vcs_info:*' actionformats \ 
#		'%F{5}(%f%s%F{5})%F{3}-%F{5}[%F{2}%b%F{3}|%F{1}%a%F{5}]%f '
#zstyle ':vcs_info:*' formats \ 
#		'%F{5}(%f%s%F{5})%F{3}-%F{5}[%F{2}%b%F{5}]%f '
#zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat '%b%F{1}:%F{3}%r'
#precmd () { vcs_info }
#PS1='%F{5}[%F{2}%n%F{5}] %F{3}%3~ ${vcs_info_msg_0_}%f%# '

# This is the default prompt -- might be slow.  If too slow, use
# fastprompt instead. ...
# これはデフォルト。遅いなら fastprompt() を使ってね
#powerprompt
#fastprompt
#minimal_prompt
middle_prompt




################ 👽️ エイリアス

alias vi='vim'

### ls

# 時系列表示が好みなので tr で時系列昇順。一番下に新しいファイルが来る
alias ll='ls -Fhltr'
alias la='ls -AFhltr'
# 拡張子ソート
alias lx='ls -lhXBtr'
# サイズソート
alias lk='ls -lhSr'
#Mac X
if [ `uname` = "Darwin" ];then
	alias ls='ls -hFtr -G'
	alias df='df -h'
fi

### chmod

alias 777='chmod 777'
alias 766='chmod 766'
alias 744='chmod 744'
alias 700='chmod 700'
alias 666='chmod 666'
alias 644='chmod 644'
alias 000='chmod 000'

alias highlight='highlight --out-format=xterm256 -s moe'
alias less='less -R'
alias clisp='clisp -E UTF-8'
alias ln='ln -s'
alias rm='trash'
alias mv='mv -i'
# -> Prevents accidentally clobbering files.
alias mkdir='mkdir -p'
alias h='history 0:'
alias p='ps ax'
alias j='jobs -l'

#function gitignore_grep {
#	local exclude_pattern=" tags *.svn-* *.min.js *tmp *bak *old .git *.bk *.org"
#	[ -f ./.gitignore ] && exclude_pattern="$exclude_pattern $(cat ./.gitignore)"
#	local ptn exclude
#	for ptn in $(echo $exclude_pattern);do
#		exclude="$exclude --exclude=\"$ptn\""
#	done
#	grep --binary-files=without-match --color=auto $exclude $@
#}
#alias grep=gitignore_grep

alias which='type -a'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
alias .......='cd ../../../../../..'
alias ........='cd ../../../../../..'
alias path='echo -e ${PATH//:/\\n}'
alias libpath='echo -e ${LD_LIBRARY_PATH//:/\\n}'
alias print='/usr/bin/lp -o nobanner -d $LPDEST'
            # Assumes LPDEST is defined (default printer)
# テキストを表示する言語っぽい。印刷している
#alias pjet='enscript -h -G -fCourier9 -d $LPDEST'
#            # Pretty-print using enscript

alias du='du -kh'       # Makes a more readable output.
alias entoja='pbpaste| trans -b en:ja'
alias yt-dlp-mp3='yt-dlp -f bestaudio --output "%(title)s.%(ext)s" --extract-audio --audio-format mp3'

### Bare Git dotfiles

alias config='/usr/bin/git --git-dir ~/.cfg --work-tree ~'
compdef _git config
zstyle ':completion:*:*:config:*:*' command 'git'

### MacVIM

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

# If your version of 'ls' doesn't support --group-directories-first try this:
# function ll(){ ls -l "$@"| egrep "^d" ; ls -lXB "$@" 2>&-| \
#                egrep -v "^d|total "; }

### 拡張子の関連付

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
#alias -s {gif,jpg,jpeg,png,bmp}=open
#alias -s {mp3,m4a,ogg}=amarok
#alias -s {mpg,mpeg,avi.mp4v}=svlc




################ 𝒇 関数

### 処理が遅い nvm を遅延評価させる

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



################ 📡 外部リソース

[ -f ~/.zshrc.local ] && source ~/.zshrc.local
[ -f ~/.fzf.zsh ]     && source ~/.fzf.zsh
[ -f ~/.cargo/evn ]   && source ~/.cargo/env

#ハイライト (zshrcの最後に書く必要があるとのこと)
[ -f ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] &&
	  source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)
