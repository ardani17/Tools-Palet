//+------------------------------------------------------------------+
//|                                          ToolsPalette_Ribbon.mqh |
//|                                            Copyright 2026, Om J. |
//|                                               https://t.me/HZFXI |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Om J."
#property link "https://t.me/HZFXI"
#property version "1.00"
#property strict

//--- Guard against multiple inclusion of this header
#ifndef TOOLS_PALETTE_RIBBON_MQH
#define TOOLS_PALETTE_RIBBON_MQH

//--- Pull in the Sidebar (base class), property descriptor system, and widget renderers
#include "../core/ToolsPalette_Sidebar.mqh"
#include "ToolsPalette_Properties.mqh"
#include "ToolsPalette_PropertyWidgets.mqh"

//+------------------------------------------------------------------+
//| CRibbon - quick-access property-editing ribbon for the selection |
//+------------------------------------------------------------------+
class CRibbon : public CSidebarRenderer
  {
protected:
   //--- Ribbon canvas + high-res supersample backing canvas
   string          m_nameRibbon;
   CCanvas         m_canvasRibbon;
   CCanvas         m_canvasRibbonHighRes;

   //--- Ribbon dimensions (recomputed when content changes)
   int             m_ribbonWidth;
   int             m_ribbonHeight;
   int             m_ribbonCornerRadius;
   int             m_ribbonShadowPad;

   //--- Current ribbon position + last-known position cache (for restore after hide/show)
   int             m_ribbonX;
   int             m_ribbonY;
   int             m_lastRibbonX;
   int             m_lastRibbonY;
   bool            m_lastRibbonValid;

   //--- Visibility + bound object ID (the drawn object the ribbon edits)
   bool            m_isRibbonVisible;
   int             m_ribbonOwnerObjectId;

   //--- Drag state (set while the user is moving the ribbon via the grip)
   bool            m_isRibbonDragging;
   int             m_ribbonDragOffsetX;
   int             m_ribbonDragOffsetY;

   //--- Width of the drag-grip area on the left edge
   int             m_ribbonGripWidth;

   //--- Icon row geometry (size, gap between icons, left/right padding inside the body)
   int             m_ribbonIconSize;
   int             m_ribbonIconGap;
   int             m_ribbonIconRowPadX;

   //--- Hovered icon index (-1 when nothing is hovered)
   int             m_hoveredRibbonIconIdx;

   //--- Filtered property descriptor list (subset of BuildPropertyListForTool that's ribbon-eligible)
   SToolProperty   m_ribbonProperties[];

   //--- Popover canvas + high-res backing canvas
   string          m_namePopover;
   CCanvas         m_canvasPopover;
   CCanvas         m_canvasPopoverHighRes;

   //--- Popover visibility + which property's popover is open + screen-space rect
   bool            m_isPopoverVisible;
   string          m_activePopoverPropId;
   int             m_popoverX;
   int             m_popoverY;
   int             m_popoverWidth;
   int             m_popoverHeight;
   int             m_popoverShadowPad;
   int             m_popoverCornerRadius;

   //--- True when a parent owns the property-edit snapshot lifecycle (Settings window case)
   bool            m_popoverSnapshotIsExternal;

   //--- Opacity slider drag state + current slider value
   bool            m_isOpacityDragging;
   int             m_opacityValuePct;

   //--- Hovered popover item index (swatch / row / row depending on popover type)
   int             m_hoveredPopoverSwatchIdx;

   //--- Inline opacity-box editing state (text buffer + caret position + blink phase)
   bool            m_isEditingBoxOpacity;
   string          m_boxEditBuffer;
   int             m_boxCaretPos;
   bool            m_boxCaretOn;
   ulong           m_boxBlinkTickAt;

public:
   //--- Lifecycle - create/destroy the ribbon's chart-object canvases
   bool            CreateRibbonCanvases();
   void            DestroyRibbonCanvases();

   //--- Show/hide the ribbon bound to a specific drawn-object ID
   void            ShowRibbonFor(int objId);
   void            HideRibbon();
   bool            IsRibbonVisible() const { return m_isRibbonVisible; }

   //--- Hook for subclasses that route the Settings action button into a settings window
   virtual void    OpenSettingsWindowForObject(int objId) { }

   //--- Force a full re-render of the ribbon canvas
   void            RedrawRibbon();

   //--- Mouse routing + grip hit-test (returns local coords via out-params)
   bool            HitTestOverRibbon(int mouseX, int mouseY, int &lx, int &ly);
   bool            HitTestOverRibbonGrip(int lx, int ly);
   bool            RibbonMouseMove(int mouseX, int mouseY, uint mouseButtons);
   bool            RibbonMouseDown(int mouseX, int mouseY);
   bool            RibbonMouseUp();

   //--- Popover lifecycle + show for a specific property id (optionally with flip anchor)
   bool            CreatePopoverCanvas();
   void            DestroyPopoverCanvas();
   void            ShowPopoverForProperty(string propId, int anchorX, int anchorY,
                                            int flipBaseTop = -1);
   void            HidePopover();
   bool            IsPopoverVisible() const { return m_isPopoverVisible; }
   void            RedrawPopover();
   bool            HitTestOverPopover(int mouseX, int mouseY, int &lx, int &ly);
   bool            PopoverMouseDown(int mouseX, int mouseY);
   bool            PopoverMouseMove(int mouseX, int mouseY, uint mouseButtons);
   bool            PopoverMouseUp();

   //--- Popover keyboard handler (for the editable opacity box) + caret-blink tick
   bool            PopoverKeyDown(uint keyCode);
   void            RibbonTick();

   //--- Selection-changed hook from CSidebarRenderer - show/hide ribbon based on the new selection
   virtual void    OnSelectionChanged(int objId)
     {
      //--- Positive objId = a single drawn object was selected; otherwise hide
      if(objId >= 0)
         ShowRibbonFor(objId);
      else
         HideRibbon();
     }

   //--- Hook for subclasses that need to know when the popover just closed (e.g., refocus a parent)
   virtual void    OnPopoverClosed() { /* default no-op */ }

protected:
   //--- Position calculation + clamp-to-chart-bounds + apply to the chart object
   void            CalcRibbonDefaultPosition(int &outX, int &outY);
   void            ClampRibbonToChart();
   void            ApplyRibbonPosition();
   //--- Draw the 2x4 grip-dot pattern on the left edge
   void            DrawGripDots(CCanvas &canvas, int hrScale);

   //--- Rebuild the filtered descriptor list + compute the ribbon's content-width
   void            RefreshRibbonProperties();
   int             CalcRibbonContentWidth();
   void            DrawRibbonIcons();
   int             HitTestRibbonIcon(int lx, int ly);
   void            GetRibbonIconBounds(int idx, int &outX, int &outY, int &outSize);
   int             GetRibbonIconWidthForType(PROP_TYPE t);

   //--- Popover positioning + flip-when-clipped logic
   void            ApplyPopoverPosition();
   void            ClampPopoverToChart();
   void            CalcPopoverPositionForAnchor(int anchorX, int anchorY,
                                                  int popoverW, int popoverH,
                                                  int &outX, int &outY,
                                                  int flipBaseTop = -1);

   //--- Commit the opacity-box text buffer back to the live opacity property
   void            CommitBoxEditToOpacity();
  };

//+------------------------------------------------------------------+
//| Create the ribbon's chart-object canvases + popover canvas       |
//+------------------------------------------------------------------+
bool CRibbon::CreateRibbonCanvases()
  {
   //--- Seed ribbon geometry constants (width is a placeholder; recomputed in ShowRibbonFor)
   m_ribbonWidth          = 280;
   m_ribbonHeight         = 36;
   m_ribbonCornerRadius   = 8;
   m_ribbonGripWidth      = 22;
   m_ribbonShadowPad      = 4;

   //--- Seed position state (will be recalculated when the ribbon first becomes visible)
   m_ribbonX              = 0;
   m_ribbonY              = 0;
   m_lastRibbonX          = 0;
   m_lastRibbonY          = 0;
   m_lastRibbonValid      = false;

   //--- Seed visibility + binding state
   m_isRibbonVisible      = false;
   m_ribbonOwnerObjectId  = -1;

   //--- Seed drag state
   m_isRibbonDragging     = false;
   m_ribbonDragOffsetX    = 0;
   m_ribbonDragOffsetY    = 0;

   //--- Icon row geometry - 22 px square matches the sidebar/flyout tile family
   m_ribbonIconSize       = 22;
   m_ribbonIconGap        = 8;
   m_ribbonIconRowPadX    = 10;
   m_hoveredRibbonIconIdx = -1;
   ArrayResize(m_ribbonProperties, 0);

   //--- Seed popover state (canvas itself is created via CreatePopoverCanvas below)
   m_namePopover          = "ToolsPalette_RibbonPopover";
   m_isPopoverVisible     = false;
   m_activePopoverPropId  = "";
   m_popoverSnapshotIsExternal = false;
   m_popoverX             = 0;
   m_popoverY             = 0;
   m_popoverWidth         = 0;
   m_popoverHeight        = 0;
   m_popoverShadowPad     = 4;
   m_popoverCornerRadius  = 8;
   m_isOpacityDragging    = false;
   m_opacityValuePct      = 100;
   m_hoveredPopoverSwatchIdx = -1;
   m_isEditingBoxOpacity  = false;
   m_boxEditBuffer        = "";
   m_boxCaretPos          = 0;
   m_boxCaretOn           = false;
   m_boxBlinkTickAt       = 0;

   //--- Chart-object name used to back the ribbon canvas
   m_nameRibbon = "ToolsPalette_Ribbon";

   //--- Canvas dimensions include the shadow halo on all 4 sides
   const int canvasW = m_ribbonWidth  + 2 * m_ribbonShadowPad;
   const int canvasH = m_ribbonHeight + 2 * m_ribbonShadowPad;

   //--- Create the display canvas + bail if creation failed
   if(!m_canvasRibbon.CreateBitmapLabel(0, 0, m_nameRibbon, 0, 0,
                                         canvasW, canvasH,
                                         COLOR_FORMAT_ARGB_NORMALIZE))
     {
      Print("[DIAG] Ribbon: failed to create display canvas");
      return false;
     }

   //--- Create the high-res supersample canvas (used for AA when downscaling)
   if(!m_canvasRibbonHighRes.Create("ToolsPalette_RibbonHR",
                                      m_ribbonWidth  * m_supersampleFactor,
                                      m_ribbonHeight * m_supersampleFactor,
                                      COLOR_FORMAT_ARGB_NORMALIZE))
     {
      Print("[DIAG] Ribbon: failed to create HR canvas");
      return false;
     }

   //--- Chart-object properties: high Z-order, initially hidden, non-selectable, no chart-period filtering
   ObjectSetInteger(0, m_nameRibbon, OBJPROP_ZORDER,    300);
   ObjectSetInteger(0, m_nameRibbon, OBJPROP_HIDDEN,    true);
   ObjectSetInteger(0, m_nameRibbon, OBJPROP_BACK,      false);
   ObjectSetInteger(0, m_nameRibbon, OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0, m_nameRibbon, OBJPROP_TIMEFRAMES, OBJ_NO_PERIODS);

   //--- Now create the popover canvas; bail if that fails too
   if(!CreatePopoverCanvas())
     {
      Print("[DIAG] Ribbon: failed to create popover canvas");
      return false;
     }
   return true;
  }

