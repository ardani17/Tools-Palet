# Fibonacci Retracement Level Preset Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Give every Fibonacci Retracement the requested 24-level preset, with only `0`, `0.382`, `0.5`, `0.618`, `1`, and `1.618` visible by default, and migrate restored version-1 drawings exactly once.

**Architecture:** A shared MQL5 preset helper owns the six parallel level arrays and is reused by object creation, migration, and placement preview. Drawing schema version 2 triggers a one-time style-preserving migration for restored Fibonacci Retracements, while hit-testing consumes each object's live ratio and visibility arrays instead of a hard-coded list.

**Tech Stack:** MQL5, MetaTrader 5 `CCanvas`, tagged-text drawing persistence, PowerShell source-contract checks, MetaEditor CLI.

## Global Constraints

- Scope is limited to `TOOL_FIBO_RETRACEMENT`; do not change defaults for Expansion, Channel, Time Zones, Fan, or Arcs.
- The ordered preset is exactly: `0`, `0.236`, `0.382`, `0.5`, `0.618`, `0.786`, `1`, `1.272`, `1.414`, `1.618`, `2`, `2.272`, `2.414`, `2.618`, `3`, `3.272`, `3.414`, `3.618`, `4`, `4.236`, `4.272`, `4.414`, `4.618`, `4.764`.
- Default-visible levels are exactly: `0`, `0.382`, `0.5`, `0.618`, `1`, `1.618`.
- Existing style values for matching ratios survive migration; new ratios use normal defaults of opacity `100`, width `2`, and solid style `0`.
- Migration applies the new visibility map and removes ratios outside the new preset, but it must not change anchors, lock state, object visibility, or unrelated properties.
- User edits made after migration must persist across later EA restarts and reattachments.
- Do not add Extend behavior, redesign Settings, change labels, add style controls, or bump the public EA version in this feature branch.
- Verification requires PowerShell source-contract checks, MetaEditor compilation with `0 errors, 0 warnings`, and manual MT5 smoke tests because the repository has no MQL5 unit-test harness.

---

## File structure

- Create `scripts/verify-fibo-retracement.ps1`: deterministic source-contract checks for the preset, migration hook, preview reuse, and live-array hit-test.
- Modify `src/core/ToolsPalette_Tools.mqh`: canonical preset constant/helper, style-preserving migration helper, and new-object initialization.
- Modify `src/storage/ToolsPalette_Storage.mqh`: schema version 2 detection and one-time migration during restore.
- Modify `src/engine/ToolsPalette_Engine_Render.mqh`: preview obtains its arrays from the canonical preset helper.
- Modify `src/tools/ToolsPalette_Fibonacci.mqh`: hit-test signature and implementation consume live ratios and visibility.
- Modify `src/engine/ToolsPalette_Engine_Interact.mqh`: pass the current object's arrays into the hit-test.
- Modify `docs/panduan-penggunaan.md`: document the complete list and six default-visible levels.

### Task 1: Add an executable source-contract check

**Files:**
- Create: `scripts/verify-fibo-retracement.ps1`

**Interfaces:**
- Consumes: repository files beneath `src/`.
- Produces: a PowerShell command that exits nonzero until all preset integration points exist, then prints `Fibonacci Retracement source checks passed.`.

- [ ] **Step 1: Add the failing source-contract script**

Create the file with strict error handling and these checks:

```powershell
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
```

- [ ] **Step 2: Run the check and confirm the expected failure**

Run:

```powershell
& .\scripts\verify-fibo-retracement.ps1
```

Expected: nonzero exit with `Preset version 2 is missing.` No production source has changed yet.

- [ ] **Step 3: Commit the executable check**

```powershell
git add scripts/verify-fibo-retracement.ps1
git commit -m "test: add fibonacci retracement source checks"
```

### Task 2: Centralize and apply the 24-level preset

**Files:**
- Modify: `src/core/ToolsPalette_Tools.mqh` near `DrawnObject` and `AddDrawnObject`.

**Interfaces:**
- Produces: `TP_FIBO_RETRACEMENT_PRESET_VERSION`, `TP_FillFibRetracementPreset(...)`, and `TP_MigrateFibRetracementPreset(DrawnObject &object)` for Tasks 3 and 4.
- Produces: new Fibonacci Retracement objects initialized with six visible levels and 18 hidden levels.

- [ ] **Step 1: Define the shared preset filler after `DrawnObject`**

Add the preset version and a global helper after the struct. The helper must resize and populate all six arrays:

