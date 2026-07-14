//+------------------------------------------------------------------+
//|                                      ToolsPalette_Primitives.mqh |
//|                                            Copyright 2026, Om J. |
//|                                               https://t.me/HZFXI |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Om J."
#property link "https://t.me/HZFXI"
#property version "1.00"
#property strict

//--- Guard against multiple inclusion of this header
#ifndef TOOLS_PALETTE_PRIMITIVES_MQH
#define TOOLS_PALETTE_PRIMITIVES_MQH

//--- Pull in the standard CCanvas API used by every primitive below
#include <Canvas/Canvas.mqh>

input int BorderWidth = 1; // Border Width (px)

input double BackgroundOpacity = 0.92; // Background Opacity (0.0 - 1.0)

//+------------------------------------------------------------------+
//| Convert (color, opacity-percent) into a packed ARGB uint         |
//+------------------------------------------------------------------+
uint ColorWithPercentOpacity(color c, int pct)
  {
   //--- Clamp the input percentage into the supported [0, 100] range
   if(pct < 0)   pct = 0;
   if(pct > 100) pct = 100;
   //--- Map the percentage to an 8-bit alpha value
   const uchar alpha = (uchar)((255 * pct) / 100);
   //--- Pack the alpha + RGB into a single ARGB uint via the platform helper
   return ColorToARGB(c, alpha);
  }

//+------------------------------------------------------------------+
//| Source-over alpha blend a single pixel onto the canvas at (x, y) |
//+------------------------------------------------------------------+
void WidgetBlendPixel(CCanvas &canvas, int x, int y, uint srcArgb)
  {
   //--- Reject out-of-canvas pixels to keep the function safe to call from any draw routine
   if(x < 0 || y < 0 || x >= canvas.Width() || y >= canvas.Height()) return;
   //--- Fully transparent source contributes nothing; skip the read-modify-write cycle
   const uchar sa = (uchar)((srcArgb >> 24) & 0xFF);
   if(sa == 0) return;
   //--- Fully opaque source can replace the destination outright
   if(sa == 255) { canvas.PixelSet(x, y, srcArgb); return; }
   //--- Standard "source-over" compositing for the partial-alpha case
   const uint dst = canvas.PixelGet(x, y);
   const uchar da = (uchar)((dst >> 24) & 0xFF);
   //--- Unpack source RGB channels for the blend math
   const int sr = (int)((srcArgb >> 16) & 0xFF);
   const int sg = (int)((srcArgb >>  8) & 0xFF);
   const int sb = (int)( srcArgb        & 0xFF);
   //--- Unpack destination RGB channels for the blend math
   const int dr = (int)((dst     >> 16) & 0xFF);
   const int dg = (int)((dst     >>  8) & 0xFF);
   const int db = (int)( dst            & 0xFF);
   //--- Composite alpha via the standard over formula
   const int oa = sa + (int)da * (255 - sa) / 255;
   if(oa <= 0) { canvas.PixelSet(x, y, 0); return; }
   //--- Cached (255 - sa) for the RGB compositing math
   const int oneMinusSA = 255 - sa;
   //--- Composite each RGB channel via premultiplied source-over
   const int r = (sr * sa + dr * (int)da * oneMinusSA / 255) / oa;
   const int g = (sg * sa + dg * (int)da * oneMinusSA / 255) / oa;
   const int b = (sb * sa + db * (int)da * oneMinusSA / 255) / oa;
   //--- Pack the composited ARGB result back and write to the canvas
   const uint outArgb = ((uint)oa << 24) | ((uint)(uchar)r << 16)
                      | ((uint)(uchar)g <<  8) | (uint)(uchar)b;
   canvas.PixelSet(x, y, outArgb);
  }

//+------------------------------------------------------------------+
//| Anti-aliased thick line via signed-distance + 4x4 supersampling  |
//+------------------------------------------------------------------+
void WidgetThickLineAA(CCanvas &canvas,
                        int x0, int y0, int x1, int y1,
                        int thickness, uint argb)
  {
   //--- Clamp the requested thickness into the supported [1, 4] px range
   if(thickness < 1) thickness = 1;
   if(thickness > 4) thickness = 4;

   //--- Fast path: axis-aligned horizontal stroke renders as a crisp rectangle (no AA fuzz)
   if(y0 == y1)
     {
      //--- Normalize the X-range and compute the thickness band's Y bounds
      const int xL = MathMin(x0, x1);
      const int xR = MathMax(x0, x1);
      const int yTop = y0 - thickness / 2;
      const int yBot = yTop + thickness - 1;
      //--- Walk every pixel in the rectangle and blend it onto the canvas
      for(int yy = yTop; yy <= yBot; yy++)
         for(int xx = xL; xx <= xR; xx++)
            WidgetBlendPixel(canvas, xx, yy, argb);
      return;
     }
   //--- Fast path: axis-aligned vertical stroke renders as a crisp rectangle (no AA fuzz)
   if(x0 == x1)
     {
      //--- Normalize the Y-range and compute the thickness band's X bounds
      const int yT = MathMin(y0, y1);
      const int yB = MathMax(y0, y1);
      const int xL = x0 - thickness / 2;
      const int xR = xL + thickness - 1;
      //--- Walk every pixel in the rectangle and blend it onto the canvas
      for(int xx = xL; xx <= xR; xx++)
         for(int yy = yT; yy <= yB; yy++)
            WidgetBlendPixel(canvas, xx, yy, argb);
      return;
     }

   //--- General diagonal path: signed-distance to the segment + subpixel coverage at the AA boundary
   const double halfT = (double)thickness / 2.0;
   //--- Pixel-center positions of the segment endpoints (a, b)
   const double ax = (double)x0 + 0.5;
   const double ay = (double)y0 + 0.5;
   const double bx = (double)x1 + 0.5;
   const double by = (double)y1 + 0.5;
   //--- Segment vector and squared length
   const double dx = bx - ax;
   const double dy = by - ay;
   const double lenSq = dx * dx + dy * dy;
   //--- Reject degenerate zero-length segments
   if(lenSq < 1e-9) return;
   //--- Padding around the bounding box for partial-coverage AA pixels
   const double pad = halfT + 1.0;
   //--- Axis-aligned bounding box of the segment thickness band (with AA padding)
   const int bbL = (int)MathFloor(MathMin(ax, bx) - pad);
   const int bbT = (int)MathFloor(MathMin(ay, by) - pad);
   const int bbR = (int)MathCeil (MathMax(ax, bx) + pad);
   const int bbB = (int)MathCeil (MathMax(ay, by) + pad);

   //--- Unpack source alpha and RGB for coverage-weighted blending
   const uchar bA = (uchar)((argb >> 24) & 0xFF);
   const uint  rgb = argb & 0x00FFFFFF;
   //--- 4x4 supersampling configuration (16 subpixels per output pixel)
   const int sub = 4;
   const double step = 1.0 / sub;
   const int subSq = sub * sub;

   //--- Walk every pixel in the bounding box and test it against the segment
   for(int py = bbT; py <= bbB; py++)
     {
      for(int px = bbL; px <= bbR; px++)
        {
         //--- Center of the pixel under test
         const double pcx = (double)px + 0.5;
         const double pcy = (double)py + 0.5;
         //--- Project the pixel center onto the segment; clamp t into [0, 1] for finite extent
         double t = ((pcx - ax) * dx + (pcy - ay) * dy) / lenSq;
         if(t < 0.0) t = 0.0;
         if(t > 1.0) t = 1.0;
         //--- Compute the projected foot and the perpendicular distance to the segment
         const double projX = ax + t * dx;
         const double projY = ay + t * dy;
         const double pdx = pcx - projX;
         const double pdy = pcy - projY;
         const double centerDist = MathSqrt(pdx * pdx + pdy * pdy);
         //--- Pixels too far from the segment contribute nothing
         if(centerDist > halfT + 1.0) continue;
         //--- Pixels well inside the thickness band are opaque (skip the supersampling pass)
         if(centerDist <= halfT - 1.0)
           {
            WidgetBlendPixel(canvas, px, py, argb);
            continue;
           }
         //--- Boundary pixels: supersample to estimate the inside-thickness coverage fraction
         int inside = 0;
         for(int sy = 0; sy < sub; sy++)
           {
            for(int sx = 0; sx < sub; sx++)
              {
               //--- Sub-pixel sample position
               const double sx_ = (double)px + (sx + 0.5) * step;
               const double sy_ = (double)py + (sy + 0.5) * step;
               //--- Project the sub-pixel onto the segment; clamp t into [0, 1]
               double st = ((sx_ - ax) * dx + (sy_ - ay) * dy) / lenSq;
               if(st < 0.0) st = 0.0;
               if(st > 1.0) st = 1.0;
               //--- Compute the projected foot and check whether this subsample is inside the thickness band
               const double spx = ax + st * dx;
               const double spy = ay + st * dy;
               const double sdx = sx_ - spx;
               const double sdy = sy_ - spy;
               if(sdx * sdx + sdy * sdy <= halfT * halfT) inside++;
              }
           }
         //--- Skip pixels with zero coverage
         if(inside == 0) continue;
         //--- Scale the source alpha by the coverage fraction and blend the result
         const uint covArgb = (((uint)(uchar)((int)bA * inside / subSq)) << 24) | rgb;
         WidgetBlendPixel(canvas, px, py, covArgb);
        }
     }
  }

