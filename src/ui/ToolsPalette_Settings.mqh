//+------------------------------------------------------------------+
//|                                        ToolsPalette_Settings.mqh |
//|                                            Copyright 2026, Om J. |
//|                                               https://t.me/HZFXI |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Om J."
#property link "https://t.me/HZFXI"
#property version "1.00"
#property strict

//--- Guard against multiple inclusion of this header
#ifndef TOOLS_PALETTE_SETTINGS_MQH
#define TOOLS_PALETTE_SETTINGS_MQH

#include "ToolsPalette_Ribbon.mqh"

//+------------------------------------------------------------------+
//| CSettingsWindow - Settings dialog inheriting from CRibbon        |
//+------------------------------------------------------------------+
class CSettingsWindow : public CRibbon
  {
protected:
   //--- Settings chart-object name + display canvas
   string          m_nameSettings;
   CCanvas         m_canvasSettings;
   //--- Visibility flag + current top-left position + content dimensions
   bool            m_isSettingsVisible;
   int             m_settingsX;
   int             m_settingsY;
   int             m_settingsWidth;
   int             m_settingsHeight;
   //--- Shadow halo padding + body corner radius (matches popover styling)
   int             m_settingsShadowPad;
   int             m_settingsCornerRadius;

   //--- Saved position cache (so reopening restores the user's last placement)
   int             m_savedSettingsX;
   int             m_savedSettingsY;

   //--- The drawn-object ID this Settings window is bound to (the tool being edited)
   int             m_settingsOwnerObjectId;

   //--- Tab strip state (parallel arrays: group id + display label)
   string          m_tabGroups[];
   string          m_tabLabels[];
   int             m_activeTabIdx;
   int             m_hoveredTabIdx;

   //--- Full descriptor list for the bound tool + per-tab row index mapping
   SToolProperty   m_settingsProperties[];
   int             m_activeTabRowIdxs[];
   int             m_hoveredRowIdx;
   //--- Synthesized descriptors for level-list rows (one per Fibo level, etc.)
   SToolProperty   m_synthRowDescriptors[];

   //--- Header + footer button hover states
   bool            m_hoveredCloseBtn;
   int             m_hoveredFooterBtn;
   //--- Text tab control hover (1=color, 2=fontSize, 3=bold, 5=text input, 6=vAlign, 7=hAlign)
   int             m_hoveredTextTabCtrl;

   //--- Text-area edit state (multi-line text input on the Text tab)
   bool            m_textAreaFocused;
   int             m_textAreaScrollPx;
   bool            m_textAreaCaretBlinkOn;
   uint            m_textAreaCaretBlinkLastMs;
   bool            m_textAreaThumbDragging;
   int             m_textAreaThumbGrabOffsetY;
   bool            m_hoveredTextAreaScrollbar;
   bool            m_textAreaAutoScrollPending;
   //--- Cached text-area content rectangle + layout metrics (updated each redraw)
   int             m_taContentL, m_taContentT, m_taContentR, m_taContentB;
   int             m_taTotalContentH;
   int             m_taLineH;
   int             m_taMaxScrollPx;

   //--- Body scrollbar state (the main content scrollbar on the Style/etc tabs)
   int             m_bodyContentH;
   int             m_bodyViewportH;
   int             m_bodyScrollPx;
   int             m_bodyMaxScrollPx;
   bool            m_bodyThumbDragging;
   int             m_bodyThumbGrabOffsetY;
   bool            m_hoveredBodyScrollbar;
   bool            m_textAreaAutoScrollPending_body;   // alias unused — kept for layout parity

   //--- Coordinate-edit state (Coordinates tab inline price/time edit)
   int             m_coordEditPointIdx;
   int             m_coordEditField;
   string          m_coordEditBuffer;
   int             m_coordEditCaretPos;
   int             m_coordSelectionAnchor;
   bool            m_coordEditCaretBlinkOn;
   uint            m_coordEditCaretBlinkLastMs;
   //--- Hover state for the coords tab (row + field + stepper direction)
   int             m_coordHoveredRow;
   int             m_coordHoveredField;
   int             m_coordHoveredStepper;

   //--- Float-edit state (numeric chip edit on Style/Visibility tabs)
   string          m_floatEditPropId;
   string          m_floatEditBuffer;
   int             m_floatEditCaretPos;
   int             m_floatSelectionAnchor;
   bool            m_floatEditCaretBlinkOn;
   uint            m_floatEditCaretBlinkLastMs;
   int             m_floatEditDecimals;
   double          m_floatEditMinValue;
   double          m_floatEditMaxValue;

   //--- Compact row hover state (sub-widgets inside a compact row: checkbox/value/color/width/style)
   int             m_compactHoveredRow;
   int             m_compactHoveredStepper;
   int             m_compactHoveredSubRow;
   int             m_compactHoveredSubButton;

   //--- Drag state (window-move via header)
   bool            m_isDraggingSettings;
   int             m_dragGrabOffsetX;
   int             m_dragGrabOffsetY;

   //--- Layout constants (heights/widths/paddings)
   int             m_settingsHeaderH;
   int             m_settingsTabBarH;
   int             m_settingsTabContainerH;
   int             m_settingsRowH;
   int             m_settingsFooterH;
   int             m_settingsPadX;
   int             m_settingsRowGap;
   int             m_settingsChipW;
   int             m_settingsChipH;

protected:
   //--- Window initialization helpers
   bool            InitSettingsWindow();
   void            InitSettingsDefaults();

public:
   //--- Show/hide/redraw the window
   void            ShowSettingsForObject(int objectId);
   void            HideSettings();
   bool            IsSettingsVisible() const { return m_isSettingsVisible; }
   //--- True when ANY drag is in progress (window, body thumb, or text-area thumb)
   bool            IsDraggingSettings() const
                     { return m_isDraggingSettings
                           || m_textAreaThumbDragging
                           || m_bodyThumbDragging; }
   void            RedrawSettings();
   //--- Override CRibbon's hook so clicking the Settings ribbon icon opens this window
   virtual void    OpenSettingsWindowForObject(int objId) override
                     { ShowSettingsForObject(objId); }

   //--- Override CRibbon hook so the Settings window repaints when a popover closes
   virtual void    OnPopoverClosed() override
     {
      if(m_isSettingsVisible) RedrawSettings();
     }

   //--- Mouse routing (called by Shell.mqh dispatcher; impls live in Settings_Interact.mqh)
   bool            SettingsMouseDown(int mouseX, int mouseY);
   bool            SettingsMouseMove(int mouseX, int mouseY, uint mouseButtons);
   bool            SettingsMouseUp();
   //--- Hit-test against the window's body rect (emits local coords via out-params)
   bool            HitTestOverSettings(int mouseX, int mouseY, int &outLx, int &outLy);

protected:
   //--- Rebuild the tab list + per-tab row mapping for the bound object
   void            RefreshTabsForObject();
   void            RefreshActiveTabRows();

   //--- Quick lookup: true if a property id is registered for the bound tool
   bool            HasRegisteredProperty(const string propId)
     {
      const int n = ArraySize(m_settingsProperties);
      for(int i = 0; i < n; i++)
         if(m_settingsProperties[i].id == propId) return true;
      return false;
     }

   //--- Resolve a row slot to its descriptor (real or synthesized via the levellist expansion)
   SToolProperty   ResolveActiveRowDescriptor(int rowSlot);
   //--- Recompute window size based on active tab content
   void            RecalcSettingsSize();
   //--- Push current XY to the chart object (offset by shadow padding)
   void            ApplySettingsPosition();

   //--- Layout rect helpers (return component bounds in window-local coords)
   void            GetTabContainerRect(int &outL, int &outT, int &outR, int &outB);
   void            GetTabRect(int tabIdx, int &outL, int &outT, int &outR, int &outB);
   void            GetRowRect(int rowSlot, int &outL, int &outT, int &outR, int &outB);
   void            GetRowChipRect(int rowSlot, int &outL, int &outT, int &outR, int &outB);

   //--- Compact-row sub-widget rect helpers (used by both render + hit-test)
   bool            GetCompactValueButtonRect(int rowSlot,
                                               int &outL, int &outT,
                                               int &outR, int &outB);
   bool            GetCompactStepperRect(int rowSlot, int dir,
                                          int &outL, int &outT,
                                          int &outR, int &outB);

   //--- Body scrollbar rendering + thumb hit-rect calculation
   void            DrawBodyScrollbar();
   bool            GetBodyThumbRect(int &outL, int &outT, int &outR, int &outB,
                                      bool settingsRelativeOnly);
   //--- Header close-X + footer buttons (Cancel/Ok/Apply Defaults) rect helpers
   void            GetCloseButtonRect(int &outL, int &outT, int &outR, int &outB);
   void            GetFooterButtonRect(int btnIdx, int &outL, int &outT, int &outR, int &outB);

   //--- Hit-tests for each interactive region
   int             HitTestTab(int lx, int ly);
   int             HitTestRow(int lx, int ly);
   int             HitTestFooterButton(int lx, int ly);
   bool            HitTestCloseButton(int lx, int ly);
   bool            HitTestHeaderDragArea(int lx, int ly);

   //--- Major draw routines (split out for readability)
   void            DrawSettingsHeader();
   void            DrawSettingsTabStrip();
   void            DrawSettingsRows();
   void            DrawTextTabRows();
   //--- Text-tab control hit-test + per-control rect helpers
   int             HitTestTextTabControl(int lx, int ly);
   void            GetTextTabColorRect(int &outL, int &outT, int &outR, int &outB);
   void            GetTextTabFontSizeRect(int &outL, int &outT, int &outR, int &outB);
   void            GetTextTabBoldRect(int &outL, int &outT, int &outR, int &outB);
   void            GetTextTabTextInputRect(int &outL, int &outT, int &outR, int &outB);
   void            GetTextTabVAlignRect(int &outL, int &outT, int &outR, int &outB);
   void            GetTextTabHAlignRect(int &outL, int &outT, int &outR, int &outB);
   void            DrawSettingsFooter();
   //--- Per-row chip renderer (dispatch by descriptor type)
   void            RenderRowChip(int rowSlot, const SToolProperty &prop);

   //--- Text-area lifecycle (focus loss + buffer-change notifier)
   void            UnfocusTextArea();
   //--- Coordinates tab rendering + hit-tests + edit-mode helpers
   void            DrawCoordsTabRows();
   void            GetCoordRowRect(int rowIdx, int &outL, int &outT, int &outR, int &outB);
   void            GetCoordPriceButtonRect(int rowIdx, int &outL, int &outT, int &outR, int &outB);
   void            GetCoordTimeButtonRect(int rowIdx, int &outL, int &outT, int &outR, int &outB);
   void            GetCoordStepperRect(int rowIdx, int field, int dir,
                                         int &outL, int &outT, int &outR, int &outB);
   bool            HitTestCoordsTab(int lx, int ly,
                                      int &outRow, int &outField, int &outStepper);
   //--- Coordinate-edit lifecycle (start/commit/cancel/step) + value formatting helpers
   void            StartCoordEdit(int pointIdx, int field);
   void            CommitCoordEdit();
   void            CancelCoordEdit();
   void            ApplyCoordStep(int pointIdx, int field, int dir);
   void            PositionCoordCaretFromClickX(int lx);
   string          FormatPriceForDisplay(double price);
   string          FormatBarForDisplay(datetime time);

public:
   //--- Keyboard handlers for the two inline edit modes (impls in Settings_Interact.mqh)
   bool            HandleCoordKey(uint vk);
   bool            IsEditingCoord() const { return m_coordEditPointIdx >= 0; }
   void            BeginFloatEdit(string propId, int decimals,
                                    double minValue, double maxValue);
   void            CommitFloatEdit();
   void            CancelFloatEdit();
   bool            IsEditingFloat() const { return StringLen(m_floatEditPropId) > 0; }
   bool            HandleFloatKey(uint vk);
   void            PositionFloatCaretFromClickX(int lx, int textStartX);
   //--- Open a sub-popover anchored to a sub-widget inside the Settings body
   void            OpenSettingsSubPopover(string propId, int anchorX, int anchorY,
                                            int flipBaseTop = -1);
   //--- Text-area integration with the engine's label-edit state
   void            NotifyTextAreaBufferChanged();
   bool            IsTextAreaFocused() const { return m_textAreaFocused; }
   bool            HitTestOverTextArea(int mouseX, int mouseY);
   bool            HitTestOverSettingsBody(int mouseX, int mouseY);
   int             SettingsBodyMaxScroll() const { return m_bodyMaxScrollPx; }
   //--- Wheel scroll handlers (chart wheel events route here when over the body / text area)
   void            ScrollSettingsBodyByWheel(int wheelDelta);
   void            ScrollTextAreaByWheel(int wheelDelta);
   //--- Caret-blink tick (called from the Shell's OnTimer)
   void            SettingsTick();
   bool            GetTextAreaThumbRect(int &outL, int &outT, int &outR, int &outB,
                                          bool settingsRelativeOnly);

protected:
   //--- Footer Ok/Cancel action handlers
   void            CommitSettingsChanges();
   void            DiscardSettingsChanges();
  };

//+------------------------------------------------------------------+
//| Seed every member variable to its initial state                  |
//+------------------------------------------------------------------+
void CSettingsWindow::InitSettingsDefaults()
  {
   //--- Chart-object name + visibility + initial XY (recomputed at show time)
   m_nameSettings           = "ToolsPalette_Settings";
   m_isSettingsVisible      = false;
   m_settingsX              = 0;
   m_settingsY              = 0;
   //--- Initial size estimate (real size computed by RecalcSettingsSize)
   m_settingsWidth          = 360;
   m_settingsHeight         = 240;
   m_settingsShadowPad      = 8;
   m_settingsCornerRadius   = 8;
   //--- Saved-position cache uses -1 as the "no saved position" sentinel
   m_savedSettingsX         = -1;
   m_savedSettingsY         = -1;
   m_settingsOwnerObjectId  = 0;
   //--- Tab strip starts empty - populated by RefreshTabsForObject
   m_activeTabIdx           = 0;
   m_hoveredTabIdx          = -1;
   m_hoveredRowIdx          = -1;
   //--- All hover flags start cleared
   m_hoveredCloseBtn        = false;
   m_hoveredFooterBtn       = 0;
   m_hoveredTextTabCtrl     = 0;
   //--- Text-area edit state cleared
   m_textAreaFocused        = false;
   m_textAreaScrollPx       = 0;
   m_textAreaCaretBlinkOn   = true;
   m_textAreaCaretBlinkLastMs = 0;
   m_textAreaThumbDragging  = false;
   m_textAreaThumbGrabOffsetY = 0;
   m_hoveredTextAreaScrollbar = false;
   m_textAreaAutoScrollPending = false;
   //--- Body scrollbar state cleared
   m_bodyContentH          = 0;
   m_bodyViewportH         = 0;
   m_bodyScrollPx          = 0;
   m_bodyMaxScrollPx       = 0;
   m_bodyThumbDragging     = false;
   m_bodyThumbGrabOffsetY  = 0;
   m_hoveredBodyScrollbar  = false;
   //--- Text-area cached content rect + metrics
   m_taContentL = 0; m_taContentT = 0;
   m_taContentR = 0; m_taContentB = 0;
   m_taTotalContentH = 0;
   m_taLineH         = 12;
   m_taMaxScrollPx   = 0;
   //--- Coordinate-edit state (sentinel -1 = no edit in progress)
   m_coordEditPointIdx        = -1;
   m_coordEditField           = 0;
   m_coordEditBuffer          = "";
   m_coordEditCaretPos        = 0;
   m_coordSelectionAnchor     = -1;
   m_coordEditCaretBlinkOn    = true;
   m_coordEditCaretBlinkLastMs = 0;
   m_coordHoveredRow          = -1;
   m_coordHoveredField        = 0;
   m_coordHoveredStepper      = 0;
   //--- Float-edit state (empty propId = no edit in progress)
   m_floatEditPropId           = "";
   m_floatEditBuffer           = "";
   m_floatEditCaretPos         = 0;
   m_floatSelectionAnchor      = -1;
   m_floatEditCaretBlinkOn     = true;
   m_floatEditCaretBlinkLastMs = 0;
   m_floatEditDecimals         = 2;
   m_floatEditMinValue         = 0.0;
   m_floatEditMaxValue         = 1.0;
   //--- Compact row hover sub-state cleared
   m_compactHoveredRow         = -1;
   m_compactHoveredStepper     = 0;
   m_compactHoveredSubRow      = -1;
   m_compactHoveredSubButton   = 0;
   //--- Drag state cleared
   m_isDraggingSettings     = false;
   m_dragGrabOffsetX        = 0;
   m_dragGrabOffsetY        = 0;
   //--- Layout heights chosen for visual rhythm (header 44, tab bar 40, row 32, footer 56)
   m_settingsHeaderH        = 44;
   m_settingsTabBarH        = 40;
   m_settingsTabContainerH  = 30;
   m_settingsRowH           = 32;
   m_settingsFooterH        = 56;
   m_settingsPadX           = 16;
   m_settingsRowGap         = 4;
   m_settingsChipW          = 140;
   m_settingsChipH          = 24;
   //--- Reset all dynamic arrays
   ArrayResize(m_tabGroups, 0);
   ArrayResize(m_tabLabels, 0);
   ArrayResize(m_settingsProperties, 0);
   ArrayResize(m_activeTabRowIdxs, 0);
  }

