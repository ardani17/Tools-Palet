//+------------------------------------------------------------------+
//|                                         ToolsPalette_Sidebar.mqh |
//|                                            Copyright 2026, Om J. |
//|                                               https://t.me/HZFXI |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Om J."
#property link "https://t.me/HZFXI"
#property version "1.00"
#property strict

//--- Guard against multiple inclusion of this header
#ifndef TOOLS_PALETTE_SIDEBAR_MQH
#define TOOLS_PALETTE_SIDEBAR_MQH

//--- Pull in CDrawingEngine + the entire tool/engine stack via the Tools header
#include "ToolsPalette_Tools.mqh"

input int    CanvasY           = 50;  // Canvas Y Position
input int    CategoryIconSize  = 26;  // Category Icon Size (pt)
input int    FlyoutIconSize    = 22;  // Flyout Icon Size (pt)
input int    FlyoutLabelSize   = 15;  // Flyout Label Font Size (pt)
input int    FlyoutTitleSize   = 14;  // Flyout Title Font Size (pt)
input int    MouseScrollSpeed  = 8;   // Mouse Scroll Step (px)
input int    SnapThreshold     = 40;  // Edge Snap Threshold (px)

//+------------------------------------------------------------------+
//| Edge-snap state for the sidebar panel position                   |
//+------------------------------------------------------------------+
enum ENUM_SNAP_STATE
  {
   SNAP_LEFT,    // Sidebar snapped to the left edge
   SNAP_RIGHT,   // Sidebar snapped to the right edge
   SNAP_FLOAT    // Sidebar is floating (not snapped to either edge)
  };

//+------------------------------------------------------------------+
//| CSidebarLayout owns panel geometry, snap, drag, resize, scroll   |
//+------------------------------------------------------------------+
class CSidebarLayout : public CDrawingEngine
  {
protected:
   //--- Panel position and dimensions
   int             m_panelX;
   int             m_panelY;
   int             m_sidebarWidth;
   int             m_sidebarHeight;
   //--- Category-tile layout
   int             m_categoryButtonSize;
   int             m_categoryButtonPadding;
   int             m_panelCornerRadius;
   int             m_headerGripHeight;
   //--- Snap state (left/right/float) + edge-snap behavior
   ENUM_SNAP_STATE m_snapState;
   //--- Scroll state for the sidebar (overflow handling when not all categories fit)
   int             m_sidebarMaxVisibleCats;
   int             m_sidebarScrollPixels;
   int             m_sidebarScrollThumbHeight;
   int             m_sidebarScrollThinWidth;
   bool            m_isSidebarThumbDragging;
   int             m_sidebarThumbDragStartY;
   int             m_sidebarThumbDragStartPixels;
   bool            m_isHoveredSidebarScrollArea;
   bool            m_isHoveredSidebarThumb;
   //--- Panel-drag state (when user grabs the grip strip and moves the panel)
   bool            m_isPanelDragging;
   int             m_dragOffsetX;
   int             m_dragOffsetY;
   //--- Bottom-edge resize state (when user drags the bottom edge to change panel height)
   bool            m_isResizingBottomEdge;
   int             m_bottomResizeDragStartY;
   int             m_bottomResizeStartHeight;
   int             m_snappedSidebarHeight;
   bool            m_isBottomResizeHovered;
   //--- HR canvas supersample factor (4 = 4x SSAA for crisp rendering)
   int             m_supersampleFactor;

   //--- Sidebar canvas objects (low-res = display, HR = SSAA source)
   CCanvas         m_canvasSidebar;
   CCanvas         m_canvasSidebarHighRes;
   string          m_nameSidebar;

protected:
   //--- Extra vertical gap above action-category tiles (room for the group divider line)
   int             CalcActionCategoryExtraGap();
   //--- Compute the Y pixel position of a category button by its index
   int             CalcCategoryButtonY(int idx);
   //--- Top Y of the scrollable category-tile clip region
   int             CalcClipTop();
   //--- Bottom Y of the scrollable category-tile clip region
   int             CalcClipBottom();
   //--- Total scroll-content height (all tiles plus action-category gap)
   int             CalcSidebarTotalScrollPixels();
   //--- Viewport pixel height = CalcClipBottom - CalcClipTop
   int             CalcSidebarViewportPixels();
   //--- Maximum scroll-pixel offset = max(0, total - viewport)
   int             CalcSidebarMaxScrollPixels();
   //--- Compute and set sidebar height based on available chart space
   void            CalcSidebarHeight();
   //--- Test whether the indexed category button is currently visible in the scroll viewport
   bool            IsCategoryButtonVisible(int idx);
   //--- Snap the panel to the nearest chart edge when it lands within SnapThreshold
   void            TrySnapToEdge();
   //--- Hit-test cursor against the sidebar rect + emit local panel coordinates
   bool            HitTestOverSidebar(int mouseX, int mouseY, int &lx, int &ly);
   //--- Hit-test cursor against the category-tile column + return matched category
   ENUM_CATEGORY   HitTestCategoryButton(int lx, int ly);
   //--- Hit-test cursor against the panel's drag-grip strip
   bool            HitTestOverGripArea(int lx, int ly);
   //--- Hit-test cursor against the close button (top of the header strip)
   bool            HitTestOverCloseButton(int lx, int ly);
   //--- Hit-test cursor against the theme-toggle button (bottom of the header strip)
   bool            HitTestOverThemeButton(int lx, int ly);
   //--- Hit-test cursor against the bottom-edge resize handle
   bool            HitTestOverBottomResizeGrip(int lx, int ly);
   //--- Resize both sidebar canvases (low-res + HR) to the given dimensions
   void            ResizeSidebarCanvases(int w, int h);
  };

//+------------------------------------------------------------------+
//| Extra vertical gap inserted ABOVE action-category tiles          |
//+------------------------------------------------------------------+
int CSidebarLayout::CalcActionCategoryExtraGap()
  {
   //--- 10 px extra gap (totals 16 px with standard 6 px padding) - room for the group divider line
   return 10;
  }

//+------------------------------------------------------------------+
//| Compute the Y pixel position of a category button by index       |
//+------------------------------------------------------------------+
int CSidebarLayout::CalcCategoryButtonY(int idx)
  {
   //--- Standard stacking: each tile offset by (size + padding); minus the scroll offset
   int y = m_headerGripHeight + 8 + idx * (m_categoryButtonSize + m_categoryButtonPadding) - m_sidebarScrollPixels;
   //--- Action categories (CAT_DELETE and below) get extra gap pushed above them
   if(idx >= (int)CAT_DELETE) y += CalcActionCategoryExtraGap();
   return y;
  }

//+------------------------------------------------------------------+
//| Top Y of the scrollable category-tile clip region                |
//+------------------------------------------------------------------+
int CSidebarLayout::CalcClipTop()    { return m_headerGripHeight + 8; }

//+------------------------------------------------------------------+
//| Bottom Y of the scrollable category-tile clip region             |
//+------------------------------------------------------------------+
int CSidebarLayout::CalcClipBottom() { return m_sidebarHeight - 10; }

//+------------------------------------------------------------------+
//| Total scroll-content height including action-category extra gap  |
//+------------------------------------------------------------------+
int CSidebarLayout::CalcSidebarTotalScrollPixels()
  {
   //--- N tiles * (size + padding) minus one trailing padding (no padding after the last tile)
   int n = CAT_COUNT;
   int total = n * (m_categoryButtonSize + m_categoryButtonPadding) - m_categoryButtonPadding;
   //--- Add the extra gap once per action category in the enum (currently only CAT_DELETE)
   total += CalcActionCategoryExtraGap();
   return total;
  }

//+------------------------------------------------------------------+
//| Viewport pixel height = clip-bottom minus clip-top               |
//+------------------------------------------------------------------+
int CSidebarLayout::CalcSidebarViewportPixels()
  {
   return CalcClipBottom() - CalcClipTop();
  }

//+------------------------------------------------------------------+
//| Maximum scroll-pixel offset = max(0, total minus viewport)       |
//+------------------------------------------------------------------+
int CSidebarLayout::CalcSidebarMaxScrollPixels()
  {
   return MathMax(0, CalcSidebarTotalScrollPixels() - CalcSidebarViewportPixels());
  }

//+------------------------------------------------------------------+
//| Compute and set sidebar height based on available chart space    |
//+------------------------------------------------------------------+
void CSidebarLayout::CalcSidebarHeight()
  {
   //--- Cache chart height + standard top/bottom padding values for the layout math
   int chartH = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
   int topPad = 8, botPad = 10;
   m_categoryButtonPadding = 6;
   //--- Total height of all category tiles + inter-tile padding + action-category extra gap
   int actionGap = CalcActionCategoryExtraGap();
   int allTilesH = CAT_COUNT * (m_categoryButtonSize + m_categoryButtonPadding) - m_categoryButtonPadding + actionGap;
   //--- Snapped state: position Y at 30 and size against the available chart vertical space
   if(m_snapState != SNAP_FLOAT)
     {
      //--- Fixed top Y for snapped state
      m_panelY = 30;
      ObjectSetInteger(0, m_nameSidebar, OBJPROP_YDISTANCE, m_panelY);
      //--- Available vertical space + the natural and minimum sidebar heights
      int availH   = chartH - m_panelY - 8;
      int naturalH = m_headerGripHeight + topPad + allTilesH + botPad;
      int minH     = m_headerGripHeight + topPad + 3 * (m_categoryButtonSize + m_categoryButtonPadding) - m_categoryButtonPadding + botPad;
      //--- If user has resized via the bottom edge, honor that height (clamped to natural and avail)
      if(m_snappedSidebarHeight > 0)
         m_sidebarHeight = MathMax(minH, MathMin(MathMin(naturalH, availH), m_snappedSidebarHeight));
      else
         m_sidebarHeight = MathMax(minH, MathMin(naturalH, availH));
     }
   else
     {
      //--- Floating state: size at natural height but cap to available vertical space
      int naturalH = m_headerGripHeight + topPad + allTilesH + botPad;
      int maxH     = chartH - m_panelY - 20;
      int minH     = m_headerGripHeight + topPad + 3 * (m_categoryButtonSize + m_categoryButtonPadding) - m_categoryButtonPadding + botPad;
      //--- Re-clamp if current height is now outside the [minH, MathMin(naturalH, maxH)] range
      if(m_sidebarHeight < minH || m_sidebarHeight > MathMin(naturalH, maxH))
         m_sidebarHeight = MathMin(naturalH, maxH);
     }
   //--- Available area for category tiles = sidebar height minus header strip and padding
   int btnAreaH = m_sidebarHeight - m_headerGripHeight - topPad - botPad;
   int fullBtnH = allTilesH;
   //--- All tiles fit: no scroll needed
   if(fullBtnH <= btnAreaH)
     {
      m_sidebarMaxVisibleCats = CAT_COUNT;
      m_sidebarScrollPixels   = 0;
     }
   else
     {
      //--- Overflow: compute how many tiles fit + clamp the scroll offset
      m_sidebarMaxVisibleCats = MathMax(3, MathMin(CAT_COUNT, btnAreaH / (m_categoryButtonSize + m_categoryButtonPadding)));
      m_sidebarScrollPixels   = MathMax(0, MathMin(m_sidebarScrollPixels, CalcSidebarMaxScrollPixels()));
     }
  }