//+------------------------------------------------------------------+
//| Build an on/off pixel-length pattern for the given line style    |
//+------------------------------------------------------------------+
int BuildLineStylePattern(int lineStyle, int lineWidth, int &outPattern[])
  {
   //--- Clamp line width into the [1, 4] px range used by all stroke primitives
   if(lineWidth < 1) lineWidth = 1;
   if(lineWidth > 4) lineWidth = 4;
   //--- Style 0 = solid (no pattern), 1 = dash, 2 = dot, 3 = dash-dot
   switch(lineStyle)
     {
      //--- DASH: fixed 6px on, 4px off (visually distinct dashes regardless of stroke width)
      case 1:
         ArrayResize(outPattern, 2);
         outPattern[0] = 6; outPattern[1] = 4;
         return 2;
      //--- DOT: equal on/off scaled by line width so dots stay roughly square
      case 2:
         ArrayResize(outPattern, 2);
         outPattern[0] = lineWidth * 2; outPattern[1] = lineWidth * 2;
         return 2;
      //--- DASH-DOT: 6px on + 3px off + dot (line-width long) + 3px off, repeated
      case 3:
         ArrayResize(outPattern, 4);
         outPattern[0] = 6; outPattern[1] = 3;
         outPattern[2] = lineWidth; outPattern[3] = 3;
         return 4;
      //--- Style 0 (solid) returns an empty pattern; caller skips the dashed render path
      default:
         ArrayResize(outPattern, 0);
         return 0;
     }
  }

//+------------------------------------------------------------------+
//| Walk a segment + emit "on" sub-segments at pattern lengths       |
//+------------------------------------------------------------------+
void WidgetDashedLineAA(CCanvas &canvas,
                         int x0, int y0, int x1, int y1,
                         int thickness, uint argb,
                         int &pattern[])
  {
   //--- Reject empty patterns and degenerate thickness values
   const int patLen = ArraySize(pattern);
   if(patLen < 2 || thickness < 1) return;
   //--- Pixel-center endpoints and segment vector
   const double ax = (double)x0 + 0.5;
   const double ay = (double)y0 + 0.5;
   const double bx = (double)x1 + 0.5;
   const double by = (double)y1 + 0.5;
   const double dx = bx - ax;
   const double dy = by - ay;
   //--- Reject zero-length segments
   const double totalLen = MathSqrt(dx * dx + dy * dy);
   if(totalLen < 1e-6) return;
   //--- Unit direction along the segment
   const double ux = dx / totalLen;
   const double uy = dy / totalLen;

   //--- Walk the segment pattern step by step, alternating on/off
   int    patIdx   = 0;
   double traveled = 0.0;
   while(traveled < totalLen)
     {
      //--- Cache the current segment length (cycling through the pattern array)
      double segLen = (double)pattern[patIdx % patLen];
      //--- Skip degenerate (zero-length) pattern entries
      if(segLen <= 0.0) { patIdx++; continue; }
      //--- Truncate the final segment so it doesn't run past the segment endpoint
      if(traveled + segLen > totalLen) segLen = totalLen - traveled;
      //--- Compute the start and end coordinates of this pattern segment
      const double sx = ax + ux * traveled;
      const double sy = ay + uy * traveled;
      const double ex = ax + ux * (traveled + segLen);
      const double ey = ay + uy * (traveled + segLen);
      //--- Even pattern indices are "on" segments; odd are "off" (gaps)
      if((patIdx % 2) == 0)
        {
         //--- Convert back to integer pixel coords and emit the AA thick-line sub-segment
         const int isx = (int)MathRound(sx - 0.5);
         const int isy = (int)MathRound(sy - 0.5);
         const int iex = (int)MathRound(ex - 0.5);
         const int iey = (int)MathRound(ey - 0.5);
         WidgetThickLineAA(canvas, isx, isy, iex, iey, thickness, argb);
        }
      //--- Advance the cursor along the segment and step to the next pattern slot
      traveled += segLen;
      patIdx++;
     }
  }

input bool StartDark = false; // Start In Dark Theme

//+------------------------------------------------------------------+
//| Theme color set - all colors used across the entire palette UI   |
//+------------------------------------------------------------------+
struct ThemeColorSet
  {
   color sidebarBackground;          // Sidebar background fill
   color sidebarBorder;              // Sidebar outer border stroke
   color buttonHoverBackground;      // Tool-button background on hover
   color buttonActiveBackground;     // Tool-button background when active
   color buttonIconColor;            // Tool-button icon (default state)
   color buttonIconActiveColor;      // Tool-button icon when active
   color flyoutBackground;           // Flyout panel background fill
   color flyoutBorder;               // Flyout panel outer border stroke
   color flyoutItemHoverBackground;  // Flyout item background on hover
   color flyoutTextColor;            // Flyout text (default state)
   color flyoutTextActiveColor;      // Flyout text when active
   color flyoutTitleColor;           // Flyout section-title text
   color gripDotsColor;              // Drag-handle dots (sidebar grip)
   color closeButtonHoverColor;      // Close-button background on hover
   color themeButtonHoverColor;      // Theme-toggle button on hover
   color separatorColor;             // Horizontal separator line color
   color accentBarColor;             // Accent bar (selected-tool marker)
   color scrollArrowColor;           // Scroll arrow (default state)
   color scrollArrowHoverColor;      // Scroll arrow on hover
  };

