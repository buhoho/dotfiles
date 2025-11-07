#!/bin/bash
# ~/bin/macvim-symlink-update.sh

# MacVimのインストールパスを取得
MACVIM_PATH=$(brew --prefix macvim)

# もし/Applications/MacVim.appがシンボリックリンクなら削除
if [ -L "/Applications/MacVim.app" ]; then
  echo "既存のMacVimのシンボリックリンクを削除しています..."
  rm "/Applications/MacVim.app"
fi

# 新しいシンボリックリンクを作成
echo "新しいMacVimのシンボリックリンクを作成しています..."
ln -s "${MACVIM_PATH}/MacVim.app" "/Applications/MacVim.app"
