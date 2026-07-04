//+------------------------------------------------------------------+
//|                                           ToolsPalette_Lines.mqh |
//|                           Copyright 2026, Allan Munene Mutiiria. |
//|                                   https://t.me/Forex_Algo_Trader |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Allan Munene Mutiiria."
#property link "https://t.me/Forex_Algo_Trader"
#property version "1.00"
#property strict

//--- Guard against multiple inclusion of this header
#ifndef TOOLS_PALETTE_LINES_MQH
#define TOOLS_PALETTE_LINES_MQH

//--- Pull in CCrosshairManager (the parent class in the tool chain)
#include "ToolsPalette_Crosshair.mqh"

//+------------------------------------------------------------------+
//| CLineTools owns line drawing, hit-tests, and generic UI helpers  |
//+------------------------------------------------------------------+
class CLineTools : public CCrosshairManager
  {
protected:
   //--- Handle display state (set by CDrawingEngine before each per-tool draw call)
   int    m_currentObjIsActive;
   //--- When >= 0, the draw routines skip rendering this handle index
   int    m_hideHandleIdx;
   //--- When >= 0, the draw routines render a hover halo around this handle index
   int    m_haloHandleIdx;

   //--- Cached info-panel rect from the last DrawInfoLineOn call (sentinels = no panel)
   int    m_lastInfoPanelX1;
   int    m_lastInfoPanelY1;
   int    m_lastInfoPanelX2;
   int    m_lastInfoPanelY2;

   //--- Generic anchor-point handle primitive used by every line/shape tool
   void   DrawHandleOnCanvas(CCanvas &canvas, int x, int y, bool selected,
                             color objColor, bool showHalo = false);

   //--- Extend a line segment to the canvas edges (used by Ray and Extended Line)
   void   ExtendLineToEdges(int canvasW, int canvasH, int x1, int y1, int x2, int y2,
                            int &ox1, int &oy1, int &ox2, int &oy2,
                            bool leftExtend, bool rightExtend);
   //--- Distance from a point to a finite line segment (used by hit-test routines)
   double PointToSegmentDistance(int mx, int my, int x1, int y1, int x2, int y2);

   //--- Per-line-tool canvas draw routines (canvas + stroke params explicit)
   void   DrawTrendLineOn(CCanvas &canvas, int x1, int y1, int x2, int y2,
                          color objColor, bool selected, bool hovered,
                          int lineWidth = 2, int lineOpacity = 100,
                          int lineStyle = 0);
   void   DrawHorizontalLineOn(CCanvas &canvas, int y,
                               color objColor, bool selected, bool hovered,
                               int lineWidth = 2, int lineOpacity = 100,
                               int lineStyle = 0);
   void   DrawVerticalLineOn(CCanvas &canvas, int x,
                             color objColor, bool selected, bool hovered,
                             int lineWidth = 2, int lineOpacity = 100,
                             int lineStyle = 0);
   //--- Cross line: full-canvas H + V meeting at the intersection with a single handle
   void   DrawCrossLineOn(CCanvas &canvas, int cx, int cy,
                          color objColor, bool selected, bool hovered,
                          int lineWidth = 2, int lineOpacity = 100,
                          int lineStyle = 0);
   void   DrawRayLineOn(CCanvas &canvas, int x1, int y1, int x2, int y2,
                        color objColor, bool selected, bool hovered,
                        int lineWidth = 2, int lineOpacity = 100,
                        int lineStyle = 0);
   void   DrawExtendedLineOn(CCanvas &canvas, int x1, int y1, int x2, int y2,
                             color objColor, bool selected, bool hovered,
                             int lineWidth = 2, int lineOpacity = 100,
                             int lineStyle = 0);
   void   DrawInfoLineOn(CCanvas &canvas, int x1, int y1, int x2, int y2,
                         color objColor, datetime t1, datetime t2,
                         double p1, double p2,
                         bool selected, bool hovered, bool isDarkTheme,
                         int lineWidth = 2, int lineOpacity = 100,
                         int lineStyle = 0);
   void   DrawTrendAngleOn(CCanvas &canvas, int x1, int y1, int x2, int y2,
                           color objColor, bool selected, bool hovered, bool isDarkTheme,
                           int lineWidth = 2, int lineOpacity = 100,
                           int lineStyle = 0);

   //--- Per-line-tool hit-test routines (caller-supplied threshold)
   bool   HitTestTrendLine(int mx, int my, int x1, int y1, int x2, int y2, int threshold);
   bool   HitTestHorizontalLine(int mx, int my, int y, int threshold);
   bool   HitTestVerticalLine(int mx, int my, int x, int threshold);
   //--- Test mouse against the last-drawn info panel for hover continuity
   bool   HitTestInfoLinePanel(int mx, int my);

   //--- "+ Add text" prompt rendered rotated along the line; writes back AABB and rotated corners
   void   DrawAddTextPromptOn(CCanvas &canvas, int x1, int y1, int x2, int y2,
                              color lineColor,
                              bool isDarkTheme,
                              int &promptX1, int &promptY1, int &promptX2, int &promptY2,
                              int &cornerX[], int &cornerY[],
                              bool centerOnLine = false);
   bool   HitTestAddTextPrompt(int mx, int my,
                                int promptX1, int promptY1, int promptX2, int promptY2);

   //--- Canvas-rendered tool icon dispatch (returns false to fall back to Wingdings glyph)
   bool   DrawToolIconOnCanvas(CCanvas &canvas, int toolType, int cx, int cy,
                                int size, color iconColor);
  };

//+------------------------------------------------------------------+
//| Draw an anti-aliased circle handle (optional hover halo first)   |
//+------------------------------------------------------------------+
void CLineTools::DrawHandleOnCanvas(CCanvas &canvas, int x, int y, bool selected,
                                     color objColor, bool showHalo)
  {
   //--- Handle size stays constant; selected thickens border to 2px (color is uniform DodgerBlue)
   int    radius   = 7;
   int    borderPx = selected ? 2 : 1;
   double outerR   = (double)radius;
   double innerR   = outerR - (double)borderPx;
   //--- Border color is uniform across all drawing tools (uniform UI element)
   color  handleBorderColor = clrDodgerBlue;
   uint   fillARGB = ColorToARGB(clrWhite, 255);
   uint   bordARGB = ColorToARGB(handleBorderColor, 255);
   //--- Cache canvas bounds and supersampling constants for the AA passes
   int    cW = canvas.Width(), cH = canvas.Height();
   int    sub = 4; double step = 1.0 / sub; int subSq = sub * sub;
   //--- Pass 0 (optional): hover halo at ~2x radius and 27% alpha around the handle
   if(showHalo)
     {
      //--- Halo radius slightly smaller than 2x for a subtle glow effect
      double haloR = outerR * 2.0 - 2.0;
      //--- Extract RGB channels of the halo color
      uchar  haloR_ = (uchar)((handleBorderColor)       & 0xFF);
      uchar  haloG_ = (uchar)((handleBorderColor >> 8)  & 0xFF);
      uchar  haloB_ = (uchar)((handleBorderColor >> 16) & 0xFF);
      int    hRint  = (int)(haloR + 1);
      //--- Iterate every pixel in the halo's bounding box
      for(int dy = -hRint; dy <= hRint; dy++)
        {
         for(int dx = -hRint; dx <= hRint; dx++)
           {
            //--- Skip out-of-canvas pixels
            int px = x + dx, py = y + dy;
            if(px < 0 || px >= cW || py < 0 || py >= cH) continue;
            //--- Supersample each pixel for smooth halo coverage
            int inHalo = 0;
            for(int sy = 0; sy < sub; sy++)
               for(int sx = 0; sx < sub; sx++)
                 {
                  //--- Subpixel offset for AA sample
                  double sdx = dx - 0.5 + (sx + 0.5) * step;
                  double sdy = dy - 0.5 + (sy + 0.5) * step;
                  //--- Inside-halo test (disc equation)
                  if(sdx*sdx + sdy*sdy <= haloR*haloR) inHalo++;
                 }
            //--- Blend halo pixel at coverage-weighted alpha
            if(inHalo > 0)
              {
               //--- Base alpha 70 (~27%) scaled by subpixel coverage
               uint a = (uint)(70 * inHalo / subSq);
               if(a > 0)
                 {
                  uint haloPixel = (a << 24) | ((uint)haloR_ << 16) | ((uint)haloG_ << 8) | (uint)haloB_;
                  BlendPixelSet(canvas, px, py, haloPixel);
                 }
              }
           }
        }
     }
   //--- Pass 1: fill the handle interior with white at full opacity (AA composite)
   for(int dy = -(radius+1); dy <= radius+1; dy++)
      for(int dx = -(radius+1); dx <= radius+1; dx++)
        {
         //--- Skip out-of-canvas pixels
         int px = x + dx, py = y + dy;
         if(px < 0 || px >= cW || py < 0 || py >= cH) continue;
         //--- Supersample each pixel to determine inside-fill coverage
         int inFill = 0;
         for(int sy = 0; sy < sub; sy++)
            for(int sx = 0; sx < sub; sx++)
              {
               double sdx = dx - 0.5 + (sx + 0.5) * step;
               double sdy = dy - 0.5 + (sy + 0.5) * step;
               //--- Inside-inner-circle test (the fill region)
               if(sdx*sdx + sdy*sdy <= innerR*innerR) inFill++;
              }
         //--- Blend fill pixel at coverage-weighted alpha
         if(inFill > 0)
            BlendPixelSet(canvas, px, py,
               (((uint)(uchar)(255 * inFill / subSq)) << 24) | (fillARGB & 0x00FFFFFF));
        }
   //--- Pass 2: draw the border ring on top of the fill (annulus between inner and outer radii)
   for(int dy = -(radius+1); dy <= radius+1; dy++)
      for(int dx = -(radius+1); dx <= radius+1; dx++)
        {
         //--- Skip out-of-canvas pixels
         int px = x + dx, py = y + dy;
         if(px < 0 || px >= cW || py < 0 || py >= cH) continue;
         //--- Supersample each pixel to determine inside-border-annulus coverage
         int inBord = 0;
         for(int sy = 0; sy < sub; sy++)
            for(int sx = 0; sx < sub; sx++)
              {
               double sdx = dx - 0.5 + (sx + 0.5) * step;
               double sdy = dy - 0.5 + (sy + 0.5) * step;
               double sd  = sdx*sdx + sdy*sdy;
               //--- Inside annulus = outside innerR AND inside outerR
               if(sd > innerR*innerR && sd <= outerR*outerR) inBord++;
              }
         //--- Blend border pixel at coverage-weighted alpha
         if(inBord > 0)
            BlendPixelSet(canvas, px, py,
               (((uint)(uchar)(255 * inBord / subSq)) << 24) | (bordARGB & 0x00FFFFFF));
        }
  }

