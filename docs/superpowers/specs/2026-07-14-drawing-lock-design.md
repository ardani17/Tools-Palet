# Drawing Lock Design

## Goal

Add a persistent per-object lock to every drawing type. A locked drawing remains selectable and configurable, but its position and geometry cannot be changed through pointer dragging.

## User experience

- Every newly created drawing starts unlocked.
- The selection ribbon shows a lock action immediately before the existing Settings and Remove actions.
- The action displays an open lock for an unlocked drawing and a closed lock for a locked drawing.
- Clicking the action toggles the selected drawing's lock state immediately.
- A locked drawing can still be selected, hovered, styled, edited as text, removed, and unlocked.
- Selection handles remain visible on a locked drawing as a selection indicator, but dragging either a handle or the drawing body has no effect.
- Locking does not change the drawing's time/price anchors, rendering, placement flow, or behavior across timeframe changes.

## Object model and persistence

Add a `bool locked` field to `DrawnObject`. Initialize it to `false` when creating a new object.

Persist the field in each drawing block as `locked=1` or `locked=0`. When loading an older drawing file that has no `locked` key, default the value to `false`. This keeps the storage format backward compatible without migrating existing files.

Lock changes mark the drawing store dirty and use the existing debounced persistence flow. Consequently, the state survives timeframe changes, terminal restarts, and normal drawing restoration.

Any code path that rebuilds or copies a `DrawnObject`, including defaults, tool-memory handling, and property snapshot/restore, must preserve the live object's lock state unless that path is explicitly creating a new drawing. Tool style memory must not transfer a lock state to subsequently created drawings.

## Ribbon integration

Register a universal `lock` action alongside the existing universal ribbon actions. Its ordering is:

1. Lock/unlock
2. Settings
3. Remove

The ribbon action reads the current object's `locked` value on redraw, renders the corresponding open-lock or closed-lock icon, and toggles the value when clicked. Toggling closes any transient popover if necessary, redraws the ribbon and drawings, and schedules persistence.

The lock control is an action, not a style property. It is not copied through per-tool style memory and does not need a Settings-window row.

## Interaction rules

Keep hit-testing enabled for locked drawings so the user can select them and reach the ribbon.

Before arming a whole-object drag, handle drag, or double-click drag, resolve the target object and stop if it is locked. A body click on a locked object still selects it. A handle click on a selected locked object is consumed without starting a drag.

Add a defensive lock check inside the drag-move handler. If an object becomes locked while a drag state is active, cancel the drag state without changing any anchor. This prevents stale interaction state from bypassing the lock.

The lock does not block:

- selection and hover;
- ribbon or Settings style changes;
- text editing;
- visibility changes;
- deletion;
- unlocking.

## Compatibility and error behavior

- Missing persisted lock data means unlocked.
- A lock action with no valid selected object is a no-op.
- If a selected object disappears before the action or drag handler resolves it, the existing invalid-selection cleanup behavior applies.
- Loading, rendering, or selecting a locked drawing must not modify its stored anchors.

## Verification

Compile the EA in MetaEditor with zero errors and zero warnings, then perform manual chart smoke tests:

1. Create and lock an axis-aligned rectangle; verify body and all handles are immovable.
2. Repeat representative tests for a two-point line, a three-point drawing, an N-point path, and a text/annotation drawing.
3. Verify locked drawings remain selectable and allow style, text, visibility, Remove, and Unlock actions.
4. Verify unlocked drawings retain the current drag and reshape behavior.
5. Change from H1 to M5 and back; verify anchors and lock state remain unchanged.
6. Restart or reattach the EA; verify the lock state is restored.
7. Load a drawing file created before this feature; verify every restored drawing defaults to unlocked.
8. Lock one drawing, create another drawing of the same tool type, and verify the new drawing is unlocked.

## Scope

This change applies to every drawing type through the shared object model and interaction engine. It does not add multi-selection, keyboard lock shortcuts, a Settings-window lock row, hidden handles, coordinate editing changes, or changes to the existing time/price persistence model.
