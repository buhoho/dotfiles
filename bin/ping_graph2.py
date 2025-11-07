import curses
import subprocess
import re
import asciichartpy
import time
import argparse
import random

RATE = 6
TIME_OUT = 5000 # Mac 環境ではデフォルト5000msec らしい(ChatGPTによると)
MA_LENGTH = 50
LEFT_SHIFT = 0

class Ping():
    def __init__(self, args):
        self.args = args 


    def main(self, win):
        curses.curs_set(0) # カーソル非表示
        # Initialize color pairs
        curses.start_color()
        curses.init_pair(10, 196, curses.COLOR_BLACK)   # 紫
        curses.init_pair(5, curses.COLOR_WHITE, 124)   # より暗い赤
        curses.init_pair(4, curses.COLOR_WHITE, 88)   # さらに暗い赤
        curses.init_pair(3, curses.COLOR_WHITE, 52)
        curses.init_pair(2, 219, 234)
        curses.init_pair(1, curses.COLOR_WHITE, 0)

        self.servers = ["www.yahoo.co.jp", "1.1.1.1", "8.8.8.8", "8.8.4.4", "1.0.0.1", "208.67.222.222", "9.9.9.9", "64.6.64.6"]
        self.results = []
        self.results_ma = []

        try:
            while True:
                self.render(win)
                if len(self.results) > 500:
                    self.results = self.results[-500:]
                    self.results_ma = self.results_ma[-500:]
        except KeyboardInterrupt:
            # Ctrl+Cが押された場合の終了処理
            curses.endwin()

    def render(self, win):
        try:
            if self.args.color_test:
                self.results = [160, 150, 120, 100, 90,
                                80, 60, 50, 40, 30, TIME_OUT, TIME_OUT, TIME_OUT,
                                200, TIME_OUT, 230, 260]
            else:
                result = subprocess.run(["ping", "-c", "1", "-W", str(TIME_OUT), random.choice(self.servers)], capture_output=True, text=True, timeout=1)
                result_line = [line for line in result.stdout.split('\n') if 'bytes from' in line]
                if result_line:
                    self.results.append(float(re.search(r"time=(\d+\.\d+)", result_line[0]).group(1)))
                else:
                    self.results.append(TIME_OUT)
        except subprocess.TimeoutExpired:
            self.results.append(TIME_OUT)

        if len(self.results) >= MA_LENGTH:
            # 計算した平均値を moving_averages リストに追加する
            self.results_ma.append(sum(self.results[-MA_LENGTH:]) / MA_LENGTH)
        else:
            # 範囲外
            self.results_ma.append(0)

        self.draw_graph(win)
        time.sleep(RATE)

    def draw_graph(self, win):
        """バッテリー残量の履歴からグラフを描画する"""
        win.clear()

        # ターミナルの画面サイズを取得
        max_y, max_x = win.getmaxyx()

        results = self.results[-(max_x - 12):]

        # タイムアウトの値をレンダリング用の値に調整する
        # TIME_OUT のままレンダリングするとチャートが汚くなるので、
        # 前後のチャートの値をコピーしてなだらかにする
        last_ping = 49
        render_results = []
        for item in results:
            if item == TIME_OUT: 
                render_results.append(last_ping)
            else:
                render_results.append(item)
                last_ping = item

        graph = asciichartpy.plot([self.results_ma[-(max_x - 12):], render_results], cfg={'height': 10})

        # グラフの各行を画面サイズに収まるように描画
        for i, line in enumerate(graph.split('\n')):
            if i < max_y:  # ウィンドウの高さ内に収める
                try:
                    ping_time = float(line.split()[0])
                    color = curses.color_pair(1)
                    if ping_time > 1100:
                        color = curses.color_pair(10)
                    elif ping_time > 540:
                        color = curses.color_pair(5)
                    elif ping_time > 260:
                        color = curses.color_pair(4)
                    elif ping_time > 120:
                        color = curses.color_pair(3)
                    elif ping_time > 50:
                        color = curses.color_pair(2)
                except ValueError:
                    color = curses.color_pair(10)
                win.addstr(i, 0, " " * (max_x -1), color)  # ウィンドウの幅内に収める
                win.addstr(i, 0, line[LEFT_SHIFT:max_x], color)  # ウィンドウの幅内に収める

                match = re.search(r"[┼┤]", line)
                if match and True:
                    start = match.start()
                    for j, item in enumerate(results):
                        if item == TIME_OUT:
                            # タイムアウトの値を上書きレンダリングする
                            win.addstr(i, start + j - LEFT_SHIFT, "-", curses.color_pair(10))


        win.refresh()




def parseArg():
    parser = argparse.ArgumentParser(description='Ping with color visualization.')
    parser.add_argument('--color-test', action='store_true', help='Run the color test.')

    return parser.parse_args();

if __name__ == "__main__":
    curses.wrapper(Ping(parseArg()).main)