//+------------------------------------------------------------------+
//| CCanvasPrimitives owns low-level canvas pixel and shape routines |
//+------------------------------------------------------------------+
class CCanvasPrimitives
  {
protected:
   //--- Blend one pixel onto the canvas using source-over alpha compositing
   void              BlendPixelSet(CCanvas &canvas, int x, int y, uint sourceARGB);
   //--- Downsample a high-res canvas into a lower-res destination by averaging blocks
   void              DownsampleCanvas(CCanvas &dst, CCanvas &src, int factor);
   //--- Fill a single corner quadrant of a rounded rectangle at high resolution
   void              FillCornerQuadrantHR(CCanvas &canvas, int cx, int cy, int radius, uint argb, int signX, int signY);
   //--- Fill a fully rounded rectangle at high resolution
   void              FillRoundRectHR(CCanvas &canvas, int x, int y, int w, int h, int radius, uint argb);
   //--- Fill a rounded rectangle with per-corner rounding control at high resolution
   void              FillSelectiveRoundRectHR(CCanvas &canvas, int x, int y, int w, int h, int radius, uint argb,
                                              bool rTL, bool rTR, bool rBL, bool rBR);
   //--- Fill a triangle using scanline rasterization at high resolution
   void              FillTriangleHR(CCanvas &canvas, int x0, int y0, int x1, int y1, int x2, int y2, uint argb);
   //--- Fill a quadrilateral using scanline rasterization (used by border edges)
   void              FillQuadrilateralBorder(CCanvas &canvas, double &vx[], double &vy[], uint argb);
   //--- Draw a thick border edge as a rotated quad between two endpoints
   void              DrawBorderEdge(CCanvas &canvas, double x0, double y0, double x1, double y1, int thickness, uint argb);
   //--- Test whether an angle falls within a directional arc range (handles wrap-around)
   bool              IsAngleBetween(double angle, double startAngle, double endAngle);
   //--- Draw an anti-aliased corner arc segment with specified thickness and angle range
   void              DrawCornerArc(CCanvas &canvas, int cx, int cy, int radius, int thickness, uint argb, double startAngle, double endAngle);
   //--- Draw a rounded rectangle BORDER with per-corner rounding control at high resolution
   void              DrawSelectiveRoundRectBorderHR(CCanvas &canvas, int x, int y, int w, int h, int radius, uint argb, int thickness,
                                                    bool rTL, bool rTR, bool rBL, bool rBR);
   //--- Draw a 1-pixel anti-aliased line via Xiaolin Wu's algorithm
   void              DrawBresenhamLine(CCanvas &canvas, int x0, int y0, int x1, int y1, uint argb);
   //--- Draw a thick line between two points (1px uses Wu; thicker uses SSAA rotated-rect coverage)
   void              DrawThickLine(CCanvas &canvas, int x0, int y0, int x1, int y1, int thickness, uint argb);
   //--- Fill a circle with an anti-aliased edge
   void              FillCircleAA(CCanvas &canvas, int cx, int cy, int radius, uint argb);
   //--- Draw a circle border with anti-aliasing
   void              DrawCircleBorderAA(CCanvas &canvas, int cx, int cy, int radius, int thickness, uint argb);
  };

//+------------------------------------------------------------------+
//| Blend one source pixel onto the canvas via source-over compose   |
//+------------------------------------------------------------------+
void CCanvasPrimitives::BlendPixelSet(CCanvas &canvas, int x, int y, uint src)
  {
   //--- Reject out-of-canvas pixels
   if(x < 0 || x >= canvas.Width() || y < 0 || y >= canvas.Height()) return;
   //--- Sample the destination pixel for the blend math
   uint dst = canvas.PixelGet(x, y);
   //--- Normalize source ARGB channels to [0, 1] floats
   double sA = ((src >> 24) & 0xFF) / 255.0, sR = ((src >> 16) & 0xFF) / 255.0;
   double sG = ((src >>  8) & 0xFF) / 255.0, sB = ( src        & 0xFF) / 255.0;
   //--- Normalize destination ARGB channels to [0, 1] floats
   double dA = ((dst >> 24) & 0xFF) / 255.0, dR = ((dst >> 16) & 0xFF) / 255.0;
   double dG = ((dst >>  8) & 0xFF) / 255.0, dB = ( dst        & 0xFF) / 255.0;
   //--- Composite alpha via the standard over formula
   double oA = sA + dA * (1.0 - sA);
   if(oA == 0.0) { canvas.PixelSet(x, y, 0); return; }
   //--- Composite RGB channels via premultiplied source-over and pack the result back
   canvas.PixelSet(x, y,
      ((uint)(uchar)(oA * 255 + 0.5) << 24) |
      ((uint)(uchar)((sR * sA + dR * dA * (1.0 - sA)) / oA * 255 + 0.5) << 16) |
      ((uint)(uchar)((sG * sA + dG * dA * (1.0 - sA)) / oA * 255 + 0.5) <<  8) |
       (uint)(uchar)((sB * sA + dB * dA * (1.0 - sA)) / oA * 255 + 0.5));
  }

//+------------------------------------------------------------------+
//| Downsample a high-res canvas into the destination by averaging   |
//+------------------------------------------------------------------+
void CCanvasPrimitives::DownsampleCanvas(CCanvas &dst, CCanvas &src, int factor)
  {
   //--- Cache destination dimensions and the block-size squared (for the average)
   int dW = dst.Width(), dH = dst.Height(), ss2 = factor * factor;
   //--- Walk every destination pixel
   for(int py = 0; py < dH; py++)
      for(int px = 0; px < dW; px++)
        {
         //--- Accumulators for ARGB channel sums + a separate count for non-transparent pixels
         double sA = 0, sR = 0, sG = 0, sB = 0, wc = 0;
         //--- Walk the SS x SS block of source pixels that maps to this destination pixel
         for(int dy = 0; dy < factor; dy++)
            for(int dx = 0; dx < factor; dx++)
              {
               //--- Compute the source pixel coords and skip out-of-source samples
               int sx = px * factor + dx, sy = py * factor + dy;
               if(sx >= src.Width() || sy >= src.Height()) continue;
               //--- Always accumulate alpha; accumulate RGB only for non-transparent samples
               uint p = src.PixelGet(sx, sy); uchar a = (uchar)((p >> 24) & 0xFF);
               sA += a;
               if(a > 0) { sR += (p >> 16) & 0xFF; sG += (p >> 8) & 0xFF; sB += p & 0xFF; wc += 1.0; }
              }
         //--- Final alpha is the simple block average (transparent pixels included)
         uchar fa = (uchar)(sA / ss2);
         //--- Skip fully-transparent or fully-empty destination pixels
         if(fa == 0 || wc == 0) { dst.PixelSet(px, py, 0); continue; }
         //--- Pack the averaged ARGB back into the destination
         dst.PixelSet(px, py, ((uint)fa << 24) | ((uint)(uchar)(sR / wc) << 16) |
                               ((uint)(uchar)(sG / wc) << 8) | (uint)(uchar)(sB / wc));
        }
  }

