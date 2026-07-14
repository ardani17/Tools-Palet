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

function Get-BracedBody([string]$Text, [int]$StartIndex, [string]$Message) {
    $openBrace = $Text.IndexOf('{', $StartIndex)
    if ($openBrace -lt 0) { throw $Message }

    $depth = 0
    for ($i = $openBrace; $i -lt $Text.Length; $i++) {
        if ($Text[$i] -eq '{') { $depth++ }
        elseif ($Text[$i] -eq '}') {
            $depth--
            if ($depth -eq 0) { return $Text.Substring($openBrace + 1, $i - $openBrace - 1) }
        }
    }
    throw $Message
}

function Get-FunctionBody([string]$Text, [string]$Signature, [string]$Message) {
    $match = [regex]::Match($Text, $Signature)
    if (-not $match.Success) { throw $Message }
    return Get-BracedBody $Text $match.Index $Message
}

Assert-Match $tools '#define\s+TP_FIBO_RETRACEMENT_PRESET_VERSION\s+2' 'Preset version 2 is missing.'
Assert-Match $tools '0\.0,\s*0\.236,\s*0\.382,\s*0\.5,\s*0\.618,\s*0\.786,\s*1\.0,\s*1\.272,\s*1\.414,\s*1\.618,\s*2\.0,\s*2\.272,\s*2\.414,\s*2\.618,\s*3\.0,\s*3\.272,\s*3\.414,\s*3\.618,\s*4\.0,\s*4\.236,\s*4\.272,\s*4\.414,\s*4\.618,\s*4\.764' 'The exact ordered 24-level preset is missing.'
Assert-Match $tools 'true,\s*false,\s*true,\s*true,\s*true,\s*false,\s*true,\s*false,\s*false,\s*true,\s*false,\s*false,\s*false,\s*false,\s*false,\s*false,\s*false,\s*false,\s*false,\s*false,\s*false,\s*false,\s*false,\s*false' 'The exact six-level visibility map is missing.'
Assert-Match $tools 'void\s+TP_FillFibRetracementPreset\s*\(' 'Canonical preset helper is missing.'
Assert-Match $tools 'void\s+TP_MigrateFibRetracementPreset\s*\(' 'Migration helper is missing.'
Assert-Match $storage '#define\s+TP_DRAW_SCHEMA_VERSION\s+2' 'Drawing schema was not bumped to 2.'
Assert-Match $storage 'TP_MigrateFibRetracementPreset\s*\(m_drawnObjects\[i\]\)' 'Restore migration hook is missing.'
Assert-Match $render 'TP_FillFibRetracementPreset\s*\(pRatio,\s*pCol,\s*pOp,\s*pW,\s*pS,\s*pVis\)' 'Preview does not reuse the canonical preset.'
$hitTestBody = Get-FunctionBody $fibonacci 'bool\s+CFibonacciTools::HitTestFibRetracement\s*\(' 'Fib retracement hit-test implementation is missing.'
Assert-Match $hitTestBody 'ArraySize\s*\(\s*lvlRatio\s*\)' 'Hit-test does not size itself from the live ratio array.'
Assert-Match $hitTestBody '!\s*lvlVisible\s*\[\s*i\s*\]' 'Hit-test does not skip hidden live levels.'
Assert-Match $hitTestBody 'lvlRatio\s*\[\s*i\s*\]' 'Hit-test does not calculate lines from live ratios.'
if ($fibonacci -match 'double\s+levels\[\]\s*=\s*\{0\.0,\s*0\.236') { throw 'Legacy hard-coded hit-test levels still exist.' }
Assert-Match $interact 'm_drawnObjects\[i\]\.fiboLevelRatio,[\s\r\n]*m_drawnObjects\[i\]\.fiboLevelVisible' 'Interaction caller does not pass live level arrays.'

$addDrawnObjectBody = Get-FunctionBody $tools 'int\s+CDrawingEngine::AddDrawnObject\s*\(' 'AddDrawnObject implementation is missing.'
$presetCalls = [regex]::Matches($addDrawnObjectBody, 'TP_FillFibRetracementPreset\s*\(')
if ($presetCalls.Count -ne 1) { throw 'AddDrawnObject must contain exactly one retracement preset call.' }
$fiboBranch = [regex]::Match($addDrawnObjectBody, 'if\s*\(\s*toolType\s*==\s*TOOL_FIBO_RETRACEMENT\s*\)')
if (-not $fiboBranch.Success) { throw 'AddDrawnObject retracement branch is missing.' }
$fiboBranchBody = Get-BracedBody $addDrawnObjectBody $fiboBranch.Index 'AddDrawnObject retracement branch is malformed.'
Assert-Match $fiboBranchBody 'TP_FillFibRetracementPreset\s*\(' 'AddDrawnObject does not initialize the preset inside the retracement branch.'

$migrationBody = Get-FunctionBody $tools 'void\s+TP_MigrateFibRetracementPreset\s*\(' 'Fib retracement migration implementation is missing.'
foreach ($style in @(
    @{ Old = 'oldColors'; Property = 'fiboLevelColor' },
    @{ Old = 'oldOpacities'; Property = 'fiboLevelOpacity' },
    @{ Old = 'oldWidths'; Property = 'fiboLevelWidth' },
    @{ Old = 'oldStyles'; Property = 'fiboLevelStyle' }
)) {
    Assert-Match $migrationBody ("ArrayCopy\s*\(\s*{0}\s*,\s*object\.{1}\s*\)" -f $style.Old, $style.Property) "Migration does not preserve $($style.Property) before resetting the preset."
    Assert-Match $migrationBody ("object\.{0}\s*\[\s*i\s*\]\s*=\s*{1}\s*\[\s*j\s*\]" -f $style.Property, $style.Old) "Migration does not restore matching $($style.Property) values."
}

Write-Host 'Fibonacci Retracement source checks passed.'
