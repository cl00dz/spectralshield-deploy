# SpectraShield Advanced Deployment (Windows)
$ErrorActionPreference = "Stop"
Write-Host "🚀 SpectraShield Deployment" -ForegroundColor Cyan

$RepoOwner = "cl00dz"; $RepoName = "spectralshield-deploy"
$ConfigFile = Join-Path $PSScriptRoot "deploy-config.json"
function Save-Config($Username){ @{GHCR_USERNAME=$Username}|ConvertTo-Json|Out-File $ConfigFile -Encoding utf8 }
function Load-Config(){ if(Test-Path $ConfigFile){Get-Content $ConfigFile|ConvertFrom-Json}else{$null} }
function Start-DockerDesktop(){ if(-not (Get-Process "Docker Desktop" -ErrorAction SilentlyContinue)){ 
  $p="C:\Program Files\Docker\Docker\Docker Desktop.exe"; if(Test-Path $p){ Start-Process $p; Start-Sleep 12 } } }
function Docker-Ready(){
  if(Get-Command docker -ErrorAction SilentlyContinue){ try{ docker info | Out-Null; return "docker"}catch{} }
  if(Get-Command wsl -ErrorAction SilentlyContinue){ try{ wsl docker info | Out-Null; return "wsl"}catch{} }
  return $null
}
function Update-Script(){
  try{
    $rel = Invoke-RestMethod "https://api.github.com/repos/$RepoOwner/$RepoName/releases/latest" -UseBasicParsing
    $latest = $rel.tag_name
    if(Test-Path "$PSScriptRoot\VERSION"){
      $local = Get-Content "$PSScriptRoot\VERSION"
      if($local -eq $latest){ return }
    }
    Write-Host "⬆ Updating to $latest..." -ForegroundColor Yellow
    $zipUrl = "https://github.com/$RepoOwner/$RepoName/archive/refs/tags/$latest.zip"
    Invoke-WebRequest $zipUrl -OutFile "$PSScriptRoot\update.zip"
    Expand-Archive "$PSScriptRoot\update.zip" "$PSScriptRoot\update-temp" -Force
    Copy-Item "$PSScriptRoot\update-temp\*\" "$PSScriptRoot" -Recurse -Force
    Remove-Item "$PSScriptRoot\update.zip"
    Remove-Item "$PSScriptRoot\update-temp" -Recurse -Force
    $latest | Out-File "$PSScriptRoot\VERSION"
    Write-Host "✅ Updated. Re-run deploy.ps1" -ForegroundColor Green; exit
  }catch{}
}
Update-Script

$config = Load-Config
if($config -and $config.GHCR_USERNAME){ $GH_USER=$config.GHCR_USERNAME }
else{ $GH_USER = Read-Host "Enter your GitHub username for GHCR (default: cl00dz)"; if([string]::IsNullOrWhiteSpace($GH_USER)){ $GH_USER="cl00dz" } ; Save-Config $GH_USER }

Start-DockerDesktop
$mode = Docker-Ready
if(-not $mode){ Write-Host "❌ Docker not running. Start Docker Desktop and try again." -ForegroundColor Red; exit 1 }

if(-not (Test-Path ".env")){ "HOST_PORT=8080" | Out-File -Encoding utf8 .env; Write-Host "⚙ Created .env (HOST_PORT=8080)" -ForegroundColor Yellow }

Write-Host "📦 Pulling image ghcr.io/$GH_USER/spectrashield:latest" -ForegroundColor Yellow
if($mode -eq "docker"){ docker pull ghcr.io/$GH_USER/spectrashield:latest } else { wsl docker pull ghcr.io/$GH_USER/spectrashield:latest }

Write-Host "🚀 Starting SpectraShield..." -ForegroundColor Cyan
if($mode -eq "docker"){ docker compose up -d } else { wsl docker compose up -d }
Write-Host "✅ Running at http://localhost:$((Get-Content .env | Select-String 'HOST_PORT'|%{$_.ToString().Split('=')[1]}) -as [int] -as [string])" -ForegroundColor Green