//+------------------------------------------------------------------+
//| Test whether the indexed category button is visible in viewport  |
//+------------------------------------------------------------------+
bool CSidebarLayout::IsCategoryButtonVisible(int idx)
  {
   //--- All tiles always visible when there's no scroll overflow
   if(m_sidebarMaxVisibleCats >= CAT_COUNT) return true;
   //--- Visible iff the tile's Y span overlaps the clip region
   int y = CalcCategoryButtonY(idx);
   return (y + m_categoryButtonSize > CalcClipTop() && y < CalcClipBottom());
  }

//+------------------------------------------------------------------+
//| Snap the sidebar panel to the nearest chart edge when in range   |
//+------------------------------------------------------------------+
void CSidebarLayout::TrySnapToEdge()
  {
   //--- Cache chart width and the previous snap state (to detect transitions in/out of FLOAT)
   int chartW = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
   ENUM_SNAP_STATE prev = m_snapState;
   //--- Within SnapThreshold of the left edge: snap left
   if(m_panelX <= SnapThreshold)
     { m_snapState = SNAP_LEFT; m_panelX = 0; if(prev == SNAP_FLOAT) m_snappedSidebarHeight = 0; }
   //--- Within SnapThreshold of the right edge: snap right
   else if(m_panelX + m_sidebarWidth >= chartW - SnapThreshold)
     { m_snapState = SNAP_RIGHT; m_panelX = chartW - m_sidebarWidth; if(prev == SNAP_FLOAT) m_snappedSidebarHeight = 0; }
   else
     {
      //--- Otherwise float - reset stored snap height when transitioning from a snapped state
      m_snapState = SNAP_FLOAT;
      if(prev != SNAP_FLOAT) { m_snappedSidebarHeight = 0; m_categoryButtonPadding = 6; }
     }
   //--- Sync the sidebar chart-object's X position after the snap decision
   ObjectSetInteger(0, m_nameSidebar, OBJPROP_XDISTANCE, m_panelX);
  }

//+------------------------------------------------------------------+
//| Hit-test cursor against sidebar rect + emit local panel coords   |
//+------------------------------------------------------------------+
bool CSidebarLayout::HitTestOverSidebar(int mouseX, int mouseY, int &lx, int &ly)
  {
   //--- Translate the global mouse coords into sidebar-local coords
   lx = mouseX - m_panelX; ly = mouseY - m_panelY;
   //--- Inside the sidebar rect iff both local coords fall within [0, width) x [0, height)
   return (lx >= 0 && lx < m_sidebarWidth && ly >= 0 && ly < m_sidebarHeight);
  }

//+------------------------------------------------------------------+
//| Hit-test cursor against the category-tile column                 |
//+------------------------------------------------------------------+
ENUM_CATEGORY CSidebarLayout::HitTestCategoryButton(int lx, int ly)
  {
   //--- Bail if cursor is outside the scrollable clip region
   if(ly < CalcClipTop() || ly >= CalcClipBottom()) return CAT_NONE;
   //--- Tile X position is centered horizontally within the sidebar width
   int btnX = (m_sidebarWidth - m_categoryButtonSize) / 2;
   //--- Walk every category and return the first one whose tile Y span contains the cursor
   for(int c = 0; c < CAT_COUNT; c++)
     {
      if(!IsCategoryButtonVisible(c)) continue;
      int btnY = CalcCategoryButtonY(c);
      if(lx >= btnX && lx <= btnX + m_categoryButtonSize &&
         ly >= btnY && ly <= btnY + m_categoryButtonSize && ly < m_sidebarHeight - 8)
         return (ENUM_CATEGORY)c;
     }
   return CAT_NONE;
  }

//+------------------------------------------------------------------+
//| Hit-test cursor against the panel's drag-grip strip              |
//+------------------------------------------------------------------+
bool CSidebarLayout::HitTestOverGripArea(int lx, int ly)
  {
   //--- Grip strip sits between the close button and the theme-toggle button (20 px high)
   return (lx >= 0 && lx < m_sidebarWidth && ly >= m_categoryButtonSize && ly < m_categoryButtonSize + 20);
  }

//+------------------------------------------------------------------+
//| Hit-test cursor against the close button at the header top       |
//+------------------------------------------------------------------+
bool CSidebarLayout::HitTestOverCloseButton(int lx, int ly)
  {
   //--- Close button occupies the top category-button-sized row of the header
   return (lx >= 0 && lx < m_sidebarWidth && ly >= 0 && ly < m_categoryButtonSize);
  }

//+------------------------------------------------------------------+
//| Hit-test cursor against the theme-toggle button below grip       |
//+------------------------------------------------------------------+
bool CSidebarLayout::HitTestOverThemeButton(int lx, int ly)
  {
   //--- Theme button occupies the remaining header rows below the grip strip
   return (lx >= 0 && lx < m_sidebarWidth && ly >= m_categoryButtonSize + 20 && ly < m_headerGripHeight);
  }

//+------------------------------------------------------------------+
//| Hit-test cursor against the bottom-edge resize handle            |
//+------------------------------------------------------------------+
bool CSidebarLayout::HitTestOverBottomResizeGrip(int lx, int ly)
  {
   //--- Bottom 8 px of the sidebar is the resize handle
   return (lx >= 0 && lx < m_sidebarWidth && ly >= m_sidebarHeight - 8 && ly < m_sidebarHeight);
  }

//+------------------------------------------------------------------+
//| Resize both sidebar canvases (low-res + HR) to given dimensions  |
//+------------------------------------------------------------------+
void CSidebarLayout::ResizeSidebarCanvases(int w, int h)
  {
   //--- Resize the display canvas and sync its chart-object size attribute
   m_canvasSidebar.Resize(w, h);
   ObjectSetInteger(0, m_nameSidebar, OBJPROP_XSIZE, w);
   ObjectSetInteger(0, m_nameSidebar, OBJPROP_YSIZE, h);
   //--- HR canvas is supersampleFactor x larger for SSAA rendering
   m_canvasSidebarHighRes.Resize(w * m_supersampleFactor, h * m_supersampleFactor);
  }

//+------------------------------------------------------------------+
//| CFlyoutPanel owns the tool-list flyout layout and rendering      |
//+------------------------------------------------------------------+
class CFlyoutPanel : public CSidebarLayout
  {
protected:
   //--- Flyout panel layout dimensions
   int           m_flyoutWidth;
   int           m_flyoutItemHeight;
   int           m_flyoutPadding;
   int           m_flyoutPointerWidth;
   int           m_flyoutPointerHeight;
   int           m_flyoutPointerLocalY;
   bool          m_flyoutPointerOnLeft;
   //--- Flyout visibility and active-category state
   bool          m_isFlyoutVisible;
   ENUM_CATEGORY m_flyoutActiveCat;
   int           m_hoveredFlyoutItem;
   //--- Flyout scroll state (used when the category has more tools than visible slots)
   int           m_flyoutScrollPixels;
   int           m_flyoutMaxVisibleItems;
   int           m_flyoutScrollThumbHeight;
   bool          m_isFlyoutThumbDragging;
   int           m_flyoutThumbDragStartY;
   int           m_flyoutThumbDragStartPixels;
   bool          m_isHoveredFlyoutScrollArea;
   bool          m_isHoveredFlyoutThumb;

   //--- Flyout canvas objects (low-res = display, HR = SSAA source)
   CCanvas       m_canvasFlyout;
   CCanvas       m_canvasFlyoutHighRes;
   string        m_nameFlyout;

protected:
   //--- Hide the flyout panel (clears hover/scroll state and detaches chart-object visibility)
   void          HideFlyout();
   //--- Hit-test cursor against the flyout rect + emit local flyout coordinates
   bool          HitTestOverFlyout(int mouseX, int mouseY, int &lx, int &ly);
   //--- Hit-test cursor against the flyout's item rows + return the matched item index
   int           HitTestFlyoutItem(int lx, int ly);
   //--- Draw the rounded flyout body border at high resolution
   void          DrawFlyoutBodyBorderHR(int x, int y, int w, int h, int r, int thickness, uint borderColor);
   //--- Render the compact action-category flyout (currently only CAT_DELETE)
   void          DrawActionFlyout(ENUM_CATEGORY cat, TOOL_TYPE activeTool);
   //--- Draw the scroll thumb pill overlay on top of the flyout body
   void          DrawFlyoutScrollPillOverlay(ENUM_CATEGORY cat);
   //--- Draw + composite the full flyout panel for the given category
   void          DrawFlyoutForCategory(ENUM_CATEGORY cat, TOOL_TYPE activeTool);
   //--- Show the flyout for the given category (compute position + dispatch DrawFlyoutForCategory)
   void          ShowFlyout(ENUM_CATEGORY cat, TOOL_TYPE activeTool);
  };

//+------------------------------------------------------------------+
//| Hide the flyout panel and clear all transient hover/scroll state |
//+------------------------------------------------------------------+
void CFlyoutPanel::HideFlyout()
  {
   //--- Clear hover + scroll + thumb-hover flags so a stale state doesn't survive into next show
   m_hoveredFlyoutItem         = -1;
   m_flyoutScrollPixels        = 0;
   m_isHoveredFlyoutScrollArea = false;
   m_isHoveredFlyoutThumb      = false;
   //--- Detach the flyout chart object from all timeframes - effectively hides it
   ObjectSetInteger(0, m_nameFlyout, OBJPROP_TIMEFRAMES, OBJ_NO_PERIODS);
   m_isFlyoutVisible = false;
   m_flyoutActiveCat = CAT_NONE;
  }