//+------------------------------------------------------------------+
//| Render a canvas-drawn tool icon centered in a size x size box    |
//+------------------------------------------------------------------+
bool CLineTools::DrawToolIconOnCanvas(CCanvas &canvas, int toolType, int cx, int cy,
                                       int size, color iconColor)
  {
   //--- Compose the icon color into ARGB at full opacity
   uint argb = ColorToARGB(iconColor, 255);
   //--- Cache canvas bounds for the ICON_AA_PLOT macro
   int  cW   = canvas.Width();
   int  cH   = canvas.Height();
   //--- Inset the icon by 3 pixels on all sides so it doesn't touch the box edge
   int inset = 3;
   int half  = size / 2;
   //--- Left, Right, Top, Bottom of the icon's drawing area
   int L     = cx - half + inset;
   int R     = cx + half - inset;
   int T     = cy - half + inset;
   int B     = cy + half - inset;

   //--- ICON_AA_PLOT: place one anti-aliased pixel via Porter-Duff source-over compositing
   #define ICON_AA_PLOT(xx, yy, cov) \
   { \
      int _px = (xx), _py = (yy); \
      double _c = (cov); \
      if(_c > 0.01 && _px >= 0 && _px < cW && _py >= 0 && _py < cH) { \
         uchar _a = (uchar)(255.0 * _c); \
         if(_a > 0) { \
            uint _ex = canvas.PixelGet(_px, _py); \
            double _sA = _a / 255.0; \
            double _dA = ((_ex >> 24) & 0xFF) / 255.0; \
            double _oA = _sA + _dA * (1.0 - _sA); \
            if(_oA > 0.0) { \
               double _sR = ((argb >> 16) & 0xFF) / 255.0; \
               double _sG = ((argb >>  8) & 0xFF) / 255.0; \
               double _sB = ( argb        & 0xFF) / 255.0; \
               double _dR = ((_ex >> 16) & 0xFF) / 255.0; \
               double _dG = ((_ex >>  8) & 0xFF) / 255.0; \
               double _dB = ( _ex        & 0xFF) / 255.0; \
               uint _ob = ((uint)(uchar)(_oA * 255.0 + 0.5) << 24) | \
                          ((uint)(uchar)((_sR*_sA + _dR*_dA*(1.0-_sA)) / _oA * 255.0 + 0.5) << 16) | \
                          ((uint)(uchar)((_sG*_sA + _dG*_dA*(1.0-_sA)) / _oA * 255.0 + 0.5) <<  8) | \
                           (uint)(uchar)((_sB*_sA + _dB*_dA*(1.0-_sA)) / _oA * 255.0 + 0.5); \
               canvas.PixelSet(_px, _py, _ob); \
            } \
         } \
      } \
   }

   //--- ICON_LINE: Xiaolin Wu's anti-aliased line algorithm between two endpoints
   #define ICON_LINE(x0, y0, x1_, y1_) \
   { \
      double _x0 = (double)(x0), _y0 = (double)(y0); \
      double _x1 = (double)(x1_), _y1 = (double)(y1_); \
      double _dxL = _x1 - _x0, _dyL = _y1 - _y0; \
      bool _steep = MathAbs(_dyL) > MathAbs(_dxL); \
      if(_steep) { \
         if(_y0 > _y1) { double _t; _t = _x0; _x0 = _x1; _x1 = _t; _t = _y0; _y0 = _y1; _y1 = _t; } \
         double _grad = (_y1 == _y0) ? 0.0 : (_x1 - _x0) / (_y1 - _y0); \
         int _iy0 = (int)MathRound(_y0), _iy1 = (int)MathRound(_y1); \
         double _xf = _x0 + _grad * (_iy0 - _y0); \
         for(int _iy = _iy0; _iy <= _iy1; _iy++) { \
            int _ix = (int)MathFloor(_xf); \
            double _frac = _xf - _ix; \
            ICON_AA_PLOT(_ix,     _iy, 1.0 - _frac); \
            ICON_AA_PLOT(_ix + 1, _iy, _frac); \
            _xf += _grad; \
         } \
      } else { \
         if(_x0 > _x1) { double _t; _t = _x0; _x0 = _x1; _x1 = _t; _t = _y0; _y0 = _y1; _y1 = _t; } \
         double _grad = (_x1 == _x0) ? 0.0 : (_y1 - _y0) / (_x1 - _x0); \
         int _ix0 = (int)MathRound(_x0), _ix1 = (int)MathRound(_x1); \
         double _yf = _y0 + _grad * (_ix0 - _x0); \
         for(int _ix = _ix0; _ix <= _ix1; _ix++) { \
            int _iy = (int)MathFloor(_yf); \
            double _frac = _yf - _iy; \
            ICON_AA_PLOT(_ix, _iy,     1.0 - _frac); \
            ICON_AA_PLOT(_ix, _iy + 1, _frac); \
            _yf += _grad; \
         } \
      } \
   }

   //--- ICON_PIXEL_F: place one AA pixel at floating-point coords via 4-pixel bilinear coverage
   #define ICON_PIXEL_F(fx, fy) \
   { \
      double _fx = (fx), _fy = (fy); \
      int _ix0 = (int)MathFloor(_fx), _iy0 = (int)MathFloor(_fy); \
      double _dx = _fx - _ix0, _dy = _fy - _iy0; \
      ICON_AA_PLOT(_ix0,     _iy0,     (1.0 - _dx) * (1.0 - _dy)); \
      ICON_AA_PLOT(_ix0 + 1, _iy0,     _dx         * (1.0 - _dy)); \
      ICON_AA_PLOT(_ix0,     _iy0 + 1, (1.0 - _dx) * _dy);         \
      ICON_AA_PLOT(_ix0 + 1, _iy0 + 1, _dx         * _dy);         \
   }

   //--- ICON_HANDLE: render the small filled ring marking an anchor point in the icon
   #define ICON_HANDLE(dx, dy) \
   { \
      canvas.CircleWu((dx), (dy), 2.0, argb); \
   }

   //--- ICON_LINE_BETWEEN: draw an icon line shortened on BOTH ends to avoid overlapping handle rings
   #define ICON_LINE_BETWEEN(x0, y0, x1_, y1_) \
   { \
      double _dxf = (double)(x1_) - (double)(x0); \
      double _dyf = (double)(y1_) - (double)(y0); \
      double _lenF = MathSqrt(_dxf*_dxf + _dyf*_dyf); \
      if(_lenF > 4.5) { \
         double _ringR = 2.0; \
         double _ux = _dxf / _lenF, _uy = _dyf / _lenF; \
         double _ax = (double)(x0) + _ux * _ringR; \
         double _ay = (double)(y0) + _uy * _ringR; \
         double _bx = (double)(x1_) - _ux * _ringR; \
         double _by = (double)(y1_) - _uy * _ringR; \
         ICON_LINE(_ax, _ay, _bx, _by); \
      } \
   }

   //--- ICON_LINE_FROM_HANDLE: draw an icon line shortened on the START end only (ray-style)
   #define ICON_LINE_FROM_HANDLE(x0, y0, x1_, y1_) \
   { \
      double _dxf = (double)(x1_) - (double)(x0); \
      double _dyf = (double)(y1_) - (double)(y0); \
      double _lenF = MathSqrt(_dxf*_dxf + _dyf*_dyf); \
      if(_lenF > 2.5) { \
         double _ringR = 2.0; \
         double _ux = _dxf / _lenF, _uy = _dyf / _lenF; \
         double _ax = (double)(x0) + _ux * _ringR; \
         double _ay = (double)(y0) + _uy * _ringR; \
         ICON_LINE(_ax, _ay, (double)(x1_), (double)(y1_)); \
      } \
   }

   //--- Per-tool dispatch; handled=true means a custom canvas icon was rendered
   bool handled = false;
   switch(toolType)
     {
      case 3:  // TOOL_TRENDLINE
        {
         //--- Diagonal line from BL to TR with handles at both endpoints
         int p1x = L, p1y = B;
         int p2x = R, p2y = T;
         ICON_LINE_BETWEEN(p1x, p1y, p2x, p2y);
         ICON_HANDLE(p1x, p1y);
         ICON_HANDLE(p2x, p2y);
         handled = true; break;
        }
      case 4:  // TOOL_HLINE
        {
         //--- Full-width horizontal line at the vertical center with handles at both ends
         int lineY = cy;
         ICON_LINE_BETWEEN(L, lineY, R, lineY);
         ICON_HANDLE(L, lineY);
         ICON_HANDLE(R, lineY);
         handled = true; break;
        }
      case 5:  // TOOL_VLINE
        {
         //--- Full-height vertical line with handle at center (line gaps around the handle)
         int lineX = cx;
         int ringR = 3;
         ICON_LINE(lineX, T,          lineX, cy - ringR);
         ICON_LINE(lineX, cy + ringR, lineX, B);
         ICON_HANDLE(lineX, cy);
         handled = true; break;
        }
      case 6:  // TOOL_RAY
        {
         //--- Diagonal ray from handle at BL, extending up-right with an arrowhead at the tip
         int p1x = L, p1y = B;
         int p2x = R, p2y = T;
         ICON_LINE_FROM_HANDLE(p1x, p1y, p2x, p2y);
         ICON_HANDLE(p1x, p1y);
         //--- Arrowhead at the ray's tip (compute unit vector and perpendicular wings)
         double dxf = p2x - p1x, dyf = p2y - p1y;
         double lenf = MathSqrt(dxf*dxf + dyf*dyf);
         if(lenf > 0.001) {
            //--- Unit direction and perpendicular for arrowhead wings
            double ux = dxf/lenf, uy = dyf/lenf;
            double nx = -uy,      ny = ux;
            double ahLen  = 3.5;
            double ahWide = 2.0;
            //--- Compute the two wing endpoints on either side of the shaft direction
            double w1x = p2x - ux*ahLen + nx*ahWide;
            double w1y = p2y - uy*ahLen + ny*ahWide;
            double w2x = p2x - ux*ahLen - nx*ahWide;
            double w2y = p2y - uy*ahLen - ny*ahWide;
            ICON_LINE(p2x, p2y, w1x, w1y);
            ICON_LINE(p2x, p2y, w2x, w2y);
         }
         handled = true; break;
        }
      case 7:  // TOOL_EXTENDED_LINE
        {
         //--- Diagonal line between two handles with short dash continuations past each endpoint
         int p1x = L + 2, p1y = B - 2;
         int p2x = R - 2, p2y = T + 2;
         ICON_LINE_BETWEEN(p1x, p1y, p2x, p2y);
         ICON_HANDLE(p1x, p1y);
         ICON_HANDLE(p2x, p2y);
         //--- Compute unit direction for the extension dashes past each end
         double dxf = p2x - p1x, dyf = p2y - p1y;
         double lenf = MathSqrt(dxf*dxf + dyf*dyf);
         if(lenf > 0.001) {
            //--- Unit vector along the line
            double ux = dxf/lenf, uy = dyf/lenf;
            //--- Short dash past P1
            double d1ax = p1x - ux*3.5, d1ay = p1y - uy*3.5;
            double d1bx = p1x - ux*5.5, d1by = p1y - uy*5.5;
            ICON_LINE(d1ax, d1ay, d1bx, d1by);
            //--- Short dash past P2
            double d2ax = p2x + ux*3.5, d2ay = p2y + uy*3.5;
            double d2bx = p2x + ux*5.5, d2by = p2y + uy*5.5;
            ICON_LINE(d2ax, d2ay, d2bx, d2by);
         }
         handled = true; break;
        }
      case 8:  // TOOL_INFO_LINE
        {
         //--- Short diagonal line plus a small floating info-panel rectangle to its right
         int p1x = L,     p1y = B;
         int p2x = L + 7, p2y = T;
         ICON_LINE_BETWEEN(p1x, p1y, p2x, p2y);
         ICON_HANDLE(p1x, p1y);
         ICON_HANDLE(p2x, p2y);
         //--- Compute the perpendicular anchor for the floating panel
         double midX = (p1x + p2x) / 2.0;
         double midY = (p1y + p2y) / 2.0;
         double dxf = p2x - p1x, dyf = p2y - p1y;
         double lenf = MathSqrt(dxf*dxf + dyf*dyf);
         //--- Panel offset perpendicular to the line direction
         double offsetPx = 3.0;
         double perpX = (lenf > 0.001) ? (-dyf / lenf) :  1.0;
         double perpY = (lenf > 0.001) ? ( dxf / lenf) :  0.0;
         int anchorX = (int)MathRound(midX + perpX * offsetPx);
         int anchorY = (int)MathRound(midY + perpY * offsetPx);
         //--- Draw a small open rectangle as the info-panel preview
         int rectL = anchorX;
         int rectT = anchorY;
         int rectR = R - 2;
         int rectB = MathMin(B, anchorY + 6);
         ICON_LINE(rectL + 1, rectT,     rectR - 1, rectT);
         ICON_LINE(rectL + 1, rectB,     rectR - 1, rectB);
         ICON_LINE(rectL,     rectT + 1, rectL,     rectB - 1);
         ICON_LINE(rectR,     rectT + 1, rectR,     rectB - 1);
         handled = true; break;
        }
      case 9:  // TOOL_TREND_ANGLE
        {
         //--- Horizontal reference + angled arm (60deg) with a small AA arc between them
         int taInset = 1;
         int taL = cx - half + taInset;
         int taR = cx + half - taInset;
         int taB = cy + half - taInset;
         //--- Vertex of the angle at bottom-left
         int vx = taL, vy = taB;
         //--- Horizontal reference arm extending right
         ICON_LINE_FROM_HANDLE(vx, vy, taR, vy);
         //--- Angled arm at 60 degrees above horizontal
         double armAng  = 60.0 * M_PI / 180.0;
         double armLenF = (double)(taR - taL);
         double armEndXf = vx + MathCos(armAng) * armLenF;
         double armEndYf = vy - MathSin(armAng) * armLenF;
         ICON_LINE_BETWEEN(vx, vy, armEndXf, armEndYf);
         //--- Small arc inside the angle to visually mark the angle measure
         double arcR  = 11.0;
         double aStep = 1.0 / arcR;
         double aStart = 4.0 * M_PI / 180.0;
         double aEnd   = armAng - 4.0 * M_PI / 180.0;
         //--- Walk the arc step by step and place AA pixels
         for(double a = aStart; a <= aEnd; a += aStep)
           {
            double ax = vx + MathCos(a) * arcR;
            double ay = vy - MathSin(a) * arcR;
            ICON_PIXEL_F(ax, ay);
           }
         ICON_HANDLE(vx, vy);
         ICON_HANDLE((int)MathRound(armEndXf), (int)MathRound(armEndYf));
         handled = true; break;
        }
      case 10:  // TOOL_CROSS_LINE
        {
         //--- Horizontal + vertical full-extent lines with a single center handle (line gaps around it)
         ICON_LINE(L,     cy, cx - 3, cy);
         ICON_LINE(cx + 3, cy, R,      cy);
         ICON_LINE(cx, T,     cx, cy - 3);
         ICON_LINE(cx, cy + 3, cx, B);
         ICON_HANDLE(cx, cy);
         handled = true; break;
        }
      case 1:  // TOOL_POINTER
        {
         //--- Classic mouse-pointer arrowhead shape (5-vertex triangle with bottom notch)
         int halfBase = (R - L) / 2 - 2;
         if(halfBase < 3) halfBase = 3;
         int H       = B - T;
         int topY    = T + (int)(H * 0.05);
         int baseY   = T + (int)(H * 0.90);
         int notchY  = T + (int)(H * 0.68);
         //--- 4 vertices: tip, bottom-right, notch, bottom-left
         double v0x = (double)cx,                v0y = (double)topY;
         double v1x = (double)(cx + halfBase),   v1y = (double)baseY;
         double v2x = (double)cx,                v2y = (double)notchY;
         double v3x = (double)(cx - halfBase),   v3y = (double)baseY;
         //--- Close the pointer outline
         ICON_LINE(v0x, v0y, v1x, v1y);
         ICON_LINE(v1x, v1y, v2x, v2y);
         ICON_LINE(v2x, v2y, v3x, v3y);
         ICON_LINE(v3x, v3y, v0x, v0y);
         handled = true; break;
        }
      case 2:  // TOOL_CROSSHAIR
        {
         //--- Tiny center ring plus 4 tick lines extending outward (N, S, E, W)
         double ringR = 2.2;
         canvas.CircleWu(cx, cy, ringR, argb);
         //--- Gap between the ring and the start of each tick
         double tickGap    = 2.0;
         double tickStart  = ringR + tickGap;
         //--- East, West, North, South tick lines
         ICON_LINE(cx + tickStart, cy, R, cy);
         ICON_LINE(L, cy, cx - tickStart, cy);
         ICON_LINE(cx, T, cx, cy - tickStart);
         ICON_LINE(cx, cy + tickStart, cx, B);
         handled = true; break;
        }
      case 11:  // TOOL_PARALLEL_CHANNEL
        {
         //--- Two parallel diagonal lines plus a mid-line connector with 3 handles
         double H = (double)(B - T);
         //--- Top trendline endpoints (above the midline)
         double m1x = (double)L,            m1y = T + H * 0.52;
         double m2x = (double)R,            m2y = T + H * 0.08;
         //--- Vertical offset between top trendline and bottom parallel line
         double offsetY = H * 0.40;
         //--- Bottom parallel-line endpoints
         double p1x = m1x, p1y = m1y + offsetY;
         double p2x = m2x, p2y = m2y + offsetY;
         //--- Mid-line connector midpoint
         double pMx = (p1x + p2x) / 2.0;
         double pMy = (p1y + p2y) / 2.0;
         //--- Top trendline + connectors from midpoint to each bottom endpoint
         ICON_LINE_BETWEEN(m1x, m1y, m2x, m2y);
         ICON_LINE_FROM_HANDLE(pMx, pMy, p1x, p1y);
         ICON_LINE_FROM_HANDLE(pMx, pMy, p2x, p2y);
         //--- Handles at the two trendline endpoints and the mid-line midpoint
         ICON_HANDLE((int)MathRound(m1x), (int)MathRound(m1y));
         ICON_HANDLE((int)MathRound(m2x), (int)MathRound(m2y));
         ICON_HANDLE((int)MathRound(pMx), (int)MathRound(pMy));
         handled = true; break;
        }
      case 12:  // TOOL_REGRESSION_CHANNEL
        {
         //--- Regression center line + upper and lower parallel band rectangles
         double H = (double)(B - T);
         double halfBandH = H * 0.42;
         //--- Center line goes from bottom-left to top-right
         double c1x = (double)L, c1y = T + H * 0.68;
         double c2x = (double)R, c2y = T + H * 0.32;
         //--- Upper band corners
         double tlX = c1x, tlY = c1y - halfBandH;
         double trX = c2x, trY = c2y - halfBandH;
         //--- Lower band corners
         double brX = c2x, brY = c2y + halfBandH;
         double blX = c1x, blY = c1y + halfBandH;
         //--- Upper and lower band lines (parallel to the center)
         ICON_LINE(tlX, tlY, trX, trY);
         ICON_LINE(brX, brY, blX, blY);
         //--- Short vertical caps at each end of the bands
         ICON_LINE(tlX, tlY, c1x, c1y - 3);
         ICON_LINE(c1x, c1y + 3, blX, blY);
         ICON_LINE(trX, trY, c2x, c2y - 3);
         ICON_LINE(c2x, c2y + 3, brX, brY);
         //--- Center regression line itself
         ICON_LINE_BETWEEN(c1x, c1y, c2x, c2y);
         //--- Handles at the center-line endpoints
         ICON_HANDLE((int)MathRound(c1x), (int)MathRound(c1y));
         ICON_HANDLE((int)MathRound(c2x), (int)MathRound(c2y));
         handled = true; break;
        }
      case 13:  // TOOL_STDDEV_CHANNEL
        {
         //--- Regression line with outer band + inner sigma-band (4 parallel lines around center)
         double H = (double)(B - T);
         //--- Center line endpoints
         double c1x = (double)L, c1y = T + H * 0.68;
         double c2x = (double)R, c2y = T + H * 0.32;
         //--- Outer (2-sigma) band height and inner (1-sigma) band height
         double outerH = H * 0.42;
         double innerH = H * 0.20;
         //--- Outer band corners
         double tlX = c1x, tlY = c1y - outerH;
         double trX = c2x, trY = c2y - outerH;
         double brX = c2x, brY = c2y + outerH;
         double blX = c1x, blY = c1y + outerH;
         //--- Inner (upper) band corners
         double uiLx = c1x, uiLy = c1y - innerH;
         double uiRx = c2x, uiRy = c2y - innerH;
         //--- Inner (lower) band corners
         double liLx = c1x, liLy = c1y + innerH;
         double liRx = c2x, liRy = c2y + innerH;
         //--- Outer band edges with vertical caps at the ends
         ICON_LINE(tlX, tlY, trX, trY);
         ICON_LINE(brX, brY, blX, blY);
         ICON_LINE(tlX, tlY, c1x, c1y - 3);
         ICON_LINE(c1x, c1y + 3, blX, blY);
         ICON_LINE(trX, trY, c2x, c2y - 3);
         ICON_LINE(c2x, c2y + 3, brX, brY);
         //--- Inner sigma band lines (1-sigma above and below the center)
         ICON_LINE(uiLx, uiLy, uiRx, uiRy);
         ICON_LINE(liLx, liLy, liRx, liRy);
         //--- Center regression line itself plus handles at its endpoints
         ICON_LINE_BETWEEN(c1x, c1y, c2x, c2y);
         ICON_HANDLE((int)MathRound(c1x), (int)MathRound(c1y));
         ICON_HANDLE((int)MathRound(c2x), (int)MathRound(c2y));
         handled = true; break;
        }
      case 14:  // TOOL_PITCHFORK (Andrews)
        {
         //--- Andrews pitchfork: P1-P3 trendline + 3 parallel tines from P1, P2, P3 along a fixed 45deg
         double W = (double)(R - L);
         double H = (double)(B - T);
         //--- Anchor positions as fractions of the icon box
         double p1FracX = 0.08, p1FracY = 0.88;
         double p3FracX = 0.60, p3FracY = 0.88;
         double p2FracX = 0.18, p2FracY = 0.29;
         //--- All tines point at 45 degrees (up-right) with a length of 70% of icon width
         double angleDeg = 45.0;
         double p3TineFracW = 0.70;
         //--- Resolve anchor positions in canvas coords
         double p1x = L + W * p1FracX, p1y = T + H * p1FracY;
         double p3x = L + W * p3FracX, p3y = T + H * p3FracY;
         double p2x = L + W * p2FracX, p2y = T + H * p2FracY;
         //--- Unit vector along the tine direction
         double rad  = angleDeg * 3.14159265 / 180.0;
         double dirX = MathCos(rad);
         double dirY = -MathSin(rad);
         //--- Tine lengths chosen so all tines terminate at the same projected front
         double lenP3  = W * p3TineFracW;
         double lenP2  = lenP3;
         double p3proj = p3x * dirX + p3y * dirY;
         double dFront = p3proj + lenP3;
         double lenP1  = dFront - (p1x * dirX + p1y * dirY) + 1.5;
         //--- Tine endpoints
         double e1x = p1x + dirX * lenP1, e1y = p1y + dirY * lenP1;
         double e2x = p2x + dirX * lenP2, e2y = p2y + dirY * lenP2;
         double e3x = p3x + dirX * lenP3, e3y = p3y + dirY * lenP3;
         //--- Connector chord between P2 and P3 (the upper bar of the fork)
         ICON_LINE_BETWEEN(p2x, p2y, p3x, p3y);
         //--- The 3 tines from each handle along the fixed direction
         ICON_LINE_FROM_HANDLE(p1x, p1y, e1x, e1y);
         ICON_LINE_FROM_HANDLE(p2x, p2y, e2x, e2y);
         ICON_LINE_FROM_HANDLE(p3x, p3y, e3x, e3y);
         //--- Handles at the 3 anchor positions
         ICON_HANDLE((int)MathRound(p1x), (int)MathRound(p1y));
         ICON_HANDLE((int)MathRound(p2x), (int)MathRound(p2y));
         ICON_HANDLE((int)MathRound(p3x), (int)MathRound(p3y));
         handled = true; break;
        }
      case 15:  // TOOL_SCHIFF_PITCHFORK
        {
         //--- Schiff variant: median tine starts shifted along P1-(P2-P3 midpoint) line
         double W = (double)(R - L);
         double H = (double)(B - T);
         double p1FracX = 0.08, p1FracY = 0.88;
         double p3FracX = 0.60, p3FracY = 0.88;
         double p2FracX = 0.18, p2FracY = 0.29;
         double angleDeg = 45.0;
         double p3TineFracW = 0.70;
         double p1x = L + W * p1FracX, p1y = T + H * p1FracY;
         double p3x = L + W * p3FracX, p3y = T + H * p3FracY;
         double p2x = L + W * p2FracX, p2y = T + H * p2FracY;
         double rad  = angleDeg * 3.14159265 / 180.0;
         double dirX = MathCos(rad);
         double dirY = -MathSin(rad);
         //--- Compute the Schiff-offset along the median ray from P1
         double bx = p3x - p2x, by = p3y - p2y;
         double denom = dirX * (-by) - dirY * (-bx);
         double tCross = 0.0;
         if(MathAbs(denom) > 1e-9) {
            //--- Solve for the parameter where the median ray crosses P2-P3
            double rhsX = p2x - p1x, rhsY = p2y - p1y;
            tCross = (rhsX * (-by) - rhsY * (-bx)) / denom;
         }
         //--- Half the crossing distance is where the median tine starts
         double medianGapPx = tCross * 0.5;
         if(medianGapPx < 0) medianGapPx = 0;
         //--- Tine lengths and endpoints (median tine starts shifted along the ray)
         double lenP3  = W * p3TineFracW;
         double lenP2  = lenP3;
         double p3proj = p3x * dirX + p3y * dirY;
         double dFront = p3proj + lenP3;
         double lenP1  = dFront - (p1x * dirX + p1y * dirY) + 1.5;
         double medStartX = p1x + dirX * medianGapPx;
         double medStartY = p1y + dirY * medianGapPx;
         double medEndX   = p1x + dirX * lenP1;
         double medEndY   = p1y + dirY * lenP1;
         double e2x = p2x + dirX * lenP2, e2y = p2y + dirY * lenP2;
         double e3x = p3x + dirX * lenP3, e3y = p3y + dirY * lenP3;
         //--- Bar chord P2-P3 plus median chord P1-P3
         ICON_LINE_BETWEEN(p2x, p2y, p3x, p3y);
         ICON_LINE_BETWEEN(p1x, p1y, p3x, p3y);
         //--- Median tine (shifted start) plus the two outer parallel tines
         ICON_LINE(medStartX, medStartY, medEndX, medEndY);
         ICON_LINE_FROM_HANDLE(p2x, p2y, e2x, e2y);
         ICON_LINE_FROM_HANDLE(p3x, p3y, e3x, e3y);
         ICON_HANDLE((int)MathRound(p1x), (int)MathRound(p1y));
         ICON_HANDLE((int)MathRound(p2x), (int)MathRound(p2y));
         ICON_HANDLE((int)MathRound(p3x), (int)MathRound(p3y));
         handled = true; break;
        }
      case 16:  // TOOL_MOD_SCHIFF
        {
         //--- Modified Schiff: median tine emerges from P1 directly (no Schiff offset)
         double W = (double)(R - L);
         double H = (double)(B - T);
         double p1FracX = 0.08, p1FracY = 0.88;
         double p3FracX = 0.60, p3FracY = 0.88;
         double p2FracX = 0.18, p2FracY = 0.29;
         double angleDeg = 45.0;
         double p3TineFracW = 0.70;
         double p1x = L + W * p1FracX, p1y = T + H * p1FracY;
         double p3x = L + W * p3FracX, p3y = T + H * p3FracY;
         double p2x = L + W * p2FracX, p2y = T + H * p2FracY;
         double rad  = angleDeg * 3.14159265 / 180.0;
         double dirX = MathCos(rad);
         double dirY = -MathSin(rad);
         //--- Tine lengths chosen so all 3 tines reach the same projected front
         double lenP3  = W * p3TineFracW;
         double lenP2  = lenP3;
         double p3proj = p3x * dirX + p3y * dirY;
         double dFront = p3proj + lenP3;
         double lenP1  = dFront - (p1x * dirX + p1y * dirY) + 1.5;
         double e1x = p1x + dirX * lenP1, e1y = p1y + dirY * lenP1;
         double e2x = p2x + dirX * lenP2, e2y = p2y + dirY * lenP2;
         double e3x = p3x + dirX * lenP3, e3y = p3y + dirY * lenP3;
         //--- Bar chord P2-P3 plus median chord P1-P3 plus the 3 tines
         ICON_LINE_BETWEEN(p2x, p2y, p3x, p3y);
         ICON_LINE_BETWEEN(p1x, p1y, p3x, p3y);
         ICON_LINE_FROM_HANDLE(p1x, p1y, e1x, e1y);
         ICON_LINE_FROM_HANDLE(p2x, p2y, e2x, e2y);
         ICON_LINE_FROM_HANDLE(p3x, p3y, e3x, e3y);
         ICON_HANDLE((int)MathRound(p1x), (int)MathRound(p1y));
         ICON_HANDLE((int)MathRound(p2x), (int)MathRound(p2y));
         ICON_HANDLE((int)MathRound(p3x), (int)MathRound(p3y));
         handled = true; break;
        }
      case 17:  // TOOL_GANN_LINE
        {
         //--- Single steep diagonal trendline (1:1 ratio) with handles at both ends
         double W = (double)(R - L);
         double H = (double)(B - T);
         double p1x = L + W * 0.08, p1y = T + H * 0.85;
         double p2x = L + W * 0.85, p2y = T + H * 0.15;
         ICON_LINE_BETWEEN(p1x, p1y, p2x, p2y);
         ICON_HANDLE((int)MathRound(p1x), (int)MathRound(p1y));
         ICON_HANDLE((int)MathRound(p2x), (int)MathRound(p2y));
         handled = true; break;
        }
      case 18:  // TOOL_GANN_FAN
        {
         //--- Multiple rays from a single anchor (P1) at various Gann ratios
         double W = (double)(R - L);
         double H = (double)(B - T);
         //--- Anchor point at bottom-left, ray endpoints fanning out
         double p1x = L + W * 0.10, p1y = T + H * 0.85;
         double e0x = L + W * 0.95, e0y = T + H * 0.80;
         double e1x = L + W * 0.95, e1y = T + H * 0.55;
         double e2x = L + W * 0.95, e2y = T + H * 0.25;
         double e3x = L + W * 0.65, e3y = T + H * 0.10;
         double e4x = L + W * 0.30, e4y = T + H * 0.10;
         //--- Render the 5 rays (idx 2 = primary 1:1 ratio, drawn shortened)
         ICON_LINE_FROM_HANDLE(p1x, p1y, e0x, e0y);
         ICON_LINE_FROM_HANDLE(p1x, p1y, e1x, e1y);
         ICON_LINE_BETWEEN(p1x, p1y, e2x, e2y);
         ICON_LINE_FROM_HANDLE(p1x, p1y, e3x, e3y);
         ICON_LINE_FROM_HANDLE(p1x, p1y, e4x, e4y);
         //--- Handles at the anchor and the primary 1:1 endpoint
         ICON_HANDLE((int)MathRound(p1x), (int)MathRound(p1y));
         ICON_HANDLE((int)MathRound(e2x), (int)MathRound(e2y));
         handled = true; break;
        }
      case 19:  // TOOL_GANN_BOX
        {
         //--- Box with diagonals from BL and TR corners, plus midpoint cross lines
         double W = (double)(R - L);
         double H = (double)(B - T);
         //--- Box corners (slightly inset from the icon edges)
         double xL_ = L + W * 0.12, xR_ = L + W * 0.88;
         double yT_ = T + H * 0.15, yB_ = T + H * 0.85;
         double p1x = xL_, p1y = yB_;
         double p2x = xR_, p2y = yT_;
         //--- Two diagonals from each handle to the opposite corners
         ICON_LINE_FROM_HANDLE(p1x, p1y, xL_, yT_);
         ICON_LINE_FROM_HANDLE(p1x, p1y, xR_, yB_);
         ICON_LINE_FROM_HANDLE(p2x, p2y, xL_, yT_);
         ICON_LINE_FROM_HANDLE(p2x, p2y, xR_, yB_);
         //--- Midpoint cross lines for the box quadrants
         double cX = (xL_ + xR_) / 2.0;
         double cY = (yT_ + yB_) / 2.0;
         ICON_LINE(xL_, cY, xR_, cY);
         ICON_LINE(cX, yT_, cX, yB_);
         ICON_HANDLE((int)MathRound(p1x), (int)MathRound(p1y));
         ICON_HANDLE((int)MathRound(p2x), (int)MathRound(p2y));
         handled = true; break;
        }
      case 20:  // TOOL_FIBO_RETRACEMENT
        {
         //--- Four horizontal Fib level lines spaced evenly with 2 alternating-side handles
         double W = (double)(R - L);
         double H = (double)(B - T);
         //--- Small vertical margin so lines don't touch the icon top/bottom
         int marginV = (int)MathRound(H * 0.05);
         int yTop    = T + marginV;
         int yBot    = B - marginV;
         //--- Equally-spaced Y positions for the 4 level lines
         int lineY[4];
         for(int i = 0; i < 4; i++)
            lineY[i] = yTop + (int)MathRound(((double)(yBot - yTop)) * ((double)i / 3.0));
         //--- Render the 4 lines; lines 1 and 3 have handles at opposite ends
         ICON_LINE(L, lineY[0], R, lineY[0]);
         int h1x = R - 1, h1y = lineY[1];
         ICON_LINE_FROM_HANDLE(h1x, h1y, L, lineY[1]);
         ICON_LINE(L, lineY[2], R, lineY[2]);
         int h2x = L + 1, h2y = lineY[3];
         ICON_LINE_FROM_HANDLE(h2x, h2y, R, lineY[3]);
         ICON_HANDLE(h1x, h1y);
         ICON_HANDLE(h2x, h2y);
         handled = true; break;
        }
      case 21:  // TOOL_FIBO_EXPANSION
        {
         //--- 3 stacked horizontal levels at the bottom + a diagonal swing to the top-right
         double W = (double)(R - L);
         double H = (double)(B - T);
         //--- Stack region of 3 horizontal lines occupies the bottom half
         int stackTopY = T + (int)MathRound(H * 0.55);
         int stackBotY = B - (int)MathRound(H * 0.03);
         //--- Three horizontal levels spread between stackTopY and stackBotY
         int lineY[3];
         for(int i = 0; i < 3; i++)
            lineY[i] = stackTopY + (int)MathRound((double)(stackBotY - stackTopY) * ((double)i / 2.0));
         //--- The top horizontal level has a handle at its left endpoint
         int h1x = L + 1, h1y = lineY[0];
         ICON_LINE_FROM_HANDLE(h1x, h1y, R, lineY[0]);
         //--- Middle and bottom horizontal levels (full width)
         ICON_LINE(L, lineY[1], R, lineY[1]);
         ICON_LINE(L, lineY[2], R, lineY[2]);
         //--- The diagonal swing line goes from h1x up to a top-right anchor
         int h2x = h1x, h2y = T + (int)MathRound(H * 0.18);
         //--- Vertical connector between the level-0 line and the swing start (with handle gap)
         {
            int ringR = 2;
            int ax = h1x, ay = h1y - ringR;
            int bx = h2x, by = h2y + ringR;
            if(ay > by) ICON_LINE(ax, ay, bx, by);
         }
         //--- Diagonal swing line to the right at a 0.364 slope (visual Fib ratio)
         double diagLen = W * 0.72;
         int h3x = h2x + (int)MathRound(diagLen);
         int h3y = h2y - (int)MathRound(diagLen * 0.364);
         //--- Clamp the diagonal endpoint inside the icon box
         if(h3x > R - 1) h3x = R - 1;
         if(h3y < T + 1) h3y = T + 1;
         ICON_LINE_BETWEEN(h2x, h2y, h3x, h3y);
         //--- Handles at the 3 key points
         ICON_HANDLE(h1x, h1y);
         ICON_HANDLE(h2x, h2y);
         ICON_HANDLE(h3x, h3y);
         handled = true; break;
        }
      case 22:  // TOOL_FIBO_CHANNEL
        {
         //--- Three parallel slanted lines representing channel edges + handles
         double W = (double)(R - L);
         double H = (double)(B - T);
         //--- Inset and channel layout constants
         int insetX   = (int)MathRound(W * 0.06);
         int xStart   = L + insetX;
         int xEnd     = R - insetX;
         int runX     = xEnd - xStart;
         //--- Channel rise (slope) along the run
         int riseY    = (int)MathRound((double)runX * 0.577);
         //--- Top line: gently downward-sloped
         int topStartY = T + (int)MathRound(H * 0.18);
         int topEndY   = topStartY - (int)MathRound((double)riseY * 0.3);
         //--- Spacing between the top, middle, and bottom parallel lines
         int gapY      = (int)MathRound(H * 0.36);
         int midStartY = topStartY + gapY;
         int midEndY   = topEndY   + gapY;
         int botStartY = topStartY + gapY * 2;
         int botEndY   = topEndY   + gapY * 2;
         //--- Handle-ring buffer for line extensions
         int ringR  = 2;
         //--- Shared slope across the three parallel lines
         double slope = (double)(topEndY - topStartY) / (double)runX;
         int extStartX = xStart - ringR;
         int extEndX   = xEnd   + ringR;
         //--- Top channel line (between two handles)
         int t1x = xStart, t1y = topStartY;
         int t2x = xEnd,   t2y = topEndY;
         ICON_LINE_BETWEEN(t1x, t1y, t2x, t2y);
         //--- Middle line (extends from a handle on the left to the right edge)
         int m1x = xStart, m1y = midStartY;
         int midRightY = midStartY + (int)MathRound(slope * (double)(extEndX - xStart));
         ICON_LINE_FROM_HANDLE(m1x, m1y, extEndX, midRightY);
         //--- Bottom line extends fully across (no handles on this line)
         int botLeftY  = botStartY + (int)MathRound(slope * (double)(extStartX - xStart));
         int botRightY = botStartY + (int)MathRound(slope * (double)(extEndX   - xStart));
         ICON_LINE(extStartX, botLeftY, extEndX, botRightY);
         //--- Three handles at the channel's defining anchors
         ICON_HANDLE(t1x, t1y);
         ICON_HANDLE(t2x, t2y);
         ICON_HANDLE(m1x, m1y);
         handled = true; break;
        }
      case 23:  // TOOL_FIBO_TIMEZONES
        {
         //--- Multiple vertical lines at Fibonacci-spaced X positions plus a diagonal connector
         double W = (double)(R - L);
         double H = (double)(B - T);
         //--- Four X positions for the vertical zone lines
         int vx[4];
         vx[0] = L + (int)MathRound(W * 0.10);
         vx[1] = L + (int)MathRound(W * 0.42);
         vx[2] = L + (int)MathRound(W * 0.66);
         vx[3] = L + (int)MathRound(W * 0.90);
         //--- Top and bottom of the vertical lines
         int yTopV = T + (int)MathRound(H * 0.08);
         int yBotV = B - (int)MathRound(H * 0.08);
         //--- Handle Y positions on the first two vertical lines
         int h1y   = T + (int)MathRound(H * 0.30);
         int h2y   = T + (int)MathRound(H * 0.70);
         int ringR = 2;
         //--- Two vertical lines with handle gaps; the other two without gaps
         ICON_LINE(vx[0], yTopV,       vx[0], h1y - ringR);
         ICON_LINE(vx[0], h1y + ringR, vx[0], yBotV);
         ICON_LINE(vx[1], yTopV,       vx[1], h2y - ringR);
         ICON_LINE(vx[1], h2y + ringR, vx[1], yBotV);
         ICON_LINE(vx[2], yTopV, vx[2], yBotV);
         ICON_LINE(vx[3], yTopV, vx[3], yBotV);
         //--- Diagonal connector between the two handles on the first 2 verticals
         ICON_LINE_BETWEEN(vx[0], h1y, vx[1], h2y);
         ICON_HANDLE(vx[0], h1y);
         ICON_HANDLE(vx[1], h2y);
         handled = true; break;
        }
      case 24:  // TOOL_FIBO_FAN
        {
         //--- Multi-ray fan from a corner anchor; also a grid line pair at the 0.75 ratio
         double W = (double)(R - L);
         double H = (double)(B - T);
         //--- Corner anchor at bottom-left
         int p1x = L + (int)MathRound(W * 0.05);
         int p1y = B - (int)MathRound(H * 0.05);
         //--- Pick a maximum reach that respects the icon box bounds
         int avail = (int)MathMin((double)(R - p1x) - 1.0, (double)(p1y - T) - 1.0);
         if(avail < 6) avail = 6;
         //--- Second handle position on the 45deg ray
         int e2x = p1x + avail;
         int e2y = p1y - avail;
         //--- Mid-point of the 45deg ray at gridFrac for the grid lines
         double gridFrac = 0.75;
         int mx = p1x + (int)MathRound((double)avail * gridFrac);
         int my = p1y - (int)MathRound((double)avail * gridFrac);
         //--- Ray endpoints at various Fib angles (horizontal, ~26deg, 45deg, 63deg, vertical)
         int eHx = p1x + avail, eHy = p1y;
         int e0x = p1x + avail, e0y = p1y - (int)MathRound((double)avail * 0.5);
         int e3x = p1x + (int)MathRound((double)avail * 0.5), e3y = p1y - avail;
         int eVx = p1x,         eVy = p1y - avail;
         //--- Render the 4 outer rays from the corner anchor
         ICON_LINE_FROM_HANDLE(p1x, p1y, eHx, eHy);
         ICON_LINE_FROM_HANDLE(p1x, p1y, e0x, e0y);
         ICON_LINE_FROM_HANDLE(p1x, p1y, e3x, e3y);
         ICON_LINE_FROM_HANDLE(p1x, p1y, eVx, eVy);
         //--- The primary 45deg ray with a mid handle, extended to the secondary handle
         ICON_LINE_BETWEEN(p1x, p1y, mx, my);
         ICON_LINE_FROM_HANDLE(mx, my, e2x, e2y);
         //--- Faint reference grid lines at the mid handle
         int ringR = 2;
         ICON_LINE(p1x, my, mx - ringR, my);
         ICON_LINE(mx, p1y, mx, my + ringR);
         ICON_HANDLE(p1x, p1y);
         ICON_HANDLE(mx, my);
         handled = true; break;
        }
      case 25:  // TOOL_FIBO_ARCS
        {
         //--- Two concentric semicircular arcs centered at a top anchor with a base handle
         double W = (double)(R - L);
         double H = (double)(B - T);
         //--- Arc center at the top-center of the icon
         double cx = L + W * 0.50, cy = T + H * 0.15;
         //--- Maximum arc radius constrained by both width and height
         double rMax = MathMin(W * 0.60, H * 1.05);
         //--- Two radii at canonical Fib-arc ratios
         double radii[2];
         radii[0] = rMax * 0.55;
         radii[1] = rMax * 1.00;
         //--- Skip-zone radius around the outer-arc handle for visual clarity
         double ringR = 2.5;
         //--- Outer-arc handle position at the bottom of the second (outer) arc
         double h2cx  = cx;
         double h2cy  = cy + radii[1];
         //--- Render each arc by walking from 0 to pi in small angular steps
         for(int i = 0; i < 2; i++)
           {
            double r = radii[i];
            //--- Outer arc skips pixels close to the handle ring
            bool skipNearH2 = (i == 1);
            //--- Step count proportional to arc length for smooth rendering
            int steps = (int)MathCeil(3.14159 * r);
            if(steps < 10) steps = 10;
            if(steps > 200) steps = 200;
            //--- Walk along the arc placing AA pixels at every step
            for(int s = 0; s <= steps; s++)
              {
               double a  = (3.14159 * (double)s) / (double)steps;
               double ax = cx + r * MathCos(a);
               double ay = cy + r * MathSin(a);
               //--- Skip pixels too close to the handle ring on the outer arc
               if(skipNearH2)
                 {
                  double ddx = ax - h2cx, ddy = ay - h2cy;
                  if(ddx * ddx + ddy * ddy < ringR * ringR) continue;
                 }
               //--- Place an AA pixel at the arc point
               ICON_AA_PLOT((int)MathRound(ax), (int)MathRound(ay), 1.0);
              }
           }
         //--- Handle at the center anchor and at the outer-arc base point
         int h1x = (int)MathRound(cx);
         int h1y = (int)MathRound(cy);
         int h2x = h1x;
         int h2y = (int)MathRound(cy + radii[1]);
         ICON_HANDLE(h1x, h1y);
         ICON_HANDLE(h2x, h2y);
         handled = true; break;
        }
      case 26:  // TOOL_RECTANGLE
        {
         //--- Simple 4-sided rectangle outline with corner handles
         double W = (double)(R - L);
         double H = (double)(B - T);
         int xL = L + (int)MathRound(W * 0.15);
         int xR = R - (int)MathRound(W * 0.15);
         int yT = T + (int)MathRound(H * 0.15);
         int yB = B - (int)MathRound(H * 0.15);
         //--- The 4 sides of the rectangle outline (shortened on both ends to clear handles)
         ICON_LINE_BETWEEN(xL, yT, xR, yT);
         ICON_LINE_BETWEEN(xR, yT, xR, yB);
         ICON_LINE_BETWEEN(xR, yB, xL, yB);
         ICON_LINE_BETWEEN(xL, yB, xL, yT);
         //--- 4 corner handles
         ICON_HANDLE(xL, yT);
         ICON_HANDLE(xR, yT);
         ICON_HANDLE(xR, yB);
         ICON_HANDLE(xL, yB);
         handled = true; break;
        }
      case 27:  // TOOL_TRIANGLE
        {
         //--- Right-triangle outline (vertical left side + horizontal bottom + hypotenuse)
         double W = (double)(R - L);
         double H = (double)(B - T);
         int xL = L + (int)MathRound(W * 0.15);
         int xR = R - (int)MathRound(W * 0.10);
         int yT = T + (int)MathRound(H * 0.15);
         int yB = B - (int)MathRound(H * 0.15);
         //--- Vertical left side, horizontal bottom, then hypotenuse
         ICON_LINE_BETWEEN(xL, yT, xL, yB);
         ICON_LINE_BETWEEN(xL, yB, xR, yB);
         ICON_LINE_BETWEEN(xR, yB, xL, yT);
         //--- Handles at the 3 triangle corners
         ICON_HANDLE(xL, yT);
         ICON_HANDLE(xL, yB);
         ICON_HANDLE(xR, yB);
         handled = true; break;
        }
      case 28:  // TOOL_ELLIPSE
        {
         //--- Axis-aligned ellipse outline with handles at the 4 cardinal points (N/E/S/W)
         double W = (double)(R - L);
         double H = (double)(B - T);
         //--- Ellipse center and radii
         double ecx = (double)(L + R) * 0.5;
         double ecy = (double)(T + B) * 0.5;
         double erx = W * 0.40;
         double ery = H * 0.32;
         //--- 4 cardinal-point handles (N, E, S, W)
         int h0x = (int)MathRound(ecx),        h0y = (int)MathRound(ecy - ery);
         int h1x = (int)MathRound(ecx + erx),  h1y = (int)MathRound(ecy);
         int h2x = (int)MathRound(ecx),        h2y = (int)MathRound(ecy + ery);
         int h3x = (int)MathRound(ecx - erx),  h3y = (int)MathRound(ecy);
         //--- Outline rendering via per-pixel ellipse equation coverage
         double halfThick = 0.5;
         double rxSq = erx * erx;
         double rySq = ery * ery;
         //--- Bounding-box iteration range with padding
         int bxLo = (int)MathFloor(ecx - erx) - 1;
         int bxHi = (int)MathCeil (ecx + erx) + 1;
         int byLo = (int)MathFloor(ecy - ery) - 1;
         int byHi = (int)MathCeil (ecy + ery) + 1;
         //--- Handle-ring skip radius so the outline doesn't pass through the handles
         double ringR = 2.5;
         //--- Walk every pixel in the bounding box and test ellipse-border distance
         for(int yy = byLo; yy <= byHi; yy++)
           {
            for(int xx = bxLo; xx <= bxHi; xx++)
              {
               //--- Skip pixels too close to any of the 4 cardinal handles
               double ddx, ddy;
               ddx = xx - h0x; ddy = yy - h0y; if(ddx*ddx + ddy*ddy < ringR*ringR) continue;
               ddx = xx - h1x; ddy = yy - h1y; if(ddx*ddx + ddy*ddy < ringR*ringR) continue;
               ddx = xx - h2x; ddy = yy - h2y; if(ddx*ddx + ddy*ddy < ringR*ringR) continue;
               ddx = xx - h3x; ddy = yy - h3y; if(ddx*ddx + ddy*ddy < ringR*ringR) continue;
               //--- Compute pixel offset from the ellipse center and the ellipse-equation value
               double dxp = (double)xx - ecx;
               double dyp = (double)yy - ecy;
               double F   = (dxp * dxp) / rxSq + (dyp * dyp) / rySq;
               //--- Skip degenerate F values to avoid numerical instability
               double sqrtF = MathSqrt(F);
               if(sqrtF < 1e-9) continue;
               //--- Gradient magnitude for the distance-to-border approximation
               double gu = dxp / rxSq;
               double gv = dyp / rySq;
               double gmag = MathSqrt(gu * gu + gv * gv);
               if(gmag < 1e-12) continue;
               //--- Approximate perpendicular distance from the pixel to the ellipse border
               double dist = MathAbs((sqrtF - 1.0) / gmag);
               //--- Pixels too far from the border don't contribute to the outline
               if(dist > halfThick + 1.5) continue;
               //--- Coverage decreases linearly with distance from the border centerline
               double cov = halfThick + 0.5 - dist;
               if(cov <= 0.0) continue;
               if(cov > 1.0) cov = 1.0;
               ICON_AA_PLOT(xx, yy, cov);
              }
           }
         //--- 4 cardinal-point handles
         ICON_HANDLE(h0x, h0y);
         ICON_HANDLE(h1x, h1y);
         ICON_HANDLE(h2x, h2y);
         ICON_HANDLE(h3x, h3y);
         handled = true; break;
        }
      case 37:  // TOOL_ROTATED_RECTANGLE
        {
         //--- Axis-rotated rectangle outline with 4 corner handles + 2 mid-side handles
         double W = (double)(R - L);
         double H = (double)(B - T);
         //--- Rectangle center and half-extents
         double ecx = (double)(L + R) * 0.5;
         double ecy = (double)(T + B) * 0.5;
         double hw = W * 0.40;
         double hh = H * 0.28;
         //--- Rotation angle of -15 degrees for the visual tilt
         double angDeg = -15.0;
         double angRad = angDeg * 3.14159265358979 / 180.0;
         double cA = MathCos(angRad);
         double sA = MathSin(angRad);
         //--- Compute the 4 rotated corners using the standard rotation matrix
         double c1x_ = ecx + (-hw) * cA - (+hh) * sA;
         double c1y_ = ecy + (-hw) * sA + (+hh) * cA;
         double c2x_ = ecx + (+hw) * cA - (+hh) * sA;
         double c2y_ = ecy + (+hw) * sA + (+hh) * cA;
         double c3x_ = ecx + (+hw) * cA - (-hh) * sA;
         double c3y_ = ecy + (+hw) * sA + (-hh) * cA;
         double c4x_ = ecx + (-hw) * cA - (-hh) * sA;
         double c4y_ = ecy + (-hw) * sA + (-hh) * cA;
         //--- Round to integer pixel positions
         int c1x = (int)MathRound(c1x_), c1y = (int)MathRound(c1y_);
         int c2x = (int)MathRound(c2x_), c2y = (int)MathRound(c2y_);
         int c3x = (int)MathRound(c3x_), c3y = (int)MathRound(c3y_);
         int c4x = (int)MathRound(c4x_), c4y = (int)MathRound(c4y_);
         //--- Mid-side handle positions (top-mid and bottom-mid edges)
         int tmx = (c3x + c4x) / 2, tmy = (c3y + c4y) / 2;
         int bmx = (c1x + c2x) / 2, bmy = (c1y + c2y) / 2;
         //--- Render the 4 sides with mid-side breaks for the additional handles
         ICON_LINE_BETWEEN(c4x, c4y, c1x, c1y);
         ICON_LINE_BETWEEN(c2x, c2y, c3x, c3y);
         ICON_LINE_BETWEEN(c1x, c1y, bmx, bmy);
         ICON_LINE_BETWEEN(bmx, bmy, c2x, c2y);
         ICON_LINE_BETWEEN(c3x, c3y, tmx, tmy);
         ICON_LINE_BETWEEN(tmx, tmy, c4x, c4y);
         //--- 4 corner handles + 2 mid-side handles
         ICON_HANDLE(c1x, c1y);
         ICON_HANDLE(c2x, c2y);
         ICON_HANDLE(c3x, c3y);
         ICON_HANDLE(c4x, c4y);
         ICON_HANDLE(tmx, tmy);
         ICON_HANDLE(bmx, bmy);
         handled = true; break;
        }
      case 29:  // TOOL_TEXT
        {
         //--- Stylized capital "T" - the classic text-tool glyph
         double W = (double)(R - L);
         double H = (double)(B - T);
         //--- Horizontal top bar
         int topY   = T + (int)MathRound(H * 0.08);
         int barL   = L + (int)MathRound(W * 0.20);
         int barR   = R - (int)MathRound(W * 0.20);
         ICON_LINE(barL, topY, barR, topY);
         //--- Small serifs hanging off each end of the top bar
         int dropLen = (int)MathRound(H * 0.22);
         ICON_LINE(barL, topY, barL, topY + dropLen);
         ICON_LINE(barR, topY, barR, topY + dropLen);
         //--- Vertical stem from the bar's center down to the baseline
         int stemX  = (barL + barR) / 2;
         int stemTop = topY;
         int stemBot = B - (int)MathRound(H * 0.08);
         ICON_LINE(stemX, stemTop, stemX, stemBot);
         //--- Small base serif under the stem
         int baseHalf = (int)MathRound(W * 0.14);
         ICON_LINE(stemX - baseHalf, stemBot, stemX + baseHalf, stemBot);
         handled = true; break;
        }
      case 30:  // TOOL_ARROW_UP
        {
         //--- Upward-pointing 7-vertex dart silhouette (apex at top, base at bottom)
         double W = (double)(R - L);
         double H = (double)(B - T);
         int cx = (int)MathRound((L + R) * 0.5);
         //--- Y positions of the dart's apex, head base, and overall base
         int apexY     = (int)MathRound(T + H * 0.08);
         int headBaseY = (int)MathRound(T + H * 0.54);
         int baseY     = (int)MathRound(B - H * 0.08);
         //--- Shaft and head widths (head wider than shaft)
         int shaftHalf = (int)MathRound(W * 0.14);
         int headHalf  = (int)MathRound(W * 0.32);
         //--- The 7 vertices of the dart silhouette, walked clockwise
         int v0x = cx,                v0y = apexY;
         int v1x = cx + headHalf,     v1y = headBaseY;
         int v2x = cx + shaftHalf,    v2y = headBaseY;
         int v3x = cx + shaftHalf,    v3y = baseY;
         int v4x = cx - shaftHalf,    v4y = baseY;
         int v5x = cx - shaftHalf,    v5y = headBaseY;
         int v6x = cx - headHalf,     v6y = headBaseY;
         //--- Draw the closed outline of the dart
         ICON_LINE(v0x, v0y, v1x, v1y);
         ICON_LINE(v1x, v1y, v2x, v2y);
         ICON_LINE(v2x, v2y, v3x, v3y);
         ICON_LINE(v3x, v3y, v4x, v4y);
         ICON_LINE(v4x, v4y, v5x, v5y);
         ICON_LINE(v5x, v5y, v6x, v6y);
         ICON_LINE(v6x, v6y, v0x, v0y);
         handled = true; break;
        }
      case 31:  // TOOL_ARROW_DOWN
        {
         //--- Downward-pointing 7-vertex dart silhouette (apex at bottom, base at top)
         double W = (double)(R - L);
         double H = (double)(B - T);
         int cx = (int)MathRound((L + R) * 0.5);
         //--- Y positions inverted vs ARROW_UP
         int apexY     = (int)MathRound(B - H * 0.08);
         int headBaseY = (int)MathRound(B - H * 0.54);
         int baseY     = (int)MathRound(T + H * 0.08);
         int shaftHalf = (int)MathRound(W * 0.14);
         int headHalf  = (int)MathRound(W * 0.32);
         //--- The 7 vertices (CW traversal)
         int v0x = cx,                v0y = apexY;
         int v1x = cx + headHalf,     v1y = headBaseY;
         int v2x = cx + shaftHalf,    v2y = headBaseY;
         int v3x = cx + shaftHalf,    v3y = baseY;
         int v4x = cx - shaftHalf,    v4y = baseY;
         int v5x = cx - shaftHalf,    v5y = headBaseY;
         int v6x = cx - headHalf,     v6y = headBaseY;
         //--- Draw the closed dart outline
         ICON_LINE(v0x, v0y, v1x, v1y);
         ICON_LINE(v1x, v1y, v2x, v2y);
         ICON_LINE(v2x, v2y, v3x, v3y);
         ICON_LINE(v3x, v3y, v4x, v4y);
         ICON_LINE(v4x, v4y, v5x, v5y);
         ICON_LINE(v5x, v5y, v6x, v6y);
         ICON_LINE(v6x, v6y, v0x, v0y);
         handled = true; break;
        }
      case 38:  // TOOL_PATH
        {
         //--- Multi-vertex zigzag polyline with handles at mid-vertices and arrowhead at the tip
         double W = (double)(R - L);
         double H = (double)(B - T);
         int ringR = 2;
         //--- Two Y bands the path zigzags between
         int yLow  = B - (int)MathRound(H * 0.22);
         int yHigh = T + (int)MathRound(H * 0.18);
         //--- Start and end X positions; span divided into 3 equal parts
         int x0    = L + (int)MathRound(W * 0.10);
         int x3    = R - (int)MathRound(W * 0.06);
         int span  = x3 - x0;
         //--- The 4 zigzag vertices (alternating low/high)
         int v0x   = x0;                                        int v0y = yLow  + ringR;
         int v1x   = x0 + (int)MathRound(span * (1.0 / 3.0));   int v1y = yHigh;
         int v2x   = x0 + (int)MathRound(span * (2.0 / 3.0));   int v2y = yLow;
         int v3x   = x3;                                        int v3y = yHigh - ringR;
         //--- 3 path segments connecting the 4 vertices (handle-clearance on ends)
         ICON_LINE_FROM_HANDLE(v1x, v1y, v0x, v0y);
         ICON_LINE_BETWEEN(v1x, v1y, v2x, v2y);
         ICON_LINE_FROM_HANDLE(v2x, v2y, v3x, v3y);
         //--- Handles at the 2 interior vertices
         ICON_HANDLE(v1x, v1y);
         ICON_HANDLE(v2x, v2y);
         //--- Arrowhead at the path's tip (final segment direction)
         double dxf = (double)(v3x - v2x);
         double dyf = (double)(v3y - v2y);
         double lenf = MathSqrt(dxf * dxf + dyf * dyf);
         if(lenf > 0.001)
           {
            //--- Unit direction and perpendicular for the arrowhead wings
            double ux = dxf / lenf;
            double uy = dyf / lenf;
            double nx = -uy;
            double ny =  ux;
            double ahLen  = 3.5;
            double ahWide = 2.0;
            //--- Two arrowhead wings flanking the tip
            double w1x = v3x - ux * ahLen + nx * ahWide;
            double w1y = v3y - uy * ahLen + ny * ahWide;
            double w2x = v3x - ux * ahLen - nx * ahWide;
            double w2y = v3y - uy * ahLen - ny * ahWide;
            ICON_LINE(v3x, v3y, w1x, w1y);
            ICON_LINE(v3x, v3y, w2x, w2y);
           }
         handled = true; break;
        }
      case 39:  // TOOL_CIRCLE
        {
         //--- Circle outline with handles at the center and on the border (east cardinal)
         double W = (double)(R - L);
         double H = (double)(B - T);
         //--- Center and radius
         double ccx = (double)(L + R) * 0.5;
         double ccy = (double)(T + B) * 0.5;
         double cr = MathMin(W, H) * 0.36;
         //--- Center and border-east handles
         int hCx = (int)MathRound(ccx);
         int hCy = (int)MathRound(ccy);
         int hRx = (int)MathRound(ccx + cr);
         int hRy = (int)MathRound(ccy);
         //--- Outline rendering via per-pixel disc-distance coverage
         double halfThick = 0.5;
         //--- Bounding-box iteration range with padding
         int bxLo = (int)MathFloor(ccx - cr) - 1;
         int bxHi = (int)MathCeil (ccx + cr) + 1;
         int byLo = (int)MathFloor(ccy - cr) - 1;
         int byHi = (int)MathCeil (ccy + cr) + 1;
         //--- Handle-skip ring radius for visual clearance
         double ringR = 2.5;
         //--- Walk every pixel in the bounding box
         for(int yy = byLo; yy <= byHi; yy++)
           {
            for(int xx = bxLo; xx <= bxHi; xx++)
              {
               //--- Skip pixels inside the handle rings
               double ddx, ddy;
               ddx = xx - hCx; ddy = yy - hCy; if(ddx*ddx + ddy*ddy < ringR*ringR) continue;
               ddx = xx - hRx; ddy = yy - hRy; if(ddx*ddx + ddy*ddy < ringR*ringR) continue;
               //--- Compute distance from the pixel to the disc border
               double dxp = (double)xx - ccx;
               double dyp = (double)yy - ccy;
               double dist = MathSqrt(dxp * dxp + dyp * dyp);
               double dFromBorder = MathAbs(dist - cr);
               //--- Pixels too far from the border don't contribute
               if(dFromBorder > halfThick + 1.5) continue;
               //--- Coverage decreases linearly with distance from the border centerline
               double cov = halfThick + 0.5 - dFromBorder;
               if(cov <= 0.0) continue;
               if(cov > 1.0) cov = 1.0;
               ICON_AA_PLOT(xx, yy, cov);
              }
           }
         //--- Center and border handles
         ICON_HANDLE(hCx, hCy);
         ICON_HANDLE(hRx, hRy);
         handled = true; break;
        }
      case 40:  // TOOL_ARC
        {
         //--- Quadratic Bezier arc between 2 endpoints with apex handle defining the bulge
         double W = (double)(R - L);
         double H = (double)(B - T);
         //--- Arc endpoints at BL and TR
         int p1x = L + (int)MathRound(W * 0.08);
         int p1y = B - (int)MathRound(H * 0.15);
         int p2x = R - (int)MathRound(W * 0.08);
         int p2y = T + (int)MathRound(H * 0.15);
         //--- Chord vector and unit-direction
         double chx = (double)(p2x - p1x);
         double chy = (double)(p2y - p1y);
         double cLen = MathSqrt(chx * chx + chy * chy);
         double ux = chx / cLen, uy = chy / cLen;
         double nx = -uy, ny = ux;
         //--- Bulge offset perpendicular to the chord; apex is the visual handle
         double bulge = cLen * 0.50;
         double midCx = 0.5 * ((double)p1x + (double)p2x);
         double midCy = 0.5 * ((double)p1y + (double)p2y);
         int apxX = (int)MathRound(midCx + nx * bulge);
         int apxY = (int)MathRound(midCy + ny * bulge);
         //--- Bezier control point is twice the apex offset (reflects through the apex)
         double cpX = 2.0 * (double)apxX - midCx;
         double cpY = 2.0 * (double)apxY - midCy;
         //--- Walk the Bezier in NS sample steps
         const int NS = 48;
         double ringSup = 2.5;
         double prevX, prevY;
         {
            //--- First sample at t=0 (the starting endpoint)
            double t = 0.0;
            double u = 1.0 - t;
            prevX = u*u*(double)p1x + 2.0*u*t*cpX + t*t*(double)p2x;
            prevY = u*u*(double)p1y + 2.0*u*t*cpY + t*t*(double)p2y;
         }
         for(int ii = 1; ii <= NS; ii++)
           {
            //--- Quadratic Bezier blend at parameter t
            double t = (double)ii / (double)NS;
            double u = 1.0 - t;
            double curX = u*u*(double)p1x + 2.0*u*t*cpX + t*t*(double)p2x;
            double curY = u*u*(double)p1y + 2.0*u*t*cpY + t*t*(double)p2y;
            //--- Skip segments that pass too close to any handle ring
            bool skip = false;
            double dxh, dyh;
            dxh = prevX - p1x; dyh = prevY - p1y; if(dxh*dxh + dyh*dyh < ringSup*ringSup) skip = true;
            if(!skip) { dxh = prevX - p2x; dyh = prevY - p2y; if(dxh*dxh + dyh*dyh < ringSup*ringSup) skip = true; }
            if(!skip) { dxh = prevX - apxX; dyh = prevY - apxY; if(dxh*dxh + dyh*dyh < ringSup*ringSup) skip = true; }
            if(!skip) { dxh = curX  - p1x; dyh = curY  - p1y; if(dxh*dxh + dyh*dyh < ringSup*ringSup) skip = true; }
            if(!skip) { dxh = curX  - p2x; dyh = curY  - p2y; if(dxh*dxh + dyh*dyh < ringSup*ringSup) skip = true; }
            if(!skip) { dxh = curX  - apxX; dyh = curY  - apxY; if(dxh*dxh + dyh*dyh < ringSup*ringSup) skip = true; }
            //--- Render the segment if it cleared the skip check
            if(!skip)
               ICON_LINE(prevX, prevY, curX, curY);
            prevX = curX; prevY = curY;
           }
         //--- Chord line between the endpoints (the arc's straight reference)
         ICON_LINE_BETWEEN(p1x, p1y, p2x, p2y);
         //--- Handles at the two endpoints and the apex
         ICON_HANDLE(p1x, p1y);
         ICON_HANDLE(p2x, p2y);
         ICON_HANDLE(apxX, apxY);
         handled = true; break;
        }
      case 41:  // TOOL_CURVE
        {
         //--- Quadratic Bezier curve (similar to ARC but with reversed perpendicular direction)
         double W = (double)(R - L);
         double H = (double)(B - T);
         //--- Curve endpoints at BL and TR (more centered than ARC)
         int p1x = L + (int)MathRound(W * 0.15);
         int p1y = B - (int)MathRound(H * 0.25);
         int p2x = R - (int)MathRound(W * 0.15);
         int p2y = T + (int)MathRound(H * 0.25);
         //--- Chord and unit-direction (perpendicular reversed vs ARC for opposite bulge)
         double chx = (double)(p2x - p1x);
         double chy = (double)(p2y - p1y);
         double cLen = MathSqrt(chx * chx + chy * chy);
         double ux = chx / cLen, uy = chy / cLen;
         double nx =  uy, ny = -ux;
         //--- Bulge offset and apex position
         double bulge = cLen * 0.30;
         double midCx = 0.5 * ((double)p1x + (double)p2x);
         double midCy = 0.5 * ((double)p1y + (double)p2y);
         int apxX = (int)MathRound(midCx + nx * bulge);
         int apxY = (int)MathRound(midCy + ny * bulge);
         //--- Bezier control point reflects through the apex
         double cpX = 2.0 * (double)apxX - midCx;
         double cpY = 2.0 * (double)apxY - midCy;
         //--- Sample the Bezier curve with the same NS=48 algorithm as ARC
         const int NS = 48;
         double ringSup = 2.5;
         double prevX, prevY;
         {
            double t = 0.0;
            double u = 1.0 - t;
            prevX = u*u*(double)p1x + 2.0*u*t*cpX + t*t*(double)p2x;
            prevY = u*u*(double)p1y + 2.0*u*t*cpY + t*t*(double)p2y;
         }
         for(int ii = 1; ii <= NS; ii++)
           {
            //--- Quadratic Bezier blend at parameter t
            double t = (double)ii / (double)NS;
            double u = 1.0 - t;
            double curX = u*u*(double)p1x + 2.0*u*t*cpX + t*t*(double)p2x;
            double curY = u*u*(double)p1y + 2.0*u*t*cpY + t*t*(double)p2y;
            //--- Skip segments passing too close to any handle
            bool skip = false;
            double dxh, dyh;
            dxh = prevX - p1x; dyh = prevY - p1y; if(dxh*dxh + dyh*dyh < ringSup*ringSup) skip = true;
            if(!skip) { dxh = prevX - p2x; dyh = prevY - p2y; if(dxh*dxh + dyh*dyh < ringSup*ringSup) skip = true; }
            if(!skip) { dxh = prevX - apxX; dyh = prevY - apxY; if(dxh*dxh + dyh*dyh < ringSup*ringSup) skip = true; }
            if(!skip) { dxh = curX  - p1x; dyh = curY  - p1y; if(dxh*dxh + dyh*dyh < ringSup*ringSup) skip = true; }
            if(!skip) { dxh = curX  - p2x; dyh = curY  - p2y; if(dxh*dxh + dyh*dyh < ringSup*ringSup) skip = true; }
            if(!skip) { dxh = curX  - apxX; dyh = curY  - apxY; if(dxh*dxh + dyh*dyh < ringSup*ringSup) skip = true; }
            //--- Render the segment if it cleared the skip check
            if(!skip)
               ICON_LINE(prevX, prevY, curX, curY);
            prevX = curX; prevY = curY;
           }
         //--- Three handles (no chord line - Curve has no straight reference)
         ICON_HANDLE(p1x, p1y);
         ICON_HANDLE(p2x, p2y);
         ICON_HANDLE(apxX, apxY);
         handled = true; break;
        }
      case 42:  // TOOL_ARROW
        {
         //--- Arrow shaft + filled triangular arrowhead at the tip
         int h1x = L, h1y = B;
         int h2x = R, h2y = T;
         //--- Unit direction of the arrow
         double dxf = h2x - h1x, dyf = h2y - h1y;
         double lenf = MathSqrt(dxf * dxf + dyf * dyf);
         double ux = 0.0, uy = 0.0;
         if(lenf > 0.001) { ux = dxf / lenf; uy = dyf / lenf; }
         //--- Pull the tip slightly inward so it sits just before the handle ring
         int ringR = 2;
         int tipPull = ringR + 1;
         int tipX = h2x - (int)MathRound(ux * tipPull);
         int tipY = h2y - (int)MathRound(uy * tipPull);
         //--- Arrowhead geometry: length along the shaft, half-width perpendicular
         double ahLen  = 6.5;
         double ahWide = 3.5;
         double baseCx = tipX - ux * ahLen;
         double baseCy = tipY - uy * ahLen;
         //--- Perpendicular direction for the two arrowhead corners
         double nx = -uy, ny = ux;
         double triBRx = baseCx + nx * ahWide;
         double triBRy = baseCy + ny * ahWide;
         double triBLx = baseCx - nx * ahWide;
         double triBLy = baseCy - ny * ahWide;
         //--- Shaft from h1 to the arrowhead base midpoint
         int baseMidXi = (int)MathRound(baseCx);
         int baseMidYi = (int)MathRound(baseCy);
         ICON_LINE_BETWEEN(h1x, h1y, baseMidXi, baseMidYi);
         //--- Filled-triangle arrowhead using barycentric sign tests
         double vAx = (double)tipX, vAy = (double)tipY;
         double vBx = triBRx,       vBy = triBRy;
         double vCx = triBLx,       vCy = triBLy;
         //--- Bounding box of the triangle for the per-pixel fill loop
         int triMinX = (int)MathFloor(MathMin(MathMin(vAx, vBx), vCx)) - 1;
         int triMaxX = (int)MathCeil (MathMax(MathMax(vAx, vBx), vCx)) + 1;
         int triMinY = (int)MathFloor(MathMin(MathMin(vAy, vBy), vCy)) - 1;
         int triMaxY = (int)MathCeil (MathMax(MathMax(vAy, vBy), vCy)) + 1;
         //--- Skip-zone radius around the tip-end handle
         double ringSup = 2.5;
         //--- Walk every pixel in the bounding box and test triangle inclusion
         for(int yy = triMinY; yy <= triMaxY; yy++)
           {
            for(int xx = triMinX; xx <= triMaxX; xx++)
              {
               //--- Skip pixels too close to the tip handle ring
               double ddxh = xx - h2x;
               double ddyh = yy - h2y;
               if(ddxh * ddxh + ddyh * ddyh < ringSup * ringSup) continue;
               //--- Compute signs of pixel relative to each triangle edge
               double d1 = ((double)xx - vBx) * (vAy - vBy) - (vAx - vBx) * ((double)yy - vBy);
               double d2 = ((double)xx - vCx) * (vBy - vCy) - (vBx - vCx) * ((double)yy - vCy);
               double d3 = ((double)xx - vAx) * (vCy - vAy) - (vCx - vAx) * ((double)yy - vAy);
               //--- Inside the triangle iff all signs are the same (no mix of positive and negative)
               bool hasNeg = (d1 < 0) || (d2 < 0) || (d3 < 0);
               bool hasPos = (d1 > 0) || (d2 > 0) || (d3 > 0);
               if(hasNeg && hasPos) continue;
               ICON_AA_PLOT(xx, yy, 1.0);
              }
           }
         //--- Handles at the shaft anchor and the tip
         ICON_HANDLE(h1x, h1y);
         ICON_HANDLE(h2x, h2y);
         handled = true; break;
        }
      case 43:  // TOOL_ARROW_MARKER
        {
         //--- Solid arrow marker (no shaft separation - silhouette tapers from tail to tip)
         int h1x = L, h1y = B;
         int h2x = R, h2y = T;
         //--- Unit direction of the marker
         double dxf = h2x - h1x, dyf = h2y - h1y;
         double lenf = MathSqrt(dxf * dxf + dyf * dyf);
         if(lenf > 0.001)
           {
            //--- Unit vector and perpendicular for the silhouette geometry
            double ux = dxf / lenf, uy = dyf / lenf;
            double nx = -uy, ny = ux;
            //--- Head starts at 70% along the shaft
            double headStartAlong = lenf * 0.70;
            double hsX = (double)h1x + ux * headStartAlong;
            double hsY = (double)h1y + uy * headStartAlong;
            //--- Shaft half-width vs head half-width
            double shaftHalfW = lenf * 0.060;
            double headHalfW  = lenf * 0.140;
            //--- 6 silhouette vertices (CW from tail-tip)
            double v0x = (double)h1x,             v0y = (double)h1y;
            double v1x = hsX + nx * shaftHalfW,   v1y = hsY + ny * shaftHalfW;
            double v2x = hsX + nx * headHalfW,    v2y = hsY + ny * headHalfW;
            double v3x = (double)h2x,             v3y = (double)h2y;
            double v4x = hsX - nx * headHalfW,    v4y = hsY - ny * headHalfW;
            double v5x = hsX - nx * shaftHalfW,   v5y = hsY - ny * shaftHalfW;
            //--- Render the closed silhouette as 6 line segments
            ICON_LINE(v0x, v0y, v1x, v1y);
            ICON_LINE(v1x, v1y, v2x, v2y);
            ICON_LINE(v2x, v2y, v3x, v3y);
            ICON_LINE(v3x, v3y, v4x, v4y);
            ICON_LINE(v4x, v4y, v5x, v5y);
            ICON_LINE(v5x, v5y, v0x, v0y);
           }
         handled = true; break;
        }
      case 44:  // TOOL_NOTE
        {
         //--- Note icon: rectangle box with a "T" inside and a connector line down to a handle
         double W = (double)(R - L);
         double H = (double)(B - T);
         //--- Note rectangle bounds (top half of icon)
         int recL = L + (int)MathRound(W * 0.12);
         int recR = R - (int)MathRound(W * 0.12);
         int recT = T + (int)MathRound(H * 0.10);
         int recB = T + (int)MathRound(H * 0.60);
         //--- Rectangle outline
         ICON_LINE(recL, recT, recR, recT);
         ICON_LINE(recR, recT, recR, recB);
         ICON_LINE(recR, recB, recL, recB);
         ICON_LINE(recL, recB, recL, recT);
         //--- Tiny "T" inside the rectangle (top-bar plus stem)
         int recCX = (recL + recR) / 2;
         int tBarY = recT + (int)MathRound((double)(recB - recT) * 0.22);
         int tBarL = recCX - (int)MathRound((double)(recR - recL) * 0.22);
         int tBarR = recCX + (int)MathRound((double)(recR - recL) * 0.22);
         int tStemBot = recB - (int)MathRound((double)(recB - recT) * 0.22);
         ICON_LINE(tBarL, tBarY, tBarR, tBarY);
         ICON_LINE(recCX, tBarY, recCX, tStemBot);
         //--- Anchor handle and connector down to the rectangle's bottom-center
         int dotY = B - (int)MathRound(H * 0.08);
         ICON_LINE_FROM_HANDLE(recCX, dotY, recCX, recB);
         ICON_HANDLE(recCX, dotY);
         handled = true; break;
        }
      case 45:  // TOOL_PRICE_NOTE
        {
         //--- Price-note icon: rectangle box with a "$"-style glyph inside + handle connector
         double W = (double)(R - L);
         double H = (double)(B - T);
         //--- Rectangle bounds (top half of icon)
         int recL = L + (int)MathRound(W * 0.12);
         int recR = R - (int)MathRound(W * 0.12);
         int recT = T + (int)MathRound(H * 0.10);
         int recB = T + (int)MathRound(H * 0.60);
         //--- Rectangle outline
         ICON_LINE(recL, recT, recR, recT);
         ICON_LINE(recR, recT, recR, recB);
         ICON_LINE(recR, recB, recL, recB);
         ICON_LINE(recL, recB, recL, recT);
         //--- "$" glyph inside the rectangle: top and bottom Z-shapes
         int recCX = (recL + recR) / 2;
         double gW = W * 0.14;
         double gH = (double)(recB - recT) * 0.24;
         int gL = recCX - (int)MathRound(gW);
         int gR = recCX + (int)MathRound(gW);
         int gT = (int)MathRound((recT + recB) * 0.5 - gH);
         int gB = (int)MathRound((recT + recB) * 0.5 + gH);
         int gMidY = (gT + gB) / 2;
         //--- Top half of $: horizontal top, right side, horizontal mid
         ICON_LINE(gL, gT, gR, gT);
         ICON_LINE(gR, gT, gR, gMidY);
         ICON_LINE(gL, gMidY, gR, gMidY);
         //--- Bottom half of $: left side from mid, horizontal bottom
         ICON_LINE(gL, gMidY, gL, gB);
         ICON_LINE(gL, gB, gR, gB);
         //--- Vertical slash through the $
         int slashTop = gT - (int)MathRound(gH * 0.15);
         int slashBot = gB + (int)MathRound(gH * 0.15);
         ICON_LINE(recCX, slashTop, recCX, slashBot);
         //--- Anchor handle and connector down to the rectangle
         int dotY = B - (int)MathRound(H * 0.08);
         ICON_LINE_FROM_HANDLE(recCX, dotY, recCX, recB);
         ICON_HANDLE(recCX, dotY);
         handled = true; break;
        }
      case 46:  // TOOL_CALLOUT
        {
         //--- Callout box with a triangular tail pointing down-left to the anchor
         double W = (double)(R - L);
         double H = (double)(B - T);
         //--- Callout rectangle bounds
         int recL = L + (int)MathRound(W * 0.20);
         int recR = R - (int)MathRound(W * 0.10);
         int recT = T + (int)MathRound(H * 0.12);
         int recB = T + (int)MathRound(H * 0.62);
         //--- Tail base: two X positions on the rectangle's bottom edge
         int a1x = recL;
         int a2x = recL + (int)MathRound(W * 0.18);
         int ay  = recB;
         //--- Tail tip below-left of the box
         int tipX = recL;
         int tipY = B - (int)MathRound(H * 0.18);
         //--- Top, right, and partial bottom edges of the rectangle
         ICON_LINE(recL, recT, recR, recT);
         ICON_LINE(recR, recT, recR, recB);
         ICON_LINE(recR, recB, a2x, recB);
         //--- Tail right side from base to tip
         ICON_LINE(a2x, ay, tipX, tipY);
         //--- Tail left side from tip back to the rectangle's bottom-left
         ICON_LINE(tipX, tipY, a1x, ay);
         //--- Left side of the rectangle
         ICON_LINE(recL, recB, recL, recT);
         handled = true; break;
        }
      case 47:  // TOOL_COMMENT
        {
         //--- Comment icon: rounded rectangle outline rendered via supersampled HR canvas downsampling
         double W = (double)(R - L);
         double H = (double)(B - T);
         //--- Comment rectangle bounds in icon coords
         int recL = (int)MathRound((double)L + W * 0.08);
         int recR = (int)MathRound((double)R - W * 0.08);
         int recT = (int)MathRound((double)T + H * 0.22);
         int recB = (int)MathRound((double)T + H * 0.82);
         int recH = recB - recT;
         //--- Corner radius for the rounded rectangle
         int bigR = recH / 2;
         int recW = recR - recL;
         //--- Supersample factor and HR canvas dimensions (with margin for AA at edges)
         const int SS = 4;
         int hrMargin = 1;
         int hrW = (recW + 2 * hrMargin) * SS;
         int hrH = (recH + 2 * hrMargin) * SS;
         //--- Allocate an offscreen HR canvas for the rounded-rect rasterization
         CCanvas tmpHR;
         if(!tmpHR.Create("CommentIconHR_tmp", hrW, hrH, COLOR_FORMAT_ARGB_NORMALIZE))
            break;
         //--- Start with fully transparent HR canvas
         tmpHR.Erase(0x00000000);
         //--- HR canvas margin offset
         int offX = hrMargin * SS;
         int offY = hrMargin * SS;
         //--- Outer rounded-rect bounds in HR canvas coords
         int outerL = offX;
         int outerT = offY;
         int outerR = offX + recW * SS;
         int outerB = offY + recH * SS;
         int outerR_corner = bigR * SS;
         //--- Solid white fills for the rounded rectangle (filled then carved hollow)
         uint solid = 0xFFFFFFFF;
         //--- Three rounded corners (TL, TR, BR; BL is the speech-bubble tail base)
         tmpHR.FillCircle(outerL + outerR_corner,         outerT + outerR_corner,         outerR_corner, solid);
         tmpHR.FillCircle(outerR - outerR_corner - 1,     outerT + outerR_corner,         outerR_corner, solid);
         tmpHR.FillCircle(outerR - outerR_corner - 1,     outerB - outerR_corner - 1,     outerR_corner, solid);
         //--- Three rectangles that connect the corner discs into a complete rounded rect
         tmpHR.FillRectangle(outerL,                         outerT + outerR_corner,
                              outerR - outerR_corner - 1,     outerB - 1, solid);
         tmpHR.FillRectangle(outerL + outerR_corner,         outerT,
                              outerR - outerR_corner - 1,     outerB - 1, solid);
         tmpHR.FillRectangle(outerR - outerR_corner,         outerT + outerR_corner,
                              outerR - 1,                     outerB - outerR_corner - 1, solid);
         //--- Inner rounded-rect bounds (carved out to leave just the border)
         int innerL = outerL + SS;
         int innerT = outerT + SS;
         int innerR = outerR - SS;
         int innerB = outerB - SS;
         int innerCornerR = outerR_corner - SS;
         //--- Clamp the inner corner radius to 0 if it goes negative
         if(innerCornerR < 0) innerCornerR = 0;
         //--- Carve the 3 inner corners with transparent pixels
         if(innerCornerR > 0)
           {
            tmpHR.FillCircle(innerL + innerCornerR,           innerT + innerCornerR,           innerCornerR, 0x00000000);
            tmpHR.FillCircle(innerR - innerCornerR - 1,       innerT + innerCornerR,           innerCornerR, 0x00000000);
            tmpHR.FillCircle(innerR - innerCornerR - 1,       innerB - innerCornerR - 1,       innerCornerR, 0x00000000);
           }
         //--- Carve the inner rectangles (matching the outer pattern)
         tmpHR.FillRectangle(innerL,                          innerT + innerCornerR,
                              innerR - innerCornerR - 1,      innerB - 1, 0x00000000);
         tmpHR.FillRectangle(innerL + innerCornerR,           innerT,
                              innerR - innerCornerR - 1,      innerB - 1, 0x00000000);
         tmpHR.FillRectangle(innerR - innerCornerR,           innerT + innerCornerR,
                              innerR - 1,                     innerB - innerCornerR - 1, 0x00000000);
         //--- Downsample the HR canvas to the icon canvas via SSxSS pixel averaging
         int ss2 = SS * SS;
         for(int py = -hrMargin; py < recH + hrMargin; py++)
           {
            //--- Y position in the HR canvas
            int hy = (py + hrMargin) * SS;
            for(int px = -hrMargin; px < recW + hrMargin; px++)
              {
               //--- X position in the HR canvas
               int hx = (px + hrMargin) * SS;
               //--- Average the alpha across an SSxSS subpixel block
               int sumA = 0;
               for(int dy = 0; dy < SS; dy++)
                  for(int dx = 0; dx < SS; dx++)
                    {
                     uint p = tmpHR.PixelGet(hx + dx, hy + dy);
                     sumA += (int)((p >> 24) & 0xFF);
                    }
               int avgA = sumA / ss2;
               if(avgA <= 0) continue;
               //--- Place the downsampled pixel onto the target canvas via AA blend
               double cov = (double)avgA / 255.0;
               int targetX = recL + px;
               int targetY = recT + py;
               ICON_AA_PLOT(targetX, targetY, cov);
              }
           }
         //--- Free the HR scratch canvas
         tmpHR.Destroy();
         handled = true; break;
        }
      //--- Tools without a registered canvas icon return handled=false so the caller falls back to Wingdings
      default: break;
     }

   //--- Clean up the icon-rendering macros so they don't leak into other compilation units
   #undef ICON_LINE
   #undef ICON_LINE_BETWEEN
   #undef ICON_LINE_FROM_HANDLE
   #undef ICON_PIXEL_F
   #undef ICON_AA_PLOT
   #undef ICON_HANDLE
   return handled;
  }