//+------------------------------------------------------------------+
//| Create the popover's chart-object canvas (sized to color picker) |
//+------------------------------------------------------------------+
bool CRibbon::CreatePopoverCanvas()
  {
   //--- Initial canvas size matches the color picker body (popovers resize on-show as needed)
   const int bodyW = GetColorPickerBodyWidth();
   const int bodyH = GetColorPickerBodyHeight();
   const int canvasW = bodyW + 2 * m_popoverShadowPad;
   const int canvasH = bodyH + 2 * m_popoverShadowPad;

   //--- Create the display canvas; bail on failure
   if(!m_canvasPopover.CreateBitmapLabel(0, 0, m_namePopover, 0, 0,
                                          canvasW, canvasH,
                                          COLOR_FORMAT_ARGB_NORMALIZE))
     {
      return false;
     }
   //--- Create the high-res supersample canvas for AA
   if(!m_canvasPopoverHighRes.Create("ToolsPalette_RibbonPopoverHR",
                                       bodyW * m_supersampleFactor,
                                       bodyH * m_supersampleFactor,
                                       COLOR_FORMAT_ARGB_NORMALIZE))
     {
      return false;
     }

   //--- Chart-object properties: higher Z than the ribbon (popovers must be ABOVE the ribbon)
   ObjectSetInteger(0, m_namePopover, OBJPROP_ZORDER,    350);
   ObjectSetInteger(0, m_namePopover, OBJPROP_HIDDEN,    true);
   ObjectSetInteger(0, m_namePopover, OBJPROP_BACK,      false);
   ObjectSetInteger(0, m_namePopover, OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0, m_namePopover, OBJPROP_TIMEFRAMES, OBJ_NO_PERIODS);
   return true;
  }

//+------------------------------------------------------------------+
//| Destroy the ribbon canvases + cascade into the popover destroy   |
//+------------------------------------------------------------------+
void CRibbon::DestroyRibbonCanvases()
  {
   //--- Free both display + HR canvases and delete the chart object
   m_canvasRibbon.Destroy();
   m_canvasRibbonHighRes.Destroy();
   if(ObjectFind(0, m_nameRibbon) >= 0) ObjectDelete(0, m_nameRibbon);
   //--- Cascade into the popover destroy
   DestroyPopoverCanvas();
  }

//+------------------------------------------------------------------+
//| Destroy the popover canvas + delete its chart object             |
//+------------------------------------------------------------------+
void CRibbon::DestroyPopoverCanvas()
  {
   //--- Free both display + HR canvases and delete the chart object
   m_canvasPopover.Destroy();
   m_canvasPopoverHighRes.Destroy();
   if(ObjectFind(0, m_namePopover) >= 0) ObjectDelete(0, m_namePopover);
  }

//+------------------------------------------------------------------+
//| Compute the default ribbon position (near the sidebar)           |
//+------------------------------------------------------------------+
void CRibbon::CalcRibbonDefaultPosition(int &outX, int &outY)
  {
   //--- When the sidebar is on the left, position the ribbon just to its right; when snapped right, snap the ribbon to the left edge
   int sidebarRightEdge = m_panelX + m_sidebarWidth;
   int chartW = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);

   if(m_snapState == SNAP_RIGHT)
      outX = 12;
   else
      outX = sidebarRightEdge + 12;

   //--- Vertically align with the sidebar
   outY = m_panelY;

   //--- If the ribbon would extend past the right edge, push it leftward (but never past inset 12)
   if(outX + m_ribbonWidth > chartW - 12)
      outX = MathMax(12, chartW - m_ribbonWidth - 12);
  }

//+------------------------------------------------------------------+
//| Clamp the ribbon's position so the body stays inside the chart   |
//+------------------------------------------------------------------+
void CRibbon::ClampRibbonToChart()
  {
   //--- Query the live chart dimensions and apply a 10-px inset on all 4 sides
   int chartW = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
   int chartH = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
   const int INSET = 10;
   if(m_ribbonX < INSET)                              m_ribbonX = INSET;
   if(m_ribbonY < INSET)                              m_ribbonY = INSET;
   if(m_ribbonX + m_ribbonWidth  > chartW - INSET)    m_ribbonX = chartW - m_ribbonWidth  - INSET;
   if(m_ribbonY + m_ribbonHeight > chartH - INSET)    m_ribbonY = chartH - m_ribbonHeight - INSET;
   //--- Final safety floor at (0, 0) - guards against tiny charts where the inset math overshoots
   if(m_ribbonX < 0) m_ribbonX = 0;
   if(m_ribbonY < 0) m_ribbonY = 0;
  }

//+------------------------------------------------------------------+
//| Push the ribbon's (X, Y) to the chart object (offset by shadow)  |
//+------------------------------------------------------------------+
void CRibbon::ApplyRibbonPosition()
  {
   //--- Chart object's XY is the top-left of the canvas - subtract the shadow halo from the logical position
   ObjectSetInteger(0, m_nameRibbon, OBJPROP_XDISTANCE, m_ribbonX - m_ribbonShadowPad);
   ObjectSetInteger(0, m_nameRibbon, OBJPROP_YDISTANCE, m_ribbonY - m_ribbonShadowPad);
  }