//+------------------------------------------------------------------+
//| Hit-test cursor against flyout rect + emit local flyout coords   |
//+------------------------------------------------------------------+
bool CFlyoutPanel::HitTestOverFlyout(int mouseX, int mouseY, int &lx, int &ly)
  {
   //--- Bail if flyout isn't currently shown
   if(!m_isFlyoutVisible) return false;
   //--- Read the flyout chart object's position and size from chart-object props
   int fx = (int)ObjectGetInteger(0, m_nameFlyout, OBJPROP_XDISTANCE);
   int fy = (int)ObjectGetInteger(0, m_nameFlyout, OBJPROP_YDISTANCE);
   int fw = (int)ObjectGetInteger(0, m_nameFlyout, OBJPROP_XSIZE);
   int fh = (int)ObjectGetInteger(0, m_nameFlyout, OBJPROP_YSIZE);
   //--- Translate global mouse coords into flyout-local coords
   lx = mouseX - fx; ly = mouseY - fy;
   //--- Inside the flyout rect iff the global coords fall within its bounds
   return (mouseX >= fx && mouseX < fx + fw && mouseY >= fy && mouseY < fy + fh);
  }

//+------------------------------------------------------------------+
//| Hit-test cursor against flyout item rows + return matched index  |
//+------------------------------------------------------------------+
int CFlyoutPanel::HitTestFlyoutItem(int lx, int ly)
  {
   //--- Bail if no flyout category is active
   if(m_flyoutActiveCat == CAT_NONE) return -1;

   //--- Action categories have a single virtual item (index 0) - no header, no scroll
   if(IsActionCategory(m_flyoutActiveCat))
     {
      //--- Account for the pointer-reserve area (skipped on the side facing the sidebar)
      int dispBx = m_flyoutPointerOnLeft ? m_flyoutPointerHeight : 0;
      //--- Single item's Y span = padding to padding + itemHeight
      int itemTop = m_flyoutPadding;
      int itemBot = m_flyoutPadding + m_flyoutItemHeight;
      if(ly < itemTop || ly >= itemBot) return -1;
      //--- Horizontal range must be inside the body (skip the pointer-reserve area)
      if(lx < dispBx || lx >= dispBx + m_flyoutWidth) return -1;
      return 0;
     }

   //--- Regular flyout: count tools + cache geometry for the visible-item-row tests
   int nTools = ArraySize(m_categories[(int)m_flyoutActiveCat].tools);
   int titleH = 26, dispBx = m_flyoutPointerOnLeft ? m_flyoutPointerHeight : 0;
   int visibleTools = MathMin(nTools, m_flyoutMaxVisibleItems);
   //--- Exclude clicks in the scrollbar's gutter when overflow exists
   if(nTools > m_flyoutMaxVisibleItems)
     {
      int tw = m_sidebarScrollThinWidth;
      if(!m_flyoutPointerOnLeft) { if(lx <= dispBx + tw + 8) return -1; }
      else                        { if(lx >= dispBx + m_flyoutWidth - tw - 8) return -1; }
     }
   //--- Item-area Y range below the title strip
   int itemClipTop = titleH + m_flyoutPadding;
   int itemClipBot = titleH + m_flyoutPadding + visibleTools * m_flyoutItemHeight;
   if(ly < itemClipTop || ly >= itemClipBot) return -1;
   //--- Map the Y position into a tool index (honoring the current scroll offset)
   int idx = (ly - itemClipTop + m_flyoutScrollPixels) / m_flyoutItemHeight;
   if(idx < 0 || idx >= nTools) return -1;
   return idx;
  }

//+------------------------------------------------------------------+
//| Draw the rounded flyout body border at high resolution           |
//+------------------------------------------------------------------+
void CFlyoutPanel::DrawFlyoutBodyBorderHR(int x, int y, int w, int h, int r, int thickness, uint borderColor)
  {
   //--- Honor the global BorderWidth toggle (BorderWidth=0 disables borders entirely)
   if(BorderWidth <= 0) return;
   //--- Clamp the corner radius so it can't exceed half the smaller side
   r = MathMin(r, MathMin(w / 2, h / 2)); int h2 = thickness / 2;
   //--- 4 edges of the rounded rectangle (Top, Right, Bottom, Left)
   DrawBorderEdge(m_canvasFlyoutHighRes, x + r,      y + h2,     x + w - r,  y + h2,     thickness, borderColor);
   DrawBorderEdge(m_canvasFlyoutHighRes, x + w - h2, y + r,      x + w - h2, y + h - r,  thickness, borderColor);
   DrawBorderEdge(m_canvasFlyoutHighRes, x + w - r,  y + h - h2, x + r,      y + h - h2, thickness, borderColor);
   DrawBorderEdge(m_canvasFlyoutHighRes, x + h2,     y + h - r,  x + h2,     y + r,      thickness, borderColor);
   //--- 4 corner arcs (TL, TR, BL, BR)
   DrawCornerArc(m_canvasFlyoutHighRes, x + r,     y + r,     r, thickness, borderColor, M_PI,       M_PI * 1.5);
   DrawCornerArc(m_canvasFlyoutHighRes, x + w - r, y + r,     r, thickness, borderColor, M_PI * 1.5, M_PI * 2.0);
   DrawCornerArc(m_canvasFlyoutHighRes, x + r,     y + h - r, r, thickness, borderColor, M_PI * 0.5, M_PI);
   DrawCornerArc(m_canvasFlyoutHighRes, x + w - r, y + h - r, r, thickness, borderColor, 0.0,        M_PI * 0.5);
  }

//+------------------------------------------------------------------+
//| Render the compact action-category flyout (CAT_DELETE)           |
//+------------------------------------------------------------------+
void CFlyoutPanel::DrawActionFlyout(ENUM_CATEGORY cat, TOOL_TYPE activeTool)
  {
   //--- Geometry - single-row flyout, no header, no pointer triangle (titleH=0, visibleTools=1)
   int titleH       = 0;
   int visibleTools = 1;
   int flyH         = m_flyoutPadding + visibleTools * m_flyoutItemHeight + m_flyoutPadding;
   int totalW       = m_flyoutWidth + m_flyoutPointerHeight;
   int ws           = totalW * m_supersampleFactor;
   int hs           = flyH * m_supersampleFactor;
   bool ptrLeft     = m_flyoutPointerOnLeft;

   //--- Resize canvases to the compact action-flyout dimensions if needed
   if(m_canvasFlyout.Width() != totalW || m_canvasFlyout.Height() != flyH)
      m_canvasFlyout.Resize(totalW, flyH);
   if(m_canvasFlyoutHighRes.Width() != ws || m_canvasFlyoutHighRes.Height() != hs)
      m_canvasFlyoutHighRes.Resize(ws, hs);
   //--- Sync the chart-object size attribute and clear the HR canvas
   ObjectSetInteger(0, m_nameFlyout, OBJPROP_XSIZE, totalW);
   ObjectSetInteger(0, m_nameFlyout, OBJPROP_YSIZE, flyH);
   m_canvasFlyoutHighRes.Erase(0x00000000);

   //--- Body geometry (excluding the pointer-reserve area on the sidebar-facing side)
   int bx = ptrLeft ? m_flyoutPointerHeight * m_supersampleFactor : 0;
   int bw = m_flyoutWidth * m_supersampleFactor;
   int br = m_panelCornerRadius * m_supersampleFactor;
   //--- Compose theme-aware ARGB values for fill, border, and border thickness
   uchar flyBgA   = (uchar)(255 * BackgroundOpacity);
   uint  fillARGB = ColorToARGB(m_themeColors.flyoutBackground, flyBgA);
   uint  borderARGB = ColorToARGB(m_themeColors.flyoutBorder, 255);
   int   brdT = BorderWidth * m_supersampleFactor;

   //--- Filled rounded body - no pointer triangle (key difference from regular flyout)
   FillRoundRectHR(m_canvasFlyoutHighRes, bx, 0, bw, hs, br, fillARGB);

   //--- Body border around the rounded rect (no triangle border edges)
   if(BorderWidth > 0)
      DrawFlyoutBodyBorderHR(bx, 0, bw, hs, br, brdT, borderARGB);

   //--- Item highlight background - single row at y = padding (highlighted on hover)
   bool isHovered = (m_hoveredFlyoutItem == 0 && m_flyoutActiveCat == cat);
   int  itemY     = (titleH + m_flyoutPadding) * m_supersampleFactor;
   int  itemH     = (m_flyoutItemHeight - 2) * m_supersampleFactor;
   int  padS      = m_flyoutPadding * m_supersampleFactor;
   //--- Render the hover highlight as a small rounded rect inside the body
   if(isHovered)
      FillRoundRectHR(m_canvasFlyoutHighRes, bx + padS, itemY, bw - 2 * padS, itemH,
                      5 * m_supersampleFactor,
                      ColorToARGB(m_themeColors.flyoutItemHoverBackground, 255));

   //--- Compose HR canvas down to the display canvas via supersample averaging
   DownsampleCanvas(m_canvasFlyout, m_canvasFlyoutHighRes, m_supersampleFactor);

   //--- Text row in display resolution - compute the row's X offset and Y span
   int dispBx = ptrLeft ? m_flyoutPointerHeight : 0;
   int dispItemY = m_flyoutPadding;
   int dispItemH = m_flyoutItemHeight - 2;

   //--- Live count of drawings on the chart (m_drawnObjects is inherited from CDrawingEngine)
   int drawingCount = ArraySize(m_drawnObjects);
   string label = "Delete " + IntegerToString(drawingCount) + " drawing" +
                   (drawingCount == 1 ? "" : "s");

   //--- Color: muted when no drawings to delete, bright on hover, normal otherwise
   color textColor;
   if(drawingCount == 0)
      textColor = m_themeColors.buttonIconColor;       // muted - no drawings to delete
   else if(isHovered)
      textColor = clrWhite;                             // bright on hover
   else
      textColor = m_themeColors.flyoutTextColor;        // normal text color

   //--- Compute the label X position so it lands where the ICON would have started in regular rows
   m_canvasFlyout.FontSet("Arial", FlyoutLabelSize);
   int lh = m_canvasFlyout.TextHeight(label);
   int labelX = dispBx + m_flyoutPadding + 8;
   int labelY = dispItemY + (dispItemH - lh) / 2;
   //--- Render the label text and push the canvas update
   m_canvasFlyout.TextOut(labelX, labelY, label, ColorToARGB(textColor, 255));

   m_canvasFlyout.Update();
  }