//+------------------------------------------------------------------+
//| Extend a line segment to the canvas edges (ray/extended-line)    |
//+------------------------------------------------------------------+
void CLineTools::ExtendLineToEdges(int canvasW, int canvasH,
                                    int x1, int y1, int x2, int y2,
                                    int &ox1, int &oy1, int &ox2, int &oy2,
                                    bool leftExtend, bool rightExtend)
  {
   //--- Start with the original endpoints; we mutate only the extended ends
   ox1 = x1; oy1 = y1; ox2 = x2; oy2 = y2;
   //--- Vertical line case: slope is undefined, so extend along Y instead
   if(x1 == x2)
     {
      if(leftExtend)  oy1 = 0;
      if(rightExtend) oy2 = canvasH - 1;
      return;
     }
   //--- General case: compute slope and project to the canvas left/right edge
   double slope = (double)(y2 - y1) / (x2 - x1);
   if(leftExtend)
     {
      //--- Project to X=0 (left edge)
      ox1 = 0;
      oy1 = (int)(y1 + slope * (0 - x1));
     }
   if(rightExtend)
     {
      //--- Project to X=canvasW-1 (right edge)
      ox2 = canvasW - 1;
      oy2 = (int)(y1 + slope * (canvasW - 1 - x1));
     }
  }

