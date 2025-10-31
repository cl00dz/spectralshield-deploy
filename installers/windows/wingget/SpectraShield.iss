; SpectralShield Windows Installer
; Installs app files from CI into C:\SpectralShield and auto-runs deploy script

#define AppName "SpectralShield"
#define AppVersion "1.0.0"
#define AppPublisher "SpectralShield Project"
#define InstallDir "C:\\SpectralShield"

[Setup]
AppName={#AppName}
AppVersion={#AppVersion}
DefaultDirName="{#InstallDir}"
DisableProgramGroupPage=yes
OutputBaseFilename=SpectralShield-Installer
Compression=lzma
SolidCompression=yes
ArchitecturesInstallIn64BitMode=x64
Uninstallable=yes
WizardStyle=modern
DisableReadyMemo=no
DisableFinishedPage=no
DisableStartupPrompt=no
UsePreviousLanguage=no

; Elevate installer
PrivilegesRequired=admin

[Files]
; NOTE: CI clones the app into "app-source" at repo root
; This .iss file lives in installers/windows/wingget, so we go up 3 levels
Source: "{#SourcePath}\..\..\..\app-source\*"; \
    DestDir: "{#InstallDir}"; \
    Flags: recursesubdirs ignoreversion createallsubdirs

; Copy deploy script from installer folder into install directory
Source: "{#SourcePath}\deploy.ps1"; DestDir: "{#InstallDir}"

[Icons]
Name: "{autodesktop}\SpectralShield"; Filename: "http://localhost:8080"
Name: "{group}\SpectralShield"; Filename: "http://localhost:8080"
Name: "{group}\Uninstall SpectralShield"; Filename: "{uninstallexe}"

[Run]
; Run deploy script after install to start docker container
Filename: "powershell.exe"; \
  Parameters: "-NoProfile -ExecutionPolicy Bypass -File ""{#InstallDir}\deploy.ps1"""; \
  WorkingDir: "{#InstallDir}"; \
  Flags: shellexec waituntilterminated runhidden

; Auto-open app in browser
Filename: "http://localhost:8080"; Flags: shellexec postinstall

[UninstallDelete]
Type: filesandordirs; Name: "{#InstallDir}"

