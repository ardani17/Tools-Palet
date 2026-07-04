//+------------------------------------------------------------------+
//|                              ToolsPalette_Settings_Interact.mqh  |
//|                                            Copyright 2026, Om J. |
//|                                               https://t.me/HZFXI |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Om J."
#property link "https://t.me/HZFXI"
#property version "1.00"
#property strict

//--- Guard against multiple inclusion of this header
#ifndef TOOLS_PALETTE_SETTINGS_INTERACT_MQH
#define TOOLS_PALETTE_SETTINGS_INTERACT_MQH

//--- Pull in the Settings window declaration (CSettingsWindow class)
#include "ToolsPalette_Settings.mqh"

//+------------------------------------------------------------------+
//| SettingsMouseDown - click router for the Settings window         |
//+------------------------------------------------------------------+
bool CSettingsWindow::SettingsMouseDown(int mouseX, int mouseY)
  {
   //--- Reject clicks outside the window (return false so the engine can route elsewhere)
   int lx, ly;
   if(!HitTestOverSettings(mouseX, mouseY, lx, ly)) return false;

   //--- Cache active-tab + Text-tab control hit (needed for the text-area unfocus rule below)
   const bool isTextTabActive = (m_activeTabIdx >= 0
                              && m_activeTabIdx < ArraySize(m_tabGroups)
                              && m_tabGroups[m_activeTabIdx] == PROP_GROUP_TEXT);
   const int  textCtrlClicked = isTextTabActive ? HitTestTextTabControl(lx, ly) : 0;
   //--- Click anywhere except the text-input itself unfocuses the text area
   if(m_textAreaFocused && textCtrlClicked != 5)
      UnfocusTextArea();

   //--- Cache Coords-tab active flag (needed for coord-edit commit rules below)
   const bool isCoordsTabActive = (m_activeTabIdx >= 0
                                && m_activeTabIdx < ArraySize(m_tabGroups)
                                && m_tabGroups[m_activeTabIdx] == PROP_GROUP_COORDS);
   //--- Commit any in-progress coord edit when clicking outside its row OR outside the Coords tab
   if(IsEditingCoord() && isCoordsTabActive)
     {
      //--- Allow re-clicking the same field's text area without committing (just repositions caret)
      int hitRow, hitField, hitStepper;
      const bool overCoords = HitTestCoordsTab(lx, ly, hitRow, hitField, hitStepper);
      const bool clickingSameField = overCoords
                                    && hitRow == m_coordEditPointIdx
                                    && hitField == m_coordEditField
                                    && hitStepper == 0;
      if(!clickingSameField) CommitCoordEdit();
     }
   else if(IsEditingCoord() && !isCoordsTabActive)
     {
      //--- Coord edit lives only on Coords tab; switching tabs commits it
      CommitCoordEdit();
     }
   //--- Commit any in-progress float edit when clicking outside its value button (steppers excluded)
   if(IsEditingFloat())
     {
      bool clickingSameField = false;
      const int rn = ArraySize(m_activeTabRowIdxs);
      //--- Scan rows to find the value button that matches the currently-edited prop id
      for(int rr = 0; rr < rn; rr++)
        {
         const SToolProperty pp = ResolveActiveRowDescriptor(rr);
         string thisValueId = "";
         if(pp.type == PROP_FLOAT)
            thisValueId = pp.id;
         else if(pp.type == PROP_COMPACT_ROW)
            thisValueId = pp.subValueId;
         if(thisValueId != m_floatEditPropId) continue;
         //--- Resolve the value-button + stepper rects for this row
         int bL, bT, bR, bB;
         if(!GetCompactValueButtonRect(rr, bL, bT, bR, bB)) break;
         int sUL, sUT, sUR, sUB; GetCompactStepperRect(rr, 0, sUL, sUT, sUR, sUB);
         int sDL, sDT, sDR, sDB; GetCompactStepperRect(rr, 1, sDL, sDT, sDR, sDB);
         //--- "Same field" = inside the button but NOT on the stepper chevrons
         const bool onUp   = (lx >= sUL && lx < sUR && ly >= sUT && ly < sUB);
         const bool onDown = (lx >= sDL && lx < sDR && ly >= sDT && ly < sDB);
         const bool inBtn  = (lx >= bL && lx < bR && ly >= bT && ly < bB);
         if(inBtn && !onUp && !onDown) clickingSameField = true;
         break;
        }
      if(!clickingSameField) CommitFloatEdit();
     }

   //--- Close-X click -> discard changes (Cancel-equivalent) + close window
   if(HitTestCloseButton(lx, ly))
     { DiscardSettingsChanges(); return true; }

   //--- Footer button dispatch (1=Cancel, 2=Ok, 3=Apply Defaults)
   const int btn = HitTestFooterButton(lx, ly);
   if(btn == 1) { DiscardSettingsChanges(); return true; }
   if(btn == 2) { CommitSettingsChanges();  return true; }
   if(btn == 3)
     {
      //--- Apply Defaults: cancel any in-progress edits + apply tool defaults + rebuild layout
      if(m_textAreaFocused)
        {
         if(m_isEditingLabel) CancelLabel();
         m_textAreaFocused      = false;
         m_textAreaCaretBlinkOn = false;
        }
      if(m_coordEditPointIdx >= 0) CancelCoordEdit();
      if(IsEditingFloat())          CancelFloatEdit();
      //--- Reset all properties to their type-specific defaults
      ApplyToolDefaults(m_settingsOwnerObjectId);
      RefreshActiveTabRows();
      RecalcSettingsSize();
      ApplySettingsPosition();
      RedrawSettings();
      ChartRedraw();
      return true;
     }

   //--- Tab click - switch active tab + rebuild row list + recompute size
   const int tabIdx = HitTestTab(lx, ly);
   if(tabIdx >= 0)
     {
      //--- Only repaint if the tab actually changed
      if(tabIdx != m_activeTabIdx)
        {
         m_activeTabIdx = tabIdx;
         RefreshActiveTabRows();
         //--- Reset body scroll when switching tabs (new content layout)
         m_bodyScrollPx = 0;
         RecalcSettingsSize();
         ApplySettingsPosition();
         RedrawSettings();
         ChartRedraw();
        }
      return true;
     }

   //--- Header drag-area click - begin window drag (offsets captured for the duration of the drag)
   if(HitTestHeaderDragArea(lx, ly))
     {
      m_isDraggingSettings = true;
      m_dragGrabOffsetX = lx;
      m_dragGrabOffsetY = ly;
      return true;
     }

   //--- Body scrollbar interaction.
   if(m_bodyMaxScrollPx > 0)
     {
      //--- Resolve thumb rect (settings-relative) + clickable track region (thumb +/- 4 px)
      int thL, thT, thR, thB;
      if(GetBodyThumbRect(thL, thT, thR, thB, true))
        {
         const int viewportT = m_settingsHeaderH + m_settingsTabBarH;
         const int viewportB = viewportT + m_bodyViewportH;
         const int trackXL   = thL - 4;
         const int trackXR   = thR + 4;
         //--- Click anywhere on the track triggers either drag-grab (on thumb) or step-paging (off thumb)
         if(lx >= trackXL && lx < trackXR
            && ly >= viewportT && ly < viewportB)
           {
            //--- On the thumb -> begin drag-grab (offset captured so the cursor stays on the same thumb pixel)
            if(ly >= thT && ly < thB)
              {
               m_bodyThumbDragging    = true;
               m_bodyThumbGrabOffsetY = ly - thT;
               RedrawSettings();
               ChartRedraw();
               return true;
              }
            //--- Off the thumb -> page step (above thumb = scroll up, below = scroll down)
            const int step = m_settingsRowH + m_settingsRowGap;
            const int delta = (ly < thT) ? -step : step;
            m_bodyScrollPx += delta;
            //--- Clamp to [0, max]
            if(m_bodyScrollPx < 0)                 m_bodyScrollPx = 0;
            if(m_bodyScrollPx > m_bodyMaxScrollPx) m_bodyScrollPx = m_bodyMaxScrollPx;
            RedrawSettings();
            ChartRedraw();
            return true;
           }
        }
     }

   //--- Text tab dispatch.
   const bool isTextTab = (m_activeTabIdx >= 0
                          && m_activeTabIdx < ArraySize(m_tabGroups)
                          && m_tabGroups[m_activeTabIdx] == PROP_GROUP_TEXT);
   if(isTextTab)
     {
      //--- Text-area scrollbar thumb drag-grab (must precede control hit-tests)
      int thL, thT, thR, thB;
      const bool hasThumb = GetTextAreaThumbRect(thL, thT, thR, thB, true);
      if(hasThumb && lx >= thL && lx < thR && ly >= thT && ly < thB)
        {
         m_textAreaThumbDragging   = true;
         m_textAreaThumbGrabOffsetY = ly - thT;
         RedrawSettings();
         ChartRedraw();
         return true;
        }

      //--- Text-tab control hit-test (color/fontSize/bold/text/vAlign/hAlign)
      const int ctrl = HitTestTextTabControl(lx, ly);
      if(ctrl > 0)
        {
         //--- Dropdown controls (color/fontSize/vAlign/hAlign) -> open popover anchored below the control
         if(ctrl == 1 || ctrl == 2 || ctrl == 6 || ctrl == 7)
           {
            //--- Resolve the propId + anchor rect for the clicked control
            string propId = "";
            int rL = 0, rT = 0, rR = 0, rB = 0;
            if(ctrl == 1) { propId = "textColor"; GetTextTabColorRect(rL, rT, rR, rB); }
            if(ctrl == 2) { propId = "fontSize";  GetTextTabFontSizeRect(rL, rT, rR, rB); }
            if(ctrl == 6) { propId = "vAlign";    GetTextTabVAlignRect(rL, rT, rR, rB); }
            if(ctrl == 7) { propId = "hAlign";    GetTextTabHAlignRect(rL, rT, rR, rB); }
            //--- Anchor: 4 px below the control's bottom-left; flip base = top of control for upward popovers
            const int anchorX = m_settingsX + rL;
            const int anchorY = m_settingsY + rB + 4;
            const int flipBaseTop = m_settingsY + rT;
            //--- Mirror Settings-state into the Ribbon-state so the popover renders against our properties
            m_ribbonOwnerObjectId = m_settingsOwnerObjectId;
            m_popoverSnapshotIsExternal = true;
            ArrayResize(m_ribbonProperties, 0);
            const int n = ArraySize(m_settingsProperties);
            for(int i = 0; i < n; i++)
              {
               const int sz = ArraySize(m_ribbonProperties);
               ArrayResize(m_ribbonProperties, sz + 1);
               m_ribbonProperties[sz] = m_settingsProperties[i];
              }
            //--- Open the popover for this propId at the computed anchor
            ShowPopoverForProperty(propId, anchorX, anchorY, flipBaseTop);
            RedrawSettings();
            return true;
           }
         //--- Bold toggle (ctrl 3) - flip the bool prop directly
         if(ctrl == 3)
           {
            bool curBold = false;
            GetObjectProperty(m_settingsOwnerObjectId, "bold", curBold);
            SetObjectProperty(m_settingsOwnerObjectId, "bold", !curBold, true);
            RedrawSettings();
            ChartRedraw();
            return true;
           }
         //--- Text-input area (ctrl 5) - focus + place caret at the click position
         if(ctrl == 5)
           {
            //--- First click: enter focus mode + start a label-edit session
            if(!m_textAreaFocused)
              {
               m_selectedObjectId = m_settingsOwnerObjectId;
               StartLabelEdit();
               m_textAreaFocused           = true;
               m_textAreaCaretBlinkOn      = true;
               m_textAreaCaretBlinkLastMs  = (uint)GetTickCount();
               m_textAreaAutoScrollPending = true;
              }
              {
               //--- Compute content rect (matches DrawTextTabRows layout: 8 px inset + 6 px scrollbar + 4 px gap)
               int taL, taT, taR, taB;
               GetTextTabTextInputRect(taL, taT, taR, taB);
               const int padIn = 8, sbW = 6, sbGap = 4;
               const int contentL = taL + padIn;
               const int contentT = taT + padIn;
               const int contentR = taR - padIn - sbW - sbGap;
               const int contentW = contentR - contentL;
               //--- Skip caret positioning if buffer is empty or layout area too narrow
               if(contentW > 0 && StringLen(m_labelEditBuffer) > 0)
                 {
                  //--- Recompute the wrapped layout to find which wrap-line the click landed on
                  string lines[]; int bufOffsets[];
                  int measMaxW = 0, measBlockH = 0, measLineH = 0;
                  ComputeWrappedLayout(m_labelEditBuffer, "Arial", 10,
                                        contentW, lines, bufOffsets,
                                        measMaxW, measBlockH, measLineH);
                  const int nLines = ArraySize(lines);
                  const int lineH  = (measLineH > 0) ? measLineH : 12;
                  if(nLines > 0)
                    {
                     //--- clickYInContent accounts for the current scroll offset
                     const int clickYInContent = (ly - contentT) + m_textAreaScrollPx;
                     int clickedLine = clickYInContent / lineH;
                     //--- Clamp to valid line index
                     if(clickedLine < 0)       clickedLine = 0;
                     if(clickedLine >= nLines) clickedLine = nLines - 1;
                     const int lineStart     = bufOffsets[clickedLine];
                     const int lineCharCount = StringLen(lines[clickedLine]);
                     const int clickXInContent = lx - contentL;
                     m_canvasSettings.FontSet("Arial", -100);
                     //--- Find the largest col where segWidth <= clickX (binary increment scan)
                     int bestCol = 0;
                     for(int col = 0; col <= lineCharCount; col++)
                       {
                        const string segment = StringSubstr(m_labelEditBuffer, lineStart, col);
                        const int segW = m_canvasSettings.TextWidth(segment);
                        if(segW <= clickXInContent)
                           bestCol = col;
                        else
                           break;
                       }
                     //--- Round to nearest char boundary (compare against midpoint of segNow + segNext)
                     if(bestCol < lineCharCount)
                       {
                        const string segNow  = StringSubstr(m_labelEditBuffer, lineStart, bestCol);
                        const string segNext = StringSubstr(m_labelEditBuffer, lineStart, bestCol + 1);
                        const int segNowW  = m_canvasSettings.TextWidth(segNow);
                        const int segNextW = m_canvasSettings.TextWidth(segNext);
                        const int midX = (segNowW + segNextW) / 2;
                        if(clickXInContent >= midX) bestCol++;
                       }
                     //--- Convert per-line column to absolute buffer position + clamp
                     int newCaret = lineStart + bestCol;
                     const int bufLen = StringLen(m_labelEditBuffer);
                     if(newCaret < 0)       newCaret = 0;
                     if(newCaret > bufLen)  newCaret = bufLen;
                     m_labelCaretPos = newCaret;
                    }
                 }
              }
            RedrawSettings();
            ChartRedraw();
            return true;
           }
        }
      //--- Text tab is exclusive - swallow even unhandled clicks on this tab
      return true;
     }

   //--- Coordinates-tab dispatch.
   const bool isCoordsTab = (m_activeTabIdx >= 0
                             && m_activeTabIdx < ArraySize(m_tabGroups)
                             && m_tabGroups[m_activeTabIdx] == PROP_GROUP_COORDS);
   if(isCoordsTab)
     {
      //--- Hit-test against Coords-tab regions (row + field 1=price/2=time + stepper 1-4)
      int hitRow, hitField, hitStepper;
      const bool overCoords = HitTestCoordsTab(lx, ly, hitRow, hitField, hitStepper);
      if(overCoords)
        {
         //--- Stepper click -> apply a one-step nudge (field 1 = price by _Point, field 2 = time by 1 bar)
         if(hitStepper > 0)
           {
            //--- Stepper key 1/2 = price up/down; 3/4 = time up/down (matches the rendering convention)
            const int field = (hitStepper <= 2) ? 1 : 2;
            const int dir   = (hitStepper == 1 || hitStepper == 3) ? 0 : 1;
            ApplyCoordStep(hitRow, field, dir);
            RedrawSettings();
            ChartRedraw();
            return true;
           }
         //--- Field click -> start/continue inline edit + position caret at the click
         if(hitField > 0)
           {
            //--- Don't restart the edit if it's already the same field (just reposition caret)
            const bool sameField = (m_coordEditPointIdx == hitRow
                                  && m_coordEditField == hitField);
            if(!sameField)
               StartCoordEdit(hitRow, hitField);
            PositionCoordCaretFromClickX(lx);
            RedrawSettings();
            ChartRedraw();
            return true;
           }
        }
      //--- Coords tab is exclusive - swallow even unhandled clicks
      return true;
     }

   //--- Row chip click.
   const int rowSlot = HitTestRow(lx, ly);
   if(rowSlot >= 0)
     {
      const SToolProperty prop = ResolveActiveRowDescriptor(rowSlot);
      if(prop.type == PROP_COMPACT_ROW)
        {
         //--- "+ Add level" pseudo-row -> append a new Fibo level + scroll to it
         if(prop.isAddLevelRow)
           {
            AppendFibLevel(m_settingsOwnerObjectId);
            RefreshActiveTabRows();
            RecalcSettingsSize();
            ApplySettingsPosition();
            //--- Scroll to the very bottom so the new level is visible
            m_bodyScrollPx = m_bodyMaxScrollPx;
            RedrawSettings();
            ChartRedraw();
            return true;
           }
         //--- Compact-row sub-widget dispatch (sub-widget sizes + spacing must match RenderRowChip)
         const int chkSize = 22, valW = 60, colW = 30, wW = 36, sW = 36;
         const int btnH = 24, gap = 8;
         //--- Row bounds + cursor positions (matches the renderer)
         int rowL_, rowT_, rowR_, rowB_;
         GetRowRect(rowSlot, rowL_, rowT_, rowR_, rowB_);
         const int contLeftX = rowL_ + 6;
         const int contMidYW = (rowT_ + rowB_) / 2;
         const int chkT = contMidYW - chkSize / 2;
         const int btnT = contMidYW - btnH / 2;
         int x = contLeftX;
         //--- 1. Checkbox.
         if(StringLen(prop.subVisibleId) > 0)
           {
            //--- Toggle the visibility bool (sub-snapshot=false because parent owns the snapshot)
            if(lx >= x && lx <= x + chkSize && ly >= chkT && ly <= chkT + chkSize)
              {
               bool cur = false;
               GetObjectProperty(m_settingsOwnerObjectId, prop.subVisibleId, cur);
               SetObjectProperty(m_settingsOwnerObjectId, prop.subVisibleId, !cur, false);
               RedrawSettings(); ChartRedraw();
               return true;
              }
            //--- Advance cursor past checkbox
            x += chkSize + gap;
           }
         //--- 2. Value stepper.
         if(StringLen(prop.subValueId) > 0)
           {
            //--- Resolve the value button rect + check stepper hits first (chevrons take priority)
            int bL, bT, bR, bB;
            GetCompactValueButtonRect(rowSlot, bL, bT, bR, bB);
            int sL, sT, sR, sB;
            //--- Up-stepper click -> increment by stepValue
            if(GetCompactStepperRect(rowSlot, 0, sL, sT, sR, sB)
               && lx >= sL && lx < sR && ly >= sT && ly < sB)
              {
               double cur = 0.0;
               GetObjectProperty(m_settingsOwnerObjectId, prop.subValueId, cur);
               const double step = (prop.stepValue > 0.0) ? prop.stepValue : 0.1;
               cur += step;
               SetObjectProperty(m_settingsOwnerObjectId, prop.subValueId, cur, false);
               RedrawSettings(); ChartRedraw();
               return true;
              }
            //--- Down-stepper click -> decrement by stepValue
            if(GetCompactStepperRect(rowSlot, 1, sL, sT, sR, sB)
               && lx >= sL && lx < sR && ly >= sT && ly < sB)
              {
               double cur = 0.0;
               GetObjectProperty(m_settingsOwnerObjectId, prop.subValueId, cur);
               const double step = (prop.stepValue > 0.0) ? prop.stepValue : 0.1;
               cur -= step;
               SetObjectProperty(m_settingsOwnerObjectId, prop.subValueId, cur, false);
               RedrawSettings(); ChartRedraw();
               return true;
              }
            //--- Value-button click (not on a stepper) -> begin/continue float edit + caret-from-click
            if(lx >= bL && lx < bR && ly >= bT && ly < bB)
              {
               const int textStartX = bL + 6;
               //--- Only begin a fresh edit if not already editing this prop
               if(!IsEditingFloat() || m_floatEditPropId != prop.subValueId)
                  BeginFloatEdit(prop.subValueId, prop.decimals, prop.minValue, prop.maxValue);
               PositionFloatCaretFromClickX(lx, textStartX);
               RedrawSettings();
               return true;
              }
            //--- Advance cursor past value button
            x += valW + gap;
           }
         //--- 3. Color cube.
         if(StringLen(prop.subColorId) > 0)
           {
            //--- Click -> open a sub-popover anchored below the cube
            if(lx >= x && lx <= x + colW && ly >= btnT && ly <= btnT + btnH)
              {
               const int anchorX = m_settingsX + x;
               const int anchorY = m_settingsY + btnT + btnH + 4;
               const int flipBaseTop = m_settingsY + btnT;
               OpenSettingsSubPopover(prop.subColorId, anchorX, anchorY, flipBaseTop);
               return true;
              }
            //--- Advance cursor past color cube
            x += colW + gap;
           }
         //--- 4. Width cube.
         if(StringLen(prop.subWidthId) > 0)
           {
            //--- Click -> open width sub-popover
            if(lx >= x && lx <= x + wW && ly >= btnT && ly <= btnT + btnH)
              {
               const int anchorX = m_settingsX + x;
               const int anchorY = m_settingsY + btnT + btnH + 4;
               const int flipBaseTop = m_settingsY + btnT;
               OpenSettingsSubPopover(prop.subWidthId, anchorX, anchorY, flipBaseTop);
               return true;
              }
            //--- Advance cursor past width cube
            x += wW + gap;
           }
         //--- 5. Style cube.
         if(StringLen(prop.subStyleId) > 0)
           {
            //--- Click -> open style sub-popover
            if(lx >= x && lx <= x + sW && ly >= btnT && ly <= btnT + btnH)
              {
               const int anchorX = m_settingsX + x;
               const int anchorY = m_settingsY + btnT + btnH + 4;
               const int flipBaseTop = m_settingsY + btnT;
               OpenSettingsSubPopover(prop.subStyleId, anchorX, anchorY, flipBaseTop);
               return true;
              }
           }
         //--- Compact row is exclusive - swallow unhandled clicks
         return true;
        }
      //--- PROP_BOOL row -> chip click toggles the bool
      if(prop.type == PROP_BOOL)
        {
         //--- Chip rect = the checkbox; click toggles
         int chL_, chT_, chR_, chB_;
         GetRowChipRect(rowSlot, chL_, chT_, chR_, chB_);
         if(lx >= chL_ && lx <= chR_ && ly >= chT_ && ly <= chB_)
           {
            bool cur = false;
            GetObjectProperty(m_settingsOwnerObjectId, prop.id, cur);
            SetObjectProperty(m_settingsOwnerObjectId, prop.id, !cur, false);
            RedrawSettings(); ChartRedraw();
            return true;
           }
         return true;
        }
      //--- PROP_FLOAT row -> stepper or inline edit (mirrors compact-row value-stepper logic)
      if(prop.type == PROP_FLOAT)
        {
         //--- Resolve value-button rect (the whole chip)
         int bL, bT, bR, bB;
         if(!GetCompactValueButtonRect(rowSlot, bL, bT, bR, bB)) return true;
         int sL, sT, sR, sB;
         //--- Up-stepper click -> increment by stepValue
         if(GetCompactStepperRect(rowSlot, 0, sL, sT, sR, sB)
            && lx >= sL && lx < sR && ly >= sT && ly < sB)
           {
            double cur = 0.0;
            GetObjectProperty(m_settingsOwnerObjectId, prop.id, cur);
            const double step = (prop.stepValue > 0.0) ? prop.stepValue : 0.1;
            cur += step;
            SetObjectProperty(m_settingsOwnerObjectId, prop.id, cur, false);
            RedrawSettings(); ChartRedraw();
            return true;
           }
         //--- Down-stepper click -> decrement by stepValue
         if(GetCompactStepperRect(rowSlot, 1, sL, sT, sR, sB)
            && lx >= sL && lx < sR && ly >= sT && ly < sB)
           {
            double cur = 0.0;
            GetObjectProperty(m_settingsOwnerObjectId, prop.id, cur);
            const double step = (prop.stepValue > 0.0) ? prop.stepValue : 0.1;
            cur -= step;
            SetObjectProperty(m_settingsOwnerObjectId, prop.id, cur, false);
            RedrawSettings(); ChartRedraw();
            return true;
           }
         //--- Click on the value text -> begin/continue float edit (text X = chip-left + 8 px pad)
         if(lx >= bL && lx < bR && ly >= bT && ly < bB)
           {
            const int textStartX = bL + 8;
            if(!IsEditingFloat() || m_floatEditPropId != prop.id)
               BeginFloatEdit(prop.id, prop.decimals, prop.minValue, prop.maxValue);
            PositionFloatCaretFromClickX(lx, textStartX);
            RedrawSettings();
            return true;
           }
         return true;
        }
      //--- PROP_COLOR / PROP_LINE_WIDTH / PROP_LINE_STYLE -> chip click opens popover
      if(prop.type == PROP_COLOR
         || prop.type == PROP_LINE_WIDTH
         || prop.type == PROP_LINE_STYLE)
        {
         //--- Anchor popover below the chip
         int chL, chT, chR, chB;
         GetRowChipRect(rowSlot, chL, chT, chR, chB);
         const int anchorX = m_settingsX + chL;
         const int anchorY = m_settingsY + chB + 4;
         const int flipBaseTop = m_settingsY + chT;
         //--- Mirror Settings-state into Ribbon-state for the popover renderer
         m_ribbonOwnerObjectId = m_settingsOwnerObjectId;
         m_popoverSnapshotIsExternal = true;
         ArrayResize(m_ribbonProperties, 0);
         const int n = ArraySize(m_settingsProperties);
         for(int i = 0; i < n; i++)
           {
            const int sz = ArraySize(m_ribbonProperties);
            ArrayResize(m_ribbonProperties, sz + 1);
            m_ribbonProperties[sz] = m_settingsProperties[i];
           }
         ShowPopoverForProperty(prop.id, anchorX, anchorY, flipBaseTop);
         RedrawSettings();
        }
      return true;
     }

   //--- Any other click inside the window is swallowed (so events don't leak to the chart)
   return true;
  }