//+------------------------------------------------------------------+
//| Create the chart-object canvas + configure its display flags     |
//+------------------------------------------------------------------+
bool CSettingsWindow::InitSettingsWindow()
  {
   //--- Seed member variables first
   InitSettingsDefaults();
   //--- Initial canvas size = 500x500 + shadow halo (large enough for any tool)
   const int initW = 500 + 2 * m_settingsShadowPad;
   const int initH = 500 + 2 * m_settingsShadowPad;
   if(!m_canvasSettings.CreateBitmapLabel(0, 0, m_nameSettings, 0, 0,
                                            initW, initH,
                                            COLOR_FORMAT_ARGB_NORMALIZE))
     {
      Print("Failed to create settings window canvas");
      return false;
     }
   //--- Anchor to upper-left + Z-order higher than ribbon (350) and popover so Settings always wins
   ObjectSetInteger(0, m_nameSettings, OBJPROP_CORNER,    CORNER_LEFT_UPPER);
   ObjectSetInteger(0, m_nameSettings, OBJPROP_ZORDER,    400);
   ObjectSetInteger(0, m_nameSettings, OBJPROP_HIDDEN,    true);
   ObjectSetInteger(0, m_nameSettings, OBJPROP_BACK,      false);
   ObjectSetInteger(0, m_nameSettings, OBJPROP_SELECTABLE,false);
   //--- Detached from all chart periods until shown
   ObjectSetInteger(0, m_nameSettings, OBJPROP_TIMEFRAMES, OBJ_NO_PERIODS);
   //--- Clear to transparent + flush
   m_canvasSettings.Erase(0x00000000);
   m_canvasSettings.Update();
   return true;
  }