//+------------------------------------------------------------------+
//| Compute the distance from a point to a finite line segment       |
//+------------------------------------------------------------------+
double CLineTools::PointToSegmentDistance(int mx, int my, int x1, int y1, int x2, int y2)
  {
   //--- Segment vector and its squared length
   double dx = x2 - x1, dy = y2 - y1;
   double lenSq = dx * dx + dy * dy;
   //--- Degenerate segment (P1==P2): fall back to point-to-point distance
   if(lenSq < 1e-6) return MathSqrt((double)((mx-x1)*(mx-x1)+(my-y1)*(my-y1)));
   //--- Project the cursor onto the segment; clamp parameter to [0,1] for finite segment
   double t = MathMax(0.0, MathMin(1.0, ((mx-x1)*dx + (my-y1)*dy) / lenSq));
   //--- Compute the perpendicular vector from cursor to the projected foot
   double px = x1 + t * dx - mx;
   double py = y1 + t * dy - my;
   return MathSqrt(px*px + py*py);
  }

//+------------------------------------------------------------------+
//| Draw a finite trend line between two points + optional handles   |
//+------------------------------------------------------------------+
void CLineTools::DrawTrendLineOn(CCanvas &canvas, int x1, int y1, int x2, int y2,
                                  color objColor, bool selected, bool hovered,
                                  int lineWidth = 2, int lineOpacity = 100,
                                  int lineStyle = 0)
  {
   //--- Apply the user-controlled per-object opacity to the stroke color
   const uint  argb = ColorWithPercentOpacity(objColor, lineOpacity);
   //--- Clamp line width into the [1, 4] px range
   if(lineWidth < 1) lineWidth = 1;
   if(lineWidth > 4) lineWidth = 4;
   //--- Clamp line style into the [0, 3] range (solid/dashed/dotted/dash-dot)
   if(lineStyle < 0) lineStyle = 0;
   if(lineStyle > 3) lineStyle = 3;
   //--- Solid style 0 uses the thick-line primitive directly
   if(lineStyle == 0)
     {
      DrawThickLine(canvas, x1, y1, x2, y2, lineWidth, argb);
     }
   else
     {
      //--- Dashed/dotted styles build a stroke pattern and call the dashed AA path
      int pat[];
      const int n = BuildLineStylePattern(lineStyle, lineWidth, pat);
      if(n > 0)
        {
         WidgetDashedLineAA(canvas, x1, y1, x2, y2, lineWidth, argb, pat);
        }
      else
        {
         //--- Fallback to solid when the pattern builder produced no segments
         DrawThickLine(canvas, x1, y1, x2, y2, lineWidth, argb);
        }
     }
   //--- Render handles at the two endpoints when the object is selected or hovered
   if(selected || hovered)
     {
      if(m_hideHandleIdx != 0)
         DrawHandleOnCanvas(canvas, x1, y1, selected, objColor, m_haloHandleIdx == 0);
      if(m_hideHandleIdx != 1)
         DrawHandleOnCanvas(canvas, x2, y2, selected, objColor, m_haloHandleIdx == 1);
     }
  }