//+------------------------------------------------------------------+
//| Bind the ribbon to an object, rebuild its layout, and show it    |
//+------------------------------------------------------------------+
void CRibbon::ShowRibbonFor(int objId)
  {
   //--- Cache the new owner ID for downstream use
   m_ribbonOwnerObjectId = objId;

   //--- Rebuild the filtered property list + recompute the ribbon's content width
   RefreshRibbonProperties();
   m_ribbonWidth = CalcRibbonContentWidth();

   //--- Resize the display canvas if the new content width differs from the previous canvas size
   const int newCanvasW = m_ribbonWidth + 2 * m_ribbonShadowPad;
   const int newCanvasH = m_ribbonHeight + 2 * m_ribbonShadowPad;
   if(m_canvasRibbon.Width() != newCanvasW || m_canvasRibbon.Height() != newCanvasH)
      m_canvasRibbon.Resize(newCanvasW, newCanvasH);
   //--- Same for the HR canvas (scaled by supersample factor)
   const int newHRW = m_ribbonWidth  * m_supersampleFactor;
   const int newHRH = m_ribbonHeight * m_supersampleFactor;
   if(m_canvasRibbonHighRes.Width() != newHRW || m_canvasRibbonHighRes.Height() != newHRH)
      m_canvasRibbonHighRes.Resize(newHRW, newHRH);

   //--- First-time show: place the ribbon at its default position and cache it
   if(!m_lastRibbonValid)
     {
      CalcRibbonDefaultPosition(m_ribbonX, m_ribbonY);
      m_lastRibbonX     = m_ribbonX;
      m_lastRibbonY     = m_ribbonY;
      m_lastRibbonValid = true;
     }
   else
     {
      //--- Subsequent shows: restore the cached position (the user may have dragged it)
      m_ribbonX = m_lastRibbonX;
      m_ribbonY = m_lastRibbonY;
     }
   //--- Clamp inside the chart + apply to the chart object
   ClampRibbonToChart();
   ApplyRibbonPosition();

   //--- Flip visibility flags + clear stale hover
   m_isRibbonVisible      = true;
   m_hoveredRibbonIconIdx = -1;
   //--- Re-enable the chart object on all periods
   ObjectSetInteger(0, m_nameRibbon, OBJPROP_TIMEFRAMES, OBJ_ALL_PERIODS);
   //--- Render + flush
   RedrawRibbon();
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| Hide the ribbon + cascade-hide any open popover                  |
//+------------------------------------------------------------------+
void CRibbon::HideRibbon()
  {
   //--- Idempotent - no-op when already hidden
   if(!m_isRibbonVisible) return;
   //--- Close any open popover first (popovers must never outlive their ribbon)
   HidePopover();
   //--- Clear visibility + binding + transient state
   m_isRibbonVisible     = false;
   m_ribbonOwnerObjectId = -1;
   m_isRibbonDragging    = false;
   m_hoveredRibbonIconIdx = -1;
   //--- Detach the chart object from all periods so it stops rendering
   ObjectSetInteger(0, m_nameRibbon, OBJPROP_TIMEFRAMES, OBJ_NO_PERIODS);
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| Repaint the ribbon body (shadow + background + grip + icons)     |
//+------------------------------------------------------------------+
void CRibbon::RedrawRibbon()
  {
   //--- No-op when hidden
   if(!m_isRibbonVisible) return;

   //--- Body rect inside the canvas (offset by the shadow halo on all sides)
   const int boxL = m_ribbonShadowPad;
   const int boxT = m_ribbonShadowPad;
   const int boxR = m_ribbonShadowPad + m_ribbonWidth;
   const int boxB = m_ribbonShadowPad + m_ribbonHeight;

   //--- Clear the canvas to fully transparent
   m_canvasRibbon.Erase(0x00000000);

   //--- Soft drop shadow underneath the rounded body
   DrawNoteDropShadow(m_canvasRibbon, boxL, boxT, boxR, boxB, m_ribbonCornerRadius);

   //--- Rounded background body (theme-aware fill at the configured opacity)
   const uchar bgAlpha  = (uchar)(255 * BackgroundOpacity);
   const uint  bodyARGB = ColorToARGB(m_themeColors.flyoutBackground, bgAlpha);
   FillNoteRoundRect(m_canvasRibbon, boxL, boxT, boxR, boxB, m_ribbonCornerRadius, bodyARGB);

   //--- Drag grip on the left edge + icon row to the right
   DrawGripDots(m_canvasRibbon, 1);
   DrawRibbonIcons();

   //--- Flush canvas pixels to the chart object
   m_canvasRibbon.Update();
  }

//+------------------------------------------------------------------+
//| Draw the 2x4 dot pattern that signals the drag-grip area         |
//+------------------------------------------------------------------+
void CRibbon::DrawGripDots(CCanvas &canvas, int hrScale)
  {
   //--- 2 columns x 4 rows of 2-px dots with 3-px gaps between them
   const int colsCount = 2;
   const int rowsCount = 4;
   const int dotSize   = 2;
   const int dotGapX   = 3;
   const int dotGapY   = 3;
   //--- Total grid extent
   const int totalGridW = colsCount * dotSize + (colsCount - 1) * dotGapX;
   const int totalGridH = rowsCount * dotSize + (rowsCount - 1) * dotGapY;
   //--- Position the grid: 8 px from the left edge of the ribbon body, vertically centered
   const int gripLeftMargin = 8;
   const int gridLeft = m_ribbonShadowPad + gripLeftMargin;
   const int gridTop  = m_ribbonShadowPad + (m_ribbonHeight - totalGridH) / 2;
   //--- Dot color = theme text at 78 percent opacity (subdued)
   const uint dotARGB = ColorToARGB(m_themeColors.flyoutTextColor, 200);

   //--- Paint each dot as a small filled rectangle
   for(int row = 0; row < rowsCount; row++)
     {
      for(int col = 0; col < colsCount; col++)
        {
         const int x = gridLeft + col * (dotSize + dotGapX);
         const int y = gridTop  + row * (dotSize + dotGapY);
         canvas.FillRectangle(x, y, x + dotSize - 1, y + dotSize - 1, dotARGB);
        }
     }
  }

//+------------------------------------------------------------------+
//| Hit-test screen coords against the ribbon body (emits local x/y) |
//+------------------------------------------------------------------+
bool CRibbon::HitTestOverRibbon(int mouseX, int mouseY, int &lx, int &ly)
  {
   //--- Bail when hidden
   if(!m_isRibbonVisible) return false;
   //--- Translate to ribbon-local coordinates
   lx = mouseX - m_ribbonX;
   ly = mouseY - m_ribbonY;
   //--- Containment test within the body rect
   return (lx >= 0 && lx < m_ribbonWidth && ly >= 0 && ly < m_ribbonHeight);
  }

//+------------------------------------------------------------------+
//| Hit-test ribbon-local coords against the drag-grip strip         |
//+------------------------------------------------------------------+
bool CRibbon::HitTestOverRibbonGrip(int lx, int ly)
  {
   //--- Grip occupies the leftmost m_ribbonGripWidth pixels across the full ribbon height
   return (lx >= 0 && lx < m_ribbonGripWidth &&
           ly >= 0 && ly < m_ribbonHeight);
  }

//+------------------------------------------------------------------+
//| Route a mouse-down on the ribbon (grip drag vs property icon)    |
//+------------------------------------------------------------------+
bool CRibbon::RibbonMouseDown(int mouseX, int mouseY)
  {
   //--- Bail when hidden + ignore clicks outside the body
   if(!m_isRibbonVisible) return false;
   int lx, ly;
   if(!HitTestOverRibbon(mouseX, mouseY, lx, ly)) return false;

   //--- Grip click: begin a drag and close any open popover (drag would otherwise leave it stranded)
   if(HitTestOverRibbonGrip(lx, ly))
     {
      if(m_isPopoverVisible) HidePopover();
      m_isRibbonDragging   = true;
      m_ribbonDragOffsetX  = lx;
      m_ribbonDragOffsetY  = ly;
      //--- Disable chart wheel-scroll during drag so the chart doesn't slide under the user
      ChartSetInteger(0, CHART_MOUSE_SCROLL, false);
      return true;
     }

   //--- Property-icon click: identify which icon was hit
   const int iconIdx = HitTestRibbonIcon(lx, ly);
   if(iconIdx >= 0)
     {
      const string clickedPropId = m_ribbonProperties[iconIdx].id;
      const PROP_TYPE clickedType = m_ribbonProperties[iconIdx].type;

      //--- Action icons (Settings / Remove) bypass the popover entirely
      if(clickedType == PROP_ACTION)
        {
         //--- Close any open popover before triggering the action
         if(m_isPopoverVisible) HidePopover();

         if(clickedPropId == "remove")
           {
            //--- Remove action: capture the owner ID first, deselect and remove the object, then hide the ribbon
            const int targetObjId = m_ribbonOwnerObjectId;
            if(targetObjId > 0)
              {
               DeselectAll();
               RemoveDrawnObject(targetObjId);
               HideRibbon();
               RedrawAllObjects();
               ChartRedraw();
              }
           }
         else if(clickedPropId == "settings")
           {
            //--- Settings action: route through the virtual hook so subclasses can open their settings window
            OpenSettingsWindowForObject(m_ribbonOwnerObjectId);
           }
         return true;
        }

      //--- Property icon - toggle the popover (open if not already open for this property, close if already open for it)
      const bool wasOpenForThis = (m_isPopoverVisible &&
                                    m_activePopoverPropId == clickedPropId);
      if(wasOpenForThis)
        {
         HidePopover();
        }
      else
        {
         //--- Compute the popover anchor: 2 px below the ribbon body, left-aligned to the icon's hover-bg
         int iconBodyX, iconBodyY, iconSize;
         GetRibbonIconBounds(iconIdx, iconBodyX, iconBodyY, iconSize);
         //--- 3-px outward hover-padding constant used by the icon renderer
         const int hoverPad = 3;
         const int anchorX = m_ribbonX + iconBodyX - hoverPad;
         const int anchorY = m_ribbonY + m_ribbonHeight + 2;
         ShowPopoverForProperty(clickedPropId, anchorX, anchorY);
        }
      return true;
     }

   //--- Body click outside any icon - consume it (so it doesn't fall through to chart) but do nothing
   return true;
  }

//+------------------------------------------------------------------+
//| Route mouse-move while dragging (grip) or for hover state        |
//+------------------------------------------------------------------+
bool CRibbon::RibbonMouseMove(int mouseX, int mouseY, uint mouseButtons)
  {
   //--- Active grip drag - update the ribbon position
   if(m_isRibbonDragging)
     {
      //--- Mouse button released while dragging: defensively end the drag
      if((mouseButtons & 1) == 0)
        {
         RibbonMouseUp();
         return false;
        }

      //--- Apply the drag offset and clamp + reposition
      m_ribbonX = mouseX - m_ribbonDragOffsetX;
      m_ribbonY = mouseY - m_ribbonDragOffsetY;
      ClampRibbonToChart();
      ApplyRibbonPosition();
      //--- Cache the new position so future shows restore it
      m_lastRibbonX     = m_ribbonX;
      m_lastRibbonY     = m_ribbonY;
      m_lastRibbonValid = true;
      ChartRedraw();
      return true;
     }

   //--- Bail when hidden
   if(!m_isRibbonVisible) return false;
   //--- Hover state: identify the currently-hovered icon (-1 when nothing is hovered)
   int lx, ly;
   const bool overRibbon = HitTestOverRibbon(mouseX, mouseY, lx, ly);
   const int newHovered = overRibbon ? HitTestRibbonIcon(lx, ly) : -1;
   //--- Only repaint when the hover changes (avoids unnecessary redraws)
   if(newHovered != m_hoveredRibbonIconIdx)
     {
      m_hoveredRibbonIconIdx = newHovered;
      //--- Update the chart-object tooltip to the hovered icon's tooltip text
      string tip = "";
      if(newHovered >= 0 && newHovered < ArraySize(m_ribbonProperties))
         tip = m_ribbonProperties[newHovered].tooltip;
      ObjectSetString(0, m_nameRibbon, OBJPROP_TOOLTIP, tip);
      RedrawRibbon();
      ChartRedraw();
     }
   //--- Returning overRibbon=true tells the dispatcher to swallow the event (don't fall through to chart)
   return overRibbon;
  }

//+------------------------------------------------------------------+
//| End the grip drag + restore chart scroll                         |
//+------------------------------------------------------------------+
bool CRibbon::RibbonMouseUp()
  {
   //--- Idempotent - return false when not dragging
   if(!m_isRibbonDragging) return false;
   m_isRibbonDragging = false;
   //--- Re-enable chart wheel scrolling
   ChartSetInteger(0, CHART_MOUSE_SCROLL, true);
   return true;
  }

//+------------------------------------------------------------------+
//| Rebuild the ribbon's filtered property descriptor list           |
//+------------------------------------------------------------------+
void CRibbon::RefreshRibbonProperties()
  {
   //--- Start with an empty filtered list
   ArrayResize(m_ribbonProperties, 0);
   //--- Bail if the bound object no longer exists
   const int idx = FindObjectIndexById(m_ribbonOwnerObjectId);
   if(idx < 0) return;
   const TOOL_TYPE tt = m_drawnObjects[idx].toolType;

   //--- Get the full descriptor list for the tool type
   SToolProperty fullList[];
   BuildPropertyListForTool(tt, fullList);

   //--- Filter: keep only ribbon-eligible descriptors with one of the 4 ribbon-renderable types
   const int n = ArraySize(fullList);
   for(int i = 0; i < n; i++)
     {
      if(!fullList[i].showInRibbon) continue;
      const PROP_TYPE pt = fullList[i].type;
      if(pt != PROP_COLOR && pt != PROP_LINE_WIDTH
         && pt != PROP_LINE_STYLE && pt != PROP_ACTION)
         continue;
      //--- Append to the filtered list
      const int sz = ArraySize(m_ribbonProperties);
      ArrayResize(m_ribbonProperties, sz + 1);
      m_ribbonProperties[sz] = fullList[i];
     }
  }

//+------------------------------------------------------------------+
//| Sum the icon-row widths to derive the ribbon's content width     |
//+------------------------------------------------------------------+
int CRibbon::CalcRibbonContentWidth()
  {
   //--- Empty descriptor list - return a small placeholder (grip + 30 px)
   const int n = ArraySize(m_ribbonProperties);
   if(n == 0)
      return m_ribbonGripWidth + 30;
   //--- Sum the per-type icon widths
   int iconsW = 0;
   for(int i = 0; i < n; i++)
      iconsW += GetRibbonIconWidthForType(m_ribbonProperties[i].type);
   //--- Total = grip + left pad + icons + (n-1) inter-icon gaps + right pad
   return m_ribbonGripWidth
        + m_ribbonIconRowPadX
        + iconsW
        + (n - 1) * m_ribbonIconGap
        + m_ribbonIconRowPadX;
  }

//+------------------------------------------------------------------+
//| Per-property-type icon width (color = square, width/style wider) |
//+------------------------------------------------------------------+
int CRibbon::GetRibbonIconWidthForType(PROP_TYPE t)
  {
   //--- Width and style icons need extra horizontal room for the label text alongside the stroke preview
   switch(t)
     {
      case PROP_LINE_WIDTH:  return 56;
      case PROP_LINE_STYLE:  return 32;
      case PROP_ACTION:      return m_ribbonIconSize;
      default:               return m_ribbonIconSize;
     }
  }

//+------------------------------------------------------------------+
//| Compute the bounds of icon `idx` in the ribbon-local coord space |
//+------------------------------------------------------------------+
void CRibbon::GetRibbonIconBounds(int idx, int &outX, int &outY, int &outSize)
  {
   //--- Walk left-to-right summing prior icon widths + gaps to find this icon's left edge
   int xCursor = m_ribbonGripWidth + m_ribbonIconRowPadX;
   for(int i = 0; i < idx; i++)
     {
      const int w = GetRibbonIconWidthForType(m_ribbonProperties[i].type);
      xCursor += w + m_ribbonIconGap;
     }
   //--- Emit out-params: x = computed cursor, y = vertically centered, size = this icon's width
   outX = xCursor;
   outY = (m_ribbonHeight - m_ribbonIconSize) / 2;
   outSize = GetRibbonIconWidthForType(m_ribbonProperties[idx].type);
  }

//+------------------------------------------------------------------+
//| Paint every property icon onto the ribbon canvas                 |
//+------------------------------------------------------------------+
void CRibbon::DrawRibbonIcons()
  {
   //--- Bail on empty descriptor list
   const int n = ArraySize(m_ribbonProperties);
   if(n == 0) return;

   //--- Bail if the bound object no longer exists
   const int objIdx = FindObjectIndexById(m_ribbonOwnerObjectId);
   if(objIdx < 0) return;
   const TOOL_TYPE tt = m_drawnObjects[objIdx].toolType;

   //--- "Many lines" tools render their color strip as the per-level color sequence (not a single color)
   const bool toolHasManyLines = (
       tt == TOOL_FIBO_RETRACEMENT || tt == TOOL_FIBO_EXPANSION
    || tt == TOOL_FIBO_CHANNEL     || tt == TOOL_FIBO_TIMEZONES
    || tt == TOOL_FIBO_FAN         || tt == TOOL_FIBO_ARCS
    || tt == TOOL_GANN_FAN         || tt == TOOL_GANN_BOX
    || tt == TOOL_PITCHFORK        || tt == TOOL_SCHIFF_PITCHFORK
    || tt == TOOL_MOD_SCHIFF);
   //--- Regression channel has 2 separately-colored fills (upper + lower)
   const bool toolHasManyFills = (tt == TOOL_REGRESSION_CHANNEL);

   //--- Iterate over each filtered descriptor and paint its icon
   for(int i = 0; i < n; i++)
     {
      //--- Compute canvas-space top-left for this icon (offset by shadow halo)
      int bx, by, sz;
      GetRibbonIconBounds(i, bx, by, sz);
      const int canvasX = bx + m_ribbonShadowPad;
      const int canvasY = by + m_ribbonShadowPad;
      const bool isHovered = (m_hoveredRibbonIconIdx == i);

      //--- PROP_COLOR icons render the color swatch + strip + glyph
      if(m_ribbonProperties[i].type == PROP_COLOR)
        {
         //--- Read the active color from the engine
         color activeColor = clrNONE;
         GetObjectProperty(m_ribbonOwnerObjectId,
                            m_ribbonProperties[i].id, activeColor);
         //--- Read the sibling opacity for this color (lineColor -> lineOpacity, etc.)
         int activeOpacity = 100;
         string opacityPropId = ColorToOpacityProp(m_ribbonProperties[i].id);
         GetObjectProperty(m_ribbonOwnerObjectId, opacityPropId, activeOpacity);

         //--- Glyph kind: 0 = line diagonal, 1 = uppercase T, 2 = paint bucket
         int glyphKind = 0;
         if(m_ribbonProperties[i].id == "textColor")      glyphKind = 1;
         else if(m_ribbonProperties[i].id == "fillColor") glyphKind = 2;

         //--- Build the color-strip data (single-color for most tools, per-level for multi-line tools)
         color stripColors[];
         int   stripOpacities[];
         const string thisPropId = m_ribbonProperties[i].id;
         //--- lineColor on a multi-line tool: cascade per-level colors into the strip data
         if(thisPropId == "lineColor" && toolHasManyLines)
           {
            //--- Fibo retracement: copy fiboLevelColor + fiboLevelOpacity arrays
            if(tt == TOOL_FIBO_RETRACEMENT)
               { const int nl = ArraySize(m_drawnObjects[objIdx].fiboLevelColor);
                 ArrayResize(stripColors, nl); ArrayResize(stripOpacities, nl);
                 for(int k=0;k<nl;k++) {
                    stripColors[k]    = m_drawnObjects[objIdx].fiboLevelColor[k];
                    stripOpacities[k] = m_drawnObjects[objIdx].fiboLevelOpacity[k];
                 } }
            //--- Fibo expansion: copy fibexLevelColor + fibexLevelOpacity arrays
            else if(tt == TOOL_FIBO_EXPANSION)
               { const int nl = ArraySize(m_drawnObjects[objIdx].fibexLevelColor);
                 ArrayResize(stripColors, nl); ArrayResize(stripOpacities, nl);
                 for(int k=0;k<nl;k++) {
                    stripColors[k]    = m_drawnObjects[objIdx].fibexLevelColor[k];
                    stripOpacities[k] = m_drawnObjects[objIdx].fibexLevelOpacity[k];
                 } }
            //--- Fibo channel: copy fibchLevelColor + fibchLevelOpacity arrays
            else if(tt == TOOL_FIBO_CHANNEL)
               { const int nl = ArraySize(m_drawnObjects[objIdx].fibchLevelColor);
                 ArrayResize(stripColors, nl); ArrayResize(stripOpacities, nl);
                 for(int k=0;k<nl;k++) {
                    stripColors[k]    = m_drawnObjects[objIdx].fibchLevelColor[k];
                    stripOpacities[k] = m_drawnObjects[objIdx].fibchLevelOpacity[k];
                 } }
            //--- Fibo time-zones: copy fibtzLevelColor + fibtzLevelOpacity arrays
            else if(tt == TOOL_FIBO_TIMEZONES)
               { const int nl = ArraySize(m_drawnObjects[objIdx].fibtzLevelColor);
                 ArrayResize(stripColors, nl); ArrayResize(stripOpacities, nl);
                 for(int k=0;k<nl;k++) {
                    stripColors[k]    = m_drawnObjects[objIdx].fibtzLevelColor[k];
                    stripOpacities[k] = m_drawnObjects[objIdx].fibtzLevelOpacity[k];
                 } }
            //--- Fibo fan: copy fibfanLevelColor + fibfanLevelOpacity arrays
            else if(tt == TOOL_FIBO_FAN)
               { const int nl = ArraySize(m_drawnObjects[objIdx].fibfanLevelColor);
                 ArrayResize(stripColors, nl); ArrayResize(stripOpacities, nl);
                 for(int k=0;k<nl;k++) {
                    stripColors[k]    = m_drawnObjects[objIdx].fibfanLevelColor[k];
                    stripOpacities[k] = m_drawnObjects[objIdx].fibfanLevelOpacity[k];
                 } }
            //--- Fibo arcs: copy fibarcLevelColor + fibarcLevelOpacity arrays
            else if(tt == TOOL_FIBO_ARCS)
               { const int nl = ArraySize(m_drawnObjects[objIdx].fibarcLevelColor);
                 ArrayResize(stripColors, nl); ArrayResize(stripOpacities, nl);
                 for(int k=0;k<nl;k++) {
                    stripColors[k]    = m_drawnObjects[objIdx].fibarcLevelColor[k];
                    stripOpacities[k] = m_drawnObjects[objIdx].fibarcLevelOpacity[k];
                 } }
            //--- Gann fan: copy gannfanLevelColor + gannfanLevelOpacity arrays
            else if(tt == TOOL_GANN_FAN)
               { const int nl = ArraySize(m_drawnObjects[objIdx].gannfanLevelColor);
                 ArrayResize(stripColors, nl); ArrayResize(stripOpacities, nl);
                 for(int k=0;k<nl;k++) {
                    stripColors[k]    = m_drawnObjects[objIdx].gannfanLevelColor[k];
                    stripOpacities[k] = m_drawnObjects[objIdx].gannfanLevelOpacity[k];
                 } }
            //--- Gann box: copy gannboxLevelColor + gannboxLevelOpacity arrays
            else if(tt == TOOL_GANN_BOX)
               { const int nl = ArraySize(m_drawnObjects[objIdx].gannboxLevelColor);
                 ArrayResize(stripColors, nl); ArrayResize(stripOpacities, nl);
                 for(int k=0;k<nl;k++) {
                    stripColors[k]    = m_drawnObjects[objIdx].gannboxLevelColor[k];
                    stripOpacities[k] = m_drawnObjects[objIdx].gannboxLevelOpacity[k];
                 } }
            //--- Pitchforks: use the 3 part-group colors (median + outer + inner) with line opacity for each
            else if(tt == TOOL_PITCHFORK
                  || tt == TOOL_SCHIFF_PITCHFORK
                  || tt == TOOL_MOD_SCHIFF)
               { ArrayResize(stripColors, 3); ArrayResize(stripOpacities, 3);
                 stripColors[0]    = m_drawnObjects[objIdx].medianColor;
                 stripColors[1]    = m_drawnObjects[objIdx].outerColor;
                 stripColors[2]    = m_drawnObjects[objIdx].innerColor;
                 stripOpacities[0] = m_drawnObjects[objIdx].lineOpacity;
                 stripOpacities[1] = m_drawnObjects[objIdx].lineOpacity;
                 stripOpacities[2] = m_drawnObjects[objIdx].lineOpacity; }
           }
         //--- fillColor on a multi-fill tool (regression channel): show upper + lower fills as a 2-band strip
         else if(thisPropId == "fillColor" && toolHasManyFills)
           {
            ArrayResize(stripColors, 2); ArrayResize(stripOpacities, 2);
            stripColors[0]    = m_drawnObjects[objIdx].fillColor;
            stripOpacities[0] = m_drawnObjects[objIdx].fillOpacity;
            stripColors[1]    = m_drawnObjects[objIdx].fillColor2;
            stripOpacities[1] = m_drawnObjects[objIdx].fillOpacity2;
           }
         else
           {
            //--- Single-color path: 1-entry strip with the active color + opacity
            ArrayResize(stripColors, 1);
            ArrayResize(stripOpacities, 1);
            stripColors[0]    = activeColor;
            stripOpacities[0] = activeOpacity;
           }

         //--- Active flag: true when this icon's popover is currently open
         const bool isActive = (m_isPopoverVisible &&
                                  m_activePopoverPropId == m_ribbonProperties[i].id);
         //--- Delegate to the widget renderer
         RenderRibbonColorIcon(m_canvasRibbon, canvasX, canvasY, sz,
                                 activeColor, activeOpacity, glyphKind,
                                 isHovered, isActive, m_themeColors,
                                 stripColors, stripOpacities);
        }
      //--- PROP_LINE_WIDTH icon: stroke preview + "Xpx" label
      else if(m_ribbonProperties[i].type == PROP_LINE_WIDTH)
        {
         int activeWidth = 2;
         GetObjectProperty(m_ribbonOwnerObjectId, "lineWidth", activeWidth);
         const bool isActive = (m_isPopoverVisible &&
                                  m_activePopoverPropId == m_ribbonProperties[i].id);
         RenderRibbonLineWidthIcon(m_canvasRibbon, canvasX, canvasY,
                                     sz, m_ribbonIconSize,
                                     activeWidth,
                                     isHovered, isActive, m_themeColors);
        }
      //--- PROP_LINE_STYLE icon: stroke preview at the active style + width
      else if(m_ribbonProperties[i].type == PROP_LINE_STYLE)
        {
         int activeStyle = 0;
         int activeWidth = 2;
         GetObjectProperty(m_ribbonOwnerObjectId, "lineStyle", activeStyle);
         GetObjectProperty(m_ribbonOwnerObjectId, "lineWidth", activeWidth);
         const bool isActive = (m_isPopoverVisible &&
                                  m_activePopoverPropId == m_ribbonProperties[i].id);
         RenderRibbonLineStyleIcon(m_canvasRibbon, canvasX, canvasY,
                                     sz, m_ribbonIconSize,
                                     activeStyle, activeWidth,
                                     isHovered, isActive, m_themeColors);
        }
      //--- PROP_ACTION icons: settings (gear) or remove (trash bin)
      else if(m_ribbonProperties[i].type == PROP_ACTION)
        {
         if(m_ribbonProperties[i].id == "settings")
           {
            RenderRibbonSettingsIcon(m_canvasRibbon, canvasX, canvasY, sz,
                                       isHovered, false, m_themeColors);
           }
         else if(m_ribbonProperties[i].id == "remove")
           {
            RenderRibbonRemoveIcon(m_canvasRibbon, canvasX, canvasY, sz,
                                     isHovered, false, m_themeColors);
           }
        }
     }
  }

//+------------------------------------------------------------------+
//| Hit-test ribbon-local coords against the icon row                |
//+------------------------------------------------------------------+
int CRibbon::HitTestRibbonIcon(int lx, int ly)
  {
   //--- Walk every icon and check rectangular containment; return the first match
   const int n = ArraySize(m_ribbonProperties);
   for(int i = 0; i < n; i++)
     {
      int bx, by, sz;
      GetRibbonIconBounds(i, bx, by, sz);
      if(lx >= bx && lx < bx + sz && ly >= by && ly < by + m_ribbonIconSize)
         return i;
     }
   return -1;
  }

//+------------------------------------------------------------------+
//| Show a popover bound to a specific property (size + position it) |
//+------------------------------------------------------------------+
void CRibbon::ShowPopoverForProperty(string propId, int anchorX, int anchorY,
                                       int flipBaseTop)
  {
   //--- Resolve which filtered descriptor matches the requested propId; bail if not found
   const int n = ArraySize(m_ribbonProperties);
   int found = -1;
   for(int i = 0; i < n; i++)
     {
      if(m_ribbonProperties[i].id == propId) { found = i; break; }
     }
   if(found < 0) return;

   //--- Size the popover body based on the descriptor's type
   if(m_ribbonProperties[found].type == PROP_COLOR)
     {
      //--- Color picker has constant geometry
      m_popoverWidth  = GetColorPickerBodyWidth();
      m_popoverHeight = GetColorPickerBodyHeight();
     }
   else if(m_ribbonProperties[found].type == PROP_LINE_WIDTH)
     {
      m_popoverWidth  = GetLineWidthPopoverBodyWidth();
      m_popoverHeight = GetLineWidthPopoverBodyHeight();
     }
   else if(m_ribbonProperties[found].type == PROP_LINE_STYLE)
     {
      m_popoverWidth  = GetLineStylePopoverBodyWidth();
      m_popoverHeight = GetLineStylePopoverBodyHeight();
     }
   else if(m_ribbonProperties[found].type == PROP_FONT_SIZE)
     {
      //--- Font size popover sized to the canonical option list
      string lbls[]; int vals[];
      BuildFontSizeOptions(lbls, vals);
      m_popoverWidth  = GetIntegerListPopoverBodyWidth(lbls);
      m_popoverHeight = GetIntegerListPopoverBodyHeight(ArraySize(lbls));
     }
   else if(m_ribbonProperties[found].type == PROP_DROPDOWN_INT)
     {
      //--- Integer-list popovers: vAlign or hAlign options
      string lbls[]; int vals[];
      if(propId == "vAlign")      BuildVAlignOptions(lbls, vals);
      else if(propId == "hAlign") BuildHAlignOptions(lbls, vals);
      else { return; }
      m_popoverWidth  = GetIntegerListPopoverBodyWidth(lbls);
      m_popoverHeight = GetIntegerListPopoverBodyHeight(ArraySize(lbls));
     }
   else
     {
      //--- Unsupported descriptor type for a popover - bail without showing
      return;
     }

   //--- Take a property snapshot for Cancel-revert (unless a parent owns the snapshot lifecycle)
   if(!m_popoverSnapshotIsExternal)
      SnapshotProperties(m_ribbonOwnerObjectId);

   //--- Seed the opacity slider from the engine value when opening a color picker
   if(m_ribbonProperties[found].type == PROP_COLOR)
     {
      string opacityPropId = ColorToOpacityProp(propId);
      int seedOpacity = 100;
      GetObjectProperty(m_ribbonOwnerObjectId, opacityPropId, seedOpacity);
      m_opacityValuePct = seedOpacity;
     }

   //--- Flip visibility flags + bind the popover to this property
   m_activePopoverPropId = propId;
   m_isPopoverVisible    = true;

   //--- Compute the popover screen position (may flip above the anchor if it would clip the bottom edge)
   CalcPopoverPositionForAnchor(anchorX, anchorY,
                                  m_popoverWidth, m_popoverHeight,
                                  m_popoverX, m_popoverY,
                                  flipBaseTop);
   ClampPopoverToChart();
   ApplyPopoverPosition();

   //--- Activate the chart object + render
   ObjectSetInteger(0, m_namePopover, OBJPROP_TIMEFRAMES, OBJ_ALL_PERIODS);
   RedrawPopover();
   //--- Re-render the ribbon too so the source icon shows its active state
   RedrawRibbon();
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| Hide the popover + drop the snapshot if we own it                |
//+------------------------------------------------------------------+
void CRibbon::HidePopover()
  {
   //--- Idempotent - no-op when already hidden
   if(!m_isPopoverVisible) return;
   //--- Clear visibility + binding
   m_isPopoverVisible    = false;
   m_activePopoverPropId = "";
   m_isOpacityDragging   = false;
   //--- If a text edit was in progress, abandon it and release the keyboard
   if(m_isEditingBoxOpacity)
     {
      m_isEditingBoxOpacity = false;
      m_boxEditBuffer       = "";
      m_boxCaretPos         = 0;
      m_boxCaretOn          = false;
      EndKeyboardOverride();
     }
   //--- Drop the property snapshot (commits the live edits) unless the parent owns the lifecycle
   if(!m_popoverSnapshotIsExternal)
      DiscardSnapshot();
   //--- Detach the popover chart object from all periods so it stops rendering
   ObjectSetInteger(0, m_namePopover, OBJPROP_TIMEFRAMES, OBJ_NO_PERIODS);
   //--- Re-render the ribbon so the source icon reverts to its non-active state
   if(m_isRibbonVisible) RedrawRibbon();
   //--- Notify subclasses that the popover just closed
   OnPopoverClosed();
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| Repaint the popover (shadow halo + rounded body + active content)|
//+------------------------------------------------------------------+
void CRibbon::RedrawPopover()
  {
   //--- No-op when hidden
   if(!m_isPopoverVisible) return;

   //--- Resize the canvas if the body size changed since the previous show
   const int canvasW = m_popoverWidth  + 2 * m_popoverShadowPad;
   const int canvasH = m_popoverHeight + 2 * m_popoverShadowPad;
   if(m_canvasPopover.Width() != canvasW || m_canvasPopover.Height() != canvasH)
      m_canvasPopover.Resize(canvasW, canvasH);

   //--- Body rect inside the canvas (offset by the shadow halo)
   const int boxL = m_popoverShadowPad;
   const int boxT = m_popoverShadowPad;
   const int boxR = m_popoverShadowPad + m_popoverWidth;
   const int boxB = m_popoverShadowPad + m_popoverHeight;

   //--- Clear the canvas to fully transparent
   m_canvasPopover.Erase(0x00000000);

   //--- Drop shadow + rounded body (theme-aware)
   DrawNoteDropShadow(m_canvasPopover, boxL, boxT, boxR, boxB, m_popoverCornerRadius);

   const uchar bgAlpha  = (uchar)(255 * BackgroundOpacity);
   const uint  bodyArgb = ColorToARGB(m_themeColors.flyoutBackground, bgAlpha);
   FillNoteRoundRect(m_canvasPopover, boxL, boxT, boxR, boxB,
                       m_popoverCornerRadius, bodyArgb);

   //--- Render the type-specific contents inside the popover body
   const int n = ArraySize(m_ribbonProperties);
   for(int i = 0; i < n; i++)
     {
      //--- Skip descriptors that aren't the active popover's binding
      if(m_ribbonProperties[i].id != m_activePopoverPropId) continue;
      //--- PROP_COLOR: full color picker (swatch grid + opacity slider + editable box)
      if(m_ribbonProperties[i].type == PROP_COLOR)
        {
         color activeColor = clrNONE;
         GetObjectProperty(m_ribbonOwnerObjectId, m_activePopoverPropId, activeColor);
         RenderColorPickerContents(m_canvasPopover, boxL, boxT,
                                     activeColor,
                                     m_hoveredPopoverSwatchIdx,
                                     m_opacityValuePct,
                                     m_isDarkTheme,
                                     m_isEditingBoxOpacity,
                                     m_boxEditBuffer,
                                     m_boxCaretPos,
                                     m_boxCaretOn,
                                     m_themeColors);
        }
      //--- PROP_LINE_WIDTH: 4-row width picker with stroke previews
      else if(m_ribbonProperties[i].type == PROP_LINE_WIDTH)
        {
         int activeWidth = 2;
         int activeStyle = 0;
         color strokeColor = clrBlack;
         GetObjectProperty(m_ribbonOwnerObjectId, m_activePopoverPropId, activeWidth);
         GetObjectProperty(m_ribbonOwnerObjectId, "lineStyle", activeStyle);
         GetObjectProperty(m_ribbonOwnerObjectId, "lineColor", strokeColor);
         RenderLineWidthPopoverContents(m_canvasPopover, boxL, boxT,
                                          activeWidth, activeStyle,
                                          m_hoveredPopoverSwatchIdx,
                                          strokeColor, m_themeColors);
        }
      //--- PROP_LINE_STYLE: 4-row style picker (solid/dash/dot/dash-dot)
      else if(m_ribbonProperties[i].type == PROP_LINE_STYLE)
        {
         int activeStyle = 0;
         int activeWidth = 2;
         color strokeColor = clrBlack;
         GetObjectProperty(m_ribbonOwnerObjectId, m_activePopoverPropId, activeStyle);
         GetObjectProperty(m_ribbonOwnerObjectId, "lineWidth", activeWidth);
         GetObjectProperty(m_ribbonOwnerObjectId, "lineColor", strokeColor);
         RenderLineStylePopoverContents(m_canvasPopover, boxL, boxT,
                                          activeStyle, activeWidth,
                                          m_hoveredPopoverSwatchIdx,
                                          strokeColor, m_themeColors);
        }
      //--- PROP_FONT_SIZE: integer-list of canonical font sizes
      else if(m_ribbonProperties[i].type == PROP_FONT_SIZE)
        {
         string lbls[]; int vals[];
         BuildFontSizeOptions(lbls, vals);
         int activeSize = 11;
         GetObjectProperty(m_ribbonOwnerObjectId, "fontSize", activeSize);
         RenderIntegerListPopoverContents(m_canvasPopover, boxL, boxT,
                                            lbls, vals, activeSize,
                                            m_hoveredPopoverSwatchIdx,
                                            m_themeColors);
        }
      //--- PROP_DROPDOWN_INT: vAlign or hAlign options (3 entries each)
      else if(m_ribbonProperties[i].type == PROP_DROPDOWN_INT)
        {
         string lbls[]; int vals[];
         if(m_ribbonProperties[i].id == "vAlign")
            BuildVAlignOptions(lbls, vals);
         else if(m_ribbonProperties[i].id == "hAlign")
            BuildHAlignOptions(lbls, vals);
         int activeVal = 0;
         GetObjectProperty(m_ribbonOwnerObjectId, m_ribbonProperties[i].id, activeVal);
         RenderIntegerListPopoverContents(m_canvasPopover, boxL, boxT,
                                            lbls, vals, activeVal,
                                            m_hoveredPopoverSwatchIdx,
                                            m_themeColors);
        }
      //--- Stop after the first matching descriptor (only one popover open at a time)
      break;
     }

   //--- Flush canvas pixels to the chart object
   m_canvasPopover.Update();
  }

//+------------------------------------------------------------------+
//| Push the popover's (X, Y) to the chart object (offset by shadow) |
//+------------------------------------------------------------------+
void CRibbon::ApplyPopoverPosition()
  {
   ObjectSetInteger(0, m_namePopover, OBJPROP_XDISTANCE,
                     m_popoverX - m_popoverShadowPad);
   ObjectSetInteger(0, m_namePopover, OBJPROP_YDISTANCE,
                     m_popoverY - m_popoverShadowPad);
  }

//+------------------------------------------------------------------+
//| Clamp the popover position so the body stays inside the chart    |
//+------------------------------------------------------------------+
void CRibbon::ClampPopoverToChart()
  {
   //--- Query the live chart dimensions and apply a 10-px inset on all 4 sides
   const int chartW = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
   const int chartH = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
   const int INSET = 10;
   if(m_popoverX < INSET)                              m_popoverX = INSET;
   if(m_popoverY < INSET)                              m_popoverY = INSET;
   if(m_popoverX + m_popoverWidth  > chartW - INSET)   m_popoverX = chartW - m_popoverWidth  - INSET;
   if(m_popoverY + m_popoverHeight > chartH - INSET)   m_popoverY = chartH - m_popoverHeight - INSET;
   //--- Safety floor at (0, 0) - guards against tiny charts where the inset math overshoots
   if(m_popoverX < 0) m_popoverX = 0;
   if(m_popoverY < 0) m_popoverY = 0;
  }

//+------------------------------------------------------------------+
//| Compute popover position from anchor (flip-above if needed)      |
//+------------------------------------------------------------------+
void CRibbon::CalcPopoverPositionForAnchor(int anchorX, int anchorY,
                                             int popoverW, int popoverH,
                                             int &outX, int &outY,
                                             int flipBaseTop)
  {
   //--- Start with the anchor as the popover's top-left
   const int chartH = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
   outX = anchorX;
   outY = anchorY;
   //--- If the popover would extend past the bottom of the chart, flip it above the anchor
   if(outY + popoverH > chartH - 10)
     {
      //--- flipBaseTop overrides the default flip reference (ribbon top); used when the popover is anchored from a non-ribbon owner
      const int flipRef = (flipBaseTop >= 0) ? flipBaseTop : m_ribbonY;
      //--- Place the popover's bottom 4 px above the flip reference
      outY = flipRef - popoverH - 4;
     }
  }

//+------------------------------------------------------------------+
//| Hit-test screen coords against the popover body                  |
//+------------------------------------------------------------------+
bool CRibbon::HitTestOverPopover(int mouseX, int mouseY, int &lx, int &ly)
  {
   //--- Bail when hidden
   if(!m_isPopoverVisible) return false;
   //--- Translate to popover-local coordinates
   lx = mouseX - m_popoverX;
   ly = mouseY - m_popoverY;
   //--- Containment test within the body rect
   return (lx >= 0 && lx < m_popoverWidth &&
           ly >= 0 && ly < m_popoverHeight);
  }

//+------------------------------------------------------------------+
//| Route a mouse-down on the popover (swatch/row/opacity dispatch)  |
//+------------------------------------------------------------------+
bool CRibbon::PopoverMouseDown(int mouseX, int mouseY)
  {
   //--- Bail when hidden
   if(!m_isPopoverVisible) return false;
   int lx, ly;
   const bool overPopover = HitTestOverPopover(mouseX, mouseY, lx, ly);

   //--- Auto-commit any pending opacity-box edit if the click moves outside the box
   if(m_isEditingBoxOpacity)
     {
      bool stillInBox = false;
      if(overPopover)
         stillInBox = HitTestColorPickerOpacityBox(lx, ly, 0, 0);
      if(!stillInBox)
         CommitBoxEditToOpacity();
     }

   //--- Click outside the popover dismisses it
   if(!overPopover)
     {
      HidePopover();
      return false;
     }

   //--- Dispatch by active popover type
   const int n = ArraySize(m_ribbonProperties);
   for(int i = 0; i < n; i++)
     {
      //--- Skip descriptors that aren't the active popover's binding
      if(m_ribbonProperties[i].id != m_activePopoverPropId) continue;
      //--- PROP_COLOR popover: swatch click, opacity-box click, or opacity-strip drag
      if(m_ribbonProperties[i].type == PROP_COLOR)
        {
         //--- Swatch hit: commit the color and opacity, then close the popover
         const int swIdx = HitTestColorPickerSwatch(lx, ly, 0, 0);
         if(swIdx >= 0)
           {
            const color picked = GetColorPickerSwatch(swIdx);
            SetObjectProperty(m_ribbonOwnerObjectId,
                                m_activePopoverPropId,
                                picked, false);
            //--- Commit the sibling opacity at the same time so the color and opacity stay in sync
            string opacityPropId = ColorToOpacityProp(m_activePopoverPropId);
            SetObjectProperty(m_ribbonOwnerObjectId, opacityPropId,
                                m_opacityValuePct, false);
            //--- Swatch click closes the popover
            HidePopover();
            ChartRedraw();
            return true;
           }
         //--- Opacity-box hit: begin (or re-position) text editing
         if(HitTestColorPickerOpacityBox(lx, ly, 0, 0))
           {
            //--- First click begins the edit + seeds the buffer with the current percent
            if(!m_isEditingBoxOpacity)
              {
               m_isEditingBoxOpacity = true;
               m_boxEditBuffer       = IntegerToString(m_opacityValuePct);
               BeginKeyboardOverride();
              }
            //--- Position the caret at the clicked X column
            m_boxCaretPos    = ColorPickerOpacityBoxCaretFromX(lx, 0, m_boxEditBuffer);
            //--- Clamp the caret position into the buffer range
            if(m_boxCaretPos < 0) m_boxCaretPos = 0;
            if(m_boxCaretPos > StringLen(m_boxEditBuffer))
               m_boxCaretPos = StringLen(m_boxEditBuffer);
            //--- Show the caret immediately + restart the blink phase
            m_boxCaretOn     = true;
            m_boxBlinkTickAt = GetTickCount();
            RedrawPopover();
            ChartRedraw();
            return true;
           }
         //--- Opacity-strip hit: begin drag at the clicked percent
         const int pct = HitTestColorPickerOpacity(lx, ly, 0, 0);
         if(pct >= 0)
           {
            m_isOpacityDragging = true;
            m_opacityValuePct   = pct;
            //--- Preview the new opacity (preview=true so the engine knows this is a live drag)
            string opacityPropId = ColorToOpacityProp(m_activePopoverPropId);
            SetObjectProperty(m_ribbonOwnerObjectId, opacityPropId,
                                m_opacityValuePct, true);
            RedrawPopover();
            RedrawRibbon();
            ChartRedraw();
            return true;
           }
         //--- Click landed inside the popover but on no interactive element - swallow it
         return true;
        }
      //--- PROP_LINE_WIDTH popover: row click commits the width and closes
      else if(m_ribbonProperties[i].type == PROP_LINE_WIDTH)
        {
         const int rowIdx = HitTestLineWidthPopover(lx, ly, 0, 0);
         if(rowIdx >= 0)
           {
            //--- Width = row index + 1 (rows are 0-indexed but widths start at 1 px)
            const int newWidth = rowIdx + 1;
            SetObjectProperty(m_ribbonOwnerObjectId, m_activePopoverPropId, newWidth, false);
            HidePopover();
            ChartRedraw();
            return true;
           }
         return true;
        }
      //--- PROP_LINE_STYLE popover: row click commits the style and closes
      else if(m_ribbonProperties[i].type == PROP_LINE_STYLE)
        {
         const int rowIdx = HitTestLineStylePopover(lx, ly, 0, 0);
         if(rowIdx >= 0)
           {
            //--- Style = row index directly (0=solid, 1=dash, 2=dot, 3=dash-dot)
            SetObjectProperty(m_ribbonOwnerObjectId, m_activePopoverPropId, rowIdx, false);
            HidePopover();
            ChartRedraw();
            return true;
           }
         return true;
        }
      //--- PROP_FONT_SIZE popover: row click commits the font size from the values array
      else if(m_ribbonProperties[i].type == PROP_FONT_SIZE)
        {
         string lbls[]; int vals[];
         BuildFontSizeOptions(lbls, vals);
         const int rowIdx = HitTestIntegerListPopover(lx, ly, 0, 0,
                                                       ArraySize(lbls), lbls);
         if(rowIdx >= 0)
           {
            SetObjectProperty(m_ribbonOwnerObjectId, "fontSize",
                                vals[rowIdx], false);
            HidePopover();
            ChartRedraw();
            return true;
           }
         return true;
        }
      //--- PROP_DROPDOWN_INT popover: vAlign or hAlign options
      else if(m_ribbonProperties[i].type == PROP_DROPDOWN_INT)
        {
         string lbls[]; int vals[];
         if(m_ribbonProperties[i].id == "vAlign")
            BuildVAlignOptions(lbls, vals);
         else if(m_ribbonProperties[i].id == "hAlign")
            BuildHAlignOptions(lbls, vals);
         const int rowIdx = HitTestIntegerListPopover(lx, ly, 0, 0,
                                                       ArraySize(lbls), lbls);
         if(rowIdx >= 0)
           {
            SetObjectProperty(m_ribbonOwnerObjectId, m_ribbonProperties[i].id,
                                vals[rowIdx], false);
            HidePopover();
            ChartRedraw();
            return true;
           }
         return true;
        }
      //--- Stop after the first matching descriptor
      break;
     }
   //--- Click inside popover but no matching descriptor - swallow it
   return true;
  }

//+------------------------------------------------------------------+
//| Mouse-move on the popover (opacity drag or hover state)          |
//+------------------------------------------------------------------+
bool CRibbon::PopoverMouseMove(int mouseX, int mouseY, uint mouseButtons)
  {
   //--- Bail when hidden
   if(!m_isPopoverVisible) return false;

   //--- Active opacity drag: update the percent and live-preview the engine value
   if(m_isOpacityDragging)
     {
      //--- Mouse button released during the drag: end the drag defensively
      if((mouseButtons & 1) == 0)
        {
         PopoverMouseUp();
         return false;
        }
      //--- Recompute the strip geometry (matches RenderColorPickerContents layout)
      const int stripL = COLORPICKER_PAD_X;
      const int stripR = GetColorPickerBodyWidth()
                       - COLORPICKER_PAD_X
                       - COLORPICKER_OPACITY_BOX_W
                       - COLORPICKER_OPACITY_BOX_GAP;
      const int stripRadius = COLORPICKER_OPACITY_STRIP_H / 2;
      const int xMin = stripL + stripRadius;
      const int xMax = stripR - stripRadius;
      const int span = xMax - xMin;
      if(span <= 0) return true;
      //--- Translate mouseX into popover-local + map into the 0..100 percent range
      const int lx = mouseX - m_popoverX;
      int dragPct = ((lx - xMin) * 100) / span;
      if(dragPct < 0)   dragPct = 0;
      if(dragPct > 100) dragPct = 100;
      //--- Only commit and redraw when the percent actually changed
      if(dragPct != m_opacityValuePct)
        {
         m_opacityValuePct = dragPct;
         //--- Preview the new opacity to the engine (preview=true)
         string opacityPropId = ColorToOpacityProp(m_activePopoverPropId);
         SetObjectProperty(m_ribbonOwnerObjectId, opacityPropId,
                             m_opacityValuePct, true);
         RedrawPopover();
         RedrawRibbon();
         ChartRedraw();
        }
      return true;
     }

   //--- Idle move: update the hovered item index based on the active popover type
   int lx, ly;
   const bool overPopover = HitTestOverPopover(mouseX, mouseY, lx, ly);
   int newHover = -1;
   if(overPopover)
     {
      //--- Walk descriptors to find the active one + hit-test against its widget
      const int n = ArraySize(m_ribbonProperties);
      for(int i = 0; i < n; i++)
        {
         //--- Skip descriptors that aren't the active popover's binding
         if(m_ribbonProperties[i].id != m_activePopoverPropId) continue;
         if(m_ribbonProperties[i].type == PROP_COLOR)
            newHover = HitTestColorPickerSwatch(lx, ly, 0, 0);
         else if(m_ribbonProperties[i].type == PROP_LINE_WIDTH)
            newHover = HitTestLineWidthPopover(lx, ly, 0, 0);
         else if(m_ribbonProperties[i].type == PROP_LINE_STYLE)
            newHover = HitTestLineStylePopover(lx, ly, 0, 0);
         else if(m_ribbonProperties[i].type == PROP_FONT_SIZE)
           {
            string lbls[]; int vals[];
            BuildFontSizeOptions(lbls, vals);
            newHover = HitTestIntegerListPopover(lx, ly, 0, 0,
                                                   ArraySize(lbls), lbls);
           }
         else if(m_ribbonProperties[i].type == PROP_DROPDOWN_INT)
           {
            string lbls[]; int vals[];
            if(m_ribbonProperties[i].id == "vAlign")
               BuildVAlignOptions(lbls, vals);
            else if(m_ribbonProperties[i].id == "hAlign")
               BuildHAlignOptions(lbls, vals);
            newHover = HitTestIntegerListPopover(lx, ly, 0, 0,
                                                   ArraySize(lbls), lbls);
           }
         //--- Stop after the first matching descriptor
         break;
        }
     }
   //--- Only repaint when the hover actually changed
   if(newHover != m_hoveredPopoverSwatchIdx)
     {
      m_hoveredPopoverSwatchIdx = newHover;
      RedrawPopover();
      ChartRedraw();
     }
   //--- Returning overPopover lets the dispatcher know whether to swallow the event
   return overPopover;
  }

//+------------------------------------------------------------------+
//| End the opacity drag                                             |
//+------------------------------------------------------------------+
bool CRibbon::PopoverMouseUp()
  {
   //--- Idempotent - return false when not dragging
   if(!m_isOpacityDragging) return false;
   m_isOpacityDragging = false;
   return true;
  }

//+------------------------------------------------------------------+
//| Commit the opacity-box text buffer back to the live opacity      |
//+------------------------------------------------------------------+
void CRibbon::CommitBoxEditToOpacity()
  {
   //--- No-op when not editing
   if(!m_isEditingBoxOpacity) return;
   //--- Parse the buffer when non-empty, clamp into 0..100, push to the engine
   if(StringLen(m_boxEditBuffer) > 0)
     {
      int parsed = (int)StringToInteger(m_boxEditBuffer);
      if(parsed < 0)   parsed = 0;
      if(parsed > 100) parsed = 100;
      m_opacityValuePct = parsed;
      //--- Commit the new opacity (preview=false so the engine knows it's a final value)
      string opacityPropId = ColorToOpacityProp(m_activePopoverPropId);
      SetObjectProperty(m_ribbonOwnerObjectId, opacityPropId,
                          m_opacityValuePct, false);
     }
   //--- Clear the editing state + release the keyboard
   m_isEditingBoxOpacity = false;
   m_boxEditBuffer       = "";
   m_boxCaretPos         = 0;
   m_boxCaretOn          = false;
   EndKeyboardOverride();
   RedrawPopover();
   RedrawRibbon();
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| Keyboard handler for the editable opacity box (digits + edits)   |
//+------------------------------------------------------------------+
bool CRibbon::PopoverKeyDown(uint keyCode)
  {
   //--- Bail when not editing
   if(!m_isPopoverVisible) return false;
   if(!m_isEditingBoxOpacity) return false;

   //--- Cache "now" for caret-blink phase resets
   const ulong now = GetTickCount();

   //--- Enter commits the buffer
   if(keyCode == 0x0D)   { CommitBoxEditToOpacity(); return true; }

   //--- Escape cancels the edit and discards the buffer
   if(keyCode == 0x1B)
     {
      m_isEditingBoxOpacity = false;
      m_boxEditBuffer       = "";
      m_boxCaretPos         = 0;
      m_boxCaretOn          = false;
      EndKeyboardOverride();
      RedrawPopover();
      ChartRedraw();
      return true;
     }

   //--- Left arrow: caret-- (clamped at 0)
   if(keyCode == 0x25)
     {
      if(m_boxCaretPos > 0) m_boxCaretPos--;
      m_boxCaretOn = true; m_boxBlinkTickAt = now;
      RedrawPopover(); ChartRedraw(); return true;
     }
   //--- Right arrow: caret++ (clamped at buffer end)
   if(keyCode == 0x27)
     {
      if(m_boxCaretPos < StringLen(m_boxEditBuffer)) m_boxCaretPos++;
      m_boxCaretOn = true; m_boxBlinkTickAt = now;
      RedrawPopover(); ChartRedraw(); return true;
     }
   //--- Home: caret to start
   if(keyCode == 0x24)
     {
      m_boxCaretPos = 0;
      m_boxCaretOn = true; m_boxBlinkTickAt = now;
      RedrawPopover(); ChartRedraw(); return true;
     }
   //--- End: caret to end of buffer
   if(keyCode == 0x23)
     {
      m_boxCaretPos = StringLen(m_boxEditBuffer);
      m_boxCaretOn = true; m_boxBlinkTickAt = now;
      RedrawPopover(); ChartRedraw(); return true;
     }

   //--- Backspace: delete the char before the caret
   if(keyCode == 0x08)
     {
      if(m_boxCaretPos > 0)
        {
         //--- Splice out one char at caret-1
         const string before = StringSubstr(m_boxEditBuffer, 0, m_boxCaretPos - 1);
         const string after  = StringSubstr(m_boxEditBuffer, m_boxCaretPos);
         m_boxEditBuffer = before + after;
         m_boxCaretPos--;
         m_boxCaretOn = true; m_boxBlinkTickAt = now;
         RedrawPopover(); ChartRedraw();
        }
      return true;
     }
   //--- Delete: delete the char at the caret (caret stays put)
   if(keyCode == 0x2E)
     {
      const int n = StringLen(m_boxEditBuffer);
      if(m_boxCaretPos < n)
        {
         //--- Splice out one char at caret
         const string before = StringSubstr(m_boxEditBuffer, 0, m_boxCaretPos);
         const string after  = StringSubstr(m_boxEditBuffer, m_boxCaretPos + 1);
         m_boxEditBuffer = before + after;
         m_boxCaretOn = true; m_boxBlinkTickAt = now;
         RedrawPopover(); ChartRedraw();
        }
      return true;
     }

   //--- Digit keys (0..9 from main row 0x30..0x39 OR numpad 0x60..0x69)
   int digit = -1;
   if(keyCode >= 0x30 && keyCode <= 0x39) digit = (int)(keyCode - 0x30);
   if(keyCode >= 0x60 && keyCode <= 0x69) digit = (int)(keyCode - 0x60);
   if(digit >= 0)
     {
      //--- Max 3 characters in the buffer (covers "0"..."100")
      if(StringLen(m_boxEditBuffer) >= 3) return true;
      //--- Splice the digit in at the caret position + advance caret
      const string before = StringSubstr(m_boxEditBuffer, 0, m_boxCaretPos);
      const string after  = StringSubstr(m_boxEditBuffer, m_boxCaretPos);
      m_boxEditBuffer = before + IntegerToString(digit) + after;
      m_boxCaretPos++;
      //--- If the resulting value exceeds 100, snap to "100"
      int parsed = (int)StringToInteger(m_boxEditBuffer);
      if(parsed > 100) { m_boxEditBuffer = "100"; m_boxCaretPos = 3; }
      m_boxCaretOn = true; m_boxBlinkTickAt = now;
      RedrawPopover(); ChartRedraw();
      return true;
     }
   //--- Any other key falls through (not consumed)
   return false;
  }

//+------------------------------------------------------------------+
//| Caret-blink tick handler (called from the host's OnTimer)        |
//+------------------------------------------------------------------+
void CRibbon::RibbonTick()
  {
   //--- Only blink when the opacity box is in edit mode
   if(!m_isPopoverVisible || !m_isEditingBoxOpacity) return;
   //--- Toggle the visible phase every 500 ms
   const ulong now = GetTickCount();
   if(now - m_boxBlinkTickAt >= 500)
     {
      m_boxCaretOn     = !m_boxCaretOn;
      m_boxBlinkTickAt = now;
      RedrawPopover();
      ChartRedraw();
     }
  }

#endif // TOOLS_PALETTE_RIBBON_MQH
//+------------------------------------------------------------------+