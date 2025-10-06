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
    "$env:USERPROFILE\dev\monitor_switcher\switch.ps1"
}

function skate {
    "$env:USERPROFILE\dev\EA-skate-start-stop\EA_skate_start_stop.ps1"
}

# Use scrcpy to mirror Android phone display to virtual desktop like Samsung Dex which no longer works in later version of OneUI - auto-detects USB or wireless
# Requires scrcpy and adb to be installed and in PATH
# Device must be paired manually once via usb and tcp/ip
function dex {
    param(
        [string]$DisplaySize = "1920x1080/200",
        [switch]$ForceWireless
    )
    
    # Get all connected devices
    $allDevices = adb devices | Select-String "device$"
    $tcpDevices = $allDevices | Where-Object { $_ -match ":\d+\s+" }
    $usbDevices = $allDevices | Where-Object { $_ -notmatch ":\d+\s+" }
    
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
        scrcpy --serial $usbSerial --new-display=$DisplaySize --video-codec=h265 --stay-awake --turn-screen-off
        return
    }
    
    if ($tcpSerial) {
        Write-Host "Launching scrcpy via TCP/IP (serial: $tcpSerial)..." -ForegroundColor Green
        scrcpy --serial $tcpSerial --new-display=$DisplaySize --video-codec=h265 --stay-awake --turn-screen-off
        return
    }
}

function cast {
    & scrcpy --tcpip --stay-awake --turn-screen-off
}

# For finding Registry entries in Windows Installed Apps that cannot be deleted because the files have been manually deleted
# Call with: Search-RegistryUninstall -SearchPattern "YourSearchTerm"
function Search-RegistryUninstall {
  param(
    [Parameter(Mandatory=$true)]
    [string]$SearchPattern
  )

  $paths = @(
    'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall',
    'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall',
    'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall',
    'HKCU:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
  )

  $results = foreach ($p in $paths) {
    Get-ChildItem -Path $p -ErrorAction SilentlyContinue |
      ForEach-Object {
        $props = Get-ItemProperty -Path $_.PsPath -ErrorAction SilentlyContinue
        if ($props.DisplayName -and ($props.DisplayName -match $SearchPattern)) {
          [pscustomobject]@{
            DisplayName     = $props.DisplayName
            KeyPath         = $_.PsPath
            UninstallString = $props.UninstallString
            DisplayVersion  = $props.DisplayVersion
          }
        }
      }
  }

  $results | Format-Table -Auto
}

if ($env:TERM_PROGRAM -eq "kiro") { . "$(kiro --locate-shell-integration-path pwsh)" }
