; SpectralShield Inno Setup Script

[Setup]
AppName=SpectralShield
AppVersion=1.0
DefaultDirName={pf}\SpectralShield
DefaultGroupName=SpectralShield
OutputDir=installers/windows
OutputBaseFilename=SpectralShield-Installer
Compression=lzma
SolidCompression=yes
SetupIconFile=assets\icon.ico

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
Source: "app\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\SpectralShield"; Filename: "{app}\SpectralShield.exe"
Name: "{commondesktop}\SpectralShield"; Filename: "{app}\SpectralShield.exe"

[Run]
Filename: "{app}\SpectralShield.exe"; Description: "Launch SpectralShield"; Flags: nowait postinstall skipifsilent