//+------------------------------------------------------------------+
//| Draw the flyout's scroll thumb pill overlay onto the display     |
//+------------------------------------------------------------------+
void CFlyoutPanel::DrawFlyoutScrollPillOverlay(ENUM_CATEGORY cat)
  {
   //--- Only render the pill while user is hovering the scroll area or dragging the thumb
   if(!m_isHoveredFlyoutScrollArea && !m_isFlyoutThumbDragging) return;
   //--- Bail if no category is active or category has no overflow
   if(cat == CAT_NONE) return;
   int nTools = ArraySize(m_categories[(int)cat].tools);
   if(nTools <= m_flyoutMaxVisibleItems) return;
   //--- Cache geometry: title height, items top Y, track height
   int titleH = 26, itemsTop = titleH + m_flyoutPadding;
   int trackH = MathMin(nTools, m_flyoutMaxVisibleItems) * m_flyoutItemHeight;
   //--- Thumb height proportional to the visible-fraction of items (min 20 px)
   m_flyoutScrollThumbHeight = MathMax(20, (int)(trackH * (double)m_flyoutMaxVisibleItems / nTools));
   //--- Compute the thumb's Y position from the current scroll fraction
   int    maxScrollPx = (nTools - m_flyoutMaxVisibleItems) * m_flyoutItemHeight;
   double scrollPos   = (maxScrollPx > 0) ? (double)m_flyoutScrollPixels / maxScrollPx : 0.0;
   int    thumbY      = itemsTop + (int)(scrollPos * (trackH - m_flyoutScrollThumbHeight));
   //--- Thin-track X position depends on which side the flyout's pointer is on
   int tw    = m_sidebarScrollThinWidth, dispBx = m_flyoutPointerOnLeft ? m_flyoutPointerHeight : 0;
   int thinX = m_flyoutPointerOnLeft ? (dispBx + m_flyoutWidth - tw - 2) : (dispBx + 2);
   //--- Pill color + alpha vary by interaction state (dragging > hovered > idle)
   color pillColor; uchar pillAlpha;
   if(m_isFlyoutThumbDragging)     { pillColor = m_themeColors.accentBarColor;        pillAlpha = 255; }
   else if(m_isHoveredFlyoutThumb) { pillColor = m_themeColors.scrollArrowHoverColor; pillAlpha = 255; }
   else                             { pillColor = m_themeColors.scrollArrowColor;      pillAlpha = 180; }
   uint thumbARGB = ColorToARGB(pillColor, pillAlpha);
   //--- Build the pill at high resolution (capsule rounded-rect)
   int pws = tw * m_supersampleFactor, phs = m_flyoutScrollThumbHeight * m_supersampleFactor;
   CCanvas pillHR;
   pillHR.Create("FlyoutPillHR_tmp", pws, phs, COLOR_FORMAT_ARGB_NORMALIZE);
   pillHR.Erase(0x00000000);
   FillRoundRectHR(pillHR, 0, 0, pws, phs, MathMax(1, pws / 2), thumbARGB);
   //--- Downsample the HR pill manually onto the display canvas (SSxSS block averaging)
   int ss2 = m_supersampleFactor * m_supersampleFactor;
   //--- Walk every output pixel
   for(int py = 0; py < m_flyoutScrollThumbHeight; py++)
      for(int px = 0; px < tw; px++)
        {
         //--- Accumulators for the SSxSS block averaging
         double sumA = 0, sumR = 0, sumG = 0, sumB = 0, wc = 0;
         //--- Walk the SSxSS source block
         for(int dy = 0; dy < m_supersampleFactor; dy++)
            for(int dx = 0; dx < m_supersampleFactor; dx++)
              {
               //--- Compute the source coords and skip out-of-bounds samples
               int sx = px * m_supersampleFactor + dx, sy = py * m_supersampleFactor + dy;
               if(sx >= pws || sy >= phs) continue;
               //--- Read the source pixel; accumulate alpha always, RGB only for non-transparent samples
               uint p = pillHR.PixelGet(sx, sy); uchar pa = (uchar)((p >> 24) & 0xFF);
               sumA += pa;
               if(pa > 0) { sumR += (p >> 16) & 0xFF; sumG += (p >> 8) & 0xFF; sumB += p & 0xFF; wc += 1.0; }
              }
         //--- Final alpha is the simple block average
         uchar fa = (uchar)(sumA / ss2);
         //--- Skip fully-transparent or fully-empty pixels; otherwise blend onto the display canvas
         if(fa > 0 && wc > 0)
            BlendPixelSet(m_canvasFlyout, thinX + px, thumbY + py,
               ((uint)fa << 24) | ((uint)(uchar)(sumR / wc) << 16) | ((uint)(uchar)(sumG / wc) << 8) | (uint)(uchar)(sumB / wc));
        }
   //--- Free the temporary HR pill canvas
   pillHR.Destroy();
  }

