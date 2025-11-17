# 🥳  理屈が通れば、それでいい  😜

typeset -U path # 環境変数の重複排除
autoload -U colors && colors

# 履歴系
HISTFILE=~/.zsh_history
HISTSIZE=99999999
SAVEHIST=99999999
setopt hist_ignore_dups # 履歴の重複を無視する
setopt share_history    # 履歴共有

# cd 履歴
setopt autocd extendedglob
setopt auto_cd
setopt auto_pushd # 自動PUSH。`cd -<TAB>` で候補補間

# 補完
autoload bashcompinit && bashcompinit      # 補完の初期化
autoload -Uz compinit && compinit
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
#export TIMEFORMAT=$'\nreal %3R\tuser %3U\tsys %3S\tpcpu %P\n'
export HISTTIMEFORMAT="%H:%M > "
#export HISTIGNORE="&:bg:fg:ll:h"
export HOSTFILE=$HOME/.hosts    # Put list of remote hosts in ~/.hosts ...
export WWW_HOME="https://duckduckgo.com"
export FZF_DEFAULT_OPTS="-m --color=light,bg+:255,fg+:92,hl:198 --history=${HOME}/.fzf.history"
export FZF_CTRL_T_OPTS="--preview '(highlight -O ansi -l {} 2> /dev/null || cat {} || tree -C {}) 2> /dev/null | head -200'"
[[ $TMUX != "" ]] && alias fzf=fzf-tmux # tmux環境ではそれで開く
# シェルのネスト呼び出しでnvm のエラーが出るのを回避するため
# https://github.com/creationix/nvm/issues/1652
#export PATH="$PATH:$(getconf PATH)"
# 2025-11-06a これ現代でも必要？
PATH="/usr/local/bin:$(getconf PATH)"
export PATH=$PATH:$HOME/bin

# メッセージ
red='[0;31m'
RED='[1;31m'
blue='[0;34m'
BLUE='[1;34m'
cyan='[0;36m'
CYAN='[1;36m'
NC='[0m'      # No Color
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
autoload -Uz add-zsh-hook                        # ブランチ名をRPROMPTで表示
autoload -Uz vcs_info
setopt PROMPT_SUBST                              # プロンプト表示ごとに変数を展開する
zstyle ':vcs_info:*' formats '%b%c%u '
zstyle ':vcs_info:*' actionformats '%b%c%u|%a '
add-zsh-hook precmd vcs_info                     # 上の関数をプロンプト表示前に実行させる
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
if [ `uname` = "Darwin" ];then # Mac X
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

alias highlight='highlight --out-format=xterm256 -s moe'
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
alias ........='cd ../../../../../..'
alias path='echo -e ${PATH//:/\\n}'
alias libpath='echo -e ${LD_LIBRARY_PATH//:/\\n}'
alias print='/usr/bin/lp -o nobanner -d $LPDEST'
alias du='du -kh'
alias entoja='pbpaste| trans -b en:ja'
alias yt-dlp-mp3='yt-dlp -f bestaudio --output "%(title)s.%(ext)s" --extract-audio --audio-format mp3'

# Bare Git dotfiles
config() {
	# "config" コマンドの引数をチェック
	if [[ "$1" == "add" && ("$2" == "." || "$2" == "-A" || "$2" == "--all") ]]; then
		echo "エラー: 'config add .' および 'config add -A' は禁止されています。" >&2
		return 1 # 失敗ステータスで終了
	fi

	/usr/bin/git --git-dir ~/.cfg --work-tree ~ "$@"
}

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
#alias -s {gif,jpg,jpeg,png,bmp}=open
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

# 外部リソース
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
[ -f ~/.fzf.zsh ]     && source ~/.fzf.zsh
[ -f ~/.cargo/evn ]   && source ~/.cargo/env
#ハイライト (zshrcの最後に書く必要があるとのこと)
[ -f ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] &&
	  source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)
