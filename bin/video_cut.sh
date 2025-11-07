#!/bin/zsh -eu 

# うまく動かないでござる

# カットリストファイル名
cut_list_file="cut_list.txt"

# カットリストファイルが存在するかチェック
if [ ! -f "$cut_list_file" ]; then
	echo "$cut_list_file ファイルを作ってください。"
	echo "フォーマットの例(削除区間を指定する):"
	echo "00:01:00 00:02:00"
	echo "00:04:00 00:05:00"
	exit 1
fi

input_video="$1" # 入力動画ファイル名（引数から受け取る）
new_viceo="_${input_video}" # リネーム後のファイル名

# 一時ファイル用のプレフィックス
temp_prefix="temp"

# 一時ファイルを格納するディレクトリ
temp_dir="temp_dir"
mkdir -p $temp_dir

# カットリストを読み込む
count=0
prev_end="00:00:00"
while read -r start_time end_time; do
  let "count++"
  temp_file="${temp_dir}/${temp_prefix}_${count}.mp4"

  # カット部分を除いた部分を一時ファイルに保存
  ffmpeg -ss "$prev_end" -to "$start_time" -i "$input_video" -acodec copy -vcodec copy "$temp_file"

  prev_end=$end_time
done < $cut_list_file

# 最後のカット終了位置から動画の最後までを保存
let "count++"
ffmpeg -ss "$prev_end" -i "$input_video" -acodec copy -vcodec copy "${temp_dir}/${temp_prefix}_${count}.mp4"



# 一時的なテキストファイルを作成
concat_file="${temp_dir}/concat_list.txt"
# 一時ファイルのリストをテキストファイルに書き出す
for f in $(ls ${temp_dir}/${temp_prefix}_*.mp4 | sort -n); do
  echo "file '$PWD/$f'" >> $concat_file
  echo "file '$PWD/$f'" >> ./concat_list_copy.txt
done
# 一時ファイルを結合
ffmpeg -f concat -safe 0 -i $concat_file -c copy "$new_video"

# 一時ファイルを削除
rm -r $temp_dir