//+------------------------------------------------------------------+
//| Draw + composite the full flyout panel for the given category    |
//+------------------------------------------------------------------+
void CFlyoutPanel::DrawFlyoutForCategory(ENUM_CATEGORY cat, TOOL_TYPE activeTool)
  {
   //--- Action categories take a dedicated render path (compact, no header, no pointer)
   if(IsActionCategory(cat))
     {
      DrawActionFlyout(cat, activeTool);
      return;
     }

   //--- Regular tool-category render path
   int nTools = ArraySize(m_categories[(int)cat].tools);
   if(nTools == 0) return;
   //--- Geometry: title strip + visible items area; scroll thumb when overflow
   int titleH = 26, visibleTools = MathMin(nTools, m_flyoutMaxVisibleItems);
   bool needsScroll = (nTools > m_flyoutMaxVisibleItems);
   int flyH   = titleH + m_flyoutPadding + visibleTools * m_flyoutItemHeight + m_flyoutPadding;
   int totalW = m_flyoutWidth + m_flyoutPointerHeight;
   int ws = totalW * m_supersampleFactor, hs = flyH * m_supersampleFactor;
   bool ptrLeft = m_flyoutPointerOnLeft;
   //--- Thumb height proportional to the visible-fraction of items (min 20 px)
   if(needsScroll)
      m_flyoutScrollThumbHeight = MathMax(20, (int)(MathMin(nTools, m_flyoutMaxVisibleItems) * m_flyoutItemHeight * (double)m_flyoutMaxVisibleItems / nTools));
   //--- Resize canvases to fit the computed dimensions if needed
   if(m_canvasFlyout.Width() != totalW || m_canvasFlyout.Height() != flyH)
      m_canvasFlyout.Resize(totalW, flyH);
   if(m_canvasFlyoutHighRes.Width() != ws || m_canvasFlyoutHighRes.Height() != hs)
      m_canvasFlyoutHighRes.Resize(ws, hs);
   //--- Sync the chart-object size attribute and clear the HR canvas
   ObjectSetInteger(0, m_nameFlyout, OBJPROP_XSIZE, totalW);
   ObjectSetInteger(0, m_nameFlyout, OBJPROP_YSIZE, flyH);
   m_canvasFlyoutHighRes.Erase(0x00000000);
   //--- Body geometry (excluding the pointer-reserve area)
   int bx = ptrLeft ? m_flyoutPointerHeight * m_supersampleFactor : 0;
   int bw = m_flyoutWidth * m_supersampleFactor;
   int br = m_panelCornerRadius * m_supersampleFactor;
   //--- Clamp the pointer triangle's Y position to fit inside the body's vertical span
   int ptrCY  = MathMax(br + m_flyoutPointerWidth * m_supersampleFactor + m_supersampleFactor,
                MathMin(hs - br - m_flyoutPointerWidth * m_supersampleFactor - m_supersampleFactor,
                        m_flyoutPointerLocalY * m_supersampleFactor));
   int ptrHHS = m_flyoutPointerWidth * m_supersampleFactor;
   //--- Pointer triangle X-coords - tip is on the canvas edge, base is on the body edge
   int tipX  = ptrLeft ? 0 : ws - 1, baseX = ptrLeft ? bx : bx + bw - 1;
   //--- Compose theme-aware ARGB values for fill + border + border thickness
   uchar flyBgA     = (uchar)(255 * BackgroundOpacity);
   uint  fillARGB   = ColorToARGB(m_themeColors.flyoutBackground, flyBgA);
   uint  borderARGB = ColorToARGB(m_themeColors.flyoutBorder, 255);
   int   brdT       = BorderWidth * m_supersampleFactor;
   //--- Filled rounded body + pointer triangle
   FillRoundRectHR(m_canvasFlyoutHighRes, bx, 0, bw, hs, br, fillARGB);
   FillTriangleHR(m_canvasFlyoutHighRes, tipX, ptrCY, baseX, ptrCY - ptrHHS, baseX, ptrCY + ptrHHS, fillARGB);
   //--- Border around the body + triangle (when BorderWidth > 0)
   if(BorderWidth > 0)
     {
      //--- Pointer-on-left layout: body border first, then erase body edge inside the triangle base, then draw triangle edges
      if(ptrLeft)
        {
         DrawFlyoutBodyBorderHR(bx, 0, bw, hs, br, brdT, borderARGB);
         m_canvasFlyoutHighRes.FillRectangle(bx, ptrCY - ptrHHS, bx + brdT + m_supersampleFactor, ptrCY + ptrHHS, fillARGB);
         DrawBorderEdge(m_canvasFlyoutHighRes, (double)bx,   (double)(ptrCY - ptrHHS), (double)tipX, (double)ptrCY,            brdT, borderARGB);
         DrawBorderEdge(m_canvasFlyoutHighRes, (double)tipX, (double)ptrCY,            (double)bx,   (double)(ptrCY + ptrHHS), brdT, borderARGB);
        }
      else
        {
         //--- Pointer-on-right layout (mirror of the left case)
         int bodyRight = bx + bw;
         DrawFlyoutBodyBorderHR(bx, 0, bw, hs, br, brdT, borderARGB);
         m_canvasFlyoutHighRes.FillRectangle(bodyRight - brdT - m_supersampleFactor, ptrCY - ptrHHS, bodyRight, ptrCY + ptrHHS, fillARGB);
         DrawBorderEdge(m_canvasFlyoutHighRes, (double)bodyRight, (double)(ptrCY - ptrHHS), (double)tipX,      (double)ptrCY,            brdT, borderARGB);
         DrawBorderEdge(m_canvasFlyoutHighRes, (double)tipX,      (double)ptrCY,            (double)bodyRight, (double)(ptrCY + ptrHHS), brdT, borderARGB);
        }
     }
   //--- Title strip background fill (top portion of the body with rounded top corners only)
   color titleFill = m_isDarkTheme ? C'25,29,40' : C'245,247,252';
   int   tbrd      = MathMax(brdT, m_supersampleFactor), innerTR = MathMax(0, br - tbrd);
   FillSelectiveRoundRectHR(m_canvasFlyoutHighRes, bx + tbrd, tbrd, bw - 2 * tbrd, titleH * m_supersampleFactor - tbrd, innerTR, ColorToARGB(titleFill, 255), true, true, false, false);
   //--- Square-fill the bottom half of the title strip so the rounded top blends seamlessly
   m_canvasFlyoutHighRes.FillRectangle(bx + tbrd, (titleH / 2) * m_supersampleFactor, bx + bw - tbrd - 1, titleH * m_supersampleFactor - 1, ColorToARGB(titleFill, 255));
   //--- Item-area Y range below the title strip
   int itemClipTop = titleH + m_flyoutPadding;
   int itemClipBot = titleH + m_flyoutPadding + visibleTools * m_flyoutItemHeight;
   //--- Render the item highlight backgrounds (active + hovered states)
   if(needsScroll)
     {
      //--- Overflow case: render all item highlights into a temporary HR canvas, then clip-blit into the main HR
      CCanvas tmpHighRes;
      tmpHighRes.Create("FlyoutTmpHR", ws, hs, COLOR_FORMAT_ARGB_NORMALIZE);
      tmpHighRes.Erase(0x00000000);
      //--- Walk every tool and render its highlight (if any) into the temp canvas
      for(int t = 0; t < nTools; t++)
        {
         //--- Item Y position with the current scroll offset applied
         int itemY = (titleH + m_flyoutPadding + t * m_flyoutItemHeight - m_flyoutScrollPixels) * m_supersampleFactor;
         //--- Skip items entirely outside the visible Y range
         if(itemY + (m_flyoutItemHeight - 2) * m_supersampleFactor <= itemClipTop * m_supersampleFactor) continue;
         if(itemY >= itemClipBot * m_supersampleFactor) continue;
         //--- Resolve active + hovered state for this item
         bool isActive  = (activeTool == m_categories[(int)cat].tools[t].toolType);
         bool isHovered = (m_hoveredFlyoutItem == t && m_flyoutActiveCat == cat);
         int  itemH = (m_flyoutItemHeight - 2) * m_supersampleFactor, padS = m_flyoutPadding * m_supersampleFactor;
         //--- Active wins over hovered when both are true (active background color is the brighter accent)
         if(isActive)
            FillRoundRectHR(tmpHighRes, bx + padS, itemY, bw - 2 * padS, itemH, 5 * m_supersampleFactor, ColorToARGB(m_themeColors.buttonActiveBackground, 255));
         else if(isHovered)
            FillRoundRectHR(tmpHighRes, bx + padS, itemY, bw - 2 * padS, itemH, 5 * m_supersampleFactor, ColorToARGB(m_themeColors.flyoutItemHoverBackground, 255));
         //--- Active items get a small white dot on the right (the "selected" indicator)
         if(isActive)
            tmpHighRes.FillCircle(bx + bw - m_flyoutPadding * m_supersampleFactor - 5 * m_supersampleFactor,
                                   itemY + itemH / 2, 3 * m_supersampleFactor, ColorToARGB(m_themeColors.flyoutTextActiveColor, 255));
        }
      //--- Blit the temp canvas onto the main HR canvas, but only within the item-clip Y range
      for(int y = itemClipTop * m_supersampleFactor; y < itemClipBot * m_supersampleFactor && y < hs; y++)
         for(int x = 0; x < ws; x++)
           {
            uint px = tmpHighRes.PixelGet(x, y);
            if(((px >> 24) & 0xFF) > 0) BlendPixelSet(m_canvasFlyoutHighRes, x, y, px);
           }
      //--- Free the temp HR canvas
      tmpHighRes.Destroy();
     }
   else
     {
      //--- Non-overflow case: render highlights directly into the main HR canvas (no scroll clipping needed)
      for(int t = 0; t < visibleTools; t++)
        {
         //--- Resolve active + hovered state for this item
         bool isActive  = (activeTool == m_categories[(int)cat].tools[t].toolType);
         bool isHovered = (m_hoveredFlyoutItem == t && m_flyoutActiveCat == cat);
         int  itemY = (titleH + m_flyoutPadding + t * m_flyoutItemHeight) * m_supersampleFactor;
         int  itemH = (m_flyoutItemHeight - 2) * m_supersampleFactor;
         int  padS  = m_flyoutPadding * m_supersampleFactor;
         //--- Active wins over hovered when both are true
         if(isActive)
            FillRoundRectHR(m_canvasFlyoutHighRes, bx + padS, itemY, bw - 2 * padS, itemH, 5 * m_supersampleFactor, ColorToARGB(m_themeColors.buttonActiveBackground, 255));
         else if(isHovered)
            FillRoundRectHR(m_canvasFlyoutHighRes, bx + padS, itemY, bw - 2 * padS, itemH, 5 * m_supersampleFactor, ColorToARGB(m_themeColors.flyoutItemHoverBackground, 255));
         //--- Active items get a small white dot on the right (the "selected" indicator)
         if(isActive)
            m_canvasFlyoutHighRes.FillCircle(bx + bw - m_flyoutPadding * m_supersampleFactor - 5 * m_supersampleFactor,
                                              itemY + itemH / 2, 3 * m_supersampleFactor, ColorToARGB(m_themeColors.flyoutTextActiveColor, 255));
        }
     }
   //--- Compose HR canvas down to the display canvas via supersample averaging
   DownsampleCanvas(m_canvasFlyout, m_canvasFlyoutHighRes, m_supersampleFactor);
   //--- Title strip divider line (separates the title from the items area)
   int dispBx = ptrLeft ? m_flyoutPointerHeight : 0;
   m_canvasFlyout.Line(dispBx + BorderWidth, titleH, dispBx + m_flyoutWidth - BorderWidth - 1, titleH, ColorToARGB(m_themeColors.flyoutBorder, 255));
   //--- Title text (category label in uppercase Arial Bold)
   string titleStr = m_categories[(int)cat].categoryLabel;
   StringToUpper(titleStr);
   m_canvasFlyout.FontSet("Arial Bold", FlyoutTitleSize);
   m_canvasFlyout.TextOut(dispBx + m_flyoutPadding + 4, 6, titleStr, ColorToARGB(m_themeColors.flyoutTitleColor, 255));
   //--- Tool-count badge on the right side of the title strip (only when category has more than 1 tool)
   if(nTools > 1)
     {
      string countStr = IntegerToString(nTools);
      m_canvasFlyout.FontSet("Arial", 15);
      int cw = m_canvasFlyout.TextWidth(countStr);
      m_canvasFlyout.TextOut(dispBx + m_flyoutWidth - m_flyoutPadding - cw - 4, 8, countStr, ColorToARGB(m_themeColors.flyoutTitleColor, 200));
     }
   //--- Render the item-row icons + labels via a temporary text canvas (for Y-clipping)
   CCanvas tmpText;
   tmpText.Create("FlyoutTmpText", m_canvasFlyout.Width(), m_canvasFlyout.Height(), COLOR_FORMAT_ARGB_NORMALIZE);
   tmpText.Erase(0x00000000);
   //--- Copy the item-area portion of the display canvas into the temp canvas (so highlights remain visible)
   for(int y = itemClipTop; y < itemClipBot && y < m_canvasFlyout.Height(); y++)
      for(int x = 0; x < m_canvasFlyout.Width(); x++)
         tmpText.PixelSet(x, y, m_canvasFlyout.PixelGet(x, y));
   //--- Walk every tool and render its icon + label into the temp canvas
   for(int t = 0; t < nTools; t++)
     {
      //--- Item Y position with the current scroll offset applied
      int itemY = titleH + m_flyoutPadding + t * m_flyoutItemHeight - m_flyoutScrollPixels;
      int itemH = m_flyoutItemHeight - 2;
      //--- Skip items entirely outside the item-area Y range
      if(itemY + itemH <= itemClipTop || itemY >= itemClipBot) continue;
      //--- Resolve active + hovered state for color selection
      bool isActive  = (activeTool == m_categories[(int)cat].tools[t].toolType);
      bool isHovered = (m_hoveredFlyoutItem == t && m_flyoutActiveCat == cat);
      //--- Icon + text color based on state (active > hovered > normal)
      color iconColor = isActive ? m_themeColors.flyoutTextActiveColor : (isHovered ? clrWhite : m_themeColors.buttonIconColor);
      color textColor = isActive ? m_themeColors.flyoutTextActiveColor : (isHovered ? clrWhite : m_themeColors.flyoutTextColor);

      //--- Icon rendering - prefer the custom canvas icon (crisp line-art); fall back to Wingdings glyph
      int iconBoxSize = FlyoutIconSize;
      int iconCx      = dispBx + m_flyoutPadding + 8 + iconBoxSize / 2;
      int iconCy      = itemY + itemH / 2;
      bool drewCanvasIcon = DrawToolIconOnCanvas(tmpText,
                              (int)m_categories[(int)cat].tools[t].toolType,
                              iconCx, iconCy, iconBoxSize, iconColor);
      //--- Fallback path: render the static Wingdings glyph if no custom canvas icon exists for this tool
      if(!drewCanvasIcon)
        {
         tmpText.FontSet(m_categories[(int)cat].tools[t].iconFontName, FlyoutIconSize);
         string sym = CharToString(m_categories[(int)cat].tools[t].iconCharCode);
         int ih = tmpText.TextHeight(sym);
         tmpText.TextOut(dispBx + m_flyoutPadding + 8, itemY + (itemH - ih) / 2, sym, ColorToARGB(iconColor, 255));
        }
      //--- Tool label text (right of the icon)
      tmpText.FontSet("Arial", FlyoutLabelSize);
      int lh = tmpText.TextHeight(m_categories[(int)cat].tools[t].toolLabel);
      tmpText.TextOut(dispBx + m_flyoutPadding + 34, itemY + (itemH - lh) / 2,
                      m_categories[(int)cat].tools[t].toolLabel, ColorToARGB(textColor, 255));
     }
   //--- Blit the temp text canvas back to the display canvas (clipped to the item-area Y range)
   for(int y = itemClipTop; y < itemClipBot && y < m_canvasFlyout.Height(); y++)
      for(int x = 0; x < m_canvasFlyout.Width(); x++)
         m_canvasFlyout.PixelSet(x, y, tmpText.PixelGet(x, y));
   //--- Free the temp text canvas
   tmpText.Destroy();
   //--- Draw the scroll pill overlay on top of everything (when scroll area is hovered or being dragged)
   DrawFlyoutScrollPillOverlay(cat);
   //--- Push the canvas update so the changes become visible on screen
   m_canvasFlyout.Update();
  }