//+------------------------------------------------------------------+
//| Draw a full-width horizontal line at row Y + optional handle     |
//+------------------------------------------------------------------+
void CLineTools::DrawHorizontalLineOn(CCanvas &canvas, int y,
                                       color objColor, bool selected, bool hovered,
                                       int lineWidth = 2, int lineOpacity = 100,
                                       int lineStyle = 0)
  {
   //--- Cache canvas width and compose stroke color
   int   cW = canvas.Width();
   const uint argb = ColorWithPercentOpacity(objColor, lineOpacity);
   //--- Clamp line width and style into supported ranges
   if(lineWidth < 1) lineWidth = 1;
   if(lineWidth > 4) lineWidth = 4;
   if(lineStyle < 0) lineStyle = 0;
   if(lineStyle > 3) lineStyle = 3;
   //--- Solid style 0 uses the thick-line primitive directly
   if(lineStyle == 0)
     {
      DrawThickLine(canvas, 0, y, cW - 1, y, lineWidth, argb);
     }
   else
     {
      //--- Dashed styles build a stroke pattern; fall back to solid on empty pattern
      int pat[];
      const int n = BuildLineStylePattern(lineStyle, lineWidth, pat);
      if(n > 0)
         WidgetDashedLineAA(canvas, 0, y, cW - 1, y, lineWidth, argb, pat);
      else
         DrawThickLine(canvas, 0, y, cW - 1, y, lineWidth, argb);
     }
   //--- Single handle positioned 150px from the right edge (with fallback for narrow canvases)
   if(selected || hovered)
     {
      int handleX = cW - 150;
      if(handleX < 20) handleX = cW - 20;
      if(m_hideHandleIdx != 0)
         DrawHandleOnCanvas(canvas, handleX, y, selected, objColor, m_haloHandleIdx == 0);
     }
  }