//+------------------------------------------------------------------+
//| SettingsMouseMove - drag tracking + hover state updates          |
//+------------------------------------------------------------------+
bool CSettingsWindow::SettingsMouseMove(int mouseX, int mouseY, uint mouseButtons)
  {
   //--- No-op when hidden
   if(!m_isSettingsVisible) return false;

   //--- Text-area scrollbar thumb drag.
   if(m_textAreaThumbDragging && mouseButtons == 1)
     {
      //--- Resolve track Y bounds in chart-absolute coords + thumb height
      int tL, tT, tR, tB;
      GetTextTabTextInputRect(tL, tT, tR, tB);
      const int padIn = 8;
      const int trackChartT = m_settingsY + tT + padIn;
      const int trackChartB = m_settingsY + tB - padIn;
      const int trackH = trackChartB - trackChartT;
      const int viewportH = trackH;
      const int totalH    = viewportH + m_taMaxScrollPx;
      int thumbH = (int)((double)trackH * (double)viewportH / (double)totalH);
      if(thumbH < 20)     thumbH = 20;
      if(thumbH > trackH) thumbH = trackH;
      //--- New thumb Y = mouse Y - grab offset; clamped to the track
      int thumbY = mouseY - m_textAreaThumbGrabOffsetY;
      if(thumbY < trackChartT)          thumbY = trackChartT;
      if(thumbY > trackChartB - thumbH) thumbY = trackChartB - thumbH;
      //--- Map thumb-Y back to scroll-Px via the (thumbY - trackTop) / trackRange ratio
      const int trackRange = trackH - thumbH;
      if(trackRange > 0)
         m_textAreaScrollPx = (int)((double)m_taMaxScrollPx
                                       * (double)(thumbY - trackChartT)
                                       / (double)trackRange);
      RedrawSettings(); ChartRedraw();
      return true;
     }
   //--- Mouse button released mid-drag (catch missed mouse-up events) -> end drag
   if(m_textAreaThumbDragging && mouseButtons == 0)
     {
      m_textAreaThumbDragging = false;
      RedrawSettings(); ChartRedraw();
      return true;
     }

   //--- Body scrollbar thumb drag.
   if(m_bodyThumbDragging && mouseButtons == 1)
     {
      //--- Track bounds in chart-absolute coords
      const int viewportT = m_settingsHeaderH + m_settingsTabBarH;
      const int viewportB = viewportT + m_bodyViewportH;
      const int trackChartT = m_settingsY + viewportT;
      const int trackChartB = m_settingsY + viewportB;
      const int trackH = trackChartB - trackChartT;
      //--- Re-query the current thumb rect to get the height
      int curL, curT, curR, curB;
      const int thumbH = (GetBodyThumbRect(curL, curT, curR, curB, true))
                         ? (curB - curT) : 20;
      if(trackH > 0)
        {
         //--- New thumb Y = mouse Y - grab offset; clamped
         int thumbY = mouseY - m_bodyThumbGrabOffsetY;
         if(thumbY < trackChartT)            thumbY = trackChartT;
         if(thumbY > trackChartB - thumbH)   thumbY = trackChartB - thumbH;
         //--- Map thumb-Y back to scroll-Px via the position ratio
         const int trackRange = trackH - thumbH;
         if(trackRange > 0)
            m_bodyScrollPx = (int)((double)m_bodyMaxScrollPx
                                      * (double)(thumbY - trackChartT)
                                      / (double)trackRange);
        }
      RedrawSettings(); ChartRedraw();
      return true;
     }
   //--- Mouse button released mid-drag -> end body-thumb drag
   if(m_bodyThumbDragging && mouseButtons == 0)
     {
      m_bodyThumbDragging = false;
      RedrawSettings(); ChartRedraw();
      return true;
     }

   //--- Window drag (LMB held + drag flag set) - move window by mouse delta
   if(m_isDraggingSettings && mouseButtons == 1)
     {
      m_settingsX = mouseX - m_dragGrabOffsetX;
      m_settingsY = mouseY - m_dragGrabOffsetY;
      //--- Clamp to chart bounds (keep at least 80 px + header visible so the window can always be grabbed back)
      const int chartW = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
      const int chartH = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
      if(m_settingsX < 0) m_settingsX = 0;
      if(m_settingsY < 0) m_settingsY = 0;
      if(m_settingsX > chartW - 80) m_settingsX = chartW - 80;
      if(m_settingsY > chartH - m_settingsHeaderH) m_settingsY = chartH - m_settingsHeaderH;
      ApplySettingsPosition();
      ChartRedraw();
      return true;
     }
   //--- Mouse button released mid-drag -> end window drag
   if(m_isDraggingSettings && mouseButtons == 0)
     { m_isDraggingSettings = false; return true; }

   //--- Hover-state pass: reject mouse-over flags when the mouse is outside the window
   int lx, ly;
   bool over = HitTestOverSettings(mouseX, mouseY, lx, ly);
   //--- Treat mouse-over-popover as "not over Settings" (popover hover wins)
   if(over && m_isPopoverVisible)
     {
      int popLx, popLy;
      if(HitTestOverPopover(mouseX, mouseY, popLx, popLy))
         over = false;
     }
   if(!over)
     {
      //--- Clear all hover flags + repaint only if something actually changed
      bool changed = (m_hoveredTabIdx != -1) || (m_hoveredRowIdx != -1)
                  || (m_hoveredFooterBtn != 0) || m_hoveredCloseBtn
                  || (m_hoveredTextTabCtrl != 0)
                  || m_hoveredTextAreaScrollbar
                  || m_hoveredBodyScrollbar
                  || m_coordHoveredRow != -1
                  || m_coordHoveredField != 0
                  || m_coordHoveredStepper != 0
                  || m_compactHoveredRow != -1
                  || m_compactHoveredStepper != 0;
      if(changed)
        {
         //--- Reset every hover flag to its "no hover" sentinel
         m_hoveredTabIdx            = -1;
         m_hoveredRowIdx            = -1;
         m_hoveredFooterBtn         = 0;
         m_hoveredCloseBtn          = false;
         m_hoveredTextTabCtrl       = 0;
         m_hoveredTextAreaScrollbar = false;
         m_hoveredBodyScrollbar     = false;
         m_coordHoveredRow          = -1;
         m_coordHoveredField        = 0;
         m_coordHoveredStepper      = 0;
         m_compactHoveredRow        = -1;
         m_compactHoveredStepper    = 0;
         RedrawSettings(); ChartRedraw();
        }
      return false;
     }

   //--- Mouse is over the window - compute new hover values for every region
   const int newTab = HitTestTab(lx, ly);
   const int newRow = HitTestRow(lx, ly);
   const int newBtn = HitTestFooterButton(lx, ly);
   const bool newClose = HitTestCloseButton(lx, ly);
   //--- Text-tab control hover (only valid when Text tab is active)
   const bool isTextTab = (m_activeTabIdx >= 0
                          && m_activeTabIdx < ArraySize(m_tabGroups)
                          && m_tabGroups[m_activeTabIdx] == PROP_GROUP_TEXT);
   const int newTextCtrl = isTextTab ? HitTestTextTabControl(lx, ly) : 0;
   //--- Text-area scrollbar hover
   bool newScrollHover = false;
   if(isTextTab)
     {
      int thL, thT, thR, thB;
      if(GetTextAreaThumbRect(thL, thT, thR, thB, true))
         if(lx >= thL && lx < thR && ly >= thT && ly < thB)
            newScrollHover = true;
     }
   //--- Body scrollbar hover (4 px padded zone around the thumb for easier targeting)
   bool newBodyScrollHover = false;
     {
      int thL, thT, thR, thB;
      if(GetBodyThumbRect(thL, thT, thR, thB, true))
         if(lx >= thL - 4 && lx < thR + 4 && ly >= thT && ly < thB)
            newBodyScrollHover = true;
     }
   //--- Coordinates tab hover (only valid when Coords tab is active)
   const bool isCoordsTab = (m_activeTabIdx >= 0
                            && m_activeTabIdx < ArraySize(m_tabGroups)
                            && m_tabGroups[m_activeTabIdx] == PROP_GROUP_COORDS);
   int newCoordRow = -1, newCoordField = 0, newCoordStepper = 0;
   if(isCoordsTab)
      HitTestCoordsTab(lx, ly, newCoordRow, newCoordField, newCoordStepper);

   //--- Compact-row value-button hover + stepper hover (for FLOAT or COMPACT_ROW types)
   int newCompactRow = -1, newCompactStepper = 0;
   if(newRow >= 0)
     {
      const SToolProperty cprop = ResolveActiveRowDescriptor(newRow);
      if(cprop.type == PROP_COMPACT_ROW || cprop.type == PROP_FLOAT)
        {
         //--- Check if mouse is over the value button at all
         int bL, bT, bR, bB;
         if(GetCompactValueButtonRect(newRow, bL, bT, bR, bB)
            && lx >= bL && lx < bR && ly >= bT && ly < bB)
           {
            newCompactRow = newRow;
            //--- Then refine to a specific stepper (key 1 = up, 2 = down)
            int sL, sT, sR, sB;
            if(GetCompactStepperRect(newRow, 0, sL, sT, sR, sB)
               && lx >= sL && lx < sR && ly >= sT && ly < sB)
               newCompactStepper = 1;
            else if(GetCompactStepperRect(newRow, 1, sL, sT, sR, sB)
                     && lx >= sL && lx < sR && ly >= sT && ly < sB)
               newCompactStepper = 2;
           }
        }
     }

   //--- Compact-row sub-widget hover (which of the 5 cubes is under the mouse, if any)
   int newCompactSubRow = -1, newCompactSubButton = 0;
   if(newRow >= 0)
     {
      const SToolProperty subprop = ResolveActiveRowDescriptor(newRow);
      if(subprop.type == PROP_COMPACT_ROW && !subprop.isAddLevelRow)
        {
         //--- Replay the cursor advance from RenderRowChip to find which sub-widget is hit
         const int chkSize = 22, valW = 60, colW = 30, wW = 36, sW = 36;
         const int btnH = 24, gap = 8;
         int rowL_, rowT_, rowR_, rowB_;
         GetRowRect(newRow, rowL_, rowT_, rowR_, rowB_);
         const int contLeftX = rowL_ + 6;
         const int contMidYW = (rowT_ + rowB_) / 2;
         const int chkT = contMidYW - chkSize / 2;
         const int btnT = contMidYW - btnH / 2;
         int x = contLeftX;
         //--- 1. Checkbox hit (key 1)
         if(StringLen(subprop.subVisibleId) > 0)
           {
            if(lx >= x && lx < x + chkSize && ly >= chkT && ly < chkT + chkSize)
              { newCompactSubRow = newRow; newCompactSubButton = 1; }
            x += chkSize + gap;
           }
         //--- 2. Value button hit (key 2)
         if(StringLen(subprop.subValueId) > 0 && newCompactSubButton == 0)
           {
            if(lx >= x && lx < x + valW && ly >= btnT && ly < btnT + btnH)
              { newCompactSubRow = newRow; newCompactSubButton = 2; }
            x += valW + gap;
           }
         else if(StringLen(subprop.subValueId) > 0) x += valW + gap;
         //--- 3. Color cube hit (key 3)
         if(StringLen(subprop.subColorId) > 0 && newCompactSubButton == 0)
           {
            if(lx >= x && lx < x + colW && ly >= btnT && ly < btnT + btnH)
              { newCompactSubRow = newRow; newCompactSubButton = 3; }
            x += colW + gap;
           }
         else if(StringLen(subprop.subColorId) > 0) x += colW + gap;
         //--- 4. Width cube hit (key 4)
         if(StringLen(subprop.subWidthId) > 0 && newCompactSubButton == 0)
           {
            if(lx >= x && lx < x + wW && ly >= btnT && ly < btnT + btnH)
              { newCompactSubRow = newRow; newCompactSubButton = 4; }
            x += wW + gap;
           }
         else if(StringLen(subprop.subWidthId) > 0) x += wW + gap;
         //--- 5. Style cube hit (key 5)
         if(StringLen(subprop.subStyleId) > 0 && newCompactSubButton == 0)
           {
            if(lx >= x && lx < x + sW && ly >= btnT && ly < btnT + btnH)
              { newCompactSubRow = newRow; newCompactSubButton = 5; }
           }
        }
     }

   //--- Commit new hover state + repaint only if something actually changed
   if(newTab != m_hoveredTabIdx
      || newRow != m_hoveredRowIdx
      || newBtn != m_hoveredFooterBtn
      || newClose != m_hoveredCloseBtn
      || newTextCtrl != m_hoveredTextTabCtrl
      || newScrollHover != m_hoveredTextAreaScrollbar
      || newBodyScrollHover != m_hoveredBodyScrollbar
      || newCoordRow != m_coordHoveredRow
      || newCoordField != m_coordHoveredField
      || newCoordStepper != m_coordHoveredStepper
      || newCompactRow != m_compactHoveredRow
      || newCompactStepper != m_compactHoveredStepper
      || newCompactSubRow != m_compactHoveredSubRow
      || newCompactSubButton != m_compactHoveredSubButton)
     {
      //--- Update every hover flag
      m_hoveredTabIdx            = newTab;
      m_hoveredRowIdx            = newRow;
      m_hoveredFooterBtn         = newBtn;
      m_hoveredCloseBtn          = newClose;
      m_hoveredTextTabCtrl       = newTextCtrl;
      m_hoveredTextAreaScrollbar = newScrollHover;
      m_hoveredBodyScrollbar     = newBodyScrollHover;
      m_coordHoveredRow          = newCoordRow;
      m_coordHoveredField        = newCoordField;
      m_coordHoveredStepper      = newCoordStepper;
      m_compactHoveredRow        = newCompactRow;
      m_compactHoveredStepper    = newCompactStepper;
      m_compactHoveredSubRow     = newCompactSubRow;
      m_compactHoveredSubButton  = newCompactSubButton;
      RedrawSettings(); ChartRedraw();
     }
   return true;
  }

