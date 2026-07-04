//+------------------------------------------------------------------+
//|                                 ToolsPalette_PropertyWidgets.mqh |
//|                           Copyright 2026, Allan Munene Mutiiria. |
//|                                   https://t.me/Forex_Algo_Trader |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Allan Munene Mutiiria."
#property link "https://t.me/Forex_Algo_Trader"
#property version "1.00"
#property strict

//--- Guard against multiple inclusion of this header
#ifndef TOOLS_PALETTE_PROPERTY_WIDGETS_MQH
#define TOOLS_PALETTE_PROPERTY_WIDGETS_MQH

//--- Pull in the Sidebar header (transitively pulls Primitives + Tools)
#include "../core/ToolsPalette_Sidebar.mqh"

//+------------------------------------------------------------------+
//| WidgetFillCircleAA - anti-aliased filled circle (4x4 supersample)|
//+------------------------------------------------------------------+
void WidgetFillCircleAA(CCanvas &canvas, int cx, int cy, int radius, uint argb)
  {
   //--- Bail on a non-positive radius
   if(radius <= 0) return;
   //--- Cache the radius as a double + decompose the ARGB color
   const double rd = (double)radius;
   const uchar  bA = (uchar)((argb >> 24) & 0xFF);
   const uint   rgb = argb & 0x00FFFFFF;
   //--- 4x4 supersampling (16 sub-samples per pixel) for coverage estimation
   const int sub = 4;
   const double step = 1.0 / sub;
   const int subSq = sub * sub;
   //--- Walk every pixel inside the bounding box + one-pixel halo for AA edges
   for(int dy = -radius - 1; dy <= radius + 1; dy++)
     {
      for(int dx = -radius - 1; dx <= radius + 1; dx++)
        {
         //--- Skip pixels clearly outside the circle
         const double dist = MathSqrt((double)(dx * dx + dy * dy));
         if(dist > rd + 1.0) continue;
         //--- Inner core (well inside) - blend at full alpha, no supersampling needed
         if(dist <= rd - 1.0)
           {
            WidgetBlendPixel(canvas, cx + dx, cy + dy, argb);
            continue;
           }
         //--- Edge band: count sub-samples that fall inside the circle
         int inside = 0;
         for(int sy = 0; sy < sub; sy++)
            for(int sx = 0; sx < sub; sx++)
              {
               const double sdx = (double)dx - 0.5 + (sx + 0.5) * step;
               const double sdy = (double)dy - 0.5 + (sy + 0.5) * step;
               if(sdx * sdx + sdy * sdy <= rd * rd) inside++;
              }
         //--- Skip pixels with zero coverage
         if(inside == 0) continue;
         //--- Scale the source alpha by the coverage fraction and blend
         const uint covArgb = (((uint)(uchar)((int)bA * inside / subSq)) << 24) | rgb;
         WidgetBlendPixel(canvas, cx + dx, cy + dy, covArgb);
        }
     }
  }

//+------------------------------------------------------------------+
//| Stroke a 1- or 2-px rounded-rect outline + fill the interior     |
//+------------------------------------------------------------------+
void WidgetStrokeRoundRect(CCanvas &canvas,
                            int l, int t, int r, int b,
                            int radius, int thickness,
                            uint borderArgb, uint interiorArgb)
  {
   //--- Clamp the stroke thickness to a sane 1..4 px range
   if(thickness < 1) thickness = 1;
   if(thickness > 4) thickness = 4;
   //--- Paint the full rect in border color first (acts as the outline)
   FillNoteRoundRect(canvas, l, t, r, b, radius, borderArgb);
   //--- Shrink by `thickness` pixels and paint the interior on top
   const int innerL = l + thickness;
   const int innerT = t + thickness;
   const int innerR = r - thickness;
   const int innerB = b - thickness;
   const int innerRad = MathMax(0, radius - thickness);
   //--- Guard against degenerate rectangles where the interior would invert
   if(innerR > innerL && innerB > innerT)
     {
      FillNoteRoundRect(canvas, innerL, innerT, innerR, innerB,
                          innerRad, interiorArgb);
     }
  }

//+------------------------------------------------------------------+
//| Paint a transparency-checker pattern clipped to a pill shape     |
//+------------------------------------------------------------------+
void WidgetCheckerFillPill(CCanvas &canvas,
                            int l, int t, int r, int b,
                            int checkerSize)
  {
   //--- Bail on degenerate rectangles
   const int h = b - t;
   if(h <= 0 || r <= l) return;
   //--- Pill = rect with semicircular ends - radius is half the height
   const int radius = h / 2;
   //--- Two checker colors (light + lighter gray)
   const uint checkerA = ColorToARGB(C'200,200,200', 255);
   const uint checkerB = ColorToARGB(C'232,232,232', 255);
   const int yMid = (t + b) / 2;
   //--- Walk every row, compute the per-row x-inset that keeps us inside the pill
   for(int y = t; y < b; y++)
     {
      //--- Distance from the pill's vertical centerline - rows beyond `radius` are outside
      const int dyFromMid = MathAbs(y - yMid);
      if(dyFromMid >= radius) continue;
      //--- Half-width of the pill at this y (from circle equation x = sqrt(r^2 - dy^2))
      const double rr = (double)radius;
      const double extent = MathSqrt(rr * rr - (double)dyFromMid * (double)dyFromMid);
      const int rowInset = (int)(rr - extent);
      const int xStart = l + rowInset;
      const int xEnd   = r - rowInset;
      //--- Paint each column with the alternating checker pattern
      for(int x = xStart; x < xEnd; x++)
        {
         const bool dark = (((x - l) / checkerSize) + ((y - t) / checkerSize)) % 2 == 0;
         canvas.PixelSet(x, y, dark ? checkerA : checkerB);
        }
     }
  }

//+------------------------------------------------------------------+
//| Paint a transparency-checker pattern inside a plain rectangle    |
//+------------------------------------------------------------------+
void WidgetCheckerFillRect(CCanvas &canvas,
                            int l, int t, int r, int b,
                            int checkerSize)
  {
   //--- Bail on degenerate rectangles
   if(r <= l || b <= t) return;
   //--- Two checker colors (light + lighter gray)
   const uint checkerA = ColorToARGB(C'200,200,200', 255);
   const uint checkerB = ColorToARGB(C'232,232,232', 255);
   //--- Walk every pixel; xor the cell index to pick the alternating color
   for(int y = t; y < b; y++)
     {
      for(int x = l; x < r; x++)
        {
         const bool dark = (((x - l) / checkerSize) + ((y - t) / checkerSize)) % 2 == 0;
         canvas.PixelSet(x, y, dark ? checkerA : checkerB);
        }
     }
  }

//+------------------------------------------------------------------+
//| WidgetStrokePillAA - razor-sharp anti-aliased pill outline       |
//+------------------------------------------------------------------+
void WidgetStrokePillAA(CCanvas &canvas,
                         int l, int t, int r, int b,
                         int thickness, uint argb)
  {
   //--- Bail on degenerate rectangles
   const int h = b - t;
   const int w = r - l;
   if(h <= 0 || w <= 0) return;
   //--- Clamp the stroke thickness to 1..4 px
   if(thickness < 1) thickness = 1;
   if(thickness > 4) thickness = 4;
   //--- Pill radius = half-height; cyMid is the vertical centerline (as double for AA math)
   const double radius = (double)h / 2.0;
   const double cyMid  = (double)(t + b) / 2.0;
   //--- Decompose the ARGB color
   const uchar bA = (uchar)((argb >> 24) & 0xFF);
   const uint  rgb = argb & 0x00FFFFFF;
   //--- 4x4 supersampling for edge coverage estimation
   const int sub = 4;
   const double step = 1.0 / sub;
   const int subSq = sub * sub;
   //--- Centers of the two end-caps' circles (left and right semicircles)
   const double lcx = (double)l + radius;
   const double rcx = (double)r - radius;

   //--- Walk every pixel inside the bounding box + one-pixel halo for AA edges
   for(int py = t - 1; py <= b; py++)
     {
      for(int px = l - 1; px <= r; px++)
        {
         //--- Pixel center in continuous coordinates
         const double pcx = (double)px + 0.5;
         const double pcy = (double)py + 0.5;
         //--- Signed distance from the pill outline (negative = inside, positive = outside)
         double dist;
         if(pcx >= lcx && pcx <= rcx)
           {
            //--- In the rectangular middle - distance is vertical offset from centerline minus radius
            dist = MathAbs(pcy - cyMid) - radius;
           }
         else if(pcx < lcx)
           {
            //--- Left end-cap - distance to left circle center minus radius
            const double dx = pcx - lcx;
            const double dy = pcy - cyMid;
            dist = MathSqrt(dx * dx + dy * dy) - radius;
           }
         else
           {
            //--- Right end-cap - distance to right circle center minus radius
            const double dx = pcx - rcx;
            const double dy = pcy - cyMid;
            dist = MathSqrt(dx * dx + dy * dy) - radius;
           }
         //--- Skip pixels well outside (dist > 1 px) or well inside the stroke band
         if(dist > 1.0) continue;
         if(dist < -((double)thickness) - 1.0) continue;

         //--- Count sub-samples that fall inside the stroke band
         int inside = 0;
         for(int sy = 0; sy < sub; sy++)
           {
            for(int sx = 0; sx < sub; sx++)
              {
               //--- Sub-sample center
               const double sx_ = (double)px + (sx + 0.5) * step;
               const double sy_ = (double)py + (sy + 0.5) * step;
               //--- Same signed-distance logic as above, but per sub-sample
               double sd;
               if(sx_ >= lcx && sx_ <= rcx)
                 {
                  sd = MathAbs(sy_ - cyMid) - radius;
                 }
               else if(sx_ < lcx)
                 {
                  const double dxx = sx_ - lcx;
                  const double dyy = sy_ - cyMid;
                  sd = MathSqrt(dxx * dxx + dyy * dyy) - radius;
                 }
               else
                 {
                  const double dxx = sx_ - rcx;
                  const double dyy = sy_ - cyMid;
                  sd = MathSqrt(dxx * dxx + dyy * dyy) - radius;
                 }
               //--- Sub-sample is in the stroke band when its sd lies in [-thickness, 0]
               if(sd <= 0.0 && sd >= -(double)thickness) inside++;
              }
           }
         //--- Skip pixels with zero coverage
         if(inside == 0) continue;
         //--- Scale source alpha by the coverage fraction and blend
         const uint covArgb = (((uint)(uchar)((int)bA * inside / subSq)) << 24) | rgb;
         WidgetBlendPixel(canvas, px, py, covArgb);
        }
     }
  }