```mql5
#define TP_FIBO_RETRACEMENT_PRESET_VERSION 2

void TP_FillFibRetracementPreset(double &ratios[], color &colors[],
                                  int &opacities[], int &widths[],
                                  int &styles[], bool &visible[])
  {
   const double presetRatios[] = {0.0,0.236,0.382,0.5,0.618,0.786,
                                   1.0,1.272,1.414,1.618,2.0,2.272,
                                   2.414,2.618,3.0,3.272,3.414,3.618,
                                   4.0,4.236,4.272,4.414,4.618,4.764};
   const bool presetVisible[] = {true,false,true,true,true,false,
                                  true,false,false,true,false,false,
                                  false,false,false,false,false,false,
                                  false,false,false,false,false,false};
   const color presetColors[] = {clrGray,clrCrimson,clrOrange,clrGoldenrod,
                                  clrSeaGreen,clrDarkCyan,clrGray,clrDodgerBlue,
                                  clrDodgerBlue,clrDodgerBlue,clrDodgerBlue,clrDodgerBlue,
                                  clrDodgerBlue,clrMediumOrchid,clrDodgerBlue,clrDodgerBlue,
                                  clrDodgerBlue,clrBlueViolet,clrDodgerBlue,clrCrimson,
                                  clrDodgerBlue,clrDodgerBlue,clrDeepPink,clrDodgerBlue};
   const int count = ArraySize(presetRatios);
   ArrayResize(ratios,count);   ArrayResize(colors,count);
   ArrayResize(opacities,count); ArrayResize(widths,count);
   ArrayResize(styles,count);   ArrayResize(visible,count);
   for(int i=0;i<count;i++)
     {
      ratios[i]=presetRatios[i]; colors[i]=presetColors[i];
      opacities[i]=100; widths[i]=2; styles[i]=0;
      visible[i]=presetVisible[i];
     }
  }
```

- [ ] **Step 2: Add the style-preserving migration helper**

Copy all old arrays before calling the preset filler. For each new ratio, find a prior ratio within `1e-6` and copy each style field only when its old index exists. Do not copy old visibility because migration must apply the new visibility map:

```mql5
void TP_MigrateFibRetracementPreset(DrawnObject &object)
  {
   double oldRatios[]; color oldColors[]; int oldOpacities[];
   int oldWidths[]; int oldStyles[];
   ArrayCopy(oldRatios,object.fiboLevelRatio);
   ArrayCopy(oldColors,object.fiboLevelColor);
   ArrayCopy(oldOpacities,object.fiboLevelOpacity);
   ArrayCopy(oldWidths,object.fiboLevelWidth);
   ArrayCopy(oldStyles,object.fiboLevelStyle);

   TP_FillFibRetracementPreset(object.fiboLevelRatio,
                               object.fiboLevelColor,
                               object.fiboLevelOpacity,
                               object.fiboLevelWidth,
                               object.fiboLevelStyle,
                               object.fiboLevelVisible);

   for(int i=0;i<ArraySize(object.fiboLevelRatio);i++)
      for(int j=0;j<ArraySize(oldRatios);j++)
         if(MathAbs(object.fiboLevelRatio[i]-oldRatios[j])<1e-6)
           {
            if(j<ArraySize(oldColors))    object.fiboLevelColor[i]=oldColors[j];
            if(j<ArraySize(oldOpacities)) object.fiboLevelOpacity[i]=oldOpacities[j];
            if(j<ArraySize(oldWidths))    object.fiboLevelWidth[i]=oldWidths[j];
            if(j<ArraySize(oldStyles))    object.fiboLevelStyle[i]=oldStyles[j];
            break;
           }
  }
```

- [ ] **Step 3: Replace the legacy new-object block**

In `AddDrawnObject`, remove the 11-level inline Fibonacci Retracement initialization and call:

```mql5
TP_FillFibRetracementPreset(m_drawnObjects[sz].fiboLevelRatio,
                            m_drawnObjects[sz].fiboLevelColor,
                            m_drawnObjects[sz].fiboLevelOpacity,
                            m_drawnObjects[sz].fiboLevelWidth,
                            m_drawnObjects[sz].fiboLevelStyle,
                            m_drawnObjects[sz].fiboLevelVisible);
```

Leave every other Fibonacci default block unchanged.

- [ ] **Step 4: Run focused source and compile checks**

Run the source check. Expected: it now proceeds past the preset checks and fails at `Drawing schema was not bumped to 2.`

Then compile:

```powershell
& 'C:\Program Files\MetaTrader 5\metaeditor64.exe' /compile:'C:\Users\ardani\Documents\APLIKASI\Tools-Palet\src\Tools Palet.mq5' /log
Get-Content 'C:\Users\ardani\Documents\APLIKASI\Tools-Palet\src\Tools Palet.log' -Tail 5
```

Expected: `Result: 0 errors, 0 warnings`.

- [ ] **Step 5: Commit the canonical preset**

```powershell
git add src/core/ToolsPalette_Tools.mqh
git commit -m "feat: add complete fibonacci retracement preset"
```

### Task 3: Migrate restored version-1 drawings once

**Files:**
- Modify: `src/storage/ToolsPalette_Storage.mqh` near schema declaration and `RestoreDrawings()`.

**Interfaces:**
- Consumes: `TP_FIBO_RETRACEMENT_PRESET_VERSION` and `TP_MigrateFibRetracementPreset(DrawnObject &object)` from Task 2.
- Produces: version-2 drawing files and a restore path that migrates only version-1 Fibonacci Retracements.

- [ ] **Step 1: Bump the drawing schema and retain the loaded version**

Change `TP_DRAW_SCHEMA_VERSION` to `2`. In `RestoreDrawings()`, initialize `int fileVersion=1;` before the read loop. Replace the special-case `TPDRAW v=1` branch and the generic header branch with:

```mql5
if(StringFind(line,"TPDRAW v=")==0)
  {
   fileVersion=(int)StringToInteger(StringSubstr(line,9));
   if(fileVersion>TP_DRAW_SCHEMA_VERSION)
     {
      Print("ToolsPalette: drawing file schema v",fileVersion,
            " newer than supported; starting empty");
      FileClose(h);
      return true;
     }
   continue;
  }
```

- [ ] **Step 2: Run migration after materialization**

After restoring the object counter and count, but before returning, migrate only an older supported store:

```mql5
if(fileVersion<TP_FIBO_RETRACEMENT_PRESET_VERSION)
  {
   bool migrated=false;
   for(int i=0;i<ArraySize(m_drawnObjects);i++)
      if(m_drawnObjects[i].toolType==TOOL_FIBO_RETRACEMENT)
        {
         TP_MigrateFibRetracementPreset(m_drawnObjects[i]);
         migrated=true;
        }
   if(migrated) MarkDrawingsDirty();
  }
```

Do not migrate a file whose header is already version 2. `SaveDrawings()` will automatically write `TPDRAW v=2` on the debounced flush.

- [ ] **Step 3: Run source and compile checks**

Run:

```powershell
& .\scripts\verify-fibo-retracement.ps1
```

Expected: it proceeds past storage checks and fails at `Preview does not reuse the canonical preset.`

Run the MetaEditor command from Task 2. Expected: `Result: 0 errors, 0 warnings`.

- [ ] **Step 4: Commit migration**

```powershell
git add src/storage/ToolsPalette_Storage.mqh
git commit -m "feat: migrate fibonacci retracement preset once"
```

### Task 4: Synchronize preview and live-array hit-testing

**Files:**
- Modify: `src/engine/ToolsPalette_Engine_Render.mqh` in the Fibonacci Retracement preview branch.
- Modify: `src/tools/ToolsPalette_Fibonacci.mqh` declaration and definition of `HitTestFibRetracement`.
- Modify: `src/engine/ToolsPalette_Engine_Interact.mqh` in the `TOOL_FIBO_RETRACEMENT` dispatch.

**Interfaces:**
- Consumes: `TP_FillFibRetracementPreset(...)` from Task 2.
- Produces: `HitTestFibRetracement(..., int threshold, const double &lvlRatio[], const bool &lvlVisible[])`.

- [ ] **Step 1: Make preview use the shared preset**

Keep the existing six temporary arrays but remove its inline `N`, ratio, color, and population definitions. Replace them with:

```mql5
TP_FillFibRetracementPreset(pRatio,pCol,pOp,pW,pS,pVis);
```

Retain the existing `DrawFibRetracementOn(...)` call unchanged.

- [ ] **Step 2: Change the hit-test interface and implementation**

Update both declaration and definition to:

```mql5
bool HitTestFibRetracement(int mx,int my,int canvasW,
                            int x1,int y1,int x2,int y2,int threshold,
                            const double &lvlRatio[],
                            const bool &lvlVisible[]);
```

Replace the hard-coded `levels[]` loop with:

```mql5
int xL=MathMin(x1,x2);
int xR=MathMax(x1,x2);
int count=MathMin(ArraySize(lvlRatio),ArraySize(lvlVisible));
for(int i=0;i<count;i++)
  {
   if(!lvlVisible[i]) continue;
   int ly=y1+(int)MathRound((double)(y2-y1)*lvlRatio[i]);
   if(PointToSegmentDistance(mx,my,xL,ly,xR,ly)<=threshold) return true;
  }
return false;
```

The unused `canvasW` parameter may remain for interface consistency with sibling Fibonacci hit-tests.

- [ ] **Step 3: Pass the current object's arrays from interaction dispatch**

Update the `TOOL_FIBO_RETRACEMENT` call to append:

```mql5
m_hitThreshold,
m_drawnObjects[i].fiboLevelRatio,
m_drawnObjects[i].fiboLevelVisible
```

Keep the rest of the object dispatch unchanged.

- [ ] **Step 4: Run the full automated and compile checks**

```powershell
& .\scripts\verify-fibo-retracement.ps1
```

Expected: `Fibonacci Retracement source checks passed.`

Run the MetaEditor command from Task 2. Expected: `Result: 0 errors, 0 warnings`.

- [ ] **Step 5: Commit preview and hit-test synchronization**

```powershell
git add src/engine/ToolsPalette_Engine_Render.mqh src/tools/ToolsPalette_Fibonacci.mqh src/engine/ToolsPalette_Engine_Interact.mqh
git commit -m "fix: synchronize fibonacci preview and hit testing"
```

### Task 5: Document and manually verify the completed feature

**Files:**
- Modify: `docs/panduan-penggunaan.md` in the Fibonacci Retracement section.

**Interfaces:**
- Consumes: completed behavior from Tasks 2–4.
- Produces: user-facing documentation and final evidence for merge readiness.

- [ ] **Step 1: Update the usage guide**

Document the exact 24-level list, state that the six standard levels are initially enabled, and explain that every other level can be enabled manually in Settings. State that a one-time upgrade applies the latest preset to restored Fibonacci Retracements, after which manual changes persist normally.

- [ ] **Step 2: Run the final static and compile gates**

Run the source script and MetaEditor compile command from previous tasks.

Expected:

```text
Fibonacci Retracement source checks passed.
Result: 0 errors, 0 warnings
```

- [ ] **Step 3: Perform the MT5 new-drawing smoke test**

Attach the newly compiled EA and create a Fibonacci Retracement. Verify:

1. Settings lists all 24 ratios in the required order.
2. Only `0`, `0.382`, `0.5`, `0.618`, `1`, and `1.618` render initially.
3. Each hidden level can be enabled and disabled independently.
4. Ratio, color, opacity, width, style, add-level, and remove-level controls still work.
5. Preview and committed drawing show the same default lines.

- [ ] **Step 4: Perform migration and persistence smoke tests**

Use a chart drawing file written by EA v1.1.0, then attach the updated EA. Verify:

1. Every restored Fibonacci Retracement receives the 24-level list once.
2. Matching ratios retain their prior colors, opacity, widths, and styles.
3. Anchors, lock state, and object visibility do not change.
4. After changing visibility and levels, reattach the updated EA again; the changes remain and are not reset.
5. The saved header is `TPDRAW v=2`.

- [ ] **Step 5: Perform selection regression tests**

Verify that a visible new level such as `1.272` selects the drawing when clicked, a manually edited ratio line remains selectable, and a hidden line position does not create an invisible hit target. Confirm other Fibonacci tools still render and select as before.

- [ ] **Step 6: Review the final diff**

```powershell
git diff --check
git status --short
git diff --stat HEAD~4..HEAD
```

Expected: only the seven files listed in this plan are changed or committed; no `.ex5`, `.log`, drawing data, version bump, or unrelated refactor is tracked.

- [ ] **Step 7: Commit the guide after successful verification**

```powershell
git add docs/panduan-penggunaan.md
git commit -m "docs: explain fibonacci retracement level preset"
```

## Plan self-review

- Spec coverage: canonical 24-level preset, six defaults, one-time migration, style retention, persistence, preview parity, live-array hit-testing, edge handling, compilation, and manual smoke tests are each assigned to a task.
- Placeholder scan: no deferred implementation or unspecified error-handling steps remain.
- Type consistency: both the declaration and definition use `HitTestFibRetracement(..., int threshold, const double &lvlRatio[], const bool &lvlVisible[])`; all consumers use `TP_FillFibRetracementPreset(...)`; migration uses `TP_MigrateFibRetracementPreset(DrawnObject &object)`.