//+------------------------------------------------------------------+
//| SettingsMouseUp - end any active drag (window or scrollbar)      |
//+------------------------------------------------------------------+
bool CSettingsWindow::SettingsMouseUp()
  {
   //--- "Consumed" tracking - true if any drag was active
   bool consumed = false;
   //--- End each of the three possible drags + flag consumed
   if(m_isDraggingSettings)    { m_isDraggingSettings    = false; consumed = true; }
   if(m_textAreaThumbDragging) { m_textAreaThumbDragging = false; consumed = true; }
   if(m_bodyThumbDragging)     { m_bodyThumbDragging     = false; consumed = true; }
   //--- Repaint once if a drag ended (so the thumb returns to its idle color)
   if(consumed) { RedrawSettings(); ChartRedraw(); }
   return consumed;
  }

//--- Coords tab row geometry (heights / button widths / stepper widths)
#define COORDS_ROW_H         32
#define COORDS_ROW_GAP        8
#define COORDS_LABEL_W       100
#define COORDS_BTN_GAP        6
#define COORDS_BTN_H         24
#define COORDS_STEPPER_W     16

//+------------------------------------------------------------------+
//| Coords row rect (offset by body scroll, padded by window pad-X)  |
//+------------------------------------------------------------------+
void CSettingsWindow::GetCoordRowRect(int rowIdx, int &outL, int &outT, int &outR, int &outB)
  {
   //--- Rows start below header+tabs, indexed by rowIdx, offset by scroll
   const int rowsTop = m_settingsHeaderH + m_settingsTabBarH;
   outL = m_settingsPadX;
   outR = m_settingsWidth - m_settingsPadX;
   outT = rowsTop + rowIdx * (COORDS_ROW_H + COORDS_ROW_GAP) - m_bodyScrollPx;
   outB = outT + COORDS_ROW_H;
  }