//--- Color picker layout constants (grid + spacing + opacity strip + label box)
#define COLORPICKER_GRID_COLS         10
#define COLORPICKER_GRID_ROWS         8
#define COLORPICKER_SWATCH_SIZE       18
#define COLORPICKER_SWATCH_GAP         5
#define COLORPICKER_SWATCH_RADIUS      4
#define COLORPICKER_PAD_X             11
#define COLORPICKER_PAD_Y_TOP         11
#define COLORPICKER_PAD_Y_BOTTOM      11
#define COLORPICKER_GRID_TO_DIVIDER   10
#define COLORPICKER_DIVIDER_TO_OPACITY 10
#define COLORPICKER_OPACITY_LABEL_H   14
#define COLORPICKER_OPACITY_LABEL_GAP  6
#define COLORPICKER_OPACITY_STRIP_H   10
#define COLORPICKER_OPACITY_BOX_W     46
#define COLORPICKER_OPACITY_BOX_H     22
#define COLORPICKER_OPACITY_BOX_GAP    8
#define COLORPICKER_RING_OFFSET        2
#define COLORPICKER_RING_THICKNESS     2
#define COLORPICKER_WHITE_BORDER_COLOR_R  220
#define COLORPICKER_WHITE_BORDER_COLOR_G  220
#define COLORPICKER_WHITE_BORDER_COLOR_B  220

//+------------------------------------------------------------------+
//| Color picker preset palette (80 swatches arranged as 10x8 grid)  |
//+------------------------------------------------------------------+
color GetColorPickerSwatch(int idx)
  {
   //--- 80-entry preset palette organized by tonal row
   static color s_palette[80] =
     {
      //--- Row 0: grayscale (white to black)
      C'255,255,255', C'232,232,232', C'209,209,209', C'186,186,186', C'163,163,163',
      C'140,140,140', C'117,117,117', C'94,94,94',    C'47,47,47',    C'0,0,0',
      //--- Row 1: lightest pastels
      C'255,205,210', C'255,224,178', C'255,249,196', C'200,230,201', C'178,235,242',
      C'179,229,252', C'197,202,233', C'209,196,233', C'225,190,231', C'248,187,208',
      //--- Row 2: soft pastels
      C'255,154,162', C'255,196,148', C'255,236,139', C'165,214,167', C'128,222,234',
      C'129,212,250', C'159,168,218', C'179,157,219', C'206,147,216', C'244,143,177',
      //--- Row 3: pastel-vivid
      C'255,138,128', C'255,167, 38', C'255,213,  0', C'129,199,132', C' 77,208,225',
      C' 79,195,247', C'121,134,203', C'149,117,205', C'186,104,200', C'240,98 ,146',
      //--- Row 4: clean mid
      C'244, 67, 54', C'255,152,  0', C'255,193,  7', C' 76,175, 80', C'  0,188,212',
      C' 33,150,243', C' 63, 81,181', C'103, 58,183', C'156, 39,176', C'233, 30, 99',
      //--- Row 5: deeper mid
      C'229, 57, 53', C'251,140,  0', C'251,177,  0', C' 56,142, 60', C'  0,151,167',
      C' 30,136,229', C' 57, 73,171', C' 94, 53,177', C'142, 36,170', C'216, 27, 96',
      //--- Row 6: deep saturated
      C'198, 40, 40', C'239,108,  0', C'245,127, 23', C' 46,125, 50', C'  0,121,107',
      C' 21,101,192', C' 48, 63,159', C' 81, 45,168', C'123, 31,162', C'194, 24, 91',
      //--- Row 7: darkest
      C'183, 28, 28', C'230, 81,  0', C'191, 54, 12', C' 27, 94, 32', C'  0, 96, 100',
      C' 13, 71,161', C' 26, 35,126', C' 49, 27,146', C' 74, 20,140', C'136, 14, 79'
     };
   //--- Out-of-range index returns the sentinel clrNONE
   if(idx < 0 || idx >= 80) return clrNONE;
   return s_palette[idx];
  }

//+------------------------------------------------------------------+
//| Reverse lookup: find the palette index for a given color value   |
//+------------------------------------------------------------------+
int FindColorPickerSwatchIndex(color c)
  {
   //--- Linear scan through the 80-entry palette; return -1 if not present
   for(int i = 0; i < 80; i++)
     {
      if(GetColorPickerSwatch(i) == c) return i;
     }
   return -1;
  }

//+------------------------------------------------------------------+
//| Compute the color picker popover body width (constant geometry)  |
//+------------------------------------------------------------------+
int GetColorPickerBodyWidth()
  {
   //--- Left + right padding + 10 swatch columns + 9 inter-swatch gaps
   return 2 * COLORPICKER_PAD_X
        + COLORPICKER_GRID_COLS * COLORPICKER_SWATCH_SIZE
        + (COLORPICKER_GRID_COLS - 1) * COLORPICKER_SWATCH_GAP;
  }

//+------------------------------------------------------------------+
//| Compute the color picker popover body height (constant geometry) |
//+------------------------------------------------------------------+
int GetColorPickerBodyHeight()
  {
   //--- 8-row swatch grid height + 7 inter-row gaps
   const int gridH = COLORPICKER_GRID_ROWS * COLORPICKER_SWATCH_SIZE
                    + (COLORPICKER_GRID_ROWS - 1) * COLORPICKER_SWATCH_GAP;
   //--- Opacity strip + label box - tallest of the two is what we reserve
   const int opacityRowH = MathMax(COLORPICKER_OPACITY_STRIP_H,
                                     COLORPICKER_OPACITY_BOX_H);
   //--- Sum: top pad + grid + grid-to-divider + divider-to-opacity-label + label height + label-to-strip + strip-row + bottom pad
   return COLORPICKER_PAD_Y_TOP
        + gridH
        + COLORPICKER_GRID_TO_DIVIDER
        + COLORPICKER_DIVIDER_TO_OPACITY
        + COLORPICKER_OPACITY_LABEL_H
        + COLORPICKER_OPACITY_LABEL_GAP
        + opacityRowH
        + COLORPICKER_PAD_Y_BOTTOM;
  }

//+------------------------------------------------------------------+
//| Compute the bounding rect for swatch index `idx` in the picker   |
//+------------------------------------------------------------------+
void GetColorPickerSwatchRect(int idx, int originX, int originY,
                               int &outL, int &outT, int &outR, int &outB)
  {
   //--- Decompose the linear index into (row, column) via grid columns
   const int row = idx / COLORPICKER_GRID_COLS;
   const int col = idx % COLORPICKER_GRID_COLS;
   //--- Top-left = origin + padding + offset by (col, row) cell strides
   outL = originX + COLORPICKER_PAD_X
        + col * (COLORPICKER_SWATCH_SIZE + COLORPICKER_SWATCH_GAP);
   outT = originY + COLORPICKER_PAD_Y_TOP
        + row * (COLORPICKER_SWATCH_SIZE + COLORPICKER_SWATCH_GAP);
   //--- Bottom-right = top-left + swatch dimensions
   outR = outL + COLORPICKER_SWATCH_SIZE;
   outB = outT + COLORPICKER_SWATCH_SIZE;
  }

//+------------------------------------------------------------------+
//| Hit-test which swatch (if any) is at local-coords (lx, ly)       |
//+------------------------------------------------------------------+
int HitTestColorPickerSwatch(int lx, int ly, int originX, int originY)
  {
   //--- Translate to grid-local coordinates inside the padded swatch area
   const int gx = lx - originX - COLORPICKER_PAD_X;
   const int gy = ly - originY - COLORPICKER_PAD_Y_TOP;
   if(gx < 0 || gy < 0) return -1;
   //--- Cell stride = swatch size + gap
   const int cellW = COLORPICKER_SWATCH_SIZE + COLORPICKER_SWATCH_GAP;
   const int cellH = COLORPICKER_SWATCH_SIZE + COLORPICKER_SWATCH_GAP;
   //--- Identify the (col, row) cell that contains the point
   const int col = gx / cellW;
   const int row = gy / cellH;
   //--- Reject points outside the grid
   if(col < 0 || col >= COLORPICKER_GRID_COLS) return -1;
   if(row < 0 || row >= COLORPICKER_GRID_ROWS) return -1;
   //--- Reject points in the inter-cell gap (cell mod stride must fall inside the swatch portion)
   if((gx % cellW) >= COLORPICKER_SWATCH_SIZE) return -1;
   if((gy % cellH) >= COLORPICKER_SWATCH_SIZE) return -1;
   //--- Compose the linear index back from (row, col)
   return row * COLORPICKER_GRID_COLS + col;
  }