//+------------------------------------------------------------------+
//| Fill one corner quadrant of a rounded rect at high resolution    |
//+------------------------------------------------------------------+
void CCanvasPrimitives::FillCornerQuadrantHR(CCanvas &canvas, int cx, int cy, int radius, uint argb, int signX, int signY)
  {
   //--- Radius as a double for the disc-equation tests
   double rd = (double)radius;
   //--- Unpack source alpha + RGB for coverage-weighted blending
   uchar  bA = (uchar)((argb >> 24) & 0xFF);
   uint   rgb = argb & 0x00FFFFFF;
   //--- 4x4 supersampling configuration (16 subpixels per output pixel)
   int sub = 4; double step = 1.0 / sub; int subSq = sub * sub;
   //--- Walk every pixel in the quadrant's bounding box (with padding for AA boundary)
   for(int dy = -(radius + 1); dy <= (radius + 1); dy++)
      for(int dx = -(radius + 1); dx <= (radius + 1); dx++)
        {
         //--- Only process pixels in the requested quadrant (signX/signY pick the corner)
         bool inQ = ((signX > 0) ? (dx >= 0) : (dx <= 0)) && ((signY > 0) ? (dy >= 0) : (dy <= 0));
         if(!inQ) continue;
         //--- Distance from the quadrant's center; skip pixels well outside the disc
         double dist = MathSqrt((double)(dx * dx + dy * dy));
         if(dist > rd + 1.0) continue;
         //--- Pixels well inside the disc are fully opaque (skip the supersampling pass)
         if(dist <= rd - 1.0) { canvas.PixelSet(cx + dx, cy + dy, argb); continue; }
         //--- Boundary pixels: supersample to estimate the inside-disc coverage fraction
         int inside = 0;
         for(int sy = 0; sy < sub; sy++)
            for(int sx = 0; sx < sub; sx++)
              {
               //--- Sub-pixel offset for the AA sample (centered on the subpixel)
               double sdx = (double)dx - 0.5 + (sx + 0.5) * step;
               double sdy = (double)dy - 0.5 + (sy + 0.5) * step;
               //--- Inside-disc test for this subsample
               if(sdx * sdx + sdy * sdy <= rd * rd) inside++;
              }
         //--- Skip zero-coverage pixels
         if(inside == 0) continue;
         //--- Scale source alpha by coverage fraction and blend the result
         BlendPixelSet(canvas, cx + dx, cy + dy, (((uint)(uchar)((int)bA * inside / subSq)) << 24) | rgb);
        }
  }

//+------------------------------------------------------------------+
//| Fill a fully rounded rectangle at high resolution                |
//+------------------------------------------------------------------+
void CCanvasPrimitives::FillRoundRectHR(CCanvas &canvas, int x, int y, int w, int h, int radius, uint argb)
  {
   //--- Clamp the corner radius so it can't exceed half the smaller side
   radius = MathMin(radius, MathMin(w / 2, h / 2));
   //--- Degenerate radius reduces to a plain filled rectangle
   if(radius <= 0) { canvas.FillRectangle(x, y, x + w - 1, y + h - 1, argb); return; }
   //--- Top + bottom band spanning the radius gap (full-width center strip)
   canvas.FillRectangle(x + radius, y, x + w - radius - 1, y + h - 1, argb);
   //--- Left vertical band between the two left corner arcs
   canvas.FillRectangle(x, y + radius, x + radius - 1, y + h - radius - 1, argb);
   //--- Right vertical band between the two right corner arcs
   canvas.FillRectangle(x + w - radius, y + radius, x + w - 1, y + h - radius - 1, argb);
   //--- Four corner quadrants completing the rounded rect
   FillCornerQuadrantHR(canvas, x + radius,     y + radius,     radius, argb, -1, -1);
   FillCornerQuadrantHR(canvas, x + w - radius, y + radius,     radius, argb,  1, -1);
   FillCornerQuadrantHR(canvas, x + radius,     y + h - radius, radius, argb, -1,  1);
   FillCornerQuadrantHR(canvas, x + w - radius, y + h - radius, radius, argb,  1,  1);
  }

//+------------------------------------------------------------------+
//| Fill a rounded rect with per-corner rounding control (HR)        |
//+------------------------------------------------------------------+
void CCanvasPrimitives::FillSelectiveRoundRectHR(CCanvas &canvas, int x, int y, int w, int h, int radius, uint argb,
                                                  bool rTL, bool rTR, bool rBL, bool rBR)
  {
   //--- Clamp the corner radius so it can't exceed half the smaller side
   radius = MathMin(radius, MathMin(w / 2, h / 2));
   //--- Degenerate radius reduces to a plain filled rectangle
   if(radius <= 0) { canvas.FillRectangle(x, y, x + w - 1, y + h - 1, argb); return; }
   //--- Center vertical band (full height between the left and right corner columns)
   canvas.FillRectangle(x + radius, y, x + w - radius - 1, y + h - 1, argb);
   //--- Left vertical band (skip rounded-corner radii based on per-corner flags)
   canvas.FillRectangle(x,          y + (rTL ? radius : 0), x + radius - 1,  y + h - 1 - (rBL ? radius : 0), argb);
   //--- Right vertical band (skip rounded-corner radii based on per-corner flags)
   canvas.FillRectangle(x + w - radius, y + (rTR ? radius : 0), x + w - 1,   y + h - 1 - (rBR ? radius : 0), argb);
   //--- Top-left corner: rounded quadrant or square fill depending on the flag
   if(rTL) FillCornerQuadrantHR(canvas, x + radius,     y + radius,     radius, argb, -1, -1);
   else     canvas.FillRectangle(x, y, x + radius - 1, y + radius - 1, argb);
   //--- Top-right corner: rounded quadrant or square fill depending on the flag
   if(rTR) FillCornerQuadrantHR(canvas, x + w - radius, y + radius,     radius, argb,  1, -1);
   else     canvas.FillRectangle(x + w - radius, y, x + w - 1, y + radius - 1, argb);
   //--- Bottom-left corner: rounded quadrant or square fill depending on the flag
   if(rBL) FillCornerQuadrantHR(canvas, x + radius,     y + h - radius, radius, argb, -1,  1);
   else     canvas.FillRectangle(x, y + h - radius, x + radius - 1, y + h - 1, argb);
   //--- Bottom-right corner: rounded quadrant or square fill depending on the flag
   if(rBR) FillCornerQuadrantHR(canvas, x + w - radius, y + h - radius, radius, argb,  1,  1);
   else     canvas.FillRectangle(x + w - radius, y + h - radius, x + w - 1, y + h - 1, argb);
  }

//+------------------------------------------------------------------+
//| Fill a triangle using scanline rasterization at high resolution  |
//+------------------------------------------------------------------+
void CCanvasPrimitives::FillTriangleHR(CCanvas &canvas, int x0, int y0, int x1, int y1, int x2, int y2, uint argb)
  {
   //--- Pack the 3 vertices into parallel arrays for the scanline loop
   double vx[3] = { (double)x0, (double)x1, (double)x2 };
   double vy[3] = { (double)y0, (double)y1, (double)y2 };
   //--- Find the Y range of the triangle for the scanline loop bounds
   double minY = vy[0], maxY = vy[0];
   for(int i = 1; i < 3; i++) { if(vy[i] < minY) minY = vy[i]; if(vy[i] > maxY) maxY = vy[i]; }
   //--- Walk every scanline in the triangle's Y range
   for(int scanY = (int)MathCeil(minY); scanY <= (int)MathFloor(maxY); scanY++)
     {
      //--- Center of the scanline + buffer for X intersection points
      double cy = (double)scanY + 0.5; double xi[6]; int nc = 0;
      //--- Walk every edge of the triangle and compute the X intersection at this scanline
      for(int i = 0; i < 3; i++)
        {
         //--- Edge endpoints (current vertex to next vertex, wrapped)
         int ni = (i + 1) % 3;
         double eMin = (vy[i] < vy[ni]) ? vy[i] : vy[ni], eMax = (vy[i] > vy[ni]) ? vy[i] : vy[ni];
         //--- Skip edges that don't straddle this scanline or are horizontal
         if(cy < eMin || cy > eMax || MathAbs(vy[ni] - vy[i]) < 1e-12) continue;
         //--- Linear interpolation parameter for the X intersection
         double t = (cy - vy[i]) / (vy[ni] - vy[i]);
         if(t < 0.0 || t > 1.0) continue;
         //--- Append the X intersection to the buffer
         xi[nc++] = vx[i] + t * (vx[ni] - vx[i]);
        }
      //--- Sort X intersections ascending (tiny bubble sort)
      for(int a = 0; a < nc - 1; a++)
         for(int b = a + 1; b < nc; b++)
            if(xi[a] > xi[b]) { double tmp = xi[a]; xi[a] = xi[b]; xi[b] = tmp; }
      //--- Fill spans between consecutive crossing pairs
      for(int p = 0; p + 1 < nc; p += 2)
         for(int fx = (int)MathCeil(xi[p]); fx <= (int)MathFloor(xi[p + 1]); fx++)
            canvas.PixelSet(fx, scanY, argb);
     }
  }