//+------------------------------------------------------------------+
//| Show the flyout for the given category (compute pos + dispatch)  |
//+------------------------------------------------------------------+
void CFlyoutPanel::ShowFlyout(ENUM_CATEGORY cat, TOOL_TYPE activeTool)
  {
   //--- Action categories have no tool list, single live-count row, no header, no pointer triangle
   bool isAction = IsActionCategory(cat);
   int nTools = ArraySize(m_categories[(int)cat].tools);
   //--- Bail (hide) if the category has no tools and isn't an action category
   if(!isAction && nTools == 0) { HideFlyout(); return; }

   //--- Reset scroll offset for a fresh display
   m_flyoutScrollPixels = 0;

   //--- Geometry: action flyouts have no header (titleH=0) and single row; regular flyouts include header
   int titleH       = isAction ? 0 : 26;
   int visibleTools = isAction ? 1 : MathMin(nTools, m_flyoutMaxVisibleItems);
   int flyH         = titleH + m_flyoutPadding + visibleTools * m_flyoutItemHeight + m_flyoutPadding;
   int totalW       = m_flyoutWidth + m_flyoutPointerHeight;

   //--- Cache chart dimensions for the position-clamping logic
   int chartW = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
   int chartH = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
   //--- Decide pointer side + flyout X based on the sidebar's snap state
   bool ptrLeft; int flyX;
   if(m_snapState == SNAP_LEFT)
     { ptrLeft = true;  flyX = m_panelX + m_sidebarWidth; }
   else if(m_snapState == SNAP_RIGHT)
     { ptrLeft = false; flyX = m_panelX - totalW; }
   else
     {
      //--- Floating: prefer right-side placement; flip to left if it doesn't fit, with safety fallback
      int rightX = m_panelX + m_sidebarWidth;
      if(rightX + totalW <= chartW - 4) { ptrLeft = true; flyX = rightX; }
      else { ptrLeft = false; flyX = m_panelX - totalW; if(flyX < 0) { ptrLeft = true; flyX = rightX; } }
     }

   //--- Action flyout: pull the BODY into the sidebar so it visually overlaps by ~5 px (tab/extension feel)
   if(isAction)
     {
      const int OVERLAP_PX = 5;
      int shift = m_flyoutPointerHeight + OVERLAP_PX;
      flyX += ptrLeft ? -shift : +shift;
     }

   //--- Stash the pointer side (used by HitTestFlyoutItem + downstream drawing)
   m_flyoutPointerOnLeft = ptrLeft;
   //--- Anchor the flyout Y so the pointer triangle aligns with the category button's vertical center
   int btnCentreY = m_panelY + CalcCategoryButtonY((int)cat) + m_categoryButtonSize / 2;
   int flyY = btnCentreY - (titleH + m_flyoutPadding + 6);
   //--- Clamp the flyout Y so it stays fully inside the chart vertical bounds
   if(flyY + flyH > chartH - 8) flyY = chartH - flyH - 8;
   if(flyY < 4) flyY = 4;
   //--- Compute the pointer's local Y inside the flyout canvas (clamped to a safe range)
   m_flyoutPointerLocalY = MathMax(m_panelCornerRadius + m_flyoutPointerWidth + 2,
                           MathMin(flyH - m_panelCornerRadius - m_flyoutPointerWidth - 2, btnCentreY - flyY));
   //--- Sync the flyout chart-object's screen position
   ObjectSetInteger(0, m_nameFlyout, OBJPROP_XDISTANCE, flyX);
   ObjectSetInteger(0, m_nameFlyout, OBJPROP_YDISTANCE, flyY);
   //--- Mark visible + cache the active category, then render
   m_isFlyoutVisible = true;
   m_flyoutActiveCat = cat;
   DrawFlyoutForCategory(cat, activeTool);
   //--- Attach the flyout chart object to all timeframes so it's visible across chart switches
   ObjectSetInteger(0, m_nameFlyout, OBJPROP_TIMEFRAMES, OBJ_ALL_PERIODS);
  }

//+------------------------------------------------------------------+
//| CSidebarRenderer renders the sidebar buttons, icons, scroll pill |
//+------------------------------------------------------------------+
class CSidebarRenderer : public CFlyoutPanel
  {
protected:
   //--- Hover state for the sidebar's header strip + category column
   ENUM_CATEGORY m_hoveredCategory;
   bool          m_isCloseButtonHovered;
   bool          m_isThemeButtonHovered;
   bool          m_isGripAreaHovered;

protected:
   //--- Render the header strip background (close + grip + theme button rows) at high resolution
   void DrawHeaderStripHR(int canvasW, int canvasH);
   //--- Render a single category button background (active/hovered/idle) at high resolution
   void DrawCategoryButtonHR(CCanvas &target, int xHR, int yHR, int sizeHR, bool isActive, bool isHovered, bool hasDot);
   //--- Render category icons + sidebar control labels (close, grip dots, theme) onto the display canvas
   void DrawSidebarIconLabels(TOOL_TYPE activeTool);
   //--- Render the sidebar scroll thumb pill overlay on top of the display canvas
   void DrawSidebarScrollPillOverlay();
   //--- Top-level sidebar render pipeline (HR fill + header + buttons + downsample + icons + scroll pill)
   void DrawSidebar(TOOL_TYPE activeTool);
  };

//+------------------------------------------------------------------+
//| Render the header strip background at high resolution            |
//+------------------------------------------------------------------+
void CSidebarRenderer::DrawHeaderStripHR(int canvasW, int canvasH)
  {
   //--- Cache header dimensions + the supersampled border-width
   int headerH = m_headerGripHeight * m_supersampleFactor;
   int brd     = BorderWidth * m_supersampleFactor;
   //--- Inset X bounds: zero on the snapped side, border-width on the open side (so border doesn't double up)
   int inL = (m_snapState == SNAP_LEFT)  ? 0 : brd;
   int inR = (m_snapState == SNAP_RIGHT) ? 0 : brd;
   //--- Header rect (in HR pixels) and corner-radius adjusted for the border inset
   int hx = inL, hy = brd, hw = canvasW - inL - inR, hh = headerH - brd;
   int innerR = MathMax(0, m_panelCornerRadius * m_supersampleFactor - brd);
   //--- Round only the top corners on the open side (the snapped side has sharp corners)
   bool rTL = (m_snapState != SNAP_LEFT), rTR = (m_snapState != SNAP_RIGHT);
   //--- Theme-aware header fill color (darker than the body for visual separation)
   color hdrFill = m_isDarkTheme ? C'25,29,40' : C'245,247,252';
   //--- Top half of the header gets the selective rounded-rect fill
   FillSelectiveRoundRectHR(m_canvasSidebarHighRes, hx, hy, hw, hh, innerR, ColorToARGB(hdrFill, 255), rTL, rTR, false, false);
   //--- Bottom half (below the rounded-corner zone) gets a square fill to extend the strip down
   m_canvasSidebarHighRes.FillRectangle(hx, hy + hh / 2, hx + hw - 1, headerH - 1, ColorToARGB(hdrFill, 255));
   //--- Close-button hover highlight (top category-button-sized row of the header)
   if(m_isCloseButtonHovered)
      FillSelectiveRoundRectHR(m_canvasSidebarHighRes, inL, hy, canvasW - inL - inR,
         m_categoryButtonSize * m_supersampleFactor, innerR,
         ColorToARGB(m_themeColors.closeButtonHoverColor, 255), rTL, rTR, false, false);
   //--- Grip strip Y range (20 px high) sits below the close button
   int row2Y = m_categoryButtonSize * m_supersampleFactor, row2H = 20 * m_supersampleFactor;
   //--- Grip-area hover highlight (green tint)
   if(m_isGripAreaHovered)
      m_canvasSidebarHighRes.FillRectangle(inL, row2Y, canvasW - inR - 1, row2Y + row2H - 1,
         ColorToARGB(C'25,130,80', 255));
   //--- Theme-toggle row sits below the grip strip
   int row3Y = (m_categoryButtonSize + 20) * m_supersampleFactor;
   int row3H = (m_headerGripHeight - m_categoryButtonSize - 20) * m_supersampleFactor;
   //--- Theme-button hover highlight (purple tint)
   if(m_isThemeButtonHovered)
      m_canvasSidebarHighRes.FillRectangle(inL, row3Y, canvasW - inR - 1, row3Y + row3H - 1,
         ColorToARGB(C'110,60,200', 255));
   //--- Grip dots (3 small circles in a row) - brighter when grip strip is hovered
   uint dotColor = m_isGripAreaHovered
      ? ColorToARGB(clrWhite, 255)
      : ColorToARGB(m_themeColors.buttonIconColor, 255);
   //--- Compute the dot spacing + radius and walk 3 columns to render the dots
   int gapX = 6 * m_supersampleFactor, dotR = 2 * m_supersampleFactor;
   for(int col = 0; col < 3; col++)
      m_canvasSidebarHighRes.FillCircle(canvasW / 2 + (col - 1) * gapX, row2Y + row2H / 2, dotR, dotColor);
  }