//+------------------------------------------------------------------+
//| Render the full color picker contents (swatch grid + opacity row)|
//+------------------------------------------------------------------+
void RenderColorPickerContents(CCanvas &canvas,
                                int originX, int originY,
                                color activeColor,
                                int hoveredIdx,
                                int opacityPct,
                                bool isDarkTheme,
                                bool boxIsEditing,
                                string boxEditBuffer,
                                int boxCaretPos,
                                bool boxCaretOn,
                                const ThemeColorSet &theme)
  {
   //--- Clamp the opacity percent into 0..100 defensively
   if(opacityPct < 0)   opacityPct = 0;
   if(opacityPct > 100) opacityPct = 100;

   //--- Find which preset (if any) matches the active color - drives the active ring placement
   const int activeIdx = FindColorPickerSwatchIndex(activeColor);
   //--- First pass: paint every swatch
   for(int i = 0; i < 80; i++)
     {
      int sL, sT, sR, sB;
      GetColorPickerSwatchRect(i, originX, originY, sL, sT, sR, sB);
      const color sw = GetColorPickerSwatch(i);
      const uint  swArgb = ColorToARGB(sw, 255);
      //--- White swatch gets a thin gray border to remain visible against the popover background
      if(sw == C'255,255,255')
        {
         const color borderC = (color)((COLORPICKER_WHITE_BORDER_COLOR_R << 16) |
                                        (COLORPICKER_WHITE_BORDER_COLOR_G <<  8) |
                                         COLORPICKER_WHITE_BORDER_COLOR_B);
         WidgetStrokeRoundRect(canvas, sL, sT, sR, sB,
                                COLORPICKER_SWATCH_RADIUS, 1,
                                ColorToARGB(borderC, 255), swArgb);
        }
      else
        {
         //--- Non-white swatches paint as a solid rounded rect
         FillNoteRoundRect(canvas, sL, sT, sR, sB,
                             COLORPICKER_SWATCH_RADIUS, swArgb);
        }
     }

   //--- Hover ring (drawn under the active ring so the active ring wins when both apply)
   if(hoveredIdx >= 0 && hoveredIdx != activeIdx && hoveredIdx < 80)
     {
      int sL, sT, sR, sB;
      GetColorPickerSwatchRect(hoveredIdx, originX, originY, sL, sT, sR, sB);
      //--- Inflate the rect by RING_OFFSET to get the outer ring bounds
      const int oL = sL - COLORPICKER_RING_OFFSET;
      const int oT = sT - COLORPICKER_RING_OFFSET;
      const int oR = sR + COLORPICKER_RING_OFFSET;
      const int oB = sB + COLORPICKER_RING_OFFSET;
      const int oRad = COLORPICKER_SWATCH_RADIUS + COLORPICKER_RING_OFFSET;
      //--- Subtle gray hover ring
      const uint hoverRingArgb = ColorToARGB(C'140,140,140', 200);
      const color sw = GetColorPickerSwatch(hoveredIdx);
      WidgetStrokeRoundRect(canvas, oL, oT, oR, oB,
                              oRad, COLORPICKER_RING_THICKNESS,
                              hoverRingArgb, ColorToARGB(sw, 255));
      //--- White swatch needs its own internal border redrawn after the ring fill
      if(sw == C'255,255,255')
        {
         const color borderC = (color)((COLORPICKER_WHITE_BORDER_COLOR_R << 16) |
                                        (COLORPICKER_WHITE_BORDER_COLOR_G <<  8) |
                                         COLORPICKER_WHITE_BORDER_COLOR_B);
         WidgetStrokeRoundRect(canvas, sL, sT, sR, sB,
                                COLORPICKER_SWATCH_RADIUS, 1,
                                ColorToARGB(borderC, 255), ColorToARGB(sw, 255));
        }
     }

   //--- Active ring (drawn last so it overlays the hover ring on the active swatch)
   if(activeIdx >= 0)
     {
      int sL, sT, sR, sB;
      GetColorPickerSwatchRect(activeIdx, originX, originY, sL, sT, sR, sB);
      //--- Inflate by RING_OFFSET for the outer ring bounds
      const int oL = sL - COLORPICKER_RING_OFFSET;
      const int oT = sT - COLORPICKER_RING_OFFSET;
      const int oR = sR + COLORPICKER_RING_OFFSET;
      const int oB = sB + COLORPICKER_RING_OFFSET;
      const int oRad = COLORPICKER_SWATCH_RADIUS + COLORPICKER_RING_OFFSET;
      //--- Active ring color contrasts with the theme (near-white on dark, near-black on light)
      const color activeRingColor = isDarkTheme ? C'240,240,240' : C'40,40,40';
      const color sw = GetColorPickerSwatch(activeIdx);
      WidgetStrokeRoundRect(canvas, oL, oT, oR, oB,
                              oRad, COLORPICKER_RING_THICKNESS,
                              ColorToARGB(activeRingColor, 255),
                              ColorToARGB(sw, 255));
      //--- White swatch needs its own internal border redrawn after the ring fill
      if(sw == C'255,255,255')
        {
         const color borderC = (color)((COLORPICKER_WHITE_BORDER_COLOR_R << 16) |
                                        (COLORPICKER_WHITE_BORDER_COLOR_G <<  8) |
                                         COLORPICKER_WHITE_BORDER_COLOR_B);
         WidgetStrokeRoundRect(canvas, sL, sT, sR, sB,
                                COLORPICKER_SWATCH_RADIUS, 1,
                                ColorToARGB(borderC, 255), ColorToARGB(sw, 255));
        }
     }

   //--- Soft divider line separating the swatch grid from the opacity controls
   const int gridBottomY = originY + COLORPICKER_PAD_Y_TOP
                          + COLORPICKER_GRID_ROWS * COLORPICKER_SWATCH_SIZE
                          + (COLORPICKER_GRID_ROWS - 1) * COLORPICKER_SWATCH_GAP;
   const int dividerY = gridBottomY + COLORPICKER_GRID_TO_DIVIDER;
   const uint sepArgb = ColorToARGB(theme.separatorColor, 255);
   const int sepL = originX + COLORPICKER_PAD_X;
   const int sepR = originX + GetColorPickerBodyWidth() - COLORPICKER_PAD_X;
   canvas.Line(sepL, dividerY, sepR, dividerY, sepArgb);

   //--- Opacity row layout (strip + label + value box)
   const int opacityRowTop = dividerY + COLORPICKER_DIVIDER_TO_OPACITY;
   const int labelTop      = opacityRowTop;
   const int stripBoxTop   = labelTop + COLORPICKER_OPACITY_LABEL_H + COLORPICKER_OPACITY_LABEL_GAP;
   const int boxH          = COLORPICKER_OPACITY_BOX_H;
   const int stripH        = COLORPICKER_OPACITY_STRIP_H;
   const int stripRowTop   = stripBoxTop + (boxH - stripH) / 2;
   const int stripRowBot   = stripRowTop + stripH;

   //--- Draw the "Opacity" label
   canvas.FontSet("Arial", -100);
   canvas.TextOut(originX + COLORPICKER_PAD_X, labelTop,
                    "Opacity",
                    ColorToARGB(theme.flyoutTextColor, 230));

   //--- Strip extent (left padding to value-box left edge minus gap)
   const int stripL    = originX + COLORPICKER_PAD_X;
   const int stripR    = originX + GetColorPickerBodyWidth()
                        - COLORPICKER_PAD_X
                        - COLORPICKER_OPACITY_BOX_W
                        - COLORPICKER_OPACITY_BOX_GAP;
   const int stripRadius = stripH / 2;

   //--- Paint the transparency-checker background of the opacity strip
   WidgetCheckerFillPill(canvas, stripL, stripRowTop, stripR, stripRowBot, 3);

   //--- Overlay an alpha gradient from 0 to fully opaque across the strip width
   for(int y = stripRowTop; y < stripRowBot; y++)
     {
      const int yMid = (stripRowTop + stripRowBot) / 2;
      const int dyFromMid = MathAbs(y - yMid);
      //--- Stay inside the pill shape using the same circle-equation row-inset as WidgetCheckerFillPill
      if(dyFromMid >= stripRadius) continue;
      const double rr = (double)stripRadius;
      const double extent = MathSqrt(rr * rr - (double)dyFromMid * (double)dyFromMid);
      const int rowInset = (int)(rr - extent);
      const int xStart = stripL + rowInset;
      const int xEnd   = stripR - rowInset;
      const int span   = xEnd - xStart;
      if(span <= 0) continue;
      //--- Each x gets alpha = 255 * (x_offset / span) so the right end is fully opaque
      for(int x = xStart; x < xEnd; x++)
        {
         const uchar alpha = (uchar)(255 * (x - xStart) / span);
         WidgetBlendPixel(canvas, x, y, ColorToARGB(activeColor, alpha));
        }
     }

   //--- 1-px AA border around the strip pill
   const uint pillBorderArgb = ColorWithPercentOpacity(activeColor, 100);
   WidgetStrokePillAA(canvas, stripL, stripRowTop, stripR, stripRowBot,
                       1, pillBorderArgb);

   //--- Thumb position based on opacity percent (linear interpolation along the strip)
   const int thumbRangeL = stripL + stripRadius;
   const int thumbRangeR = stripR - stripRadius;
   const int thumbRange  = thumbRangeR - thumbRangeL;
   const int thumbX = thumbRangeL + (thumbRange * opacityPct) / 100;
   const int thumbY = (stripRowTop + stripRowBot) / 2;
   const int thumbR = stripRadius + 3;
   //--- Drop shadow + white outline + active-color fill
   WidgetFillCircleAA(canvas, thumbX, thumbY, thumbR + 1,
                       ColorToARGB(C'0,0,0', 60));
   WidgetFillCircleAA(canvas, thumbX, thumbY, thumbR,
                       ColorToARGB(C'255,255,255', 255));
   WidgetFillCircleAA(canvas, thumbX, thumbY, thumbR - 2,
                       ColorToARGB(activeColor, 255));

   //--- Editable percentage box on the right of the strip
   const int boxRowTop = stripBoxTop;
   const int boxRowBot = stripBoxTop + boxH;
   const int boxL = stripR + COLORPICKER_OPACITY_BOX_GAP;
   const int boxT = boxRowTop;
   const int boxRx = boxL + COLORPICKER_OPACITY_BOX_W;
   const int boxB = boxRowBot;
   //--- Border colors when editing vs not (DodgerBlue accent for editing, theme separator otherwise)
   const uint boxBorderArgb = boxIsEditing
      ? ColorToARGB(clrDodgerBlue, 255)
      : ColorToARGB(theme.separatorColor, 255);
   const uint boxFillArgb = ColorToARGB(theme.flyoutBackground, 255);
   WidgetStrokeRoundRect(canvas, boxL, boxT, boxRx, boxB,
                           4, 1, boxBorderArgb, boxFillArgb);

   //--- Build the text to display: edit buffer when editing, formatted percent otherwise
   string pctText;
   if(boxIsEditing)
      pctText = boxEditBuffer + "%";
   else
      pctText = IntegerToString(opacityPct) + "%";

   //--- Draw the text centered inside the box (approx char width = 6 px at the default font)
   canvas.FontSet("Arial", -100);
   const int approxTextW = StringLen(pctText) * 6;
   const int textX = (boxL + boxRx) / 2 - approxTextW / 2;
   const int textY = (boxT + boxB) / 2 - 7;
   canvas.TextOut(textX, textY, pctText,
                    ColorToARGB(theme.flyoutTextColor, 240));

   //--- Draw the blinking caret when editing + caret is in its visible phase
   if(boxIsEditing && boxCaretOn)
     {
      //--- Clamp the caret position to the buffer length
      int caretPos = boxCaretPos;
      if(caretPos < 0) caretPos = 0;
      if(caretPos > StringLen(boxEditBuffer)) caretPos = StringLen(boxEditBuffer);
      //--- Caret X = text origin + caret-column * approx char width
      const int caretOffsetW = caretPos * 6;
      const int caretX = textX + caretOffsetW;
      //--- Caret height matches the text run
      const int caretYTop = textY;
      const int caretYBot = textY + 12;
      canvas.Line(caretX, caretYTop, caretX, caretYBot,
                   ColorToARGB(theme.flyoutTextColor, 255));
     }
  }