//+------------------------------------------------------------------+
//| Fill a quadrilateral using scanline rasterization                |
//+------------------------------------------------------------------+
void CCanvasPrimitives::FillQuadrilateralBorder(CCanvas &canvas, double &vx[], double &vy[], uint argb)
  {
   //--- Find the Y range of the quad for the scanline loop bounds
   double minY = vy[0], maxY = vy[0];
   for(int i = 1; i < 4; i++) { if(vy[i] < minY) minY = vy[i]; if(vy[i] > maxY) maxY = vy[i]; }
   //--- Walk every scanline in the quad's Y range
   for(int scanY = (int)MathCeil(minY); scanY <= (int)MathCeil(maxY) - 1; scanY++)
     {
      //--- Center of the scanline + buffer for X intersection points
      double cy = (double)scanY + 0.5; double xi[8]; int nc = 0;
      //--- Walk every edge of the quad and compute the X intersection at this scanline
      for(int i = 0; i < 4; i++)
        {
         //--- Edge endpoints (current vertex to next vertex, wrapped)
         int ni = (i + 1) % 4;
         double eMin = (vy[i] < vy[ni]) ? vy[i] : vy[ni], eMax = (vy[i] > vy[ni]) ? vy[i] : vy[ni];
         //--- Skip edges that don't straddle this scanline or are horizontal
         if(cy < eMin || cy > eMax || MathAbs(vy[ni] - vy[i]) < 1e-12) continue;
         //--- Linear interpolation parameter for the X intersection
         double t = (cy - vy[i]) / (vy[ni] - vy[i]);
         if(t < 0.0 || t > 1.0) continue;
         //--- Append the X intersection to the buffer
         xi[nc++] = vx[i] + t * (vx[ni] - vx[i]);
        }
      //--- Sort X intersections ascending (tiny bubble sort)
      for(int a = 0; a < nc - 1; a++)
         for(int b = a + 1; b < nc; b++)
            if(xi[a] > xi[b]) { double tmp = xi[a]; xi[a] = xi[b]; xi[b] = tmp; }
      //--- Fill spans between consecutive crossing pairs
      for(int p = 0; p + 1 < nc; p += 2)
         for(int fx = (int)MathCeil(xi[p]); fx <= (int)MathCeil(xi[p + 1]) - 1; fx++)
            canvas.PixelSet(fx, scanY, argb);
     }
  }

//+------------------------------------------------------------------+
//| Draw a thick border edge as a rotated quad between two points    |
//+------------------------------------------------------------------+
void CCanvasPrimitives::DrawBorderEdge(CCanvas &canvas, double x0, double y0, double x1, double y1, int thickness, uint argb)
  {
   //--- Edge vector and squared length; reject degenerate edges
   double dx = x1 - x0, dy = y1 - y0, len = MathSqrt(dx * dx + dy * dy);
   if(len < 1e-6) return;
   //--- Perpendicular unit vector (for thickness offset) and along-edge unit vector
   double px = -dy / len, py = dx / len, ex = dx / len, ey = dy / len;
   //--- Half-thickness and small along-edge extension (so corner joins don't show a notch)
   double ht = thickness / 2.0, ext = 0.23 * thickness;
   //--- Extended endpoints along the edge direction
   double sx = x0 - ex * ext, sy = y0 - ey * ext, ex2 = x1 + ex * ext, ey2 = y1 + ey * ext;
   //--- Compute the 4 corners of the rotated edge quad (perpendicular offsets at each endpoint)
   double tvx[4] = { sx - px*ht, sx + px*ht, ex2 + px*ht, ex2 - px*ht };
   double tvy[4] = { sy - py*ht, sy + py*ht, ey2 + py*ht, ey2 - py*ht };
   //--- Rasterize the rotated quad via scanline fill
   FillQuadrilateralBorder(canvas, tvx, tvy, argb);
  }

//+------------------------------------------------------------------+
//| Test whether an angle falls within a directional arc range       |
//+------------------------------------------------------------------+
bool CCanvasPrimitives::IsAngleBetween(double angle, double start, double end)
  {
   //--- Wrap all three angles into the [0, 2pi) range for safe comparison
   double tp = 2.0 * M_PI;
   angle = MathMod(angle + tp, tp); start = MathMod(start + tp, tp); end = MathMod(end + tp, tp);
   //--- Distance from start to angle (modulo 2pi) must be <= the arc's angular span
   return MathMod(angle - start + tp, tp) <= MathMod(end - start + tp, tp);
  }

//+------------------------------------------------------------------+
//| Draw an anti-aliased corner arc with specified thickness         |
//+------------------------------------------------------------------+
void CCanvasPrimitives::DrawCornerArc(CCanvas &canvas, int cx, int cy, int radius, int thickness, uint argb, double startAngle, double endAngle)
  {
   //--- Outer and inner radii of the arc band (inner clamped to 0 if thickness exceeds radius)
   double oR = (double)radius, iR = MathMax(0.0, (double)radius - thickness);
   //--- Unpack source alpha + RGB for coverage-weighted blending
   uchar  bA = (uchar)((argb >> 24) & 0xFF); uint rgb = argb & 0x00FFFFFF;
   //--- 4x4 supersampling configuration and bounding-box radius
   int sub = 4; double step = 1.0 / sub; int subSq = sub * sub, pr = (int)(oR + 2.0);
   //--- Walk every pixel in the arc's bounding box (with padding for AA boundary)
   for(int dy = -pr; dy <= pr; dy++)
      for(int dx = -pr; dx <= pr; dx++)
        {
         //--- Distance from the arc center; skip pixels outside the [iR, oR] band
         double dist = MathSqrt((double)(dx * dx + dy * dy));
         if(dist > oR + 1.0 || dist < iR - 1.0) continue;
         //--- Skip pixels whose angle is outside the requested arc range
         if(!IsAngleBetween(MathArctan2((double)dy, (double)dx), startAngle, endAngle)) continue;
         //--- Pixels well inside the band and angular range are fully opaque
         if(dist <= oR - 1.0 && dist >= iR + 1.0) { canvas.PixelSet(cx + dx, cy + dy, argb); continue; }
         //--- Boundary pixels: supersample to estimate inside-band coverage
         int inside = 0;
         for(int sy = 0; sy < sub; sy++)
            for(int sx = 0; sx < sub; sx++)
              {
               //--- Sub-pixel offset and its distance + angle relative to the arc center
               double sdx = (double)dx - 0.5 + (sx + 0.5) * step, sdy = (double)dy - 0.5 + (sy + 0.5) * step;
               double sd = MathSqrt(sdx * sdx + sdy * sdy);
               //--- Subsample inside the band AND within the arc's angular range
               if(sd >= iR && sd <= oR && IsAngleBetween(MathArctan2(sdy, sdx), startAngle, endAngle)) inside++;
              }
         //--- Skip zero-coverage pixels
         if(inside == 0) continue;
         //--- Full coverage = direct write; partial coverage = alpha-scaled blend
         if(inside >= subSq) canvas.PixelSet(cx + dx, cy + dy, argb);
         else BlendPixelSet(canvas, cx + dx, cy + dy, (((uint)(uchar)((int)bA * inside / subSq)) << 24) | rgb);
        }
  }

