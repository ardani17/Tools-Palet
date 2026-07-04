//+------------------------------------------------------------------+
//|                                           ToolsPalette_Shell.mqh |
//|                                            Copyright 2026, Om J. |
//|                                               https://t.me/HZFXI |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Om J."
#property link "https://t.me/HZFXI"
#property version "1.00"
#property strict

//--- Guard against multiple inclusion of this header
#ifndef TOOLS_PALETTE_SHELL_MQH
#define TOOLS_PALETTE_SHELL_MQH

//--- Pull in the sidebar/flyout class chain (drags in the entire tool/engine stack)
#include "ToolsPalette_Sidebar.mqh"

//--- Ribbon and Settings classes are pulled in just before CChartEventHandler so the handler sees fully-declared base classes
#include "../ui/ToolsPalette_Ribbon.mqh"
#include "../ui/ToolsPalette_Settings.mqh"

//+------------------------------------------------------------------+
//| CChartEventHandler routes all chart events into sub-handlers     |
//+------------------------------------------------------------------+
class CChartEventHandler : public CSettingsWindow
  {
protected:
   //--- Previous mouse-button state - used to detect press-down edge transitions
   int m_previousMouseButtonState;

protected:
   //--- Dispatch a single chart event to the correct specialized handler
   void RouteChartEvent(const int id, const long &lp, const double &dp, const string &sp, TOOL_TYPE &activeTool);
   //--- Reposition + resize all canvases on CHART_CHANGE
   void OnChartChangeEvent(TOOL_TYPE activeTool);
   //--- Sidebar / flyout wheel scroll on CHARTEVENT_MOUSE_WHEEL
   void OnMouseWheelEvent(int mouseX, int mouseY, int wheelDelta, TOOL_TYPE activeTool);
   //--- Main mouse-move dispatcher (drags, hover, click-down routing)
   void OnMouseMoveEvent(int mouseX, int mouseY, int mouseButtons, TOOL_TYPE &activeTool);
   //--- Continue dragging the sidebar panel as the cursor moves
   void HandlePanelDragMove(int mouseX, int mouseY, TOOL_TYPE activeTool);
   //--- Release the panel drag and snap to nearest edge if applicable
   void HandlePanelDragRelease(TOOL_TYPE activeTool);
   //--- Continue dragging the sidebar's bottom-edge resize handle
   void HandleBottomResizeDrag(int mouseX, int mouseY, TOOL_TYPE activeTool);
   //--- Continue dragging the sidebar's scrollbar thumb
   void HandleSidebarThumbDrag(int mouseX, int mouseY, TOOL_TYPE activeTool);
   //--- Release the sidebar scrollbar thumb drag and clear the dragging flag
   void HandleSidebarThumbRelease(TOOL_TYPE activeTool);
   //--- Continue dragging the flyout's scrollbar thumb
   void HandleFlyoutThumbDrag(int mouseX, int mouseY);
   //--- Release the flyout scrollbar thumb drag and clear the dragging flag
   void HandleFlyoutThumbRelease();
   //--- Recompute ALL hover state for sidebar + flyout and redraw if anything changed
   void UpdateAllHoverStates(int mouseX, int mouseY, bool overSidebar, bool overFlyout,
                              int lx, int ly, int flx, int fly, TOOL_TYPE activeTool);
   //--- Route a fresh left-button press to scrollbar / grip / category / chart paths
   void HandleMouseClickDown(int mouseX, int mouseY, bool overSidebar, bool overFlyout,
                              int lx, int ly, int flx, int fly, TOOL_TYPE &activeTool);
  };

//+------------------------------------------------------------------+
//| Dispatch a chart event to the correct CChartEventHandler method  |
//+------------------------------------------------------------------+
void CChartEventHandler::RouteChartEvent(const int id, const long &lp, const double &dp, const string &sp, TOOL_TYPE &activeTool)
  {
   //--- CHART_CHANGE => repositioning / resizing all sidebar + crosshair canvases
   if(id == CHARTEVENT_CHART_CHANGE) { OnChartChangeEvent(activeTool); return; }
   //--- MOUSE_WHEEL => sidebar / flyout wheel scroll (lp packs the X+Y coords, dp is the delta)
   if(id == CHARTEVENT_MOUSE_WHEEL)  { OnMouseWheelEvent((int)(short)lp, (int)(short)(lp >> 16), (int)dp, activeTool); return; }
   //--- MOUSE_MOVE => the main drag/hover/click dispatcher
   if(id == CHARTEVENT_MOUSE_MOVE)     OnMouseMoveEvent((int)lp, (int)dp, (int)sp, activeTool);
  }

