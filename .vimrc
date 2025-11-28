" 環境依存しないように書こう、でもvi互換は切る
" vim: set noexpandtab tabstop=8 shiftwidth=8 softtabstop=8 :
" vim: set tags+=~/.vim/tags :




" https://raw.githubusercontent.com/Shougo/dein.vim
"dein Scripts ================================================================
	if &compatible
	  set nocompatible               " Be iMproved
	endif

	" Required:
	set runtimepath+=$HOME/.cache/dein/repos/github.com/Shougo/dein.vim

	" Required:
	call dein#begin($HOME . '/.cache/dein')

	" Let dein manage dein
	" Required:
	call dein#add($HOME . '/.cache/dein/repos/github.com/Shougo/dein.vim')




" プラグイン管理
" https://raw.githubusercontent.com/Shougo/dein.vim
"dein Scripts=================================================================
	call dein#add('tpope/vim-surround')
	call dein#add('tpope/vim-repeat')
	"vim-ref のドキュメントとかは環境毎に設定＆読み込みしてね
	call dein#add('thinca/vim-ref')
		"let g:ref_open = ':vsplit'
		let g:ref_phpmanual_path = $HOME . '/.local/share/refvim/php-chunked-xhtml'
	call dein#add('vim-jp/vimdoc-ja')
	call dein#add('ap/vim-css-color')
	call dein#add('junegunn/vim-easy-align')
		nmap ga <Plug>(EasyAlign)
		xmap ga <Plug>(EasyAlign)

	" 参考:
	" https://github.com/Shougo/dein.vim/issues/74
	call dein#add('junegunn/fzf', {'merged': 0})          " fzf 本体かつプラグイン本体
	call dein#add('junegunn/fzf.vim', {'depends': 'fzf'}) " ヘルパースクリプト
		" タブ
		nmap <leader><tab> <plug>(fzf-maps-n)
		xmap <leader><tab> <plug>(fzf-maps-x)
		omap <leader><tab> <plug>(fzf-maps-o)

		" Insert mode completion
		imap <c-x><c-k> <plug>(fzf-complete-word)
		imap <c-x><c-f> <plug>(fzf-complete-path)
		imap <c-x><c-j> <plug>(fzf-complete-file-ag)
		imap <c-x><c-l> <plug>(fzf-complete-line)

		" Advanced customization using autoload functions
		inoremap <expr> <c-x><c-k> fzf#vim#complete#word({'left': '15%'})

	call dein#add('shawncplus/phpcomplete.vim')
	call dein#add('deris/vim-shot-f')
	call dein#add('zhaocai/GoldenView.Vim')
		let g:goldenview__enable_default_mapping = 0
	call dein#add('leafOfTree/vim-vue-plugin')

	call dein#add('joonty/vdebug')
		" 各プロジェクトのvimrcで設定する

	call dein#add('yuttie/comfortable-motion.vim')
		nnoremap <silent> <C-d> :call comfortable_motion#flick(100)<CR>
		"nnoremap <silent> <C-u> :call comfortable_motion#flick(-100)<CR>

	call dein#add('w0rp/ale')
		let g:ale_linters = {
			\'php': [],
		\}

	call dein#add('airblade/vim-gitgutter')
	call dein#add('leafgarland/typescript-vim')
	call dein#add('tpope/vim-markdown')
	call dein#add('vim-scripts/autodate.vim')
	call dein#add('luochen1990/rainbow')
	    let g:rainbow_active = 1 " 常に有効にする
	call dein#add('neoclide/coc.nvim', {'merged': 0, 'rev': 'release'})



	" Required:
	call dein#end()

	" Required:
	filetype plugin indent on
	syntax enable

" If you want to install not installed plugins on startup.
" if dein#check_install()
"   call dein#install()
" endif

"End dein Scripts-----------------------------------------------------------














set encoding=utf-8
scriptencoding utf-8
set nocompatible
syntax on
call has('python3')

