; Inno Setup script for SpectraShield
#define MyAppName "SpectraShield"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "cl00dz"
#define MyAppURL "https://github.com/cl00dz/spectralshield-deploy"
#define MyAppExeName "deploy.ps1"

[Setup]
AppId={{7B8D8C62-5C1A-4C17-8F85-SS-SP-SHIELD}}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
DefaultDirName={autopf}\SpectraShield
DisableDirPage=yes
DefaultGroupName=SpectraShield
OutputDir=.
OutputBaseFilename=SpectraShield-Installer
Compression=lzma
SolidCompression=yes
ArchitecturesInstallIn64BitMode=x64

[Files]
Source: "..\..\deploy.ps1"; DestDir: "{app}"
Source: "..\..\deploy.sh"; DestDir: "{app}"
Source: "..\..\docker-compose.yml"; DestDir: "{app}"
Source: "..\..\assets\icon.ico"; DestDir: "{app}"

[Icons]
Name: "{autoprograms}\SpectraShield"; Filename: "powershell.exe"; Parameters: "-ExecutionPolicy Bypass -File ""{app}\deploy.ps1"""; WorkingDir: "{app}"; IconFilename: "{app}\icon.ico"
Name: "{autodesktop}\SpectraShield"; Filename: "powershell.exe"; Parameters: "-ExecutionPolicy Bypass -File ""{app}\deploy.ps1"""; WorkingDir: "{app}"; IconFilename: "{app}\icon.ico"; Tasks: desktopicon

[Tasks]
Name: "desktopicon"; Description: "Create a &desktop icon"; GroupDescription: "Additional icons:"

[Run]
Filename: "powershell.exe"; Parameters: "-ExecutionPolicy Bypass -File ""{app}\deploy.ps1"""; Flags: nowait postinstall