//+------------------------------------------------------------------+
//| Hit-test the opacity strip: returns the percent value (or -1)    |
//+------------------------------------------------------------------+
int HitTestColorPickerOpacity(int lx, int ly, int originX, int originY)
  {
   //--- Recompute the strip geometry (matches RenderColorPickerContents layout)
   const int gridBottomY = originY + COLORPICKER_PAD_Y_TOP
                          + COLORPICKER_GRID_ROWS * COLORPICKER_SWATCH_SIZE
                          + (COLORPICKER_GRID_ROWS - 1) * COLORPICKER_SWATCH_GAP;
   const int dividerY      = gridBottomY + COLORPICKER_GRID_TO_DIVIDER;
   const int labelTop      = dividerY + COLORPICKER_DIVIDER_TO_OPACITY;
   const int stripBoxTop   = labelTop + COLORPICKER_OPACITY_LABEL_H + COLORPICKER_OPACITY_LABEL_GAP;
   const int boxH          = COLORPICKER_OPACITY_BOX_H;
   const int stripH        = COLORPICKER_OPACITY_STRIP_H;
   const int stripRowTop   = stripBoxTop + (boxH - stripH) / 2;
   const int stripRowBot   = stripRowTop + stripH;
   const int stripL        = originX + COLORPICKER_PAD_X;
   const int stripR        = originX + GetColorPickerBodyWidth()
                            - COLORPICKER_PAD_X
                            - COLORPICKER_OPACITY_BOX_W
                            - COLORPICKER_OPACITY_BOX_GAP;
   const int stripRadius = stripH / 2;
   //--- Generous vertical hit slack: full box height (easier to grab the thumb)
   const int slackTop = stripBoxTop;
   const int slackBot = stripBoxTop + boxH;
   //--- Reject points outside the strip's hit-zone
   if(ly < slackTop || ly > slackBot) return -1;
   if(lx < stripL || lx > stripR) return -1;
   //--- Map the lx coordinate into the 0..100 percent range
   const int xMin = stripL + stripRadius;
   const int xMax = stripR - stripRadius;
   const int span = xMax - xMin;
   if(span <= 0) return -1;
   int pct = ((lx - xMin) * 100) / span;
   //--- Clamp into 0..100
   if(pct < 0)   pct = 0;
   if(pct > 100) pct = 100;
   return pct;
  }

//+------------------------------------------------------------------+
//| Hit-test the editable percentage box (returns true if inside)    |
//+------------------------------------------------------------------+
bool HitTestColorPickerOpacityBox(int lx, int ly, int originX, int originY)
  {
   //--- Recompute the box geometry (matches RenderColorPickerContents layout)
   const int gridBottomY = originY + COLORPICKER_PAD_Y_TOP
                          + COLORPICKER_GRID_ROWS * COLORPICKER_SWATCH_SIZE
                          + (COLORPICKER_GRID_ROWS - 1) * COLORPICKER_SWATCH_GAP;
   const int dividerY    = gridBottomY + COLORPICKER_GRID_TO_DIVIDER;
   const int labelTop    = dividerY + COLORPICKER_DIVIDER_TO_OPACITY;
   const int stripBoxTop = labelTop + COLORPICKER_OPACITY_LABEL_H + COLORPICKER_OPACITY_LABEL_GAP;
   const int boxH        = COLORPICKER_OPACITY_BOX_H;
   const int stripR      = originX + GetColorPickerBodyWidth()
                          - COLORPICKER_PAD_X
                          - COLORPICKER_OPACITY_BOX_W
                          - COLORPICKER_OPACITY_BOX_GAP;
   const int boxL = stripR + COLORPICKER_OPACITY_BOX_GAP;
   const int boxT = stripBoxTop;
   const int boxRx = boxL + COLORPICKER_OPACITY_BOX_W;
   const int boxB = stripBoxTop + boxH;
   //--- Standard rectangle containment test
   return (lx >= boxL && lx < boxRx && ly >= boxT && ly < boxB);
  }

//+------------------------------------------------------------------+
//| Compute the caret column for click X inside the opacity box      |
//+------------------------------------------------------------------+
int ColorPickerOpacityBoxCaretFromX(int lx, int originX,
                                     string buffer)
  {
   //--- Recompute the box geometry (origin-relative; only the X matters for caret placement)
   const int gridBottomY = COLORPICKER_PAD_Y_TOP
                          + COLORPICKER_GRID_ROWS * COLORPICKER_SWATCH_SIZE
                          + (COLORPICKER_GRID_ROWS - 1) * COLORPICKER_SWATCH_GAP;
   const int dividerY    = gridBottomY + COLORPICKER_GRID_TO_DIVIDER;
   const int labelTop    = dividerY + COLORPICKER_DIVIDER_TO_OPACITY;
   const int stripBoxTop = labelTop + COLORPICKER_OPACITY_LABEL_H + COLORPICKER_OPACITY_LABEL_GAP;
   const int stripR      = originX + GetColorPickerBodyWidth()
                          - COLORPICKER_PAD_X
                          - COLORPICKER_OPACITY_BOX_W
                          - COLORPICKER_OPACITY_BOX_GAP;
   const int boxL = stripR + COLORPICKER_OPACITY_BOX_GAP;
   const int boxRx = boxL + COLORPICKER_OPACITY_BOX_W;
   //--- Text uses buffer + "%" so account for the trailing percent sign in width estimation
   const string displayedText = buffer + "%";
   const int approxTextW = StringLen(displayedText) * 6;
   const int textStartX = (boxL + boxRx) / 2 - approxTextW / 2;
   //--- Walk each possible caret column and pick the one closest to lx
   const int bufLen = StringLen(buffer);
   int bestCaret = bufLen;
   int bestDist  = 2147483647;
   for(int caret = 0; caret <= bufLen; caret++)
     {
      const int caretX = textStartX + caret * 6;
      const int dist = (lx >= caretX) ? (lx - caretX) : (caretX - lx);
      if(dist < bestDist)
        {
         bestDist  = dist;
         bestCaret = caret;
        }
     }
   return bestCaret;
  }

//+------------------------------------------------------------------+
//| RenderRibbonColorIcon - color picker icon for the ribbon         |
//+------------------------------------------------------------------+
void RenderRibbonColorIcon(CCanvas &canvas,
                            int x, int y, int size,
                            color activeColor,
                            int activeOpacityPct,
                            int glyphKind,
                            bool isHovered,
                            bool isActive,
                            const ThemeColorSet &theme,
                            const color &stripColors[],
                            const int   &stripOpacities[])
  {
   //--- Active-state highlight (active wins over hover when both are true)
   if(isActive)
     {
      const uint actArgb = ColorToARGB(theme.flyoutTextColor, 75);
      const int padAct = 3;
      FillNoteRoundRect(canvas,
                          x - padAct, y - padAct,
                          x + size + padAct, y + size + padAct,
                          5, actArgb);
     }
   else if(isHovered)
     {
      //--- Hover-state highlight (more subtle than active)
      const uint hovArgb = ColorToARGB(theme.flyoutTextColor, 35);
      const int padHov = 3;
      FillNoteRoundRect(canvas,
                          x - padHov, y - padHov,
                          x + size + padHov, y + size + padHov,
                          5, hovArgb);
     }

   //--- Color-strip geometry at the bottom of the icon
   const int stripH = 4;
   const int stripBottomMargin = 1;
   const int stripT = y + size - stripBottomMargin - stripH;
   const int stripB = stripT + stripH - 1;
   const int stripGap        = 3;
   //--- Glyph area sits above the strip with a small gap between them
   const int glyphAreaTop    = y + 4;
   const int glyphAreaBottom = stripT - stripGap;
   const int glyphHeight     = glyphAreaBottom - glyphAreaTop;

   //--- Only draw the glyph if there's vertical room for it
   if(glyphHeight > 4)
     {
      const uint glyphArgb = ColorToARGB(theme.flyoutTextColor, 230);
      const int gL = x + 4;
      const int gR = x + size - 4;
      const int gT = glyphAreaTop;
      const int gB = glyphAreaBottom;

      //--- glyphKind = 1: uppercase T glyph (5 Wu-AA strokes - top bar + serif drops + stem + base serif)
      if(glyphKind == 1)
        {
         //--- All positions are proportional fractions of the glyph rect
         const double W = (double)(gR - gL);
         const double H = (double)(gB - gT);
         const int topY = gT + (int)MathRound(H * 0.08);
         const int barL = gL + (int)MathRound(W * 0.20);
         const int barR = gR - (int)MathRound(W * 0.20);
         //--- Top horizontal bar
         WidgetWuLineAA(canvas, barL, topY, barR, topY, glyphArgb);
         //--- Two serif drops (small vertical tails at each end of the top bar)
         const int dropLen = (int)MathRound(H * 0.22);
         WidgetWuLineAA(canvas, barL, topY, barL, topY + dropLen, glyphArgb);
         WidgetWuLineAA(canvas, barR, topY, barR, topY + dropLen, glyphArgb);
         //--- Central vertical stem
         const int stemX   = (barL + barR) / 2;
         const int stemTop = topY;
         const int stemBot = gB - (int)MathRound(H * 0.08);
         WidgetWuLineAA(canvas, stemX, stemTop, stemX, stemBot, glyphArgb);
         //--- Base serif (small horizontal tick at the foot of the stem)
         const int baseHalf = (int)MathRound(W * 0.14);
         WidgetWuLineAA(canvas, stemX - baseHalf, stemBot,
                                 stemX + baseHalf, stemBot, glyphArgb);
        }
      //--- glyphKind = 2: paint bucket glyph (trapezoid body + handle arc + drop)
      else if(glyphKind == 2)
        {
         const double W = (double)(gR - gL);
         const double H = (double)(gB - gT);
         //--- Bucket rim (top opening) and base (narrower at the bottom) edges
         const int rimL  = gL + (int)MathRound(W * 0.15);
         const int rimR  = gR - (int)MathRound(W * 0.15);
         const int rimY  = gT + (int)MathRound(H * 0.34);
         const int baseL = gL + (int)MathRound(W * 0.30);
         const int baseR = gR - (int)MathRound(W * 0.30);
         const int baseY = gT + (int)MathRound(H * 0.78);
         //--- Bucket body (4 strokes: top + left + right + bottom)
         WidgetWuLineAA(canvas, rimL,  rimY,  rimR,  rimY,  glyphArgb);
         WidgetWuLineAA(canvas, rimL,  rimY,  baseL, baseY, glyphArgb);
         WidgetWuLineAA(canvas, rimR,  rimY,  baseR, baseY, glyphArgb);
         WidgetWuLineAA(canvas, baseL, baseY, baseR, baseY, glyphArgb);
         //--- Handle: 4 short Wu lines approximating a low arc above the rim
         const int handlePeakX  = (rimL + rimR) / 2;
         const int handlePeakY  = gT + (int)MathRound(H * 0.10);
         const int handleLeftX  = rimL - (int)MathRound(W * 0.02);
         const int handleLeftY  = rimY - (int)MathRound(H * 0.05);
         const int handleRightX = rimR + (int)MathRound(W * 0.02);
         const int handleRightY = rimY - (int)MathRound(H * 0.05);
         const int handleMidLX  = (handleLeftX + handlePeakX) / 2;
         const int handleMidLY  = handlePeakY - (int)MathRound(H * 0.02);
         const int handleMidRX  = (handlePeakX + handleRightX) / 2;
         const int handleMidRY  = handlePeakY - (int)MathRound(H * 0.02);
         WidgetWuLineAA(canvas, handleLeftX,  handleLeftY,
                                  handleMidLX, handleMidLY, glyphArgb);
         WidgetWuLineAA(canvas, handleMidLX,  handleMidLY,
                                  handlePeakX, handlePeakY, glyphArgb);
         WidgetWuLineAA(canvas, handlePeakX,  handlePeakY,
                                  handleMidRX, handleMidRY, glyphArgb);
         WidgetWuLineAA(canvas, handleMidRX,  handleMidRY,
                                  handleRightX, handleRightY, glyphArgb);
         //--- Drop falling out the bottom: triangular shape (top edge + two slanted sides)
         const int dropCx  = (baseL + baseR) / 2;
         const int dropTop = baseY + (int)MathRound(H * 0.04);
         const int dropTip = gB - 1;
         int dropHalfW = (int)MathRound(W * 0.07);
         if(dropHalfW < 1) dropHalfW = 1;
         WidgetWuLineAA(canvas, dropCx - dropHalfW, dropTop,
                                  dropCx + dropHalfW, dropTop,    glyphArgb);
         WidgetWuLineAA(canvas, dropCx - dropHalfW, dropTop,
                                  dropCx,            dropTip,     glyphArgb);
         WidgetWuLineAA(canvas, dropCx + dropHalfW, dropTop,
                                  dropCx,            dropTip,     glyphArgb);
        }
      //--- Default glyphKind: rising trendline diagonal (bottom-left to top-right)
      else
        {
         WidgetWuLineAA(canvas, gL, gB, gR, gT, glyphArgb);
        }
     }

   //--- Color-strip backdrop = transparency checker so partially-transparent overlay shows through
   const int stripL = x + 2;
   const int stripR = x + size - 2;
   WidgetCheckerFillRect(canvas, stripL, stripT, stripR, stripB + 1, 2);
   //--- Single-band path: paint the full strip with the active color at the active opacity
   const int nBands = ArraySize(stripColors);
   if(nBands <= 1)
     {
      const uint overlayArgb = ColorWithPercentOpacity(activeColor, activeOpacityPct);
      for(int yy = stripT; yy <= stripB; yy++)
         for(int xx = stripL; xx < stripR; xx++)
            WidgetBlendPixel(canvas, xx, yy, overlayArgb);
     }
   else
     {
      //--- Multi-band path: paint a 4-stop diagonal gradient (red -> orange -> teal -> purple) for an "open the picker" affordance
      const color stops[4] = { (color)0xFFE74C3C,
                                (color)0xFFF39C12,
                                (color)0xFF1ABC9C,
                                (color)0xFF6C3FA0 };
      const int sw = stripR - stripL;
      const int sh = stripB - stripT + 1;
      if(sw > 0 && sh > 0)
        {
         //--- Diagonal skew of the gradient axis (positive moves the gradient with the rows)
         const double diagAmt = 0.35;
         for(int yy = stripT; yy <= stripB; yy++)
           {
            const double yt = (double)(yy - stripT) / (double)(sh > 1 ? sh - 1 : 1);
            for(int xx = stripL; xx < stripR; xx++)
              {
               //--- Normalize x to 0..1 and skew by the row's y position
               const double xt = (double)(xx - stripL) / (double)(sw > 1 ? sw - 1 : 1);
               double u = xt + (yt - 0.5) * diagAmt;
               if(u < 0.0) u = 0.0; else if(u > 1.0) u = 1.0;
               //--- Map u into one of 3 inter-stop segments (3 segments between 4 stops)
               double seg_d = u * 3.0;
               int    seg   = (int)seg_d;
               if(seg > 2) seg = 2;
               //--- Linear blend between the two endpoint colors of the current segment
               double t     = seg_d - (double)seg;
               const color cA = stops[seg];
               const color cB = stops[seg + 1];
               //--- Decompose each stop into BGR bytes (MQL5 color layout)
               const uchar rA = (uchar)((cA)       & 0xFF);
               const uchar gA = (uchar)((cA >> 8)  & 0xFF);
               const uchar bA = (uchar)((cA >> 16) & 0xFF);
               const uchar rB = (uchar)((cB)       & 0xFF);
               const uchar gB = (uchar)((cB >> 8)  & 0xFF);
               const uchar bB = (uchar)((cB >> 16) & 0xFF);
               //--- Per-channel lerp with rounding
               const uchar r  = (uchar)((double)rA * (1.0 - t) + (double)rB * t + 0.5);
               const uchar g  = (uchar)((double)gA * (1.0 - t) + (double)gB * t + 0.5);
               const uchar b  = (uchar)((double)bA * (1.0 - t) + (double)bB * t + 0.5);
               //--- Reassemble into ARGB at ~90 percent alpha (0xE6) and write the pixel
               const uint argb = ((uint)0xE6 << 24) | ((uint)b << 16) | ((uint)g << 8) | (uint)r;
               WidgetBlendPixel(canvas, xx, yy, argb);
              }
           }
        }
     }
  }