//+------------------------------------------------------------------+
//| Draw rounded-rect border with per-corner rounding control (HR)   |
//+------------------------------------------------------------------+
void CCanvasPrimitives::DrawSelectiveRoundRectBorderHR(CCanvas &canvas, int x, int y, int w, int h, int radius, uint argb, int thickness,
                                                        bool rTL, bool rTR, bool rBL, bool rBR)
  {
   //--- Honor the global border-width input as a hard "no border" toggle
   if(BorderWidth <= 0) return;
   //--- Clamp the corner radius so it can't exceed half the smaller side
   radius = MathMin(radius, MathMin(w / 2, h / 2));
   //--- Per-corner radii (0 when that corner is not rounded) + half-thickness inset
   int tlR = rTL ? radius : 0, trR = rTR ? radius : 0, blR = rBL ? radius : 0, brR = rBR ? radius : 0, h2 = thickness / 2;
   //--- Top edge: span between the two top corners
   DrawBorderEdge(canvas, x + tlR,     y + h2,     x + w - trR, y + h2,     thickness, argb);
   //--- Right edge: only when at least one right corner is rounded (otherwise the corner squares it)
   if(rTR || rBR) DrawBorderEdge(canvas, x + w - h2, y + trR, x + w - h2, y + h - brR, thickness, argb);
   //--- Bottom edge: span between the two bottom corners
   DrawBorderEdge(canvas, x + w - brR, y + h - h2, x + blR,     y + h - h2, thickness, argb);
   //--- Left edge: only when at least one left corner is rounded
   if(rTL || rBL) DrawBorderEdge(canvas, x + h2, y + h - blR, x + h2, y + tlR, thickness, argb);
   //--- The 4 corner arcs (one per rounded-corner flag)
   if(rTL) DrawCornerArc(canvas, x + radius,     y + radius,     radius, thickness, argb, M_PI,       M_PI * 1.5);
   if(rTR) DrawCornerArc(canvas, x + w - radius, y + radius,     radius, thickness, argb, M_PI * 1.5, M_PI * 2.0);
   if(rBL) DrawCornerArc(canvas, x + radius,     y + h - radius, radius, thickness, argb, M_PI * 0.5, M_PI);
   if(rBR) DrawCornerArc(canvas, x + w - radius, y + h - radius, radius, thickness, argb, 0.0,        M_PI * 0.5);
  }

//+------------------------------------------------------------------+
//| Draw a 1-pixel anti-aliased line via Xiaolin Wu's algorithm      |
//+------------------------------------------------------------------+
void CCanvasPrimitives::DrawBresenhamLine(CCanvas &canvas, int x0, int y0, int x1, int y1, uint argb)
  {
   //--- Unpack source alpha and cache canvas bounds for the WU_PLOT macro
   uchar bA = (uchar)((argb >> 24) & 0xFF);
   uint  rgb = argb & 0x00FFFFFF;
   int   cW  = canvas.Width(), cH = canvas.Height();

   //--- WU_PLOT: emit one coverage-weighted AA pixel onto the canvas (bounds-checked)
   #define WU_PLOT(px, py, brightness) \
   { \
      int _x = (px), _y = (py); \
      if(_x >= 0 && _x < cW && _y >= 0 && _y < cH) \
        { \
         uchar _a = (uchar)((double)bA * (brightness)); \
         if(_a > 0) BlendPixelSet(canvas, _x, _y, (((uint)_a) << 24) | rgb); \
        } \
   }

   //--- Steep-axis detection so we always step along the major-axis direction
   bool steep = MathAbs(y1 - y0) > MathAbs(x1 - x0);
   //--- Swap X<->Y when steep so the main loop always increments X by 1
   if(steep)   { int t=x0;x0=y0;y0=t; t=x1;x1=y1;y1=t; }
   //--- Ensure we walk from left to right along the major axis
   if(x0 > x1) { int t=x0;x0=x1;x1=t; t=y0;y0=y1;y1=t; }

   //--- Gradient (Y advance per X step) - 1.0 fallback for vertical lines
   double dx   = x1 - x0;
   double dy   = y1 - y0;
   double grad = (dx == 0.0) ? 1.0 : dy / dx;

   //--- Start endpoint: plot the two pixels straddling the line at the X-pixel boundary
   double xend  = MathRound((double)x0);
   double yend  = y0 + grad * (xend - x0);
   double xgap  = 1.0 - MathMod((double)x0 + 0.5, 1.0);
   int    xpxl1 = (int)xend;
   int    ypxl1 = (int)yend;
   double fpart = MathMod(yend, 1.0);
   double rfpart= 1.0 - fpart;
   if(steep) { WU_PLOT(ypxl1,   xpxl1, rfpart * xgap); WU_PLOT(ypxl1+1, xpxl1, fpart  * xgap); }
   else      { WU_PLOT(xpxl1, ypxl1,   rfpart * xgap); WU_PLOT(xpxl1, ypxl1+1, fpart  * xgap); }
   //--- Interpolated Y for the inner loop
   double intery = yend + grad;

   //--- End endpoint: plot the two pixels straddling the line at the final X-pixel boundary
   xend  = MathRound((double)x1);
   yend  = y1 + grad * (xend - x1);
   xgap  = MathMod((double)x1 + 0.5, 1.0);
   int xpxl2 = (int)xend;
   int ypxl2 = (int)yend;
   fpart  = MathMod(yend, 1.0);
   rfpart = 1.0 - fpart;
   if(steep) { WU_PLOT(ypxl2,   xpxl2, rfpart * xgap); WU_PLOT(ypxl2+1, xpxl2, fpart  * xgap); }
   else      { WU_PLOT(xpxl2, ypxl2,   rfpart * xgap); WU_PLOT(xpxl2, ypxl2+1, fpart  * xgap); }

   //--- Inner loop: walk every X column between the two endpoints (steep-axis branch)
   if(steep)
     {
      for(int x = xpxl1+1; x <= xpxl2-1; x++)
        {
         //--- Fractional and inverse-fractional parts of the current Y
         fpart  = MathMod(intery, 1.0);
         rfpart = 1.0 - fpart;
         //--- Plot the two pixels straddling the line at this X column (axes swapped)
         WU_PLOT((int)intery,   x, rfpart);
         WU_PLOT((int)intery+1, x, fpart);
         intery += grad;
        }
     }
   else
     {
      //--- Shallow-axis branch: same logic but axes not swapped
      for(int x = xpxl1+1; x <= xpxl2-1; x++)
        {
         fpart  = MathMod(intery, 1.0);
         rfpart = 1.0 - fpart;
         //--- Plot the two pixels straddling the line at this X column
         WU_PLOT(x, (int)intery,   rfpart);
         WU_PLOT(x, (int)intery+1, fpart);
         intery += grad;
        }
     }
   //--- Clean up the per-function plot macro
   #undef WU_PLOT
  }

