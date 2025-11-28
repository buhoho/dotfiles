local M = {}

-- ファイル情報から再生時間を計算
local function calculate_duration(raw_info, file_size)
	-- WAVファイルの判定と計算
	if raw_info:match("WAVE audio") or raw_info:match("WAV") then
		local sample_rate = raw_info:match("(%d+)%s*Hz")
		local bit_depth = raw_info:match("(%d+)%s*bit")
		local channels = raw_info:match("stereo") and 2 or 1
		
		if sample_rate and bit_depth then
			local bytes_per_sec = tonumber(sample_rate) * (tonumber(bit_depth) / 8) * channels
			return file_size / bytes_per_sec
		end
	end
	
	-- MP3などの圧縮音声（ビットレートベース）
	local bitrate_str = raw_info:match("(%d+)%s*kbps")
	if bitrate_str then
		local bitrate = tonumber(bitrate_str)
		if bitrate and bitrate > 0 then
			-- (Bytes * 8) / (kbps * 1000)
			return (file_size * 8) / (bitrate * 1000)
		end
	end
	
	return nil
end

-- 秒数を "分:秒" 形式に変換
local function format_duration(seconds)
	local mins = math.floor(seconds / 60)
	local secs = math.floor(seconds % 60)
	return string.format("%d:%02d", mins, secs)
end

function M:peek(job)
	-- 1. file コマンドでファイル情報を取得
	local child = Command("file")
		:arg("-b")
		:arg(tostring(job.file.url))
		:stdout(Command.PIPED)
		:spawn()

	local output, err = child:wait_with_output()
	if not output then return end

	-- 2. 出力の整形（カンマを改行に変換）
	local raw_info = output.stdout:gsub(",%s*", "\n")
	
	-- 3. 再生時間を計算
	local file_size = job.file.cha.len
	local seconds = calculate_duration(raw_info, file_size)
	
	-- 4. 追加情報を生成
	local extra_info = ""
	if seconds then
		extra_info = string.format("\n----------------\nEst. Duration: %s", format_duration(seconds))
	end

	-- 5. 描画
	ya.preview_widgets(job, {
		ui.Text(raw_info .. extra_info):area(job.area)
	})
end

function M:seek(job)
	-- スクロール実装が必要なら追加
end

return M
