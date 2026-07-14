# Fibonacci Retracement Level Preset Design

## Goal

Expand the Fibonacci Retracement tool to provide the complete requested level set while keeping its initial chart output simple. Every level remains individually available in Settings, but only six standard levels are visible by default.

This change applies only to Fibonacci Retracement. Fibonacci Expansion, Channel, Time Zones, Fan, Arcs, and the existing color and line-style controls remain unchanged.

## User experience

Every Fibonacci Retracement uses this ordered 24-level preset:

`0`, `0.236`, `0.382`, `0.5`, `0.618`, `0.786`, `1`, `1.272`, `1.414`, `1.618`, `2`, `2.272`, `2.414`, `2.618`, `3`, `3.272`, `3.414`, `3.618`, `4`, `4.236`, `4.272`, `4.414`, `4.618`, `4.764`.

The initial visibility is:

- Visible: `0`, `0.382`, `0.5`, `0.618`, `1`, `1.618`.
- Hidden: all other levels in the preset.

Settings continues to show one row per level. The user can enable or disable every level independently and can keep using the existing ratio, color, opacity, width, style, add-level, and remove-level controls.

The drawing preview and a completed drawing must show the same default levels. Labels retain the current ratio format and placement.

## Chosen migration behavior

Installing and reattaching the updated EA replaces the old Fibonacci Retracement level preset on both restored and newly created drawings. The replacement happens once when a drawing store from the previous preset version is loaded.

The migration replaces the level list and applies the new default visibility states. Because this feature concerns level points rather than visual styling, an existing level that has the same ratio keeps its stored color, opacity, width, and line style. A newly introduced ratio receives the application's normal per-level defaults. Ratios removed by the new preset are discarded.

After migration, the store is saved in the new version. Subsequent EA restarts or reattachments load the user's current level edits normally and do not reset them again. This ensures that manual enable/disable choices and later level customization remain persistent.

## Alternatives considered

### One-time versioned migration — selected

Mark persisted drawing data with a new supported version, migrate older Fibonacci Retracement objects once, and save the result. This updates every restored drawing as requested without erasing future manual edits on every startup.

### Reset on every EA attachment — rejected

Rebuilding the preset every time would be simpler, but it would also erase manual visibility and level changes whenever the EA restarts. That conflicts with the existing persistence behavior.

### Apply the preset only to new drawings — rejected

This would preserve all restored objects unchanged, but it would leave older Fibonacci Retracements with the incomplete level set after the EA is reattached.

## Components and data flow

### Canonical preset initialization

Keep one canonical definition for the 24 ratios and their six default visibility states. The Fibonacci Retracement object initialization path uses this definition when creating a new drawing. The migration path uses the same definition when upgrading restored drawings, preventing the two paths from drifting apart.

All six parallel arrays remain aligned by index:

- `fiboLevelRatio[]`
- `fiboLevelColor[]`
- `fiboLevelOpacity[]`
- `fiboLevelWidth[]`
- `fiboLevelStyle[]`
- `fiboLevelVisible[]`

The preview uses the same ratios and visibility states. It may build temporary arrays for rendering, but those values must match the canonical preset exactly.

### Persistence and migration

The drawing store version identifies whether the one-time preset migration is required. Loading an older supported store still materializes all drawings first. For each `TOOL_FIBO_RETRACEMENT` object, the migration then rebuilds the parallel arrays using the new preset, preserves styles for matching ratios, assigns existing application defaults to new ratios, and applies the new visibility map.

If at least one object is migrated, the drawing store is marked dirty and written through the existing persistence flow. Non-Fibonacci objects and other Fibonacci tool types are not modified.

A drawing store already written with the new version bypasses migration completely. A store newer than the EA supports keeps the existing safe failure behavior.

### Rendering and hit-testing

Rendering continues to consume the live per-object arrays and skips levels whose visibility is false.

Fibonacci Retracement hit-testing must stop using the hard-coded legacy 11-level list. Its interface receives the selected object's live ratio and visibility arrays, then tests only rendered, visible level lines within the current P1–P2 horizontal span. This keeps selection behavior correct for the 24-level preset and for later manual additions, removals, ratio edits, and visibility changes.

## Error and edge behavior

- The canonical preset always creates all six parallel arrays at the same length.
- During migration, matching ratios use a small floating-point tolerance rather than exact binary equality.
- If a restored style array is missing or shorter than its ratio array, the affected level uses the normal application default instead of reading an invalid index.
- A hidden level is not rendered and is not independently hit-tested.
- A manually added or edited level remains renderable and selectable after the one-time migration has completed.
- Migration never changes drawing anchors, lock state, selection state, general visibility, or other tool properties.

## Verification

Compile the EA in MetaEditor with zero errors and zero warnings, then perform these chart smoke tests:

1. Create a new Fibonacci Retracement and verify all 24 rows appear in the specified order in Settings.
2. Verify only `0`, `0.382`, `0.5`, `0.618`, `1`, and `1.618` are initially visible.
3. Enable each initially hidden level and verify its line and label appear; disable it and verify both disappear.
4. Change a level's ratio and style, add a level, remove a level, and verify drawing and Settings remain synchronized.
5. Verify the placement preview and the completed drawing use the same default visibility map.
6. Load a drawing store from the previous EA version and verify every restored Fibonacci Retracement receives the 24-level preset once.
7. On a migrated drawing, verify styles for ratios that existed previously are retained and new ratios receive valid defaults.
8. Customize the migrated levels, restart or reattach the updated EA, and verify the customization is preserved instead of being reset.
9. Click near visible newly added and manually edited ratio lines and verify the drawing can be selected; click where a hidden line would be and verify that hidden line is not used for hit-testing.
10. Verify other Fibonacci tools and non-Fibonacci drawings are unchanged.

## Scope

This feature adds Fibonacci Retracement level points, their default visibility, one-time migration, preview parity, and live-array hit-testing. It does not add TradingView's Extend option, change the Settings layout, introduce new color or style controls, alter line-label formatting, or change the defaults of other Fibonacci tools.