//+------------------------------------------------------------------+
//| Draw a thick line - 1px uses Wu, thicker uses SSAA rotated rect  |
//+------------------------------------------------------------------+
void CCanvasPrimitives::DrawThickLine(CCanvas &canvas, int x0, int y0, int x1, int y1, int thickness, uint argb)
  {
   //--- Thin lines route to the 1-pixel Wu path for crisp single-pixel rendering
   if(thickness <= 1)
     {
      DrawBresenhamLine(canvas, x0, y0, x1, y1, argb);
      return;
     }

   //--- Segment vector and length; reject degenerate zero-length segments
   double dx = (double)(x1 - x0);
   double dy = (double)(y1 - y0);
   double len = MathSqrt(dx*dx + dy*dy);
   if(len < 1e-6)
     {
      //--- Zero-length thick line falls back to the Wu single-pixel path
      DrawBresenhamLine(canvas, x0, y0, x1, y1, argb);
      return;
     }
   //--- Unit-direction vector along the segment
   double ux = dx / len;
   double uy = dy / len;
   //--- Perpendicular unit vector (for thickness offset)
   double px = -uy;
   double py =  ux;

   //--- Half-thickness and even-width half-pixel shift (centers the band on the integer line)
   double halfT = thickness / 2.0;
   double halfPxShift = ((thickness & 1) == 0) ? 0.5 : 0.0;
   //--- Center offset to apply when the band sits between integer rows/columns
   double cx = -px * halfPxShift;
   double cy = -py * halfPxShift;

   //--- Compute the axis-aligned bounding box of the thickness band (with padding for AA)
   int minX = MathMin(x0, x1) - (int)MathCeil(halfT) - 1;
   int maxX = MathMax(x0, x1) + (int)MathCeil(halfT) + 1;
   int minY = MathMin(y0, y1) - (int)MathCeil(halfT) - 1;
   int maxY = MathMax(y0, y1) + (int)MathCeil(halfT) + 1;
   //--- Cache canvas bounds and clip the bounding box accordingly
   int cW = canvas.Width(), cH = canvas.Height();
   if(minX < 0) minX = 0;
   if(minY < 0) minY = 0;
   if(maxX >= cW) maxX = cW - 1;
   if(maxY >= cH) maxY = cH - 1;

   //--- Unpack source alpha + RGB for coverage-weighted blending
   uchar bA = (uchar)((argb >> 24) & 0xFF);
   uint  rgb = argb & 0x00FFFFFF;

   //--- 4x4 supersampling configuration (16 subpixels per output pixel)
   const int SS = 4;
   double subStep  = 1.0 / SS;
   double subStart = -0.5 + subStep * 0.5;
   int subCount = SS * SS;

   //--- Walk every pixel in the bounding box and test it against the rotated rectangle
   for(int sy = minY; sy <= maxY; sy++)
     {
      for(int sx = minX; sx <= maxX; sx++)
        {
         //--- Coverage counter for this pixel's supersamples
         int inside = 0;
         //--- Walk every SS x SS subpixel of the current output pixel
         for(int vy = 0; vy < SS; vy++)
           {
            for(int vx = 0; vx < SS; vx++)
              {
               //--- Sub-pixel position in canvas coords
               double subX = (double)sx + subStart + subStep * vx;
               double subY = (double)sy + subStart + subStep * vy;
               //--- Translate to the segment origin (with optional even-width center shift)
               double qx = subX - (double)x0 - cx;
               double qy = subY - (double)y0 - cy;
               //--- Decompose into "along" (segment direction) and "perp" (normal direction)
               double along = qx * ux + qy * uy;
               double perp  = qx * px + qy * py;
               //--- Subsample inside the rectangle iff along is in [0, len] AND perp in [-halfT, halfT]
               if(along >= 0.0 && along <= len &&
                  perp >= -halfT && perp <= halfT)
                  inside++;
              }
           }
         //--- Skip zero-coverage pixels
         if(inside == 0) continue;
         //--- Scale source alpha by coverage fraction; skip if the resulting alpha rounds to 0
         uchar cov = (uchar)((int)bA * inside / subCount);
         if(cov == 0) continue;
         //--- Blend the coverage-weighted pixel onto the canvas
         BlendPixelSet(canvas, sx, sy, (((uint)cov) << 24) | rgb);
        }
     }
  }

//+------------------------------------------------------------------+
//| Fill a circle with an anti-aliased edge                          |
//+------------------------------------------------------------------+
void CCanvasPrimitives::FillCircleAA(CCanvas &canvas, int cx, int cy, int radius, uint argb)
  {
   //--- Radius as a double for the disc-equation tests
   double rd = (double)radius;
   //--- Unpack source alpha + RGB for coverage-weighted blending
   uchar  bA = (uchar)((argb >> 24) & 0xFF);
   uint   rgb = argb & 0x00FFFFFF;
   //--- 4x4 supersampling configuration (16 subpixels per output pixel)
   int sub = 4; double step = 1.0 / sub; int subSq = sub * sub;
   //--- Walk every pixel in the disc's bounding box (with padding for AA boundary)
   for(int dy = -radius - 1; dy <= radius + 1; dy++)
      for(int dx = -radius - 1; dx <= radius + 1; dx++)
        {
         //--- Distance from disc center; skip pixels well outside the disc
         double dist = MathSqrt((double)(dx * dx + dy * dy));
         if(dist > rd + 1.0) continue;
         //--- Pixels well inside the disc are fully opaque (skip the supersampling pass)
         if(dist <= rd - 1.0) { canvas.PixelSet(cx + dx, cy + dy, argb); continue; }
         //--- Boundary pixels: supersample to estimate inside-disc coverage
         int inside = 0;
         for(int sy = 0; sy < sub; sy++)
            for(int sx = 0; sx < sub; sx++)
              {
               //--- Sub-pixel offset and inside-disc test
               double sdx = (double)dx - 0.5 + (sx + 0.5) * step;
               double sdy = (double)dy - 0.5 + (sy + 0.5) * step;
               if(sdx * sdx + sdy * sdy <= rd * rd) inside++;
              }
         //--- Skip zero-coverage pixels
         if(inside == 0) continue;
         //--- Scale source alpha by coverage fraction and blend the result
         BlendPixelSet(canvas, cx + dx, cy + dy, (((uint)(uchar)((int)bA * inside / subSq)) << 24) | rgb);
        }
  }

//+------------------------------------------------------------------+
//| Draw a circle border via DrawCornerArc with full 0..2pi sweep    |
//+------------------------------------------------------------------+
void CCanvasPrimitives::DrawCircleBorderAA(CCanvas &canvas, int cx, int cy, int radius, int thickness, uint argb)
  {
   //--- A full-circle border is just a corner arc spanning the entire 360 degrees
   DrawCornerArc(canvas, cx, cy, radius, thickness, argb, 0.0, M_PI * 2.0);
  }

