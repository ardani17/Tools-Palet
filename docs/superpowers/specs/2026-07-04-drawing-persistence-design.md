# Drawing Persistence — Design Spec

- **Issue:** [#2 — Bug: Gambar drawing hilang saat pindah timeframe](https://github.com/ardani17/Tools-Palet/issues/2)
- **Branch:** `beta`
- **Date:** 2026-07-04
- **Status:** Approved (design)

## Problem

All user drawings live only in `CDrawingEngine::m_drawnObjects[]` (RAM). There is no
persistence anywhere in the codebase (no `FileOpen`, no `GlobalVariable`). When MT5
changes timeframe it runs `OnDeinit(REASON_CHARTCHANGE)` → `OnInit()`, which wipes the
array and recreates an empty drawings canvas. Result: every drawing disappears on a
timeframe change (and on terminal restart).

Object anchors are already timeframe-agnostic — `(datetime time, double price)` — so
restoring across periods is correct as long as the model is persisted and reloaded.

## Goals / Acceptance Criteria

- Drawings survive timeframe change (M1, M5, M15, H1, H4, D1).
- Drawings survive full MT5 terminal restart (file-based persistence).
- Drawings are isolated per chart (multiple charts do not overwrite each other).
- No regression to create / edit / delete / select / drag.
- Acceptable performance for 50+ objects.

## Non-Goals

- Cross-terminal / cloud sync.
- Migrating drawings to native MT5 chart objects (rendering stays on the bitmap canvas).
- Backwards import of drawings created before this feature.

## Decisions (locked)

| Decision | Choice |
|----------|--------|
| Scope | Full file-based persistence: survives timeframe change **and** terminal restart |
| Storage key | `Symbol + ChartID` (isolates multiple charts of the same symbol) |
| On-disk format | Versioned tagged `key=value` text, one block per object |
| Save trigger | Hybrid: dirty flag → debounced flush in `OnTimer` + final flush in `Destroy()` |
| Module placement | `src/storage/ToolsPalette_Storage.mqh` |

## Architecture

New module `src/storage/ToolsPalette_Storage.mqh` owns all (de)serialization logic.
`CDrawingEngine` (which owns `m_drawnObjects[]`, `m_drawnObjectCount`,
`m_drawnObjectCounter`) gains three thin members:

- `void SaveDrawings()` — serialize the array to the chart's file (atomic write).
- `bool RestoreDrawings()` — load the file, repopulate the array, fix the counter.
- `void MarkDrawingsDirty()` — set the dirty flag + timestamp for the debounced flush.

MQL5 has no partial classes, so the three methods are **declared** in the
`CDrawingEngine` class body and **defined** in the storage include, which is pulled in
after both `DrawnObject` and `CDrawingEngine` are declared (i.e. near the bottom of the
include chain, so the struct and class are fully visible).

Inheritance chain (unchanged): `CDrawingEngine` → `CToolRegistry` → … →
`CChartEventHandler` → `CToolsSidebar`.

## Storage Key & Location

- Path: `<MQL5>/Files/ToolsPalette/drawings/<Symbol>_<ChartID>.dat`
- Opened in the terminal file sandbox (no `FILE_COMMON`).
- `Symbol()` + `ChartID()` form the key. `ChartID()` is stable across a timeframe change
  and is normally preserved across restart for charts saved in the profile, satisfying
  the per-chart isolation criterion.
- The `ToolsPalette/drawings/` subfolders are created on demand before the first write.

## On-Disk Format (versioned tagged text)

```
TPDRAW v=1
counter=42
[OBJ]
toolType=12
id=7
time1=1719950400
price1=1.08123
time2=1719960400
price2=1.08560
objColor=4294901760
lineWidth=2
lineStyle=0
labelText=my note
fibo.n=7
fibo.ratio=0,0.236,0.382,0.5,0.618,0.786,1
fibo.color=4294901760,4294901760,...
fibo.opacity=100,100,...
fibo.width=1,1,...
fibo.style=0,0,...
fibo.visible=1,1,...
path.n=4
path.time=1719950400,1719951000,...
path.price=1.081,1.082,...
[/OBJ]
[OBJ]
...
[/OBJ]
```

Rules:

- **Header line** `TPDRAW v=<schema>` identifies the format version.
- **`counter=`** records `m_drawnObjectCounter` so restored IDs never collide with new ones.
- **Object blocks** are delimited by `[OBJ]` / `[/OBJ]`.
- **Scalars** are one `key=value` per line.
- **Dynamic arrays** are written as `name.n=<count>` followed by one comma-joined value
  line per parallel array (`name.ratio`, `name.color`, `name.opacity`, `name.width`,
  `name.style`, `name.visible`). The N-point path uses `path.n` + `path.time` +
  `path.price`.
- **Reader is tolerant:** unknown keys are skipped and missing keys leave the struct
  default in place. This means adding a new `DrawnObject` property later does not break
  reading of older files.
- `labelText` may contain arbitrary characters; it is written last-in-line as the raw
  value after the first `=` (reader splits on the first `=` only). Newlines in labels are
  escaped (`\n`) on write and unescaped on read.

### Fields to serialize

All of `DrawnObject` (`src/core/ToolsPalette_Tools.mqh` line 526): core identity + anchors
(`toolType`, `id`, `time1..3`, `price1..3`), the N-point `pathTimes[]`/`pathPrices[]`,
selection/visibility/label, per-object line/text/opacity/font/alignment overrides, fill
colors, channel midline + regression band fields, all Fibonacci variants
(fibo/fibex/fibch/fibtz/fibfan/fibarc) level arrays, Gann (gannfan/gannbox) level arrays,
and pitchfork median/outer/inner style fields.

`selected` and `hovered`-style transient UI state are **not** persisted as selected
(objects load deselected).

## Save Flow (hybrid, crash-safe)

1. Every mutation path calls `MarkDrawingsDirty()`:
   - `CDrawingEngine::AddDrawnObject()`
   - `CDrawingEngine::RemoveDrawnObject()`
   - edit / drag **commit** points in `ToolsPalette_Engine_Edit.mqh` /
     `ToolsPalette_Engine_Interact.mqh` (mark dirty on commit, not on every mouse-move frame)
   - property setters in `ToolsPalette_Engine_Properties.mqh`
2. `CToolsSidebar::OnTimer()` (already firing for the label cursor blink) checks the dirty
   flag; if set and ≥ ~1s since the last change, it calls `SaveDrawings()` and clears the
   flag (debounce prevents disk thrash during a drag).
3. `CToolsSidebar::Destroy()` (invoked from `OnDeinit`, including `REASON_CHARTCHANGE`)
   performs a final `SaveDrawings()` if still dirty.
4. **Atomic write:** serialize to `<file>.tmp`, then `FileMove(..., FILE_REWRITE)` over the
   real file so an interrupted write cannot corrupt the store.

## Restore Flow

1. At the end of `CToolsSidebar::Init()` (runs on every `OnInit`, covering both timeframe
   change and restart), call `RestoreDrawings()`.
2. `RestoreDrawings()`:
   - Returns cleanly if the file is missing.
   - Parses the header; if `v` is newer than supported, logs and starts empty.
   - Clears `m_drawnObjects[]`, parses each `[OBJ]` block into a `DrawnObject`, resizing
     the parallel arrays from the `*.n` counts before filling them.
   - Sets `m_drawnObjectCount` to the loaded count and
     `m_drawnObjectCounter = max(loaded id, m_drawnObjectCounter)`.
3. Then `RedrawAllObjects()` paints the restored objects onto the fresh canvas.
4. Any parse failure logs a warning and leaves the array empty (never crashes the EA).

## Edge Cases

- **Clear all:** clearing drawings still writes an (object-less) file so the cleared state
  persists across a reload — an empty valid file, not a missing file.
- **Corrupt / partial file:** tolerated by atomic writes + defensive parsing; on failure
  start empty and log.
- **Version mismatch:** older files read via tolerant parser; newer `v` → start empty + log.
- **50+ objects:** a few KB of text; write/read cost is negligible.
- **Deep-copy arrays:** the existing add path already deep-copies fibo/gann level arrays;
  the serializer reads/writes explicit counts so no aliasing occurs on restore.

## Affected Files

| File | Change |
|------|--------|
| `src/storage/ToolsPalette_Storage.mqh` | **New** — serializer, parser, atomic file I/O |
| `src/core/ToolsPalette_Tools.mqh` | Declare `SaveDrawings/RestoreDrawings/MarkDrawingsDirty` + dirty-flag state on `CDrawingEngine`; call `MarkDrawingsDirty()` in `AddDrawnObject`/`RemoveDrawnObject`; include storage module |
| `src/core/ToolsPalette_Shell.mqh` | `Init()` → `RestoreDrawings()`; `OnTimer()` → debounced flush; `Destroy()` → final flush |
| `src/engine/ToolsPalette_Engine_Edit.mqh` | `MarkDrawingsDirty()` on drag/edit commit |
| `src/engine/ToolsPalette_Engine_Interact.mqh` | `MarkDrawingsDirty()` on move/delete commit |
| `src/engine/ToolsPalette_Engine_Properties.mqh` | `MarkDrawingsDirty()` in property setters |

## Test Plan (manual, MT5)

1. Draw trendline + rectangle + fibonacci; switch M15 → H1 → D1 → back. Drawings persist
   at identical time/price anchors.
2. Draw objects; restart the terminal; confirm drawings reload on the same chart.
3. Open two charts of the same symbol; verify drawings do not cross over.
4. Create / edit / delete / drag / select all still work; deletes persist after reload.
5. Draw 50+ objects; confirm no visible lag on timeframe change and correct reload.
6. Kill the terminal mid-drag; confirm the store file is still valid (atomic write).