//+------------------------------------------------------------------+
//| Render a single category button background at high resolution    |
//+------------------------------------------------------------------+
void CSidebarRenderer::DrawCategoryButtonHR(CCanvas &target, int xHR, int yHR, int sizeHR,
                                             bool isActive, bool isHovered, bool hasDot)
  {
   //--- Corner radius for the button background (HR scaled)
   int cornerHR = 6 * m_supersampleFactor;
   //--- Active state: filled background + accent bar on the snapped-side edge
   if(isActive)
     {
      FillRoundRectHR(target, xHR, yHR, sizeHR, sizeHR, cornerHR,
         ColorToARGB(m_themeColors.buttonActiveBackground, 255));
      //--- Accent bar (3 px wide) on the side opposite the sidebar's open edge
      int barW = 3 * m_supersampleFactor, barH = sizeHR / 2;
      int barX = (m_snapState == SNAP_RIGHT)
         ? xHR + sizeHR + m_supersampleFactor
         : xHR - barW - m_supersampleFactor;
      FillRoundRectHR(target, barX, yHR + sizeHR / 4, barW, barH, m_supersampleFactor,
         ColorToARGB(m_themeColors.accentBarColor, 255));
     }
   else if(isHovered)
     {
      //--- Hovered (but not active): filled hover-background rounded rect
      FillRoundRectHR(target, xHR, yHR, sizeHR, sizeHR, cornerHR,
         ColorToARGB(m_themeColors.buttonHoverBackground, 255));
     }
   //--- Multi-tool indicator: small dot in the bottom-right corner of the tile
   if(hasDot)
      target.FillCircle(
         xHR + sizeHR - 6 * m_supersampleFactor,
         yHR + sizeHR - 6 * m_supersampleFactor,
         2 * m_supersampleFactor,
         ColorToARGB(isActive ? m_themeColors.buttonIconActiveColor : m_themeColors.gripDotsColor, 180));
  }

//+------------------------------------------------------------------+
//| Render category icons + sidebar control labels on display canvas |
//+------------------------------------------------------------------+
void CSidebarRenderer::DrawSidebarIconLabels(TOOL_TYPE activeTool)
  {
   //--- Resolve which category is active (drives the active-icon color path)
   ENUM_CATEGORY activeCat = GetCategoryForActiveTool(activeTool);
   //--- Cache clip-region Y bounds for the scrolling overflow case
   int clipTop = CalcClipTop(), clipBot = CalcClipBottom();
   //--- Render all icons into a temp canvas first, then blit (with Y clipping when needed)
   CCanvas tmpIcons;
   tmpIcons.Create("SB_TmpIcons", m_sidebarWidth, m_sidebarHeight, COLOR_FORMAT_ARGB_NORMALIZE);
   tmpIcons.Erase(0x00000000);
   //--- Blit Y range = clip region when scroll-overflow exists, otherwise whole sidebar
   int blitY0 = (m_sidebarMaxVisibleCats < CAT_COUNT) ? clipTop : 0;
   int blitY1 = (m_sidebarMaxVisibleCats < CAT_COUNT) ? clipBot  : m_sidebarHeight;
   //--- Pre-fill the temp canvas from the display canvas (preserves the highlight backgrounds)
   for(int y = blitY0; y < blitY1 && y < m_sidebarHeight; y++)
      for(int x = 0; x < m_sidebarWidth; x++)
         tmpIcons.PixelSet(x, y, m_canvasSidebar.PixelGet(x, y));
   //--- Walk every category and render its icon at the tile center
   for(int c = 0; c < CAT_COUNT; c++)
     {
      if(!IsCategoryButtonVisible(c)) continue;
      //--- Cache tile coords + active state for color selection
      int btnY = CalcCategoryButtonY(c), btnX = (m_sidebarWidth - m_categoryButtonSize) / 2;
      bool isActive = (activeCat == (ENUM_CATEGORY)c);
      color iconColor = isActive ? m_themeColors.buttonIconActiveColor : m_themeColors.buttonIconColor;

      //--- Resolve which TOOL the tile should display - the last-used tool for this category
      TOOL_TYPE displayTool = GetCategoryDisplayToolType((ENUM_CATEGORY)c);

      //--- Tile center coords (where the icon glyph is centered)
      int tileCx = btnX + m_categoryButtonSize / 2;
      int tileCy = btnY + m_categoryButtonSize / 2;
      bool drewCanvasIcon = false;

      //--- Action categories take a custom trash-bin icon with destructive-action red color
      if(IsActionCategory((ENUM_CATEGORY)c))
        {
         //--- Brighter red on hover/active, standard "danger" red otherwise
         color actionIconColor = (isActive || m_hoveredCategory == (ENUM_CATEGORY)c)
                                  ? C'255,80,80'      // brighter red on hover/active
                                  : C'220,53,69';     // standard "danger" red
         drewCanvasIcon = DrawActionCategoryIconOnCanvas(tmpIcons,
                                                          (ENUM_CATEGORY)c,
                                                          tileCx, tileCy,
                                                          FlyoutIconSize,
                                                          actionIconColor);
        }
      else if(displayTool != TOOL_NONE)
        {
         //--- Regular tool category - render the same custom canvas icon the flyout uses (at FlyoutIconSize)
         drewCanvasIcon = DrawToolIconOnCanvas(tmpIcons, (int)displayTool,
                                                tileCx, tileCy,
                                                FlyoutIconSize, iconColor);
        }

      //--- Defensive fallback to the category's static Wingdings glyph (should never trigger for real tools)
      if(!drewCanvasIcon)
        {
         tmpIcons.FontSet(m_categories[c].iconFontName, CategoryIconSize);
         string sym = CharToString(m_categories[c].iconCharCode);
         int iw = tmpIcons.TextWidth(sym), ih = tmpIcons.TextHeight(sym);
         tmpIcons.TextOut(btnX + (m_categoryButtonSize - iw) / 2,
                          btnY + (m_categoryButtonSize - ih) / 2,
                          sym, ColorToARGB(iconColor, 255));
        }
     }
   //--- Blit the temp canvas back to the display canvas (with Y clipping when scroll-overflow)
   for(int y = blitY0; y < blitY1 && y < m_sidebarHeight; y++)
      for(int x = 0; x < m_sidebarWidth; x++)
         m_canvasSidebar.PixelSet(x, y, tmpIcons.PixelGet(x, y));
   //--- Free the temp canvas
   tmpIcons.Destroy();
   //--- Cache separator line X bounds (no inset on the snapped side)
   int brd  = BorderWidth;
   int sepL = (m_snapState == SNAP_LEFT)  ? 0              : brd;
   int sepR = m_sidebarWidth - 1 - ((m_snapState == SNAP_RIGHT) ? 0 : brd);
   //--- Two separator colors: bold for the header-to-body divider, light for the in-header dividers
   uint sepCol  = ColorToARGB(m_themeColors.separatorColor, 255);
   uint sepCol2 = ColorToARGB(m_isDarkTheme ? C'45,52,66' : C'195,202,215', 255);
   //--- 3 horizontal separator lines: header-to-body, close-to-grip, grip-to-theme
   m_canvasSidebar.Line(sepL, m_headerGripHeight - 1,    sepR, m_headerGripHeight - 1,    sepCol);
   m_canvasSidebar.Line(sepL, m_categoryButtonSize,      sepR, m_categoryButtonSize,      sepCol2);
   m_canvasSidebar.Line(sepL, m_categoryButtonSize + 20, sepR, m_categoryButtonSize + 20, sepCol2);

   //--- Group divider line above the CAT_DELETE tile (only when delete tile is currently visible)
   if(IsCategoryButtonVisible((int)CAT_DELETE))
     {
      //--- Center the divider line inside the combined (standard padding + action-extra) gap above the tile
      int delTileY = CalcCategoryButtonY((int)CAT_DELETE);
      int totalGapAbove = m_categoryButtonPadding + CalcActionCategoryExtraGap();
      int dividerY = delTileY - totalGapAbove / 2;
      //--- Clamp to viewport so the line doesn't bleed past the scroll top/bottom clip
      int clipT = CalcClipTop(), clipB = CalcClipBottom();
      if(dividerY > clipT && dividerY < clipB)
        {
         //--- Inset the line a bit from the sidebar edges so it reads as a centered group-divider
         int divInset = 8;
         int divL = sepL + divInset;
         int divR = sepR - divInset;
         m_canvasSidebar.Line(divL, dividerY, divR, dividerY, sepCol2);
        }
     }
   //--- Close button glyph (Webdings 'r' = X symbol) - white on hover, theme icon color otherwise
   color closeIconColor = m_isCloseButtonHovered ? clrWhite : m_themeColors.buttonIconColor;
   m_canvasSidebar.FontSet("Webdings", CategoryIconSize);
   string closeSym = CharToString((uchar)114);
   int clW = m_canvasSidebar.TextWidth(closeSym), clH = m_canvasSidebar.TextHeight(closeSym);
   m_canvasSidebar.TextOut((m_sidebarWidth - clW) / 2, (m_categoryButtonSize - clH) / 2,
                            closeSym, ColorToARGB(closeIconColor, 255));
   //--- Theme button glyph (Wingdings '[' = moon symbol) at the bottom of the header strip
   int row3Y = m_categoryButtonSize + 20, row3H = m_headerGripHeight - m_categoryButtonSize - 20;
   color themeIconColor = m_isThemeButtonHovered ? clrWhite : m_themeColors.buttonIconColor;
   m_canvasSidebar.FontSet("Wingdings", CategoryIconSize);
   string themeSym = CharToString((uchar)91);
   int thW = m_canvasSidebar.TextWidth(themeSym), thH = m_canvasSidebar.TextHeight(themeSym);
   m_canvasSidebar.TextOut((m_sidebarWidth - thW) / 2, row3Y + (row3H - thH) / 2,
                            themeSym, ColorToARGB(themeIconColor, 255));
   //--- Bottom-edge resize hint - thin colored bar when hovered or being dragged
   if(m_isBottomResizeHovered || m_isResizingBottomEdge)
     {
      int stripH = 3, gripY = m_sidebarHeight - stripH - 1;
      //--- Accent color when actively dragging, hover color otherwise
      color barC = m_isResizingBottomEdge ? m_themeColors.accentBarColor : m_themeColors.scrollArrowHoverColor;
      m_canvasSidebar.FillRectangle(8, gripY, m_sidebarWidth - 9, gripY + stripH - 1,
         ColorToARGB(barC, 210));
     }
  }