//+------------------------------------------------------------------+
//| Price button rect (left half of the two-button cluster on a row) |
//+------------------------------------------------------------------+
void CSettingsWindow::GetCoordPriceButtonRect(int rowIdx, int &outL, int &outT, int &outR, int &outB)
  {
   //--- Row bounds + label-W carve-out at the left + 2 equal buttons in remaining space
   int rL, rT, rR, rB;
   GetCoordRowRect(rowIdx, rL, rT, rR, rB);
   const int btnsL = rL + COORDS_LABEL_W;
   const int btnsR = rR;
   const int btnW  = (btnsR - btnsL - COORDS_BTN_GAP) / 2;
   //--- Price button = left button
   outL = btnsL; outR = outL + btnW;
   outT = rT + (COORDS_ROW_H - COORDS_BTN_H) / 2;
   outB = outT + COORDS_BTN_H;
  }

//+------------------------------------------------------------------+
//| Time button rect (right half of the two-button cluster)          |
//+------------------------------------------------------------------+
void CSettingsWindow::GetCoordTimeButtonRect(int rowIdx, int &outL, int &outT, int &outR, int &outB)
  {
   //--- Same geometry, but right-aligned (right button of the pair)
   int rL, rT, rR, rB;
   GetCoordRowRect(rowIdx, rL, rT, rR, rB);
   const int btnsL = rL + COORDS_LABEL_W;
   const int btnsR = rR;
   const int btnW  = (btnsR - btnsL - COORDS_BTN_GAP) / 2;
   //--- Time button = right button (anchored to btnsR, extending left by btnW)
   outR = btnsR; outL = outR - btnW;
   outT = rT + (COORDS_ROW_H - COORDS_BTN_H) / 2;
   outB = outT + COORDS_BTN_H;
  }

