# Install jqssun/android-airplay-server (AirPlay receiver) on Android TV
[CmdletBinding()]
param(
    [string]$TvHost = $env:TV_HOST,
    [string]$AirPlayName = $env:AIRPLAY_NAME,
    [string]$Tag = "v0.0.33"
)

$ErrorActionPreference = "Stop"

if (-not $TvHost) {
    Write-Error "Set TV_HOST or pass -TvHost <ip>, e.g. .\airplay\build-and-install.ps1 -TvHost 192.168.1.42"
    exit 1
}

$env:TV_HOST = $TvHost
$Root = Split-Path -Parent $PSScriptRoot
$Python = Join-Path $Root "tools\venv\Scripts\python.exe"
if (-not (Test-Path $Python)) {
    $Python = "python"
}

$Pkg = "io.github.jqssun.airplay"
$ApkDir = Join-Path $Root "work\airplay"
New-Item -ItemType Directory -Force -Path $ApkDir | Out-Null
$LocalApk = Join-Path $ApkDir "airplay-$Tag.apk"

# Download official release APK if not already cached
if (-not (Test-Path $LocalApk)) {
    $Url = "https://github.com/jqssun/android-airplay-server/releases/download/$Tag/app-release.apk"
    Write-Host "Downloading AirPlay receiver ($Tag) from GitHub releases..."
    Invoke-WebRequest -Uri $Url -OutFile $LocalApk
}

Write-Host "Connecting to TV at $TvHost..."
& $Python -I (Join-Path $Root "tools\tv.py") --probe

Write-Host "Pushing APK to TV..."
& $Python -I (Join-Path $Root "tools\tv.py") --push $LocalApk /data/local/tmp/airplay.apk

Write-Host "Installing APK..."
& $Python -I (Join-Path $Root "tools\tv.py") "pm install -r /data/local/tmp/airplay.apk"
& $Python -I (Join-Path $Root "tools\tv.py") "rm -f /data/local/tmp/airplay.apk"

if (-not $AirPlayName) {
    $AirPlayName = (& $Python -I (Join-Path $Root "tools\tv.py") "settings get global device_name").Trim()
    if (-not $AirPlayName) { $AirPlayName = "Android TV" }
}

Write-Host "Configuring AirPlay receiver as '$AirPlayName'..."
& $Python -I (Join-Path $Root "tools\tv.py") "am broadcast -a $Pkg.SET_SETTING -n $Pkg/.SettingsReceiver --es key server_name --es value '$AirPlayName'"
& $Python -I (Join-Path $Root "tools\tv.py") "am broadcast -a $Pkg.SET_SETTING -n $Pkg/.SettingsReceiver --es key boot_auto_start --es value true"
& $Python -I (Join-Path $Root "tools\tv.py") "dumpsys deviceidle whitelist +$Pkg"
& $Python -I (Join-Path $Root "tools\tv.py") "cmd appops set $Pkg RUN_IN_BACKGROUND allow"

Write-Host "Starting AirPlay service..."
& $Python -I (Join-Path $Root "tools\tv.py") "am start -n $Pkg/.MainActivity"
Start-Sleep -Seconds 1
& $Python -I (Join-Path $Root "tools\tv.py") "input keyevent KEYCODE_HOME"

Write-Host "`nSuccessfully installed and configured AirPlay receiver!" -ForegroundColor Green
Write-Host "TV shows up in Control Center / Screen Mirroring as: '$AirPlayName'"