//+------------------------------------------------------------------+
//| Draw a full-height vertical line at column X + optional handle   |
//+------------------------------------------------------------------+
void CLineTools::DrawVerticalLineOn(CCanvas &canvas, int x,
                                     color objColor, bool selected, bool hovered,
                                     int lineWidth = 2, int lineOpacity = 100,
                                     int lineStyle = 0)
  {
   //--- Cache canvas height and compose stroke color
   int   cH = canvas.Height();
   const uint argb = ColorWithPercentOpacity(objColor, lineOpacity);
   //--- Clamp line width and style into supported ranges
   if(lineWidth < 1) lineWidth = 1;
   if(lineWidth > 4) lineWidth = 4;
   if(lineStyle < 0) lineStyle = 0;
   if(lineStyle > 3) lineStyle = 3;
   //--- Solid style 0 uses the thick-line primitive directly
   if(lineStyle == 0)
     {
      DrawThickLine(canvas, x, 0, x, cH - 1, lineWidth, argb);
     }
   else
     {
      //--- Dashed styles build a stroke pattern; fall back to solid on empty pattern
      int pat[];
      const int n = BuildLineStylePattern(lineStyle, lineWidth, pat);
      if(n > 0)
         WidgetDashedLineAA(canvas, x, 0, x, cH - 1, lineWidth, argb, pat);
      else
         DrawThickLine(canvas, x, 0, x, cH - 1, lineWidth, argb);
     }
   //--- Single handle positioned 150px from the bottom edge (with fallback for short canvases)
   if(selected || hovered)
     {
      int handleY = cH - 150;
      if(handleY < 20) handleY = cH - 20;
      if(m_hideHandleIdx != 0)
         DrawHandleOnCanvas(canvas, x, handleY, selected, objColor, m_haloHandleIdx == 0);
     }
  }

//+------------------------------------------------------------------+
//| Draw a cross line (full-canvas H + V meeting at the intersection)|
//+------------------------------------------------------------------+
void CLineTools::DrawCrossLineOn(CCanvas &canvas, int cx, int cy,
                                  color objColor, bool selected, bool hovered,
                                  int lineWidth = 2, int lineOpacity = 100,
                                  int lineStyle = 0)
  {
   //--- Cache canvas extents and compose stroke color
   int   cW = canvas.Width();
   int   cH = canvas.Height();
   const uint argb = ColorWithPercentOpacity(objColor, lineOpacity);
   //--- Clamp line width and style into supported ranges
   if(lineWidth < 1) lineWidth = 1;
   if(lineWidth > 4) lineWidth = 4;
   if(lineStyle < 0) lineStyle = 0;
   if(lineStyle > 3) lineStyle = 3;
   //--- Solid style 0 uses the thick-line primitive directly for both arms of the cross
   if(lineStyle == 0)
     {
      DrawThickLine(canvas, 0,  cy, cW - 1, cy,     lineWidth, argb);
      DrawThickLine(canvas, cx, 0,  cx,     cH - 1, lineWidth, argb);
     }
   else
     {
      //--- Dashed styles build a stroke pattern and call the dashed AA path for both arms
      int pat[];
      const int n = BuildLineStylePattern(lineStyle, lineWidth, pat);
      if(n > 0)
        {
         WidgetDashedLineAA(canvas, 0,  cy, cW - 1, cy,     lineWidth, argb, pat);
         WidgetDashedLineAA(canvas, cx, 0,  cx,     cH - 1, lineWidth, argb, pat);
        }
      else
        {
         //--- Fallback to solid when the pattern builder produced no segments
         DrawThickLine(canvas, 0,  cy, cW - 1, cy,     lineWidth, argb);
         DrawThickLine(canvas, cx, 0,  cx,     cH - 1, lineWidth, argb);
        }
     }
   //--- Single handle at the intersection (2-DOF drag for the whole cross)
   if(selected || hovered)
     {
      if(m_hideHandleIdx != 0)
         DrawHandleOnCanvas(canvas, cx, cy, selected, objColor, m_haloHandleIdx == 0);
     }
  }

//+------------------------------------------------------------------+
//| Draw a ray line - extends from P1 through P2 to the canvas edge  |
//+------------------------------------------------------------------+
void CLineTools::DrawRayLineOn(CCanvas &canvas, int x1, int y1, int x2, int y2,
                                color objColor, bool selected, bool hovered,
                                int lineWidth = 2, int lineOpacity = 100,
                                int lineStyle = 0)
  {
   //--- Project the segment outward in the P1->P2 direction only (right-extend the line)
   int ex1 = x1, ey1 = y1, ex2 = x2, ey2 = y2;
   ExtendLineToEdges(canvas.Width(), canvas.Height(),
                     x1, y1, x2, y2, ex1, ey1, ex2, ey2, false, true);
   //--- Compose stroke color and clamp width/style into supported ranges
   const uint argb = ColorWithPercentOpacity(objColor, lineOpacity);
   if(lineWidth < 1) lineWidth = 1;
   if(lineWidth > 4) lineWidth = 4;
   if(lineStyle < 0) lineStyle = 0;
   if(lineStyle > 3) lineStyle = 3;
   //--- Solid style 0 uses the thick-line primitive directly
   if(lineStyle == 0)
     {
      DrawThickLine(canvas, ex1, ey1, ex2, ey2, lineWidth, argb);
     }
   else
     {
      //--- Dashed styles build a stroke pattern; fall back to solid on empty pattern
      int pat[];
      const int n = BuildLineStylePattern(lineStyle, lineWidth, pat);
      if(n > 0)
         WidgetDashedLineAA(canvas, ex1, ey1, ex2, ey2, lineWidth, argb, pat);
      else
         DrawThickLine(canvas, ex1, ey1, ex2, ey2, lineWidth, argb);
     }
   //--- Handles at the ORIGINAL P1 and P2 positions (not the extended endpoints)
   if(selected || hovered)
     {
      if(m_hideHandleIdx != 0)
         DrawHandleOnCanvas(canvas, x1, y1, selected, objColor, m_haloHandleIdx == 0);
      if(m_hideHandleIdx != 1)
         DrawHandleOnCanvas(canvas, x2, y2, selected, objColor, m_haloHandleIdx == 1);
     }
  }

//+------------------------------------------------------------------+
//| Draw an extended line - extends in both directions to the edges  |
//+------------------------------------------------------------------+
void CLineTools::DrawExtendedLineOn(CCanvas &canvas, int x1, int y1, int x2, int y2,
                                     color objColor, bool selected, bool hovered,
                                     int lineWidth = 2, int lineOpacity = 100,
                                     int lineStyle = 0)
  {
   //--- Project the segment outward in BOTH directions to the canvas edges
   int ex1 = x1, ey1 = y1, ex2 = x2, ey2 = y2;
   ExtendLineToEdges(canvas.Width(), canvas.Height(),
                     x1, y1, x2, y2, ex1, ey1, ex2, ey2, true, true);
   //--- Compose stroke color and clamp width/style into supported ranges
   const uint argb = ColorWithPercentOpacity(objColor, lineOpacity);
   if(lineWidth < 1) lineWidth = 1;
   if(lineWidth > 4) lineWidth = 4;
   if(lineStyle < 0) lineStyle = 0;
   if(lineStyle > 3) lineStyle = 3;
   //--- Solid style 0 uses the thick-line primitive directly
   if(lineStyle == 0)
     {
      DrawThickLine(canvas, ex1, ey1, ex2, ey2, lineWidth, argb);
     }
   else
     {
      //--- Dashed styles build a stroke pattern; fall back to solid on empty pattern
      int pat[];
      const int n = BuildLineStylePattern(lineStyle, lineWidth, pat);
      if(n > 0)
         WidgetDashedLineAA(canvas, ex1, ey1, ex2, ey2, lineWidth, argb, pat);
      else
         DrawThickLine(canvas, ex1, ey1, ex2, ey2, lineWidth, argb);
     }
   //--- Handles at the ORIGINAL P1 and P2 positions (not the extended endpoints)
   if(selected || hovered)
     {
      if(m_hideHandleIdx != 0)
         DrawHandleOnCanvas(canvas, x1, y1, selected, objColor, m_haloHandleIdx == 0);
      if(m_hideHandleIdx != 1)
         DrawHandleOnCanvas(canvas, x2, y2, selected, objColor, m_haloHandleIdx == 1);
     }
  }

