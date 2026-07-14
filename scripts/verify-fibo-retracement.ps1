$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$tools = Get-Content -Raw (Join-Path $root 'src/core/ToolsPalette_Tools.mqh')
$storage = Get-Content -Raw (Join-Path $root 'src/storage/ToolsPalette_Storage.mqh')
$render = Get-Content -Raw (Join-Path $root 'src/engine/ToolsPalette_Engine_Render.mqh')
$fibonacci = Get-Content -Raw (Join-Path $root 'src/tools/ToolsPalette_Fibonacci.mqh')
$interact = Get-Content -Raw (Join-Path $root 'src/engine/ToolsPalette_Engine_Interact.mqh')

function Assert-Match([string]$Text, [string]$Pattern, [string]$Message) {
    if ($Text -notmatch $Pattern) { throw $Message }
}

Assert-Match $tools '#define\s+TP_FIBO_RETRACEMENT_PRESET_VERSION\s+2' 'Preset version 2 is missing.'
Assert-Match $tools '0\.0,\s*0\.236,\s*0\.382,\s*0\.5,\s*0\.618,\s*0\.786,\s*1\.0,\s*1\.272,\s*1\.414,\s*1\.618,\s*2\.0,\s*2\.272,\s*2\.414,\s*2\.618,\s*3\.0,\s*3\.272,\s*3\.414,\s*3\.618,\s*4\.0,\s*4\.236,\s*4\.272,\s*4\.414,\s*4\.618,\s*4\.764' 'The exact ordered 24-level preset is missing.'
Assert-Match $tools 'true,\s*false,\s*true,\s*true,\s*true,\s*false,\s*true,\s*false,\s*false,\s*true,\s*false,\s*false,\s*false,\s*false,\s*false,\s*false,\s*false,\s*false,\s*false,\s*false,\s*false,\s*false,\s*false,\s*false' 'The exact six-level visibility map is missing.'
Assert-Match $tools 'void\s+TP_FillFibRetracementPreset\s*\(' 'Canonical preset helper is missing.'
Assert-Match $tools 'void\s+TP_MigrateFibRetracementPreset\s*\(' 'Migration helper is missing.'
Assert-Match $storage '#define\s+TP_DRAW_SCHEMA_VERSION\s+2' 'Drawing schema was not bumped to 2.'
Assert-Match $storage 'TP_MigrateFibRetracementPreset\s*\(m_drawnObjects\[i\]\)' 'Restore migration hook is missing.'
Assert-Match $render 'TP_FillFibRetracementPreset\s*\(pRatio,\s*pCol,\s*pOp,\s*pW,\s*pS,\s*pVis\)' 'Preview does not reuse the canonical preset.'
Assert-Match $fibonacci 'HitTestFibRetracement[\s\S]*const double\s+&lvlRatio\[\][\s\S]*const bool\s+&lvlVisible\[\]' 'Hit-test does not accept live level arrays.'
if ($fibonacci -match 'double\s+levels\[\]\s*=\s*\{0\.0,\s*0\.236') { throw 'Legacy hard-coded hit-test levels still exist.' }
Assert-Match $interact 'm_drawnObjects\[i\]\.fiboLevelRatio,[\s\r\n]*m_drawnObjects\[i\]\.fiboLevelVisible' 'Interaction caller does not pass live level arrays.'

Write-Host 'Fibonacci Retracement source checks passed.'
