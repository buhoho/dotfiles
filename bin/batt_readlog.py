import curses
import subprocess
import re
import asciichartpy
import time
import pandas as pd
import select
import sys


LOG_PATH = '/tmp/mac_battery.log'

def draw_graph(stdscr, df):
    """バッテリー残量の履歴からグラフを描画する"""
    stdscr.clear()

    # ターミナルの画面サイズを取得
    max_y, max_x = stdscr.getmaxyx()

    # 右側の画面外にはみ出ないように横幅を調整する
    render_history = df['Level'].tolist()[-(max_x - 12):]
    power_history = df['Power'].tolist()[-(max_x - 12):]

    # スケール固定のために0%と100%を追加
    render_history.insert(0, 100)   # 最初に0%を追加
    render_history.append(0)    # 最後に100%を追加

    graph = asciichartpy.plot(render_history, cfg={'height': 10})  # 最新の10データポイントを使用

    shift_left = 2

    # グラフの各行を画面サイズに収まるように描画
    for i, line in enumerate(graph.split('\n')):
        if i < max_y:  # ウィンドウの高さ内に収める
            stdscr.addstr(i, 0, line[shift_left:max_x])  # ウィンドウの幅内に収める
            # ベースとなる罫線の位置を取得
            match = re.search(r"[┼┤]", line)
            if match:
                # チャートの一番初めの列インデックス
                start = match.start() + 1

                # 開始時の100% の値を削除
                start_char = line[start]
                if start_char in ['╯', '│', '╮']:
                    start_char = " "
                elif start_char in ["╭", "╰"]:
                    start_char = "─"
                # 文字置き換え
                line = line[:start] + start_char + line[start + 1:]
                line += " " * max_x # 背景に色を付けるために空文字でパディングする

                stdscr.addstr(i, 0, line[shift_left:max_x])
                stdscr.addstr(i, start-shift_left, line[start:max_x], curses.color_pair(1))  # ウィンドウの幅内に収める

                # 電源使ってるときのチャート列は色を付ける
                for j, c in enumerate(line[start : start+len(power_history)]):
                    if power_history[j].startswith("AC"):
                        stdscr.addstr(i, start-shift_left + j, c, curses.color_pair(10))

                #stdscr.addstr(i, start + len(render_history) - (shift_left + 2), " ", curses.color_pair(5))  # 色付き
                stdscr.addstr(i, start + len(render_history) - (shift_left + 2), " ")

    stdscr.refresh()

def main(stdscr):
    # キー入力の待機時間を設定（ノンブロッキングモード）
    curses.curs_set(0) # カーソル非表示
    curses.start_color()
    curses.use_default_colors()
    curses.init_pair(10, 51, 22) # くらい緑の背景
    curses.init_pair(5, curses.COLOR_WHITE, 124)   # より暗い赤
    curses.init_pair(1, 46, -1)

    stdscr.timeout(60000)  # 60秒（60000ミリ秒）でタイムアウトするように設定するよ

    try:
        while True:
            draw_graph(stdscr, pd.read_csv(LOG_PATH, names=['Time', 'Level', 'Power'], skipinitialspace=True))
            # タイム・アウトするかキー入力が発生するまで処理を停止する
            stdscr.getch()  # キーボード入力を取得して無視するよ
            # ここで60秒待つ代わりに、短いインターバルでループを回すよ
            time.sleep(0.1)  

    except KeyboardInterrupt:
        # Ctrl+Cが押された場合の終了処理
        curses.endwin()


curses.wrapper(main)