//+------------------------------------------------------------------+
//| Coords stepper rect (up/down chevron inside price or time button)|
//+------------------------------------------------------------------+
void CSettingsWindow::GetCoordStepperRect(int rowIdx, int field, int dir,
                                            int &outL, int &outT, int &outR, int &outB)
  {
   //--- Resolve the parent button rect based on the field (1=price, 2=time)
   int bL, bT, bR, bB;
   if(field == 1) GetCoordPriceButtonRect(rowIdx, bL, bT, bR, bB);
   else           GetCoordTimeButtonRect(rowIdx,  bL, bT, bR, bB);
   //--- Stepper sits on the right edge of the button (same convention as compact-row stepper)
   outR = bR - 2;
   outL = outR - COORDS_STEPPER_W;
   const int halfH = (bB - bT) / 2;
   //--- dir=0 -> upper half (increment), dir=1 -> lower half (decrement)
   if(dir == 0) { outT = bT + 2; outB = bT + halfH; }
   else         { outT = bT + halfH; outB = bB - 2; }
  }

//+------------------------------------------------------------------+
//| Hit-test against Coords-tab rows + fields + steppers             |
//+------------------------------------------------------------------+
bool CSettingsWindow::HitTestCoordsTab(int lx, int ly,
                                         int &outRow, int &outField, int &outStepper)
  {
   //--- Initialize out-params to "no hit" sentinels
   outRow = -1; outField = 0; outStepper = 0;
   //--- Reject hits outside the body viewport
   const int viewportT = m_settingsHeaderH + m_settingsTabBarH;
   const int viewportB = viewportT + m_bodyViewportH;
   if(ly < viewportT || ly >= viewportB) return false;
   //--- Walk each point's row; bail when row found (returns true with field+stepper set)
   const int pointCount = GetObjectPointCount(m_settingsOwnerObjectId);
   for(int r = 0; r < pointCount; r++)
     {
      //--- Skip rows that don't contain ly
      int rL, rT, rR, rB;
      GetCoordRowRect(r, rL, rT, rR, rB);
      if(ly < rT || ly >= rB) continue;
      outRow = r;
      //--- Check both fields (1=price, 2=time) for stepper hits first (chevrons take priority)
      int sL, sT, sR, sB;
      for(int f = 1; f <= 2; f++)
        {
         //--- Up-stepper hit: stepper key 1 (price up) or 3 (time up)
         GetCoordStepperRect(r, f, 0, sL, sT, sR, sB);
         if(lx >= sL && lx < sR && ly >= sT && ly < sB)
           { outField = f; outStepper = (f == 1) ? 1 : 3; return true; }
         //--- Down-stepper hit: stepper key 2 (price down) or 4 (time down)
         GetCoordStepperRect(r, f, 1, sL, sT, sR, sB);
         if(lx >= sL && lx < sR && ly >= sT && ly < sB)
           { outField = f; outStepper = (f == 1) ? 2 : 4; return true; }
        }
      //--- Then check field hits (price text area)
      int pL, pT, pR, pB;
      GetCoordPriceButtonRect(r, pL, pT, pR, pB);
      if(lx >= pL && lx < pR && ly >= pT && ly < pB)
        { outField = 1; return true; }
      //--- Then time text area
      GetCoordTimeButtonRect(r, pL, pT, pR, pB);
      if(lx >= pL && lx < pR && ly >= pT && ly < pB)
        { outField = 2; return true; }
      //--- Row hit but no field hit (clicked the label) - still return true with field=0
      return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
//| Format a price for display (uses symbol digits for precision)    |
//+------------------------------------------------------------------+
string CSettingsWindow::FormatPriceForDisplay(double price)
  {
   //--- Use the symbol's tick-digit precision
   const int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   return DoubleToString(price, digits);
  }

//+------------------------------------------------------------------+
//| Format a time as a bar index (relative to current chart period)  |
//+------------------------------------------------------------------+
string CSettingsWindow::FormatBarForDisplay(datetime time)
  {
   //--- iBarShift returns -1 for times in the future; clamp to 0
   int bar = iBarShift(_Symbol, _Period, time, false);
   if(bar < 0) bar = 0;
   return IntegerToString(bar);
  }

//+------------------------------------------------------------------+
//| Start an inline edit on a coordinate field (price or time)       |
//+------------------------------------------------------------------+
void CSettingsWindow::StartCoordEdit(int pointIdx, int field)
  {
   //--- Commit any existing edit before starting a new one
   if(m_coordEditPointIdx >= 0) CommitCoordEdit();
   //--- Build the initial edit buffer from the current property value
   string buf = "";
   if(field == 1)
     {
      //--- Price field: read price + format with symbol digits
      double p = 0.0;
      if(GetObjectPointPrice(m_settingsOwnerObjectId, pointIdx, p))
         buf = FormatPriceForDisplay(p);
     }
   else if(field == 2)
     {
      //--- Time field: read time + format as a bar shift
      datetime t = 0;
      if(GetObjectPointTime(m_settingsOwnerObjectId, pointIdx, t))
         buf = FormatBarForDisplay(t);
     }
   //--- Initialize the edit state (caret at end of buffer; no selection)
   m_coordEditPointIdx = pointIdx;
   m_coordEditField    = field;
   m_coordEditBuffer   = buf;
   m_coordEditCaretPos = StringLen(buf);
   m_coordSelectionAnchor = -1;
   m_coordEditCaretBlinkOn     = true;
   m_coordEditCaretBlinkLastMs = (uint)GetTickCount();
   //--- Take over keyboard input from the chart while editing
   BeginKeyboardOverride();
  }

//+------------------------------------------------------------------+
//| Commit the current coordinate edit (parse + push to the engine)  |
//+------------------------------------------------------------------+
void CSettingsWindow::CommitCoordEdit()
  {
   //--- No-op when not editing
   if(m_coordEditPointIdx < 0) return;
   //--- Cache edit state locally (cleared below)
   const int  pIdx  = m_coordEditPointIdx;
   const int  field = m_coordEditField;
   const string buf = m_coordEditBuffer;
   if(field == 1)
     {
      //--- Price field: trim + replace "," with "." (Euro-locale tolerance) + parse double + push
      string trimmed = buf;
      StringTrimLeft(trimmed); StringTrimRight(trimmed);
      StringReplace(trimmed, ",", ".");
      const double newPrice = StringToDouble(trimmed);
      //--- Only push when the buffer wasn't empty (preserves the original value on accidental clears)
      if(StringLen(trimmed) > 0)
         SetObjectPointPrice(m_settingsOwnerObjectId, pIdx, newPrice, false);
     }
   else if(field == 2)
     {
      //--- Time field: trim + parse int as bar shift + clamp >= 0 + convert to datetime via iTime
      string trimmed = buf;
      StringTrimLeft(trimmed); StringTrimRight(trimmed);
      const int newBar = (int)StringToInteger(trimmed);
      const int clamped = (newBar < 0) ? 0 : newBar;
      const datetime newTime = iTime(_Symbol, _Period, clamped);
      //--- Only push when iTime returned a valid timestamp (guards against unloaded history)
      if(newTime > 0)
         SetObjectPointTime(m_settingsOwnerObjectId, pIdx, newTime, false);
     }
   //--- Clear edit state + release keyboard override
   m_coordEditPointIdx = -1; m_coordEditField = 0;
   m_coordEditBuffer   = ""; m_coordEditCaretPos = 0;
   m_coordSelectionAnchor = -1;
   EndKeyboardOverride();
   //--- Repaint to remove the focus border + caret
   if(m_isSettingsVisible) RedrawSettings();
  }

//+------------------------------------------------------------------+
//| Cancel the current coordinate edit (drop buffer without saving)  |
//+------------------------------------------------------------------+
void CSettingsWindow::CancelCoordEdit()
  {
   //--- No-op when not editing
   if(m_coordEditPointIdx < 0) return;
   //--- Clear edit state without committing anything
   m_coordEditPointIdx = -1; m_coordEditField = 0;
   m_coordEditBuffer   = ""; m_coordEditCaretPos = 0;
   m_coordSelectionAnchor = -1;
   EndKeyboardOverride();
   if(m_isSettingsVisible) RedrawSettings();
  }

//+------------------------------------------------------------------+
//| Begin a float-value inline edit (steppers + numeric input)       |
//+------------------------------------------------------------------+
void CSettingsWindow::BeginFloatEdit(string propId, int decimals,
                                      double minValue, double maxValue)
  {
   //--- Commit any in-progress edits before starting a new one (only one at a time)
   if(IsEditingCoord()) CommitCoordEdit();
   if(IsEditingFloat()) CommitFloatEdit();
   //--- Initialize edit state (clamp decimals to [0, 6])
   m_floatEditPropId   = propId;
   m_floatEditDecimals = (decimals < 0) ? 0 : (decimals > 6 ? 6 : decimals);
   m_floatEditMinValue = minValue;
   m_floatEditMaxValue = maxValue;
   //--- Read current value + format into the edit buffer
   double cur = 0.0;
   GetObjectProperty(m_settingsOwnerObjectId, propId, cur);
   m_floatEditBuffer       = DoubleToString(cur, m_floatEditDecimals);
   m_floatEditCaretPos     = StringLen(m_floatEditBuffer);
   m_floatSelectionAnchor  = -1;
   m_floatEditCaretBlinkOn = true;
   //--- Microseconds / 1000 for sub-ms blink timing precision
   m_floatEditCaretBlinkLastMs = (uint)GetMicrosecondCount() / 1000;
   //--- Take over keyboard input
   BeginKeyboardOverride();
  }

//+------------------------------------------------------------------+
//| Commit float edit (parse buffer + clamp to [min, max] + push)    |
//+------------------------------------------------------------------+
void CSettingsWindow::CommitFloatEdit()
  {
   //--- No-op when not editing
   if(!IsEditingFloat()) return;
   //--- Trim + Euro-locale tolerance ("," -> ".")
   string buf = m_floatEditBuffer;
   StringTrimLeft(buf); StringTrimRight(buf);
   StringReplace(buf, ",", ".");
   //--- Only push when buffer wasn't empty (preserves original on accidental clears)
   if(StringLen(buf) > 0)
     {
      //--- Parse + clamp to [min, max] + push
      double parsed = StringToDouble(buf);
      if(parsed < m_floatEditMinValue) parsed = m_floatEditMinValue;
      if(parsed > m_floatEditMaxValue) parsed = m_floatEditMaxValue;
      SetObjectProperty(m_settingsOwnerObjectId, m_floatEditPropId, parsed, false);
     }
   //--- Clear edit state + release keyboard
   m_floatEditPropId   = ""; m_floatEditBuffer = "";
   m_floatEditCaretPos = 0;  m_floatSelectionAnchor = -1;
   EndKeyboardOverride();
   if(m_isSettingsVisible) RedrawSettings();
  }

//+------------------------------------------------------------------+
//| Cancel float edit (drop buffer without saving)                   |
//+------------------------------------------------------------------+
void CSettingsWindow::CancelFloatEdit()
  {
   //--- No-op when not editing
   if(!IsEditingFloat()) return;
   //--- Clear state without committing
   m_floatEditPropId   = ""; m_floatEditBuffer = "";
   m_floatEditCaretPos = 0;  m_floatSelectionAnchor = -1;
   EndKeyboardOverride();
   if(m_isSettingsVisible) RedrawSettings();
  }

//+------------------------------------------------------------------+
//| HandleFloatKey - keyboard handler for float-value inline edit    |
//+------------------------------------------------------------------+
bool CSettingsWindow::HandleFloatKey(uint vk)
  {
   //--- No-op when not editing a float
   if(!IsEditingFloat()) return false;
   //--- Shift-key state (TERMINAL_KEYSTATE_SHIFT high bit set = shift held)
   const int  shiftRaw = (int)TerminalInfoInteger(TERMINAL_KEYSTATE_SHIFT);
   const bool shiftDown = (shiftRaw < 0) || ((shiftRaw & 0x8000) != 0);
   //--- Enter or Tab commits + Esc cancels
   if(vk == 13 || vk == 9) { CommitFloatEdit(); RedrawSettings(); return true; }
   if(vk == 27)            { CancelFloatEdit(); RedrawSettings(); return true; }

   //--- Selection-delete: runs upfront for keys that should consume a selection (sets floatSelDeleted true if a range was removed)
   bool floatSelDeleted = false;
   if(m_floatSelectionAnchor >= 0 && m_floatSelectionAnchor != m_floatEditCaretPos
      && (vk == 8 || vk == 46
          || (vk >= 48 && vk <= 57) || (vk >= 96 && vk <= 105)
          || vk == 190 || vk == 110 || vk == 189 || vk == 109))
     {
      //--- Compute selection bounds (min..max) then splice out the selected range
      const int fds  = (m_floatSelectionAnchor < m_floatEditCaretPos) ? m_floatSelectionAnchor : m_floatEditCaretPos;
      const int fde  = (m_floatSelectionAnchor > m_floatEditCaretPos) ? m_floatSelectionAnchor : m_floatEditCaretPos;
      const int fdl  = StringLen(m_floatEditBuffer);
      m_floatEditBuffer   = ((fds > 0) ? StringSubstr(m_floatEditBuffer, 0, fds) : "")
                          + ((fde < fdl) ? StringSubstr(m_floatEditBuffer, fde, fdl - fde) : "");
      m_floatEditCaretPos = fds;
      m_floatSelectionAnchor = -1;
      floatSelDeleted = true;
     }

   //--- Backspace (vk 8): if a selection was deleted above, we're done; otherwise delete one char before caret
   if(vk == 8)
     {
      if(floatSelDeleted) { RedrawSettings(); return true; }
      if(m_floatEditCaretPos > 0)
        {
         //--- Splice out the char before the caret
         const string before = StringSubstr(m_floatEditBuffer, 0, m_floatEditCaretPos - 1);
         const string after  = StringSubstr(m_floatEditBuffer, m_floatEditCaretPos);
         m_floatEditBuffer = before + after;
         m_floatEditCaretPos--;
         RedrawSettings();
        }
      return true;
     }
   //--- Delete (vk 46): similar but removes char AFTER the caret
   if(vk == 46)
     {
      if(floatSelDeleted) { RedrawSettings(); return true; }
      const int len = StringLen(m_floatEditBuffer);
      if(m_floatEditCaretPos < len)
        {
         m_floatEditBuffer = StringSubstr(m_floatEditBuffer, 0, m_floatEditCaretPos)
                           + StringSubstr(m_floatEditBuffer, m_floatEditCaretPos + 1);
         RedrawSettings();
        }
      return true;
     }
   //--- Left arrow (vk 37): caret left, with shift = extend selection
   if(vk == 37)
     {
      if(shiftDown)
        {
         //--- Begin selection from caret if none active; then move caret left
         if(m_floatSelectionAnchor < 0) m_floatSelectionAnchor = m_floatEditCaretPos;
         if(m_floatEditCaretPos > 0) m_floatEditCaretPos--;
        }
      else
        {
         //--- No shift: if there's an active selection, collapse to its left edge; otherwise move caret
         if(m_floatSelectionAnchor >= 0 && m_floatSelectionAnchor != m_floatEditCaretPos)
           { m_floatEditCaretPos = (m_floatSelectionAnchor < m_floatEditCaretPos) ? m_floatSelectionAnchor : m_floatEditCaretPos; m_floatSelectionAnchor = -1; }
         else if(m_floatEditCaretPos > 0) m_floatEditCaretPos--;
        }
      RedrawSettings(); return true;
     }
   //--- Right arrow (vk 39): mirror of Left
   if(vk == 39)
     {
      if(shiftDown)
        {
         //--- Begin selection + move caret right
         if(m_floatSelectionAnchor < 0) m_floatSelectionAnchor = m_floatEditCaretPos;
         if(m_floatEditCaretPos < StringLen(m_floatEditBuffer)) m_floatEditCaretPos++;
        }
      else
        {
         //--- Collapse to right edge or move caret right
         if(m_floatSelectionAnchor >= 0 && m_floatSelectionAnchor != m_floatEditCaretPos)
           { m_floatEditCaretPos = (m_floatSelectionAnchor > m_floatEditCaretPos) ? m_floatSelectionAnchor : m_floatEditCaretPos; m_floatSelectionAnchor = -1; }
         else if(m_floatEditCaretPos < StringLen(m_floatEditBuffer)) m_floatEditCaretPos++;
        }
      RedrawSettings(); return true;
     }
   //--- Home (vk 36): caret to start, with shift = extend selection
   if(vk == 36)
     {
      if(shiftDown) { if(m_floatSelectionAnchor < 0) m_floatSelectionAnchor = m_floatEditCaretPos; }
      else m_floatSelectionAnchor = -1;
      m_floatEditCaretPos = 0; RedrawSettings(); return true;
     }
   //--- End (vk 35): caret to end, with shift = extend selection
   if(vk == 35)
     {
      if(shiftDown) { if(m_floatSelectionAnchor < 0) m_floatSelectionAnchor = m_floatEditCaretPos; }
      else m_floatSelectionAnchor = -1;
      m_floatEditCaretPos = StringLen(m_floatEditBuffer); RedrawSettings(); return true;
     }

   //--- Printable char insert: digits (top row 48-57 or numpad 96-105), dot (190/110), minus (189/109)
   string ch = "";
   if(vk >= 48 && vk <= 57)        ch = CharToString((uchar)vk);
   else if(vk >= 96 && vk <= 105)  ch = CharToString((uchar)(vk - 48));
   else if(vk == 190 || vk == 110) ch = ".";
   else if(vk == 189 || vk == 109) ch = "-";
   if(StringLen(ch) > 0)
     {
      //--- Selection already deleted above for printable keys; reject duplicate "." and "-" anywhere but pos 0
      if(ch == "." && StringFind(m_floatEditBuffer, ".") >= 0) return true;
      if(ch == "-" && m_floatEditCaretPos != 0) return true;
      //--- Insert the character at the caret position + advance caret
      m_floatEditBuffer = StringSubstr(m_floatEditBuffer, 0, m_floatEditCaretPos)
                        + ch
                        + StringSubstr(m_floatEditBuffer, m_floatEditCaretPos);
      m_floatEditCaretPos++;
      RedrawSettings(); return true;
     }
   //--- Key didn't match any handler - report unhandled
   return false;
  }

//+------------------------------------------------------------------+
//| Open a popover for a Settings sub-widget (color/width/style cube)|
//+------------------------------------------------------------------+
void CSettingsWindow::OpenSettingsSubPopover(string propId, int anchorX, int anchorY,
                                               int flipBaseTop)
  {
   //--- Bail on empty propId
   if(StringLen(propId) == 0) return;
   //--- Mirror Settings-state into Ribbon-state so the popover renderer sees our properties
   m_ribbonOwnerObjectId         = m_settingsOwnerObjectId;
   m_popoverSnapshotIsExternal   = true;
   ArrayResize(m_ribbonProperties, 0);
   //--- Copy every settings property into the ribbon property list
   const int n = ArraySize(m_settingsProperties);
   for(int i = 0; i < n; i++)
     {
      const int sz = ArraySize(m_ribbonProperties);
      ArrayResize(m_ribbonProperties, sz + 1);
      m_ribbonProperties[sz] = m_settingsProperties[i];
     }
   //--- Check if the target propId is already in the list (it usually is for top-level props)
   bool found = false;
   for(int j = 0; j < ArraySize(m_ribbonProperties); j++)
      if(m_ribbonProperties[j].id == propId) { found = true; break; }
   //--- Not found: synthesize a minimal descriptor for sub-widget propIds like "level:0:color"
   if(!found)
     {
      const int sz = ArraySize(m_ribbonProperties);
      ArrayResize(m_ribbonProperties, sz + 1);
      m_ribbonProperties[sz].id    = propId;
      m_ribbonProperties[sz].label = "";
      //--- Infer the type from the propId suffix (Color/Width/Style or :color/:width/:style)
      if(StringFind(propId, "Color") >= 0 || StringFind(propId, ":color") >= 0)
         m_ribbonProperties[sz].type = PROP_COLOR;
      else if(StringFind(propId, "Width") >= 0 || StringFind(propId, ":width") >= 0)
         m_ribbonProperties[sz].type = PROP_LINE_WIDTH;
      else if(StringFind(propId, "Style") >= 0 || StringFind(propId, ":style") >= 0)
         m_ribbonProperties[sz].type = PROP_LINE_STYLE;
      else
         //--- Fallback to color when the suffix doesn't match
         m_ribbonProperties[sz].type = PROP_COLOR;
      m_ribbonProperties[sz].group        = "Style";
      m_ribbonProperties[sz].showInRibbon = false;
      m_ribbonProperties[sz].showInSettings = true;
     }
   //--- Open the popover at the anchor + repaint
   ShowPopoverForProperty(propId, anchorX, anchorY, flipBaseTop);
   RedrawSettings();
  }

//+------------------------------------------------------------------+
//| Apply a one-step nudge to a coordinate field (price or time)     |
//+------------------------------------------------------------------+
void CSettingsWindow::ApplyCoordStep(int pointIdx, int field, int dir)
  {
   //--- Commit any active edit on the same field first (so the new value is based on the engine state)
   if(m_coordEditPointIdx == pointIdx && m_coordEditField == field)
      CommitCoordEdit();
   if(field == 1)
     {
      //--- Price step: +/- 1 point (smallest tradable increment for the symbol)
      double p = 0.0;
      if(!GetObjectPointPrice(m_settingsOwnerObjectId, pointIdx, p)) return;
      const double step = _Point;
      const double newP = (dir == 0) ? (p + step) : (p - step);
      SetObjectPointPrice(m_settingsOwnerObjectId, pointIdx, newP, false);
     }
   else if(field == 2)
     {
      //--- Time step: +/- 1 bar (dir=0 = newer/older convention follows the chevron direction)
      datetime t = 0;
      if(!GetObjectPointTime(m_settingsOwnerObjectId, pointIdx, t)) return;
      int bar = iBarShift(_Symbol, _Period, t, false);
      //--- Clamp bar to 0 (current bar) if iBarShift returned -1
      if(bar < 0) bar = 0;
      //--- dir=0 -> newer bar (lower bar index), dir=1 -> older bar (higher bar index)
      const int newBar = (dir == 0) ? MathMax(0, bar - 1) : (bar + 1);
      const datetime newT = iTime(_Symbol, _Period, newBar);
      if(newT > 0)
         SetObjectPointTime(m_settingsOwnerObjectId, pointIdx, newT, false);
     }
  }

//+------------------------------------------------------------------+
//| Position coord-edit caret at the click X (text-width based scan) |
//+------------------------------------------------------------------+
void CSettingsWindow::PositionCoordCaretFromClickX(int lx)
  {
   //--- No-op when not editing a coord
   if(m_coordEditPointIdx < 0) return;
   //--- Resolve the field button rect to derive textStartX (8 px from chip-left for price/time text)
   int bL, bT, bR, bB;
   if(m_coordEditField == 1)
      GetCoordPriceButtonRect(m_coordEditPointIdx, bL, bT, bR, bB);
   else
      GetCoordTimeButtonRect(m_coordEditPointIdx, bL, bT, bR, bB);
   const int textStartX = bL + 6;
   //--- Click X relative to the text start
   const int clickXInContent = lx - textStartX;
   const int bufLen = StringLen(m_coordEditBuffer);
   //--- Click before the text -> caret at 0
   if(clickXInContent <= 0) { m_coordEditCaretPos = 0; return; }
   m_canvasSettings.FontSet("Arial", -100);
   //--- Find the largest col where segWidth <= clickX
   int bestCol = 0;
   for(int col = 0; col <= bufLen; col++)
     {
      const string seg = StringSubstr(m_coordEditBuffer, 0, col);
      const int segW = m_canvasSettings.TextWidth(seg);
      if(segW <= clickXInContent) bestCol = col;
      else break;
     }
   //--- Round to nearest char boundary (compare against midpoint of segNow + segNext)
   if(bestCol < bufLen)
     {
      const string segNow  = StringSubstr(m_coordEditBuffer, 0, bestCol);
      const string segNext = StringSubstr(m_coordEditBuffer, 0, bestCol + 1);
      const int midX = (m_canvasSettings.TextWidth(segNow) + m_canvasSettings.TextWidth(segNext)) / 2;
      if(clickXInContent >= midX) bestCol++;
     }
   //--- Clamp + commit caret position + reset caret-blink to visible
   if(bestCol < 0)       bestCol = 0;
   if(bestCol > bufLen)  bestCol = bufLen;
   m_coordEditCaretPos    = bestCol;
   m_coordSelectionAnchor = -1;
   m_coordEditCaretBlinkOn     = true;
   m_coordEditCaretBlinkLastMs = (uint)GetTickCount();
  }

//+------------------------------------------------------------------+
//| Position float-edit caret at the click X (similar logic)         |
//+------------------------------------------------------------------+
void CSettingsWindow::PositionFloatCaretFromClickX(int lx, int textStartX)
  {
   //--- No-op when not editing a float
   if(!IsEditingFloat()) return;
   //--- Click X relative to the text start (caller passes textStartX since chip layout varies)
   const int clickXInContent = lx - textStartX;
   const int bufLen = StringLen(m_floatEditBuffer);
   //--- Click before the text -> caret at 0
   if(clickXInContent <= 0) { m_floatEditCaretPos = 0; return; }
   m_canvasSettings.FontSet("Arial", -100);
   //--- Find the largest col where segWidth <= clickX
   int bestCol = 0;
   for(int col = 0; col <= bufLen; col++)
     {
      const string seg = StringSubstr(m_floatEditBuffer, 0, col);
      if(m_canvasSettings.TextWidth(seg) <= clickXInContent) bestCol = col;
      else break;
     }
   //--- Round to nearest char boundary
   if(bestCol < bufLen)
     {
      const string segNow  = StringSubstr(m_floatEditBuffer, 0, bestCol);
      const string segNext = StringSubstr(m_floatEditBuffer, 0, bestCol + 1);
      const int midX = (m_canvasSettings.TextWidth(segNow) + m_canvasSettings.TextWidth(segNext)) / 2;
      if(clickXInContent >= midX) bestCol++;
     }
   //--- Clamp + commit caret position + reset caret-blink to visible
   if(bestCol < 0)      bestCol = 0;
   if(bestCol > bufLen) bestCol = bufLen;
   m_floatEditCaretPos    = bestCol;
   m_floatSelectionAnchor = -1;
   m_floatEditCaretBlinkOn     = true;
   m_floatEditCaretBlinkLastMs = (uint)GetTickCount();
  }

//+------------------------------------------------------------------+
//| HandleCoordKey - keyboard handler for coord-edit (price/time)    |
//+------------------------------------------------------------------+
bool CSettingsWindow::HandleCoordKey(uint vk)
  {
   //--- No-op when not editing a coord
   if(m_coordEditPointIdx < 0) return false;
   //--- Shift-key state (same convention as HandleFloatKey)
   const int  shiftRaw = (int)TerminalInfoInteger(TERMINAL_KEYSTATE_SHIFT);
   const bool shiftDown = (shiftRaw < 0) || ((shiftRaw & 0x8000) != 0);

   //--- Enter commits + Esc cancels
   if(vk == 13) { CommitCoordEdit(); RedrawSettings(); ChartRedraw(); return true; }
   if(vk == 27) { CancelCoordEdit(); RedrawSettings(); ChartRedraw(); return true; }

   //--- Selection-delete: runs upfront for keys that should consume a selection (sets coordSelDeleted true if a range was removed)
   bool coordSelDeleted = false;
   if(m_coordSelectionAnchor >= 0 && m_coordSelectionAnchor != m_coordEditCaretPos
      && (vk == 8 || vk == 46
          || (vk >= 48 && vk <= 57) || (vk >= 96 && vk <= 105)
          || vk == 190 || vk == 110 || vk == 189 || vk == 109))
     {
      //--- Compute selection bounds + splice out the range (same pattern as HandleFloatKey)
      const int cds  = (m_coordSelectionAnchor < m_coordEditCaretPos) ? m_coordSelectionAnchor : m_coordEditCaretPos;
      const int cde  = (m_coordSelectionAnchor > m_coordEditCaretPos) ? m_coordSelectionAnchor : m_coordEditCaretPos;
      const int cdl  = StringLen(m_coordEditBuffer);
      m_coordEditBuffer   = ((cds > 0) ? StringSubstr(m_coordEditBuffer, 0, cds) : "")
                          + ((cde < cdl) ? StringSubstr(m_coordEditBuffer, cde, cdl - cde) : "");
      m_coordEditCaretPos = cds;
      m_coordSelectionAnchor = -1;
      coordSelDeleted = true;
     }

   //--- Left arrow (vk 37): caret left + selection handling
   if(vk == 37)
     {
      if(shiftDown) { if(m_coordSelectionAnchor < 0) m_coordSelectionAnchor = m_coordEditCaretPos; if(m_coordEditCaretPos > 0) m_coordEditCaretPos--; }
      else { if(m_coordSelectionAnchor >= 0 && m_coordSelectionAnchor != m_coordEditCaretPos) { m_coordEditCaretPos = (m_coordSelectionAnchor < m_coordEditCaretPos) ? m_coordSelectionAnchor : m_coordEditCaretPos; m_coordSelectionAnchor = -1; } else if(m_coordEditCaretPos > 0) m_coordEditCaretPos--; }
      //--- Reset caret blink to visible on any movement
      m_coordEditCaretBlinkOn = true; m_coordEditCaretBlinkLastMs = (uint)GetTickCount();
      RedrawSettings(); ChartRedraw(); return true;
     }
   //--- Right arrow (vk 39): caret right + selection handling (mirror of Left)
   if(vk == 39)
     {
      if(shiftDown) { if(m_coordSelectionAnchor < 0) m_coordSelectionAnchor = m_coordEditCaretPos; if(m_coordEditCaretPos < StringLen(m_coordEditBuffer)) m_coordEditCaretPos++; }
      else { if(m_coordSelectionAnchor >= 0 && m_coordSelectionAnchor != m_coordEditCaretPos) { m_coordEditCaretPos = (m_coordSelectionAnchor > m_coordEditCaretPos) ? m_coordSelectionAnchor : m_coordEditCaretPos; m_coordSelectionAnchor = -1; } else if(m_coordEditCaretPos < StringLen(m_coordEditBuffer)) m_coordEditCaretPos++; }
      m_coordEditCaretBlinkOn = true; m_coordEditCaretBlinkLastMs = (uint)GetTickCount();
      RedrawSettings(); ChartRedraw(); return true;
     }
   //--- Home (vk 36): caret to start
   if(vk == 36)
     {
      if(shiftDown) { if(m_coordSelectionAnchor < 0) m_coordSelectionAnchor = m_coordEditCaretPos; } else m_coordSelectionAnchor = -1;
      m_coordEditCaretPos = 0; RedrawSettings(); ChartRedraw(); return true;
     }
   //--- End (vk 35): caret to end
   if(vk == 35)
     {
      if(shiftDown) { if(m_coordSelectionAnchor < 0) m_coordSelectionAnchor = m_coordEditCaretPos; } else m_coordSelectionAnchor = -1;
      m_coordEditCaretPos = StringLen(m_coordEditBuffer); RedrawSettings(); ChartRedraw(); return true;
     }
   //--- Backspace (vk 8): delete char before caret (or consume selection)
   if(vk == 8)
     {
      if(coordSelDeleted) { m_coordEditCaretBlinkOn = true; m_coordEditCaretBlinkLastMs = (uint)GetTickCount(); RedrawSettings(); ChartRedraw(); return true; }
      if(m_coordEditCaretPos > 0)
        {
         //--- Splice out the char before the caret
         const int len = StringLen(m_coordEditBuffer);
         m_coordEditBuffer = StringSubstr(m_coordEditBuffer, 0, m_coordEditCaretPos - 1)
                           + ((m_coordEditCaretPos < len) ? StringSubstr(m_coordEditBuffer, m_coordEditCaretPos, len - m_coordEditCaretPos) : "");
         m_coordEditCaretPos--;
         m_coordEditCaretBlinkOn = true; m_coordEditCaretBlinkLastMs = (uint)GetTickCount();
         RedrawSettings(); ChartRedraw();
        }
      return true;
     }
   //--- Delete (vk 46): delete char after caret
   if(vk == 46)
     {
      if(coordSelDeleted) { RedrawSettings(); ChartRedraw(); return true; }
      const int len = StringLen(m_coordEditBuffer);
      if(m_coordEditCaretPos < len)
        {
         //--- Splice out the char after the caret
         m_coordEditBuffer = StringSubstr(m_coordEditBuffer, 0, m_coordEditCaretPos)
                           + StringSubstr(m_coordEditBuffer, m_coordEditCaretPos + 1, len - m_coordEditCaretPos - 1);
         RedrawSettings(); ChartRedraw();
        }
      return true;
     }

   //--- Printable char insert (digits + "." + "-")
   string ch = "";
   if(vk >= 48 && vk <= 57)       ch = ShortToString((ushort)vk);
   else if(vk >= 96 && vk <= 105) ch = ShortToString((ushort)('0' + (vk - 96)));
   else if(vk == 190 || vk == 110) ch = ".";
   else if(vk == 189 || vk == 109) ch = "-";
   if(StringLen(ch) > 0)
     {
      //--- Selection already deleted above for printable keys; "." only valid in price field (and not duplicate)
      if(ch == ".") { if(m_coordEditField != 1) return true; if(StringFind(m_coordEditBuffer, ".") >= 0) return true; }
      //--- "-" only valid at position 0 (no negative coords inside)
      if(ch == "-" && m_coordEditCaretPos != 0) return true;
      //--- Insert the character at the caret position + advance caret
      const int len = StringLen(m_coordEditBuffer);
      m_coordEditBuffer = StringSubstr(m_coordEditBuffer, 0, m_coordEditCaretPos)
                        + ch
                        + ((m_coordEditCaretPos < len) ? StringSubstr(m_coordEditBuffer, m_coordEditCaretPos, len - m_coordEditCaretPos) : "");
      m_coordEditCaretPos += StringLen(ch);
      m_coordEditCaretBlinkOn = true; m_coordEditCaretBlinkLastMs = (uint)GetTickCount();
      RedrawSettings(); ChartRedraw();
      return true;
     }
   //--- Swallow all other keys while editing
   return true;
  }

//+------------------------------------------------------------------+
//| DrawCoordsTabRows - full render for the Coordinates tab          |
//+------------------------------------------------------------------+
void CSettingsWindow::DrawCoordsTabRows()
  {
   //--- Canvas-space top-left + bound object id + point count + viewport bounds
   const int boxL = m_settingsShadowPad;
   const int boxT = m_settingsShadowPad;
   const int objId = m_settingsOwnerObjectId;
   const int pointCount = GetObjectPointCount(objId);
   const int viewportT = m_settingsHeaderH + m_settingsTabBarH;
   const int viewportB = viewportT + m_bodyViewportH;

   //--- One row per drawn-object point
   for(int r = 0; r < pointCount; r++)
     {
      //--- Skip rows fully above or below the viewport (scroll clipping)
      int rcL, rcT, rcR, rcB;
      GetCoordRowRect(r, rcL, rcT, rcR, rcB);
      if(rcB <= viewportT) continue;
      if(rcT >= viewportB) continue;

      //--- Read the live coordinate values for this point from the engine
      double price = 0.0;
      datetime t = 0;
      GetObjectPointPrice(objId, r, price);
      GetObjectPointTime(objId, r, t);

      //--- Label = "#1 (price, bar)" etc. (left-aligned at pad-X, vertically centered)
      int rL, rT, rR, rB;
      GetCoordRowRect(r, rL, rT, rR, rB);
      m_canvasSettings.FontSet("Arial", -100);
      const string lbl = "#" + IntegerToString(r + 1) + " (price, bar)";
      const int lLH = m_canvasSettings.TextHeight(lbl);
      m_canvasSettings.TextOut(boxL + rL,
                                 boxT + rT + (COORDS_ROW_H - lLH) / 2,
                                 lbl,
                                 ColorToARGB(m_themeColors.flyoutTextColor, 220));

      //--- 2 fields per row: 1=price, 2=time (rendered side-by-side)
      for(int field = 1; field <= 2; field++)
        {
         //--- Field button rect
         int bL, bT, bR, bB;
         if(field == 1) GetCoordPriceButtonRect(r, bL, bT, bR, bB);
         else           GetCoordTimeButtonRect(r,  bL, bT, bR, bB);

         //--- State flags: is this field being edited / is the mouse hovering it
         const bool isEditing = (m_coordEditPointIdx == r && m_coordEditField == field);
         const bool isHov     = (m_coordHoveredRow == r && m_coordHoveredField == field);

         //--- Border color = DodgerBlue focus when editing, separator otherwise
         const uint focusArgb  = ColorToARGB(clrDodgerBlue, 255);
         const uint normalArgb = ColorToARGB(m_themeColors.separatorColor, 255);
         const uint fillArgb   = ColorToARGB(m_themeColors.flyoutBackground, 255);
         //--- Paint button outline + fill
         WidgetStrokeRoundRect(m_canvasSettings,
                                 boxL + bL, boxT + bT, boxL + bR, boxT + bB,
                                 4, 1, isEditing ? focusArgb : normalArgb, fillArgb);
         //--- Editing state: paint a second inner border for emphasis
         if(isEditing)
            WidgetStrokeRoundRect(m_canvasSettings,
                                    boxL + bL + 1, boxT + bT + 1,
                                    boxL + bR - 1, boxT + bB - 1,
                                    3, 1, focusArgb, fillArgb);
         //--- Hover tint when not editing
         if(isHov && !isEditing)
           {
            const uint tintArgb = ColorToARGB(m_themeColors.flyoutTextColor, 28);
            FillNoteRoundRect(m_canvasSettings,
                                boxL + bL + 1, boxT + bT + 1,
                                boxL + bR - 1, boxT + bB - 1,
                                3, tintArgb);
           }

         //--- Display text = edit buffer if editing, formatted price/bar otherwise
         m_canvasSettings.FontSet("Arial", -100);
         string displayText;
         if(isEditing)       displayText = m_coordEditBuffer;
         else if(field == 1) displayText = FormatPriceForDisplay(price);
         else                displayText = FormatBarForDisplay(t);

         //--- Show steppers when hovered OR editing
         const bool showSteppers = (isHov || isEditing);
         //--- Text geometry (6 px left pad, vertically centered)
         const int textLH = m_canvasSettings.TextHeight(displayText);
         const int textY  = boxT + bT + (COORDS_BTN_H - textLH) / 2;
         const int textX  = boxL + bL + 6;

         //--- Render text selection highlight when there's an active selection range
         if(isEditing
            && m_coordSelectionAnchor >= 0
            && m_coordSelectionAnchor != m_coordEditCaretPos)
           {
            //--- Normalize selection bounds + measure pre/in widths
            const int selS = (m_coordSelectionAnchor < m_coordEditCaretPos) ? m_coordSelectionAnchor : m_coordEditCaretPos;
            const int selE = (m_coordSelectionAnchor > m_coordEditCaretPos) ? m_coordSelectionAnchor : m_coordEditCaretPos;
            const string preSel = StringSubstr(m_coordEditBuffer, 0, selS);
            const string inSel  = StringSubstr(m_coordEditBuffer, selS, selE - selS);
            const int preW = (StringLen(preSel) > 0) ? m_canvasSettings.TextWidth(preSel) : 0;
            const int selW = (StringLen(inSel) > 0)  ? m_canvasSettings.TextWidth(inSel)  : 0;
            //--- Paint the highlight at 90 alpha
            const uint selArgb = ColorToARGB(clrDodgerBlue, 90);
            for(int yy = boxT + bT + 3; yy < boxT + bB - 3; yy++)
               for(int xx = textX + preW; xx < textX + preW + selW; xx++)
                  WidgetBlendPixel(m_canvasSettings, xx, yy, selArgb);
           }

         //--- Draw the text on top of the (optional) highlight
         m_canvasSettings.TextOut(textX, textY, displayText,
                                    ColorToARGB(m_themeColors.flyoutTextColor, 230));

         //--- Caret: thin AA line at the caret column when editing + visible blink phase
         if(isEditing && m_coordEditCaretBlinkOn)
           {
            const string seg = StringSubstr(m_coordEditBuffer, 0, m_coordEditCaretPos);
            const int caretX = textX + m_canvasSettings.TextWidth(seg);
            const uint caretArgb = ColorToARGB(m_themeColors.flyoutTextColor, 255);
            WidgetThickLineAA(m_canvasSettings, caretX, boxT + bT + 4,
                                                 caretX, boxT + bB - 4, 1, caretArgb);
           }

         //--- Render steppers (up + down chevrons) when hovered or editing
         if(showSteppers)
           {
            //--- Two stepper directions: 0 = up, 1 = down
            for(int dir = 0; dir <= 1; dir++)
              {
               int sL, sT, sR, sB;
               GetCoordStepperRect(r, field, dir, sL, sT, sR, sB);
               //--- Stepper key naming: field 1 (price) = keys 1/2; field 2 (time) = keys 3/4
               const int stepperKey = (field == 1) ? ((dir == 0) ? 1 : 2) : ((dir == 0) ? 3 : 4);
               const bool stepHov = (m_coordHoveredRow == r && m_coordHoveredStepper == stepperKey);
               if(stepHov)
                 {
                  //--- Subtle hover background behind the stepper
                  const uint stepBgArgb = ColorToARGB(m_themeColors.flyoutTextColor, 45);
                  FillNoteRoundRect(m_canvasSettings,
                                      boxL + sL, boxT + sT, boxL + sR, boxT + sB,
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
        }
     }
   //--- Draw body scrollbar on top when content overflows
   if(m_bodyMaxScrollPx > 0)
      DrawBodyScrollbar();
  }

#endif // TOOLS_PALETTE_SETTINGS_INTERACT_MQH
//+------------------------------------------------------------------+