//+------------------------------------------------------------------+
//| Draw an info line + floating panel showing price/bars/time/angle |
//+------------------------------------------------------------------+
void CLineTools::DrawInfoLineOn(CCanvas &canvas, int x1, int y1, int x2, int y2,
                                 color objColor, datetime t1, datetime t2,
                                 double p1, double p2,
                                 bool selected, bool hovered, bool isDarkTheme,
                                 int lineWidth = 2, int lineOpacity = 100,
                                 int lineStyle = 0)
  {
   //--- Compose stroke color and clamp line width/style into supported ranges
   const uint argb = ColorWithPercentOpacity(objColor, lineOpacity);
   if(lineWidth < 1) lineWidth = 1;
   if(lineWidth > 4) lineWidth = 4;
   if(lineStyle < 0) lineStyle = 0;
   if(lineStyle > 3) lineStyle = 3;
   //--- Draw the underlying line segment between P1 and P2 with the selected style
   if(lineStyle == 0)
     {
      DrawThickLine(canvas, x1, y1, x2, y2, lineWidth, argb);
     }
   else
     {
      //--- Dashed styles build a stroke pattern; fall back to solid on empty pattern
      int pat[];
      const int n = BuildLineStylePattern(lineStyle, lineWidth, pat);
      if(n > 0)
         WidgetDashedLineAA(canvas, x1, y1, x2, y2, lineWidth, argb, pat);
      else
         DrawThickLine(canvas, x1, y1, x2, y2, lineWidth, argb);
     }
   //--- Endpoint handles (selected/hovered) honoring hide and halo state
   if(selected || hovered)
     {
      if(m_hideHandleIdx != 0)
         DrawHandleOnCanvas(canvas, x1, y1, selected, objColor, m_haloHandleIdx == 0);
      if(m_hideHandleIdx != 1)
         DrawHandleOnCanvas(canvas, x2, y2, selected, objColor, m_haloHandleIdx == 1);
     }

   //--- Compute price change, percentage, and pips (using symbol's point/digits)
   double pointSize = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   long   digits    = SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   //--- Pip size = 10x point for 3/5-digit symbols, 1x point for others
   double pipSize   = (digits == 3 || digits == 5) ? pointSize * 10.0 : pointSize;
   double priceDiff = p2 - p1;
   double pips      = priceDiff / pipSize;
   double pctChange = (p1 != 0.0) ? (priceDiff / p1) * 100.0 : 0.0;

   //--- Compute bar count and duration over the time delta between P1 and P2
   long   secondsDelta = (long)(t2 - t1);
   if(secondsDelta < 0) secondsDelta = -secondsDelta;
   long   periodSecs   = PeriodSeconds(_Period);
   long   barCount     = (periodSecs > 0) ? (secondsDelta / periodSecs) : 0;
   //--- Break the duration into days/hours/minutes for display
   long hours   = secondsDelta / 3600;
   long minutes = (secondsDelta % 3600) / 60;
   long days    = hours / 24;
   string durStr;
   //--- Pick the most readable duration unit based on the magnitude
   if(days > 0)
      durStr = StringFormat("%dd %dh", (int)days, (int)(hours % 24));
   else if(hours > 0)
      durStr = StringFormat("%dh %dm", (int)hours, (int)minutes);
   else
      durStr = StringFormat("%dm", (int)minutes);

   //--- Compute pixel-space distance and angle for the third info row
   double dxPx = (double)(x2 - x1), dyPx = (double)(y2 - y1);
   int    pixDist = (int)MathRound(MathSqrt(dxPx*dxPx + dyPx*dyPx));
   //--- Angle measured CCW from screen-east; screen-Y inverted via -dyPx
   double angleDeg = MathArctan2(-dyPx, dxPx) * 180.0 / M_PI;

   //--- Format the 3 panel rows: price-change, bars+duration+pixels, angle
   string row1 = StringFormat("%s (%.2f%%), %.1f",
                              DoubleToString(MathAbs(priceDiff), (int)digits),
                              pctChange,
                              MathAbs(pips));
   string row2 = StringFormat("%d bars (%s), distance: %d px",
                              (int)barCount,
                              durStr,
                              pixDist);
   string row3 = StringFormat("%.2f%s",
                              angleDeg,
                              "\xB0");

   //--- Midpoint of the line + cached rotation factors (used for panel anchoring)
   int mx_line = (x1 + x2) / 2, my_line = (y1 + y2) / 2;
   double rad = angleDeg * M_PI / 180.0;
   double ca  = MathCos(rad), sa = MathSin(rad);
   double ssa = -sa;

   //--- Render the floating info panel: rounded background + 3 text rows + 3 icons
   {
      //--- Panel theming: light gray background, dark blue-gray text
      color panelBg   = C'240,240,240';
      color panelText = C'55,66,78';
      //--- Composite ARGB values for the panel background (90% alpha) and text (full)
      uint  panelBgARGB   = ColorToARGB(panelBg,   230);
      uint  panelTextARGB = ColorToARGB(panelText, 255);

      //--- Set the panel font and measure each row's dimensions
      canvas.FontSet("Arial", -90);
      int rowH1 = canvas.TextHeight(row1);
      int rowH2 = canvas.TextHeight(row2);
      int rowH3 = canvas.TextHeight(row3);
      int w1 = canvas.TextWidth(row1);
      int w2 = canvas.TextWidth(row2);
      int w3 = canvas.TextWidth(row3);
      //--- Layout constants for the panel: icon column, padding, gaps
      const int iconW   = 26;
      const int iconGap = 8;
      const int padL    = 10;
      const int padR    = 10;
      //--- Final panel dimensions sized to fit the widest row + icon column + padding
      int panelW = MathMax(w1, MathMax(w2, w3)) + padL + iconW + iconGap + padR;
      int panelH = rowH1 + rowH2 + rowH3 + 16;

      //--- Anchor the panel offset by 'gap' pixels perpendicular to the line at the midpoint
      double gap = 8.0;
      double lenLine = MathSqrt(dxPx*dxPx + dyPx*dyPx);

      //--- Choose which panel corner anchors to the line midpoint based on the angle quadrant
      bool useTopLeft;
      //--- Q1 + Q3 -> top-left anchor (panel extends down-right)
      if( (angleDeg >= 0.0   && angleDeg <= 90.0) ||
          (angleDeg <= -90.0 && angleDeg >= -180.0) )
         useTopLeft = true;
      else
         //--- Q2 + Q4 -> bottom-left anchor (panel extends up-right)
         useTopLeft = false;

      //--- Compute the perpendicular unit vector for the panel offset
      double nx, ny;
      if(lenLine < 1e-6) { nx = 1.0; ny = useTopLeft ? 1.0 : -1.0; }
      else
        {
         //--- Two candidate perpendiculars; pick the one matching the corner anchor's Y sign
         double p1x = -dyPx / lenLine, p1y = dxPx  / lenLine;
         double p2x =  dyPx / lenLine, p2y = -dxPx / lenLine;
         if(useTopLeft)
           { if(p1y > 0.0) { nx = p1x; ny = p1y; } else { nx = p2x; ny = p2y; } }
         else
           { if(p1y < 0.0) { nx = p1x; ny = p1y; } else { nx = p2x; ny = p2y; } }
        }
      //--- Normalize the perpendicular vector (defensive against zero-length lines)
      double nLen = MathSqrt(nx*nx + ny*ny);
      if(nLen < 1e-6) { nx = 1.0; ny = useTopLeft ? 1.0 : -1.0; nLen = MathSqrt(2.0); }
      nx /= nLen; ny /= nLen;

      //--- Anchor point = line midpoint offset by 'gap' pixels along the perpendicular
      int anchorX = mx_line + (int)MathRound(nx * gap);
      int anchorY = my_line + (int)MathRound(ny * gap);

      //--- Top-left corner of the panel rect (different math depending on corner anchor choice)
      int px0, py0;
      if(useTopLeft)
        { px0 = anchorX; py0 = anchorY; }
      else
        { px0 = anchorX; py0 = anchorY - panelH; }
      int cW  = canvas.Width(), cH = canvas.Height();

      //--- Cache the panel rect for the next-frame HitTestInfoLinePanel call
      m_lastInfoPanelX1 = px0;
      m_lastInfoPanelY1 = py0;
      m_lastInfoPanelX2 = px0 + panelW - 1;
      m_lastInfoPanelY2 = py0 + panelH - 1;

      //--- Round the panel corners with a 4px radius by saving/restoring corner-pixel rectangles
      int radius = 4;
      uint cornerSave[];
      int cornerSaveSize = radius * radius * 4;
      ArrayResize(cornerSave, cornerSaveSize);
      //--- Center positions of the 4 corner discs (for the rounded mask)
      int ccTL_x = px0 + radius,              ccTL_y = py0 + radius;
      int ccTR_x = px0 + panelW - 1 - radius, ccTR_y = py0 + radius;
      int ccBL_x = px0 + radius,              ccBL_y = py0 + panelH - 1 - radius;
      int ccBR_x = px0 + panelW - 1 - radius, ccBR_y = py0 + panelH - 1 - radius;
      //--- Snapshot the 4 corner rectangles so we can restore the wedges OUTSIDE the rounded mask
      int saveIdx = 0;
      for(int k = 0; k < 4; k++)
        {
         //--- Top-left corner of each corner rect
         int cornerX_ = 0, cornerY_ = 0;
         switch(k)
           {
            case 0: cornerX_ = px0;                   cornerY_ = py0;                   break;
            case 1: cornerX_ = px0 + panelW - radius; cornerY_ = py0;                   break;
            case 2: cornerX_ = px0;                   cornerY_ = py0 + panelH - radius; break;
            case 3: cornerX_ = px0 + panelW - radius; cornerY_ = py0 + panelH - radius; break;
           }
         //--- Save every pixel in the radius x radius corner rect
         for(int yy = 0; yy < radius; yy++)
            for(int xx = 0; xx < radius; xx++)
              {
               int ax = cornerX_ + xx;
               int ay = cornerY_ + yy;
               if(ax >= 0 && ax < cW && ay >= 0 && ay < cH)
                  cornerSave[saveIdx] = canvas.PixelGet(ax, ay);
               else
                  cornerSave[saveIdx] = 0x00000000;
               saveIdx++;
              }
        }

      //--- Fill the entire panel rect with the alpha-blended background color
      for(int yy = py0; yy < py0 + panelH; yy++)
        {
         //--- Skip rows outside the canvas
         if(yy < 0 || yy >= cH) continue;
         for(int xx = px0; xx < px0 + panelW; xx++)
           {
            //--- Skip columns outside the canvas
            if(xx < 0 || xx >= cW) continue;
            //--- Porter-Duff source-over compositing of the panel-bg over the existing pixel
            uint existing = canvas.PixelGet(xx, yy);
            uchar sA = 230;
            uchar sR = (uchar)((panelBg)       & 0xFF);
            uchar sG = (uchar)((panelBg >> 8)  & 0xFF);
            uchar sB = (uchar)((panelBg >> 16) & 0xFF);
            //--- Convert source and destination alpha to [0,1] floats
            double fA = sA / 255.0;
            double dA = ((existing >> 24) & 0xFF) / 255.0;
            //--- Composite alpha via standard over formula
            double outA = fA + dA * (1.0 - fA);
            if(outA <= 0.0) { canvas.PixelSet(xx, yy, 0); continue; }
            //--- Unpack destination RGB
            double eR = ((existing >> 16) & 0xFF) / 255.0;
            double eG = ((existing >>  8) & 0xFF) / 255.0;
            double eB = ( existing        & 0xFF) / 255.0;
            //--- Composite RGB via standard over formula
            double oR = (sR/255.0 * fA + eR*dA*(1.0-fA)) / outA;
            double oG = (sG/255.0 * fA + eG*dA*(1.0-fA)) / outA;
            double oB = (sB/255.0 * fA + eB*dA*(1.0-fA)) / outA;
            //--- Pack the result back into an ARGB uint and write
            uint blended = ((uint)(uchar)(outA * 255.0 + 0.5) << 24) |
                          ((uint)(uchar)(oR * 255.0 + 0.5) << 16) |
                          ((uint)(uchar)(oG * 255.0 + 0.5) <<  8) |
                           (uint)(uchar)(oB * 255.0 + 0.5);
            canvas.PixelSet(xx, yy, blended);
           }
        }

      //--- Restore the saved corner pixels at the outside-radius wedges (creates rounded corners)
      saveIdx = 0;
      for(int k = 0; k < 4; k++)
        {
         //--- Per-corner anchor coords and the corner disc's center
         int cornerX_ = 0, cornerY_ = 0;
         int ccX = 0, ccY = 0;
         switch(k)
           {
            case 0: cornerX_ = px0;                   cornerY_ = py0;                   ccX = ccTL_x; ccY = ccTL_y; break;
            case 1: cornerX_ = px0 + panelW - radius; cornerY_ = py0;                   ccX = ccTR_x; ccY = ccTR_y; break;
            case 2: cornerX_ = px0;                   cornerY_ = py0 + panelH - radius; ccX = ccBL_x; ccY = ccBL_y; break;
            case 3: cornerX_ = px0 + panelW - radius; cornerY_ = py0 + panelH - radius; ccX = ccBR_x; ccY = ccBR_y; break;
           }
         //--- Walk every pixel in the corner rect and restore the OUTSIDE-disc ones
         for(int yy = 0; yy < radius; yy++)
            for(int xx = 0; xx < radius; xx++)
              {
               int ax = cornerX_ + xx;
               int ay = cornerY_ + yy;
               //--- Distance from the corner disc's center
               double dxFromCc = (double)ax - ccX + 0.5;
               double dyFromCc = (double)ay - ccY + 0.5;
               double dist = MathSqrt(dxFromCc*dxFromCc + dyFromCc*dyFromCc);
               //--- Determine if this pixel is in the OUTSIDE wedge of its corner
               bool inWedge = false;
               if(k == 0 && ax <= ccX && ay <= ccY) inWedge = true;
               if(k == 1 && ax >= ccX && ay <= ccY) inWedge = true;
               if(k == 2 && ax <= ccX && ay >= ccY) inWedge = true;
               if(k == 3 && ax >= ccX && ay >= ccY) inWedge = true;
               //--- Outside-wedge pixels beyond the corner radius get restored to the saved color
               if(inWedge && dist > radius)
                 {
                  if(ax >= 0 && ax < cW && ay >= 0 && ay < cH)
                     canvas.PixelSet(ax, ay, cornerSave[saveIdx]);
                 }
               saveIdx++;
              }
        }

      //--- Compute text-row Y positions and render each row's string
      int textX = px0 + padL + iconW + iconGap;
      int row1Y = py0 + 4;
      int row2Y = py0 + 4 + rowH1 + 4;
      int row3Y = py0 + 4 + rowH1 + 4 + rowH2 + 4;
      canvas.TextOut(textX, row1Y, row1, panelTextARGB);
      canvas.TextOut(textX, row2Y, row2, panelTextARGB);
      canvas.TextOut(textX, row3Y, row3, panelTextARGB);

      //--- Cache the icon-column color and X-center for the inline AA icons
      uint iconARGB = panelTextARGB;
      int  iconCx   = px0 + padL + iconW / 2;

      //--- AA_PLOT: Porter-Duff source-over compositing for one pixel at integer coords
      #define AA_PLOT(xx, yy, cov) \
      { \
         int _px = (xx), _py = (yy); \
         double _c = (cov); \
         if(_c > 0.01 && _px >= 0 && _px < cW && _py >= 0 && _py < cH) \
           { \
            uchar _a = (uchar)(255.0 * _c); \
            if(_a > 0) { \
               uint _ex = canvas.PixelGet(_px, _py); \
               double _sA = _a / 255.0; \
               double _dA = ((_ex >> 24) & 0xFF) / 255.0; \
               double _oA = _sA + _dA * (1.0 - _sA); \
               if(_oA > 0.0) { \
                  double _sR = ((iconARGB >> 16) & 0xFF) / 255.0; \
                  double _sG = ((iconARGB >>  8) & 0xFF) / 255.0; \
                  double _sB = ( iconARGB        & 0xFF) / 255.0; \
                  double _dR = ((_ex >> 16) & 0xFF) / 255.0; \
                  double _dG = ((_ex >>  8) & 0xFF) / 255.0; \
                  double _dB = ( _ex        & 0xFF) / 255.0; \
                  uint _ob = ((uint)(uchar)(_oA * 255.0 + 0.5) << 24) | \
                             ((uint)(uchar)((_sR*_sA + _dR*_dA*(1.0-_sA)) / _oA * 255.0 + 0.5) << 16) | \
                             ((uint)(uchar)((_sG*_sA + _dG*_dA*(1.0-_sA)) / _oA * 255.0 + 0.5) <<  8) | \
                              (uint)(uchar)((_sB*_sA + _dB*_dA*(1.0-_sA)) / _oA * 255.0 + 0.5); \
                  canvas.PixelSet(_px, _py, _ob); \
               } \
            } \
           } \
      }

      //--- AA_PIXEL_F: place an AA pixel at floating-point coords via 4-pixel bilinear coverage
      #define AA_PIXEL_F(fx, fy) \
      { \
         double _fx = (fx), _fy = (fy); \
         int _ix0 = (int)MathFloor(_fx), _iy0 = (int)MathFloor(_fy); \
         double _dx = _fx - _ix0, _dy = _fy - _iy0; \
         AA_PLOT(_ix0,     _iy0,     (1.0 - _dx) * (1.0 - _dy)); \
         AA_PLOT(_ix0 + 1, _iy0,     _dx         * (1.0 - _dy)); \
         AA_PLOT(_ix0,     _iy0 + 1, (1.0 - _dx) * _dy);         \
         AA_PLOT(_ix0 + 1, _iy0 + 1, _dx         * _dy);         \
      }

      //--- AA_LINE: walk a line by sampling AA_PIXEL_F at evenly spaced parameter steps
      #define AA_LINE(x0, y0, x1, y1) \
      { \
         double _x0 = (x0), _y0 = (y0), _x1 = (x1), _y1 = (y1); \
         double _dxL = _x1 - _x0, _dyL = _y1 - _y0; \
         double _absDx = MathAbs(_dxL), _absDy = MathAbs(_dyL); \
         int _steps = (int)MathRound(MathMax(_absDx, _absDy)); \
         if(_steps <= 0) { AA_PIXEL_F(_x0, _y0); } \
         else { \
            for(int _s = 0; _s <= _steps; _s++) { \
               double _t = (double)_s / (double)_steps; \
               double _fx = _x0 + _dxL * _t; \
               double _fy = _y0 + _dyL * _t; \
               AA_PIXEL_F(_fx, _fy); \
            } \
         } \
      }

      //--- Row 1 icon: vertical double-headed arrow with horizontal cap-lines (price-change)
      {
         //--- Icon vertical span centered on the row
         int icY = row1Y + rowH1 / 2;
         int halfH = 8;
         int icTop = icY - halfH, icBot = icY + halfH;
         int gap_   = 2;
         //--- Top and bottom horizontal cap-lines
         canvas.LineHorizontal(iconCx - 4, iconCx + 4, icTop, iconARGB);
         canvas.LineHorizontal(iconCx - 4, iconCx + 4, icBot, iconARGB);
         //--- Vertical shaft between the cap-lines with small gaps for the arrowhead tips
         int tipTopY = icTop + gap_;
         int tipBotY = icBot - gap_;
         canvas.LineVertical(iconCx, tipTopY, tipBotY, iconARGB);
         //--- Upper arrowhead (V-shape pointing up)
         AA_LINE(iconCx, tipTopY, iconCx - 2, tipTopY + 3);
         AA_LINE(iconCx, tipTopY, iconCx + 2, tipTopY + 3);
         //--- Lower arrowhead (V-shape pointing down)
         AA_LINE(iconCx, tipBotY, iconCx - 2, tipBotY - 3);
         AA_LINE(iconCx, tipBotY, iconCx + 2, tipBotY - 3);
      }

      //--- Row 2 icon: two candlesticks (red+green) with a horizontal double-headed arrow (bars/time)
      {
         //--- Icon vertical center on the row
         int icY = row2Y + rowH2 / 2;
         //--- Candlestick body dimensions and inter-candle gap
         int candleW = 3, candleH = 7, wickExt = 2;
         int candleGap = 2;
         //--- Horizontal arrow half-width and total icon group width
         int arrowHalfW = 3;
         int arrowW = arrowHalfW * 2 + 1;
         int totalW = candleW + candleGap + arrowW + candleGap + candleW;
         //--- Left-aligned group position centered on iconCx
         int groupLeft = iconCx - totalW / 2;
         int leftCandleX  = groupLeft;
         int rightCandleX = groupLeft + totalW - candleW;
         //--- Candle body and wick Y bounds
         int bodyTop      = icY - candleH / 2;
         int bodyBot      = icY + candleH / 2;
         int wickTop      = bodyTop - wickExt;
         int wickBot      = bodyBot + wickExt;
         //--- Render the left candlestick in red (down-bar) with wick + body fill
         color redCol  = C'217,78,85';
         uint  redARGB = ColorToARGB(redCol, 255);
         canvas.LineVertical(leftCandleX + candleW / 2, wickTop, wickBot, redARGB);
         canvas.FillRectangle(leftCandleX, bodyTop,
                              leftCandleX + candleW - 1, bodyBot, redARGB);
         //--- Render the right candlestick in green (up-bar) with wick + body fill
         color grnCol  = C'38,166,154';
         uint  grnARGB = ColorToARGB(grnCol, 255);
         canvas.LineVertical(rightCandleX + candleW / 2, wickTop, wickBot, grnARGB);
         canvas.FillRectangle(rightCandleX, bodyTop,
                              rightCandleX + candleW - 1, bodyBot, grnARGB);
         //--- Horizontal arrow between the candlesticks
         int arrowLeftX  = leftCandleX + candleW + candleGap;
         int arrowRightX = arrowLeftX + arrowW - 1;
         canvas.LineHorizontal(arrowLeftX, arrowRightX, icY, iconARGB);
         //--- Left arrowhead (>) and right arrowhead (<)
         AA_LINE(arrowLeftX,  icY, arrowLeftX + 2,  icY - 2);
         AA_LINE(arrowLeftX,  icY, arrowLeftX + 2,  icY + 2);
         AA_LINE(arrowRightX, icY, arrowRightX - 2, icY - 2);
         AA_LINE(arrowRightX, icY, arrowRightX - 2, icY + 2);
      }

      //--- Row 3 icon: angle symbol with arc (horizontal arm + diagonal arm + arc between them)
      {
         //--- Icon Y center on the row + vertex position at the bottom-left of the icon column
         int icY = row3Y + rowH3 / 2;
         int iconLeftX = px0 + padL;
         int vertexX  = iconLeftX + 5, vertexY = icY + 5;
         //--- Horizontal reference arm extending right from the vertex
         int armLen   = 14;
         int baseEndX = vertexX + armLen, baseEndY = vertexY;
         //--- Angled arm at 60deg above horizontal
         double armAngleDeg = 60.0;
         double armAngleRad = armAngleDeg * M_PI / 180.0;
         double armEndXf = vertexX + MathCos(armAngleRad) * armLen;
         double armEndYf = vertexY - MathSin(armAngleRad) * armLen;
         //--- Render the horizontal arm + the angled arm
         canvas.LineHorizontal(vertexX, baseEndX, vertexY, iconARGB);
         AA_LINE((double)vertexX, (double)vertexY, armEndXf, armEndYf);
         //--- Small arc between the two arms marking the angle measure
         double arcR_  = 7.0;
         double aStep_ = 1.0 / arcR_;
         double aEnd_  = armAngleRad - 4.0 * M_PI / 180.0;
         double aStart_ = 4.0 * M_PI / 180.0;
         //--- Walk the arc placing AA pixels at every step
         for(double a = aStart_; a <= aEnd_; a += aStep_)
           {
            double ax = vertexX + MathCos(a) * arcR_;
            double ay = vertexY - MathSin(a) * arcR_;
            AA_PIXEL_F(ax, ay);
           }
      }

      //--- Clean up the panel-icon macros so they don't leak into other compilation units
      #undef AA_PLOT
      #undef AA_PIXEL_F
      #undef AA_LINE
   }
  }