"set listchars=tab:\|\ ,trail:-,nbsp:%,extends:»,precedes:<,eol:\ 
set listchars=tab:│\ ,trail:-,nbsp:%,extends:»,precedes:<
set fillchars=vert:│,diff:.
"set number
set exrc    " カレントの.vimrcを読み込む
set secure  " コマンドに制限をかける
set list    "ターミナルでも 制御文字表示
set mouse=a " CUIでもマウス使える
"set shell=/bin/zsh\ -i " エイリアスを有効にする

set t_Co=256 "256発色する
" colorscheme beauty256 "明るめのデザイン(ターミナルでも綺麗)
colorscheme molokai "sublimetext2
" matchit.xml なぜか動かなくなった。英語版MacVimだから？
"source $VIMRUNTIME/macros/matchit.vim "matchit 使う


"let &colorcolumn=join(range(81,999),",") " 81行目以降全部塗りつぶす
set hlsearch      " 検索文字強調
set numberwidth=5 " 行数を表示する幅

set laststatus=2
" == ステータスラインフォーマット
"そこそこいいやつ
set statusline=
set statusline+=%#User1#
set statusline+=%M%R%H%W
set statusline+=\ %n\ 
set statusline+=%#StatusLine#
set statusline+=\ %F
set statusline+=\%=
set statusline+=\ %l/%L\ 
"set statusline+=%#User1#<
"set statusline+=%##\ 
set statusline+=%#User1#\ 
"set statusline+=%Y\ 
set statusline+=\%{&fenc!=''?&fenc:&enc}:%{&ff}\ 

" gfコマンドプロジェクト以下のファイルを検索してジャンプするため
set path+=*,**
" 変数との組み合わせで指定されているファイルを見たいので
" $val/yay.tpl や dirname(__FILE__) . '/yay.php' ; のような文字列を想定
" 取り敢えずこの設定で様子を見てみる


" myfold.vimプラグインの関数を設定
set foldexpr=MyFoldExpr()
set foldtext=MyFoldText()
" 一部のジャンプ系移動でフォールド展開を抑止
" 既定値からblockを抜いたもの
set foldopen=hor,mark,quickfix,search,tag,undo,percent

"set nowrap   "not 折り返し 
"set linebreak   "折り返し位置をそれらしい場所でブレイクする
"set breakindent "折り返し行でもインデントを維持する
"set breakindentopt=shift:2 "折り返し行のインデントを更に深くする

set completeopt-=preview
" == 現在のバッファをライトしなくても、別のバッファに移れる
set hidden

" 無名レジスタに入るデータを、*レジスタにも入れる。
"set clipboard+=unnamed,autoselect
set clipboard+=unnamed

" <C-A>インクリメントの際、0から始まる数字を八進数と認識させない
set nrformats-=octal
set scrolloff=3 " スクロールの幅確保

"set cursorline "カーソル行の強調

"beep 音を抑制
" set visualbell
"set belloff cursor
set formatoptions-=ro
set autoindent
set iminsert=0
set imsearch=0
set wildmenu
set history=5000

" 親ディレクトリのタグファイルを探しに行く
set tags=./tags;

" tmuxのなかでマウスを使える
set mouse=a
set ttymouse=sgr




" Date set value
:let g:changelog_timeformat = "%Y-%m-%d %H:%M"

" fold
autocmd BufRead *.chg setf changelog
autocmd FileType changelog set foldexpr=ChgLogFoldLevel(v:lnum) foldmethod=expr foldlevel=0
function! ChgLogFoldLevel(lnum)
	let l1 = getline(a:lnum)  
	if l1 =~"^\\t\\*[^*]"
		return '>1'
	elseif l1 =~"^\\t"
		:q
		return 1
	else
		return 0
	endif
endfunction




" ファイルの設定
" ========================================================================
set directory=/tmp/
set backupdir=/tmp/
set undodir=/tmp/
if has('win32')
	" Windows用
	set directory=C:\\tmp
	set backupdir=C:\\tmp
	set undodir=C:\\tmp