//+------------------------------------------------------------------+
//| Bind the window to an object, build its layout, and show it      |
//+------------------------------------------------------------------+
void CSettingsWindow::ShowSettingsForObject(int objectId)
  {
   //--- Bail on invalid object id
   if(objectId <= 0) return;
   m_settingsOwnerObjectId = objectId;

   //--- Resolve the drawn-object index + tool type
   const int idx = FindObjectIndexById(objectId);
   if(idx < 0) return;
   const TOOL_TYPE tool = m_drawnObjects[idx].toolType;
   //--- Rebuild the full property descriptor list for this tool
   ArrayResize(m_settingsProperties, 0);
   BuildPropertyListForTool(tool, m_settingsProperties);

   //--- Take a property snapshot (Cancel later will RestoreProperties from this)
   SnapshotProperties(objectId);

   //--- Build tab list + row mapping + recompute window size
   RefreshTabsForObject();
   m_activeTabIdx = 0;
   RefreshActiveTabRows();
   RecalcSettingsSize();

   //--- Position: restore saved if any (clamped to chart), otherwise center
   const int chartW = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
   const int chartH = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
   if(m_savedSettingsX >= 0 && m_savedSettingsY >= 0)
     {
      //--- Restore previous position + clamp to chart bounds
      m_settingsX = m_savedSettingsX;
      m_settingsY = m_savedSettingsY;
      if(m_settingsX + m_settingsWidth  > chartW) m_settingsX = chartW - m_settingsWidth;
      if(m_settingsY + m_settingsHeight > chartH) m_settingsY = chartH - m_settingsHeight;
      if(m_settingsX < 0) m_settingsX = 0;
      if(m_settingsY < 0) m_settingsY = 0;
     }
   else
     {
      //--- First open: center the window in the chart
      m_settingsX = (chartW - m_settingsWidth)  / 2;
      m_settingsY = (chartH - m_settingsHeight) / 2;
     }
   ApplySettingsPosition();

   //--- Hide the ribbon while Settings is open (HideSettings restores it on close)
   HideRibbon();

   //--- Flip visibility + attach the chart object + render
   m_isSettingsVisible = true;
   ObjectSetInteger(0, m_nameSettings, OBJPROP_TIMEFRAMES, OBJ_ALL_PERIODS);
   RedrawSettings();
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| Hide the Settings window + restore the ribbon                    |
//+------------------------------------------------------------------+
void CSettingsWindow::HideSettings()
  {
   //--- Close any open popover first (popovers can't outlive their host)
   if(m_isPopoverVisible) HidePopover();

   //--- Cancel any open label edit (text area was wired into the engine's label-edit state)
   if(m_isEditingLabel) CancelLabel();
   //--- Clear text-area state
   m_textAreaFocused           = false;
   m_textAreaCaretBlinkOn      = false;
   m_textAreaScrollPx          = 0;
   m_textAreaThumbDragging     = false;
   m_textAreaAutoScrollPending = false;
   //--- Clear body scrollbar state
   m_bodyScrollPx              = 0;
   m_bodyThumbDragging         = false;
   m_hoveredBodyScrollbar      = false;
   //--- Clear coordinate-edit state
   m_coordEditPointIdx     = -1;
   m_coordEditField        = 0;
   m_coordEditBuffer       = "";
   m_coordEditCaretPos     = 0;
   m_coordSelectionAnchor  = -1;
   m_coordEditCaretBlinkOn = false;
   m_coordHoveredRow       = -1;
   m_coordHoveredField     = 0;
   m_coordHoveredStepper   = 0;

   //--- Drop the externally-owned snapshot flag (we own snapshots while the window is open)
   m_popoverSnapshotIsExternal = false;

   //--- Cache the current position so the next open restores it
   m_savedSettingsX = m_settingsX;
   m_savedSettingsY = m_settingsY;

   //--- Flip visibility + detach the chart object from all periods + clear the canvas
   m_isSettingsVisible = false;
   ObjectSetInteger(0, m_nameSettings, OBJPROP_TIMEFRAMES, OBJ_NO_PERIODS);
   m_canvasSettings.Erase(0x00000000);
   m_canvasSettings.Update();
   //--- Clear hover + drag state
   m_hoveredTabIdx       = -1;
   m_hoveredRowIdx       = -1;
   m_hoveredCloseBtn     = false;
   m_hoveredFooterBtn    = 0;
   m_isDraggingSettings  = false;

   //--- Bring the ribbon back for the same object (continuity)
   if(m_settingsOwnerObjectId > 0)
      ShowRibbonFor(m_settingsOwnerObjectId);
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| Ok handler - commit any pending edits + discard snapshot + close |
//+------------------------------------------------------------------+
void CSettingsWindow::CommitSettingsChanges()
  {
   //--- Force-commit any inline edits before closing
   if(m_textAreaFocused) UnfocusTextArea();
   if(m_coordEditPointIdx >= 0) CommitCoordEdit();
   //--- Drop the snapshot (commits the live preview values to the engine)
   DiscardSnapshot();
   HideSettings();
  }

//+------------------------------------------------------------------+
//| Cancel handler - restore from snapshot + close                   |
//+------------------------------------------------------------------+
void CSettingsWindow::DiscardSettingsChanges()
  {
   //--- Cancel any in-progress text edit
   if(m_textAreaFocused)
     {
      if(m_isEditingLabel) CancelLabel();
      m_textAreaFocused      = false;
      m_textAreaCaretBlinkOn = false;
     }
   //--- Cancel any in-progress coordinate edit
   if(m_coordEditPointIdx >= 0) CancelCoordEdit();
   //--- Restore the snapshot values to undo all live preview edits
   RestoreProperties();
   //--- Redraw all drawn objects so the chart shows the restored values
   RedrawAllObjects();
   HideSettings();
  }

//+------------------------------------------------------------------+
//| Rebuild the tab list (one tab per distinct group) for the object |
//+------------------------------------------------------------------+
void CSettingsWindow::RefreshTabsForObject()
  {
   //--- Reset tab arrays
   ArrayResize(m_tabGroups, 0);
   ArrayResize(m_tabLabels, 0);
   const int n = ArraySize(m_settingsProperties);
   //--- Walk every settings-eligible non-action property and collect distinct group ids
   for(int i = 0; i < n; i++)
     {
      if(m_settingsProperties[i].type == PROP_ACTION) continue;
      if(!m_settingsProperties[i].showInSettings) continue;
      const string g = m_settingsProperties[i].group;
      //--- Skip if this group is already in the tab list
      bool found = false;
      const int t = ArraySize(m_tabGroups);
      for(int k = 0; k < t; k++)
         if(m_tabGroups[k] == g) { found = true; break; }
      if(found) continue;
      //--- Append the group + map it to a display label
      const int sz = t + 1;
      ArrayResize(m_tabGroups, sz);
      ArrayResize(m_tabLabels, sz);
      m_tabGroups[sz - 1] = g;
      string lbl = g;
      if(g == PROP_GROUP_STYLE)           lbl = "Style";
      else if(g == PROP_GROUP_TEXT)       lbl = "Text";
      else if(g == PROP_GROUP_COORDS)     lbl = "Coordinates";
      else if(g == PROP_GROUP_VISIBILITY) lbl = "Visibility";
      m_tabLabels[sz - 1] = lbl;
     }

   //--- Auto-inject the Coordinates tab when the object has points (even if no coord-group properties are registered)
   const int pointCount = GetObjectPointCount(m_settingsOwnerObjectId);
   if(pointCount > 0)
     {
      bool hasCoordTab = false;
      const int tCount = ArraySize(m_tabGroups);
      for(int k = 0; k < tCount; k++)
         if(m_tabGroups[k] == PROP_GROUP_COORDS) { hasCoordTab = true; break; }
      if(!hasCoordTab)
        {
         //--- Coords tab missing - append it now
         const int sz = tCount + 1;
         ArrayResize(m_tabGroups, sz);
         ArrayResize(m_tabLabels, sz);
         m_tabGroups[sz - 1] = PROP_GROUP_COORDS;
         m_tabLabels[sz - 1] = "Coordinates";
        }
     }
  }

//+------------------------------------------------------------------+
//| Build the row-index list for the currently active tab            |
//+------------------------------------------------------------------+
void CSettingsWindow::RefreshActiveTabRows()
  {
   //--- Reset row mappings + clear hover state for stale rows
   ArrayResize(m_activeTabRowIdxs, 0);
   ArrayResize(m_synthRowDescriptors, 0);
   m_hoveredRowIdx          = -1;
   m_compactHoveredRow      = -1;
   m_compactHoveredStepper  = 0;
   m_compactHoveredSubRow      = -1;
   m_compactHoveredSubButton   = 0;
   //--- Bail on invalid active tab index
   if(m_activeTabIdx < 0 || m_activeTabIdx >= ArraySize(m_tabGroups)) return;
   const string activeGroup = m_tabGroups[m_activeTabIdx];
   const int n = ArraySize(m_settingsProperties);
   //--- Walk every property and add the ones in the active group to the row list
   for(int i = 0; i < n; i++)
     {
      const SToolProperty p = m_settingsProperties[i];
      if(p.type == PROP_ACTION) continue;
      if(!p.showInSettings) continue;
      if(p.group != activeGroup) continue;
      //--- PROP_LEVEL_LIST expands into one synthesized compact row per level
      if(p.type == PROP_LEVEL_LIST)
        {
         //--- Query the actual level count from the engine
         int levelCount = 0;
         GetObjectProperty(m_settingsOwnerObjectId, p.id + ":count", levelCount);
         for(int li = 0; li < levelCount; li++)
           {
            //--- Build a synthesized PROP_COMPACT_ROW descriptor for this level
            const string idxs = IntegerToString(li);
            SToolProperty row;
            row.id              = p.id + ":" + idxs;
            row.label           = "";
            row.type            = PROP_COMPACT_ROW;
            row.group           = p.group;
            row.showInRibbon    = false;
            row.showInSettings  = true;
            row.tooltip         = "";
            row.defaultColor    = clrBlack;
            row.defaultInt      = 0;
            row.defaultDouble   = 0.0;
            row.defaultString   = "";
            row.defaultBool     = false;
            row.minValue        = p.minValue;
            row.maxValue        = p.maxValue;
            row.stepValue       = p.stepValue;
            row.decimals        = p.decimals;
            //--- Sub-widget ids follow the convention: "<list>:<idx>:<field>"
            row.subVisibleId    = p.id + ":" + idxs + ":visible";
            row.subValueId      = p.id + ":" + idxs + ":ratio";
            row.subColorId      = p.id + ":" + idxs + ":color";
            row.subWidthId      = p.id + ":" + idxs + ":width";
            row.subStyleId      = p.id + ":" + idxs + ":style";
            row.levelIdx        = li;
            row.isAddLevelRow   = false;
            row.levelListPrefix = p.id;
            //--- Append to the synth array + reference it from the row list via negative encoding
            const int sySz = ArraySize(m_synthRowDescriptors);
            ArrayResize(m_synthRowDescriptors, sySz + 1);
            m_synthRowDescriptors[sySz] = row;
            const int rsz = ArraySize(m_activeTabRowIdxs);
            ArrayResize(m_activeTabRowIdxs, rsz + 1);
            //--- Negative-encoded: -(idx + 1) -> resolved by ResolveActiveRowDescriptor
            m_activeTabRowIdxs[rsz] = -(sySz + 1);
           }
         continue;
        }
      //--- Filter to the 6 renderable types (others are not row-eligible)
      if(p.type != PROP_COLOR && p.type != PROP_LINE_WIDTH
         && p.type != PROP_LINE_STYLE && p.type != PROP_COMPACT_ROW
         && p.type != PROP_BOOL && p.type != PROP_FLOAT)
         continue;
      //--- Append the real-descriptor index to the row list
      const int sz = ArraySize(m_activeTabRowIdxs);
      ArrayResize(m_activeTabRowIdxs, sz + 1);
      m_activeTabRowIdxs[sz] = i;
     }
  }

//+------------------------------------------------------------------+
//| Resolve a row slot to its descriptor (real or synthesized)       |
//+------------------------------------------------------------------+
SToolProperty CSettingsWindow::ResolveActiveRowDescriptor(int rowSlot)
  {
   //--- Out-of-range -> default-constructed empty descriptor
   SToolProperty empty;
   if(rowSlot < 0 || rowSlot >= ArraySize(m_activeTabRowIdxs)) return empty;
   const int code = m_activeTabRowIdxs[rowSlot];
   //--- Non-negative code -> direct index into m_settingsProperties
   if(code >= 0)
     {
      if(code >= ArraySize(m_settingsProperties)) return empty;
      return m_settingsProperties[code];
     }
   //--- Negative code -> negative-encoded synth index (-(idx + 1))
   const int synthIdx = -(code + 1);
   if(synthIdx < 0 || synthIdx >= ArraySize(m_synthRowDescriptors)) return empty;
   return m_synthRowDescriptors[synthIdx];
  }

//+------------------------------------------------------------------+
//| Recompute window size based on the active tab's content height   |
//+------------------------------------------------------------------+
void CSettingsWindow::RecalcSettingsSize()
  {
   //--- Resolve the active group; empty string if no tabs
   const string activeGroup = (m_activeTabIdx >= 0
                              && m_activeTabIdx < ArraySize(m_tabGroups))
                              ? m_tabGroups[m_activeTabIdx]
                              : "";

   //--- Compute the content height for the active tab
   int contentH = 0;
   if(activeGroup == PROP_GROUP_TEXT)
     {
      //--- Text tab has 3 fixed-height rows: row1 (color+font+bold) 32 + gap 8 + row2 (text area) 90 + gap 8 + row3 (alignments) 32
      contentH = 32 + 8 + 90 + 8 + 32;     // = 170
     }
   else if(activeGroup == PROP_GROUP_COORDS)
     {
      //--- Coords tab has one row per drawn-object point (or 1 fallback)
      const int pointCount = GetObjectPointCount(m_settingsOwnerObjectId);
      const int rows = MathMax(1, pointCount);
      const int rowH = 32;
      const int rowGap = 8;
      contentH = rows * rowH + (rows - 1) * rowGap;
     }
   else
     {
      //--- Default tab: row-per-descriptor with the standard row height + gap
      int rows = ArraySize(m_activeTabRowIdxs);
      if(rows < 1) rows = 1;
      contentH = rows * (m_settingsRowH + m_settingsRowGap);
     }

   //--- Window width is fixed; height is content + chrome, clamped to the chart
   m_settingsWidth = 360;

   const int idealH = m_settingsHeaderH
                    + m_settingsTabBarH
                    + contentH
                    + m_settingsFooterH;
   //--- Clamp to chart-cap (min 160 to avoid degenerate windows)
   const int chartH = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
   const int chartCap = MathMax(160, chartH - 16);
   const int actualH = (idealH < chartCap) ? idealH : chartCap;
   m_settingsHeight  = actualH;
   //--- Chrome = header + tab bar + footer; body viewport = actualH - chrome
   const int bodyChromeH = m_settingsHeaderH + m_settingsTabBarH
                          + m_settingsFooterH;
   m_bodyContentH    = contentH;
   m_bodyViewportH   = actualH - bodyChromeH;
   if(m_bodyViewportH < 0) m_bodyViewportH = 0;
   //--- Max scroll = content - viewport (or 0 if content fits)
   m_bodyMaxScrollPx = MathMax(0, m_bodyContentH - m_bodyViewportH);
   if(m_bodyScrollPx > m_bodyMaxScrollPx) m_bodyScrollPx = m_bodyMaxScrollPx;
   if(m_bodyScrollPx < 0)                  m_bodyScrollPx = 0;

   //--- Resize canvas only when the actual size changed (avoids unnecessary reallocations)
   const int canvasW = m_settingsWidth  + 2 * m_settingsShadowPad;
   const int canvasH = m_settingsHeight + 2 * m_settingsShadowPad;
   if(m_canvasSettings.Width() != canvasW || m_canvasSettings.Height() != canvasH)
      m_canvasSettings.Resize(canvasW, canvasH);
   //--- Also push the new size to the chart object so MT5 knows the new bounds
   ObjectSetInteger(0, m_nameSettings, OBJPROP_XSIZE, canvasW);
   ObjectSetInteger(0, m_nameSettings, OBJPROP_YSIZE, canvasH);
  }

//+------------------------------------------------------------------+
//| Push the window's logical (X, Y) to the chart object             |
//+------------------------------------------------------------------+
void CSettingsWindow::ApplySettingsPosition()
  {
   //--- Subtract the shadow halo so the chart-object top-left = our logical top-left minus halo
   ObjectSetInteger(0, m_nameSettings, OBJPROP_XDISTANCE,
                     m_settingsX - m_settingsShadowPad);
   ObjectSetInteger(0, m_nameSettings, OBJPROP_YDISTANCE,
                     m_settingsY - m_settingsShadowPad);
  }

//+------------------------------------------------------------------+
//| Layout helpers - return per-component bounds in window-local px  |
//+------------------------------------------------------------------+
void CSettingsWindow::GetTabContainerRect(int &outL, int &outT, int &outR, int &outB)
  {
   //--- Container = window pad to window pad horizontally + centered vertically inside the tab bar
   outL = m_settingsPadX;
   outR = m_settingsWidth - m_settingsPadX;
   const int barT = m_settingsHeaderH;
   outT = barT + (m_settingsTabBarH - m_settingsTabContainerH) / 2;
   outB = outT + m_settingsTabContainerH;
  }

//+------------------------------------------------------------------+
//| Tab segment rect (n-th tab inside the container, equal width)    |
//+------------------------------------------------------------------+
void CSettingsWindow::GetTabRect(int tabIdx, int &outL, int &outT, int &outR, int &outB)
  {
   //--- Bail on empty or out-of-range tab index
   const int n = ArraySize(m_tabLabels);
   if(n <= 0 || tabIdx < 0 || tabIdx >= n)
     { outL = outT = outR = outB = 0; return; }
   //--- Divide the container into n equal-width segments
   int cL, cT, cR, cB;
   GetTabContainerRect(cL, cT, cR, cB);
   const int containerW = cR - cL;
   const int segW = containerW / n;
   //--- Last tab gets any leftover width so the strip extends fully to the right edge
   const bool isLast = (tabIdx == n - 1);
   outL = cL + tabIdx * segW;
   outR = isLast ? cR : (outL + segW);
   outT = cT;
   outB = cB;
  }

//+------------------------------------------------------------------+
//| Settings row rect (offset by the body scroll position)           |
//+------------------------------------------------------------------+
void CSettingsWindow::GetRowRect(int rowSlot, int &outL, int &outT, int &outR, int &outB)
  {
   //--- Rows start below the header + tab bar
   const int rowsTop = m_settingsHeaderH + m_settingsTabBarH;
   outL = m_settingsPadX;
   outR = m_settingsWidth - m_settingsPadX;
   //--- Row Y = rows top + (row index * stride) - current body scroll
   outT = rowsTop + rowSlot * (m_settingsRowH + m_settingsRowGap)
        - m_bodyScrollPx;
   outB = outT + m_settingsRowH;
  }

//+------------------------------------------------------------------+
//| Right-aligned chip rect inside a row                             |
//+------------------------------------------------------------------+
void CSettingsWindow::GetRowChipRect(int rowSlot, int &outL, int &outT, int &outR, int &outB)
  {
   //--- Chip = right-aligned, vertically centered, fixed chip W x H
   int rL, rT, rR, rB;
   GetRowRect(rowSlot, rL, rT, rR, rB);
   outR = rR;
   outL = outR - m_settingsChipW;
   outT = rT + (m_settingsRowH - m_settingsChipH) / 2;
   outB = outT + m_settingsChipH;
  }

//+------------------------------------------------------------------+
//| Value-button rect inside a compact row (or whole chip for FLOAT) |
//+------------------------------------------------------------------+
bool CSettingsWindow::GetCompactValueButtonRect(int rowSlot,
                                                  int &outL, int &outT,
                                                  int &outR, int &outB)
  {
   //--- Bail on out-of-range slot
   if(rowSlot < 0 || rowSlot >= ArraySize(m_activeTabRowIdxs)) return false;
   const SToolProperty p = ResolveActiveRowDescriptor(rowSlot);
   //--- PROP_FLOAT: the whole chip IS the value button
   if(p.type == PROP_FLOAT)
     {
      GetRowChipRect(rowSlot, outL, outT, outR, outB);
      return true;
     }
   //--- PROP_COMPACT_ROW: value button sits after the (optional) visibility checkbox
   if(p.type == PROP_COMPACT_ROW)
     {
      if(StringLen(p.subValueId) == 0) return false;
      const int chkSize = 22, valW = 60, btnH = 24, gap = 8;
      int rL, rT, rR, rB;
      GetRowRect(rowSlot, rL, rT, rR, rB);
      const int contLeftX = rL + 6;
      const int contMidYW = (rT + rB) / 2;
      //--- Skip past the checkbox if present
      int x = contLeftX;
      if(StringLen(p.subVisibleId) > 0)
         x += chkSize + gap;
      outL = x;
      outR = x + valW;
      outT = contMidYW - btnH / 2;
      outB = outT + btnH;
      return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
//| Stepper rect (up/down chevron) inside the value button           |
//+------------------------------------------------------------------+
bool CSettingsWindow::GetCompactStepperRect(int rowSlot, int dir,
                                              int &outL, int &outT,
                                              int &outR, int &outB)
  {
   //--- Stepper sits on the right edge of the value button
   int bL, bT, bR, bB;
   if(!GetCompactValueButtonRect(rowSlot, bL, bT, bR, bB)) return false;
   const int stepW = 16;
   outR = bR - 2;
   outL = outR - stepW;
   //--- dir=0 -> upper half (increment), dir=1 -> lower half (decrement)
   const int halfH = (bB - bT) / 2;
   if(dir == 0)
     { outT = bT + 2; outB = bT + halfH; }
   else
     { outT = bT + halfH; outB = bB - 2; }
   return true;
  }

//+------------------------------------------------------------------+
//| Body scrollbar thumb rect (settings-local or chart-absolute)     |
//+------------------------------------------------------------------+
bool CSettingsWindow::GetBodyThumbRect(int &outL, int &outT, int &outR, int &outB,
                                         bool settingsRelativeOnly)
  {
   //--- Initialize out-params to 0 then bail if there's no scrollable content
   outL = outT = outR = outB = 0;
   if(m_bodyMaxScrollPx <= 0) return false;
   //--- Track sits on the right edge between header+tabs and the footer
   const int boxL = m_settingsShadowPad;
   const int boxT = m_settingsShadowPad;
   const int sbW   = 3;
   const int viewportT = m_settingsHeaderH + m_settingsTabBarH;
   const int viewportB = viewportT + m_bodyViewportH;
   const int trackR = boxL + m_settingsWidth - 2;
   const int trackL = trackR - sbW;
   const int trackT = boxT + viewportT;
   const int trackB = boxT + viewportB;
   const int trackH = trackB - trackT;
   if(trackH <= 0) return false;
   //--- Thumb height = (viewport / total) * track height; clamped to a min of 20 px
   const int viewportH = trackH;
   const int totalH    = viewportH + m_bodyMaxScrollPx;
   int thumbH = (int)((double)trackH * (double)viewportH / (double)totalH);
   if(thumbH < 20)     thumbH = 20;
   if(thumbH > trackH) thumbH = trackH;
   //--- Thumb Y = track top + (scroll-fraction * available-travel)
   const int thumbY = trackT + (int)((double)(trackH - thumbH)
                                       * (double)m_bodyScrollPx
                                       / (double)m_bodyMaxScrollPx);
   //--- Settings-relative: subtract canvas top-left so callers can blit into the canvas
   if(settingsRelativeOnly)
     {
      outL = trackL - boxL;
      outR = trackR - boxL;
      outT = thumbY - boxT;
      outB = thumbY + thumbH - boxT;
     }
   else
     {
      //--- Chart-absolute: add settings XY so callers can hit-test against mouse coords
      outL = m_settingsX + (trackL - boxL);
      outR = m_settingsX + (trackR - boxL);
      outT = m_settingsY + (thumbY - boxT);
      outB = m_settingsY + (thumbY + thumbH - boxT);
     }
   return true;
  }

//+------------------------------------------------------------------+
//| Render the body scrollbar thumb (pill, theme-aware)              |
//+------------------------------------------------------------------+
void CSettingsWindow::DrawBodyScrollbar()
  {
   //--- Bail if there's no scrollable content
   int tL, tT, tR, tB;
   if(!GetBodyThumbRect(tL, tT, tR, tB, true)) return;
   const int boxL = m_settingsShadowPad;
   const int boxT = m_settingsShadowPad;
   //--- Pill color reflects 3 states: dragging > hovered > idle
   color   pillColor;
   uchar   pillAlpha;
   if(m_bodyThumbDragging)
     { pillColor = m_themeColors.accentBarColor;        pillAlpha = 255; }
   else if(m_hoveredBodyScrollbar)
     { pillColor = m_themeColors.scrollArrowHoverColor; pillAlpha = 255; }
   else
     { pillColor = m_themeColors.scrollArrowColor;      pillAlpha = 180; }
   //--- Paint as a rounded rect with corner radius = half the bar width
   const uint thumbArgb = ColorToARGB(pillColor, pillAlpha);
   const int sbW = tR - tL;
   FillNoteRoundRect(m_canvasSettings,
                       boxL + tL, boxT + tT,
                       boxL + tR, boxT + tB,
                       MathMax(1, sbW / 2),
                       thumbArgb);
  }

//+------------------------------------------------------------------+
//| Close-X button rect (top-right of header)                        |
//+------------------------------------------------------------------+
void CSettingsWindow::GetCloseButtonRect(int &outL, int &outT, int &outR, int &outB)
  {
   //--- 26x26 button anchored 10 px from the right edge, vertically centered in the header
   const int sz = 26;
   outR = m_settingsWidth - 10;
   outL = outR - sz;
   outT = (m_settingsHeaderH - sz) / 2;
   outB = outT + sz;
  }

//+------------------------------------------------------------------+
//| Footer button rect (1=Cancel, 2=Ok, 3=Apply Defaults)            |
//+------------------------------------------------------------------+
void CSettingsWindow::GetFooterButtonRect(int btnIdx, int &outL, int &outT, int &outR, int &outB)
  {
   //--- Buttons are 76x28 (Apply is 110 wide for the longer text), centered vertically in the footer
   const int btnW   = 76;
   const int applyW = 110;
   const int btnH   = 28;
   const int gap    = 8;
   const int rightX = m_settingsWidth - m_settingsPadX;
   const int leftX  = m_settingsPadX;
   const int btnT   = m_settingsHeight - m_settingsFooterH +
                       (m_settingsFooterH - btnH) / 2;
   const int btnB   = btnT + btnH;
   //--- btn 2 = Ok (rightmost), btn 1 = Cancel (left of Ok), btn 3 = Apply Defaults (leftmost)
   if(btnIdx == 2)
     { outR = rightX; outL = outR - btnW; }
   else if(btnIdx == 1)
     { outR = rightX - btnW - gap; outL = outR - btnW; }
   else if(btnIdx == 3)
     { outL = leftX; outR = outL + applyW; }
   else
     { outL = outT = outR = outB = 0; return; }
   outT = btnT;
   outB = btnB;
  }

//+------------------------------------------------------------------+
//| Hit-tests for each interactive region (return idx or -1/0/false) |
//+------------------------------------------------------------------+
int CSettingsWindow::HitTestTab(int lx, int ly)
  {
   //--- Linear scan over all tabs; return the index of the first containing tab
   const int n = ArraySize(m_tabLabels);
   for(int i = 0; i < n; i++)
     {
      int tL, tT, tR, tB;
      GetTabRect(i, tL, tT, tR, tB);
      if(lx >= tL && lx < tR && ly >= tT && ly < tB) return i;
     }
   return -1;
  }

//+------------------------------------------------------------------+
//| Hit-test against settings rows (chip OR full row for compact)    |
//+------------------------------------------------------------------+
int CSettingsWindow::HitTestRow(int lx, int ly)
  {
   //--- Reject hits outside the body viewport
   const int viewportT = m_settingsHeaderH + m_settingsTabBarH;
   const int viewportB = viewportT + m_bodyViewportH;
   if(ly < viewportT || ly >= viewportB) return -1;
   const int n = ArraySize(m_activeTabRowIdxs);
   //--- Walk all rows; PROP_COMPACT_ROW gets full-row hit, others get chip-only hit
   for(int s = 0; s < n; s++)
     {
      const SToolProperty p = ResolveActiveRowDescriptor(s);
      if(p.type == PROP_COMPACT_ROW)
        {
         int rL, rT, rR, rB;
         GetRowRect(s, rL, rT, rR, rB);
         if(lx >= rL && lx < rR && ly >= rT && ly < rB) return s;
        }
      else
        {
         int cL, cT, cR, cB;
         GetRowChipRect(s, cL, cT, cR, cB);
         if(lx >= cL && lx < cR && ly >= cT && ly < cB) return s;
        }
     }
   return -1;
  }

//+------------------------------------------------------------------+
//| Hit-test footer buttons (returns 1=Cancel, 2=Ok, 3=Apply, 0=miss)|
//+------------------------------------------------------------------+
int CSettingsWindow::HitTestFooterButton(int lx, int ly)
  {
   //--- Scan all 3 footer buttons
   for(int i = 1; i <= 3; i++)
     {
      int bL, bT, bR, bB;
      GetFooterButtonRect(i, bL, bT, bR, bB);
      if(lx >= bL && lx < bR && ly >= bT && ly < bB) return i;
     }
   return 0;
  }

//+------------------------------------------------------------------+
//| Hit-test close-X button (true if inside the 26x26 rect)          |
//+------------------------------------------------------------------+
bool CSettingsWindow::HitTestCloseButton(int lx, int ly)
  {
   int cL, cT, cR, cB;
   GetCloseButtonRect(cL, cT, cR, cB);
   return (lx >= cL && lx < cR && ly >= cT && ly < cB);
  }

//+------------------------------------------------------------------+
//| Hit-test header drag area (header strip MINUS the close button)  |
//+------------------------------------------------------------------+
bool CSettingsWindow::HitTestHeaderDragArea(int lx, int ly)
  {
   //--- Outside the header band -> not draggable
   if(ly < 0 || ly >= m_settingsHeaderH) return false;
   //--- Don't treat clicks on the close button as drag-grabs
   if(HitTestCloseButton(lx, ly)) return false;
   return true;
  }

//+------------------------------------------------------------------+
//| Hit-test settings window body (emits local coords via out-params)|
//+------------------------------------------------------------------+
bool CSettingsWindow::HitTestOverSettings(int mouseX, int mouseY, int &outLx, int &outLy)
  {
   //--- Bail when hidden
   if(!m_isSettingsVisible) return false;
   //--- Translate to window-local coords + rectangle containment test
   const int lx = mouseX - m_settingsX;
   const int ly = mouseY - m_settingsY;
   if(lx < 0 || lx >= m_settingsWidth)  return false;
   if(ly < 0 || ly >= m_settingsHeight) return false;
   outLx = lx; outLy = ly;
   return true;
  }

//+------------------------------------------------------------------+
//| Full repaint - shadow + body + rows + header/tabs/footer overlay |
//+------------------------------------------------------------------+
void CSettingsWindow::RedrawSettings()
  {
   //--- No-op when hidden
   if(!m_isSettingsVisible) return;
   //--- Clear the canvas to fully transparent
   m_canvasSettings.Erase(0x00000000);

   //--- Body rect inside the canvas (offset by shadow halo)
   const int boxL = m_settingsShadowPad;
   const int boxT = m_settingsShadowPad;
   const int boxR = m_settingsShadowPad + m_settingsWidth;
   const int boxB = m_settingsShadowPad + m_settingsHeight;

   //--- Drop shadow first (drawn underneath the body)
   DrawNoteDropShadow(m_canvasSettings, boxL, boxT, boxR, boxB,
                       m_settingsCornerRadius);

   //--- Rounded background body (theme-aware fill)
   const uchar bgAlpha = (uchar)(255 * BackgroundOpacity);
   const uint  bodyArgb = ColorToARGB(m_themeColors.flyoutBackground, bgAlpha);
   FillNoteRoundRect(m_canvasSettings, boxL, boxT, boxR, boxB,
                       m_settingsCornerRadius, bodyArgb);

   //--- Rows FIRST — header/tabstrip/footer painted on top to mask spillover.
   DrawSettingsRows();
   DrawSettingsHeader();
   DrawSettingsTabStrip();
   DrawSettingsFooter();

   //--- Flush canvas pixels to the chart object
   m_canvasSettings.Update();
  }

//+------------------------------------------------------------------+
//| Draw the header strip (tool name + close-X with hover bg)        |
//+------------------------------------------------------------------+
void CSettingsWindow::DrawSettingsHeader()
  {
   //--- Canvas-space top-left of the body rect (offset by shadow halo)
   const int boxL = m_settingsShadowPad;
   const int boxT = m_settingsShadowPad;

   //--- Fill header band - 2 rectangles to keep the rounded top corners untouched
   const uchar bgAlpha = (uchar)(255 * BackgroundOpacity);
   const uint  hdrBgArgb = ColorToARGB(m_themeColors.flyoutBackground, bgAlpha);
   const int hdrInnerT = boxT + m_settingsCornerRadius;
   const int hdrInnerB = boxT + m_settingsHeaderH - 1;
   //--- Main body of header strip (below the rounded corners)
   m_canvasSettings.FillRectangle(boxL + 1, hdrInnerT,
                                    boxL + m_settingsWidth - 2, hdrInnerB,
                                    hdrBgArgb);
   //--- Top strip between the rounded corners
   m_canvasSettings.FillRectangle(boxL + m_settingsCornerRadius, boxT + 1,
                                    boxL + m_settingsWidth - m_settingsCornerRadius - 1,
                                    hdrInnerT - 1,
                                    hdrBgArgb);

   //--- Header text = tool label for the bound object (fallback "Settings")
   string toolName = "Settings";
   const int idx = FindObjectIndexById(m_settingsOwnerObjectId);
   if(idx >= 0)
      toolName = GetToolLabel(m_drawnObjects[idx].toolType);
   m_canvasSettings.FontSet("Arial Bold", -110);
   const int hdrLH = m_canvasSettings.TextHeight(toolName);
   const int textY = boxT + (m_settingsHeaderH - hdrLH) / 2;
   //--- Left-aligned at pad-X, vertically centered in header
   m_canvasSettings.TextOut(boxL + m_settingsPadX, textY,
                              toolName,
                              ColorToARGB(m_themeColors.flyoutTextColor, 255));

   //--- Close-X button: paint hover background first (if hovered), then the X glyph
   int cL, cT, cR, cB;
   GetCloseButtonRect(cL, cT, cR, cB);
   if(m_hoveredCloseBtn)
     {
      //--- Subtle hover-tint rounded background behind the X
      const uint hovArgb = ColorToARGB(m_themeColors.flyoutTextColor, 40);
      FillNoteRoundRect(m_canvasSettings,
                          boxL + cL, boxT + cT, boxL + cR, boxT + cB,
                          5, hovArgb);
     }
   //--- Two crossing AA thick lines = the X glyph
   const int btnCx = boxL + (cL + cR) / 2;
   const int btnCy = boxT + (cT + cB) / 2;
   const int xRadius = 5;
   const uint xArgb = ColorToARGB(m_themeColors.flyoutTextColor, 230);
   //--- Diagonal 1: top-left to bottom-right
   WidgetThickLineAA(m_canvasSettings,
                      btnCx - xRadius, btnCy - xRadius,
                      btnCx + xRadius, btnCy + xRadius,
                      2, xArgb);
   //--- Diagonal 2: top-right to bottom-left
   WidgetThickLineAA(m_canvasSettings,
                      btnCx + xRadius, btnCy - xRadius,
                      btnCx - xRadius, btnCy + xRadius,
                      2, xArgb);
  }

//+------------------------------------------------------------------+
//| Draw the tab strip (segmented control with active + hover states)|
//+------------------------------------------------------------------+
void CSettingsWindow::DrawSettingsTabStrip()
  {
   //--- Bail on empty tab list
   const int boxL = m_settingsShadowPad;
   const int boxT = m_settingsShadowPad;
   const int n = ArraySize(m_tabLabels);
   if(n == 0) return;

   //--- Tab bar zone fill (mask any body content that bled up under the bar)
   const uchar bgAlpha = (uchar)(255 * BackgroundOpacity);
   const uint  zoneArgb = ColorToARGB(m_themeColors.flyoutBackground, bgAlpha);
   const int zoneT = boxT + m_settingsHeaderH;
   const int zoneB = zoneT + m_settingsTabBarH - 1;
   m_canvasSettings.FillRectangle(boxL + 1, zoneT,
                                    boxL + m_settingsWidth - 2, zoneB,
                                    zoneArgb);

   //--- Outer container: rounded rect at low alpha
   int cL, cT, cR, cB;
   GetTabContainerRect(cL, cT, cR, cB);
   const uint containerArgb = ColorToARGB(m_themeColors.flyoutTextColor, 22);
   FillNoteRoundRect(m_canvasSettings,
                       boxL + cL, boxT + cT,
                       boxL + cR, boxT + cB,
                       6, containerArgb);

   //--- Per-tab loop: paint active/hover backgrounds + label text
   m_canvasSettings.FontSet("Arial Bold", -100);
   for(int i = 0; i < n; i++)
     {
      //--- Resolve this tab's bounds + active/hover state
      int tL, tT, tR, tB;
      GetTabRect(i, tL, tT, tR, tB);
      const bool isActive  = (i == m_activeTabIdx);
      const bool isHovered = (i == m_hoveredTabIdx);

      if(isActive)
        {
         //--- Active tab: inner pill at theme-inverse color (subtle alpha drop when also hovered)
         const int inset = 3;
         const uchar pillA = isHovered ? (uchar)225 : (uchar)255;
         const uint pillArgb = ColorToARGB(m_themeColors.flyoutTextColor, pillA);
         FillNoteRoundRect(m_canvasSettings,
                             boxL + tL + inset, boxT + tT + inset,
                             boxL + tR - inset, boxT + tB - inset,
                             5, pillArgb);
        }
      else if(isHovered)
        {
         //--- Hover-only (inactive): subtle bg tint
         const int inset = 3;
         const uint hovArgb = ColorToARGB(m_themeColors.flyoutTextColor, 28);
         FillNoteRoundRect(m_canvasSettings,
                             boxL + tL + inset, boxT + tT + inset,
                             boxL + tR - inset, boxT + tB - inset,
                             5, hovArgb);
        }

      //--- Center the label inside the tab; active text contrasts with the pill (= flyoutBackground)
      const int tLW = m_canvasSettings.TextWidth(m_tabLabels[i]);
      const int tLH = m_canvasSettings.TextHeight(m_tabLabels[i]);
      const int labelX = boxL + tL + (tR - tL - tLW) / 2;
      const int labelY = boxT + tT + (tB - tT - tLH) / 2;
      //--- Active = inverse color, inactive = normal text color
      const color labelCol = isActive
                              ? m_themeColors.flyoutBackground
                              : m_themeColors.flyoutTextColor;
      const uchar labelA = isActive ? (uchar)255 : (uchar)200;
      m_canvasSettings.TextOut(labelX, labelY, m_tabLabels[i],
                                 ColorToARGB(labelCol, labelA));
     }
  }

//+------------------------------------------------------------------+
//| Draw all body rows for the active tab (dispatch to Text/Coords)  |
//+------------------------------------------------------------------+
void CSettingsWindow::DrawSettingsRows()
  {
   //--- Text tab takes a custom render path (different layout from generic rows)
   const bool isTextTab = (m_activeTabIdx >= 0
                          && m_activeTabIdx < ArraySize(m_tabGroups)
                          && m_tabGroups[m_activeTabIdx] == PROP_GROUP_TEXT);
   if(isTextTab)
     {
      DrawTextTabRows();
      return;
     }
   //--- Coordinates tab also has a custom render path (point-per-row)
   const bool isCoordsTab = (m_activeTabIdx >= 0
                             && m_activeTabIdx < ArraySize(m_tabGroups)
                             && m_tabGroups[m_activeTabIdx] == PROP_GROUP_COORDS);
   if(isCoordsTab)
     {
      DrawCoordsTabRows();
      return;
     }

   //--- Generic-row path (Style/Visibility tabs): label + chip per row, clipped to the viewport
   const int boxL = m_settingsShadowPad;
   const int boxT = m_settingsShadowPad;
   const int n = ArraySize(m_activeTabRowIdxs);
   const int viewportT = m_settingsHeaderH + m_settingsTabBarH;
   const int viewportB = viewportT + m_bodyViewportH;
   m_canvasSettings.FontSet("Arial", -100);
   for(int s = 0; s < n; s++)
     {
      //--- Resolve this row's descriptor + bounds
      const SToolProperty prop = ResolveActiveRowDescriptor(s);
      int rL, rT, rR, rB;
      GetRowRect(s, rL, rT, rR, rB);
      //--- Skip rows fully above or below the viewport (scroll clipping)
      if(rB <= viewportT) continue;
      if(rT >= viewportB) continue;
      //--- Compact rows are self-contained; non-compact rows get a left label
      if(prop.type != PROP_COMPACT_ROW)
        {
         const int rLH = m_canvasSettings.TextHeight(prop.label);
         const int labelY = boxT + rT + (m_settingsRowH - rLH) / 2;
         m_canvasSettings.TextOut(boxL + rL, labelY,
                                    prop.label,
                                    ColorToARGB(m_themeColors.flyoutTextColor, 220));
        }
      //--- Delegate chip rendering by type
      RenderRowChip(s, prop);
     }
   //--- Draw the scrollbar on top if the content overflows
   if(m_bodyMaxScrollPx > 0)
      DrawBodyScrollbar();
  }

//+------------------------------------------------------------------+
//| Per-row chip renderer - dispatches by descriptor type            |
//+------------------------------------------------------------------+
void CSettingsWindow::RenderRowChip(int rowSlot, const SToolProperty &prop)
  {
   //--- Canvas-space top-left + chip rect for this row
   const int boxL = m_settingsShadowPad;
   const int boxT = m_settingsShadowPad;
   int chL, chT, chR, chB;
   GetRowChipRect(rowSlot, chL, chT, chR, chB);

   //--- Active flag: true when a popover is open for this row's property id
   const bool isHovered  = (rowSlot == m_hoveredRowIdx);
   const bool isCompact  = (prop.type == PROP_COMPACT_ROW);
   const bool isActiveChip = (m_isPopoverVisible
                              && m_activePopoverPropId == prop.id);
   //--- Border = DodgerBlue accent when popover is active for this chip, separator otherwise
   const uint borderArgb = isActiveChip
                            ? ColorToARGB(clrDodgerBlue, 255)
                            : ColorToARGB(m_themeColors.separatorColor, 255);
   const uint fillArgb = ColorToARGB(m_themeColors.flyoutBackground, 255);

   //--- Non-compact rows get the standard chip outline + optional hover tint
   if(!isCompact)
     {
      WidgetStrokeRoundRect(m_canvasSettings,
                              boxL + chL, boxT + chT,
                              boxL + chR, boxT + chB,
                              4, 1, borderArgb, fillArgb);
      if(isHovered && !isActiveChip)
        {
         //--- Subtle hover tint inside the chip border
         const uint tintArgb = ColorToARGB(m_themeColors.flyoutTextColor, 30);
         FillNoteRoundRect(m_canvasSettings,
                             boxL + chL + 1, boxT + chT + 1,
                             boxL + chR - 1, boxT + chB - 1,
                             3, tintArgb);
        }
     }

   //--- Content cursor + vertical center inside the chip
   const int contL = boxL + chL + 8;
   const int contMidY = boxT + (chT + chB) / 2;

   //--- PROP_COLOR: 16x16 swatch with checker backdrop + active-color overlay at opacity
   if(prop.type == PROP_COLOR)
     {
      //--- Read the active color + sibling opacity from the engine
      color activeColor = clrBlack;
      GetObjectProperty(m_settingsOwnerObjectId, prop.id, activeColor);
      string opacityPropId = ColorToOpacityProp(prop.id);
      int activeOpacity = 100;
      GetObjectProperty(m_settingsOwnerObjectId, opacityPropId, activeOpacity);
      //--- Swatch: 16x16 with transparency-checker backdrop
      const int sqSize = 16;
      const int sqL = contL;
      const int sqT = contMidY - sqSize / 2;
      WidgetCheckerFillRect(m_canvasSettings, sqL, sqT,
                             sqL + sqSize, sqT + sqSize, 3);
      //--- Overlay the active color at the active opacity (shows through the checker)
      const uint overlayArgb = ColorWithPercentOpacity(activeColor, activeOpacity);
      for(int yy = sqT; yy < sqT + sqSize; yy++)
         for(int xx = sqL; xx < sqL + sqSize; xx++)
            WidgetBlendPixel(m_canvasSettings, xx, yy, overlayArgb);
     }
   //--- PROP_LINE_WIDTH: AA thick line preview + "Xpx" label
   else if(prop.type == PROP_LINE_WIDTH)
     {
      int activeWidth = 2;
      GetObjectProperty(m_settingsOwnerObjectId, "lineWidth", activeWidth);
      const uint glyphArgb = ColorToARGB(m_themeColors.flyoutTextColor, 230);
      //--- 28-pixel stroke preview at the active width
      WidgetThickLineAA(m_canvasSettings, contL, contMidY,
                          contL + 28, contMidY, activeWidth, glyphArgb);
      //--- "Xpx" text label to the right of the stroke preview
      m_canvasSettings.FontSet("Arial", -100);
      const string wText = IntegerToString(activeWidth) + "px";
      const int wLH = m_canvasSettings.TextHeight(wText);
      const int wTextY = boxT + chT + (m_settingsChipH - wLH) / 2;
      m_canvasSettings.TextOut(contL + 36, wTextY, wText,
                                 ColorToARGB(m_themeColors.flyoutTextColor, 230));
     }
   //--- PROP_LINE_STYLE: stroke preview at active style/width + style-name label
   else if(prop.type == PROP_LINE_STYLE)
     {
      int activeStyle = 0;
      int activeWidth = 2;
      GetObjectProperty(m_settingsOwnerObjectId, "lineStyle", activeStyle);
      GetObjectProperty(m_settingsOwnerObjectId, "lineWidth", activeWidth);
      const uint glyphArgb = ColorToARGB(m_themeColors.flyoutTextColor, 230);
      //--- Stroke preview rendered in a 28x12 area to the left
      StrokeLinePreview(m_canvasSettings, contL, contMidY - 6,
                          contL + 28, contMidY + 6,
                          activeWidth, activeStyle, glyphArgb);
      //--- Style label to the right ("Line", "Dashed line", etc.)
      m_canvasSettings.FontSet("Arial", -100);
      const string sText = GetLineStyleLabel(activeStyle);
      const int sLH = m_canvasSettings.TextHeight(sText);
      const int sTextY = boxT + chT + (m_settingsChipH - sLH) / 2;
      m_canvasSettings.TextOut(contL + 36, sTextY, sText,
                                 ColorToARGB(m_themeColors.flyoutTextColor, 230));
     }
   //--- PROP_BOOL: 22x22 checkbox cube (blue filled + white tick when true)
   else if(prop.type == PROP_BOOL)
     {
      bool curBool = false;
      GetObjectProperty(m_settingsOwnerObjectId, prop.id, curBool);
      //--- Checkbox centered inside the chip rect
      const int chkSize = 22;
      const int chkL_ = boxL + chL + (chR - chL - chkSize) / 2;
      const int chkT_ = boxT + chT + (chB - chT - chkSize) / 2;
      const uint chkBorder = ColorToARGB(m_themeColors.separatorColor, 255);
      const uint chkFill   = ColorToARGB(m_themeColors.flyoutBackground, 255);
      //--- Always paint the empty checkbox first (outline + background)
      WidgetStrokeRoundRect(m_canvasSettings,
                              chkL_, chkT_,
                              chkL_ + chkSize, chkT_ + chkSize,
                              4, 1, chkBorder, chkFill);
      if(curBool)
        {
         //--- True state: DodgerBlue interior + white tick glyph
         const uint blueArgb = ColorToARGB(clrDodgerBlue, 255);
         FillNoteRoundRect(m_canvasSettings,
                            chkL_ + 2, chkT_ + 2,
                            chkL_ + chkSize - 2, chkT_ + chkSize - 2,
                            2, blueArgb);
         //--- Tick = 2 thick AA strokes forming a checkmark
         const uint tickArgb = ColorToARGB(clrWhite, 255);
         const int tx0 = chkL_ + chkSize / 4;
         const int ty0 = chkT_ + chkSize / 2;
         const int tx1 = chkL_ + chkSize * 4 / 10;
         const int ty1 = chkT_ + chkSize * 7 / 10;
         const int tx2 = chkL_ + chkSize * 3 / 4;
         const int ty2 = chkT_ + chkSize / 4 + 1;
         WidgetThickLineAA(m_canvasSettings, tx0, ty0, tx1, ty1, 2, tickArgb);
         WidgetThickLineAA(m_canvasSettings, tx1, ty1, tx2, ty2, 2, tickArgb);
        }
     }
   //--- PROP_FLOAT: inline-editable numeric value with caret + selection + steppers
   else if(prop.type == PROP_FLOAT)
     {
      //--- Read the live value + check if THIS is the float being edited
      double curVal = 0.0;
      GetObjectProperty(m_settingsOwnerObjectId, prop.id, curVal);
      const bool isThisFloatEdit = IsEditingFloat() && m_floatEditPropId == prop.id;
      const uint glyphArgb = ColorToARGB(m_themeColors.flyoutTextColor, 230);
      //--- Focus border (DodgerBlue) when this float is being edited
      if(isThisFloatEdit)
        {
         const uint focusArgb = ColorToARGB(clrDodgerBlue, 255);
         const uint fillArgb_ = ColorToARGB(m_themeColors.flyoutBackground, 255);
         WidgetStrokeRoundRect(m_canvasSettings,
                                 boxL + chL + 1, boxT + chT + 1,
                                 boxL + chR - 1, boxT + chB - 1,
                                 3, 1, focusArgb, fillArgb_);
        }
      //--- Text: edit buffer when editing, formatted value otherwise
      m_canvasSettings.FontSet("Arial", -100);
      string valStr = isThisFloatEdit
                     ? m_floatEditBuffer
                     : DoubleToString(curVal, prop.decimals);
      const int textH = m_canvasSettings.TextHeight(valStr);
      const int textY = boxT + chT + (m_settingsChipH - textH) / 2;
      const int textX = boxL + chL + 8;
      //--- Render text selection highlight (when there's an active selection range)
      if(isThisFloatEdit
         && m_floatSelectionAnchor >= 0
         && m_floatSelectionAnchor != m_floatEditCaretPos)
        {
         //--- Normalize the selection range (min..max)
         const int selS = (m_floatSelectionAnchor < m_floatEditCaretPos)
                          ? m_floatSelectionAnchor : m_floatEditCaretPos;
         const int selE = (m_floatSelectionAnchor > m_floatEditCaretPos)
                          ? m_floatSelectionAnchor : m_floatEditCaretPos;
         //--- Measure preSelection + inSelection text widths to derive the highlight rect
         const string preSel = StringSubstr(m_floatEditBuffer, 0, selS);
         const string inSel  = StringSubstr(m_floatEditBuffer, selS, selE - selS);
         const int preW = (StringLen(preSel) > 0) ? m_canvasSettings.TextWidth(preSel) : 0;
         const int selW = (StringLen(inSel) > 0)  ? m_canvasSettings.TextWidth(inSel)  : 0;
         //--- Paint the selection highlight at 90 alpha
         const uint selArgb = ColorToARGB(clrDodgerBlue, 90);
         const int rectL = textX + preW;
         const int rectR = rectL + selW;
         const int rectT = boxT + chT + 3;
         const int rectB = boxT + chB - 3;
         for(int yy = rectT; yy < rectB; yy++)
            for(int xx = rectL; xx < rectR; xx++)
               WidgetBlendPixel(m_canvasSettings, xx, yy, selArgb);
        }
      //--- Draw the value text on top of the (optional) selection highlight
      m_canvasSettings.TextOut(textX, textY, valStr, glyphArgb);
      //--- Caret: thin vertical line at the caret column (in the visible blink phase)
      if(isThisFloatEdit && m_floatEditCaretBlinkOn)
        {
         //--- Caret X = text origin + width of the buffer up to the caret position
         const string seg = StringSubstr(m_floatEditBuffer, 0, m_floatEditCaretPos);
         const int caretX = textX + m_canvasSettings.TextWidth(seg);
         const int caretY1 = boxT + chT + 4;
         const int caretY2 = boxT + chB - 4;
         WidgetThickLineAA(m_canvasSettings, caretX, caretY1, caretX, caretY2, 1, glyphArgb);
        }
      //--- Show steppers when hovered or while editing
      const bool showChev = (m_compactHoveredRow == rowSlot) || isThisFloatEdit;
      if(showChev)
        {
         //--- Two steppers: dir=0 (up arrow) and dir=1 (down arrow)
         for(int dir = 0; dir <= 1; dir++)
           {
            int sL, sT, sR, sB;
            if(!GetCompactStepperRect(rowSlot, dir, sL, sT, sR, sB)) continue;
            //--- Hover state for THIS stepper (key 1 = up, key 2 = down)
            const int stepperKey = (dir == 0) ? 1 : 2;
            const bool stepHov = (m_compactHoveredRow == rowSlot
                                  && m_compactHoveredStepper == stepperKey);
            if(stepHov)
              {
               //--- Paint a subtle hover background behind the stepper
               const uint stepBgArgb = ColorToARGB(m_themeColors.flyoutTextColor, 45);
               FillNoteRoundRect(m_canvasSettings,
                                   boxL + sL, boxT + sT,
                                   boxL + sR, boxT + sB,
                                   2, stepBgArgb);
              }
            //--- Chevron glyph: 2 thick AA segments forming an arrow
            const int cx = boxL + (sL + sR) / 2;
            const int cy = boxT + (sT + sB) / 2;
            const uint chevArgb = ColorToARGB(m_themeColors.flyoutTextColor, 230);
            if(dir == 0)
              {
               //--- Up arrow: 2 segments forming an upward chevron
               WidgetThickLineAA(m_canvasSettings, cx - 3, cy + 1, cx,     cy - 1, 2, chevArgb);
               WidgetThickLineAA(m_canvasSettings, cx,     cy - 1, cx + 3, cy + 1, 2, chevArgb);
              }
            else
              {
               //--- Down arrow: 2 segments forming a downward chevron
               WidgetThickLineAA(m_canvasSettings, cx - 3, cy - 1, cx,     cy + 1, 2, chevArgb);
               WidgetThickLineAA(m_canvasSettings, cx,     cy + 1, cx + 3, cy - 1, 2, chevArgb);
              }
           }
        }
     }
   //--- PROP_COMPACT_ROW: cube cluster (visibility + value + color + width + style sub-widgets)
   else if(prop.type == PROP_COMPACT_ROW)
     {
      //--- Special-case: "+ Add level" pseudo-row gets a centered pill button
      if(prop.isAddLevelRow)
        {
         int rL_, rT_, rR_, rB_;
         GetRowRect(rowSlot, rL_, rT_, rR_, rB_);
         const int btnH_ = 24;
         const int btnT_ = (rT_ + rB_) / 2 - btnH_ / 2;
         const int btnL_ = rL_ + 6;
         const int btnR_ = rR_ - 6;
         //--- Paint the button outline + fill
         const uint borderArgb_ = ColorToARGB(m_themeColors.separatorColor, 200);
         const uint fillArgb_   = ColorToARGB(m_themeColors.flyoutBackground, 255);
         WidgetStrokeRoundRect(m_canvasSettings,
                                 boxL + btnL_, boxT + btnT_,
                                 boxL + btnR_, boxT + btnT_ + btnH_,
                                 4, 1, borderArgb_, fillArgb_);
         //--- Optional hover tint
         if(m_hoveredRowIdx == rowSlot)
           {
            const uint hovArgb = ColorToARGB(m_themeColors.flyoutTextColor, 35);
            FillNoteRoundRect(m_canvasSettings,
                                boxL + btnL_ + 1, boxT + btnT_ + 1,
                                boxL + btnR_ - 1, boxT + btnT_ + btnH_ - 1,
                                3, hovArgb);
           }
         //--- "+ Add level" label centered inside the button
         m_canvasSettings.FontSet("Arial", -100);
         const string addLbl = "+ Add level";
         const int aLW = m_canvasSettings.TextWidth(addLbl);
         const int aLH = m_canvasSettings.TextHeight(addLbl);
         const int aTX = boxL + (btnL_ + btnR_) / 2 - aLW / 2;
         const int aTY = boxT + btnT_ + (btnH_ - aLH) / 2;
         m_canvasSettings.TextOut(aTX, aTY, addLbl,
                                    ColorToARGB(m_themeColors.flyoutTextColor, 230));
         return;
        }
      //--- Compact row cube cluster - sub-widget sizes + spacing
      const int chkSize = 22, valW = 60, colW = 30, wW = 36, sW = 36;
      const int btnH = 24, gap = 8;
      //--- Row bounds + cursor positions
      int rowL_, rowT_, rowR_, rowB_;
      GetRowRect(rowSlot, rowL_, rowT_, rowR_, rowB_);
      const int contLeftX = rowL_ + 6;
      const int contMidYW = (rowT_ + rowB_) / 2;
      //--- Read all 5 sub-property current values from the engine
      bool   isVisible = true;
      double curValue  = 0.0;
      color  curColor  = clrBlack;
      int    curWidth  = 2;
      int    curStyle  = 0;
      if(StringLen(prop.subVisibleId) > 0)
         GetObjectProperty(m_settingsOwnerObjectId, prop.subVisibleId, isVisible);
      if(StringLen(prop.subValueId) > 0)
         GetObjectProperty(m_settingsOwnerObjectId, prop.subValueId, curValue);
      if(StringLen(prop.subColorId) > 0)
         GetObjectProperty(m_settingsOwnerObjectId, prop.subColorId, curColor);
      if(StringLen(prop.subWidthId) > 0)
         GetObjectProperty(m_settingsOwnerObjectId, prop.subWidthId, curWidth);
      if(StringLen(prop.subStyleId) > 0)
         GetObjectProperty(m_settingsOwnerObjectId, prop.subStyleId, curStyle);
      //--- Left-to-right cursor + shared style colors
      int x = contLeftX;
      const uint borderArgbC = ColorToARGB(m_themeColors.separatorColor, 255);
      const uint fillArgbC   = ColorToARGB(m_themeColors.flyoutBackground, 255);
      const uint glyphArgbC  = ColorToARGB(m_themeColors.flyoutTextColor, 230);
      //--- 1. Checkbox.
      if(StringLen(prop.subVisibleId) > 0)
        {
         //--- Empty checkbox base (always painted)
         const int chkT = contMidYW - chkSize / 2;
         WidgetStrokeRoundRect(m_canvasSettings,
                                 boxL + x, boxT + chkT,
                                 boxL + x + chkSize, boxT + chkT + chkSize,
                                 4, 1, borderArgbC, fillArgbC);
         //--- Hover state for the checkbox (sub-button key 1)
         const bool hovChk = (m_compactHoveredSubRow == rowSlot
                              && m_compactHoveredSubButton == 1);
         if(isVisible)
           {
            //--- Visible state: DodgerBlue interior + white tick
            const uint blueArgb = ColorToARGB(clrDodgerBlue, 255);
            FillNoteRoundRect(m_canvasSettings,
                                boxL + x + 2, boxT + chkT + 2,
                                boxL + x + chkSize - 2, boxT + chkT + chkSize - 2,
                                2, blueArgb);
            //--- Tick = 2 thick AA strokes forming a checkmark
            const uint tickArgb = ColorToARGB(clrWhite, 255);
            const int tx0 = boxL + x + chkSize / 4;
            const int ty0 = boxT + chkT + chkSize / 2;
            const int tx1 = boxL + x + chkSize * 4 / 10;
            const int ty1 = boxT + chkT + chkSize * 7 / 10;
            const int tx2 = boxL + x + chkSize * 3 / 4;
            const int ty2 = boxT + chkT + chkSize / 4 + 1;
            WidgetThickLineAA(m_canvasSettings, tx0, ty0, tx1, ty1, 2, tickArgb);
            WidgetThickLineAA(m_canvasSettings, tx1, ty1, tx2, ty2, 2, tickArgb);
           }
         if(hovChk)
           {
            //--- Subtle hover tint overlay
            const uint hovArgb = ColorToARGB(m_themeColors.flyoutTextColor, 35);
            FillNoteRoundRect(m_canvasSettings,
                                boxL + x + 1, boxT + chkT + 1,
                                boxL + x + chkSize - 1, boxT + chkT + chkSize - 1,
                                3, hovArgb);
           }
         //--- Advance cursor past the checkbox + gap
         x += chkSize + gap;
        }
      //--- 2. Value stepper.
      if(StringLen(prop.subValueId) > 0)
        {
         //--- Value button outline + fill
         const int btnT = contMidYW - btnH / 2;
         WidgetStrokeRoundRect(m_canvasSettings,
                                 boxL + x, boxT + btnT,
                                 boxL + x + valW, boxT + btnT + btnH,
                                 4, 1, borderArgbC, fillArgbC);
         //--- Check if THIS value button is in edit mode
         const bool isThisFloatEdit = IsEditingFloat() && m_floatEditPropId == prop.subValueId;
         const bool hovValBtn = (m_compactHoveredSubRow == rowSlot
                                 && m_compactHoveredSubButton == 2);
         //--- Hover tint (not when editing - the focus border replaces it)
         if(hovValBtn && !isThisFloatEdit)
           {
            const uint hovArgb = ColorToARGB(m_themeColors.flyoutTextColor, 30);
            FillNoteRoundRect(m_canvasSettings,
                                boxL + x + 1, boxT + btnT + 1,
                                boxL + x + valW - 1, boxT + btnT + btnH - 1,
                                3, hovArgb);
           }
         if(isThisFloatEdit)
           {
            //--- Focus state: replace border with DodgerBlue accent
            const uint focusArgb = ColorToARGB(clrDodgerBlue, 255);
            WidgetStrokeRoundRect(m_canvasSettings,
                                    boxL + x + 1, boxT + btnT + 1,
                                    boxL + x + valW - 1, boxT + btnT + btnH - 1,
                                    3, 1, focusArgb, fillArgbC);
           }
         //--- Value text: edit buffer if editing, formatted value otherwise
         m_canvasSettings.FontSet("Arial", -100);
         string valStr;
         if(isThisFloatEdit) valStr = m_floatEditBuffer;
         else valStr = DoubleToString(curValue, prop.decimals);
         const int textY = boxT + btnT + (btnH - m_canvasSettings.TextHeight(valStr)) / 2;
         const int textX = boxL + x + 6;
         //--- Render text selection highlight when there's an active selection range
         if(isThisFloatEdit && m_floatSelectionAnchor >= 0
            && m_floatSelectionAnchor != m_floatEditCaretPos)
           {
            //--- Normalize selection bounds + measure pre/in widths
            const int selS = (m_floatSelectionAnchor < m_floatEditCaretPos)
                             ? m_floatSelectionAnchor : m_floatEditCaretPos;
            const int selE = (m_floatSelectionAnchor > m_floatEditCaretPos)
                             ? m_floatSelectionAnchor : m_floatEditCaretPos;
            const string preSel = StringSubstr(m_floatEditBuffer, 0, selS);
            const string inSel  = StringSubstr(m_floatEditBuffer, selS, selE - selS);
            const int preW = (StringLen(preSel) > 0) ? m_canvasSettings.TextWidth(preSel) : 0;
            const int selW = (StringLen(inSel) > 0)  ? m_canvasSettings.TextWidth(inSel)  : 0;
            //--- Paint the selection highlight
            const uint selArgb = ColorToARGB(clrDodgerBlue, 90);
            const int rectL = textX + preW; const int rectR = rectL + selW;
            const int rectT = boxT + btnT + 3; const int rectB = boxT + btnT + btnH - 3;
            for(int yy = rectT; yy < rectB; yy++)
               for(int xx = rectL; xx < rectR; xx++)
                  WidgetBlendPixel(m_canvasSettings, xx, yy, selArgb);
           }
         //--- Draw the text on top
         m_canvasSettings.TextOut(textX, textY, valStr, glyphArgbC);
         //--- Caret: blinking thin AA line at caret column
         if(isThisFloatEdit && m_floatEditCaretBlinkOn)
           {
            const string seg = StringSubstr(m_floatEditBuffer, 0, m_floatEditCaretPos);
            const int caretX = textX + m_canvasSettings.TextWidth(seg);
            const int caretY1 = boxT + btnT + 4; const int caretY2 = boxT + btnT + btnH - 4;
            const uint caretArgb = ColorToARGB(m_themeColors.flyoutTextColor, 255);
            WidgetThickLineAA(m_canvasSettings, caretX, caretY1, caretX, caretY2, 1, caretArgb);
           }
         //--- Steppers visible when hovered or while editing
         const bool showChev = (m_compactHoveredRow == rowSlot) || isThisFloatEdit;
         if(showChev)
           {
            //--- Two stepper directions: 0 = up, 1 = down
            for(int dir = 0; dir <= 1; dir++)
              {
               int sL, sT, sR, sB;
               if(!GetCompactStepperRect(rowSlot, dir, sL, sT, sR, sB)) continue;
               //--- Hover state for this stepper (key 1 = up, key 2 = down)
               const int stepperKey = (dir == 0) ? 1 : 2;
               const bool stepHov = (m_compactHoveredRow == rowSlot
                                     && m_compactHoveredStepper == stepperKey);
               if(stepHov)
                 {
                  //--- Subtle hover background behind the stepper
                  const uint stepBgArgb = ColorToARGB(m_themeColors.flyoutTextColor, 45);
                  FillNoteRoundRect(m_canvasSettings,
                                      boxL + sL, boxT + sT,
                                      boxL + sR, boxT + sB,
                                      2, stepBgArgb);
                 }
               //--- Chevron glyph (up or down)
               const int cx = boxL + (sL + sR) / 2;
               const int cy = boxT + (sT + sB) / 2;
               const uint chevArgb = ColorToARGB(m_themeColors.flyoutTextColor, 230);
               if(dir == 0)
                 { WidgetThickLineAA(m_canvasSettings, cx-3,cy+1,cx,cy-1,2,chevArgb);
                   WidgetThickLineAA(m_canvasSettings, cx,cy-1,cx+3,cy+1,2,chevArgb); }
               else
                 { WidgetThickLineAA(m_canvasSettings, cx-3,cy-1,cx,cy+1,2,chevArgb);
                   WidgetThickLineAA(m_canvasSettings, cx,cy+1,cx+3,cy-1,2,chevArgb); }
              }
           }
         //--- Advance cursor past the value button + gap
         x += valW + gap;
        }
      //--- 3. Color cube.
      if(StringLen(prop.subColorId) > 0)
        {
         //--- Color cube outline (DodgerBlue when popover is open for this sub-color)
         const int btnT = contMidYW - btnH / 2;
         const bool isPop = (m_isPopoverVisible && m_activePopoverPropId == prop.subColorId);
         const uint thisBorder = isPop ? ColorToARGB(clrDodgerBlue,255) : borderArgbC;
         WidgetStrokeRoundRect(m_canvasSettings,
                                 boxL + x, boxT + btnT,
                                 boxL + x + colW, boxT + btnT + btnH,
                                 4, 1, thisBorder, fillArgbC);
         //--- 16x16 swatch centered inside the cube
         const int sqSize = 16;
         const int sqL = boxL + x + (colW - sqSize) / 2;
         const int sqT = boxT + btnT + (btnH - sqSize) / 2;
         //--- Transparency-checker backdrop + active color overlay at opacity
         WidgetCheckerFillRect(m_canvasSettings, sqL, sqT, sqL + sqSize, sqT + sqSize, 3);
         int subOpacity = 100;
         GetObjectProperty(m_settingsOwnerObjectId,
                            ColorToOpacityProp(prop.subColorId), subOpacity);
         const uint overlayArgb = ColorWithPercentOpacity(curColor, subOpacity);
         for(int yy = sqT; yy < sqT + sqSize; yy++)
            for(int xx = sqL; xx < sqL + sqSize; xx++)
               WidgetBlendPixel(m_canvasSettings, xx, yy, overlayArgb);
         //--- Hover tint when not actively popping
         const bool hovColCube = (m_compactHoveredSubRow == rowSlot
                                  && m_compactHoveredSubButton == 3);
         if(hovColCube && !isPop)
           {
            const uint hovArgb = ColorToARGB(m_themeColors.flyoutTextColor, 30);
            FillNoteRoundRect(m_canvasSettings,
                                boxL + x + 1, boxT + btnT + 1,
                                boxL + x + colW - 1, boxT + btnT + btnH - 1,
                                3, hovArgb);
           }
         //--- Advance cursor
         x += colW + gap;
        }
      //--- 4. Width cube.
      if(StringLen(prop.subWidthId) > 0)
        {
         //--- Width cube outline (DodgerBlue when popover is open for this sub-width)
         const int btnT = contMidYW - btnH / 2;
         const bool isPop = (m_isPopoverVisible && m_activePopoverPropId == prop.subWidthId);
         const uint thisBorder = isPop ? ColorToARGB(clrDodgerBlue,255) : borderArgbC;
         WidgetStrokeRoundRect(m_canvasSettings,
                                 boxL + x, boxT + btnT,
                                 boxL + x + wW, boxT + btnT + btnH,
                                 4, 1, thisBorder, fillArgbC);
         //--- Stroke preview inside the cube (solid style, current width)
         const int sLp = boxL + x + 6; const int sRp = boxL + x + wW - 6;
         const int sYp = boxT + btnT + btnH / 2;
         StrokeLinePreview(m_canvasSettings, sLp, sYp, sRp, sYp, curWidth, 0, glyphArgbC);
         //--- Hover tint
         const bool hovWidCube = (m_compactHoveredSubRow == rowSlot
                                  && m_compactHoveredSubButton == 4);
         if(hovWidCube && !isPop)
           {
            const uint hovArgb = ColorToARGB(m_themeColors.flyoutTextColor, 30);
            FillNoteRoundRect(m_canvasSettings,
                                boxL + x + 1, boxT + btnT + 1,
                                boxL + x + wW - 1, boxT + btnT + btnH - 1,
                                3, hovArgb);
           }
         //--- Advance cursor
         x += wW + gap;
        }
      //--- 5. Style cube.
      if(StringLen(prop.subStyleId) > 0)
        {
         //--- Style cube outline (DodgerBlue when popover is open for this sub-style)
         const int btnT = contMidYW - btnH / 2;
         const bool isPop = (m_isPopoverVisible && m_activePopoverPropId == prop.subStyleId);
         const uint thisBorder = isPop ? ColorToARGB(clrDodgerBlue,255) : borderArgbC;
         WidgetStrokeRoundRect(m_canvasSettings,
                                 boxL + x, boxT + btnT,
                                 boxL + x + sW, boxT + btnT + btnH,
                                 4, 1, thisBorder, fillArgbC);
         //--- Stroke preview at current width + current style
         const int sLp = boxL + x + 6; const int sRp = boxL + x + sW - 6;
         const int sYp = boxT + btnT + btnH / 2;
         StrokeLinePreview(m_canvasSettings, sLp, sYp, sRp, sYp, curWidth, curStyle, glyphArgbC);
         //--- Hover tint
         const bool hovStyCube = (m_compactHoveredSubRow == rowSlot
                                  && m_compactHoveredSubButton == 5);
         if(hovStyCube && !isPop)
           {
            const uint hovArgb = ColorToARGB(m_themeColors.flyoutTextColor, 30);
            FillNoteRoundRect(m_canvasSettings,
                                boxL + x + 1, boxT + btnT + 1,
                                boxL + x + sW - 1, boxT + btnT + btnH - 1,
                                3, hovArgb);
           }
        }
     }
  }

//+------------------------------------------------------------------+
//| Text-tab layout rect helpers (per-control bounds in window space)|
//+------------------------------------------------------------------+
void CSettingsWindow::GetTextTabColorRect(int &outL, int &outT, int &outR, int &outB)
  {
   //--- 28x24 color chip at the left of row 1
   const int rowsTop = m_settingsHeaderH + m_settingsTabBarH;
   outL = m_settingsPadX; outR = outL + 28;
   outT = rowsTop + (32 - 24) / 2; outB = outT + 24;
  }
void CSettingsWindow::GetTextTabFontSizeRect(int &outL, int &outT, int &outR, int &outB)
  {
   //--- 60x24 font-size dropdown, right of the color chip
   int cL, cT, cR, cB; GetTextTabColorRect(cL, cT, cR, cB);
   outL = cR + 6; outR = outL + 60; outT = cT; outB = cB;
  }
void CSettingsWindow::GetTextTabBoldRect(int &outL, int &outT, int &outR, int &outB)
  {
   //--- 28x24 bold toggle, right of the font-size dropdown
   int fL, fT, fR, fB; GetTextTabFontSizeRect(fL, fT, fR, fB);
   outL = fR + 6; outR = outL + 28; outT = fT; outB = fB;
  }
void CSettingsWindow::GetTextTabTextInputRect(int &outL, int &outT, int &outR, int &outB)
  {
   //--- Full-width 90-px tall multi-line text area (row 2)
   const int rowsTop = m_settingsHeaderH + m_settingsTabBarH;
   const int row2Top = rowsTop + 32 + 8;
   outL = m_settingsPadX; outR = m_settingsWidth - m_settingsPadX;
   outT = row2Top; outB = outT + 90;
  }
void CSettingsWindow::GetTextTabVAlignRect(int &outL, int &outT, int &outR, int &outB)
  {
   //--- 80x24 vAlign dropdown (right side of row 3, just left of hAlign)
   const int rowsTop = m_settingsHeaderH + m_settingsTabBarH;
   const int row3Top = rowsTop + 32 + 8 + 90 + 8;
   const int btnW = 80, gap = 6;
   const int rightX = m_settingsWidth - m_settingsPadX;
   outR = rightX - btnW - gap; outL = outR - btnW;
   outT = row3Top + (32 - 24) / 2; outB = outT + 24;
  }
void CSettingsWindow::GetTextTabHAlignRect(int &outL, int &outT, int &outR, int &outB)
  {
   //--- 80x24 hAlign dropdown (rightmost on row 3)
   const int rowsTop = m_settingsHeaderH + m_settingsTabBarH;
   const int row3Top = rowsTop + 32 + 8 + 90 + 8;
   const int btnW = 80;
   const int rightX = m_settingsWidth - m_settingsPadX;
   outR = rightX; outL = outR - btnW;
   outT = row3Top + (32 - 24) / 2; outB = outT + 24;
  }

//+------------------------------------------------------------------+
//| Hit-test Text-tab controls (returns control id; 0 = miss)        |
//+------------------------------------------------------------------+
int CSettingsWindow::HitTestTextTabControl(int lx, int ly)
  {
   //--- Color chip (always present on Text tab)
   int rL, rT, rR, rB;
   GetTextTabColorRect(rL, rT, rR, rB);
   if(lx >= rL && lx < rR && ly >= rT && ly < rB) return 1;
   //--- font-size, bold, text, vAlign, hAlign hit-tests are gated by property registration
   if(HasRegisteredProperty("fontSize"))
     { GetTextTabFontSizeRect(rL, rT, rR, rB);
       if(lx >= rL && lx < rR && ly >= rT && ly < rB) return 2; }
   if(HasRegisteredProperty("bold"))
     { GetTextTabBoldRect(rL, rT, rR, rB);
       if(lx >= rL && lx < rR && ly >= rT && ly < rB) return 3; }
   if(HasRegisteredProperty("text"))
     { GetTextTabTextInputRect(rL, rT, rR, rB);
       if(lx >= rL && lx < rR && ly >= rT && ly < rB) return 5; }
   if(HasRegisteredProperty("vAlign"))
     { GetTextTabVAlignRect(rL, rT, rR, rB);
       if(lx >= rL && lx < rR && ly >= rT && ly < rB) return 6; }
   if(HasRegisteredProperty("hAlign"))
     { GetTextTabHAlignRect(rL, rT, rR, rB);
       if(lx >= rL && lx < rR && ly >= rT && ly < rB) return 7; }
   return 0;
  }

//+------------------------------------------------------------------+
//| DrawTextTabRows - full custom render for the Text tab            |
//+------------------------------------------------------------------+
void CSettingsWindow::DrawTextTabRows()
  {
   //--- Canvas-space top-left + bound object id
   const int boxL = m_settingsShadowPad;
   const int boxT = m_settingsShadowPad;
   const int objId = m_settingsOwnerObjectId;

   //--- Read all live text-property values from the engine
   color  textColor   = clrBlack;
   int    textOpacity = 100;
   int    curFontSize = 11;
   bool   curBold     = false;
   int    curVAlign   = 0;
   int    curHAlign   = 1;
   string curText     = "";
   GetObjectProperty(objId, "textColor",   textColor);
   GetObjectProperty(objId, "textOpacity", textOpacity);
   GetObjectProperty(objId, "fontSize",    curFontSize);
   GetObjectProperty(objId, "bold",        curBold);
   GetObjectProperty(objId, "vAlign",      curVAlign);
   GetObjectProperty(objId, "hAlign",      curHAlign);
   GetObjectProperty(objId, "text",        curText);

   //--- Cache active-popover flags for each dropdown (for border color + chevron direction)
   const bool fontSizePopActive = (m_isPopoverVisible && m_activePopoverPropId == "fontSize");
   const bool vAlignPopActive   = (m_isPopoverVisible && m_activePopoverPropId == "vAlign");
   const bool hAlignPopActive   = (m_isPopoverVisible && m_activePopoverPropId == "hAlign");

   //--- Row 1 - color chip.
     {
      //--- Color chip rect + state flags
      int cL, cT, cR, cB;
      GetTextTabColorRect(cL, cT, cR, cB);
      const bool isHov  = (m_hoveredTextTabCtrl == 1);
      const bool isPop  = (m_isPopoverVisible && m_activePopoverPropId == "textColor");
      //--- Border = DodgerBlue when popover open, separator otherwise
      const uint borderArgb = isPop
         ? ColorToARGB(clrDodgerBlue, 255)
         : ColorToARGB(m_themeColors.separatorColor, 255);
      WidgetStrokeRoundRect(m_canvasSettings,
                              boxL + cL, boxT + cT, boxL + cR, boxT + cB,
                              4, 1, borderArgb,
                              ColorToARGB(m_themeColors.flyoutBackground, 255));
      //--- 16x16 transparency-checker backdrop + color overlay at opacity
      const int sqSize = 16;
      const int sqL = boxL + cL + (cR - cL - sqSize) / 2;
      const int sqT = boxT + cT + (cB - cT - sqSize) / 2;
      WidgetCheckerFillRect(m_canvasSettings, sqL, sqT, sqL + sqSize, sqT + sqSize, 3);
      const uint overlayArgb = ColorWithPercentOpacity(textColor, textOpacity);
      for(int yy = sqT; yy < sqT + sqSize; yy++)
         for(int xx = sqL; xx < sqL + sqSize; xx++)
            WidgetBlendPixel(m_canvasSettings, xx, yy, overlayArgb);
      //--- Hover tint when not actively popping
      if(isHov && !isPop)
        {
         const uint tintArgb = ColorToARGB(m_themeColors.flyoutTextColor, 30);
         FillNoteRoundRect(m_canvasSettings,
                             boxL + cL + 1, boxT + cT + 1,
                             boxL + cR - 1, boxT + cB - 1,
                             3, tintArgb);
        }
     }

   //--- Row 1 - font-size button.
   if(HasRegisteredProperty("fontSize"))
     {
      //--- Font-size button rect + state
      int fL, fT, fR, fB;
      GetTextTabFontSizeRect(fL, fT, fR, fB);
      const bool isHov = (m_hoveredTextTabCtrl == 2);
      const uint borderArgb = fontSizePopActive
         ? ColorToARGB(clrDodgerBlue, 255)
         : ColorToARGB(m_themeColors.separatorColor, 255);
      WidgetStrokeRoundRect(m_canvasSettings,
                              boxL + fL, boxT + fT, boxL + fR, boxT + fB,
                              4, 1, borderArgb,
                              ColorToARGB(m_themeColors.flyoutBackground, 255));
      //--- Hover tint when not actively popping
      if(isHov && !fontSizePopActive)
        {
         const uint tintArgb = ColorToARGB(m_themeColors.flyoutTextColor, 30);
         FillNoteRoundRect(m_canvasSettings,
                             boxL + fL + 1, boxT + fT + 1,
                             boxL + fR - 1, boxT + fB - 1,
                             3, tintArgb);
        }
      //--- Font-size label (current value)
      m_canvasSettings.FontSet("Arial", -100);
      const string lbl = IntegerToString(curFontSize);
      const int lLH = m_canvasSettings.TextHeight(lbl);
      m_canvasSettings.TextOut(boxL + fL + 8,
                                 boxT + fT + (fB - fT - lLH) / 2,
                                 lbl,
                                 ColorToARGB(m_themeColors.flyoutTextColor, 230));
      //--- Right-side chevron (up when popover open, down when closed)
      const int chCx = boxL + fR - 10;
      const int chCy = boxT + fT + (fB - fT) / 2;
      const uint chevArgb = ColorToARGB(m_themeColors.flyoutTextColor, 230);
      if(fontSizePopActive)
        {
         //--- Up chevron (popover open)
         WidgetThickLineAA(m_canvasSettings, chCx-4,chCy+2,chCx,chCy-2,2,chevArgb);
         WidgetThickLineAA(m_canvasSettings, chCx,chCy-2,chCx+4,chCy+2,2,chevArgb);
        }
      else
        {
         //--- Down chevron (popover closed)
         WidgetThickLineAA(m_canvasSettings, chCx-4,chCy-2,chCx,chCy+2,2,chevArgb);
         WidgetThickLineAA(m_canvasSettings, chCx,chCy+2,chCx+4,chCy-2,2,chevArgb);
        }
     }

   //--- Row 1 - Bold toggle.
   if(HasRegisteredProperty("bold"))
     {
      //--- Bold toggle rect + state
      int bL, bT, bR, bB;
      GetTextTabBoldRect(bL, bT, bR, bB);
      const bool isHov = (m_hoveredTextTabCtrl == 3);
      //--- Border + fill colors invert based on the bold state (filled when bold = true)
      const uint borderArgb = ColorToARGB(curBold
                                            ? m_themeColors.flyoutTextColor
                                            : m_themeColors.separatorColor, 255);
      const uint fillArgb   = ColorToARGB(curBold
                                            ? m_themeColors.flyoutTextColor
                                            : m_themeColors.flyoutBackground, 255);
      WidgetStrokeRoundRect(m_canvasSettings,
                              boxL + bL, boxT + bT, boxL + bR, boxT + bB,
                              4, 1, borderArgb, fillArgb);
      //--- Hover tint (color inverts based on the bold state)
      if(isHov)
        {
         const uint tintArgb = ColorToARGB(curBold
                                             ? m_themeColors.flyoutBackground
                                             : m_themeColors.flyoutTextColor, 30);
         FillNoteRoundRect(m_canvasSettings,
                             boxL + bL + 1, boxT + bT + 1,
                             boxL + bR - 1, boxT + bB - 1,
                             3, tintArgb);
        }
      //--- "B" label centered (text color inverts with the toggle state)
      m_canvasSettings.FontSet("Arial Bold", -110);
      const string lbl = "B";
      const int lLW = m_canvasSettings.TextWidth(lbl);
      const int lLH = m_canvasSettings.TextHeight(lbl);
      const color labelCol = curBold ? m_themeColors.flyoutBackground
                                       : m_themeColors.flyoutTextColor;
      m_canvasSettings.TextOut(boxL + bL + (bR - bL - lLW) / 2,
                                 boxT + bT + (bB - bT - lLH) / 2,
                                 lbl, ColorToARGB(labelCol, 255));
     }

   //--- Row 2 - multi-line text area.
   if(HasRegisteredProperty("text"))
     {
      //--- Text-area rect + border state
      int tL, tT, tR, tB;
      GetTextTabTextInputRect(tL, tT, tR, tB);

      //--- Border colors (DodgerBlue focus border when focused, separator otherwise)
      const uint focusArgb  = ColorToARGB(clrDodgerBlue, 255);
      const uint normalArgb = ColorToARGB(m_themeColors.separatorColor, 255);
      const uint fillArgb   = ColorToARGB(m_themeColors.flyoutBackground, 255);
      WidgetStrokeRoundRect(m_canvasSettings,
                              boxL + tL, boxT + tT, boxL + tR, boxT + tB,
                              5, 1,
                              m_textAreaFocused ? focusArgb : normalArgb,
                              fillArgb);
      //--- Focused state: paint a second inner border for emphasis
      if(m_textAreaFocused)
        {
         WidgetStrokeRoundRect(m_canvasSettings,
                                 boxL + tL + 1, boxT + tT + 1,
                                 boxL + tR - 1, boxT + tB - 1,
                                 4, 1, focusArgb, fillArgb);
        }

      //--- Source text: live edit buffer if focused (engine label edit), saved value otherwise
      string sourceText;
      int    caretPos;
      if(m_textAreaFocused && m_isEditingLabel)
        { sourceText = m_labelEditBuffer; caretPos = m_labelCaretPos; }
      else
        { sourceText = curText; caretPos = 0; }

      //--- Empty + unfocused = show "Add text" placeholder
      const bool isEmpty       = (StringLen(sourceText) == 0);
      const bool showPlaceholder = isEmpty && !m_textAreaFocused;
      //--- Layout: 8 px inset + scrollbar at the right (6 px wide + 4 px gap)
      const int padIn = 8, sbW = 6, sbGap = 4;
      //--- Cache the content rect so other functions (hit-test, scrollbar) can find it
      m_taContentL = boxL + tL + padIn;
      m_taContentT = boxT + tT + padIn;
      m_taContentR = boxL + tR - padIn - sbW - sbGap;
      m_taContentB = boxT + tB - padIn;
      const int contentW  = m_taContentR - m_taContentL;
      const int viewportH = m_taContentB - m_taContentT;
      //--- Skip rendering when the content area is too narrow to be useful
      if(contentW >= 20)
        {
         //--- Wrap the source (or placeholder) text into lines for measurement
         string lines[]; int bufOffsets[];
         int measMaxW = 0, measBlockH = 0, measLineH = 0;
         string measureText = showPlaceholder ? "Add text" : sourceText;
         ComputeWrappedLayout(measureText, "Arial", 10, contentW,
                               lines, bufOffsets, measMaxW, measBlockH, measLineH);
         //--- Cache line metrics for scrolling math
         m_taLineH = (measLineH > 0) ? measLineH : 12;
         const int nLines = ArraySize(lines);
         m_taTotalContentH = nLines * m_taLineH;
         //--- Max scroll = total content - viewport
         m_taMaxScrollPx = MathMax(0, m_taTotalContentH - viewportH);
         if(m_textAreaScrollPx > m_taMaxScrollPx) m_textAreaScrollPx = m_taMaxScrollPx;
         if(m_textAreaScrollPx < 0)               m_textAreaScrollPx = 0;

         //--- Caret line/column tracking for selection + auto-scroll
         int caretLineIdx = 0, caretColX = 0;
         if(m_textAreaFocused && !showPlaceholder)
           {
            //--- Find the wrap-line containing the caret position (scan top-down from last line)
            for(int li = nLines - 1; li >= 0; li--)
              {
               const int lineStart     = bufOffsets[li];
               const int lineCharCount = StringLen(lines[li]);
               if(caretPos >= lineStart && caretPos <= lineStart + lineCharCount)
                 {
                  caretLineIdx = li;
                  //--- Caret X = width of the line-prefix up to the caret
                  m_canvasSettings.FontSet("Arial", -100);
                  const string segment = StringSubstr(sourceText, lineStart,
                                                        caretPos - lineStart);
                  caretColX = m_canvasSettings.TextWidth(segment);
                  break;
                 }
              }
            //--- Auto-scroll: if a buffer-change just happened, scroll the caret into view
            if(m_textAreaAutoScrollPending)
              {
               const int caretYInContent = caretLineIdx * m_taLineH;
               //--- Caret above viewport -> scroll up to expose it
               if(caretYInContent < m_textAreaScrollPx)
                  m_textAreaScrollPx = caretYInContent;
               else if(caretYInContent + m_taLineH > m_textAreaScrollPx + viewportH)
                  //--- Caret below viewport -> scroll down to expose it
                  m_textAreaScrollPx = caretYInContent + m_taLineH - viewportH;
               //--- Clamp + clear the auto-scroll flag
               if(m_textAreaScrollPx > m_taMaxScrollPx) m_textAreaScrollPx = m_taMaxScrollPx;
               if(m_textAreaScrollPx < 0)               m_textAreaScrollPx = 0;
               m_textAreaAutoScrollPending = false;
              }
           }

         //--- Render text into a temporary canvas (so we can clip the blit to the content rect)
         const int taCanvasW = m_canvasSettings.Width();
         const int taCanvasH = m_canvasSettings.Height();
         CCanvas tmpText;
         tmpText.Create("SettingsTextAreaTmp", taCanvasW, taCanvasH,
                          COLOR_FORMAT_ARGB_NORMALIZE);
         tmpText.Erase(0x00000000);
         //--- Copy the content rect from the main canvas into the temp (preserves the border)
         for(int yy = m_taContentT; yy < m_taContentB; yy++)
           {
            if(yy < 0 || yy >= taCanvasH) continue;
            for(int xx = m_taContentL; xx < m_taContentR; xx++)
              {
               if(xx < 0 || xx >= taCanvasW) continue;
               tmpText.PixelSet(xx, yy, m_canvasSettings.PixelGet(xx, yy));
              }
           }
         //--- Configure temp canvas font + text color (lighter when showing placeholder)
         tmpText.FontSet("Arial", -100);
         const uchar dispA = showPlaceholder ? (uchar)110 : (uchar)230;

         //--- Render text selection (light DodgerBlue highlight behind selected chars)
         int selS = 0, selE = 0;
         const bool hasSel = m_textAreaFocused && !showPlaceholder
                            && GetLabelSelectionRange(selS, selE);
         if(hasSel)
           {
            //--- For each wrap-line: clip the selection range to this line's bounds + measure + paint
            const uint selArgb = ColorToARGB(clrDodgerBlue, 90);
            for(int liS = 0; liS < nLines; liS++)
              {
               const int lineStart = bufOffsets[liS];
               const int lineLen   = StringLen(lines[liS]);
               const int lineEnd   = lineStart + lineLen;
               const int subS = (selS > lineStart) ? selS : lineStart;
               const int subE = (selE < lineEnd)   ? selE : lineEnd;
               if(subE <= subS) continue;
               //--- Measure the preSelection + inSelection widths for this line
               tmpText.FontSet("Arial", -100);
               const string preSel = StringSubstr(sourceText, lineStart, subS - lineStart);
               const string inSel  = StringSubstr(sourceText, subS, subE - subS);
               const int preW = (StringLen(preSel) > 0) ? tmpText.TextWidth(preSel) : 0;
               const int selW = (StringLen(inSel) > 0)  ? tmpText.TextWidth(inSel)  : 0;
               //--- Add a tiny "sliver" when the selection includes a trailing newline (so users see the line break is selected)
               const bool includesTrailingNewline =
                  (selE > lineEnd && lineEnd < StringLen(sourceText)
                   && StringGetCharacter(sourceText, lineEnd) == '\n');
               const int sliverW = includesTrailingNewline ? 4 : 0;
               //--- Selection rect for this line (offset by current scroll)
               const int rectL = m_taContentL + preW;
               const int rectR = rectL + selW + sliverW;
               const int rectT = m_taContentT + liS * m_taLineH - m_textAreaScrollPx;
               const int rectB = rectT + m_taLineH;
               //--- Skip lines fully outside the viewport
               if(rectB <= m_taContentT || rectT >= m_taContentB) continue;
               //--- Blend the highlight onto the temp canvas
               for(int yy = rectT; yy < rectB; yy++)
                  for(int xx = rectL; xx < rectR; xx++)
                     WidgetBlendPixel(tmpText, xx, yy, selArgb);
              }
           }

         //--- Render each wrap-line of text (skip lines fully outside the viewport)
         for(int li2 = 0; li2 < nLines; li2++)
           {
            const int lineY = m_taContentT + li2 * m_taLineH - m_textAreaScrollPx;
            if(lineY + m_taLineH < m_taContentT) continue;
            if(lineY > m_taContentB) break;
            tmpText.TextOut(m_taContentL, lineY, lines[li2],
                             ColorToARGB(m_themeColors.flyoutTextColor, dispA));
           }

         //--- Render caret (blinking thin AA line) when focused
         if(m_textAreaFocused && m_textAreaCaretBlinkOn && !showPlaceholder)
           {
            const int caretY1 = m_taContentT + caretLineIdx * m_taLineH - m_textAreaScrollPx;
            const int caretY2 = caretY1 + m_taLineH - 2;
            const int caretX  = m_taContentL + caretColX;
            const uint caretArgb = ColorToARGB(m_themeColors.flyoutTextColor, 255);
            WidgetThickLineAA(tmpText, caretX, caretY1, caretX, caretY2, 1, caretArgb);
           }

         //--- Blit the temp canvas content rect back to the main canvas (clamped to canvas bounds)
         const int blitL = MathMax(m_taContentL, 0);
         const int blitT = MathMax(m_taContentT, 0);
         const int blitR = MathMin(m_taContentR, taCanvasW);
         const int blitB = MathMin(m_taContentB, taCanvasH);
         for(int yy = blitT; yy < blitB; yy++)
            for(int xx = blitL; xx < blitR; xx++)
               m_canvasSettings.PixelSet(xx, yy, tmpText.PixelGet(xx, yy));
         tmpText.Destroy();

         //--- Render the text-area's own scrollbar when content overflows
         if(m_taMaxScrollPx > 0)
           {
            //--- Track sits to the right of the content rect; thumb sizing matches the body scrollbar pattern
            const int trackL = boxL + tR - padIn - sbW;
            const int trackT = m_taContentT;
            const int trackR = trackL + sbW;
            const int trackB = m_taContentB;
            const int trackH = trackB - trackT;
            //--- Thumb height = (viewport/total)*track, clamped to a min of 20 px
            int thumbH = (int)((double)trackH * (double)viewportH
                                 / (double)m_taTotalContentH);
            if(thumbH < 20) thumbH = 20;
            if(thumbH > trackH) thumbH = trackH;
            //--- Thumb Y = track top + (scroll fraction * available travel)
            const int thumbY = trackT + (int)((double)(trackH - thumbH)
                                                 * (double)m_textAreaScrollPx
                                                 / (double)m_taMaxScrollPx);
            //--- Pill color reflects 3 states (drag > hover > idle), same pattern as the body scrollbar
            color   pillCol;
            uchar   pillA;
            if(m_textAreaThumbDragging)
              { pillCol = m_themeColors.accentBarColor;        pillA = 255; }
            else if(m_hoveredTextAreaScrollbar)
              { pillCol = m_themeColors.scrollArrowHoverColor; pillA = 255; }
            else
              { pillCol = m_themeColors.scrollArrowColor;      pillA = 180; }
            //--- Paint the thumb as a rounded rect
            const uint pillArgb = ColorToARGB(pillCol, pillA);
            FillNoteRoundRect(m_canvasSettings,
                                trackL, thumbY, trackR, thumbY + thumbH,
                                3, pillArgb);
           }
        }
     }

   //--- Row 3 alignment label + vAlign/hAlign dropdowns (only when at least one alignment property is registered)
   const bool showAlignmentRow = HasRegisteredProperty("vAlign")
                                  || HasRegisteredProperty("hAlign");
   if(showAlignmentRow)
     {
      //--- "Text alignment" label on the left of row 3
      const int rowsTop = m_settingsHeaderH + m_settingsTabBarH;
      const int row3Top = rowsTop + 32 + 8 + 90 + 8;
      m_canvasSettings.FontSet("Arial", -100);
      const string lbl = "Text alignment";
      const int lLH = m_canvasSettings.TextHeight(lbl);
      m_canvasSettings.TextOut(boxL + m_settingsPadX,
                                 boxT + row3Top + (32 - lLH) / 2,
                                 lbl,
                                 ColorToARGB(m_themeColors.flyoutTextColor, 220));
     }

   //--- vAlign dropdown (mirrors the font-size dropdown styling)
   if(HasRegisteredProperty("vAlign"))
     {
      //--- vAlign button rect + state
      int vL, vT, vR, vB;
      GetTextTabVAlignRect(vL, vT, vR, vB);
      const bool isHov = (m_hoveredTextTabCtrl == 6);
      const uint borderArgb = vAlignPopActive
         ? ColorToARGB(clrDodgerBlue, 255)
         : ColorToARGB(m_themeColors.separatorColor, 255);
      WidgetStrokeRoundRect(m_canvasSettings,
                              boxL + vL, boxT + vT, boxL + vR, boxT + vB,
                              4, 1, borderArgb,
                              ColorToARGB(m_themeColors.flyoutBackground, 255));
      //--- Hover tint when not popping
      if(isHov && !vAlignPopActive)
        {
         const uint tintArgb = ColorToARGB(m_themeColors.flyoutTextColor, 30);
         FillNoteRoundRect(m_canvasSettings,
                             boxL + vL + 1, boxT + vT + 1,
                             boxL + vR - 1, boxT + vB - 1,
                             3, tintArgb);
        }
      //--- Display the current vAlign value ("Top"/"Middle"/"Bottom")
      m_canvasSettings.FontSet("Arial", -100);
      string vNames[3]; vNames[0] = "Top"; vNames[1] = "Middle"; vNames[2] = "Bottom";
      const string vLbl = vNames[curVAlign];
      const int lLH = m_canvasSettings.TextHeight(vLbl);
      m_canvasSettings.TextOut(boxL + vL + 8, boxT + vT + (vB - vT - lLH) / 2,
                                 vLbl, ColorToARGB(m_themeColors.flyoutTextColor, 230));
      //--- Right-side chevron (up when open, down when closed)
      const int chCx = boxL + vR - 10;
      const int chCy = boxT + vT + (vB - vT) / 2;
      const uint chevArgb = ColorToARGB(m_themeColors.flyoutTextColor, 230);
      if(vAlignPopActive)
        { WidgetThickLineAA(m_canvasSettings,chCx-4,chCy+2,chCx,chCy-2,2,chevArgb);
          WidgetThickLineAA(m_canvasSettings,chCx,chCy-2,chCx+4,chCy+2,2,chevArgb); }
      else
        { WidgetThickLineAA(m_canvasSettings,chCx-4,chCy-2,chCx,chCy+2,2,chevArgb);
          WidgetThickLineAA(m_canvasSettings,chCx,chCy+2,chCx+4,chCy-2,2,chevArgb); }
     }

   //--- hAlign dropdown (mirrors vAlign styling)
   if(HasRegisteredProperty("hAlign"))
     {
      //--- hAlign button rect + state
      int hL, hT, hR, hB;
      GetTextTabHAlignRect(hL, hT, hR, hB);
      const bool isHov = (m_hoveredTextTabCtrl == 7);
      const uint borderArgb = hAlignPopActive
         ? ColorToARGB(clrDodgerBlue, 255)
         : ColorToARGB(m_themeColors.separatorColor, 255);
      WidgetStrokeRoundRect(m_canvasSettings,
                              boxL + hL, boxT + hT, boxL + hR, boxT + hB,
                              4, 1, borderArgb,
                              ColorToARGB(m_themeColors.flyoutBackground, 255));
      //--- Hover tint when not popping
      if(isHov && !hAlignPopActive)
        {
         const uint tintArgb = ColorToARGB(m_themeColors.flyoutTextColor, 30);
         FillNoteRoundRect(m_canvasSettings,
                             boxL + hL + 1, boxT + hT + 1,
                             boxL + hR - 1, boxT + hB - 1,
                             3, tintArgb);
        }
      //--- Display the current hAlign value ("Left"/"Center"/"Right")
      m_canvasSettings.FontSet("Arial", -100);
      string hNames[3]; hNames[0] = "Left"; hNames[1] = "Center"; hNames[2] = "Right";
      const string hLbl = hNames[curHAlign];
      const int lLH = m_canvasSettings.TextHeight(hLbl);
      m_canvasSettings.TextOut(boxL + hL + 8, boxT + hT + (hB - hT - lLH) / 2,
                                 hLbl, ColorToARGB(m_themeColors.flyoutTextColor, 230));
      //--- Right-side chevron (up when open, down when closed)
      const int chCx = boxL + hR - 10;
      const int chCy = boxT + hT + (hB - hT) / 2;
      const uint chevArgb = ColorToARGB(m_themeColors.flyoutTextColor, 230);
      if(hAlignPopActive)
        { WidgetThickLineAA(m_canvasSettings,chCx-4,chCy+2,chCx,chCy-2,2,chevArgb);
          WidgetThickLineAA(m_canvasSettings,chCx,chCy-2,chCx+4,chCy+2,2,chevArgb); }
      else
        { WidgetThickLineAA(m_canvasSettings,chCx-4,chCy-2,chCx,chCy+2,2,chevArgb);
          WidgetThickLineAA(m_canvasSettings,chCx,chCy+2,chCx+4,chCy-2,2,chevArgb); }
     }
  }

//+------------------------------------------------------------------+
//| Drop text-area focus (commit any open label edit + clear flags)  |
//+------------------------------------------------------------------+
void CSettingsWindow::UnfocusTextArea()
  {
   //--- No-op when not focused
   if(!m_textAreaFocused) return;
   //--- Commit any in-progress label edit (engine-level) before unfocusing
   FinalizeOpenLabelEdit();
   m_textAreaFocused        = false;
   m_textAreaCaretBlinkOn   = false;
   //--- Repaint to remove the focus border + caret
   if(m_isSettingsVisible) RedrawSettings();
  }

//+------------------------------------------------------------------+
//| Buffer-change notifier - reset caret blink + queue auto-scroll   |
//+------------------------------------------------------------------+
void CSettingsWindow::NotifyTextAreaBufferChanged()
  {
   //--- No-op when not visible or not focused
   if(!m_isSettingsVisible || !m_textAreaFocused) return;
   //--- Force caret visible (so the user sees feedback on every keystroke)
   m_textAreaCaretBlinkOn      = true;
   m_textAreaCaretBlinkLastMs  = (uint)GetTickCount();
   //--- Schedule an auto-scroll-to-caret on the next render
   m_textAreaAutoScrollPending = true;
   RedrawSettings();
  }

//+------------------------------------------------------------------+
//| Periodic tick - drive caret blink for text-area + coord edits    |
//+------------------------------------------------------------------+
void CSettingsWindow::SettingsTick()
  {
   //--- Bail when hidden
   if(!m_isSettingsVisible) return;
   const uint now = (uint)GetTickCount();
   bool needRedraw = false;
   //--- 500-ms blink cycle for text-area caret when focused
   if(m_textAreaFocused && (now - m_textAreaCaretBlinkLastMs >= 500))
     {
      m_textAreaCaretBlinkOn     = !m_textAreaCaretBlinkOn;
      m_textAreaCaretBlinkLastMs = now;
      needRedraw = true;
     }
   //--- Same 500-ms blink for coordinate-edit caret
   if(m_coordEditPointIdx >= 0 && (now - m_coordEditCaretBlinkLastMs >= 500))
     {
      m_coordEditCaretBlinkOn     = !m_coordEditCaretBlinkOn;
      m_coordEditCaretBlinkLastMs = now;
      needRedraw = true;
     }
   //--- Only redraw + chart-flush when something changed
   if(needRedraw) { RedrawSettings(); ChartRedraw(); }
  }

//+------------------------------------------------------------------+
//| Hit-test text area (true when mouse is over the multi-line input)|
//+------------------------------------------------------------------+
bool CSettingsWindow::HitTestOverTextArea(int mouseX, int mouseY)
  {
   //--- Bail when hidden or active tab is not the Text tab
   if(!m_isSettingsVisible) return false;
   if(m_activeTabIdx < 0 || m_activeTabIdx >= ArraySize(m_tabGroups)) return false;
   if(m_tabGroups[m_activeTabIdx] != PROP_GROUP_TEXT) return false;
   //--- Translate text-input rect to chart-absolute coordinates + containment test
   int tL, tT, tR, tB;
   GetTextTabTextInputRect(tL, tT, tR, tB);
   const int chartL = m_settingsX + tL;
   const int chartT = m_settingsY + tT;
   const int chartR = m_settingsX + tR;
   const int chartB = m_settingsY + tB;
   return (mouseX >= chartL && mouseX < chartR && mouseY >= chartT && mouseY < chartB);
  }

//+------------------------------------------------------------------+
//| Scroll the text area by mouse-wheel delta                        |
//+------------------------------------------------------------------+
void CSettingsWindow::ScrollTextAreaByWheel(int wheelDelta)
  {
   //--- No-op when there's no overflow to scroll
   if(m_taMaxScrollPx <= 0) return;
   //--- Step = 2 line heights (or 24-px fallback if line height is invalid)
   const int step = (m_taLineH > 0) ? m_taLineH * 2 : 24;
   //--- Positive wheel delta = scroll up; negative = scroll down
   const int delta = (wheelDelta > 0) ? -step : step;
   m_textAreaScrollPx += delta;
   //--- Clamp to [0, max]
   if(m_textAreaScrollPx < 0)               m_textAreaScrollPx = 0;
   if(m_textAreaScrollPx > m_taMaxScrollPx) m_textAreaScrollPx = m_taMaxScrollPx;
   RedrawSettings();
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| Hit-test settings body viewport (between header+tabs and footer) |
//+------------------------------------------------------------------+
bool CSettingsWindow::HitTestOverSettingsBody(int mouseX, int mouseY)
  {
   //--- Bail when hidden
   if(!m_isSettingsVisible) return false;
   //--- Body viewport = below header+tabs, above footer; full width
   const int viewportT = m_settingsHeaderH + m_settingsTabBarH;
   const int viewportB = viewportT + m_bodyViewportH;
   const int chartT = m_settingsY + viewportT;
   const int chartB = m_settingsY + viewportB;
   const int chartL = m_settingsX;
   const int chartR = m_settingsX + m_settingsWidth;
   //--- Containment test against the chart-absolute viewport rect
   return (mouseX >= chartL && mouseX < chartR
        && mouseY >= chartT && mouseY < chartB);
  }

//+------------------------------------------------------------------+
//| Scroll the body content area by mouse-wheel delta                |
//+------------------------------------------------------------------+
void CSettingsWindow::ScrollSettingsBodyByWheel(int wheelDelta)
  {
   //--- No-op when there's no overflow to scroll
   if(m_bodyMaxScrollPx <= 0) return;
   //--- Step = 1 row + 1 row-gap (so wheel ticks snap to row boundaries)
   const int step = m_settingsRowH + m_settingsRowGap;
   //--- Positive wheel delta = scroll up; negative = scroll down
   const int delta = (wheelDelta > 0) ? -step : step;
   m_bodyScrollPx += delta;
   //--- Clamp to [0, max]
   if(m_bodyScrollPx < 0)                  m_bodyScrollPx = 0;
   if(m_bodyScrollPx > m_bodyMaxScrollPx)  m_bodyScrollPx = m_bodyMaxScrollPx;
   RedrawSettings();
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| Text-area scrollbar thumb rect (settings-local or chart-absolute)|
//+------------------------------------------------------------------+
bool CSettingsWindow::GetTextAreaThumbRect(int &outL, int &outT, int &outR, int &outB,
                                            bool settingsRelativeOnly)
  {
   //--- Initialize out-params to 0 then bail if no overflow
   outL = outT = outR = outB = 0;
   if(m_taMaxScrollPx <= 0) return false;
   //--- Text-input rect determines the track position
   int tL, tT, tR, tB;
   GetTextTabTextInputRect(tL, tT, tR, tB);
   const int boxL = m_settingsShadowPad;
   const int boxT = m_settingsShadowPad;
   //--- Same padding + bar width as the renderer uses (8 px inset, 6 px wide)
   const int padIn = 8, sbW = 6;
   const int trackL = boxL + tR - padIn - sbW;
   const int trackT = boxT + tT + padIn;
   const int trackR = trackL + sbW;
   const int trackB = boxT + tB - padIn;
   const int trackH = trackB - trackT;
   //--- Thumb height = (viewport/total)*track; clamped to a min of 20 px
   const int viewportH = trackH;
   const int totalH    = viewportH + m_taMaxScrollPx;
   int thumbH = (int)((double)trackH * (double)viewportH / (double)totalH);
   if(thumbH < 20)     thumbH = 20;
   if(thumbH > trackH) thumbH = trackH;
   //--- Thumb Y = track top + (scroll fraction * available travel)
   const int thumbY = trackT + (int)((double)(trackH - thumbH)
                                       * (double)m_textAreaScrollPx
                                       / (double)m_taMaxScrollPx);
   //--- Settings-relative: subtract canvas top-left so callers can blit into the canvas
   if(settingsRelativeOnly)
     {
      outL = trackL - boxL; outR = trackR - boxL;
      outT = thumbY - boxT; outB = thumbY + thumbH - boxT;
     }
   else
     {
      //--- Chart-absolute: add settings XY so callers can hit-test against mouse coords
      outL = m_settingsX + (trackL - boxL);
      outR = m_settingsX + (trackR - boxL);
      outT = m_settingsY + (thumbY - boxT);
      outB = m_settingsY + (thumbY + thumbH - boxT);
     }
   return true;
  }

//+------------------------------------------------------------------+
//| DrawSettingsFooter - separator + Cancel + Ok + Apply defaults    |
//+------------------------------------------------------------------+
void CSettingsWindow::DrawSettingsFooter()
  {
   //--- Canvas-space top-left of the body rect
   const int boxL = m_settingsShadowPad;
   const int boxT = m_settingsShadowPad;

   //--- Fill footer band - 2 rectangles to preserve the rounded bottom corners
   const uchar bgAlpha = (uchar)(255 * BackgroundOpacity);
   const uint  ftrBgArgb = ColorToARGB(m_themeColors.flyoutBackground, bgAlpha);
   const int ftrTop  = boxT + m_settingsHeight - m_settingsFooterH;
   const int ftrInnerB = boxT + m_settingsHeight - m_settingsCornerRadius - 1;
   //--- Upper part of the footer (above the rounded corners)
   m_canvasSettings.FillRectangle(boxL + 1, ftrTop,
                                    boxL + m_settingsWidth - 2, ftrInnerB,
                                    ftrBgArgb);
   //--- Bottom strip between the rounded corners
   m_canvasSettings.FillRectangle(boxL + m_settingsCornerRadius,
                                    ftrInnerB + 1,
                                    boxL + m_settingsWidth - m_settingsCornerRadius - 1,
                                    boxT + m_settingsHeight - 2,
                                    ftrBgArgb);

   //--- 1-px AA separator line at the top of the footer
   const int sepY = boxT + m_settingsHeight - m_settingsFooterH;
   const uint sepArgb = ColorToARGB(m_themeColors.flyoutTextColor, 70);
   WidgetThickLineAA(m_canvasSettings, boxL, sepY,
                      boxL + m_settingsWidth - 1, sepY, 1, sepArgb);

   m_canvasSettings.FontSet("Arial Bold", -100);

   //--- Cancel button (outlined pill, theme-aware border + text on theme bg).
     {
      //--- Cancel button rect + state
      int bL, bT, bR, bB;
      GetFooterButtonRect(1, bL, bT, bR, bB);
      const bool isHov = (m_hoveredFooterBtn == 1);
      //--- Outline = flyoutTextColor full alpha; fill = flyoutBackground
      const uint borderArgb = ColorToARGB(m_themeColors.flyoutTextColor, 255);
      const uchar bgAlphaFull = (uchar)(255 * BackgroundOpacity);
      const uint fillArgb = ColorToARGB(m_themeColors.flyoutBackground, bgAlphaFull);
      WidgetStrokeRoundRect(m_canvasSettings,
                              boxL + bL, boxT + bT, boxL + bR, boxT + bB,
                              5, 1, borderArgb, fillArgb);
      //--- Subtle hover tint on the button interior
      if(isHov)
        {
         const uint tintArgb = ColorToARGB(m_themeColors.flyoutTextColor, 28);
         FillNoteRoundRect(m_canvasSettings,
                             boxL + bL + 1, boxT + bT + 1,
                             boxL + bR - 1, boxT + bB - 1,
                             4, tintArgb);
        }
      //--- "Cancel" label centered
      const string lbl = "Cancel";
      const int lLW = m_canvasSettings.TextWidth(lbl);
      const int lLH = m_canvasSettings.TextHeight(lbl);
      m_canvasSettings.TextOut(boxL + bL + (bR - bL - lLW) / 2,
                                 boxT + bT + (bB - bT - lLH) / 2,
                                 lbl, ColorToARGB(m_themeColors.flyoutTextColor, 255));
     }

   //--- Ok button (filled pill, theme-INVERSE bg, contrast text).
     {
      //--- Ok button rect + state
      int bL, bT, bR, bB;
      GetFooterButtonRect(2, bL, bT, bR, bB);
      const bool isHov = (m_hoveredFooterBtn == 2);
      //--- Fill + border = flyoutTextColor (theme-inverse); text below = flyoutBackground for contrast
      const uint borderArgb = ColorToARGB(m_themeColors.flyoutTextColor, 255);
      const uint fillArgb   = ColorToARGB(m_themeColors.flyoutTextColor, 255);
      WidgetStrokeRoundRect(m_canvasSettings,
                              boxL + bL, boxT + bT, boxL + bR, boxT + bB,
                              5, 1, borderArgb, fillArgb);
      //--- Subtle hover tint (uses flyoutBackground at low alpha since the bg is now inverse)
      if(isHov)
        {
         const uint tintArgb = ColorToARGB(m_themeColors.flyoutBackground, 60);
         FillNoteRoundRect(m_canvasSettings,
                             boxL + bL + 1, boxT + bT + 1,
                             boxL + bR - 1, boxT + bB - 1,
                             4, tintArgb);
        }
      //--- "Ok" label centered in contrast color
      const string lbl = "Ok";
      const int lLW = m_canvasSettings.TextWidth(lbl);
      const int lLH = m_canvasSettings.TextHeight(lbl);
      m_canvasSettings.TextOut(boxL + bL + (bR - bL - lLW) / 2,
                                 boxT + bT + (bB - bT - lLH) / 2,
                                 lbl, ColorToARGB(m_themeColors.flyoutBackground, 255));
     }

   //--- Apply Defaults button (outlined pill, like Cancel - the "secondary action").
     {
      //--- Apply-defaults button rect + state
      int bL, bT, bR, bB;
      GetFooterButtonRect(3, bL, bT, bR, bB);
      const bool isHov = (m_hoveredFooterBtn == 3);
      //--- Same styling as Cancel: outlined pill, flyoutBackground fill, flyoutTextColor border
      const uint borderArgb = ColorToARGB(m_themeColors.flyoutTextColor, 255);
      const uchar bgAlphaApply = (uchar)(255 * BackgroundOpacity);
      const uint fillArgb = ColorToARGB(m_themeColors.flyoutBackground, bgAlphaApply);
      WidgetStrokeRoundRect(m_canvasSettings,
                              boxL + bL, boxT + bT, boxL + bR, boxT + bB,
                              5, 1, borderArgb, fillArgb);
      //--- Subtle hover tint
      if(isHov)
        {
         const uint tintArgb = ColorToARGB(m_themeColors.flyoutTextColor, 28);
         FillNoteRoundRect(m_canvasSettings,
                             boxL + bL + 1, boxT + bT + 1,
                             boxL + bR - 1, boxT + bB - 1,
                             4, tintArgb);
        }
      //--- "Apply defaults" label centered (Arial regular, not bold, since it's a secondary action)
      m_canvasSettings.FontSet("Arial", -100);
      const string lbl = "Apply defaults";
      const int lLW = m_canvasSettings.TextWidth(lbl);
      const int lLH = m_canvasSettings.TextHeight(lbl);
      m_canvasSettings.TextOut(boxL + bL + (bR - bL - lLW) / 2,
                                 boxT + bT + (bB - bT - lLH) / 2,
                                 lbl, ColorToARGB(m_themeColors.flyoutTextColor, 255));
     }
  }

//+------------------------------------------------------------------+
//| Pull in the interaction subsystem (mouse routing + key handlers) |
//+------------------------------------------------------------------+
#include "ToolsPalette_Settings_Interact.mqh"

#endif // TOOLS_PALETTE_SETTINGS_MQH
//+------------------------------------------------------------------+