#!/bin/bash

# launchctl の処理で呼び出す想定。

# バッテリー情報を取得
battery_info=$(pmset -g batt)

# バッテリー残量と充電状態を抽出
battery_level=$(echo "$battery_info" | grep -o '[0-9]\+%;' | tr -d '%;')
power_source=$(echo "$battery_info" | grep -o 'Now drawing from.*' | cut -d "'" -f 2)

# Now drawing from 'AC Power'
# Now drawing from 'Battery Power'
# discharging
# charged;
# 'finishing charge'

# 現在の日時を取得
current_time=$(date "+%Y-%m-%d %H:%M:%S")

# CSV形式でファイルに保存（日時, バッテリー残量, 充電状態）
echo "$current_time, $battery_level, $power_source"
