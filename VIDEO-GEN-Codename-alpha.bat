@echo off

REM Generate a unique seed for each session
powershell -Command "$seed = Get-Random -Minimum 0 -Maximum 100000; Write-Output $seed" > tmp_seed.txt
set /p seed=<tmp_seed.txt

REM Video settings
set width=640
set height=480
set fps=30
set duration=60

REM Generate a random number for the video name
set /a random_number=%RANDOM% * (999999 - 100000 + 1) / 32768 + 100000
set video_name=Story_Series_Episode_%random_number%.mp4

REM Generate video frames and audio
set /a num_frames=%fps% * %duration%
powershell -Command "$video = New-Object System.Collections.ArrayList; $audio = New-Object System.Collections.ArrayList"

for /l %%n in (0, 1, %num_frames%) do (
  powershell -Command "$frame = New-Object 'System.Byte[,]' %height%, %width%, 3; $frame_type = $frame.GetType(); $frame_method = $frame_type.GetMethod('SetValue', [Type[]]@([Byte], [Int32], [Int32], [Int32]));"

  REM Generate shapes
  powershell -Command "$shape_types = @('circle', 'square', 'triangle'); $colors = @( @(255, 0, 0), @(0, 255, 0), @(0, 0, 255), @(255, 255, 0), @(255, 0, 255), @(0, 255, 255) ); $max_shapes = $n + 1; $max_intensity = $n + 1;"

  powershell -Command "for ($i = 0; $i -lt $max_shapes; $i++) { $shape_type = Get-Random -InputObject $shape_types; $color = Get-Random -InputObject $colors[0..($max_intensity - 1)]; $size = Get-Random -Minimum 10 -Maximum 61; $x = Get-Random -Minimum 0 -Maximum ($width - $size); $y = Get-Random -Minimum 0 -Maximum ($height - $size);"

  powershell -Command "if ($shape_type -eq 'circle') { $g = [System.Drawing.Graphics]::FromImage($frame); $brush = New-Object 'System.Drawing.SolidBrush' (New-Object 'System.Drawing.Color' $color[0], $color[1], $color[2]); $g.FillEllipse($brush, $x, $y, $size, $size); $g.Dispose(); }"
  powershell -Command "elseif ($shape_type -eq 'square') { $g = [System.Drawing.Graphics]::FromImage($frame); $brush = New-Object 'System.Drawing.SolidBrush' (New-Object 'System.Drawing.Color' $color[0], $color[1], $color[2]); $g.FillRectangle($brush, $x, $y, $size, $size); $g.Dispose(); }"
  powershell -Command "elseif ($shape_type -eq 'triangle') { $points = @(@( $x + ($size / 2), $y), @( $x, $y + $size ), @( $x + $size, $y + $size )); $g = [System.Drawing.Graphics]::FromImage($frame); $brush = New-Object 'System.Drawing.SolidBrush' (New-Object 'System.Drawing.Color' $color[0], $color[1], $color[2]); $g.FillPolygon($brush, $points); $g.Dispose(); }"

  REM Generate text
  powershell -Command "$text = '01010101010100'; $font = 'Arial'; $scale = Get-Random -Minimum 0.5 -Maximum 2.0; $thickness = Get-Random -Minimum 1 -Maximum 4; $color = Get-Random -InputObject @( @(0, 0, 0), @(255, 255, 255) );"

  powershell -Command "$drawing = [System.Drawing.Graphics]::FromImage($frame); $font_size = $drawing.MeasureString($text, $font, [int]$width).ToSize(); $x = Get-Random -Minimum 0 -Maximum ($width - $font_size.Width); $y = Get-Random -Minimum 0 -Maximum ($height - $font_size.Height);"
  powershell -Command "$brush = New-Object 'System.Drawing.SolidBrush' (New-Object 'System.Drawing.Color' $color[0], $color[1], $color[2]); $drawing.DrawString($text, ($scale * 16), $brush, $x, $y); $drawing.Dispose();"

  REM Add computer-generated noise
  powershell -Command "$noise = [byte[,]]::new($height, $width, 3); $rng = New-Object System.Random; $rng.NextBytes($noise); $frame_method.Invoke($frame, @([Byte], 0, 0, 0), $noise)"

  REM Add glitches
  powershell -Command "$glitch_count = $n + 1; $rng = New-Object System.Random;"

  powershell -Command "for ($i = 0; $i -lt $glitch_count; $i++) { $x = $rng.Next(0, $width); $y = $rng.Next(0, $height);"

  powershell -Command "$r = $rng.Next(0, 256); $g = $rng.Next(0, 256); $b = $rng.Next(0, 256); $frame_method.Invoke($frame, @([Byte], $r, $g, $b), $y, $x) }"

  powershell -Command "$video.Add($frame)"
  powershell -Command "$frequency = Get-Random -Minimum 100 -Maximum 1001; $duration = Get-Random -Minimum 100 -Maximum 501; $audio.Add((New-Object 'System.Media.SoundPlayer' ([System.IO.MemoryStream](New-Object 'System.IO.MemoryStream' -ArgumentList)) -ArgumentList (New-Object 'System.IO.MemoryStream' -ArgumentList (,($frequency | % { [Math]::Sin((2 * [Math]::PI * $frequency) / $audio.Count) }))))"
)

REM Export video frames
powershell -Command "$video_path = Join-Path -Path $pwd -ChildPath $video_name; $video[0].Save($video_path, [System.Drawing.Imaging.ImageFormat]::Jpeg); Write-Output $video_path" > tmp_video_path.txt
set /p video_path=<tmp_video_path.txt

REM Export audio
set audio_file=computer_audio_%random_number%.wav
powershell -Command "$audio_file_path = Join-Path -Path $pwd -ChildPath $audio_file; $audio[0].Save($audio_file_path, 'Wav'); Write-Output $audio_file_path" > tmp_audio_file_path.txt
set /p audio_file_path=<tmp_audio_file_path.txt

REM Load video and audio
set video_file=%video_path%
set audio_file=%audio_file_path%

REM Set audio for the video
powershell -Command "$video = New-Object 'System.Media.SoundPlayer' (New-Object 'System.IO.MemoryStream' -ArgumentList ([System.IO.File]::ReadAllBytes('%audio_file%')))"
powershell -Command "$video.SoundLocation = '%audio_file%'"

REM Merge audio and video
powershell -Command "$merged_video = Join-Path -Path $pwd -ChildPath 'merged_video.mp4'; (New-Object 'FFmpeg.NET.Engine.Mp4ConcatOutputBuilder' -ArgumentList ($video_file, $audio_file)).Join($merged_video); Write-Output $merged_video" > tmp_merged_video.txt
set /p merged_video=<tmp_merged_video.txt

REM Delete temporary files
del tmp_seed.txt
del tmp_video_path.txt
del tmp_audio_file_path.txt
del tmp_merged_video.txt

echo Video generation complete. Seed: %seed%
echo Final video name: %merged_video%