//+------------------------------------------------------------------+
//| Render the sidebar scroll thumb pill overlay onto display canvas |
//+------------------------------------------------------------------+
void CSidebarRenderer::DrawSidebarScrollPillOverlay()
  {
   //--- Bail when there's no scroll overflow OR when the scroll area isn't being hovered/dragged
   if(CalcSidebarMaxScrollPixels() <= 0 ||
       (!m_isHoveredSidebarScrollArea && !m_isSidebarThumbDragging)) return;
   //--- Cache track geometry and recompute the thumb height proportionally
   int trackY = CalcClipTop(), trackH = CalcSidebarViewportPixels();
   m_sidebarScrollThumbHeight = MathMax(20, (int)(trackH * (double)trackH / CalcSidebarTotalScrollPixels()));
   //--- Compute the thumb's Y position from the current scroll fraction
   int maxPx = CalcSidebarMaxScrollPixels();
   double pos    = (maxPx > 0) ? (double)m_sidebarScrollPixels / maxPx : 0.0;
   int    thumbY = trackY + (int)(pos * (trackH - m_sidebarScrollThumbHeight));
   //--- Thin-track X position: left edge when sidebar is snapped right, right edge otherwise
   int tw    = m_sidebarScrollThinWidth;
   int thinX = (m_snapState == SNAP_RIGHT) ? 2 : m_sidebarWidth - tw - 2;
   //--- Pill color + alpha vary by interaction state (dragging > hovered > idle)
   color pillColor; uchar pillAlpha;
   if(m_isSidebarThumbDragging)     { pillColor = m_themeColors.accentBarColor;        pillAlpha = 255; }
   else if(m_isHoveredSidebarThumb) { pillColor = m_themeColors.scrollArrowHoverColor; pillAlpha = 255; }
   else                              { pillColor = m_themeColors.scrollArrowColor;      pillAlpha = 180; }
   uint thumbARGB = ColorToARGB(pillColor, pillAlpha);
   //--- Build the pill at high resolution (capsule rounded-rect)
   int pws = tw * m_supersampleFactor, phs = m_sidebarScrollThumbHeight * m_supersampleFactor;
   CCanvas pillHR;
   pillHR.Create("SB_PillHR_tmp", pws, phs, COLOR_FORMAT_ARGB_NORMALIZE);
   pillHR.Erase(0x00000000);
   FillRoundRectHR(pillHR, 0, 0, pws, phs, MathMax(1, pws / 2), thumbARGB);
   //--- Downsample the HR pill manually onto the display canvas (SSxSS block averaging)
   int ss2 = m_supersampleFactor * m_supersampleFactor;
   //--- Walk every output pixel
   for(int py = 0; py < m_sidebarScrollThumbHeight; py++)
      for(int px = 0; px < tw; px++)
        {
         //--- Accumulators for the SSxSS block averaging
         double sumA = 0, sumR = 0, sumG = 0, sumB = 0, wc = 0;
         //--- Walk the SSxSS source block
         for(int dy = 0; dy < m_supersampleFactor; dy++)
            for(int dx = 0; dx < m_supersampleFactor; dx++)
              {
               //--- Compute the source coords and skip out-of-bounds samples
               int sx = px * m_supersampleFactor + dx, sy = py * m_supersampleFactor + dy;
               if(sx >= pws || sy >= phs) continue;
               //--- Read the source pixel; accumulate alpha always, RGB only for non-transparent samples
               uint p = pillHR.PixelGet(sx, sy); uchar pa = (uchar)((p >> 24) & 0xFF);
               sumA += pa;
               if(pa > 0) { sumR += (p >> 16) & 0xFF; sumG += (p >> 8) & 0xFF; sumB += p & 0xFF; wc += 1.0; }
              }
         //--- Final alpha is the simple block average
         uchar fa = (uchar)(sumA / ss2);
         //--- Skip fully-transparent or fully-empty pixels; otherwise blend onto the display canvas
         if(fa > 0 && wc > 0)
            BlendPixelSet(m_canvasSidebar, thinX + px, thumbY + py,
               ((uint)fa << 24) | ((uint)(uchar)(sumR / wc) << 16) |
               ((uint)(uchar)(sumG / wc) << 8) | (uint)(uchar)(sumB / wc));
        }
   //--- Free the temporary HR pill canvas
   pillHR.Destroy();
  }

//+------------------------------------------------------------------+
//| Top-level sidebar render pipeline (HR fill + buttons + composite)|
//+------------------------------------------------------------------+
void CSidebarRenderer::DrawSidebar(TOOL_TYPE activeTool)
  {
   //--- When scroll overflow exists, recompute the thumb height proportionally to viewport/total
   if(CalcSidebarMaxScrollPixels() > 0)
     {
      int trackH = CalcSidebarViewportPixels();
      m_sidebarScrollThumbHeight = MathMax(20, (int)(trackH * (double)trackH / CalcSidebarTotalScrollPixels()));
     }
   //--- HR canvas dimensions (supersampleFactor x larger than display canvas)
   int ws = m_sidebarWidth * m_supersampleFactor, hs = m_sidebarHeight * m_supersampleFactor;
   //--- Resize HR canvas if dimensions changed; then clear it for a fresh render
   if(m_canvasSidebarHighRes.Width() != ws || m_canvasSidebarHighRes.Height() != hs)
      m_canvasSidebarHighRes.Resize(ws, hs);
   m_canvasSidebarHighRes.Erase(0x00000000);
   //--- Background fill with rounded corners only on the open side (snapped side has sharp corners)
   uchar bgA = (uchar)(255 * BackgroundOpacity);
   bool rTL = (m_snapState != SNAP_LEFT), rBL = rTL;
   bool rTR = (m_snapState != SNAP_RIGHT), rBR = rTR;
   FillSelectiveRoundRectHR(m_canvasSidebarHighRes, 0, 0, ws, hs,
      m_panelCornerRadius * m_supersampleFactor,
      ColorToARGB(m_themeColors.sidebarBackground, bgA), rTL, rTR, rBL, rBR);
   //--- Snapped-side edge highlight: 1 px line in the chart's foreground color
   if(m_snapState == SNAP_LEFT)
      m_canvasSidebarHighRes.FillRectangle(0, 0, m_supersampleFactor - 1, hs - 1,
         ColorToARGB((color)ChartGetInteger(0, CHART_COLOR_FOREGROUND), 255));
   else if(m_snapState == SNAP_RIGHT)
      m_canvasSidebarHighRes.FillRectangle(ws - m_supersampleFactor, 0, ws - 1, hs - 1,
         ColorToARGB((color)ChartGetInteger(0, CHART_COLOR_FOREGROUND), 255));
   //--- Render the header strip (close + grip + theme button rows) onto the HR canvas
   DrawHeaderStripHR(ws, hs);
   //--- Resolve which category is currently active (drives the active-button rendering)
   ENUM_CATEGORY activeCat = GetCategoryForActiveTool(activeTool);
   //--- Render category buttons - take the scroll-clip path when overflow exists
   if(m_sidebarMaxVisibleCats < CAT_COUNT)
     {
      //--- Overflow case: render all visible buttons into a temp HR canvas, then clip-blit
      CCanvas tmpHR;
      tmpHR.Create("SB_TmpHR", ws, hs, COLOR_FORMAT_ARGB_NORMALIZE);
      tmpHR.Erase(0x00000000);
      //--- Walk every visible category and render its button background
      for(int c = 0; c < CAT_COUNT; c++)
        {
         if(!IsCategoryButtonVisible(c)) continue;
         DrawCategoryButtonHR(tmpHR,
            (m_sidebarWidth - m_categoryButtonSize) / 2 * m_supersampleFactor,
            CalcCategoryButtonY(c) * m_supersampleFactor,
            m_categoryButtonSize * m_supersampleFactor,
            activeCat == (ENUM_CATEGORY)c,
            m_hoveredCategory == (ENUM_CATEGORY)c,
            ArraySize(m_categories[c].tools) > 1);
        }
      //--- Blit the temp canvas onto the main HR canvas, clipped to the scroll Y range
      int clipTop = CalcClipTop() * m_supersampleFactor, clipBot = CalcClipBottom() * m_supersampleFactor;
      for(int y = clipTop; y < clipBot && y < hs; y++)
         for(int x = 0; x < ws; x++)
           {
            uint px = tmpHR.PixelGet(x, y);
            if(((px >> 24) & 0xFF) > 0) BlendPixelSet(m_canvasSidebarHighRes, x, y, px);
           }
      //--- Free the temp HR canvas
      tmpHR.Destroy();
     }
   else
     {
      //--- Non-overflow case: render all category buttons directly to the main HR canvas
      for(int c = 0; c < CAT_COUNT; c++)
         DrawCategoryButtonHR(m_canvasSidebarHighRes,
            (m_sidebarWidth - m_categoryButtonSize) / 2 * m_supersampleFactor,
            CalcCategoryButtonY(c) * m_supersampleFactor,
            m_categoryButtonSize * m_supersampleFactor,
            activeCat == (ENUM_CATEGORY)c,
            m_hoveredCategory == (ENUM_CATEGORY)c,
            ArraySize(m_categories[c].tools) > 1);
     }
   //--- Outer border around the rounded-rect panel (HR scaled)
   if(BorderWidth > 0)
      DrawSelectiveRoundRectBorderHR(m_canvasSidebarHighRes, 0, 0, ws, hs,
         m_panelCornerRadius * m_supersampleFactor,
         ColorToARGB(m_themeColors.sidebarBorder, 255),
         BorderWidth * m_supersampleFactor, rTL, rTR, rBL, rBR);
   //--- Compose HR canvas down to the display canvas via supersample averaging
   DownsampleCanvas(m_canvasSidebar, m_canvasSidebarHighRes, m_supersampleFactor);
   //--- Render the category icons + control labels + scroll thumb pill on top of the composited image
   DrawSidebarIconLabels(activeTool);
   DrawSidebarScrollPillOverlay();
   //--- Push the canvas update so the changes become visible on screen
   m_canvasSidebar.Update();
  }

#endif // TOOLS_PALETTE_SIDEBAR_MQH
//+------------------------------------------------------------------+