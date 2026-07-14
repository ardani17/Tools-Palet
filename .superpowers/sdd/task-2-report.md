# Task 2 Report: Centralize Fibonacci Retracement Preset

## Scope

Modified only `src/core/ToolsPalette_Tools.mqh`:

- Added `TP_FIBO_RETRACEMENT_PRESET_VERSION` with value `2`.
- Added `TP_FillFibRetracementPreset(...)` with the exact ordered 24-ratio preset, six-visible-level map, prescribed colors, and default style fields.
- Added `TP_MigrateFibRetracementPreset(DrawnObject &object)`, preserving matching prior colors, opacities, widths, and styles while applying the new visibility map.
- Replaced the legacy 11-level new-object Fibonacci Retracement initialization in `AddDrawnObject` with the canonical filler.

No other Fibonacci defaults were changed.

## Verification

1. Red-state source check before implementation:
   `& .\scripts\verify-fibo-retracement.ps1`
   failed as expected with `Preset version 2 is missing.`
2. Source check after implementation:
   `& .\scripts\verify-fibo-retracement.ps1`
   failed as expected at the next task boundary with `Drawing schema was not bumped to 2.`
3. Requested compiler gate:
   `& 'C:\Program Files\MetaTrader 5\metaeditor64.exe' /compile:'C:\Users\ardani\Documents\APLIKASI\Tools-Palet\src\Tools Palet.mq5' /log`
   followed by the requested log tail reported `Result: 0 errors, 0 warnings`.
4. `git diff --check` completed without diff errors.

## Caveat

The prescribed compiler command targets the main workspace source tree rather than this isolated worktree. An additional worktree-path compiler invocation did not create the expected local log file, so the successful compile output is for the required main-workspace command; Task 2's source-contract progression verifies this worktree change.

## Review Fix: Scope the 24-level preset to Fibonacci Retracement

### Finding and root cause

The canonical preset call in `AddDrawnObject` was unconditional. Because `fiboLevel*` arrays are initialized for every new tool object, this changed non-retracement tools from their legacy 11-level arrays to the new 24-level retracement preset, affecting their persisted state.

### Fix

Modified only `src/core/ToolsPalette_Tools.mqh` for production code:

- `TP_FillFibRetracementPreset(...)` is now called only when `toolType == TOOL_FIBO_RETRACEMENT`.
- All other tool types execute the unchanged legacy 11-level `fiboLevel*` initialization, including ratios, colors, style defaults, and visible flags.

### Verification

1. Focused source inspection of `AddDrawnObject` reported exactly one `TP_FillFibRetracementPreset(...)` call, guarded by `toolType == TOOL_FIBO_RETRACEMENT`, and confirmed the non-retracement `FIBO_DEFAULT_N = 11` branch.
2. `& .\scripts\verify-fibo-retracement.ps1` failed at the intended next task boundary: `Drawing schema was not bumped to 2.`
3. A MetaEditor compile invocation targeted the worktree source, but did not create a worktree log file; therefore no compilation result is claimed for this fix.
4. `git diff --check` was run before commit.