//+------------------------------------------------------------------+
//| Outline a rectangle with 1-px Wu lines (compact-chip border)     |
//+------------------------------------------------------------------+
void CompactChipOutline(CCanvas &canvas, int x, int y, int x2, int y2,
                         uint argb)
  {
   //--- 4 Wu-AA edges (top, right, bottom, left)
   WidgetWuLineAA(canvas, x,  y,  x2, y,  argb);
   WidgetWuLineAA(canvas, x2, y,  x2, y2, argb);
   WidgetWuLineAA(canvas, x2, y2, x,  y2, argb);
   WidgetWuLineAA(canvas, x,  y2, x,  y,  argb);
  }

//+------------------------------------------------------------------+
//| Render the visibility checkbox cube inside a compact row         |
//+------------------------------------------------------------------+
void RenderCompactRowCheckbox(CCanvas &canvas, int x, int y, int size,
                                bool checked, const ThemeColorSet &theme)
  {
   //--- Fill color when checked (theme's active accent) + outline color (theme text at 78 percent)
   const uint fillArgb   = ColorToARGB(theme.flyoutTextActiveColor, 255);
   const uint outlineArgb= ColorToARGB(theme.flyoutTextColor, 200);
   const int x2 = x + size - 1;
   const int y2 = y + size - 1;
   //--- Solid fill when checked
   if(checked)
     {
      for(int yy = y; yy <= y2; yy++)
         for(int xx = x; xx <= x2; xx++)
            WidgetBlendPixel(canvas, xx, yy, fillArgb);
     }
   //--- 1-px Wu outline (drawn whether checked or not)
   CompactChipOutline(canvas, x, y, x2, y2, outlineArgb);
   //--- White tick glyph (two Wu segments forming a checkmark) when checked
   if(checked)
     {
      const uint tickArgb = ColorToARGB(clrWhite, 255);
      //--- Tick goes from lower-left elbow to upper-right tip
      const int tx0 = x + size / 4;
      const int ty0 = y + size / 2;
      const int tx1 = x + size * 4 / 10;
      const int ty1 = y + size * 7 / 10;
      const int tx2 = x + size * 3 / 4;
      const int ty2 = y + size / 4 + 1;
      WidgetWuLineAA(canvas, tx0, ty0, tx1, ty1, tickArgb);
      WidgetWuLineAA(canvas, tx1, ty1, tx2, ty2, tickArgb);
     }
  }

//+------------------------------------------------------------------+
//| Render the value-stepper cube (number text + up/down chevrons)   |
//+------------------------------------------------------------------+
void RenderCompactRowValueStepper(CCanvas &canvas, int x, int y,
                                    int w, int h, double value,
                                    int decimals, const ThemeColorSet &theme)
  {
   const int x2 = x + w - 1;
   const int y2 = y + h - 1;
   //--- 1-px Wu outline using a subdued theme color
   const uint outline = ColorToARGB(theme.flyoutTextColor, 120);
   CompactChipOutline(canvas, x, y, x2, y2, outline);
   //--- Format the value with the caller-specified decimal places
   string valStr = DoubleToString(value, decimals);
   //--- Default canvas font
   canvas.FontSet("Arial", -100);
   const uint txtArgb = ColorToARGB(theme.flyoutTextColor, 230);
   const int tw = canvas.TextWidth(valStr);
   const int th = canvas.TextHeight(valStr);
   //--- Reserve 14 px on the right for the chevrons; center the text in the remaining area
   const int valAreaR = x2 - 14;
   int valX = x + 6 + ((valAreaR - x - 6 - tw) / 2);
   if(valX < x + 4) valX = x + 4;
   const int valY = y + (h - th) / 2;
   canvas.TextOut(valX, valY, valStr, txtArgb);
   //--- Up-chevron at top of stepper + down-chevron at bottom (both 3-pixel Wu glyphs)
   const uint chevArgb = ColorToARGB(theme.flyoutTextColor, 200);
   const int chevX = x2 - 9;
   const int chevYUp   = y + 4;
   const int chevYDn   = y + h - 5;
   WidgetWuLineAA(canvas, chevX,     chevYUp + 3, chevX + 3, chevYUp,     chevArgb);
   WidgetWuLineAA(canvas, chevX + 3, chevYUp,     chevX + 6, chevYUp + 3, chevArgb);
   WidgetWuLineAA(canvas, chevX,     chevYDn - 3, chevX + 3, chevYDn,     chevArgb);
   WidgetWuLineAA(canvas, chevX + 3, chevYDn,     chevX + 6, chevYDn - 3, chevArgb);
  }

//+------------------------------------------------------------------+
//| Render the color-chip cube (checker backdrop + solid color fill) |
//+------------------------------------------------------------------+
void RenderCompactRowColorChip(CCanvas &canvas, int x, int y,
                                 int w, int h, color c,
                                 const ThemeColorSet &theme)
  {
   const int x2 = x + w - 1;
   const int y2 = y + h - 1;
   //--- Inset the color swatch area by 3 px so the outline doesn't overlap it
   const int sL = x + 3;
   const int sT = y + 3;
   const int sR = x2 - 3;
   const int sB = y2 - 3;
   //--- Transparency checker backdrop (shows through if c has alpha < 1)
   WidgetCheckerFillRect(canvas, sL, sT, sR + 1, sB + 1, 2);
   //--- Overlay the chosen color at full opacity
   const uint argb = ColorToARGB(c, 255);
   for(int yy = sT; yy <= sB; yy++)
      for(int xx = sL; xx <= sR; xx++)
         WidgetBlendPixel(canvas, xx, yy, argb);
   //--- 1-px Wu outline around the chip
   const uint outline = ColorToARGB(theme.flyoutTextColor, 120);
   CompactChipOutline(canvas, x, y, x2, y2, outline);
  }