endif

augroup auto_comment_for_filetype " ファイルタイプごとの設定
	autocmd!
	autocmd BufNewFile,BufRead *.as setlocal filetype=actionscript
	autocmd FIletype php,javascript,python,sh,zsh,bash,c,cpp,h,vim,as,mxml
				\,gitcommit,css
				\ setlocal colorcolumn=80
	autocmd FIletype html,smarty,smarty_ex setlocal colorcolumn=
	autocmd FIletype html,php,xml,smarty,smarty_ex,javascript setlocal includeexpr=substitute(v:fname,'^\\/','','')

	autocmd FileType css        setlocal iskeyword+=- " attribute とかを想定

	autocmd FileType xml setlocal fileencoding=utf-8
	autocmd FileType yml,yaml,xml setlocal softtabstop=2 shiftwidth=2 tabstop=2 noexpandtab
	autocmd BufNewFile,BufRead,FileType java,javascript setlocal noexpandtab cino=:0 cino==24 cino=M1 cino=j1
	" android res 以下はデフォルト
	autocmd BufNewFile,BufRead,FileType */res/*.xml setlocal softtabstop=8 shiftwidth=8 tabstop=8 noexpandtab
	autocmd FileType python setlocal ts=4 sw=4 sta et sts ai
	autocmd FileType tsv    setlocal noexpandtab softtabstop=8 shiftwidth=8 tabstop=8
	"autocmd FileType * colorscheme beauty256
	autocmd BufRead,BufNewFile *.ts setlocal filetype=typescript
	autocmd BufRead,BufNewFile *.pcss setlocal filetype=scss
	autocmd FileType vue setlocal isfname+=@-@  includeexpr=substitute(v:fname,'^@/','src/','')
	"auto lint
	" どのファイルタイプでも。JSONっぽいファイルをJSONとして読み込み
	autocmd BufRead * if line('$')>=2 && getline(1)==#'{' && getline('$')==#'}' && &ft=='' | set ft=json | endif
augroup END



" フォールド(折りたたみ)の設定
" ========================================================================
	set foldlevel=0
	set foldnestmax=16
	set foldmethod=expr




" プラグインとかの設定
" ========================================================================
	" ラストチェンジのフォーマット変更
	let autodate_format="%Y-%m-%d %H:%M:%S"



" キーマップ
" ========================================================================
" manage windows 本当に使える？この設定。あとで見直すかも
nnoremap gw <c-w>
nnoremap ? :BLines<CR>
nnoremap <C-b> :Buffers<CR>


" 自作コマンド
command LS :Buffers<CR>

" ========================================================================
"set fileencoding=japan
set fileencodings=utf-8,cp932,euc-jp,iso-20220-jp,default,latin

" 改行コードの自動認識
set fileformats=unix,dos,mac
" □とか○の文字があってもカーソル位置がずれないようにする
augroup ambiwidth_double
	autocmd!
	autocmd BufEnter *.txt,*.tpl,*.php setlocal ambiwidth=single
augroup END

" コピペで自動的なコメントアウトの挿入を入れない
" https://gist.github.com/rbtnn/8540338 （一部修正）
augroup auto_comment_off
	autocmd!
	autocmd BufEnter * setlocal formatoptions-=r
	autocmd BufEnter * setlocal formatoptions-=o
augroup END

augroup AUTOCMD_QUICKFIX " QuickFix 関係
	autocmd!
"	" エラーが有るなら自動で開く
	autocmd QuickFixCmdPost make,vimgrep cwindow 5
	autocmd QuickfixCmdPost lmake,lvimgrep lwindow 5
augroup END
 
augroup JAVASCRIPT " おもにEslintとかの設定
	autocmd!
	autocmd FileType javascript setlocal makeprg=eslint\ -f\ compact\ %
	autocmd FileType javascript setlocal errorformat=%f:\ line\ %l\\,\ col\ %c\\,\ %trror\ -\ %m
	" ALEがlint結果をlocation listに入れる仕様なので、私も
	" それに合わせてファイル書き込み時のmake系の処理はlmakeに統一します。
	" そして、vimgrepはそのまま使ってQuickfixに書き込みます。
	autocmd BufWritePost *.js silent lmake | :redraw!
	"autocmd BufRead *.js colorscheme molokai
augroup END

augroup PYTHON
	" http://vim.wikia.com/wiki/Python_-_check_syntax_and_run_script
	autocmd!
	autocmd FileType python setlocal makeprg=python\ -m\ py_compile\ %
	autocmd FileType python setlocal errorformat=%C\ %.%#,%A\ \ File\ \"%f\"\\,\ line\ %l%.%#,%Z%[%^\ ]%\\@=%m
	autocmd BufWritePost *.py silent lmake | :redraw!
augroup END

"markdown中のハイライト
let g:markdown_fenced_languages = [
	\  'c',
	\  'cpp',
	\  'css',
	\  'html',
	\  'smarty',
	\  'smarty_ex',
	\  'php',
	\  'sh',
	\  'zsh',
	\  'java',
	\  'javascript',
	\  'js=javascript',
	\  'json=javascript',
	\  'sql',
	\  'xml',
	\  'make',
	\  'vim',
\]
	"\  'bash',  this line error?


 
 

" diff実行時にシンタックスがONになってしまうので、dein系処理のあとに移動してみました。
 set diffopt+=,vertical,iwhite
 if &diff
 	syntax off " vimdiffが重いので言語のシンタックス処理を切る
 	let g:goldenview__enable_at_startup = 0
 	setlocal cursorline nonumber
 	augroup VIMDIFF
 		autocmd!
 		autocmd FileType yaml,xml,smarty,smarty_ex setlocal softtabstop=2 shiftwidth=2 tabstop=2 noexpandtab
 		autocmd BufWritePost * diffupdate
 	augroup END
 	nnoremap <pageup> [c
 	nnoremap <pagedown> ]c
 	nnoremap do do:diffupdate<CR>
 	nnoremap dp dp:diffupdate<CR>
 	"nnoremap do do]c
 	"nnoremap dp dp]c
 
 
 	" https://stackoverflow.com/questions/19594802/diffput-to-multiple-buffers
 	function! GetDiffBuffers()
 		return map(filter(range(1, winnr('$')), 'getwinvar(v:val, "&diff")'), 'winbufnr(v:val)')
 	endfunction
 
 	function! DiffPutAll()
 		for bufspec in GetDiffBuffers()
 			execute 'diffput' bufspec
 		endfor
 	endfunction
 
 	command! -range=-1 -nargs=* DPA call DiffPutAll()
 endif


















let Tlist_WinWidth  = 30      " taglist.vim の横幅
let Tlist_Auto_Open = 0
let Tlist_Exit_OnlyWindow = 1 " taglistのウインドウだけならVimを閉じる
" ホットキー(暫定的。他のIDEだとどのキーが標準なんだろう?)
nnoremap ts :Tlist<CR>
" 微妙に選択範囲じゃなく行選択になってるので後で直す
vnoremap <C-H> :  !trans -b en:ja<CR>
nnoremap <C-H> :. !trans -b en:ja<CR>

" 超すげーグレップ
nnoremap <F7> :Ag <CR>
nnoremap <leader>g :silent !tmux split-window -p 40 "w3m 'https://google.co.jp/search?q='"<CR>

let g:diff_translations = 0
let g:java_ignore_javadoc = 1 " markdown <-> javadoc での再起読み込みが発生するのでjavadocのシンタックス処理を停止する

" ターミナルのレンダリング高速化のため
set lazyredraw "再描画待ち
"set scrolljump=5        " Scroll 8 lines at a time at bottom/top; かなり効果的
set scrolljump=1        "  alacritty  best render 
let html_no_rendering=1 " Don't render italic, bold


if filereadable(expand($HOME.'/.vimrc.local')) " 環境設定
	source $HOME/.vimrc.local
endif













