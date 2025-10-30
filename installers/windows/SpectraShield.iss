; SpectralShield Windows Installer
; Installs to C:\SpectralShield and auto-runs on finish

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

[Files]
Source: "..\..\..\*"; DestDir: "{#InstallDir}"; Flags: recursesubdirs ignoreversion

[Icons]
Name: "{autodesktop}\SpectralShield"; Filename: "http://localhost:8080"
Name: "{group}\SpectralShield"; Filename: "http://localhost:8080"
Name: "{autodesktop}\Uninstall SpectralShield"; Filename: "{uninstallexe}"

[Run]
; Auto-run PowerShell script on install to start Docker and container
Filename: "powershell.exe"; \
  Parameters: "-NoProfile -ExecutionPolicy Bypass -File ""{#InstallDir}\deploy.ps1"""; \
  WorkingDir: "{#InstallDir}"; Flags: shellexec waituntilterminated

; Auto-launch UI in browser after script completes
Filename: "http://localhost:8080"; Flags: shellexec postinstall

[UninstallDelete]
Type: filesandordirs; Name: "{#InstallDir}"