//+------------------------------------------------------------------+
//| Render a horizontal stroke preview (solid or dashed) inside rect |
//+------------------------------------------------------------------+
void StrokeLinePreview(CCanvas &canvas,
                        int l, int t, int r, int b,
                        int lineWidth, int lineStyle,
                        uint argb)
  {
   //--- Preview line is drawn at the vertical midline of the box
   const int yMid = (t + b) / 2;
   //--- Solid style: simple anti-aliased thick line
   if(lineStyle == 0)
     {
      WidgetThickLineAA(canvas, l, yMid, r, yMid, lineWidth, argb);
     }
   else
     {
      //--- Dashed/dotted: derive a dash pattern from the style + width, then render as a dashed AA line
      int pat[];
      const int n = BuildLineStylePattern(lineStyle, lineWidth, pat);
      if(n > 0)
        {
         WidgetDashedLineAA(canvas, l, yMid, r, yMid, lineWidth, argb, pat);
        }
     }
  }

//+------------------------------------------------------------------+
//| Render the width-chip cube (outline + solid stroke preview)      |
//+------------------------------------------------------------------+
void RenderCompactRowWidthChip(CCanvas &canvas, int x, int y,
                                 int w, int h, int width,
                                 const ThemeColorSet &theme)
  {
   const int x2 = x + w - 1;
   const int y2 = y + h - 1;
   //--- 1-px outline
   const uint outline = ColorToARGB(theme.flyoutTextColor, 120);
   CompactChipOutline(canvas, x, y, x2, y2, outline);
   //--- Preview the stroke at lineStyle=0 (solid) so width is the only varying dimension
   const uint stkArgb = ColorToARGB(theme.flyoutTextColor, 230);
   const int sL = x + 5;
   const int sR = x2 - 5;
   const int sY = y + h / 2;
   StrokeLinePreview(canvas, sL, sY, sR, sY, width, 0, stkArgb);
  }

//+------------------------------------------------------------------+
//| Render the style-chip cube (outline + styled stroke preview)     |
//+------------------------------------------------------------------+
void RenderCompactRowStyleChip(CCanvas &canvas, int x, int y,
                                 int w, int h, int style, int width,
                                 const ThemeColorSet &theme)
  {
   const int x2 = x + w - 1;
   const int y2 = y + h - 1;
   //--- 1-px outline
   const uint outline = ColorToARGB(theme.flyoutTextColor, 120);
   CompactChipOutline(canvas, x, y, x2, y2, outline);
   //--- Preview the stroke at the caller's lineStyle (so the chip shows the actual style)
   const uint stkArgb = ColorToARGB(theme.flyoutTextColor, 230);
   const int sL = x + 5;
   const int sR = x2 - 5;
   const int sY = y + h / 2;
   StrokeLinePreview(canvas, sL, sY, sR, sY, width, style, stkArgb);
  }

//+------------------------------------------------------------------+
//| SCompactRowLayout - per-sub-widget bounding rects for one row    |
//+------------------------------------------------------------------+
struct SCompactRowLayout
  {
   //--- Visibility checkbox bounds
   int chkL,   chkT,   chkR,   chkB;
   //--- Value stepper bounds
   int valL,   valT,   valR,   valB;
   //--- Color chip bounds
   int colL,   colT,   colR,   colB;
   //--- Width chip bounds
   int wL,     wT,     wR,     wB;
   //--- Style chip bounds
   int sL,     sT,     sR,     sB;
  };

//+------------------------------------------------------------------+
//| Compute per-sub-widget rects for one compact row (right-aligned) |
//+------------------------------------------------------------------+
void CompactRowComputeLayout(int contR, int contMidY,
                              const string subVisibleId,
                              const string subValueId,
                              const string subColorId,
                              const string subWidthId,
                              const string subStyleId,
                              SCompactRowLayout &out)
  {
   //--- Spacing + per-sub-widget dimensions
   const int gap     = 6;
   const int chipW   = 28;
   const int chipH   = 24;
   const int chkSize = 18;
   const int valW    = 60;
   //--- Sentinel-fill every rect to -1 so callers can detect "not present"
   out.chkL = out.chkT = out.chkR = out.chkB = -1;
   out.valL = out.valT = out.valR = out.valB = -1;
   out.colL = out.colT = out.colR = out.colB = -1;
   out.wL   = out.wT   = out.wR   = out.wB   = -1;
   out.sL   = out.sT   = out.sR   = out.sB   = -1;
   //--- Walk right-to-left, allocating each sub-widget only if its ID was supplied
   int cursorX = contR;
   const int chipT = contMidY - chipH / 2;
   const int chkT  = contMidY - chkSize / 2;
   //--- Style chip first (rightmost)
   if(StringLen(subStyleId) > 0)
     {
      cursorX -= chipW;
      out.sL = cursorX; out.sT = chipT; out.sR = cursorX + chipW; out.sB = chipT + chipH;
      cursorX -= gap;
     }
   //--- Width chip
   if(StringLen(subWidthId) > 0)
     {
      cursorX -= chipW;
      out.wL = cursorX; out.wT = chipT; out.wR = cursorX + chipW; out.wB = chipT + chipH;
      cursorX -= gap;
     }
   //--- Color chip
   if(StringLen(subColorId) > 0)
     {
      cursorX -= chipW;
      out.colL = cursorX; out.colT = chipT; out.colR = cursorX + chipW; out.colB = chipT + chipH;
      cursorX -= gap;
     }
   //--- Value stepper (wider than the chips)
   if(StringLen(subValueId) > 0)
     {
      cursorX -= valW;
      out.valL = cursorX; out.valT = chipT; out.valR = cursorX + valW; out.valB = chipT + chipH;
      cursorX -= gap;
     }
   //--- Visibility checkbox (leftmost, slightly smaller than the chips)
   if(StringLen(subVisibleId) > 0)
     {
      cursorX -= chkSize;
      out.chkL = cursorX; out.chkT = chkT; out.chkR = cursorX + chkSize; out.chkB = chkT + chkSize;
     }
  }

//--- Line-width / line-style popover layout constants
#define LINEPOPOVER_PAD_X            10
#define LINEPOPOVER_PAD_Y_TOP         8
#define LINEPOPOVER_PAD_Y_BOTTOM      8
#define LINEPOPOVER_ROW_H            22
#define LINEPOPOVER_ROW_GAP           2
#define LINEPOPOVER_NUM_OPTIONS       4
#define LINEPOPOVER_STROKE_W         20
#define LINEPOPOVER_STROKE_LABEL_GAP 10
#define LINEPOPOVER_APPROX_CHAR_W     6

//+------------------------------------------------------------------+
//| Map a line-style index (0..3) to its human label                 |
//+------------------------------------------------------------------+
string GetLineStyleLabel(int styleIdx)
  {
   //--- Hand-rolled lookup for the 4 supported styles
   switch(styleIdx)
     {
      case 0: return "Line";
      case 1: return "Dashed line";
      case 2: return "Dotted line";
      case 3: return "Dash-dot line";
     }
   //--- Unknown styles return empty
   return "";
  }

//+------------------------------------------------------------------+
//| Width-popover body width (constant: stroke + small label "Xpx")  |
//+------------------------------------------------------------------+
int GetLineWidthPopoverBodyWidth()
  {
   //--- Width labels are 3 chars ("1px"..."4px") - measure with the approximate char width
   const int labelW = 3 * LINEPOPOVER_APPROX_CHAR_W;
   return LINEPOPOVER_PAD_X + LINEPOPOVER_STROKE_W
        + LINEPOPOVER_STROKE_LABEL_GAP + labelW + LINEPOPOVER_PAD_X;
  }

//+------------------------------------------------------------------+
//| Style-popover body width (sized to the longest style label)      |
//+------------------------------------------------------------------+
int GetLineStylePopoverBodyWidth()
  {
   //--- Scan the 4 style labels and find the longest one (in chars)
   int longest = 0;
   for(int i = 0; i < LINEPOPOVER_NUM_OPTIONS; i++)
     {
      const int len = StringLen(GetLineStyleLabel(i));
      if(len > longest) longest = len;
     }
   //--- Body = pad + stroke preview + gap + longest label width + pad
   const int labelW = longest * LINEPOPOVER_APPROX_CHAR_W;
   return LINEPOPOVER_PAD_X + LINEPOPOVER_STROKE_W
        + LINEPOPOVER_STROKE_LABEL_GAP + labelW + LINEPOPOVER_PAD_X;
  }

//+------------------------------------------------------------------+
//| Line popover body height (same for both width and style variants)|
//+------------------------------------------------------------------+
int GetLineWidthPopoverBodyHeight()
  {
   //--- Top pad + 4 rows + 3 inter-row gaps + bottom pad
   return LINEPOPOVER_PAD_Y_TOP
        + LINEPOPOVER_NUM_OPTIONS * LINEPOPOVER_ROW_H
        + (LINEPOPOVER_NUM_OPTIONS - 1) * LINEPOPOVER_ROW_GAP
        + LINEPOPOVER_PAD_Y_BOTTOM;
  }
//--- Style popover shares the same body height as the width popover
int GetLineStylePopoverBodyHeight() { return GetLineWidthPopoverBodyHeight(); }

//+------------------------------------------------------------------+
//| Compute the bounding rect for line-popover row `rowIdx`          |
//+------------------------------------------------------------------+
void GetLinePopoverRowRect(int rowIdx, int originX, int originY, int bodyW,
                            int &outL, int &outT, int &outR, int &outB)
  {
   //--- Rows span the full popover width
   outL = originX;
   outR = originX + bodyW;
   //--- Top edge = origin + top pad + row offset (row height + gap stride)
   outT = originY + LINEPOPOVER_PAD_Y_TOP
        + rowIdx * (LINEPOPOVER_ROW_H + LINEPOPOVER_ROW_GAP);
   //--- Bottom = top + row height
   outB = outT + LINEPOPOVER_ROW_H;
  }