//+------------------------------------------------------------------+
//| Reposition + resize all canvases on a CHART_CHANGE event         |
//+------------------------------------------------------------------+
void CChartEventHandler::OnChartChangeEvent(TOOL_TYPE activeTool)
  {
   //--- Do NOT reset m_previousMouseButtonState - mouse state is owned exclusively by mouse events
   m_isPanelDragging          = false;
   m_isResizingBottomEdge     = false;
   m_isSidebarThumbDragging   = false;
   m_isFlyoutThumbDragging    = false;
   //--- Reset magnifier last-position so the next mouse move forces a fresh draw
   m_lastMagMouseX = -9999;
   m_lastMagMouseY = -9999;
   //--- Only restore chart scroll when NOT in pointer mode (pointer mode owns scroll)
   if(activeTool != TOOL_NONE && activeTool != TOOL_POINTER)
      ChartSetInteger(0, CHART_MOUSE_SCROLL, true);
   //--- Snapped sidebar needs its X-position re-clamped to the chart's new width
   if(m_snapState != SNAP_FLOAT)
     {
      //--- Cache the chart width and re-anchor the sidebar at the snapped edge
      int chartW = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
      m_panelX   = (m_snapState == SNAP_RIGHT) ? chartW - m_sidebarWidth : 0;
      ObjectSetInteger(0, m_nameSidebar, OBJPROP_XDISTANCE, m_panelX);
      //--- Re-clamp the snapped sidebar height against the chart's new available vertical space
      if(m_snappedSidebarHeight > 0)
         m_snappedSidebarHeight = MathMin(m_snappedSidebarHeight,
            (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS) - m_panelY - 8);
      //--- Recompute sidebar height (visible categories), resize canvases, redraw
      CalcSidebarHeight();
      ResizeSidebarCanvases(m_sidebarWidth, m_sidebarHeight);
      DrawSidebar(activeTool);
      //--- If a flyout was open, re-anchor and redraw it against the new sidebar position
      if(m_isFlyoutVisible) ShowFlyout(m_flyoutActiveCat, activeTool);
     }
   //--- Resize crosshair canvases against the new chart dimensions
   OnCrosshairChartChange();
   //--- Resize the drawings canvas against the new chart dimensions
   ResizeDrawingsCanvas();
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| Sidebar / flyout wheel-scroll dispatch on CHARTEVENT_MOUSE_WHEEL |
//+------------------------------------------------------------------+
void CChartEventHandler::OnMouseWheelEvent(int mouseX, int mouseY, int wheelDelta, TOOL_TYPE activeTool)
  {
   //--- Settings text-area first refusal: cursor over focused text area -> wheel scrolls content + locks chart scroll
   if(IsSettingsVisible() && HitTestOverTextArea(mouseX, mouseY))
     {
      ChartSetInteger(0, CHART_MOUSE_SCROLL, false);
      ScrollTextAreaByWheel(wheelDelta);
      return;
     }
   //--- Settings BODY wheel: cursor over scrollable body region (excludes header/footer/tabbar) + has scroll capacity
   if(IsSettingsVisible() && HitTestOverSettingsBody(mouseX, mouseY)
      && SettingsBodyMaxScroll() > 0)
     {
      ChartSetInteger(0, CHART_MOUSE_SCROLL, false);
      ScrollSettingsBodyByWheel(wheelDelta);
      return;
     }

   //--- Resolve local-coordinate flags for sidebar / flyout containment
   int lx, ly, flx, fly;
   bool overSidebar = HitTestOverSidebar(mouseX, mouseY, lx, ly);
   bool overFlyout  = HitTestOverFlyout(mouseX, mouseY, flx, fly);
   //--- Wheel over sidebar AND there are more categories than visible slots: scroll the sidebar
   if(overSidebar && m_sidebarMaxVisibleCats < CAT_COUNT)
     {
      //--- Lock chart scroll while we own the wheel
      ChartSetInteger(0, CHART_MOUSE_SCROLL, false);
      //--- Advance the scroll cursor by MouseScrollSpeed px (clamped to [0, maxScrollPixels])
      m_sidebarScrollPixels = MathMax(0, MathMin(
         m_sidebarScrollPixels + ((wheelDelta < 0) ? MathMax(1, MouseScrollSpeed) : -MathMax(1, MouseScrollSpeed)),
         CalcSidebarMaxScrollPixels()));
      //--- Hide any open flyout (the underlying category may have scrolled out of view)
      HideFlyout(); DrawSidebar(activeTool); ChartRedraw();
      return;
     }
   //--- Wheel over open flyout AND it has more items than visible slots: scroll the flyout
   if(overFlyout && m_isFlyoutVisible && m_flyoutActiveCat != CAT_NONE)
     {
      //--- Cache the active category's tool count for the max-scroll calculation
      int nTools = ArraySize(m_categories[(int)m_flyoutActiveCat].tools);
      if(nTools > m_flyoutMaxVisibleItems)
        {
         //--- Lock chart scroll while we own the wheel
         ChartSetInteger(0, CHART_MOUSE_SCROLL, false);
         //--- Maximum scroll = (hidden items) * item height
         int maxPx = (nTools - m_flyoutMaxVisibleItems) * m_flyoutItemHeight;
         //--- Advance the scroll cursor by MouseScrollSpeed px (clamped to [0, maxPx])
         m_flyoutScrollPixels = MathMax(0, MathMin(
            m_flyoutScrollPixels + ((wheelDelta < 0) ? MathMax(1, MouseScrollSpeed) : -MathMax(1, MouseScrollSpeed)),
            maxPx));
         //--- Redraw the flyout with the new scroll offset
         DrawFlyoutForCategory(m_flyoutActiveCat, activeTool); ChartRedraw();
        }
      return;
     }
   //--- Wheel landed off both sidebar and flyout: re-enable chart scroll
   ChartSetInteger(0, CHART_MOUSE_SCROLL, true);
  }

//+------------------------------------------------------------------+
//| Continue dragging the sidebar panel as the cursor moves          |
//+------------------------------------------------------------------+
void CChartEventHandler::HandlePanelDragMove(int mouseX, int mouseY, TOOL_TYPE activeTool)
  {
   //--- Cache chart dimensions for clamping the panel position to the chart area
   int chartW = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
   int chartH = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
   //--- Compute new panel position relative to drag-offset; clamp to keep panel fully on-screen
   m_panelX = MathMax(0, MathMin(chartW - m_sidebarWidth,  mouseX - m_dragOffsetX));
   m_panelY = MathMax(0, MathMin(chartH - m_sidebarHeight, mouseY - m_dragOffsetY));
   //--- Update the sidebar chart-object's screen position
   ObjectSetInteger(0, m_nameSidebar, OBJPROP_XDISTANCE, m_panelX);
   ObjectSetInteger(0, m_nameSidebar, OBJPROP_YDISTANCE, m_panelY);
   //--- If a flyout is open, re-anchor it against the new sidebar position
   if(m_isFlyoutVisible) ShowFlyout(m_flyoutActiveCat, activeTool);
   //--- Redraw the sidebar at its new location
   DrawSidebar(activeTool); ChartRedraw();
  }

//+------------------------------------------------------------------+
//| Release the panel drag and snap to the nearest edge if applicable|
//+------------------------------------------------------------------+
void CChartEventHandler::HandlePanelDragRelease(TOOL_TYPE activeTool)
  {
   //--- Clear the drag flag and run the edge-snap logic
   m_isPanelDragging = false;
   TrySnapToEdge();
   //--- Recompute sidebar height (snap may change available vertical space), resize canvases, redraw
   CalcSidebarHeight();
   ResizeSidebarCanvases(m_sidebarWidth, m_sidebarHeight);
   DrawSidebar(activeTool);
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| Continue dragging the sidebar's bottom-edge resize handle        |
//+------------------------------------------------------------------+
void CChartEventHandler::HandleBottomResizeDrag(int mouseX, int mouseY, TOOL_TYPE activeTool)
  {
   //--- Cursor delta + chart height for the height-clamping calculation
   int dy      = mouseY - m_bottomResizeDragStartY;
   int chartH  = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
   //--- Natural height (all categories visible) + minimum height (header + 3 category buttons)
   int naturalH = m_headerGripHeight + 8 + CAT_COUNT * (m_categoryButtonSize + 6) - 6 + 10;
   int minH     = m_headerGripHeight + 8 + 10 + 3 * (m_categoryButtonSize + 6) - 6;
   //--- Snapped sidebar caps height at the natural maximum (so empty space below isn't draggable)
   int maxH     = (m_snapState != SNAP_FLOAT)
      ? MathMin(naturalH, chartH - m_panelY - 8)
      : chartH - m_panelY - 8;
   //--- Clamp the new height into the [minH, maxH] range
   int newH = MathMax(minH, MathMin(maxH, m_bottomResizeStartHeight + dy));
   //--- Only redraw when the height actually changed
   if(newH != m_sidebarHeight)
     {
      //--- Snapped state stores height in m_snappedSidebarHeight; floating stores directly
      if(m_snapState != SNAP_FLOAT) m_snappedSidebarHeight = newH; else m_sidebarHeight = newH;
      //--- Recompute sidebar height (categories visible), resize canvases, redraw
      CalcSidebarHeight();
      ResizeSidebarCanvases(m_sidebarWidth, m_sidebarHeight);
      DrawSidebar(activeTool);
      ChartRedraw();
     }
  }

//+------------------------------------------------------------------+
//| Continue dragging the sidebar's scrollbar thumb                  |
//+------------------------------------------------------------------+
void CChartEventHandler::HandleSidebarThumbDrag(int mouseX, int mouseY, TOOL_TYPE activeTool)
  {
   //--- Track height + travel distance of the thumb within the track
   int trackH = CalcSidebarViewportPixels(), travel = trackH - m_sidebarScrollThumbHeight;
   //--- Only process drag when there's room for the thumb to travel
   if(travel > 0)
     {
      //--- Cursor delta + max scroll for the proportional mapping
      int dy    = mouseY - m_sidebarThumbDragStartY;
      int maxPx = CalcSidebarMaxScrollPixels();
      //--- Translate thumb travel proportionally into scroll pixels; clamp to [0, maxPx]
      int newPx = MathMax(0, MathMin(maxPx,
         m_sidebarThumbDragStartPixels + (int)MathRound((double)dy / travel * maxPx)));
      //--- Only redraw when scroll actually changed
      if(newPx != m_sidebarScrollPixels)
        { m_sidebarScrollPixels = newPx; HideFlyout(); DrawSidebar(activeTool); ChartRedraw(); }
     }
  }

//+------------------------------------------------------------------+
//| Release the sidebar scrollbar thumb drag and clear dragging flag |
//+------------------------------------------------------------------+
void CChartEventHandler::HandleSidebarThumbRelease(TOOL_TYPE activeTool)
  {
   //--- Clear the drag flag and force a redraw so the thumb returns to idle visual state
   m_isSidebarThumbDragging = false;
   DrawSidebar(activeTool);
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| Continue dragging the flyout's scrollbar thumb                   |
//+------------------------------------------------------------------+
void CChartEventHandler::HandleFlyoutThumbDrag(int mouseX, int mouseY)
  {
   //--- Bail if no flyout is open
   if(m_flyoutActiveCat == CAT_NONE) return;
   //--- Bail if the flyout has no overflow (no scrollbar needed)
   int nTools = ArraySize(m_categories[(int)m_flyoutActiveCat].tools);
   if(nTools <= m_flyoutMaxVisibleItems) return;
   //--- Track height + travel distance of the thumb within the track
   int trackH = MathMin(nTools, m_flyoutMaxVisibleItems) * m_flyoutItemHeight;
   int travel = trackH - m_flyoutScrollThumbHeight;
   //--- Only process drag when there's room for the thumb to travel
   if(travel > 0)
     {
      //--- Cursor delta + max scroll for the proportional mapping
      int dy    = mouseY - m_flyoutThumbDragStartY;
      int maxPx = (nTools - m_flyoutMaxVisibleItems) * m_flyoutItemHeight;
      //--- Translate thumb travel proportionally into scroll pixels; clamp to [0, maxPx]
      int newPx = MathMax(0, MathMin(maxPx,
         m_flyoutThumbDragStartPixels + (int)MathRound((double)dy / travel * maxPx)));
      //--- Only redraw when scroll actually changed
      if(newPx != m_flyoutScrollPixels)
        { m_flyoutScrollPixels = newPx; DrawFlyoutForCategory(m_flyoutActiveCat, TOOL_NONE); ChartRedraw(); }
     }
  }

//+------------------------------------------------------------------+
//| Release the flyout scrollbar thumb drag and clear dragging flag  |
//+------------------------------------------------------------------+
void CChartEventHandler::HandleFlyoutThumbRelease()
  {
   //--- Clear the drag flag and force a redraw so the thumb returns to idle visual state
   m_isFlyoutThumbDragging = false;
   DrawFlyoutForCategory(m_flyoutActiveCat, TOOL_NONE);
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| Recompute ALL hover state for sidebar + flyout and redraw on diff|
//+------------------------------------------------------------------+
void CChartEventHandler::UpdateAllHoverStates(int mouseX, int mouseY, bool overSidebar, bool overFlyout,
                                               int lx, int ly, int flx, int fly, TOOL_TYPE activeTool)
  {
   //--- Snapshot previous hover state for the change-detection comparison at the end
   ENUM_CATEGORY prevHovCat  = m_hoveredCategory;
   int           prevHovItem = m_hoveredFlyoutItem;
   bool prevClose = m_isCloseButtonHovered, prevTheme = m_isThemeButtonHovered;
   bool prevGrip  = m_isGripAreaHovered,    prevSBA   = m_isHoveredSidebarScrollArea;
   bool prevFSA   = m_isHoveredFlyoutScrollArea, prevBR = m_isBottomResizeHovered;
   bool prevSbTh  = m_isHoveredSidebarThumb, prevFlyTh = m_isHoveredFlyoutThumb;
   //--- Reset all hover flags so the recomputation below sets only what's actually true
   m_isCloseButtonHovered = m_isThemeButtonHovered = m_isGripAreaHovered = false;
   m_isBottomResizeHovered = m_isHoveredSidebarScrollArea = m_isHoveredSidebarThumb = false;
   m_isHoveredFlyoutScrollArea = m_isHoveredFlyoutThumb = false;
   //--- Sidebar hover detection: category tile, close button, theme button, grip, bottom-resize handle
   if(overSidebar)
     {
      m_hoveredCategory       = HitTestCategoryButton(lx, ly);
      m_isCloseButtonHovered  = HitTestOverCloseButton(lx, ly);
      m_isThemeButtonHovered  = HitTestOverThemeButton(lx, ly);
      m_isGripAreaHovered     = HitTestOverGripArea(lx, ly);
      m_isBottomResizeHovered = HitTestOverBottomResizeGrip(lx, ly);
      //--- If the sidebar has overflow, detect scroll-area + thumb hover
      if(CalcSidebarMaxScrollPixels() > 0)
        {
         //--- Cache scroll-track Y range
         int trackY = CalcClipTop(), trackH = CalcSidebarViewportPixels();
         m_isHoveredSidebarScrollArea = (ly >= trackY && ly <= trackY + trackH);
         if(m_isHoveredSidebarScrollArea)
           {
            //--- Compute thin-track X position (left side when snapped right, otherwise right side)
            int tw = m_sidebarScrollThinWidth;
            int thinX = (m_snapState == SNAP_RIGHT) ? 2 : m_sidebarWidth - tw - 2;
            //--- Within the +/-4 px gutter around the thin track => candidate for thumb-hover check
            if(lx >= thinX - 4 && lx <= thinX + tw + 4)
              {
               //--- Compute current thumb Y position from the scroll fraction
               int maxPx   = CalcSidebarMaxScrollPixels();
               int sliderY = trackY + (int)((maxPx > 0 ? (double)m_sidebarScrollPixels / maxPx : 0.0) *
                              (trackH - m_sidebarScrollThumbHeight));
               //--- Thumb is hovered iff the cursor falls within the thumb's Y span
               m_isHoveredSidebarThumb = (ly >= sliderY && ly <= sliderY + m_sidebarScrollThumbHeight);
              }
           }
        }
     }
   else if(!overFlyout) m_hoveredCategory = CAT_NONE;
   //--- Flyout hover detection: hovered item index, scroll-area + thumb when overflow
   if(overFlyout)
     {
      m_hoveredFlyoutItem = HitTestFlyoutItem(flx, fly);
      if(m_hoveredFlyoutItem < 0) m_hoveredFlyoutItem = -1;
      //--- Scroll-area hover only when the flyout actually has overflow
      m_isHoveredFlyoutScrollArea = m_isFlyoutVisible && m_flyoutActiveCat != CAT_NONE &&
         (ArraySize(m_categories[(int)m_flyoutActiveCat].tools) > m_flyoutMaxVisibleItems);
      if(m_isHoveredFlyoutScrollArea)
        {
         //--- Cache geometry for the thumb-hover test
         int nTools   = ArraySize(m_categories[(int)m_flyoutActiveCat].tools);
         int titleH   = 26, itemsTop = titleH + m_flyoutPadding;
         int trackH   = MathMin(nTools, m_flyoutMaxVisibleItems) * m_flyoutItemHeight;
         int tw       = m_sidebarScrollThinWidth;
         int dispBx   = m_flyoutPointerOnLeft ? m_flyoutPointerHeight : 0;
         //--- Thin-track X position depends on which side the flyout's pointer is on
         int thinX    = m_flyoutPointerOnLeft ? (dispBx + m_flyoutWidth - tw - 2) : (dispBx + 2);
         //--- Within the +/-6 px gutter around the thin track AND inside the items area => candidate
         if(flx >= thinX - 6 && flx <= thinX + tw + 6 && fly >= itemsTop && fly <= itemsTop + trackH)
           {
            //--- Compute current thumb Y position from the scroll fraction
            int maxPx   = (nTools - m_flyoutMaxVisibleItems) * m_flyoutItemHeight;
            int sliderY = itemsTop + (int)((maxPx > 0 ? (double)m_flyoutScrollPixels / maxPx : 0.0) *
                           (trackH - m_flyoutScrollThumbHeight));
            //--- Thumb is hovered iff the cursor falls within the thumb's Y span
            m_isHoveredFlyoutThumb = (fly >= sliderY && fly <= sliderY + m_flyoutScrollThumbHeight);
           }
        }
     }
   else if(!overSidebar) { m_hoveredFlyoutItem = -1; m_isHoveredFlyoutScrollArea = false; }
   //--- Auto-open flyout on category hover (unless hovering close/theme/grip buttons)
   if(overSidebar && m_hoveredCategory != CAT_NONE &&
       !m_isCloseButtonHovered && !m_isThemeButtonHovered && !m_isGripAreaHovered)
     {
      //--- Only show flyout for a different category than the currently-active one
      if(m_hoveredCategory != m_flyoutActiveCat) ShowFlyout(m_hoveredCategory, activeTool);
     }
   else if(!overFlyout && m_isFlyoutVisible)
     {
      //--- Cursor left both sidebar and flyout - hide flyout unless cursor is on the edge transit margin
      bool transitEdge = false;
      if(overSidebar)
        {
         //--- Transit-edge margin lets the cursor cross from sidebar to flyout without flicker
         int margin  = m_sidebarWidth / 4;
         transitEdge = (m_snapState == SNAP_LEFT)  ? (lx >= m_sidebarWidth - margin) :
                       (m_snapState == SNAP_RIGHT) ? (lx <= margin) :
                       (m_flyoutPointerOnLeft ? (lx >= m_sidebarWidth - margin) : (lx <= margin));
        }
      //--- Off the transit edge => commit to hiding the flyout
      if(!transitEdge) { HideFlyout(); ChartRedraw(); }
     }
   //--- Determine whether ANY hover state changed - drives the redraw decision
   bool changed = (prevHovCat  != m_hoveredCategory      || prevHovItem != m_hoveredFlyoutItem  ||
                   prevClose   != m_isCloseButtonHovered  || prevTheme  != m_isThemeButtonHovered ||
                   prevGrip    != m_isGripAreaHovered      || prevSBA   != m_isHoveredSidebarScrollArea ||
                   prevFSA     != m_isHoveredFlyoutScrollArea || prevBR != m_isBottomResizeHovered ||
                   prevSbTh    != m_isHoveredSidebarThumb  || prevFlyTh != m_isHoveredFlyoutThumb);
   //--- Only redraw if something visibly changed (avoids unnecessary repaints on every mouse move)
   if(changed)
     {
      DrawSidebar(activeTool);
      if(m_isFlyoutVisible) DrawFlyoutForCategory(m_flyoutActiveCat, activeTool);
      ChartRedraw();
     }
  }

//+------------------------------------------------------------------+
//| Route a fresh left-button press to scrollbar / grip / chart paths|
//+------------------------------------------------------------------+
void CChartEventHandler::HandleMouseClickDown(int mouseX, int mouseY, bool overSidebar, bool overFlyout,
                                               int lx, int ly, int flx, int fly, TOOL_TYPE &activeTool)
  {
   //--- Popover gets FIRST refusal (highest z-order); click inside -> popover handles; click outside -> popover closes and click routes below
   const bool popoverWasVisible = IsPopoverVisible();
   if(popoverWasVisible && PopoverMouseDown(mouseX, mouseY))
     {
      return;
     }
   const bool popoverClosed = popoverWasVisible && !IsPopoverVisible();
   if(popoverClosed && IsSettingsVisible())
     {
      //--- Force settings repaint so the previously-active chip's DodgerBlue border returns to normal
      RedrawSettings();
      ChartRedraw();
     }

   //--- Settings second refusal handles clicks inside its body; outside-settings click while text-area focused commits + unfocuses before routing on
   if(IsSettingsVisible() && IsTextAreaFocused())
     {
      int peekLx = 0, peekLy = 0;
      if(!HitTestOverSettings(mouseX, mouseY, peekLx, peekLy))
        {
         UnfocusTextArea();
         RedrawSettings();
         ChartRedraw();
         //--- Don't early-return; let the click route to whatever below was being targeted
        }
     }

   //--- Outside-settings click while coord field is being edited: commit so the next branch's outside-click dismissal doesn't lose the unflushed buffer
   if(IsSettingsVisible() && IsEditingCoord())
     {
      int peekLx = 0, peekLy = 0;
      if(!HitTestOverSettings(mouseX, mouseY, peekLx, peekLy))
        {
         CommitCoordEdit();
         RedrawSettings();
         ChartRedraw();
        }
     }

   //+--------------------------------------------------------------+
   //| Outside-click dismissal of the settings window.              |
   //|                                                              |
   //| Click outside settings AND outside any open popover -> commit|
   //| and close the settings window (standard click-away-to-dismiss|
   //| pattern from native UI: modal popovers, tooltips, dropdowns).|
   //|                                                              |
   //| The click is CONSUMED — it doesn't fall through to whatever  |
   //| was clicked. First click dismisses, second click interacts   |
   //| with whatever is beneath.                                    |
   //|                                                              |
   //| Commit semantics: clicking-away ACCEPTS edits (same as Ok).  |
   //| Cancel (X / Cancel button) is the only way to revert. This   |
   //| matches modal-popover convention.                            |
   //+--------------------------------------------------------------+
   if(IsSettingsVisible())
     {
      int peekLx = 0, peekLy = 0;
      const bool overSettings = HitTestOverSettings(mouseX, mouseY, peekLx, peekLy);
      bool overPopoverChk = false;
      if(IsPopoverVisible())
        {
         //--- Mouse-over-popover test (popover sits above settings z-stack)
         int popLx = 0, popLy = 0;
         overPopoverChk = HitTestOverPopover(mouseX, mouseY, popLx, popLy);
        }
      if(!overSettings && !overPopoverChk)
        {
         //--- Click outside both -> commit edits + close + consume
         CommitSettingsChanges();
         ChartRedraw();
         return;
        }
     }

   //--- Settings window interior click - dispatch to SettingsMouseDown router
   if(IsSettingsVisible() && SettingsMouseDown(mouseX, mouseY))
     {
      return;
     }

   //--- Ribbon hit next refusal: RibbonMouseDown returns true if click landed inside ribbon (consumes even empty body so it doesn't fall through to sidebar/chart)
   if(IsRibbonVisible() && RibbonMouseDown(mouseX, mouseY))
     {
      return;
     }

   //--- Sidebar scrollbar click: thumb-grab OR page-up/down
   if(overSidebar && CalcSidebarMaxScrollPixels() > 0)
     {
      //--- Cache geometry for the click-target test
      int trackY = CalcClipTop(), trackH = CalcSidebarViewportPixels(), tw = m_sidebarScrollThinWidth;
      int thinX  = (m_snapState == SNAP_RIGHT) ? 2 : m_sidebarWidth - tw - 2;
      //--- Click landed within the scrollbar's +/-4 px gutter and inside the track Y range
      if(lx >= thinX - 4 && lx <= thinX + tw + 4 && ly >= trackY && ly <= trackY + trackH)
        {
         //--- Compute current thumb Y position from the scroll fraction
         int maxPx   = CalcSidebarMaxScrollPixels();
         int sliderY = trackY + (int)((maxPx > 0 ? (double)m_sidebarScrollPixels / maxPx : 0.0) *
                        (trackH - m_sidebarScrollThumbHeight));
         //--- Click on the thumb itself: start dragging it
         if(ly >= sliderY && ly <= sliderY + m_sidebarScrollThumbHeight)
           {
            //--- Capture initial state for the proportional drag math
            m_isSidebarThumbDragging      = true;
            m_sidebarThumbDragStartY      = mouseY;
            m_sidebarThumbDragStartPixels = m_sidebarScrollPixels;
            //--- Lock chart scroll while we own the drag
            ChartSetInteger(0, CHART_MOUSE_SCROLL, false);
            HideFlyout(); DrawSidebar(activeTool); ChartRedraw();
           }
         else
           {
            //--- Click on the track but not the thumb: page up/down by one category-button step
            int step = m_categoryButtonSize + m_categoryButtonPadding;
            m_sidebarScrollPixels = MathMax(0, MathMin(maxPx,
               m_sidebarScrollPixels + ((ly < sliderY) ? -step : step)));
            HideFlyout(); DrawSidebar(activeTool); ChartRedraw();
           }
         return;
        }
     }
   //--- Flyout scrollbar click: thumb-grab OR page-up/down (same pattern as sidebar)
   if(overFlyout && m_flyoutActiveCat != CAT_NONE)
     {
      //--- Cache the active category's tool count - scrollbar exists only when there's overflow
      int nTools = ArraySize(m_categories[(int)m_flyoutActiveCat].tools);
      if(nTools > m_flyoutMaxVisibleItems)
        {
         //--- Cache geometry for the click-target test
         int titleH  = 26, itemsTop = titleH + m_flyoutPadding;
         int trackH  = MathMin(nTools, m_flyoutMaxVisibleItems) * m_flyoutItemHeight;
         int tw      = m_sidebarScrollThinWidth;
         int dispBx  = m_flyoutPointerOnLeft ? m_flyoutPointerHeight : 0;
         //--- Thin-track X position depends on which side the flyout's pointer is on
         int thinX   = m_flyoutPointerOnLeft ? (dispBx + m_flyoutWidth - tw - 2) : (dispBx + 2);
         //--- Click landed within the scrollbar's +/-6 px gutter and inside the items area
         if(flx >= thinX - 6 && flx <= thinX + tw + 6 && fly >= itemsTop && fly <= itemsTop + trackH)
           {
            //--- Compute current thumb Y position from the scroll fraction
            int maxPx   = (nTools - m_flyoutMaxVisibleItems) * m_flyoutItemHeight;
            int sliderY = itemsTop + (int)((maxPx > 0 ? (double)m_flyoutScrollPixels / maxPx : 0.0) *
                           (trackH - m_flyoutScrollThumbHeight));
            //--- Click on the thumb itself: start dragging it
            if(fly >= sliderY && fly <= sliderY + m_flyoutScrollThumbHeight)
              {
               //--- Capture initial state for the proportional drag math
               m_isFlyoutThumbDragging      = true;
               m_flyoutThumbDragStartY      = mouseY;
               m_flyoutThumbDragStartPixels = m_flyoutScrollPixels;
               //--- Lock chart scroll while we own the drag
               ChartSetInteger(0, CHART_MOUSE_SCROLL, false);
               DrawFlyoutForCategory(m_flyoutActiveCat, activeTool); ChartRedraw();
              }
            else
              {
               //--- Click on the track but not the thumb: page up/down by one item height
               m_flyoutScrollPixels = MathMax(0, MathMin(maxPx,
                  m_flyoutScrollPixels + ((fly < sliderY) ? -m_flyoutItemHeight : m_flyoutItemHeight)));
               DrawFlyoutForCategory(m_flyoutActiveCat, activeTool); ChartRedraw();
              }
            return;
           }
        }
     }
   //--- Grip area click (sidebar's drag handle) starts a panel-drag operation
   if(overSidebar && HitTestOverGripArea(lx, ly) && !m_isCloseButtonHovered && !m_isThemeButtonHovered)
     {
      m_isPanelDragging = true;
      m_dragOffsetX     = lx;
      m_dragOffsetY     = ly;
      //--- Lock chart scroll while we own the drag
      ChartSetInteger(0, CHART_MOUSE_SCROLL, false);
      HideFlyout();
      return;
     }
   //--- Bottom-resize handle click starts a bottom-edge-resize operation
   if(overSidebar && HitTestOverBottomResizeGrip(lx, ly))
     {
      m_isResizingBottomEdge    = true;
      m_bottomResizeDragStartY  = mouseY;
      m_bottomResizeStartHeight = m_sidebarHeight;
      //--- Lock chart scroll while we own the drag
      ChartSetInteger(0, CHART_MOUSE_SCROLL, false);
      HideFlyout();
      return;
     }
   //--- Close-button click terminates the EA
   if(overSidebar && m_isCloseButtonHovered) { ExpertRemove(); return; }

   //--- Pointer-mode click off both sidebar and flyout: delegate to HandlePointerClick (full decision tree)
   if(!overSidebar && !overFlyout &&
      (activeTool == TOOL_NONE || activeTool == TOOL_POINTER))
     {
      //--- Cache hit-test result then dispatch via the engine's pointer-click handler
      int hitId = HitTestAllObjects(mouseX, mouseY);
      HandlePointerClick(mouseX, mouseY);
      ChartRedraw();
     }
  }

//+------------------------------------------------------------------+
//| Main mouse-move dispatcher - drags, hover updates, click routing |
//+------------------------------------------------------------------+
void CChartEventHandler::OnMouseMoveEvent(int mouseX, int mouseY, int mouseButtons, TOOL_TYPE &activeTool)
  {
   //--- Resolve sidebar / flyout containment + local coordinates
   int lx, ly, flx, fly;
   bool overSidebar = HitTestOverSidebar(mouseX, mouseY, lx, ly);
   bool overFlyout  = !overSidebar && HitTestOverFlyout(mouseX, mouseY, flx, fly);

   //--- Popover drag (opacity slider, etc.) is highest priority of all because popover sits above the ribbon
   if(m_isOpacityDragging && mouseButtons == 1)
     {
      PopoverMouseMove(mouseX, mouseY, mouseButtons);
      m_previousMouseButtonState = mouseButtons;
      return;
     }
   if(m_isOpacityDragging && mouseButtons == 0)
     {
      PopoverMouseUp();
      m_previousMouseButtonState = mouseButtons;
      return;
     }

   //--- Settings-window drag has top priority among drag handlers (settings sits at top z); every move reaches SettingsMouseMove regardless of button state
   if(IsDraggingSettings())
     {
      SettingsMouseMove(mouseX, mouseY, mouseButtons);
      m_previousMouseButtonState = mouseButtons;
      return;
     }

   //--- Ribbon drag (grip move) - same early-exit pattern as panel/handle drags below; RibbonMouseMove calls RibbonMouseUp if mouse-up was missed
   if(m_isRibbonDragging && mouseButtons == 1)
     {
      RibbonMouseMove(mouseX, mouseY, mouseButtons);
      m_previousMouseButtonState = mouseButtons;
      return;
     }
   if(m_isRibbonDragging && mouseButtons == 0)
     {
      RibbonMouseUp();
      m_previousMouseButtonState = mouseButtons;
      return;
     }

   //--- Hover-feedback dispatch (no drags active). ORDER MATTERS: popover FIRST, then settings - so a popover overlapping settings wins hover; SettingsMouseMove always runs to clear stale hover when cursor moves off settings into popover region
   bool popoverConsumedHover = false;
   if(IsPopoverVisible() && mouseButtons == 0)
     {
      popoverConsumedHover = PopoverMouseMove(mouseX, mouseY, mouseButtons);
     }
   if(IsSettingsVisible() && mouseButtons == 0)
     {
      //--- Always run SettingsMouseMove to clear stale hover (mouse may have moved off settings)
      const bool overSettingsBody = SettingsMouseMove(mouseX, mouseY, mouseButtons);
      //--- If popover claimed it or settings hover landed inside the body, early-return
      if(popoverConsumedHover || overSettingsBody)
        {
         m_previousMouseButtonState = mouseButtons;
         return;
        }
     }
   else if(popoverConsumedHover)
     {
      m_previousMouseButtonState = mouseButtons;
      return;
     }

   //--- Ribbon hover feedback (icon highlight + tooltip) - no early return so sidebar/chart hover can still update if cursor is elsewhere
   if(IsRibbonVisible() && mouseButtons == 0)
     {
      RibbonMouseMove(mouseX, mouseY, mouseButtons);
     }

   //--- Earliest-priority drag handlers (panel/resize/sidebar-thumb/flyout-thumb/object-handle/whole-object) - each routes to its drag/release path and returns
   if(m_isPanelDragging        && mouseButtons == 1) { HandlePanelDragMove(mouseX, mouseY, activeTool);    m_previousMouseButtonState = mouseButtons; return; }
   if(m_isPanelDragging        && mouseButtons == 0) { HandlePanelDragRelease(activeTool);                 m_previousMouseButtonState = mouseButtons; return; }
   if(m_isResizingBottomEdge   && mouseButtons == 1) { HandleBottomResizeDrag(mouseX, mouseY, activeTool); m_previousMouseButtonState = mouseButtons; return; }
   if(m_isResizingBottomEdge   && mouseButtons == 0) { m_isResizingBottomEdge = false;                     m_previousMouseButtonState = mouseButtons; return; }
   if(m_isSidebarThumbDragging && mouseButtons == 1) { HandleSidebarThumbDrag(mouseX, mouseY, activeTool); m_previousMouseButtonState = mouseButtons; return; }
   if(m_isSidebarThumbDragging && mouseButtons == 0) { HandleSidebarThumbRelease(activeTool);              m_previousMouseButtonState = mouseButtons; return; }
   if(m_isFlyoutThumbDragging  && mouseButtons == 1) { HandleFlyoutThumbDrag(mouseX, mouseY);              m_previousMouseButtonState = mouseButtons; return; }
   if(m_isFlyoutThumbDragging  && mouseButtons == 0) { HandleFlyoutThumbRelease();                         m_previousMouseButtonState = mouseButtons; return; }
   //--- Object handle drag - early exit (same pattern as sidebar/flyout drag)
   if(m_isDraggingHandle       && mouseButtons == 1) { HandlePointerDragMove(mouseX, mouseY);  ChartRedraw(); m_previousMouseButtonState = mouseButtons; return; }
   if(m_isDraggingHandle       && mouseButtons == 0) { HandlePointerDragRelease();              ChartRedraw(); m_previousMouseButtonState = mouseButtons; return; }
   //--- Whole-object drag - early exit (same pattern as object handle drag)
   if(m_isDraggingObject       && mouseButtons == 1) { HandlePointerDragMove(mouseX, mouseY);  ChartRedraw(); m_previousMouseButtonState = mouseButtons; return; }
   if(m_isDraggingObject       && mouseButtons == 0) { HandlePointerDragRelease();              ChartRedraw(); m_previousMouseButtonState = mouseButtons; return; }
   //--- No active drag - refresh hover state for sidebar + flyout
   UpdateAllHoverStates(mouseX, mouseY, overSidebar, overFlyout, lx, ly, flx, fly, activeTool);
   //--- Manage chart scroll lock here only when NOT in pointer mode (pointer mode locks scroll in OnEvent)
   if(activeTool != TOOL_NONE && activeTool != TOOL_POINTER)
     {
      //--- Scroll locked while cursor is over sidebar/flyout (so the wheel scrolls our UI, not the chart)
      bool overAny = overSidebar || overFlyout;
      if(!m_isSidebarThumbDragging && !m_isPanelDragging && !m_isResizingBottomEdge && !m_isFlyoutThumbDragging)
         ChartSetInteger(0, CHART_MOUSE_SCROLL, !overAny);
     }
   //--- Rising-edge mouse-down detection - dispatch to HandleMouseClickDown
   if(mouseButtons == 1 && m_previousMouseButtonState == 0)
      HandleMouseClickDown(mouseX, mouseY, overSidebar, overFlyout, lx, ly, flx, fly, activeTool);
   //--- Cache mouse state for the next edge-transition detection
   m_previousMouseButtonState = mouseButtons;
  }

//+------------------------------------------------------------------+
//| CToolsSidebar is the top-level indicator class - the EA's entry  |
//+------------------------------------------------------------------+
class CToolsSidebar : public CChartEventHandler
  {
private:
   //--- Currently active tool (TOOL_NONE when no drawing tool is selected)
   TOOL_TYPE m_currentActiveTool;
   //--- Tooltip-style instruction string shown to the user (e.g. "Click on chart to place ...")
   string    m_currentInstruction;

public:
   //--- Constructor delegates to InitDefaults so default state is set in one place
                     CToolsSidebar()  { InitDefaults(); }
   //--- Destructor delegates to Destroy so cleanup is centralized
                    ~CToolsSidebar() { Destroy(); }
   //--- Initialize all canvases and register chart event hooks (called from OnInit)
   bool              Init(long chartId);
   //--- Tear down all canvases / chart objects and restore chart state (called from OnDeinit)
   void              Destroy();
   //--- Main chart event dispatcher (called from OnChartEvent)
   void              OnEvent(const int id, const long &lp, const double &dp, const string &sp);
   //--- Timer callback that drives the label-edit cursor blink (only active during edits)
   void              OnTimer();

private:
   //--- Set every member variable to its default starting value
   void              InitDefaults();
   //--- Toggle the given tool on / off (handles preview cancel + scroll-lock state)
   void              ToggleTool(TOOL_TYPE toolType);
   //--- Fully tear down the active tool (Escape key + tool-completion paths)
   void              DeactivateCurrentTool();
   //--- Hide crosshair + measure objects when switching away from the crosshair tool
   void              CleanupCrosshairOnToolSwitch();
   //--- Update crosshair canvases as the cursor moves (called from OnEvent)
   void              HandleCrosshairMouseMove(int mouseX, int mouseY, bool overSidebar, bool overFlyout);
  };

//+------------------------------------------------------------------+
//| Set every member variable to its default starting value          |
//+------------------------------------------------------------------+
void CToolsSidebar::InitDefaults()
  {
   //--- Chart and canvas names: stable identifiers for every chart object the sidebar creates
   m_chartId                 = 0;
   m_nameSidebar             = "ToolsPalette_Sidebar";
   m_nameFlyout              = "ToolsPalette_Flyout";
   m_nameReticle             = "ToolsPalette_Reticle";
   m_nameMagnifier           = "ToolsPalette_Magnifier";
   m_nameCrossVertical       = "ToolsPalette_CrosshairVertical";
   m_nameCrossHorizontal     = "ToolsPalette_CrosshairHorizontal";
   m_nameCrossPriceLabel     = "ToolsPalette_CrosshairPriceLabel";
   m_nameCrossTimeLabel      = "ToolsPalette_CrosshairTimeLabel";
   m_nameMeasureVertical     = "ToolsPalette_MeasureVertical";
   m_nameMeasureHorizontal   = "ToolsPalette_MeasureHorizontal";
   m_nameMeasurePriceLabel   = "ToolsPalette_MeasurePriceLabel";
   m_nameMeasureTimeLabel    = "ToolsPalette_MeasureTimeLabel";
   m_nameMeasureDiagonalLine = "ToolsPalette_MeasureDiagonalLine";
   m_nameDrawings            = "ToolsPalette_Drawings";
   m_nameObjPriceLabel1      = "ToolsPalette_ObjPriceLabel1";
   m_nameObjTimeLabel1       = "ToolsPalette_ObjTimeLabel1";
   m_nameObjPriceLabel2      = "ToolsPalette_ObjPriceLabel2";
   m_nameObjTimeLabel2       = "ToolsPalette_ObjTimeLabel2";
   m_nameObjPriceLabel3      = "ToolsPalette_ObjPriceLabel3";
   m_nameObjTimeLabel3       = "ToolsPalette_ObjTimeLabel3";
   m_objLabelsVisible        = false;
   //--- Rendering dimensions and supersample factor for HR canvases
   m_supersampleFactor       = 4;
   m_categoryButtonSize      = 36;
   m_categoryButtonPadding   = 6;
   m_panelCornerRadius       = 10;
   m_headerGripHeight        = 92;
   m_sidebarWidth            = 48;
   m_sidebarHeight           = 0;
   m_sidebarMaxVisibleCats   = 0;
   m_sidebarScrollPixels     = 0;
   m_sidebarScrollThumbHeight      = 30;
   m_sidebarScrollThinWidth        = 3;
   m_isSidebarThumbDragging        = false;
   m_sidebarThumbDragStartY        = 0;
   m_sidebarThumbDragStartPixels   = 0;
   m_isHoveredSidebarScrollArea    = false;
   m_isHoveredSidebarThumb         = false;
   //--- Panel position and drag state
   m_panelX                  = 0;
   m_panelY                  = CanvasY;
   m_snapState               = SNAP_LEFT;
   m_isPanelDragging         = false;
   m_dragOffsetX             = 0;
   m_dragOffsetY             = 0;
   m_snappedSidebarHeight    = 0;
   m_isResizingBottomEdge    = false;
   m_bottomResizeDragStartY  = 0;
   m_bottomResizeStartHeight = 0;
   m_isBottomResizeHovered   = false;
   //--- Sidebar hover state flags
   m_hoveredCategory         = CAT_NONE;
   m_isCloseButtonHovered    = false;
   m_isThemeButtonHovered    = false;
   m_isGripAreaHovered       = false;
   //--- Flyout layout and state
   m_flyoutWidth             = 195;
   m_flyoutItemHeight        = 32;
   m_flyoutPadding           = 7;
   m_flyoutPointerWidth      = 10;
   m_flyoutPointerHeight     = 8;
   m_flyoutPointerLocalY     = 40;
   m_flyoutPointerOnLeft     = true;
   m_isFlyoutVisible         = false;
   m_flyoutActiveCat         = CAT_NONE;
   m_hoveredFlyoutItem       = -1;
   m_flyoutScrollPixels      = 0;
   m_flyoutMaxVisibleItems   = 5;
   m_flyoutScrollThumbHeight = 30;
   m_isFlyoutThumbDragging   = false;
   m_flyoutThumbDragStartY   = 0;
   m_flyoutThumbDragStartPixels  = 0;
   m_isHoveredFlyoutScrollArea   = false;
   m_isHoveredFlyoutThumb        = false;
   //--- Theme: honor the StartDark input on first run
   m_isDarkTheme             = StartDark;
   //--- Crosshair state and reticle canvas dimensions
   m_reticleCanvasSize       = 2 * (ReticleOffset + ReticleTickLen / 2) + 6;
   m_isReticleVisible        = false;
   m_isMagnifierVisible      = false;
   m_isCrossVertVisible      = false;
   m_isCrossHorizVisible     = false;
   m_isCrossPriceLabelVisible    = false;
   m_isCrossTimeLabelVisible     = false;
   m_isMeasureVertVisible        = false;
   m_isMeasureHorizVisible       = false;
   m_isMeasurePriceLabelVisible  = false;
   m_isMeasureTimeLabelVisible   = false;
   m_isMeasureDiagonalVisible    = false;
   m_isMeasuringActive       = false;
   m_measureAnchorTime       = 0;
   m_measureAnchorPrice      = 0.0;
   m_measureAnchorPixelX     = 0;
   m_measureAnchorPixelY     = 0;
   m_lastClickTimeMicros     = 0;
   m_lastMagMouseX           = -9999;
   m_lastMagMouseY           = -9999;
   //--- Drawing engine state - object store + in-progress placement
   m_drawnObjectCounter      = 0;
   m_drawnObjectCount        = 0;
   m_drawingsDirty           = false;
   m_drawingsDirtyTick       = 0;
   m_toolDrawingClickCount   = 0;
   m_drawPoint1Time          = 0;
   m_drawPoint2Time          = 0;
   m_drawPoint1Price         = 0.0;
   m_drawPoint2Price         = 0.0;
   ArrayResize(m_drawnObjects, 0);
   //--- Hit testing and selection state
   m_hoveredObjectId            = -1;
   m_hoveredHandleIdx           = -1;
   m_hoveredHandleHostId        = -1;
   //--- Handle display state for the per-tool drawers
   m_currentObjIsActive         = 0;
   m_hideHandleIdx              = -1;
   m_haloHandleIdx              = -1;
   m_selectedObjectId           = -1;
   m_draggedHandleIdx           = -1;
   m_isDraggingHandle           = false;
   m_isDraggingObject           = false;
   m_dragLastMouseX             = 0;
   m_dragLastMouseY             = 0;
   m_lastPointerClickMicros     = 0;
   m_lastPointerClickHitId      = -1;
   //--- Add-text-prompt overlay state (rotated rect highlighted on hover before commit)
   m_addTextPromptObjId         = -1;
   m_addTextPromptX1            = 0;
   m_addTextPromptY1            = 0;
   m_addTextPromptX2            = 0;
   m_addTextPromptY2            = 0;
   //--- Label hit state (which object's label was last hit, plus its rotated-rect corners)
   m_labelHitActive             = false;
   m_labelHitObjIdForLast       = -1;
   m_labelHitObjIdForSelected   = -1;
   m_labelHitX1                 = 0;
   m_labelHitY1                 = 0;
   m_labelHitX2                 = 0;
   m_labelHitY2                 = 0;
   //--- Initialize rotated-corner hit arrays to zero (fixed size 4 for the rect corners)
   ArrayResize(m_addTextPromptCornerX, 4);
   ArrayResize(m_addTextPromptCornerY, 4);
   ArrayResize(m_labelHitCornerX,      4);
   ArrayResize(m_labelHitCornerY,      4);
   for(int _ci = 0; _ci < 4; _ci++)
     {
      m_addTextPromptCornerX[_ci] = 0; m_addTextPromptCornerY[_ci] = 0;
      m_labelHitCornerX[_ci]      = 0; m_labelHitCornerY[_ci]      = 0;
     }
   m_hitThreshold               = 8;
   //--- Info panel rect sentinels - (-1) means no panel has been drawn yet
   m_lastInfoPanelX1 = -1;
   m_lastInfoPanelY1 = -1;
   m_lastInfoPanelX2 = -1;
   m_lastInfoPanelY2 = -1;
   //--- Rubber-band preview state (active during multi-click tool placement)
   m_isPreviewActive            = false;
   m_previewMouseX              = 0;
   m_previewMouseY              = 0;
   m_previewToolType            = TOOL_NONE;
   //--- Label editing state - buffer + caret + selection anchor
   m_isEditingLabel             = false;
   m_labelEditBuffer            = "";
   m_labelCaretPos              = 0;
   m_labelSelectionAnchor       = -1;     // -1 = no selection
   m_savedKeyboardControl       = true;   // MT5 default
   m_savedQuickNavigation       = true;   // MT5 default
   m_keyboardOverrideActive     = false;
   //--- Mouse and interaction state
   m_previousMouseButtonState = 0;
   m_currentActiveTool        = TOOL_NONE;
   m_currentInstruction       = "";
  }

//+------------------------------------------------------------------+
//| Initialize all canvases and register chart event hooks           |
//+------------------------------------------------------------------+
bool CToolsSidebar::Init(long chartId)
  {
   //--- Reset all state to defaults before initialization starts
   InitDefaults();
   //--- Cache the chart ID (passed in from OnInit) and compute initial X based on snap state
   m_chartId = chartId;
   m_panelX  = (m_snapState == SNAP_RIGHT)
      ? (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS) - m_sidebarWidth : 0;
   //--- Build the category / tool catalog and apply the initial theme
   InitAllCategoriesAndTools();
   ApplyTheme();
   //--- Compute sidebar height based on the resolved category count
   CalcSidebarHeight();
   //--- Create sidebar canvases - low-res (final display) + high-res (SSAA source)
   if(!m_canvasSidebar.CreateBitmapLabel(0, 0, m_nameSidebar, 0, 0, m_sidebarWidth, m_sidebarHeight, COLOR_FORMAT_ARGB_NORMALIZE))
     { Print("Failed to create sidebar canvas"); return false; }
   if(!m_canvasSidebarHighRes.Create("ToolsPalette_SidebarHR", m_sidebarWidth * m_supersampleFactor, m_sidebarHeight * m_supersampleFactor, COLOR_FORMAT_ARGB_NORMALIZE))
     { Print("Failed to create sidebar HR canvas"); return false; }
   //--- Create flyout canvases - default 200x200 (resized on demand when a category is shown)
   if(!m_canvasFlyout.CreateBitmapLabel(0, 0, m_nameFlyout, 0, 0, 200, 200, COLOR_FORMAT_ARGB_NORMALIZE))
     { Print("Failed to create flyout canvas"); return false; }
   if(!m_canvasFlyoutHighRes.Create("ToolsPalette_FlyoutHR", 200 * m_supersampleFactor, 200 * m_supersampleFactor, COLOR_FORMAT_ARGB_NORMALIZE))
     { Print("Failed to create flyout HR canvas"); return false; }
   //--- Create crosshair canvases (reticle, magnifier, axis labels, measure lines)
   if(!CreateCrosshairCanvases()) return false;
   //--- Create the drawings canvas (where all user-drawn objects render)
   if(!CreateDrawingsCanvas()) return false;
   //--- Create object-axis label canvases (price / time labels that follow selected objects)
   if(!CreateObjLabelCanvases()) return false;
   //--- Create the ribbon + popover canvases (appears when an object is selected, hides on deselect)
   if(!CreateRibbonCanvases()) return false;
   //--- Create the Settings window canvas (dynamic property editor, opens when ribbon Settings icon is clicked)
   if(!InitSettingsWindow()) return false;
   //--- Configure the sidebar chart object's screen position and Z-order
   ObjectSetInteger(0, m_nameSidebar, OBJPROP_XDISTANCE, m_panelX);
   ObjectSetInteger(0, m_nameSidebar, OBJPROP_YDISTANCE, m_panelY);
   ObjectSetInteger(0, m_nameSidebar, OBJPROP_ZORDER,    100);
   //--- Flyout sits ABOVE the sidebar (higher Z-order so it draws on top when both are visible)
   ObjectSetInteger(0, m_nameFlyout,  OBJPROP_ZORDER,    200);
   //--- Initial render - flyout hidden, sidebar drawn at the configured position
   HideFlyout();
   DrawSidebar(m_currentActiveTool);
   ObjectSetInteger(0, m_nameSidebar, OBJPROP_XDISTANCE, m_panelX);
   ObjectSetInteger(0, m_nameSidebar, OBJPROP_YDISTANCE, m_panelY);
   //--- Enable mouse events so the EA actually receives mouse move + wheel
   ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE,  true);
   ChartSetInteger(0, CHART_EVENT_MOUSE_WHEEL, true);
   ChartSetInteger(0, CHART_MOUSE_SCROLL,      true);
   //--- Restore any persisted drawings for this chart, then paint them
   if(RestoreDrawings())
      RedrawAllObjects();
   //--- Persistent heartbeat timer drives the debounced drawing flush (and label-caret blink)
   EventSetMillisecondTimer(500);
   return true;
  }

//+------------------------------------------------------------------+
//| Hide crosshair + measure objects when switching tools            |
//+------------------------------------------------------------------+
void CToolsSidebar::CleanupCrosshairOnToolSwitch()
  {
   //--- Only cleanup if crosshair was the active tool or a measure session was in progress
   if(m_currentActiveTool == TOOL_CROSSHAIR || m_isMeasuringActive)
     {
      //--- Hide every crosshair-related canvas (reticle, magnifier, axis labels, etc.)
      HideAllCrosshairElements();
      //--- If a measure session was in progress, end it and clean up the measure overlays
      if(m_isMeasuringActive)
        {
         m_isMeasuringActive = false;
         DeleteAllMeasureObjects();
         //--- Restore chart scroll - measure mode locked it
         ChartSetInteger(0, CHART_MOUSE_SCROLL, true);
        }
     }
  }

//+------------------------------------------------------------------+
//| Tear down all canvases / chart objects + restore chart state     |
//+------------------------------------------------------------------+
void CToolsSidebar::Destroy()
  {
   //--- Hide crosshair + end any active measure session before tearing down canvases
   CleanupCrosshairOnToolSwitch();
   //--- Final persistence flush before teardown (covers timeframe change / EA removal)
   if(m_drawingsDirty && SaveDrawings()) m_drawingsDirty = false;
   //--- Kill the persistent heartbeat timer
   EventKillTimer();
   //--- Force-restore keyboard override (idempotent if not active) - prevents lock-out on unexpected unload
   EndKeyboardOverride();
   m_currentActiveTool = TOOL_NONE;
   //--- Destroy sidebar canvases (low-res + HR) and remove the chart object
   m_canvasSidebar.Destroy();        ObjectDelete(0, m_nameSidebar);
   m_canvasSidebarHighRes.Destroy();
   //--- Destroy flyout canvases (low-res + HR) and remove the chart object
   m_canvasFlyout.Destroy();         ObjectDelete(0, m_nameFlyout);
   m_canvasFlyoutHighRes.Destroy();
   //--- Destroy crosshair canvases (reticle, magnifier, axis labels, measure lines)
   DestroyCrosshairCanvases();
   //--- Destroy the drawings canvas
   DestroyDrawingsCanvas();
   //--- Destroy object-axis label canvases
   DestroyObjLabelCanvases();
   //--- Destroy the ribbon + popover canvases (Part 8 - inherited from CRibbon base class)
   DestroyRibbonCanvases();
   //--- Restore chart scrolling (the EA may have locked it during pointer/measure modes)
   ChartSetInteger(0, CHART_MOUSE_SCROLL, true);
  }

//+------------------------------------------------------------------+
//| Toggle the given tool on or off                                  |
//+------------------------------------------------------------------+
void CToolsSidebar::ToggleTool(TOOL_TYPE toolType)
  {
   //--- Tool-switch cleanup in 3 ordered steps: Finalize edits, DeselectAll, CancelInProgressPlacement
   FinalizeOpenLabelEdit();
   DeselectAll();
   CancelInProgressPlacement();
   //--- Hide crosshair + end any active measure session before switching tools
   CleanupCrosshairOnToolSwitch();
   //--- Pointer or same-tool-as-active => deactivate (toggle off)
   if(toolType == TOOL_POINTER || m_currentActiveTool == toolType)
     {
      m_currentActiveTool     = TOOL_NONE;
      m_toolDrawingClickCount = 0;
      m_currentInstruction    = "";
      //--- Restore scroll when switching away from any tool
      ChartSetInteger(0, CHART_MOUSE_SCROLL, true);
     }
   else
     {
      //--- Switch to the new tool and reset placement state
      m_currentActiveTool     = toolType;
      m_toolDrawingClickCount = 0;
      //--- Remember the new tool as the LAST-USED for its category (so the sidebar tile renders this tool's icon)
      RecordToolSelection(toolType);
      //--- Tool-specific instruction text + scroll-lock behavior
      if(toolType == TOOL_CROSSHAIR)
        {
         m_currentInstruction = "Move mouse for crosshair. Double-click to measure.";
         ShowAllCrosshairElements();
         //--- Crosshair manages scroll itself (see HandleCrosshairMouseMove)
         ChartSetInteger(0, CHART_MOUSE_SCROLL, true);
        }
      else if(toolType == TOOL_POINTER || toolType == TOOL_NONE)
        {
         m_currentInstruction = "";
         //--- Pointer mode locks scroll to prevent chart movement during object interaction
         ChartSetInteger(0, CHART_MOUSE_SCROLL, false);
        }
      else
        {
         //--- Drawing tools: allow chart scroll between clicks
         m_currentInstruction = "Click on chart to place " + GetToolLabel(toolType) + ".";
         ChartSetInteger(0, CHART_MOUSE_SCROLL, true);
        }
     }
  }

//+------------------------------------------------------------------+
//| Fully tear down the active tool (Escape key + completion paths)  |
//+------------------------------------------------------------------+
void CToolsSidebar::DeactivateCurrentTool()
  {
   //--- Same 3-step cleanup as ToggleTool (see the comment block in ToggleTool)
   FinalizeOpenLabelEdit();
   DeselectAll();
   CleanupCrosshairOnToolSwitch();
   //--- If we were mid-path-drawing, flush the accumulator arrays so the next path tool starts clean
   if(m_currentActiveTool == TOOL_PATH)
      CancelPath();
   //--- Reset all tool-state fields back to "no tool active" baseline
   m_currentActiveTool     = TOOL_NONE;
   m_toolDrawingClickCount = 0;
   m_currentInstruction    = "";
   m_isPreviewActive       = false;
   //--- Restore chart scroll when deactivating any tool
   ChartSetInteger(0, CHART_MOUSE_SCROLL, true);
   //--- Redraw the sidebar with no active tool highlight
   DrawSidebar(m_currentActiveTool);
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| Update crosshair canvases as the cursor moves                    |
//+------------------------------------------------------------------+
void CToolsSidebar::HandleCrosshairMouseMove(int mouseX, int mouseY, bool overSidebar, bool overFlyout)
  {
   //--- Only update crosshair while the crosshair tool is active
   if(m_currentActiveTool != TOOL_CROSSHAIR) return;
   //--- Hide crosshair while cursor is over sidebar / flyout (the UI takes priority)
   if(overSidebar || overFlyout) { HideAllCrosshairElements(); return; }
   //--- Show every crosshair element back to the chart
   ShowAllCrosshairElements();
   //--- Convert the cursor pixel coords into bar time + price for label updates
   datetime barTime; double barPrice; int subWindow;
   if(ChartXYToTimePrice(m_chartId, mouseX, mouseY, subWindow, barTime, barPrice))
     {
      //--- Reposition the crosshair vertical + horizontal lines
      UpdateCrossVerticalPosition(mouseX);
      UpdateCrossHorizontalPosition(mouseY);
      //--- Refresh the axis labels with the current time + price values
      UpdateCrosshairAxisLabels(mouseX, mouseY, barTime, barPrice);
      //--- Move the reticle + magnifier overlays to follow the cursor
      UpdateReticlePosition(mouseX, mouseY);
      UpdateMagnifierPosition(mouseX, mouseY, barTime, barPrice);
      //--- If we're in measure mode, update the anchor lines + diagonal + info label
      if(m_isMeasuringActive)
        {
         //--- Convert the measure anchor (time + price) back to pixel coords
         int fx = 0, fy = 0;
         if(ChartTimePriceToXY(m_chartId, 0, m_measureAnchorTime, m_measureAnchorPrice, fx, fy))
           {
            //--- Show + reposition the anchor vertical / horizontal measure lines
            ShowMeasureLines();
            UpdateMeasureVerticalPosition(fx);
            UpdateMeasureHorizontalPosition(fy);
            UpdateMeasureAnchorLabels();
           }
         //--- Update the diagonal measure line (anchor -> cursor) and its info label
         UpdateMeasureDiagonalLine(mouseX, mouseY);
         UpdateMeasurementInfoLabel(mouseX, mouseY, barTime, barPrice);
        }
      ChartRedraw();
     }
  }

//+------------------------------------------------------------------+
//| Main chart event dispatcher - called from EA's OnChartEvent      |
//+------------------------------------------------------------------+
void CToolsSidebar::OnEvent(const int id, const long &lp, const double &dp, const string &sp)
  {
   //--- Popover keyboard input gets FIRST refusal: % box in color picker captures digits/backspace/enter/escape; PopoverKeyDown returns true when consumed
   if(id == CHARTEVENT_KEYDOWN && IsPopoverVisible())
     {
      if(PopoverKeyDown((uint)lp))
        {
         return;
        }
     }

   //+--------------------------------------------------------------+
   //| Coordinates-tab edit keyboard routing.                       |
   //|                                                              |
   //| When a price/bar button is in edit mode, all keystrokes go   |
   //| to HandleCoordKey (digits, '.', '-', backspace, delete,      |
   //| arrows, Home/End, Enter=commit, Esc=cancel). HandleCoordKey  |
   //| returns true when it consumed the key; we early-out so the   |
   //| same key doesn't fire the chart-side label-edit path too.    |
   //+--------------------------------------------------------------+
   if(id == CHARTEVENT_KEYDOWN && IsSettingsVisible() && IsEditingCoord())
     {
      if(HandleCoordKey((uint)lp)) return;
     }
   //--- Float-edit (compact-row value steppers) uses the same routing
   if(id == CHARTEVENT_KEYDOWN && IsSettingsVisible() && IsEditingFloat())
     {
      if(HandleFloatKey((uint)lp)) return;
     }

   //--- Caret-blink drivers (cheap no-op when nothing's editing) - chart event frequency replaces dedicated timer
   RibbonTick();
   SettingsTick();

   //--- Escape key: cancel label edit, cancel rubber-band preview, or deactivate the active tool
   if(id == CHARTEVENT_KEYDOWN && lp == 27)
     {
      //--- Editing label => cancel the edit and bail
      if(m_isEditingLabel) { CancelLabel(); ChartRedraw(); return; }
      //--- Preview active => cancel placement (also flush path-tool accumulator for clean restart)
      if(m_isPreviewActive)
        {
         if(m_previewToolType == TOOL_PATH)
            CancelPath();
         m_isPreviewActive       = false;
         m_toolDrawingClickCount = 0;
         RedrawAllObjects();
         ChartRedraw();
         return;
        }
      //--- Otherwise => deactivate the active tool
      DeactivateCurrentTool();
      return;
     }

   //--- Delete key: forward-delete inside edit OR delete the selected object outside edit
   if(id == CHARTEVENT_KEYDOWN && lp == 46)
     {
      if(m_isEditingLabel)
        {
         //--- Editing => forward-delete character at the caret position
         DeleteAtCaret();
         NotifyTextAreaBufferChanged();
         ChartRedraw();
         return;
        }
      //--- Not editing => delete the selected drawn object
      DeleteSelectedObject();
      ChartRedraw();
      return;
     }

   //--- Backspace key during edit: delete the character BEFORE the caret
   if(id == CHARTEVENT_KEYDOWN && lp == 8 && m_isEditingLabel)
     {
      BackspaceAtCaret();
      NotifyTextAreaBufferChanged();
      ChartRedraw();
      return;
     }

   //--- Enter key during edit: insert a newline at the caret position
   if(id == CHARTEVENT_KEYDOWN && lp == 13 && m_isEditingLabel)
     {
      InsertNewlineAtCaret();
      NotifyTextAreaBufferChanged();
      ChartRedraw();
      return;
     }

   //--- Caret navigation keys during edit (arrows / Home / End - with optional Shift-extend)
   if(id == CHARTEVENT_KEYDOWN && m_isEditingLabel)
     {
      int vk = (int)lp;
      //--- Only the text-area code path handles Shift-extend selection (Part 8 stub returns false in Part 7)
      if(IsTextAreaFocused())
        {
         //--- Read Shift-key state from terminal info - negative or high-bit set means held
         const int  shiftRaw  = (int)TerminalInfoInteger(TERMINAL_KEYSTATE_SHIFT);
         const bool shiftDown = (shiftRaw < 0) || ((shiftRaw & 0x8000) != 0);
         //--- Shift held => extend the selection in the direction of the arrow key
         if(shiftDown)
           {
            if(vk == 37) { ShiftExtendCaretLeft();  NotifyTextAreaBufferChanged(); ChartRedraw(); return; }
            if(vk == 39) { ShiftExtendCaretRight(); NotifyTextAreaBufferChanged(); ChartRedraw(); return; }
            if(vk == 38) { ShiftExtendCaretUp();    NotifyTextAreaBufferChanged(); ChartRedraw(); return; }
            if(vk == 40) { ShiftExtendCaretDown();  NotifyTextAreaBufferChanged(); ChartRedraw(); return; }
            if(vk == 36) { ShiftExtendCaretHome();  NotifyTextAreaBufferChanged(); ChartRedraw(); return; }
            if(vk == 35) { ShiftExtendCaretEnd();   NotifyTextAreaBufferChanged(); ChartRedraw(); return; }
           }
        }
      //--- Plain caret movement (no Shift) - one direction at a time
      if(vk == 37) { MoveCaretLeft();  NotifyTextAreaBufferChanged(); ChartRedraw(); return; }
      if(vk == 39) { MoveCaretRight(); NotifyTextAreaBufferChanged(); ChartRedraw(); return; }
      if(vk == 38) { MoveCaretUp();    NotifyTextAreaBufferChanged(); ChartRedraw(); return; }
      if(vk == 40) { MoveCaretDown();  NotifyTextAreaBufferChanged(); ChartRedraw(); return; }
      if(vk == 36) { MoveCaretHome();  NotifyTextAreaBufferChanged(); ChartRedraw(); return; }
      if(vk == 35) { MoveCaretEnd();   NotifyTextAreaBufferChanged(); ChartRedraw(); return; }
     }

   //--- T key: start label editing on the currently selected object
   if(id == CHARTEVENT_KEYDOWN && lp == 84)
     {
      if(m_selectedObjectId >= 0 && !m_isEditingLabel)
        { StartLabelEdit(); ChartRedraw(); return; }
     }

   //--- Typed-character capture during label edit - filter modifiers / navigation / function keys first
   if(id == CHARTEVENT_KEYDOWN && m_isEditingLabel)
     {
      //--- Skip the keys already handled above (backspace / enter / escape / delete)
      if(lp == 8 || lp == 13 || lp == 27 || lp == 46) return;
      int vk = (int)lp;
      //--- Filter out non-printable keys that shouldn't insert characters
      bool isModifier   = (vk==16||vk==17||vk==18||vk==20||vk==144||vk==145||vk==91||vk==92||vk==93);
      bool isNavigation = (vk>=33&&vk<=40)||(vk==45);
      bool isFunctionKey = (vk>=112&&vk<=123);
      bool isTab = (vk==9);
      if(isModifier||isNavigation||isFunctionKey||isTab) return;
      //--- Only accept VK ranges that correspond to printable characters (space, digits, letters, etc.)
      bool isPrintableVk = (vk==32)||(vk>=48&&vk<=57)||(vk>=65&&vk<=90)||(vk>=96&&vk<=111)||(vk>=186&&vk<=223);
      if(!isPrintableVk) return;
      //--- Translate the virtual-key code to a Unicode character (honoring Shift state)
      short uch = TranslateKey(vk);
      if(uch > 0)
        {
         //--- Convert to string and insert at the caret position
         ushort code = (ushort)uch;
         string ch   = ShortToString(code);
         if(StringLen(ch) > 0)
           { InsertCharAtCaret(ch); NotifyTextAreaBufferChanged(); ChartRedraw(); return; }
        }
     }

   //--- MOUSE_MOVE: the bulk of the event dispatcher
   if(id == CHARTEVENT_MOUSE_MOVE)
     {
      //--- Unpack the lp/dp/sp event params into mouse-state locals
      int mouseX = (int)lp, mouseY = (int)dp, mouseButtons = (int)sp;
      //--- Resolve sidebar / flyout containment + local coordinates
      int lx, ly, flx, fly;
      bool overSidebar = HitTestOverSidebar(mouseX, mouseY, lx, ly);
      bool overFlyout  = !overSidebar && HitTestOverFlyout(mouseX, mouseY, flx, fly);

      //--- Pointer mode must lock scroll, but ONLY write when state differs (avoid CHART_CHANGE event storm)
      if(m_currentActiveTool == TOOL_NONE || m_currentActiveTool == TOOL_POINTER)
        {
         if((bool)ChartGetInteger(0, CHART_MOUSE_SCROLL) != false)
            ChartSetInteger(0, CHART_MOUSE_SCROLL, false);
        }

      //--- Theme toggle button click - flip the theme and re-render everything that uses theme colors
      if(mouseButtons == 1 && m_previousMouseButtonState == 0 &&
         overSidebar && m_isThemeButtonHovered)
        {
         ToggleTheme();
         DrawSidebar(m_currentActiveTool);
         //--- Redraw flyout (if open) + every crosshair canvas that uses theme colors
         if(m_isFlyoutVisible) DrawFlyoutForCategory(m_flyoutActiveCat, m_currentActiveTool);
         if(m_isCrossVertVisible)  { int chartH = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS); DrawCrossVerticalLinePixels(chartH); }
         if(m_isCrossHorizVisible) { int chartW = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);  DrawCrossHorizontalLinePixels(chartW); }
         if(m_isReticleVisible) DrawReticleTickMarks();
         //--- Ribbon also reads theme colors so it needs a redraw on theme change
         if(IsRibbonVisible()) RedrawRibbon();
         ChartRedraw();
         m_previousMouseButtonState = mouseButtons;
         return;
        }

      //--- Flyout item click - branches on category type (action vs tool category)
      if(mouseButtons == 1 && m_previousMouseButtonState == 0 &&
         overFlyout && m_hoveredFlyoutItem >= 0 && m_flyoutActiveCat != CAT_NONE)
        {
         //--- Action category (e.g. CAT_DELETE): invoke the action directly; no tool gets activated
         if(IsActionCategory(m_flyoutActiveCat))
           {
            //--- Currently the only action category is CAT_DELETE - branch by category if more get added
            if(m_flyoutActiveCat == CAT_DELETE)
              {
               //--- Same 3-step cleanup as ToggleTool, then clear all drawn objects
               FinalizeOpenLabelEdit();
               DeselectAll();
               CancelInProgressPlacement();
               ClearAllDrawnObjects();
              }
            //--- Hide flyout + redraw sidebar regardless of which action category fired
            HideFlyout();
            DrawSidebar(m_currentActiveTool);
            ChartRedraw();
            m_previousMouseButtonState = mouseButtons;
            return;
           }

         //--- Regular tool category: ToggleTool with the picked tool
         int nT = ArraySize(m_categories[(int)m_flyoutActiveCat].tools);
         if(m_hoveredFlyoutItem < nT)
           {
            ToggleTool(m_categories[(int)m_flyoutActiveCat].tools[m_hoveredFlyoutItem].toolType);
            HideFlyout();
            DrawSidebar(m_currentActiveTool);
            ChartRedraw();
           }
         m_previousMouseButtonState = mouseButtons;
         return;
        }

      //--- Category tile click - activates the LAST-USED tool from that category
      if(mouseButtons == 1 && m_previousMouseButtonState == 0 &&
         overSidebar && m_hoveredCategory != CAT_NONE &&
         !m_isCloseButtonHovered && !m_isThemeButtonHovered && !m_isGripAreaHovered &&
         ArraySize(m_categories[(int)m_hoveredCategory].tools) > 0)
        {
         //--- Decide which tool to activate: single-tool category vs multi-tool category
         int nT = ArraySize(m_categories[(int)m_hoveredCategory].tools);
         TOOL_TYPE pickedTool;
         if(nT == 1)
           {
            //--- Single-tool category - straightforward toggle of that one tool
            pickedTool = m_categories[(int)m_hoveredCategory].tools[0].toolType;
           }
         else
           {
            //--- Multi-tool category - pick the last-used tool for this category (defensive fallback to tools[0])
            pickedTool = m_lastUsedToolPerCategory[(int)m_hoveredCategory];
            if(pickedTool == TOOL_NONE)
               pickedTool = m_categories[(int)m_hoveredCategory].tools[0].toolType;
           }
         //--- Activate the picked tool, hide the flyout, redraw the sidebar with the new active state
         ToggleTool(pickedTool);
         HideFlyout();
         DrawSidebar(m_currentActiveTool);
         ChartRedraw();
         m_previousMouseButtonState = mouseButtons;
         return;
        }

      //--- Crosshair double-click on chart toggles measure mode (uses chart-side click timing)
      if(mouseButtons == 1 && m_previousMouseButtonState == 0 &&
         m_currentActiveTool == TOOL_CROSSHAIR && !overSidebar && !overFlyout)
        {
         //--- Convert click pixel coords into bar time + price for the measure anchor
         datetime barTime; double barPrice; int subWindow;
         if(ChartXYToTimePrice(m_chartId, mouseX, mouseY, subWindow, barTime, barPrice))
            HandleCrosshairDoubleClick(mouseX, mouseY, barTime, barPrice);
         m_previousMouseButtonState = mouseButtons;
         return;
        }

      //--- Drawing-tool placement click on chart (NOT crosshair / pointer / no-tool)
      if(mouseButtons == 1 && m_previousMouseButtonState == 0 &&
         m_currentActiveTool != TOOL_NONE     &&
         m_currentActiveTool != TOOL_CROSSHAIR &&
         m_currentActiveTool != TOOL_POINTER   &&
         !overSidebar && !overFlyout)
        {
         //--- Cache the tool BEFORE the click - HandleDrawingClick may reset it to TOOL_NONE on completion
         TOOL_TYPE toolBeforeClick = m_currentActiveTool;
         HandleDrawingClick(mouseX, mouseY, m_currentActiveTool, m_currentInstruction);
         //--- If the click finalized the object (tool reset to TOOL_NONE), run the deactivation path
         if(toolBeforeClick != TOOL_NONE && m_currentActiveTool == TOOL_NONE)
           {
            m_isPreviewActive       = false;
            m_toolDrawingClickCount = 0;
            //--- Restore scroll-lock to the pointer-mode default (locked)
            ChartSetInteger(0, CHART_MOUSE_SCROLL, false);
            //--- Clear hover state on completion so the newly-created object is purely SELECTED (not hovered)
            m_hoveredObjectId     = -1;
            m_hoveredHandleIdx    = -1;
            m_hoveredHandleHostId = -1;
            //--- Force a redraw so the new object's handles appear immediately on selection
            RedrawAllObjects();
           }
         //--- Redraw the sidebar to reflect the new active-tool state (likely cleared)
         DrawSidebar(m_currentActiveTool);
         ChartRedraw();
         m_previousMouseButtonState = mouseButtons;
         return;
        }

      //--- Update crosshair canvas positions for the current cursor location
      HandleCrosshairMouseMove(mouseX, mouseY, overSidebar, overFlyout);

      //--- Rubber-band preview update during multi-click tool placement
      if(m_isPreviewActive && !overSidebar && !overFlyout)
        {
         UpdatePreviewMousePos(mouseX, mouseY);
         RedrawAllObjects();
         ChartRedraw();
        }

      //--- Pointer-mode hover detection - drives hover halos when no drag is active
      if((m_currentActiveTool == TOOL_NONE || m_currentActiveTool == TOOL_POINTER) &&
         !m_isDraggingHandle && !m_isDraggingObject && !overSidebar && !overFlyout)
         HandlePointerMouseMove(mouseX, mouseY);

      //--- Route remaining mouse-move handling (sidebar/panel drags + click-down) via the base dispatcher
      RouteChartEvent(id, lp, dp, sp, m_currentActiveTool);

      //--- Update sidebar tooltip text based on what's currently hovered
      string tip = "";
      if(overSidebar && m_hoveredCategory != CAT_NONE)
         tip = m_categories[(int)m_hoveredCategory].categoryLabel;
      if(overFlyout && m_hoveredFlyoutItem >= 0 && m_flyoutActiveCat != CAT_NONE)
        {
         int nT = ArraySize(m_categories[(int)m_flyoutActiveCat].tools);
         if(m_hoveredFlyoutItem < nT)
            tip = m_categories[(int)m_flyoutActiveCat].tools[m_hoveredFlyoutItem].tooltipText;
        }
      ObjectSetString(0, m_nameSidebar, OBJPROP_TOOLTIP, tip);
      return;
     }

   //--- Route all non-MOUSE_MOVE events (CHART_CHANGE, MOUSE_WHEEL) via the base dispatcher
   RouteChartEvent(id, lp, dp, sp, m_currentActiveTool);
  }

//+------------------------------------------------------------------+
//| Timer callback - drives the label-edit cursor blink animation    |
//+------------------------------------------------------------------+
void CToolsSidebar::OnTimer()
  {
   //--- Persistent heartbeat timer (500 ms): label caret blink, settings/popover ticks, debounced drawing flush
   if(m_isEditingLabel)
     {
      //--- Redraw all objects so the caret visibly toggles on / off
      RedrawAllObjects();
      ChartRedraw();
     }
   //--- Drive the settings text-area caret blink from the timer too (cheap no-op when not focused)
   SettingsTick();
   //--- Also drive the popover opacity-box caret blink (independent timer phase, but same trigger)
   RibbonTick();
   //--- Debounced persistence flush (writes at most ~once per change burst)
   MaybeFlushDrawings();
  }

#endif // TOOLS_PALETTE_SHELL_MQH
//+------------------------------------------------------------------+