//+------------------------------------------------------------------+
//| CThemeManager applies and toggles the dark/light color sets      |
//+------------------------------------------------------------------+
class CThemeManager : public CCanvasPrimitives
  {
protected:
   //--- Current theme flag (true = dark, false = light)
   bool          m_isDarkTheme;
   //--- Cached color set populated by ApplyTheme(); read by all downstream renderers
   ThemeColorSet m_themeColors;

protected:
   //--- Populate m_themeColors from the dark or light palette based on m_isDarkTheme
   void          ApplyTheme();
   //--- Flip the theme flag and immediately repopulate the color set
   void          ToggleTheme();
  };

//+------------------------------------------------------------------+
//| Populate m_themeColors with the dark or light palette values     |
//+------------------------------------------------------------------+
void CThemeManager::ApplyTheme()
  {
   //--- Dark theme: deep blue-gray backgrounds with bright accent on hover/active
   if(m_isDarkTheme)
     {
      m_themeColors.sidebarBackground         = C'30,34,45';
      m_themeColors.sidebarBorder             = C'200,210,225';
      m_themeColors.buttonHoverBackground     = C'30,100,200';
      m_themeColors.buttonActiveBackground    = C'41,98,255';
      m_themeColors.buttonIconColor           = C'220,225,235';
      m_themeColors.buttonIconActiveColor     = clrWhite;
      m_themeColors.flyoutBackground          = C'36,41,54';
      m_themeColors.flyoutBorder              = C'200,210,225';
      m_themeColors.flyoutItemHoverBackground = C'30,100,200';
      m_themeColors.flyoutTextColor           = C'200,210,225';
      m_themeColors.flyoutTextActiveColor     = clrWhite;
      m_themeColors.flyoutTitleColor          = C'90,105,130';
      m_themeColors.gripDotsColor             = C'90,100,120';
      m_themeColors.closeButtonHoverColor     = C'235,55,55';
      m_themeColors.themeButtonHoverColor     = C'255,200,50';
      m_themeColors.separatorColor            = C'44,50,64';
      m_themeColors.accentBarColor            = C'41,98,255';
      m_themeColors.scrollArrowColor          = C'120,130,150';
      m_themeColors.scrollArrowHoverColor     = clrWhite;
     }
   else
     {
      //--- Light theme: white backgrounds with deep blue accent on hover/active
      m_themeColors.sidebarBackground         = clrWhite;
      m_themeColors.sidebarBorder             = C'30,35,45';
      m_themeColors.buttonHoverBackground     = C'30,100,200';
      m_themeColors.buttonActiveBackground    = C'41,98,255';
      m_themeColors.buttonIconColor           = C'40,45,58';
      m_themeColors.buttonIconActiveColor     = clrWhite;
      m_themeColors.flyoutBackground          = clrWhite;
      m_themeColors.flyoutBorder              = C'30,35,45';
      m_themeColors.flyoutItemHoverBackground = C'30,100,200';
      m_themeColors.flyoutTextColor           = C'40,45,58';
      m_themeColors.flyoutTextActiveColor     = clrWhite;
      m_themeColors.flyoutTitleColor          = C'130,140,160';
      m_themeColors.gripDotsColor             = C'160,170,185';
      m_themeColors.closeButtonHoverColor     = C'210,35,35';
      m_themeColors.themeButtonHoverColor     = C'150,100,0';
      m_themeColors.separatorColor            = C'210,215,225';
      m_themeColors.accentBarColor            = C'41,98,255';
      m_themeColors.scrollArrowColor          = C'120,130,145';
      m_themeColors.scrollArrowHoverColor     = C'40,45,58';
     }
  }

//+------------------------------------------------------------------+
//| Toggle between dark and light theme and reapply colors           |
//+------------------------------------------------------------------+
void CThemeManager::ToggleTheme()
  {
   //--- Flip the theme flag and immediately rebuild the cached color set
   m_isDarkTheme = !m_isDarkTheme;
   ApplyTheme();
  }

//+------------------------------------------------------------------+
//| WidgetWuLineAA - 1-pixel anti-aliased line via Wu's algorithm    |
//+------------------------------------------------------------------+
void WidgetWuLineAA(CCanvas &canvas,
                     double x0, double y0, double x1, double y1,
                     uint argb)
  {
   //--- Cache the alpha channel and the RGB triplet; bail out for fully transparent lines
   const uchar bA = (uchar)((argb >> 24) & 0xFF);
   if(bA == 0) return;
   const uint  rgb = argb & 0x00FFFFFF;

   //--- Compute the line's extents and decide which axis is the major (longer) one
   double dxL = x1 - x0;
   double dyL = y1 - y0;
   const bool steep = MathAbs(dyL) > MathAbs(dxL);
   //--- Steep branch: step along Y axis, distribute coverage between adjacent X pixels
   if(steep)
     {
      //--- Ensure we always step from low-Y to high-Y by swapping endpoints if needed
      if(y0 > y1)
        {
         double tt;
         tt = x0; x0 = x1; x1 = tt;
         tt = y0; y0 = y1; y1 = tt;
        }
      //--- Gradient: how much X advances per unit Y step
      const double grad = (y1 == y0) ? 0.0 : (x1 - x0) / (y1 - y0);
      const int iy0 = (int)MathRound(y0);
      const int iy1 = (int)MathRound(y1);
      //--- Fractional X position seeded at the rounded start Y
      double xf = x0 + grad * (iy0 - y0);
      //--- Step row by row, distributing one pixel's worth of coverage across two adjacent X pixels
      for(int iy = iy0; iy <= iy1; iy++)
        {
         const int ix = (int)MathFloor(xf);
         const double frac = xf - ix;
         //--- Left pixel gets (1-frac) of the alpha; right pixel gets frac - coverages always sum to 1
         const uchar a0 = (uchar)((double)bA * (1.0 - frac));
         const uchar a1 = (uchar)((double)bA * frac);
         if(a0 > 0) WidgetBlendPixel(canvas, ix,     iy, ((uint)a0 << 24) | rgb);
         if(a1 > 0) WidgetBlendPixel(canvas, ix + 1, iy, ((uint)a1 << 24) | rgb);
         xf += grad;
        }
     }
   else
     {
      //--- Shallow branch: step along X axis, ensure low-X to high-X order by swapping endpoints if needed
      if(x0 > x1)
        {
         double tt;
         tt = x0; x0 = x1; x1 = tt;
         tt = y0; y0 = y1; y1 = tt;
        }
      //--- Gradient: how much Y advances per unit X step
      const double grad = (x1 == x0) ? 0.0 : (y1 - y0) / (x1 - x0);
      const int ix0 = (int)MathRound(x0);
      const int ix1 = (int)MathRound(x1);
      //--- Fractional Y position seeded at the rounded start X
      double yf = y0 + grad * (ix0 - x0);
      //--- Step column by column, distributing one pixel's worth of coverage across two adjacent Y pixels
      for(int ix = ix0; ix <= ix1; ix++)
        {
         const int iy = (int)MathFloor(yf);
         const double frac = yf - iy;
         //--- Top pixel gets (1-frac) of the alpha; bottom pixel gets frac
         const uchar a0 = (uchar)((double)bA * (1.0 - frac));
         const uchar a1 = (uchar)((double)bA * frac);
         if(a0 > 0) WidgetBlendPixel(canvas, ix, iy,     ((uint)a0 << 24) | rgb);
         if(a1 > 0) WidgetBlendPixel(canvas, ix, iy + 1, ((uint)a1 << 24) | rgb);
         yf += grad;
        }
     }
  }

#endif // TOOLS_PALETTE_PRIMITIVES_MQH
//+------------------------------------------------------------------+