//+------------------------------------------------------------------+
//| Render the rows of the line-width OR line-style popover          |
//+------------------------------------------------------------------+
void RenderLinePopoverRows(CCanvas &canvas,
                            int originX, int originY, int bodyW,
                            int activeOptionIdx,
                            int hoveredIdx,
                            int lineWidthOption,
                            int lineStyleOption,
                            color strokeColor,
                            const ThemeColorSet &theme)
  {
   //--- 4 fixed rows (LINEPOPOVER_NUM_OPTIONS) - one per width or style
   for(int i = 0; i < LINEPOPOVER_NUM_OPTIONS; i++)
     {
      int rL, rT, rR, rB;
      GetLinePopoverRowRect(i, originX, originY, bodyW, rL, rT, rR, rB);
      //--- Active-row highlight (stronger than hover)
      if(i == activeOptionIdx)
        {
         const uint actArgb = ColorToARGB(theme.flyoutTextColor, 55);
         for(int yy = rT; yy < rB; yy++)
            for(int xx = rL; xx < rR; xx++)
               WidgetBlendPixel(canvas, xx, yy, actArgb);
        }
      else if(i == hoveredIdx)
        {
         //--- Hover-row highlight (more subtle)
         const uint hovArgb = ColorToARGB(theme.flyoutTextColor, 25);
         for(int yy = rT; yy < rB; yy++)
            for(int xx = rL; xx < rR; xx++)
               WidgetBlendPixel(canvas, xx, yy, hovArgb);
        }
      //--- Width and style preview: in width-popover, w varies (i+1) and s is fixed; in style-popover, s varies (i) and w is fixed
      const int w = (lineWidthOption >= 0) ? lineWidthOption : (i + 1);
      const int s = (lineStyleOption >= 0) ? lineStyleOption : i;
      //--- Stroke preview at the left of the row
      const int sL = rL + LINEPOPOVER_PAD_X;
      const int sR = sL + LINEPOPOVER_STROKE_W;
      StrokeLinePreview(canvas, sL, rT, sR, rB, w, s,
                          ColorToARGB(strokeColor, 255));
      //--- Label text: "Xpx" for width-popover, style name for style-popover, empty for the orthogonal axis
      string label = "";
      if(lineWidthOption < 0)
         label = IntegerToString(i + 1) + "px";
      else if(lineStyleOption < 0)
         label = GetLineStyleLabel(i);
      //--- Position the label to the right of the stroke preview with gap, vertically centered
      const int textX = sR + LINEPOPOVER_STROKE_LABEL_GAP;
      const int textY = (rT + rB) / 2 - 7;
      canvas.FontSet("Arial", -100);
      canvas.TextOut(textX, textY, label,
                       ColorToARGB(theme.flyoutTextColor, 240));
     }
  }

//+------------------------------------------------------------------+
//| Render the line-width popover (4 rows of 1px..4px, active style) |
//+------------------------------------------------------------------+
void RenderLineWidthPopoverContents(CCanvas &canvas,
                                     int originX, int originY,
                                     int activeWidth,
                                     int activeStyle,
                                     int hoveredIdx,
                                     color strokeColor,
                                     const ThemeColorSet &theme)
  {
   //--- Clamp activeWidth into 1..4 so the active-row index is valid
   if(activeWidth < 1) activeWidth = 1;
   if(activeWidth > 4) activeWidth = 4;
   //--- Delegate to the shared row renderer: activeOption = width-1 (rows are 0-indexed), lineWidthOption = -1 (so w varies per row)
   RenderLinePopoverRows(canvas, originX, originY, GetLineWidthPopoverBodyWidth(),
                          activeWidth - 1, hoveredIdx,
                          -1, activeStyle, strokeColor, theme);
  }

//+------------------------------------------------------------------+
//| Render the line-style popover (4 rows of solid..dash-dot)        |
//+------------------------------------------------------------------+
void RenderLineStylePopoverContents(CCanvas &canvas,
                                     int originX, int originY,
                                     int activeStyle,
                                     int activeWidth,
                                     int hoveredIdx,
                                     color strokeColor,
                                     const ThemeColorSet &theme)
  {
   //--- Clamp activeStyle into 0..3 so the active-row index is valid
   if(activeStyle < 0) activeStyle = 0;
   if(activeStyle > 3) activeStyle = 3;
   //--- Delegate to the shared row renderer: activeOption = style, lineStyleOption = -1 (so s varies per row)
   RenderLinePopoverRows(canvas, originX, originY, GetLineStylePopoverBodyWidth(),
                          activeStyle, hoveredIdx,
                          activeWidth, -1, strokeColor, theme);
  }

//+------------------------------------------------------------------+
//| Generic hit-test for a line popover row (returns row idx or -1)  |
//+------------------------------------------------------------------+
int HitTestLinePopoverRow(int lx, int ly, int originX, int originY, int bodyW)
  {
   //--- Linear scan over the 4 rows
   for(int i = 0; i < LINEPOPOVER_NUM_OPTIONS; i++)
     {
      int rL, rT, rR, rB;
      GetLinePopoverRowRect(i, originX, originY, bodyW, rL, rT, rR, rB);
      if(lx >= rL && lx < rR && ly >= rT && ly < rB) return i;
     }
   return -1;
  }
//--- Width popover delegates to the generic hit-test using the width-popover body width
int HitTestLineWidthPopover(int lx, int ly, int originX, int originY)
  { return HitTestLinePopoverRow(lx, ly, originX, originY, GetLineWidthPopoverBodyWidth()); }
//--- Style popover delegates to the generic hit-test using the style-popover body width
int HitTestLineStylePopover(int lx, int ly, int originX, int originY)
  { return HitTestLinePopoverRow(lx, ly, originX, originY, GetLineStylePopoverBodyWidth()); }

//--- Integer-list popover (used for font-size, vertical alignment, horizontal alignment dropdowns)
#define INTLIST_PAD_X            10
#define INTLIST_PAD_Y_TOP         8
#define INTLIST_PAD_Y_BOTTOM      8
#define INTLIST_ROW_H            22
#define INTLIST_ROW_GAP           2
#define INTLIST_APPROX_CHAR_W     6

//+------------------------------------------------------------------+
//| Integer-list popover body width (sized to the longest label)     |
//+------------------------------------------------------------------+
int GetIntegerListPopoverBodyWidth(const string &labels[])
  {
   //--- Scan all labels and find the longest one in chars
   int longest = 0;
   const int n = ArraySize(labels);
   for(int i = 0; i < n; i++)
     {
      const int len = StringLen(labels[i]);
      if(len > longest) longest = len;
     }
   //--- Body = pad + longest label width + pad; enforce an 80-px floor for usability
   int bodyW = INTLIST_PAD_X + longest * INTLIST_APPROX_CHAR_W + INTLIST_PAD_X;
   if(bodyW < 80) bodyW = 80;
   return bodyW;
  }

//+------------------------------------------------------------------+
//| Integer-list popover body height = pad + N rows + (N-1) gaps     |
//+------------------------------------------------------------------+
int GetIntegerListPopoverBodyHeight(int itemCount)
  {
   //--- Empty list: return a 40-px sentinel so the popover doesn't disappear
   if(itemCount <= 0) return 40;
   return INTLIST_PAD_Y_TOP
        + itemCount * INTLIST_ROW_H
        + (itemCount - 1) * INTLIST_ROW_GAP
        + INTLIST_PAD_Y_BOTTOM;
  }

//+------------------------------------------------------------------+
//| Compute the bounding rect for integer-list row `rowIdx`          |
//+------------------------------------------------------------------+
void GetIntegerListRowRect(int rowIdx, int originX, int originY, int bodyW,
                            int &outL, int &outT, int &outR, int &outB)
  {
   //--- Rows span the full popover width
   outL = originX;
   outR = originX + bodyW;
   //--- Top edge = origin + top pad + row offset stride
   outT = originY + INTLIST_PAD_Y_TOP
        + rowIdx * (INTLIST_ROW_H + INTLIST_ROW_GAP);
   outB = outT + INTLIST_ROW_H;
  }

//+------------------------------------------------------------------+
//| Render the integer-list popover rows with active + hover states  |
//+------------------------------------------------------------------+
void RenderIntegerListPopoverContents(CCanvas &canvas,
                                       int originX, int originY,
                                       const string &labels[],
                                       const int    &values[],
                                       int activeValue,
                                       int hoveredIdx,
                                       const ThemeColorSet &theme)
  {
   //--- Iterate over every label/value pair
   const int n = ArraySize(labels);
   const int bodyW = GetIntegerListPopoverBodyWidth(labels);
   for(int i = 0; i < n; i++)
     {
      int rL, rT, rR, rB;
      GetIntegerListRowRect(i, originX, originY, bodyW, rL, rT, rR, rB);
      //--- Active-row highlight (strongest); active is matched by value, not by index
      const bool isActive = (values[i] == activeValue);
      if(isActive)
        {
         const uint actArgb = ColorToARGB(theme.flyoutTextColor, 55);
         for(int yy = rT; yy < rB; yy++)
            for(int xx = rL; xx < rR; xx++)
               WidgetBlendPixel(canvas, xx, yy, actArgb);
        }
      else if(i == hoveredIdx)
        {
         //--- Hover-row highlight (more subtle)
         const uint hovArgb = ColorToARGB(theme.flyoutTextColor, 25);
         for(int yy = rT; yy < rB; yy++)
            for(int xx = rL; xx < rR; xx++)
               WidgetBlendPixel(canvas, xx, yy, hovArgb);
        }
      //--- Draw the row's label text vertically centered
      canvas.FontSet("Arial", -100);
      const int lh = canvas.TextHeight(labels[i]);
      const int textX = rL + INTLIST_PAD_X;
      const int textY = rT + (INTLIST_ROW_H - lh) / 2;
      canvas.TextOut(textX, textY, labels[i],
                       ColorToARGB(theme.flyoutTextColor, 240));
     }
  }

//+------------------------------------------------------------------+
//| Hit-test the integer-list popover (returns row index or -1)      |
//+------------------------------------------------------------------+
int HitTestIntegerListPopover(int lx, int ly, int originX, int originY,
                               int itemCount, const string &labels[])
  {
   //--- Scan every row for containment
   const int bodyW = GetIntegerListPopoverBodyWidth(labels);
   for(int i = 0; i < itemCount; i++)
     {
      int rL, rT, rR, rB;
      GetIntegerListRowRect(i, originX, originY, bodyW, rL, rT, rR, rB);
      if(lx >= rL && lx < rR && ly >= rT && ly < rB) return i;
     }
   return -1;
  }

//+------------------------------------------------------------------+
//| Build the canonical font-size option list (14 sizes 8..40)       |
//+------------------------------------------------------------------+
void BuildFontSizeOptions(string &outLabels[], int &outValues[])
  {
   //--- Hand-rolled list of common font sizes (matches Engine_Properties' fontSize clamp band)
   const int sizes[] = {8, 9, 10, 11, 12, 14, 16, 18, 20, 22, 24, 28, 32, 40};
   const int n = ArraySize(sizes);
   ArrayResize(outLabels, n);
   ArrayResize(outValues, n);
   //--- Populate values + their stringified labels in parallel
   for(int i = 0; i < n; i++)
     {
      outValues[i] = sizes[i];
      outLabels[i] = IntegerToString(sizes[i]);
     }
  }

