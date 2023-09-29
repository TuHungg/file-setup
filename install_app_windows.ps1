# --> Run this command if no excution policy error: Set-ExcutionPolicy RemoteSigned -Scope CurrentUser

function StartRun {
  param (
    $msg
  )
  Write-Host(">> ", + $msg) -ForegroundColor Green
}

function DoneRun {
  Write-Host "DONE" -ForegroundColor Blue; Write-Host
}

Start-Process -Wait powershell -Verb runas -ArgumentList "Set-ItemProperty -Path REGISTRY::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -Name ConsentPromptBehaviorAdmin -Value 0"

Write-Start -msg "Install Scoop..."
if (Get-Command scoop -ErrorAction SilentlyContinue) {
  Write-Warning "Scoop already installed"
}
else {
  Set-ExecutionPolicy RemoteSigned -Scope CurrentUser # Optional: Needed to run a remote script the first time
  irm get.scoop.sh | iex
} 
DoneRun

StartRun -msg "Installing Scoop..."
scoop install git
scoop bucket add extras
scoop bucket add nerd-fonts
scoop bucket add java
scoop update

DoneRun


StartRun -msg "Installing Scoop's packages..."

# scoop install <name-packages>
scoop install extras/googlechrome
scoop install extras/vscode
scoop install extras/wpsoffice
scoop install extras/notepadnext
scoop install extras/windows-terminal
scoop install extras/postman
scoop install extras/spotify
scoop install nonportable/grammarly-np
scoop install main/nodejs-lts

Start-Process -Wait powershell -Verb runnas -ArgumentList "scoop install nerd-fonts/JetBrains-Mono vcredits-aio nonportable/virtualbox-np docker"

# StartRun -msg "Configuring alacritty"
# $DestinationPath = "~\AppData\"

StartRun -msg "Enable Virtualization"
Start-Process -Wait powershell -Verb runas -ArgumentList @"
      echo y | Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -Norestart
      echo y | Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Subsystems-Linus -All -Norestart
      echo y | Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -All -Norestart
      echo y | Enable-WindowsOptionalFeature -Online -FeatureName Containers -All -Norestart
"@
DoneRun

StartRun -msg "Installing WSL..."
if (!(wsl -l -v)) {
  wsl --install 
  wsl --update
  wsl --install --no-launch --web-download -d Ubuntu
}
else {
  Write-Warning "WSL installed :D"
}
DoneRun