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

# Use scrcpy to mirror Android phone display - auto-detects USB or wireless
# Requires scrcpy to be installed and in PATH
# Use scrcpy to mirror Android phone display - auto-detects USB or wireless
# Requires scrcpy to be installed and in PATH
# Use scrcpy to mirror Android phone display - auto-detects USB or wireless
# Requires scrcpy to be installed and in PATH
function dex {
    param(
        [string]$DisplaySize = "1920x1080/225",
        [switch]$ForceWireless
    )
    
    # Get all connected devices
    $allDevices = adb devices | Select-String "device$"
    $usbDevices = $allDevices | Where-Object { $_ -notmatch "_adb-tls-connect._tcp" }
    $tcpDevices = $allDevices | Where-Object { $_ -match "_adb-tls-connect._tcp" }
    
    Write-Host "[DEBUG] All devices: $($allDevices.Count)" -ForegroundColor Cyan
    Write-Host "[DEBUG] USB devices: $usbDevices" -ForegroundColor Cyan
    Write-Host "[DEBUG] TCP devices: $tcpDevices" -ForegroundColor Cyan
    
    # Extract serial numbers
    $usbSerial = if ($usbDevices) { ($usbDevices[0] -split '\s+')[0] }
    $tcpSerial = if ($tcpDevices) { ($tcpDevices[0] -split '\s+')[0] }
    
    Write-Host "[DEBUG] USB serial: $usbSerial" -ForegroundColor Cyan
    Write-Host "[DEBUG] TCP serial: $tcpSerial" -ForegroundColor Cyan
    
    # Priority: USB > TCP > mDNS discovery (unless ForceWireless)
    if ($usbSerial -and -not $ForceWireless) {
        Write-Host "Launching scrcpy via USB (serial: $usbSerial)..." -ForegroundColor Green
        scrcpy -s $usbSerial --new-display=$DisplaySize --video-codec=h265
        return
    }
    
    if ($tcpSerial) {
        Write-Host "Launching scrcpy via TCP/IP (serial: $tcpSerial)..." -ForegroundColor Green
        scrcpy -s $tcpSerial --new-display=$DisplaySize --video-codec=h265
        return
    }
    
    # No devices connected - attempt mDNS discovery
    Write-Host "No devices connected, attempting mDNS discovery..." -ForegroundColor Yellow
    $env:ADB_MDNS_OPENSCREEN = "1"
    
    adb kill-server
    adb start-server
    Start-Sleep -Seconds 3
    
    # Check mDNS services
    $services = adb mdns services | Out-String
    Write-Host "[DEBUG] mDNS services:" -ForegroundColor Cyan
    Write-Host $services -ForegroundColor Yellow
    
    # Try connecting via mDNS service name
    if ($services -match "([\w-]+)\._adb-tls-connect\._tcp") {
        $serviceName = $matches[0]
        Write-Host "Discovered: $serviceName" -ForegroundColor Green
        
        adb connect $serviceName
        Start-Sleep -Seconds 2
        
        # Get the newly connected device serial
        $newTcpDevice = adb devices | Select-String "_adb-tls-connect._tcp.*device$"
        if ($newTcpDevice) {
            $newSerial = ($newTcpDevice -split '\s+')[0]
            scrcpy -s $newSerial --new-display=$DisplaySize --video-codec=h265
        }
    } else {
        Write-Host "ERROR: No devices found! Ensure Wireless Debugging is ON." -ForegroundColor Red
    }
}

function cast {
    & scrcpy --tcpip=192.168.40.117:46099
}

if ($env:TERM_PROGRAM -eq "kiro") { . "$(kiro --locate-shell-integration-path pwsh)" }