//+------------------------------------------------------------------+
//| Build the vertical-alignment option list (Top/Middle/Bottom)     |
//+------------------------------------------------------------------+
void BuildVAlignOptions(string &outLabels[], int &outValues[])
  {
   //--- 3 fixed options
   ArrayResize(outLabels, 3);
   ArrayResize(outValues, 3);
   outLabels[0] = "Top";    outValues[0] = 0;
   outLabels[1] = "Middle"; outValues[1] = 1;
   outLabels[2] = "Bottom"; outValues[2] = 2;
  }

//+------------------------------------------------------------------+
//| Build the horizontal-alignment option list (Left/Center/Right)   |
//+------------------------------------------------------------------+
void BuildHAlignOptions(string &outLabels[], int &outValues[])
  {
   //--- 3 fixed options
   ArrayResize(outLabels, 3);
   ArrayResize(outValues, 3);
   outLabels[0] = "Left";   outValues[0] = 0;
   outLabels[1] = "Center"; outValues[1] = 1;
   outLabels[2] = "Right";  outValues[2] = 2;
  }

//+------------------------------------------------------------------+
//| RenderRibbonLineWidthIcon - ribbon icon for the line-width btn   |
//+------------------------------------------------------------------+
void RenderRibbonLineWidthIcon(CCanvas &canvas,
                                int x, int y, int width, int height,
                                int activeWidth,
                                bool isHovered,
                                bool isActive,
                                const ThemeColorSet &theme)
  {
   //--- Active highlight (stronger than hover) - rounded rect inflated by padAct
   if(isActive)
     {
      const uint actArgb = ColorToARGB(theme.flyoutTextColor, 75);
      const int padAct = 3;
      FillNoteRoundRect(canvas, x - padAct, y - padAct,
                         x + width + padAct, y + height + padAct, 5, actArgb);
     }
   else if(isHovered)
     {
      //--- Hover highlight (subtler)
      const uint hovArgb = ColorToARGB(theme.flyoutTextColor, 35);
      const int padHov = 3;
      FillNoteRoundRect(canvas, x - padHov, y - padHov,
                         x + width + padHov, y + height + padHov, 5, hovArgb);
     }
   //--- Clamp activeWidth into 1..4
   if(activeWidth < 1) activeWidth = 1;
   if(activeWidth > 4) activeWidth = 4;
   //--- Layout: left pad + stroke preview + gap + label ("Xpx")
   const int padL       = 4;
   const int strokeW    = 20;
   const int strokeGap  = 6;
   const int sL = x + padL;
   const int sR = sL + strokeW;
   const int sY = y + height / 2;
   const uint glyphArgb = ColorToARGB(theme.flyoutTextColor, 230);
   //--- AA thick line preview at the active width
   WidgetThickLineAA(canvas, sL, sY, sR, sY, activeWidth, glyphArgb);
   //--- Label "Xpx" to the right of the stroke preview
   const string label = IntegerToString(activeWidth) + "px";
   const int textX = sR + strokeGap;
   const int textY = sY - 7;
   canvas.FontSet("Arial", -100);
   canvas.TextOut(textX, textY, label,
                    ColorToARGB(theme.flyoutTextColor, 240));
  }

//+------------------------------------------------------------------+
//| RenderRibbonLineStyleIcon - ribbon icon for the line-style btn   |
//+------------------------------------------------------------------+
void RenderRibbonLineStyleIcon(CCanvas &canvas,
                                int x, int y, int width, int height,
                                int activeStyle, int activeWidth,
                                bool isHovered,
                                bool isActive,
                                const ThemeColorSet &theme)
  {
   //--- Active highlight
   if(isActive)
     {
      const uint actArgb = ColorToARGB(theme.flyoutTextColor, 75);
      const int padAct = 3;
      FillNoteRoundRect(canvas, x - padAct, y - padAct,
                         x + width + padAct, y + height + padAct, 5, actArgb);
     }
   else if(isHovered)
     {
      //--- Hover highlight
      const uint hovArgb = ColorToARGB(theme.flyoutTextColor, 35);
      const int padHov = 3;
      FillNoteRoundRect(canvas, x - padHov, y - padHov,
                         x + width + padHov, y + height + padHov, 5, hovArgb);
     }
   //--- Clamp activeWidth into 1..4 and activeStyle into 0..3
   if(activeWidth < 1) activeWidth = 1;
   if(activeWidth > 4) activeWidth = 4;
   if(activeStyle < 0) activeStyle = 0;
   if(activeStyle > 3) activeStyle = 3;
   //--- Layout: stroke preview spans the icon width (minus padding) at the active style + width
   const int padX = 4;
   const int sL = x + padX;
   const int sR = x + width - padX;
   const int sY = y + height / 2;
   const uint glyphArgb = ColorToARGB(theme.flyoutTextColor, 230);
   StrokeLinePreview(canvas, sL, sY, sR, sY, activeWidth, activeStyle, glyphArgb);
  }

//+------------------------------------------------------------------+
//| RenderRibbonSettingsIcon - hexagonal gear glyph with center dot  |
//+------------------------------------------------------------------+
void RenderRibbonSettingsIcon(CCanvas &canvas,
                               int x, int y, int size,
                               bool isHovered,
                               bool isActive,
                               const ThemeColorSet &theme)
  {
   //--- Active highlight
   if(isActive)
     {
      const uint actArgb = ColorToARGB(theme.flyoutTextColor, 75);
      const int padAct = 3;
      FillNoteRoundRect(canvas, x - padAct, y - padAct,
                          x + size + padAct, y + size + padAct, 5, actArgb);
     }
   else if(isHovered)
     {
      //--- Hover highlight
      const uint hovArgb = ColorToARGB(theme.flyoutTextColor, 35);
      const int padHov = 3;
      FillNoteRoundRect(canvas, x - padHov, y - padHov,
                          x + size + padHov, y + size + padHov, 5, hovArgb);
     }
   //--- Glyph area (inset by 2 px) + center point + bounding radius
   const int gL = x + 2;
   const int gR = x + size - 2;
   const int gT = y + 2;
   const int gB = y + size - 2;
   const int cx = (gL + gR) / 2;
   const int cy = (gT + gB) / 2;
   const int rW = (gR - gL) / 2 - 1;
   const int rH = (gB - gT) / 2 - 1;
   //--- Use the smaller of width/height radii so the hexagon stays inscribed
   const int r  = MathMin(rW, rH);
   //--- Compute the 6 hexagon vertices (one per 60-degree step starting at angle 0)
   int ivx[6], ivy[6];
   for(int i = 0; i < 6; i++)
     {
      const double ang = (double)i * M_PI / 3.0;
      ivx[i] = (int)MathRound(cx + r * MathCos(ang));
      ivy[i] = (int)MathRound(cy + r * MathSin(ang));
     }
   //--- Stroke the 6 hexagon edges with Wu AA lines
   const uint glyphArgb = ColorToARGB(theme.flyoutTextColor, 230);
   for(int i = 0; i < 6; i++)
     {
      const int j = (i + 1) % 6;
      WidgetWuLineAA(canvas, ivx[i], ivy[i], ivx[j], ivy[j], glyphArgb);
     }
   //--- Small center circle (built-in canvas Wu circle at radius 2.0)
   canvas.CircleWu(cx, cy, 2.0, glyphArgb);
  }

//+------------------------------------------------------------------+
//| RenderRibbonRemoveIcon - trash-bin glyph (lid + body + content)  |
//+------------------------------------------------------------------+
void RenderRibbonRemoveIcon(CCanvas &canvas,
                             int x, int y, int size,
                             bool isHovered,
                             bool isActive,
                             const ThemeColorSet &theme)
  {
   //--- Active highlight
   if(isActive)
     {
      const uint actArgb = ColorToARGB(theme.flyoutTextColor, 75);
      const int padAct = 3;
      FillNoteRoundRect(canvas, x - padAct, y - padAct,
                          x + size + padAct, y + size + padAct, 5, actArgb);
     }
   else if(isHovered)
     {
      //--- Hover highlight
      const uint hovArgb = ColorToARGB(theme.flyoutTextColor, 35);
      const int padHov = 3;
      FillNoteRoundRect(canvas, x - padHov, y - padHov,
                          x + size + padHov, y + size + padHov, 5, hovArgb);
     }
   //--- Glyph area (inset by 3 px) + width/height
   const int gL = x + 3;
   const int gR = x + size - 3;
   const int gT = y + 3;
   const int gB = y + size - 3;
   const int W  = gR - gL;
   const int H  = gB - gT;
   //--- Layout positions (lid + body + handle tab) as fractions of the glyph rect
   const int lidY        = gT + (int)MathRound(H * 0.22);
   const int handleHalfW = (int)MathRound(W * 0.15);
   const int handleTop   = gT + (int)MathRound(H * 0.05);
   const int bodyL       = gL + (int)MathRound(W * 0.10);
   const int bodyR       = gR - (int)MathRound(W * 0.10);
   const int bodyT       = lidY + 2;
   const int bodyB       = gB;
   const int gcx         = (gL + gR) / 2;
   const uint glyphArgb = ColorToARGB(theme.flyoutTextColor, 230);
   //--- Handle tab (top + 2 sides; sits on top of the lid)
   const int tabL = gcx - handleHalfW;
   const int tabR = gcx + handleHalfW;
   WidgetWuLineAA(canvas, tabL, handleTop, tabR, handleTop, glyphArgb);
   WidgetWuLineAA(canvas, tabL, handleTop, tabL, lidY, glyphArgb);
   WidgetWuLineAA(canvas, tabR, handleTop, tabR, lidY, glyphArgb);
   //--- Lid (single horizontal line spanning the full glyph width)
   WidgetWuLineAA(canvas, gL, lidY, gR, lidY, glyphArgb);
   //--- Body (left side + right side + bottom)
   WidgetWuLineAA(canvas, bodyL, bodyT, bodyL, bodyB, glyphArgb);
   WidgetWuLineAA(canvas, bodyR, bodyT, bodyR, bodyB, glyphArgb);
   WidgetWuLineAA(canvas, bodyL, bodyB, bodyR, bodyB, glyphArgb);
   //--- 3 content vertical bars (the slashed-content suggesting deleted items)
   const int contentT = bodyT + (int)MathRound(H * 0.10);
   const int contentB = bodyB - (int)MathRound(H * 0.10);
   const int bodyW    = bodyR - bodyL;
   const int c1x = bodyL + bodyW / 4;
   const int c2x = bodyL + bodyW / 2;
   const int c3x = bodyL + (bodyW * 3) / 4;
   WidgetWuLineAA(canvas, c1x, contentT, c1x, contentB, glyphArgb);
   WidgetWuLineAA(canvas, c2x, contentT, c2x, contentB, glyphArgb);
   WidgetWuLineAA(canvas, c3x, contentT, c3x, contentB, glyphArgb);
  }

#endif // TOOLS_PALETTE_PROPERTY_WIDGETS_MQH
//+------------------------------------------------------------------+