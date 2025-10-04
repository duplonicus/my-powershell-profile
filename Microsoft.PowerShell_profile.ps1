function reboot {
    shutdown /f /r /t 0
}

function zzz {
    rundll32.exe powrprof.dll,SetSuspendState 0,1,0
}

function lock {
    rundll32.exe user32.dll,LockWorkStation
}

function killdcs {
    taskkill /f /im dcs.exe
}

function switchmon {
    & "C:\Users\dup\dev\monitor_switcher\switch.ps1"
}

function skate {
    & "C:\Users\dup\dev\EA-skate-start-stop\EA_skate_start_stop.ps1"
}

# Use scrcpy to mirror Android phone display
# Requires scrcpy to be installed and in PATH
function dex {
    & scrcpy --new-display=1920x1080/225 --video-codec=h265
}

# Phone display must remain on for this to work
# With wireless ADB enabled on the phone
function dexw {
    & scrcpy --tcpip=192.168.40.117:46099 --video-codec=h265 --new-display=1920x1080/225
}

function cast {
    & scrcpy --tcpip=192.168.40.117:46099
}

if ($env:TERM_PROGRAM -eq "kiro") { . "$(kiro --locate-shell-integration-path pwsh)" }
