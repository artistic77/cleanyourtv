# AirPlay receiver (iPhone / iPad / Mac → TV)

Ad-free background AirPlay receiver, like Chromecast built-in but for Apple devices.
It uses [jqssun/android-airplay-server](https://github.com/jqssun/android-airplay-server), which builds on the
[UxPlay](https://github.com/FDH2/UxPlay) protocol core. That code is **GPL-3** and stays a separate app
(`io.github.jqssun.airplay`). This repo only holds the MIT build/install script and contains no GPL code.

### Windows (PowerShell)
```powershell
$env:TV_HOST = "192.168.1.42"
.\airplay\build-and-install.ps1
```

### Linux / macOS (Bash)
```bash
TV_HOST=192.168.1.42 ./airplay/build-and-install.sh
```

What the script does:

- Downloads or builds the pinned release tag (`AIRPLAY_TAG`, default `v0.0.33`)
- Pushes and installs `io.github.jqssun.airplay` on the TV
- Sets the AirPlay receiver name after the TV's `device_name` (or `AIRPLAY_NAME`)
- Configures automatic start on TV boot
- Exempts the app from Doze and background execution limits

When an Apple device starts mirroring or streaming, the receiver opens full screen on its own. When idle, it is a lightweight foreground service using ~27 MB of RAM.

### Settings
Other settings can be changed over ADB, for example to require a PIN:

```powershell
$env:TV_HOST = "192.168.1.42"
tools\venv\Scripts\python.exe -I tools\tv.py "am broadcast -a io.github.jqssun.airplay.SET_SETTING -n io.github.jqssun.airplay/.SettingsReceiver --es key require_pin --es value true"
```

To list all current settings:
```powershell
tools\venv\Scripts\python.exe -I tools\tv.py "am broadcast -a io.github.jqssun.airplay.LIST_SETTINGS -n io.github.jqssun.airplay/.SettingsReceiver"
```

### Uninstall / Remove
To completely remove the AirPlay receiver:
```powershell
tools\venv\Scripts\python.exe -I tools\tv.py "pm uninstall io.github.jqssun.airplay"
```
