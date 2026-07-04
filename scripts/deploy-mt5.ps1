<#
.SYNOPSIS
  Deploy Tools Palette ke MetaTrader 5 via junction (tanpa copy manual).
.DESCRIPTION
  Membuat directory junction: <TerminalDataPath>\MQL5\Experts\ToolsPalet -> <repo>\src
  Junction (/J) tidak butuh hak admin, beda dengan symbolic link.
.PARAMETER TerminalDataPath
  Path folder data terminal MT5 (yang berisi subfolder MQL5).
  Cari via MetaEditor/Terminal: File > Open Data Folder.
.EXAMPLE
  .\scripts\deploy-mt5.ps1 -TerminalDataPath "C:\Users\ardani\AppData\Roaming\MetaQuotes\Terminal\<HASH>"
#>
param(
    [Parameter(Mandatory = $true)]
    [string]$TerminalDataPath
)

$ErrorActionPreference = "Stop"

# Repo root = parent dari folder scripts ini
$repoRoot = Split-Path -Parent $PSScriptRoot
$srcPath  = Join-Path $repoRoot "src"

if (-not (Test-Path $srcPath)) {
    Write-Error "Folder src/ tidak ditemukan di: $srcPath"
    exit 1
}

$expertsPath = Join-Path $TerminalDataPath "MQL5\Experts"
if (-not (Test-Path $expertsPath)) {
    Write-Error "Folder Experts tidak ditemukan: $expertsPath`nPastikan -TerminalDataPath menunjuk folder data MT5 (berisi MQL5). Di terminal: File > Open Data Folder."
    exit 1
}

$linkPath = Join-Path $expertsPath "ToolsPalet"

if (Test-Path $linkPath) {
    $item = Get-Item $linkPath -Force
    if ($item.LinkType) {
        Write-Host "Junction sudah ada, menghapus yang lama: $linkPath"
        (Get-Item $linkPath -Force).Delete()
    } else {
        Write-Error "Path sudah ada dan BUKAN junction (folder/file asli): $linkPath`nHapus/backup manual dulu sebelum menjalankan script ini."
        exit 1
    }
}

New-Item -ItemType Junction -Path $linkPath -Target $srcPath | Out-Null

Write-Host ""
Write-Host "OK. Junction dibuat:" -ForegroundColor Green
Write-Host "  $linkPath  ->  $srcPath"
Write-Host ""
Write-Host "Langkah berikut:"
Write-Host "  1. Buka MetaEditor"
Write-Host "  2. Navigasi: Experts\ToolsPalet\Tools Palet.mq5"
Write-Host "  3. Compile (F7) -> pastikan 0 error, 0 warning"
