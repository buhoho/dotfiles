"#colorscheme mydarkblue
"colorscheme mydesert
"colorscheme my3dglasses "サイバネティック
colorscheme molokai "sublimetextっぽいやつ
"colorscheme beauty256 "明るめのデザイン

" guiでは描画ちょっぱやなので
set scrolljump=1
set guioptions=

"---------------------------------------------------------------------------
" フォント設定:
"
if has('win32')
  " Windows用
  set guifont=MS_Gothic:h9:cSHIFTJIS
  "set guifont=MS_Mincho:h12:cSHIFTJIS
  " 行間隔の設定
  "set linespace=-1
  " 一部のUCS文字の幅を自動計測して決める
  if has('kaoriya')
    set ambiwidth=auto
  endif
elseif has('mac')
  "set guifont=Andale\ Mono:h12
  set linespace=1
  "set guifont=Courier:h13
  set macligatures
  set guifont=FiraCode-Light:h18
  "set guifont=MigMix\ 2M:h9
  "set guifont=Osaka－等幅:h13
  "set guifont=IPAGothic:h11
  "set guifont=yutapon-coding-K:h10
  "set guifont=Arial:h14
elseif has('xfontset')
  " UNIX用 (xfontsetを使用)
  "set guifontset=a14,r14,k14
  set guifont=M+\ 2VM+\ IPAG\ circle\ 11
  set printfont=M+\ 2VM+\ IPAG\ circle\ 11
  set guifontset=a4,r4,k4
  "set guifontset=a8,r8,k8
  " 文字間の幅なし
  "set linespace=-3
endif


"---------------------------------------------------------------------------
" 日本語入力に関する設定:
"
if has('multi_byte_ime') || has('xim')
  " IME ON時のカーソルの色を設定(設定例:紫)
  highlight CursorIM guibg=#CC4444 guifg=NONE
  "highlight CursorColumn guibg=#200000 guifg=NONE
  "highlight CursorLine guibg=#200000 guifg=NONE
  " 挿入モード・検索モードでのデフォルトのIME状態設定
  set iminsert=0 imsearch=0
  if has('xim') && has('GUI_GTK')
    " XIMの入力開始キーを設定:
    " 下記の s-space はShift+Spaceの意味でkinput2+canna用設定
    "set imactivatekey=s-space
  endif
  " 挿入モードでのIME状態を記憶させない場合、次行のコメントを解除
  "inoremap <silent> <ESC> <ESC>:set iminsert=0<CR>
endif







"---------------------------------------------------------------------------
" 全プラットフォーム共通定義


"
" ウインドウの幅
set columns=84
" ウインドウの高さ
set lines=32
" コマンドラインの高さ(GUI使用時)
set cmdheight=1

" eolの表示色を設定(Windows用gvim使用時はgvimrcを編集すること) 
"highlight clear NonText
"highlight NonText guifg=#0D2C8D