//+------------------------------------------------------------------+
//| Draw a trend angle line + horizontal reference + arc + label     |
//+------------------------------------------------------------------+
void CLineTools::DrawTrendAngleOn(CCanvas &canvas, int x1, int y1, int x2, int y2,
                                   color objColor, bool selected, bool hovered, bool isDarkTheme,
                                   int lineWidth = 2, int lineOpacity = 100,
                                   int lineStyle = 0)
  {
   //--- Compose stroke color and clamp line width/style into supported ranges
   const uint argb = ColorWithPercentOpacity(objColor, lineOpacity);
   if(lineWidth < 1) lineWidth = 1;
   if(lineWidth > 4) lineWidth = 4;
   if(lineStyle < 0) lineStyle = 0;
   if(lineStyle > 3) lineStyle = 3;

   //--- Render the main trendline between P1 and P2 with the selected style
   if(lineStyle == 0)
     {
      DrawThickLine(canvas, x1, y1, x2, y2, lineWidth, argb);
     }
   else
     {
      //--- Dashed styles build a stroke pattern; fall back to solid on empty pattern
      int pat[];
      const int n = BuildLineStylePattern(lineStyle, lineWidth, pat);
      if(n > 0)
         WidgetDashedLineAA(canvas, x1, y1, x2, y2, lineWidth, argb, pat);
      else
         DrawThickLine(canvas, x1, y1, x2, y2, lineWidth, argb);
     }

   //--- Compute the line's pixel-space angle in degrees (screen-Y inverted via -dy)
   double dx = (double)(x2 - x1), dy = (double)(y2 - y1);
   double len = MathSqrt(dx*dx + dy*dy);
   //--- Reject degenerate (zero-length) lines
   if(len < 1e-6) return;
   double angleDeg = MathArctan2(-dy, dx) * 180.0 / M_PI;

   //--- Size the reference arm length and arc radius based on the line length
   int refLen = 55;
   int arcR   = 32;
   //--- Short lines shrink the reference + arc proportionally (with minimums)
   if(len < 80)
     {
      double s = len / 80.0;
      refLen = (int)MathMax(25.0, refLen * s);
      arcR   = (int)MathMax(15.0, arcR   * s);
     }

   //--- Cache canvas bounds for the dotted reference line + dotted arc
   int cW = canvas.Width(), cH = canvas.Height();
   //--- Dotted horizontal reference line from P1 to the right (pairs of pixels every 5)
   for(int i = 0; i <= refLen; i += 5)
     {
      //--- Each dot is 2 pixels wide (i and i+1)
      for(int dot = 0; dot < 2; dot++)
        {
         int px = x1 + i + dot;
         int py = y1;
         if(px >= 0 && px < cW && py >= 0 && py < cH)
            canvas.PixelSet(px, py, argb);
        }
     }

   //--- Compute arc start/end angles (start = 0, end = trendline angle in radians, wrapped)
   double startA = 0.0;
   double endA   = MathArctan2(dy, dx);
   //--- Wrap endA into the standard [-pi, pi] range
   while(endA >  M_PI) endA -= 2.0 * M_PI;
   while(endA < -M_PI) endA += 2.0 * M_PI;

   //--- Angular step proportional to the arc radius (negate for sweep direction)
   double aStep = 1.0 / (double)arcR;
   if(endA < startA) aStep = -aStep;
   int nSteps = (int)(MathAbs(endA - startA) / MathAbs(aStep)) + 1;
   //--- Walk the arc step by step, placing AA pixel pairs every 5 steps (dotted arc)
   for(int s = 0; s < nSteps; s++)
     {
      //--- Skip 3 out of every 5 steps to create the dotted appearance
      int phase = s % 5;
      if(phase >= 2) continue;
      //--- Compute the arc point at this angle (note arc sits in standard math frame)
      double a = startA + aStep * s;
      double px_f = x1 + MathCos(a) * arcR;
      double py_f = y1 + MathSin(a) * arcR;
      //--- Integer pixel base and fractional offsets for 4-pixel bilinear AA
      int ix0 = (int)MathFloor(px_f), iy0 = (int)MathFloor(py_f);
      double fx = px_f - ix0, fy = py_f - iy0;
      //--- 4-pixel coverage weights
      double w00 = (1.0 - fx) * (1.0 - fy);
      double w10 =        fx  * (1.0 - fy);
      double w01 = (1.0 - fx) *        fy;
      double w11 =        fx  *        fy;
      //--- ARC_AA_PLOT: composite a single coverage-weighted ARGB pixel via Porter-Duff over
      #define ARC_AA_PLOT(xx, yy, ww) \
         if((xx) >= 0 && (xx) < cW && (yy) >= 0 && (yy) < cH && (ww) > 0.05) \
           { \
            uchar _a = (uchar)(255.0 * (ww)); \
            uint _existing = canvas.PixelGet((xx), (yy)); \
            double _sA = _a / 255.0; \
            double _dA = ((_existing >> 24) & 0xFF) / 255.0; \
            double _outA = _sA + _dA * (1.0 - _sA); \
            if(_outA > 0.0) { \
               double _sR = ((argb >> 16) & 0xFF) / 255.0; \
               double _sG = ((argb >>  8) & 0xFF) / 255.0; \
               double _sB = ( argb        & 0xFF) / 255.0; \
               double _dR = ((_existing >> 16) & 0xFF) / 255.0; \
               double _dG = ((_existing >>  8) & 0xFF) / 255.0; \
               double _dB = ( _existing        & 0xFF) / 255.0; \
               uint _blended = ((uint)(uchar)(_outA * 255.0 + 0.5) << 24) | \
                              ((uint)(uchar)((_sR*_sA + _dR*_dA*(1.0-_sA)) / _outA * 255.0 + 0.5) << 16) | \
                              ((uint)(uchar)((_sG*_sA + _dG*_dA*(1.0-_sA)) / _outA * 255.0 + 0.5) <<  8) | \
                               (uint)(uchar)((_sB*_sA + _dB*_dA*(1.0-_sA)) / _outA * 255.0 + 0.5); \
               canvas.PixelSet((xx), (yy), _blended); \
            } \
           }
      //--- Place all 4 coverage-weighted pixels around the arc-point
      ARC_AA_PLOT(ix0,     iy0,     w00);
      ARC_AA_PLOT(ix0 + 1, iy0,     w10);
      ARC_AA_PLOT(ix0,     iy0 + 1, w01);
      ARC_AA_PLOT(ix0 + 1, iy0 + 1, w11);
      //--- Clean up the per-iteration arc macro
      #undef ARC_AA_PLOT
     }

   //--- Render the angle label "X.XX deg" next to the reference line endpoint
   string lblStr = StringFormat("%.2f%s", angleDeg, "\xB0");
   const int fontPx = 9;
   TextSetFont("Arial", -(fontPx * 10));
   //--- Measure the label dimensions
   uint twU = 0, thU = 0;
   TextGetSize(lblStr, twU, thU);
   const int lw = (int)twU;
   const int lh = (int)thU;
   //--- Label position: right of the reference arm, vertically centered on the anchor
   int ltx = x1 + refLen + 6;
   int lty = y1 - lh / 2;
   //--- Only render if label has positive dimensions and partially intersects the canvas
   if(lw > 0 && lh > 0 &&
      !(ltx + lw < 0 || ltx >= cW || lty + lh < 0 || lty >= cH))
     {
      //--- 2-pass alpha-extraction technique: rasterize text on black AND white backgrounds
      uint bufB[]; ArrayResize(bufB, lw * lh);
      ArrayFill(bufB, 0, lw * lh, 0xFF000000);
      TextOut(lblStr, 0, 0, TA_LEFT | TA_TOP, bufB, lw, lh,
              argb, COLOR_FORMAT_ARGB_NORMALIZE);
      uint bufW[]; ArrayResize(bufW, lw * lh);
      ArrayFill(bufW, 0, lw * lh, 0xFFFFFFFF);
      TextOut(lblStr, 0, 0, TA_LEFT | TA_TOP, bufW, lw, lh,
              argb, COLOR_FORMAT_ARGB_NORMALIZE);
      //--- Source RGB from the stroke color (used to tint the alpha-extracted text)
      const uchar srcR_ = (uchar)((objColor)       & 0xFF);
      const uchar srcG_ = (uchar)((objColor >> 8)  & 0xFF);
      const uchar srcB_ = (uchar)((objColor >> 16) & 0xFF);
      //--- Walk every pixel in the label and composite the extracted alpha onto the canvas
      for(int py = 0; py < lh; py++)
        {
         for(int px = 0; px < lw; px++)
           {
            //--- Extract alpha as the inverse difference between white-bg and black-bg rasters
            const int i = py * lw + px;
            const int dR = (int)((bufW[i] >> 16) & 0xFF) - (int)((bufB[i] >> 16) & 0xFF);
            const int dG = (int)((bufW[i] >>  8) & 0xFF) - (int)((bufB[i] >>  8) & 0xFF);
            const int dB = (int)( bufW[i]        & 0xFF) - (int)( bufB[i]        & 0xFF);
            int a = 255 - (dR + dG + dB) / 3;
            //--- Skip fully-transparent pixels and clamp alpha into [0, 255]
            if(a <= 0) continue;
            if(a > 255) a = 255;
            //--- Map the local label pixel into canvas coords
            const int dstX = ltx + px;
            const int dstY = lty + py;
            if(dstX < 0 || dstX >= cW || dstY < 0 || dstY >= cH) continue;
            //--- Porter-Duff source-over compositing onto the existing canvas pixel
            const uint existing = canvas.PixelGet(dstX, dstY);
            const double sA = (double)a / 255.0;
            const double dA = ((existing >> 24) & 0xFF) / 255.0;
            const double oA = sA + dA * (1.0 - sA);
            if(oA <= 0.0) continue;
            //--- Source and destination RGB channels normalized to [0, 1]
            const double sRf = srcR_ / 255.0;
            const double sGf = srcG_ / 255.0;
            const double sBf = srcB_ / 255.0;
            const double dRf = ((existing >> 16) & 0xFF) / 255.0;
            const double dGf = ((existing >>  8) & 0xFF) / 255.0;
            const double dBf = ( existing        & 0xFF) / 255.0;
            //--- Compose the final ARGB pixel via the standard over formula
            const uint outPix = ((uint)(uchar)(oA * 255.0 + 0.5) << 24) |
                                ((uint)(uchar)((sRf*sA + dRf*dA*(1.0-sA)) / oA * 255.0 + 0.5) << 16) |
                                ((uint)(uchar)((sGf*sA + dGf*dA*(1.0-sA)) / oA * 255.0 + 0.5) <<  8) |
                                 (uint)(uchar)((sBf*sA + dBf*dA*(1.0-sA)) / oA * 255.0 + 0.5);
            canvas.PixelSet(dstX, dstY, outPix);
           }
        }
     }

   //--- Endpoint handles (selected/hovered) honoring hide and halo state
   if(selected || hovered)
     {
      if(m_hideHandleIdx != 0)
         DrawHandleOnCanvas(canvas, x1, y1, selected, objColor, m_haloHandleIdx == 0);
      if(m_hideHandleIdx != 1)
         DrawHandleOnCanvas(canvas, x2, y2, selected, objColor, m_haloHandleIdx == 1);
     }
  }

//+------------------------------------------------------------------+
//| Hit-test a finite trendline (also used by ray and extended line) |
//+------------------------------------------------------------------+
bool CLineTools::HitTestTrendLine(int mx, int my, int x1, int y1, int x2, int y2, int threshold)
  {
   //--- Trendline hit reduces to point-to-segment distance under the caller's threshold
   return PointToSegmentDistance(mx, my, x1, y1, x2, y2) <= threshold;
  }

//+------------------------------------------------------------------+
//| Hit-test a horizontal line at row Y                              |
//+------------------------------------------------------------------+
bool CLineTools::HitTestHorizontalLine(int mx, int my, int y, int threshold)
  {
   //--- HLine hit reduces to vertical distance under the caller's threshold
   return MathAbs(my - y) <= threshold;
  }

//+------------------------------------------------------------------+
//| Hit-test a vertical line at column X                             |
//+------------------------------------------------------------------+
bool CLineTools::HitTestVerticalLine(int mx, int my, int x, int threshold)
  {
   //--- VLine hit reduces to horizontal distance under the caller's threshold
   return MathAbs(mx - x) <= threshold;
  }

//+------------------------------------------------------------------+
//| Hit-test the last-drawn info panel rectangle for hover continuity|
//+------------------------------------------------------------------+
bool CLineTools::HitTestInfoLinePanel(int mx, int my)
  {
   //--- Sentinels of -1 mean no panel has been drawn yet this frame
   if(m_lastInfoPanelX1 < 0 || m_lastInfoPanelY1 < 0 ||
      m_lastInfoPanelX2 < 0 || m_lastInfoPanelY2 < 0)
      return false;
   //--- Standard inside-rect test against the cached panel bounds
   return (mx >= m_lastInfoPanelX1 && mx <= m_lastInfoPanelX2 &&
           my >= m_lastInfoPanelY1 && my <= m_lastInfoPanelY2);
  }

//+------------------------------------------------------------------+
//| Draw the "+ Add text" rotated prompt centered on the line        |
//+------------------------------------------------------------------+
void CLineTools::DrawAddTextPromptOn(CCanvas &canvas, int x1, int y1, int x2, int y2,
                                      color lineColor,
                                      bool isDarkTheme,
                                      int &promptX1, int &promptY1, int &promptX2, int &promptY2,
                                      int &cornerX[], int &cornerY[],
                                      bool centerOnLine)
  {
   //--- Midpoint of the line is the rotated text's center anchor
   int mx = (x1 + x2) / 2;
   int my = (y1 + y2) / 2;

   //--- Compute the line's angle in degrees (screen-Y inverted via -dy)
   double dx = (double)(x2 - x1), dy = (double)(y2 - y1);
   double angleDeg = 0.0;
   if(dx != 0.0 || dy != 0.0)
      angleDeg = MathArctan2(-dy, dx) * 180.0 / M_PI;
   //--- Keep the prompt text reading right-side up by wrapping the angle into [-90, 90]
   if(angleDeg > 90.0)  angleDeg -= 180.0;
   if(angleDeg < -90.0) angleDeg += 180.0;

   //--- Prompt label, font, and SSAA supersampling factor (4x for clean rotated text)
   string label    = "+ Add text";
   string fontName = "Arial";
   int    fontSize = 11;
   const int SS = 4;
   int    hrFontSize = fontSize * SS;

   //--- Prompt text color matches the object's line color
   color txtColor = lineColor;
   //--- Unpack RGB channels for the final compositing pass
   uchar txtR = (uchar)((txtColor)       & 0xFF);
   uchar txtG = (uchar)((txtColor >> 8)  & 0xFF);
   uchar txtB = (uchar)((txtColor >> 16) & 0xFF);

   //--- Set the HR font and measure the HR text dimensions
   TextSetFont(fontName, -(hrFontSize * 10));
   uint hrTwU = 0, hrThU = 0;
   TextGetSize(label, hrTwU, hrThU);
   int hrTw = (int)hrTwU, hrTh = (int)hrThU;
   //--- Reject degenerate text-measure results
   if(hrTw <= 0 || hrTh <= 0)
     { promptX1 = promptY1 = promptX2 = promptY2 = 0; return; }

   //--- 2-pass alpha-extraction: rasterize the HR text on black AND white backgrounds
   uint bufB[]; ArrayResize(bufB, hrTw * hrTh);
   ArrayFill(bufB, 0, hrTw * hrTh, 0xFF000000);
   TextOut(label, 0, 0, TA_LEFT | TA_TOP, bufB, hrTw, hrTh,
           ColorToARGB(txtColor, 255), COLOR_FORMAT_ARGB_NORMALIZE);
   uint bufW[]; ArrayResize(bufW, hrTw * hrTh);
   ArrayFill(bufW, 0, hrTw * hrTh, 0xFFFFFFFF);
   TextOut(label, 0, 0, TA_LEFT | TA_TOP, bufW, hrTw, hrTh,
           ColorToARGB(txtColor, 255), COLOR_FORMAT_ARGB_NORMALIZE);

   //--- Build an HR alpha buffer by subtracting black-bg pixels from white-bg pixels
   uchar hrAlpha[]; ArrayResize(hrAlpha, hrTw * hrTh);
   for(int i = 0; i < hrTw * hrTh; i++)
     {
      //--- Difference in each RGB channel between the two background rasters
      int dR = (int)((bufW[i] >> 16) & 0xFF) - (int)((bufB[i] >> 16) & 0xFF);
      int dG = (int)((bufW[i] >>  8) & 0xFF) - (int)((bufB[i] >>  8) & 0xFF);
      int dB = (int)( bufW[i]        & 0xFF) - (int)( bufB[i]        & 0xFF);
      //--- Alpha = 255 - mean RGB difference; clamp into [0, 255]
      int a  = 255 - (dR + dG + dB) / 3;
      if(a < 0) a = 0; else if(a > 255) a = 255;
      hrAlpha[i] = (uchar)a;
     }

   //--- Downsampled (final) text dimensions in screen pixels
   int tw = hrTw / SS;
   int th = hrTh / SS;
   //--- Reject degenerate downsampled-size results
   if(tw <= 0 || th <= 0)
     { promptX1 = promptY1 = promptX2 = promptY2 = 0; return; }
   //--- Cached half-extents for the rotation math
   double halfW = tw / 2.0, halfH = th / 2.0;

   //--- Cache rotation factors (cos, sin, neg-sin) for the inverse-rotation sampling pass
   double rad = angleDeg * M_PI / 180.0;
   double ca  = MathCos(rad), sa = MathSin(rad);
   double ssa = -sa;
   //--- Perpendicular offset: 0 = center on line (HLine/VLine), 11 = sit above the line
   int perpOffset = centerOnLine ? 0 : 11;
   //--- Target text center = line midpoint offset perpendicular by perpOffset pixels
   int midTargetX = (int)MathRound(mx - sa * perpOffset);
   int midTargetY = (int)MathRound(my - ca * perpOffset);

   //--- Compute the 4 rotated text-box corners (TL, TR, BR, BL) around the target center
   int cx1 = (int)MathRound(midTargetX + (-halfW)*ca - (-halfH)*ssa);
   int cy1 = (int)MathRound(midTargetY + (-halfW)*ssa + (-halfH)*ca);
   int cx2 = (int)MathRound(midTargetX + ( halfW)*ca - (-halfH)*ssa);
   int cy2 = (int)MathRound(midTargetY + ( halfW)*ssa + (-halfH)*ca);
   int cx3 = (int)MathRound(midTargetX + ( halfW)*ca - ( halfH)*ssa);
   int cy3 = (int)MathRound(midTargetY + ( halfW)*ssa + ( halfH)*ca);
   int cx4 = (int)MathRound(midTargetX + (-halfW)*ca - ( halfH)*ssa);
   int cy4 = (int)MathRound(midTargetY + (-halfW)*ssa + ( halfH)*ca);
   //--- Axis-aligned bounding box of the rotated corners (with 2px padding for AA)
   int bbMinX = MathMin(MathMin(cx1,cx2), MathMin(cx3,cx4)) - 2;
   int bbMaxX = MathMax(MathMax(cx1,cx2), MathMax(cx3,cx4)) + 2;
   int bbMinY = MathMin(MathMin(cy1,cy2), MathMin(cy3,cy4)) - 2;
   int bbMaxY = MathMax(MathMax(cy1,cy2), MathMax(cy3,cy4)) + 2;

   //--- Clip the AABB against canvas bounds for the per-pixel sampling loop
   int cW = canvas.Width(), cH = canvas.Height();
   int clipMinX = MathMax(0, bbMinX);
   int clipMinY = MathMax(0, bbMinY);
   int clipMaxX = MathMin(cW - 1, bbMaxX);
   int clipMaxY = MathMin(cH - 1, bbMaxY);

   //--- Subpixel sampling step + start offset (SS x SS supersamples per output pixel)
   double subStep  = 1.0 / SS;
   double subStart = -0.5 + subStep * 0.5;
   int    subCount = SS * SS;

   //--- Walk every clipped output pixel and inverse-rotate to sample the HR text
   for(int py = clipMinY; py <= clipMaxY; py++)
     {
      for(int px = clipMinX; px <= clipMaxX; px++)
        {
         //--- Accumulate alpha across SS x SS subpixel samples for the AA average
         int alphaSum = 0;
         for(int sy = 0; sy < SS; sy++)
           {
            for(int sx = 0; sx < SS; sx++)
              {
               //--- Subpixel coords in canvas space
               double subX = (double)px + subStart + subStep * sx;
               double subY = (double)py + subStart + subStep * sy;
               //--- Translate to target-center origin, then inverse-rotate to text-local coords
               double rx = subX - midTargetX;
               double ry = subY - midTargetY;
               double srcCX =  rx * ca + ry * ssa;
               double srcCY = -rx * ssa + ry * ca;
               //--- Translate text-local coords to HR-source coords (scale by SS, offset by half)
               double srcXHR = (srcCX + halfW) * SS;
               double srcYHR = (srcCY + halfH) * SS;
               //--- Skip subpixels outside the HR source buffer
               if(srcXHR < 0.0 || srcXHR >= (double)hrTw) continue;
               if(srcYHR < 0.0 || srcYHR >= (double)hrTh) continue;
               //--- Integer HR pixel coords (truncated lookup)
               int ix = (int)srcXHR;
               int iy = (int)srcYHR;
               //--- Defensive bounds check
               if(ix < 0 || ix >= hrTw || iy < 0 || iy >= hrTh) continue;
               //--- Accumulate the HR alpha at this subsample
               alphaSum += hrAlpha[iy * hrTw + ix];
              }
           }
         //--- Average alpha across all SS x SS subsamples
         int alpha = alphaSum / subCount;
         if(alpha <= 0) continue;
         if(alpha > 255) alpha = 255;

         //--- Porter-Duff source-over compositing onto the existing canvas pixel
         uint existing = canvas.PixelGet(px, py);
         double sA = alpha / 255.0;
         double dA = ((existing >> 24) & 0xFF) / 255.0;
         double outA = sA + dA * (1.0 - sA);
         if(outA <= 0.0) continue;
         //--- Source RGB normalized to [0, 1] (text color)
         double sR = txtR / 255.0, sG = txtG / 255.0, sB = txtB / 255.0;
         //--- Destination RGB normalized to [0, 1]
         double dR = ((existing >> 16) & 0xFF) / 255.0;
         double dG = ((existing >>  8) & 0xFF) / 255.0;
         double dB = ( existing        & 0xFF) / 255.0;
         //--- Composite final ARGB pixel via standard over formula
         uint blended = ((uint)(uchar)(outA * 255.0 + 0.5) << 24) |
                       ((uint)(uchar)((sR*sA + dR*dA*(1.0-sA)) / outA * 255.0 + 0.5) << 16) |
                       ((uint)(uchar)((sG*sA + dG*dA*(1.0-sA)) / outA * 255.0 + 0.5) <<  8) |
                        (uint)(uchar)((sB*sA + dB*dA*(1.0-sA)) / outA * 255.0 + 0.5);
         canvas.PixelSet(px, py, blended);
        }
     }

   //--- Write back the AABB to the output parameters for the simple-rect hit test
   promptX1 = bbMinX; promptY1 = bbMinY;
   promptX2 = bbMaxX; promptY2 = bbMaxY;
   //--- Ensure the rotated-corner output arrays are at least 4 long
   if(ArraySize(cornerX) < 4) ArrayResize(cornerX, 4);
   if(ArraySize(cornerY) < 4) ArrayResize(cornerY, 4);
   //--- Write back the 4 rotated corners (TL, TR, BR, BL order) for precise hit testing
   cornerX[0] = cx1; cornerY[0] = cy1;
   cornerX[1] = cx2; cornerY[1] = cy2;
   cornerX[2] = cx3; cornerY[2] = cy3;
   cornerX[3] = cx4; cornerY[3] = cy4;
  }

//+------------------------------------------------------------------+
//| Hit-test the "+ Add text" prompt's axis-aligned bounding rect    |
//+------------------------------------------------------------------+
bool CLineTools::HitTestAddTextPrompt(int mx, int my,
                                       int promptX1, int promptY1, int promptX2, int promptY2)
  {
   //--- Normalize the rect bounds (the caller may have passed them in either order)
   int lx = MathMin(promptX1, promptX2), rx = MathMax(promptX1, promptX2);
   int ty = MathMin(promptY1, promptY2), by = MathMax(promptY1, promptY2);
   //--- Standard inside-rect test
   return (mx >= lx && mx <= rx && my >= ty && my <= by);
  }

#endif // TOOLS_PALETTE_LINES_MQH
//+------------------------------------------------------------------+