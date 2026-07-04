//+------------------------------------------------------------------+
//|                                        ToolsPalette_Channels.mqh |
//|                                            Copyright 2026, Om J. |
//|                                               https://t.me/HZFXI |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Om J."
#property link "https://t.me/HZFXI"
#property version "1.00"
#property strict

//--- Guard against multiple inclusion of this header
#ifndef TOOLS_PALETTE_CHANNELS_MQH
#define TOOLS_PALETTE_CHANNELS_MQH

//--- Pull in the base line-tools layer that CChannelTools extends
#include "ToolsPalette_Lines.mqh"

//+------------------------------------------------------------------+
//| CChannelTools class declaration                                  |
//+------------------------------------------------------------------+
class CChannelTools : public CLineTools
  {
protected:

public:
   //--- Compute regression line endpoints for the bar range [t1, t2]
   bool   ComputeRegressionEndpoints(datetime t1, datetime t2,
                                     double &leftP, double &rightP);
   //--- Draw a parallel channel (2 trendlines plus optional mid-line and fill)
   void   DrawParallelChannelOn(CCanvas &canvas,
                                int x1, int y1, int x2, int y2, int x3, int y3,
                                color objColor, bool selected, bool hovered,
                                int lineWidth = 2,     int lineOpacity = 100,  int lineStyle = 0,
                                color midColor = clrNONE,  int midOpacity = 80, int midStyle = 1,
                                color fillColor = clrNONE, int fillOpacity = 30,
                                bool midVisible = true,
                                int midWidth = 2,      double midOffset = 0.5);
   //--- Draw a regression channel (center line plus upper/lower sigma bands)
   void   DrawRegressionChannelOn(CCanvas &canvas, long chartId,
                                  datetime t1, datetime t2,
                                  color objColor, bool selected, bool hovered,
                                  int lineWidth = 2,       int lineOpacity = 100,   int lineStyle = 0,
                                  color fillColor = clrNONE,  int fillOpacity = 30,
                                  color fillColor2 = clrNONE, int fillOpacity2 = 30,
                                  color textColor = clrNONE,  int textOpacity = 100,
                                  bool centerVisible = true,
                                  color centerColor = clrNONE, int centerOpacity = 100,
                                  int centerWidth = 2,     int centerStyle = 1,
                                  bool upperBandVisible = true, double upperBandSigma = 2.0,
                                  bool lowerBandVisible = true, double lowerBandSigma = 2.0,
                                  bool pearsonVisible = true);
   //--- Draw a standard deviation channel (center line plus single band fill)
   void   DrawStdDevChannelOn(CCanvas &canvas, long chartId,
                              datetime t1, datetime t2,
                              color objColor, bool selected, bool hovered,
                              int lineWidth = 2,      int lineOpacity = 100,  int lineStyle = 0,
                              color fillColor = clrNONE, int fillOpacity = 30,
                              bool centerVisible = true,
                              color centerColor = clrNONE, int centerOpacity = 100,
                              int centerWidth = 2,    int centerStyle = 1,
                              bool upperBandVisible = true, double upperBandSigma = 2.0,
                              bool lowerBandVisible = true, double lowerBandSigma = 2.0);
   //--- Hit-test the parallel channel body (2 trendlines plus center line)
   bool   HitTestParallelChannel(int mx, int my,
                                 int x1, int y1, int x2, int y2, int x3, int y3,
                                 int threshold);
   //--- Hit-test the regression channel body (recomputes regression to find line positions)
   bool   HitTestRegressionChannel(int mx, int my, long chartId,
                                   datetime t1, datetime t2, int threshold);
   //--- Hit-test the std deviation channel body (delegates to regression hit test)
   bool   HitTestStdDevChannel(int mx, int my, long chartId,
                               datetime t1, datetime t2, int threshold);
   //--- Draw Andrew's Pitchfork (median plus outer and inner parallels)
   void   DrawAndrewsPitchforkOn(CCanvas &canvas,
                                 int x1, int y1, int x2, int y2, int x3, int y3,
                                 color objColor, bool selected, bool hovered,
                                 bool medianVisible, color medianColor, int medianWidth, int medianStyle,
                                 bool outerVisible,  color outerColor,  int outerWidth,  int outerStyle,
                                 bool innerVisible,  color innerColor,  int innerWidth,  int innerStyle,
                                 int lineOpacity, int fillOpacity);
   //--- Hit-test Andrew's Pitchfork body (tests all 6 drawn lines)
   bool   HitTestAndrewsPitchfork(int mx, int my, int canvasW, int canvasH,
                                  int x1, int y1, int x2, int y2, int x3, int y3,
                                  int threshold);
   //--- Draw Schiff Pitchfork (origin sits at P1 X with midpoint Y)
   void   DrawSchiffPitchforkOn(CCanvas &canvas,
                                int x1, int y1, int x2, int y2, int x3, int y3,
                                color objColor, bool selected, bool hovered,
                                bool medianVisible, color medianColor, int medianWidth, int medianStyle,
                                bool outerVisible,  color outerColor,  int outerWidth,  int outerStyle,
                                bool innerVisible,  color innerColor,  int innerWidth,  int innerStyle,
                                int lineOpacity, int fillOpacity);
   //--- Hit-test Schiff Pitchfork body (6 lines plus P1-P2 swing segment)
   bool   HitTestSchiffPitchfork(int mx, int my, int canvasW, int canvasH,
                                 int x1, int y1, int x2, int y2, int x3, int y3,
                                 int threshold);
   //--- Draw Modified Schiff Pitchfork (origin sits at TRUE midpoint of P1-P2)
   void   DrawModSchiffPitchforkOn(CCanvas &canvas,
                                   int x1, int y1, int x2, int y2, int x3, int y3,
                                   color objColor, bool selected, bool hovered,
                                   bool medianVisible, color medianColor, int medianWidth, int medianStyle,
                                   bool outerVisible,  color outerColor,  int outerWidth,  int outerStyle,
                                   bool innerVisible,  color innerColor,  int innerWidth,  int innerStyle,
                                   int lineOpacity, int fillOpacity);
   //--- Hit-test Modified Schiff Pitchfork body (same 7 segments)
   bool   HitTestModSchiffPitchfork(int mx, int my, int canvasW, int canvasH,
                                    int x1, int y1, int x2, int y2, int x3, int y3,
                                    int threshold);
   //--- Draw a Gann Line: single ray from P1 through P2 extended to canvas edge
   void   DrawGannLineOn(CCanvas &canvas,
                         int x1, int y1, int x2, int y2,
                         color objColor, bool selected, bool hovered,
                         int lineOpacity, int lineWidth, int lineStyle);
   //--- Hit-test a Gann Line (distance from cursor to extended ray)
   bool   HitTestGannLine(int mx, int my, int canvasW, int canvasH,
                          int x1, int y1, int x2, int y2, int threshold);
   //--- Draw a Gann Fan: rays from P1 at user-supplied price/time ratios
   void   DrawGannFanOn(CCanvas &canvas,
                        int x1, int y1, int x2, int y2,
                        color objColor, bool selected, bool hovered,
                        const double &lvlRatio[],
                        const color  &lvlColor[],
                        const int    &lvlOpacity[],
                        const int    &lvlWidth[],
                        const int    &lvlStyle[],
                        const bool   &lvlVisible[],
                        int fillOpacity);
   //--- Hit-test a Gann Fan (returns true when cursor lies near any of the 9 rays)
   bool   HitTestGannFan(int mx, int my, int canvasW, int canvasH,
                         int x1, int y1, int x2, int y2, int threshold);
   //--- Draw a Gann Box: Fibonacci grid on both price and time axes
   void   DrawGannBoxOn(CCanvas &canvas,
                        int x1, int y1, int x2, int y2,
                        color objColor, bool selected, bool hovered,
                        const double &lvlRatio[],
                        const color  &lvlColor[],
                        const int    &lvlOpacity[],
                        const int    &lvlWidth[],
                        const int    &lvlStyle[],
                        const bool   &lvlVisible[],
                        int fillOpacity);
   //--- Hit-test a Gann Box (cursor near any outer edge or interior Fib line)
   bool   HitTestGannBox(int mx, int my,
                         int x1, int y1, int x2, int y2, int threshold);
  };

//+------------------------------------------------------------------+
//| Blend a single pixel onto the canvas with alpha compositing      |
//+------------------------------------------------------------------+
#ifndef CHANNEL_BLEND_PIXEL_SET_DEFINED
#define CHANNEL_BLEND_PIXEL_SET_DEFINED
void ChannelBlendPixelSet(CCanvas &canvas, int px, int py, uint srcArgb)
  {
   //--- Cache canvas dimensions for the bounds check
   int cW = canvas.Width(), cH = canvas.Height();
   //--- Reject out-of-bounds pixels immediately
   if(px < 0 || px >= cW || py < 0 || py >= cH) return;
   //--- Extract the source alpha from the top byte
   uchar sA = (uchar)((srcArgb >> 24) & 0xFF);
   //--- Skip fully transparent source pixels
   if(sA == 0) return;
   //--- Fully opaque source: write directly without compositing math
   if(sA == 255) { canvas.PixelSet(px, py, srcArgb); return; }
   //--- Read the existing destination pixel for blending
   uint dst = canvas.PixelGet(px, py);
   uchar dA = (uchar)((dst >> 24) & 0xFF);
   //--- Normalize alpha values into the [0, 1] range
   double a  = sA / 255.0;
   double da = dA / 255.0;
   //--- Compute the combined output alpha via Porter-Duff source-over
   double oa = a + da * (1.0 - a);
   if(oa <= 0.0) return;
   //--- Normalize source RGB channels
   double sR = ((srcArgb >> 16) & 0xFF) / 255.0;
   double sG = ((srcArgb >>  8) & 0xFF) / 255.0;
   double sB = ( srcArgb        & 0xFF) / 255.0;
   //--- Normalize destination RGB channels
   double dR = ((dst >> 16) & 0xFF) / 255.0;
   double dG = ((dst >>  8) & 0xFF) / 255.0;
   double dB = ( dst        & 0xFF) / 255.0;
   //--- Assemble the composited ARGB output pixel and write it back
   uint outPix = ((uint)(uchar)(oa * 255.0 + 0.5) << 24) |
                 ((uint)(uchar)((sR*a + dR*da*(1.0-a)) / oa * 255.0 + 0.5) << 16) |
                 ((uint)(uchar)((sG*a + dG*da*(1.0-a)) / oa * 255.0 + 0.5) <<  8) |
                  (uint)(uchar)((sB*a + dB*da*(1.0-a)) / oa * 255.0 + 0.5);
   canvas.PixelSet(px, py, outPix);
  }
#endif

//+------------------------------------------------------------------+
//| Scanline fill a 4-vertex quad with flat alpha-composited color   |
//+------------------------------------------------------------------+
#ifndef CHANNEL_FILL_QUAD_DEFINED
#define CHANNEL_FILL_QUAD_DEFINED
void ChannelFillQuad(CCanvas &canvas,
                     int x0, int y0, int x1, int y1,
                     int x2, int y2, int x3, int y3,
                     uint fillArgb)
  {
   //--- Pack the four vertices into parallel arrays for scanline traversal
   int pxs[4]; int pys[4];
   pxs[0] = x0; pys[0] = y0;
   pxs[1] = x1; pys[1] = y1;
   pxs[2] = x2; pys[2] = y2;
   pxs[3] = x3; pys[3] = y3;
   //--- Find the vertical extents of the quad
   int ymin = pys[0], ymax = pys[0];
   for(int k = 1; k < 4; k++) { if(pys[k] < ymin) ymin = pys[k]; if(pys[k] > ymax) ymax = pys[k]; }
   //--- Clamp the vertical range to canvas bounds
   int cW = canvas.Width(), cH = canvas.Height();
   if(ymin < 0)   ymin = 0;
   if(ymax >= cH) ymax = cH - 1;
   //--- Scanline rasterization: one horizontal span per row
   for(int yy = ymin; yy <= ymax; yy++)
     {
      //--- Collect intersection X values where this scanline crosses quad edges
      double xs[4]; int nx = 0;
      for(int e = 0; e < 4; e++)
        {
         //--- Identify the edge endpoints with wrap-around closure
         int e2 = (e + 1) & 3;
         double ay = (double)pys[e], by = (double)pys[e2];
         //--- Skip edges that don't cross this scanline row
         if((ay > yy) == (by > yy)) continue;
         //--- Interpolate the intersection X at this row
         double ax = (double)pxs[e], bx = (double)pxs[e2];
         double t  = ((double)yy - ay) / (by - ay);
         xs[nx++] = ax + t * (bx - ax);
        }
      //--- Need at least two intersections to span a row
      if(nx < 2) continue;
      //--- Sort intersection X values ascending for paired span fill
      for(int a = 0; a < nx - 1; a++)
         for(int b = a + 1; b < nx; b++)
            if(xs[b] < xs[a]) { double tmp = xs[a]; xs[a] = xs[b]; xs[b] = tmp; }
      //--- Fill each horizontal span between paired intersections
      for(int p = 0; p + 1 < nx; p += 2)
        {
         //--- Snap span endpoints to integer columns
         int xL = (int)MathCeil(xs[p]);
         int xR = (int)MathFloor(xs[p + 1]);
         //--- Clamp the span to canvas horizontal bounds
         if(xL < 0) xL = 0;
         if(xR >= cW) xR = cW - 1;
         //--- Paint each pixel in the span via the alpha-composited setter
         for(int xx = xL; xx <= xR; xx++)
            ChannelBlendPixelSet(canvas, xx, yy, fillArgb);
        }
     }
  }
#endif

//+------------------------------------------------------------------+
//| Draw a 1px dashed line (4-on 4-off) between two canvas points    |
//+------------------------------------------------------------------+
void ChannelDrawDashedLine(CCanvas &canvas, int x1, int y1, int x2, int y2, uint argb)
  {
   //--- Compute the direction vector and total pixel length of the segment
   double dxl = x2 - x1, dyl = y2 - y1;
   double ll  = MathSqrt(dxl * dxl + dyl * dyl);
   //--- Skip degenerate zero-length segments
   if(ll <= 1.0) return;
   int steps = (int)ll;
   int cW = canvas.Width(), cH = canvas.Height();
   //--- Walk along the segment painting only the "on" dash pixels
   for(int s = 0; s < steps; s++)
     {
      //--- 4-on 4-off pattern: skip every second 4-pixel run
      if((s / 4) % 2 != 0) continue;
      //--- Interpolate the integer pixel coordinates along the segment
      int px = x1 + (int)(dxl * s / steps);
      int py = y1 + (int)(dyl * s / steps);
      //--- Paint only pixels that land inside the canvas
      if(px >= 0 && px < cW && py >= 0 && py < cH)
         ChannelBlendPixelSet(canvas, px, py, argb);
     }
  }

//+------------------------------------------------------------------+
//| Compute regression endpoints over bar closes in [t1, t2]         |
//+------------------------------------------------------------------+
bool CChannelTools::ComputeRegressionEndpoints(datetime t1, datetime t2,
                                               double &leftP, double &rightP)
  {
   //--- Identify the chronologically earlier and later datetimes
   datetime tL = (t1 < t2) ? t1 : t2;
   datetime tR = (t1 < t2) ? t2 : t1;
   //--- Map the datetimes to bar indices (nearest bar, no strict mode)
   int barR = iBarShift(_Symbol, _Period, tR, false);
   int barL = iBarShift(_Symbol, _Period, tL, false);
   //--- Ensure barL is the higher (older) bar index
   if(barL < barR) { int tmp = barL; barL = barR; barR = tmp; }
   int nBars = barL - barR + 1;
   //--- Reject ranges too small for a valid regression
   if(nBars < 2) return false;
   //--- Accumulate regression sums over all bars in the range
   double Sx = 0, Sy = 0, Sxx = 0, Sxy = 0;
   for(int i = 0; i < nBars; i++)
     {
      //--- Read the close price for the bar at this index offset
      int shift = barL - i;
      double cls = iClose(_Symbol, _Period, shift);
      //--- Skip bars with no valid close price
      if(cls == 0.0) continue;
      //--- Update the OLS sums with this sample point
      double x = (double)i;
      Sx += x; Sy += cls; Sxx += x*x; Sxy += x*cls;
     }
   double dn    = (double)nBars;
   double denom = dn*Sxx - Sx*Sx;
   //--- Reject the degenerate case where X-variance is effectively zero
   if(MathAbs(denom) < 1e-12) return false;
   //--- Compute the slope and intercept of the OLS regression line
   double slope     = (dn*Sxy - Sx*Sy) / denom;
   double intercept = (Sy - slope*Sx) / dn;
   //--- Evaluate the line at the leftmost and rightmost bar positions
   leftP  = intercept;
   rightP = slope * (double)(nBars - 1) + intercept;
   //--- Swap outputs if the caller passed t1 > t2 to preserve the stored order
   if(t1 > t2) { double tmp = leftP; leftP = rightP; rightP = tmp; }
   return true;
  }

//+------------------------------------------------------------------+
//| Draw a parallel channel onto the canvas                          |
//+------------------------------------------------------------------+
void CChannelTools::DrawParallelChannelOn(CCanvas &canvas,
      int x1, int y1, int x2, int y2, int x3, int y3,
      color objColor, bool selected, bool hovered,
      int lineWidth = 2,     int lineOpacity = 100,  int lineStyle = 0,
      color midColor = clrNONE,  int midOpacity = 80, int midStyle = 1,
      color fillColor = clrNONE, int fillOpacity = 30,
      bool midVisible = true,
      int midWidth = 2,      double midOffset = 0.5)
  {
   //--- Clamp the line width to the supported [1, 4] range
   if(lineWidth < 1) lineWidth = 1;
   if(lineWidth > 4) lineWidth = 4;
   //--- Clamp the midline width to the supported [1, 4] range
   if(midWidth  < 1) midWidth  = 1;
   if(midWidth  > 4) midWidth  = 4;
   //--- Clamp the line style to the supported [0, 3] range
   if(lineStyle < 0) lineStyle = 0;
   if(lineStyle > 3) lineStyle = 3;
   //--- Clamp the midline style to the supported [0, 3] range
   if(midStyle  < 0) midStyle  = 0;
   if(midStyle  > 3) midStyle  = 3;
   //--- Clamp the mid offset away from the degenerate 0 and 1 extremes
   if(midOffset < 0.05) midOffset = 0.05;
   if(midOffset > 0.95) midOffset = 0.95;
   //--- Resolve clrNONE to the object's base color for each sub-part
   color lineCol = objColor;
   color midCol  = (midColor  == clrNONE) ? objColor      : midColor;
   color fillCol = (fillColor == clrNONE) ? clrDodgerBlue : fillColor;
   //--- Build the ARGB values for each rendered part
   const uint lineArgb = ColorWithPercentOpacity(lineCol, lineOpacity);
   const uint fillArgb = ColorWithPercentOpacity(fillCol, fillOpacity);
   const uint midArgb  = ColorWithPercentOpacity(midCol,  midOpacity);
   const int  thick    = lineWidth;
   //--- Enforce the vertical-alignment invariant: C shares A's X, D shares B's X
   int cx3 = x1;
   int cy3 = y3;
   int x4  = x2;
   int y4  = y2 + (cy3 - y1);
   //--- Fill the parallelogram A-B-D-C with a translucent color
   ChannelFillQuad(canvas, x1, y1, x2, y2, x4, y4, cx3, cy3, fillArgb);
   //--- Draw the two solid (or styled) parallel trendlines
   if(lineStyle == 0)
     {
      //--- Solid-line path: render upper and lower trendlines flat
      DrawThickLine(canvas, x1,  y1,  x2, y2, thick, lineArgb);
      DrawThickLine(canvas, cx3, cy3, x4, y4, thick, lineArgb);
     }
   else
     {
      //--- Styled-line path: build the dash pattern and dispatch
      int pat[];
      const int n = BuildLineStylePattern(lineStyle, thick, pat);
      if(n > 0)
        {
         WidgetDashedLineAA(canvas, x1,  y1,  x2, y2, thick, lineArgb, pat);
         WidgetDashedLineAA(canvas, cx3, cy3, x4, y4, thick, lineArgb, pat);
        }
      else
        {
         //--- Fall back to solid lines if the pattern build fails
         DrawThickLine(canvas, x1,  y1,  x2, y2, thick, lineArgb);
         DrawThickLine(canvas, cx3, cy3, x4, y4, thick, lineArgb);
        }
     }
   //--- Draw the mid-line only when the visibility flag is set
   if(midVisible)
     {
      //--- Interpolate left and right mid-points using the midOffset blend
      int d1x = x1, d1y = (int)MathRound((double)y1 * (1.0 - midOffset) + (double)cy3 * midOffset);
      int d2x = x2, d2y = (int)MathRound((double)y2 * (1.0 - midOffset) + (double)y4  * midOffset);
      const int midThick = midWidth;
      if(midStyle == 0)
        {
         //--- Solid mid-line path
         DrawThickLine(canvas, d1x, d1y, d2x, d2y, midThick, midArgb);
        }
      else
        {
         //--- Styled mid-line path with fallback to solid on failure
         int mpat[];
         const int mn = BuildLineStylePattern(midStyle, midThick, mpat);
         if(mn > 0)
            WidgetDashedLineAA(canvas, d1x, d1y, d2x, d2y, midThick, midArgb, mpat);
         else
            DrawThickLine(canvas, d1x, d1y, d2x, d2y, midThick, midArgb);
        }
     }
   //--- Draw 6 handles at corners and midpoints of both trendlines
   if(selected || hovered)
     {
      //--- Compute trendline midpoints for the side handles
      int mABx = (x1 + x2) / 2,  mABy = (y1 + y2) / 2;
      int mCDx = (cx3 + x4) / 2, mCDy = (cy3 + y4) / 2;
      //--- Render each handle unless its index is currently being dragged
      if(m_hideHandleIdx != 0) DrawHandleOnCanvas(canvas, x1,   y1,   selected, lineCol, m_haloHandleIdx == 0);
      if(m_hideHandleIdx != 1) DrawHandleOnCanvas(canvas, x2,   y2,   selected, lineCol, m_haloHandleIdx == 1);
      if(m_hideHandleIdx != 2) DrawHandleOnCanvas(canvas, cx3,  cy3,  selected, lineCol, m_haloHandleIdx == 2);
      if(m_hideHandleIdx != 3) DrawHandleOnCanvas(canvas, x4,   y4,   selected, lineCol, m_haloHandleIdx == 3);
      if(m_hideHandleIdx != 4) DrawHandleOnCanvas(canvas, mABx, mABy, selected, lineCol, m_haloHandleIdx == 4);
      if(m_hideHandleIdx != 5) DrawHandleOnCanvas(canvas, mCDx, mCDy, selected, lineCol, m_haloHandleIdx == 5);
     }
  }

//+------------------------------------------------------------------+
//| Draw a regression channel onto the canvas                        |
//+------------------------------------------------------------------+
void CChannelTools::DrawRegressionChannelOn(CCanvas &canvas, long chartId,
      datetime t1, datetime t2,
      color objColor, bool selected, bool hovered,
      int lineWidth = 2,       int lineOpacity = 100,   int lineStyle = 0,
      color fillColor = clrNONE,  int fillOpacity = 30,
      color fillColor2 = clrNONE, int fillOpacity2 = 30,
      color textColor = clrNONE,  int textOpacity = 100,
      bool centerVisible = true,
      color centerColor = clrNONE, int centerOpacity = 100,
      int centerWidth = 2,     int centerStyle = 1,
      bool upperBandVisible = true, double upperBandSigma = 2.0,
      bool lowerBandVisible = true, double lowerBandSigma = 2.0,
      bool pearsonVisible = true)
  {
   //--- Clamp the line width to the supported [1, 4] range
   if(lineWidth < 1) lineWidth = 1;
   if(lineWidth > 4) lineWidth = 4;
   //--- Clamp the center-line width to the supported [1, 4] range
   if(centerWidth < 1) centerWidth = 1;
   if(centerWidth > 4) centerWidth = 4;
   //--- Clamp the band line style to the supported [0, 3] range
   if(lineStyle < 0) lineStyle = 0;
   if(lineStyle > 3) lineStyle = 3;
   //--- Clamp the center-line style to the supported [0, 3] range
   if(centerStyle < 0) centerStyle = 0;
   if(centerStyle > 3) centerStyle = 3;
   //--- Prevent sigma values from collapsing to zero
   if(upperBandSigma < 0.1) upperBandSigma = 0.1;
   if(lowerBandSigma < 0.1) lowerBandSigma = 0.1;
   //--- Resolve clrNONE to the appropriate default color for each sub-part
   color lineCol   = objColor;
   color centerCol = (centerColor == clrNONE) ? objColor      : centerColor;
   color fillUp    = (fillColor   == clrNONE) ? clrDodgerBlue : fillColor;
   color fillDn    = (fillColor2  == clrNONE) ? clrCrimson    : fillColor2;
   color labelCol  = (textColor   == clrNONE) ? objColor      : textColor;
   //--- Build ARGB values for the band boundary lines and band fills
   const uint lineArgb      = ColorWithPercentOpacity(lineCol, lineOpacity);
   const uint upperFillArgb = ColorWithPercentOpacity(fillUp,  fillOpacity);
   const uint lowerFillArgb = ColorWithPercentOpacity(fillDn,  fillOpacity2);
   const int  thick         = lineWidth;
   //--- Determine the chronologically left and right datetimes
   datetime tL = (t1 < t2) ? t1 : t2;
   datetime tR = (t1 < t2) ? t2 : t1;
   //--- Map the datetimes to bar indices
   int barR = iBarShift(_Symbol, _Period, tR, false);
   int barL = iBarShift(_Symbol, _Period, tL, false);
   //--- Ensure barL is the older (higher-index) bar
   if(barL < barR) { int tmp = barL; barL = barR; barR = tmp; }
   int nBars = barL - barR + 1;
   //--- Need at least 2 bars for a valid regression
   if(nBars < 2) return;
   //--- Accumulate OLS sums including Syy for the Pearson R calculation
   double Sx = 0, Sy = 0, Sxx = 0, Syy = 0, Sxy = 0;
   for(int i = 0; i < nBars; i++)
     {
      //--- Read the close price for the bar at this index offset
      int shift = barL - i;
      double cls = iClose(_Symbol, _Period, shift);
      //--- Skip bars with an invalid close price
      if(cls == 0.0) continue;
      //--- Update the OLS sums with this sample point
      double x = (double)i;
      Sx += x; Sy += cls; Sxx += x*x; Syy += cls*cls; Sxy += x*cls;
     }
   double dn    = (double)nBars;
   double denom = dn * Sxx - Sx * Sx;
   //--- Reject the degenerate X-variance case
   if(MathAbs(denom) < 1e-12) return;
   //--- Compute the OLS slope and intercept
   double slope     = (dn * Sxy - Sx * Sy) / denom;
   double intercept = (Sy - slope * Sx) / dn;
   //--- Compute the Y-variance denominator needed for Pearson R
   double denomY   = dn * Syy - Sy * Sy;
   double pearsonR = 0.0;
   //--- Compute Pearson R only when both denominators are well-defined
   if(denomY > 1e-12 && denom > 1e-12)
      pearsonR = (dn * Sxy - Sx * Sy) / MathSqrt(denom * denomY);
   //--- Accumulate sum of squared residuals for the sigma estimate
   double sumSq = 0.0;
   for(int i = 0; i < nBars; i++)
     {
      //--- Read this bar's close price again for the residual pass
      int shift = barL - i;
      double cls = iClose(_Symbol, _Period, shift);
      //--- Skip invalid bars in the residual pass
      if(cls == 0.0) continue;
      //--- Compute the predicted price and accumulate the squared residual
      double pred = slope * (double)i + intercept;
      double r    = cls - pred;
      sumSq += r * r;
     }
   //--- Compute the residual standard deviation
   double sigma = MathSqrt(sumSq / dn);
   //--- Convert bar indices back to chart datetimes for coordinate mapping
   datetime leftTime  = (datetime)iTime(_Symbol, _Period, barL);
   datetime rightTime = (datetime)iTime(_Symbol, _Period, barR);
   //--- Compute the center, upper, and lower band prices at both ends
   double leftCP  = intercept;
   double rightCP = slope * (double)(nBars - 1) + intercept;
   double leftUP  = leftCP  + upperBandSigma * sigma;
   double rightUP = rightCP + upperBandSigma * sigma;
   double leftLP  = leftCP  - lowerBandSigma * sigma;
   double rightLP = rightCP - lowerBandSigma * sigma;
   //--- Map all price/time coordinates to canvas pixel positions
   int xL_p=0, yLc=0, xR_p=0, yRc=0, xtmp=0;
   int yLu=0, yRu=0, yLl=0, yRl=0;
   ChartTimePriceToXY(chartId, 0, leftTime,  leftCP,  xL_p, yLc);
   ChartTimePriceToXY(chartId, 0, rightTime, rightCP, xR_p, yRc);
   ChartTimePriceToXY(chartId, 0, leftTime,  leftUP,  xtmp, yLu);
   ChartTimePriceToXY(chartId, 0, rightTime, rightUP, xtmp, yRu);
   ChartTimePriceToXY(chartId, 0, leftTime,  leftLP,  xtmp, yLl);
   ChartTimePriceToXY(chartId, 0, rightTime, rightLP, xtmp, yRl);
   //--- Fill the upper band region between the center and the upper boundary
   if(upperBandVisible)
      ChannelFillQuad(canvas, xL_p, yLu, xR_p, yRu, xR_p, yRc, xL_p, yLc, upperFillArgb);
   //--- Fill the lower band region between the center and the lower boundary
   if(lowerBandVisible)
      ChannelFillQuad(canvas, xL_p, yLc, xR_p, yRc, xR_p, yRl, xL_p, yLl, lowerFillArgb);
   //--- Draw the upper and lower band boundary lines gated by visibility
   if(upperBandVisible || lowerBandVisible)
     {
      if(lineStyle == 0)
        {
         //--- Solid-line path: render each visible band boundary flat
         if(upperBandVisible) DrawThickLine(canvas, xL_p, yLu, xR_p, yRu, thick, lineArgb);
         if(lowerBandVisible) DrawThickLine(canvas, xL_p, yLl, xR_p, yRl, thick, lineArgb);
        }
      else
        {
         //--- Styled-line path: build the dash pattern and dispatch
         int pat[];
         const int n = BuildLineStylePattern(lineStyle, thick, pat);
         if(n > 0)
           {
            if(upperBandVisible) WidgetDashedLineAA(canvas, xL_p, yLu, xR_p, yRu, thick, lineArgb, pat);
            if(lowerBandVisible) WidgetDashedLineAA(canvas, xL_p, yLl, xR_p, yRl, thick, lineArgb, pat);
           }
         else
           {
            //--- Fall back to solid lines if the pattern build fails
            if(upperBandVisible) DrawThickLine(canvas, xL_p, yLu, xR_p, yRu, thick, lineArgb);
            if(lowerBandVisible) DrawThickLine(canvas, xL_p, yLl, xR_p, yRl, thick, lineArgb);
           }
        }
     }
   //--- Draw the center regression line with its own style, width, and color
   if(centerVisible)
     {
      //--- Compose the center-line ARGB at its own opacity
      const uint centerArgb = ColorWithPercentOpacity(centerCol, centerOpacity);
      if(centerStyle == 0)
        {
         //--- Solid center-line path
         DrawThickLine(canvas, xL_p, yLc, xR_p, yRc, centerWidth, centerArgb);
        }
      else
        {
         //--- Styled center-line path with fallback to solid on failure
         int cpat[];
         const int cn = BuildLineStylePattern(centerStyle, centerWidth, cpat);
         if(cn > 0)
            WidgetDashedLineAA(canvas, xL_p, yLc, xR_p, yRc, centerWidth, centerArgb, cpat);
         else
            DrawThickLine(canvas, xL_p, yLc, xR_p, yRc, centerWidth, centerArgb);
        }
     }
   //--- Render the Pearson R label only when visibility is enabled
   if(pearsonVisible)
     {
      //--- Configure the label font and format the Pearson R value
      int fontPxSize = 9;
      string fontName = "Arial";
      string rText = DoubleToString(pearsonR, 17);
      TextSetFont(fontName, -(fontPxSize * 10));
      //--- Measure the label bounding box
      uint twU = 0, thU = 0;
      TextGetSize(rText, twU, thU);
      int tw = (int)twU, th = (int)thU;
      if(tw > 0 && th > 0)
        {
         //--- Compose the label ARGB at its own opacity
         uint textArgb = ColorWithPercentOpacity(labelCol, textOpacity);
         //--- First pass: render on black background to extract ink coverage
         uint bufB[]; ArrayResize(bufB, tw * th);
         ArrayFill(bufB, 0, tw * th, 0xFF000000);
         TextOut(rText, 0, 0, TA_LEFT | TA_TOP, bufB, tw, th,
                 textArgb, COLOR_FORMAT_ARGB_NORMALIZE);
         //--- Second pass: render on white background to extract ink coverage
         uint bufW[]; ArrayResize(bufW, tw * th);
         ArrayFill(bufW, 0, tw * th, 0xFFFFFFFF);
         TextOut(rText, 0, 0, TA_LEFT | TA_TOP, bufW, tw, th,
                 textArgb, COLOR_FORMAT_ARGB_NORMALIZE);
         //--- Position the label below the lower band's left endpoint
         int txtX = xL_p - tw / 2;
         int txtY = yLl + 4;
         int cW_t = canvas.Width();
         int cH_t = canvas.Height();
         //--- Clamp the label to stay inside the canvas bounds
         if(txtX < 0)          txtX = 0;
         if(txtX + tw >= cW_t) txtX = cW_t - tw - 1;
         if(txtY + th >= cH_t) txtY = cH_t - th - 1;
         //--- Extract the source RGB from the label color
         uchar srcR = (uchar)((labelCol)       & 0xFF);
         uchar srcG = (uchar)((labelCol >> 8)  & 0xFF);
         uchar srcB = (uchar)((labelCol >> 16) & 0xFF);
         //--- Composite each glyph pixel onto the canvas using alpha from ink coverage
         for(int py = 0; py < th; py++)
           {
            for(int px = 0; px < tw; px++)
              {
               //--- Derive per-pixel alpha from the black/white render difference
               int i = py * tw + px;
               int dR = (int)((bufW[i] >> 16) & 0xFF) - (int)((bufB[i] >> 16) & 0xFF);
               int dG = (int)((bufW[i] >>  8) & 0xFF) - (int)((bufB[i] >>  8) & 0xFF);
               int dB = (int)( bufW[i]        & 0xFF) - (int)( bufB[i]        & 0xFF);
               int a  = 255 - (dR + dG + dB) / 3;
               //--- Skip transparent pixels
               if(a <= 0) continue;
               if(a > 255) a = 255;
               //--- Compute the canvas target coordinate with bounds checking
               int dstX = txtX + px, dstY = txtY + py;
               if(dstX < 0 || dstX >= cW_t || dstY < 0 || dstY >= cH_t) continue;
               //--- Blend the label pixel over the existing canvas pixel
               uint existing = canvas.PixelGet(dstX, dstY);
               double sA = (double)a / 255.0;
               double dA = ((existing >> 24) & 0xFF) / 255.0;
               double oA = sA + dA * (1.0 - sA);
               if(oA <= 0.0) continue;
               //--- Normalize source and destination channels for compositing
               double sR = srcR / 255.0, sG = srcG / 255.0, sB = srcB / 255.0;
               double dR_ = ((existing >> 16) & 0xFF) / 255.0;
               double dG_ = ((existing >>  8) & 0xFF) / 255.0;
               double dB_ = ( existing        & 0xFF) / 255.0;
               //--- Assemble the final ARGB output pixel and write it back
               uint outPix = ((uint)(uchar)(oA * 255.0 + 0.5) << 24) |
                             ((uint)(uchar)((sR*sA + dR_*dA*(1.0-sA)) / oA * 255.0 + 0.5) << 16) |
                             ((uint)(uchar)((sG*sA + dG_*dA*(1.0-sA)) / oA * 255.0 + 0.5) <<  8) |
                              (uint)(uchar)((sB*sA + dB_*dA*(1.0-sA)) / oA * 255.0 + 0.5);
               canvas.PixelSet(dstX, dstY, outPix);
              }
           }
        }
     }
   //--- Draw 2 handles at the center-line endpoints when selected or hovered
   if(selected || hovered)
     {
      if(m_hideHandleIdx != 0)
         DrawHandleOnCanvas(canvas, xL_p, yLc, selected, lineCol, m_haloHandleIdx == 0);
      if(m_hideHandleIdx != 1)
         DrawHandleOnCanvas(canvas, xR_p, yRc, selected, lineCol, m_haloHandleIdx == 1);
     }
  }

//+------------------------------------------------------------------+
//| Draw a std deviation channel onto the canvas                     |
//+------------------------------------------------------------------+
void CChannelTools::DrawStdDevChannelOn(CCanvas &canvas, long chartId,
      datetime t1, datetime t2,
      color objColor, bool selected, bool hovered,
      int lineWidth = 2,      int lineOpacity = 100,  int lineStyle = 0,
      color fillColor = clrNONE, int fillOpacity = 30,
      bool centerVisible = true,
      color centerColor = clrNONE, int centerOpacity = 100,
      int centerWidth = 2,    int centerStyle = 1,
      bool upperBandVisible = true, double upperBandSigma = 2.0,
      bool lowerBandVisible = true, double lowerBandSigma = 2.0)
  {
   //--- Clamp the line width to the supported [1, 4] range
   if(lineWidth < 1) lineWidth = 1;
   if(lineWidth > 4) lineWidth = 4;
   //--- Clamp the center-line width to the supported [1, 4] range
   if(centerWidth < 1) centerWidth = 1;
   if(centerWidth > 4) centerWidth = 4;
   //--- Clamp the band line style to the supported [0, 3] range
   if(lineStyle < 0) lineStyle = 0;
   if(lineStyle > 3) lineStyle = 3;
   //--- Clamp the center-line style to the supported [0, 3] range
   if(centerStyle < 0) centerStyle = 0;
   if(centerStyle > 3) centerStyle = 3;
   //--- Prevent sigma from collapsing to zero
   if(upperBandSigma < 0.1) upperBandSigma = 0.1;
   if(lowerBandSigma < 0.1) lowerBandSigma = 0.1;
   //--- Resolve clrNONE defaults for each sub-part
   color centerCol = (centerColor == clrNONE) ? objColor      : centerColor;
   color lineCol   = objColor;
   color fillCol   = (fillColor   == clrNONE) ? clrDodgerBlue : fillColor;
   //--- Build ARGB values for the boundary lines and the single band fill
   const uint lineArgb = ColorWithPercentOpacity(lineCol, lineOpacity);
   const uint fillArgb = ColorWithPercentOpacity(fillCol, fillOpacity);
   const int  thick    = lineWidth;
   //--- Identify the chronologically left and right datetimes
   datetime tL = (t1 < t2) ? t1 : t2;
   datetime tR = (t1 < t2) ? t2 : t1;
   //--- Map the datetimes to bar indices
   int barR = iBarShift(_Symbol, _Period, tR, false);
   int barL = iBarShift(_Symbol, _Period, tL, false);
   //--- Ensure barL holds the older (higher-index) bar
   if(barL < barR) { int tmp = barL; barL = barR; barR = tmp; }
   int nBars = barL - barR + 1;
   //--- Need at least 2 bars to form a regression line
   if(nBars < 2) return;
   //--- Accumulate OLS sums (no Syy here since Pearson R is not needed)
   double Sx = 0, Sy = 0, Sxx = 0, Sxy = 0;
   for(int i = 0; i < nBars; i++)
     {
      //--- Read the close price for the bar at this index offset
      int shift = barL - i;
      double cls = iClose(_Symbol, _Period, shift);
      //--- Skip bars with an invalid close price
      if(cls == 0.0) continue;
      //--- Update the OLS sums with this sample point
      double x = (double)i;
      Sx += x; Sy += cls; Sxx += x*x; Sxy += x*cls;
     }
   double dn    = (double)nBars;
   double denom = dn * Sxx - Sx * Sx;
   //--- Reject the degenerate X-variance case
   if(MathAbs(denom) < 1e-12) return;
   //--- Compute the OLS slope and intercept
   double slope     = (dn * Sxy - Sx * Sy) / denom;
   double intercept = (Sy - slope * Sx) / dn;
   //--- Accumulate sum of squared residuals for the sigma estimate
   double sumSq = 0.0;
   for(int i = 0; i < nBars; i++)
     {
      //--- Read this bar's close price again for the residual pass
      int shift = barL - i;
      double cls = iClose(_Symbol, _Period, shift);
      //--- Skip invalid bars in the residual pass
      if(cls == 0.0) continue;
      //--- Compute the predicted price and accumulate the squared residual
      double pred = slope * (double)i + intercept;
      double r    = cls - pred;
      sumSq += r * r;
     }
   //--- Compute the residual standard deviation
   double sigma = MathSqrt(sumSq / dn);
   //--- Recover bar datetimes for pixel mapping
   datetime leftTime  = (datetime)iTime(_Symbol, _Period, barL);
   datetime rightTime = (datetime)iTime(_Symbol, _Period, barR);
   //--- Compute the center, upper, and lower band prices at both ends
   double leftCP  = intercept;
   double rightCP = slope * (double)(nBars - 1) + intercept;
   double leftUP  = leftCP  + upperBandSigma * sigma;
   double rightUP = rightCP + upperBandSigma * sigma;
   double leftLP  = leftCP  - lowerBandSigma * sigma;
   double rightLP = rightCP - lowerBandSigma * sigma;
   //--- Map all price/time coordinates to canvas pixel positions
   int xL_p=0, yLc=0, xR_p=0, yRc=0, xtmp=0;
   int yLu=0, yRu=0, yLl=0, yRl=0;
   ChartTimePriceToXY(chartId, 0, leftTime,  leftCP,  xL_p, yLc);
   ChartTimePriceToXY(chartId, 0, rightTime, rightCP, xR_p, yRc);
   ChartTimePriceToXY(chartId, 0, leftTime,  leftUP,  xtmp, yLu);
   ChartTimePriceToXY(chartId, 0, rightTime, rightUP, xtmp, yRu);
   ChartTimePriceToXY(chartId, 0, leftTime,  leftLP,  xtmp, yLl);
   ChartTimePriceToXY(chartId, 0, rightTime, rightLP, xtmp, yRl);
   //--- Fill the single band quad only when both boundaries are visible
   if(upperBandVisible && lowerBandVisible)
      ChannelFillQuad(canvas, xL_p, yLu, xR_p, yRu, xR_p, yRl, xL_p, yLl, fillArgb);
   //--- Draw band boundary lines gated by per-band visibility
   if(upperBandVisible || lowerBandVisible)
     {
      if(lineStyle == 0)
        {
         //--- Solid-line path: render each visible band boundary flat
         if(upperBandVisible) DrawThickLine(canvas, xL_p, yLu, xR_p, yRu, thick, lineArgb);
         if(lowerBandVisible) DrawThickLine(canvas, xL_p, yLl, xR_p, yRl, thick, lineArgb);
        }
      else
        {
         //--- Styled-line path: build the dash pattern and dispatch
         int pat[];
         const int n = BuildLineStylePattern(lineStyle, thick, pat);
         if(n > 0)
           {
            if(upperBandVisible) WidgetDashedLineAA(canvas, xL_p, yLu, xR_p, yRu, thick, lineArgb, pat);
            if(lowerBandVisible) WidgetDashedLineAA(canvas, xL_p, yLl, xR_p, yRl, thick, lineArgb, pat);
           }
         else
           {
            //--- Fall back to solid lines if the pattern build fails
            if(upperBandVisible) DrawThickLine(canvas, xL_p, yLu, xR_p, yRu, thick, lineArgb);
            if(lowerBandVisible) DrawThickLine(canvas, xL_p, yLl, xR_p, yRl, thick, lineArgb);
           }
        }
     }
   //--- Draw the center regression line with its own style, width, and color
   if(centerVisible)
     {
      //--- Compose the center-line ARGB at its own opacity
      const uint centerArgb = ColorWithPercentOpacity(centerCol, centerOpacity);
      if(centerStyle == 0)
        {
         //--- Solid center-line path
         DrawThickLine(canvas, xL_p, yLc, xR_p, yRc, centerWidth, centerArgb);
        }
      else
        {
         //--- Styled center-line path with fallback to solid on failure
         int cpat[];
         const int cn = BuildLineStylePattern(centerStyle, centerWidth, cpat);
         if(cn > 0)
            WidgetDashedLineAA(canvas, xL_p, yLc, xR_p, yRc, centerWidth, centerArgb, cpat);
         else
            DrawThickLine(canvas, xL_p, yLc, xR_p, yRc, centerWidth, centerArgb);
        }
     }
   //--- Draw 2 handles at the center-line endpoints when selected or hovered
   if(selected || hovered)
     {
      if(m_hideHandleIdx != 0)
         DrawHandleOnCanvas(canvas, xL_p, yLc, selected, lineCol, m_haloHandleIdx == 0);
      if(m_hideHandleIdx != 1)
         DrawHandleOnCanvas(canvas, xR_p, yRc, selected, lineCol, m_haloHandleIdx == 1);
     }
  }

//+------------------------------------------------------------------+
//| Hit-test the parallel channel body: 2 trendlines plus center     |
//+------------------------------------------------------------------+
bool CChannelTools::HitTestParallelChannel(int mx, int my,
                                           int x1, int y1, int x2, int y2, int x3, int y3,
                                           int threshold)
  {
   //--- Reconstruct D from the vertical-alignment invariant
   int cx3 = x1;
   int cy3 = y3;
   int x4  = x2;
   int y4  = y2 + (cy3 - y1);
   //--- Test the upper trendline A-B
   if(PointToSegmentDistance(mx, my, x1, y1, x2, y2) <= threshold) return true;
   //--- Test the lower trendline C-D
   if(PointToSegmentDistance(mx, my, cx3, cy3, x4, y4) <= threshold) return true;
   //--- Test the dashed center line (triggers whole-channel drag)
   int d1x = x1, d1y = (y1 + cy3) / 2;
   int d2x = x2, d2y = (y2 + y4)  / 2;
   if(PointToSegmentDistance(mx, my, d1x, d1y, d2x, d2y) <= threshold) return true;
   return false;
  }

//+------------------------------------------------------------------+
//| Hit-test the regression channel body (recomputes regression)     |
//+------------------------------------------------------------------+
bool CChannelTools::HitTestRegressionChannel(int mx, int my, long chartId,
                                             datetime t1, datetime t2, int threshold)
  {
   //--- Identify the chronologically left and right datetimes
   datetime tL = (t1 < t2) ? t1 : t2;
   datetime tR = (t1 < t2) ? t2 : t1;
   //--- Map the datetimes to bar indices
   int barR = iBarShift(_Symbol, _Period, tR, false);
   int barL = iBarShift(_Symbol, _Period, tL, false);
   //--- Ensure barL holds the older bar
   if(barL < barR) { int tmp = barL; barL = barR; barR = tmp; }
   int nBars = barL - barR + 1;
   //--- Abort if too few bars for a regression
   if(nBars < 2) return false;
   //--- Accumulate OLS sums for slope and intercept
   double Sx = 0, Sy = 0, Sxx = 0, Sxy = 0;
   for(int i = 0; i < nBars; i++)
     {
      //--- Read the close price for the bar at this index offset
      int shift = barL - i;
      double cls = iClose(_Symbol, _Period, shift);
      //--- Skip bars with no valid close
      if(cls == 0.0) continue;
      //--- Update the OLS sums with this sample point
      double x = (double)i;
      Sx += x; Sy += cls; Sxx += x*x; Sxy += x*cls;
     }
   double dn    = (double)nBars;
   double denom = dn*Sxx - Sx*Sx;
   //--- Reject the degenerate X-variance case
   if(MathAbs(denom) < 1e-12) return false;
   //--- Compute the slope and intercept
   double slope     = (dn*Sxy - Sx*Sy) / denom;
   double intercept = (Sy - slope*Sx) / dn;
   //--- Accumulate sum of squared residuals for the sigma estimate
   double sumSq = 0.0;
   for(int i = 0; i < nBars; i++)
     {
      //--- Read this bar's close price for the residual pass
      int shift = barL - i;
      double cls = iClose(_Symbol, _Period, shift);
      //--- Skip invalid bars
      if(cls == 0.0) continue;
      //--- Compute the predicted price and accumulate the squared residual
      double pred = slope*(double)i + intercept;
      double r    = cls - pred;
      sumSq += r*r;
     }
   //--- Compute the residual sigma
   double sigma = MathSqrt(sumSq / dn);
   //--- Recover bar datetimes for coordinate mapping
   datetime leftTime  = (datetime)iTime(_Symbol, _Period, barL);
   datetime rightTime = (datetime)iTime(_Symbol, _Period, barR);
   double leftCP  = intercept;
   double rightCP = slope*(double)(nBars-1) + intercept;
   //--- Map all six band endpoints to pixel coordinates
   int xL_p=0, yLc=0, xR_p=0, yRc=0, xt=0, yLu=0, yRu=0, yLl=0, yRl=0;
   ChartTimePriceToXY(chartId, 0, leftTime,  leftCP,                xL_p, yLc);
   ChartTimePriceToXY(chartId, 0, rightTime, rightCP,               xR_p, yRc);
   ChartTimePriceToXY(chartId, 0, leftTime,  leftCP  + 2.0*sigma,   xt,   yLu);
   ChartTimePriceToXY(chartId, 0, rightTime, rightCP + 2.0*sigma,   xt,   yRu);
   ChartTimePriceToXY(chartId, 0, leftTime,  leftCP  - 2.0*sigma,   xt,   yLl);
   ChartTimePriceToXY(chartId, 0, rightTime, rightCP - 2.0*sigma,   xt,   yRl);
   //--- Test all 3 lines: upper band, lower band, center regression
   if(PointToSegmentDistance(mx, my, xL_p, yLu, xR_p, yRu) <= threshold) return true;
   if(PointToSegmentDistance(mx, my, xL_p, yLl, xR_p, yRl) <= threshold) return true;
   if(PointToSegmentDistance(mx, my, xL_p, yLc, xR_p, yRc) <= threshold) return true;
   return false;
  }

//+------------------------------------------------------------------+
//| Hit-test the std deviation channel body                          |
//+------------------------------------------------------------------+
bool CChannelTools::HitTestStdDevChannel(int mx, int my, long chartId,
                                         datetime t1, datetime t2, int threshold)
  {
   //--- Std dev channel shares identical 3-line geometry with regression; delegate
   return HitTestRegressionChannel(mx, my, chartId, t1, t2, threshold);
  }

//+------------------------------------------------------------------+
//| Extend a pitchfork ray to the right (or nearest) canvas edge     |
//+------------------------------------------------------------------+
void PitchforkExtendToRight(int canvasW, int canvasH,
                            int x0, int y0, double dx, double dy,
                            int &ex, int &ey)
  {
   //--- Positive dx: intersect the right canvas edge
   if(dx > 0.5)
     {
      //--- Solve for the parameter t at the right edge and project Y
      double t = ((double)(canvasW - 1) - (double)x0) / dx;
      ex = canvasW - 1;
      ey = (int)MathRound((double)y0 + dy * t);
     }
   else if(dx < -0.5)
     {
      //--- Negative dx: intersect the left canvas edge instead
      double t = ((double)0 - (double)x0) / dx;
      ex = 0;
      ey = (int)MathRound((double)y0 + dy * t);
     }
   else
     {
      //--- Near-vertical line: extend to the top or bottom edge based on dy sign
      if(dy >= 0) { ex = x0; ey = canvasH - 1; }
      else        { ex = x0; ey = 0; }
     }
  }

//+------------------------------------------------------------------+
//| Draw Andrew's Pitchfork onto the canvas                          |
//+------------------------------------------------------------------+
void CChannelTools::DrawAndrewsPitchforkOn(CCanvas &canvas,
      int x1, int y1, int x2, int y2, int x3, int y3,
      color objColor, bool selected, bool hovered,
      bool medianVisible, color medianColor, int medianWidth, int medianStyle,
      bool outerVisible,  color outerColor,  int outerWidth,  int outerStyle,
      bool innerVisible,  color innerColor,  int innerWidth,  int innerStyle,
      int lineOpacity, int fillOpacity)
  {
   //--- Cache canvas dimensions for the ray extension calls
   const int cW = canvas.Width();
   const int cH = canvas.Height();
   //--- Build per-group ARGBs honoring the shared user opacity
   const uint medArgb = ColorWithPercentOpacity(medianColor, lineOpacity);
   const uint outArgb = ColorWithPercentOpacity(outerColor,  lineOpacity);
   const uint innArgb = ColorWithPercentOpacity(innerColor,  lineOpacity);
   //--- Compute the midpoint of P2-P3 through which the median ray passes
   const int mx = (x2 + x3) / 2;
   const int my = (y2 + y3) / 2;
   //--- Build the median direction vector from P1 toward the midpoint
   const double mdx  = (double)(mx - x1);
   const double mdy  = (double)(my - y1);
   const double mlen = MathSqrt(mdx * mdx + mdy * mdy);
   //--- Reject degenerate pivot where P1 equals the midpoint
   if(mlen < 1.0) return;
   //--- Extend each of the three primary lines to the right canvas edge
   int medEndX = 0, medEndY = 0;
   int upEndX  = 0, upEndY  = 0;
   int loEndX  = 0, loEndY  = 0;
   PitchforkExtendToRight(cW, cH, mx, my, mdx, mdy, medEndX, medEndY);
   PitchforkExtendToRight(cW, cH, x2, y2, mdx, mdy, upEndX,  upEndY);
   PitchforkExtendToRight(cW, cH, x3, y3, mdx, mdy, loEndX,  loEndY);
   //--- Compute inner (green) anchor points at 50% between each outer and the midpoint
   const int gUpStartX = (x2 + mx) / 2, gUpStartY = (y2 + my) / 2;
   const int gLoStartX = (x3 + mx) / 2, gLoStartY = (y3 + my) / 2;
   //--- Compute inner extension endpoints midway between outer ends and median end
   const int gUpEndX = (upEndX + medEndX) / 2, gUpEndY = (upEndY + medEndY) / 2;
   const int gLoEndX = (loEndX + medEndX) / 2, gLoEndY = (loEndY + medEndY) / 2;
   //--- Build fill ARGBs for the outer and inner band regions
   const uint outerFill = ColorWithPercentOpacity(outerColor, fillOpacity);
   const uint innerFill = ColorWithPercentOpacity(innerColor, fillOpacity);
   //--- Fill outer bands only when both outer and inner groups are visible
   if(outerVisible && innerVisible)
     {
      //--- Upper outer band quad: P2, upper outer end, upper inner end, upper inner start
      ChannelFillQuad(canvas,
                      x2, y2, upEndX, upEndY,
                      gUpEndX, gUpEndY, gUpStartX, gUpStartY,
                      outerFill);
      //--- Lower outer band quad: lower inner start, lower inner end, lower outer end, P3
      ChannelFillQuad(canvas,
                      gLoStartX, gLoStartY, gLoEndX, gLoEndY,
                      loEndX, loEndY, x3, y3,
                      outerFill);
     }
   //--- Fill inner (green) band when the inner group is visible
   if(innerVisible)
     {
      //--- Inner band quad: upper inner start, upper inner end, lower inner end, lower inner start
      ChannelFillQuad(canvas,
                      gUpStartX, gUpStartY, gUpEndX, gUpEndY,
                      gLoEndX, gLoEndY, gLoStartX, gLoStartY,
                      innerFill);
     }
   //--- Stroke the median group: base line P2-P3 plus median ray P1 to medEnd
   if(medianVisible)
     {
      //--- Resolve the effective median thickness with a sane default
      const int thM = (medianWidth > 0) ? medianWidth : 2;
      if(medianStyle == 0)
        {
         //--- Solid median path: base line plus median ray
         DrawThickLine(canvas, x2, y2, x3, y3,           thM, medArgb);
         DrawThickLine(canvas, x1, y1, medEndX, medEndY, thM, medArgb);
        }
      else
        {
         //--- Styled median path: build the dash pattern and dispatch
         int pat[]; const int pn = BuildLineStylePattern(medianStyle, thM, pat);
         if(pn > 0)
           {
            WidgetDashedLineAA(canvas, x2, y2, x3, y3,           thM, medArgb, pat);
            WidgetDashedLineAA(canvas, x1, y1, medEndX, medEndY, thM, medArgb, pat);
           }
         else
           {
            //--- Fall back to solid lines if the pattern build fails
            DrawThickLine(canvas, x2, y2, x3, y3,           thM, medArgb);
            DrawThickLine(canvas, x1, y1, medEndX, medEndY, thM, medArgb);
           }
        }
     }
   //--- Stroke the outer (blue) parallels from P2 and P3
   if(outerVisible)
     {
      //--- Resolve the effective outer thickness with a sane default
      const int thO = (outerWidth > 0) ? outerWidth : 2;
      if(outerStyle == 0)
        {
         //--- Solid outer path: upper and lower outer parallels
         DrawThickLine(canvas, x2, y2, upEndX, upEndY, thO, outArgb);
         DrawThickLine(canvas, x3, y3, loEndX, loEndY, thO, outArgb);
        }
      else
        {
         //--- Styled outer path: build the dash pattern and dispatch
         int pat[]; const int pn = BuildLineStylePattern(outerStyle, thO, pat);
         if(pn > 0)
           {
            WidgetDashedLineAA(canvas, x2, y2, upEndX, upEndY, thO, outArgb, pat);
            WidgetDashedLineAA(canvas, x3, y3, loEndX, loEndY, thO, outArgb, pat);
           }
         else
           {
            //--- Fall back to solid lines if the pattern build fails
            DrawThickLine(canvas, x2, y2, upEndX, upEndY, thO, outArgb);
            DrawThickLine(canvas, x3, y3, loEndX, loEndY, thO, outArgb);
           }
        }
     }
   //--- Stroke the inner (green) parallels at 50% between each outer and the median
   if(innerVisible)
     {
      //--- Resolve the effective inner thickness with a sane default
      const int thI = (innerWidth > 0) ? innerWidth : 2;
      if(innerStyle == 0)
        {
         //--- Solid inner path: upper and lower inner parallels
         DrawThickLine(canvas, gUpStartX, gUpStartY, gUpEndX, gUpEndY, thI, innArgb);
         DrawThickLine(canvas, gLoStartX, gLoStartY, gLoEndX, gLoEndY, thI, innArgb);
        }
      else
        {
         //--- Styled inner path: build the dash pattern and dispatch
         int pat[]; const int pn = BuildLineStylePattern(innerStyle, thI, pat);
         if(pn > 0)
           {
            WidgetDashedLineAA(canvas, gUpStartX, gUpStartY, gUpEndX, gUpEndY, thI, innArgb, pat);
            WidgetDashedLineAA(canvas, gLoStartX, gLoStartY, gLoEndX, gLoEndY, thI, innArgb, pat);
           }
         else
           {
            //--- Fall back to solid lines if the pattern build fails
            DrawThickLine(canvas, gUpStartX, gUpStartY, gUpEndX, gUpEndY, thI, innArgb);
            DrawThickLine(canvas, gLoStartX, gLoStartY, gLoEndX, gLoEndY, thI, innArgb);
           }
        }
     }
   //--- Draw 3 handles at the user-defined anchor points when selected or hovered
   if(selected || hovered)
     {
      //--- Force a vivid blue handle color in selected/hovered state for contrast
      color handleColor = (hovered || selected) ? clrDodgerBlue : objColor;
      if(m_hideHandleIdx != 0) DrawHandleOnCanvas(canvas, x1, y1, selected, handleColor, m_haloHandleIdx == 0);
      if(m_hideHandleIdx != 1) DrawHandleOnCanvas(canvas, x2, y2, selected, handleColor, m_haloHandleIdx == 1);
      if(m_hideHandleIdx != 2) DrawHandleOnCanvas(canvas, x3, y3, selected, handleColor, m_haloHandleIdx == 2);
     }
  }

//+------------------------------------------------------------------+
//| Hit-test Andrew's Pitchfork body (all 6 drawn lines)             |
//+------------------------------------------------------------------+
bool CChannelTools::HitTestAndrewsPitchfork(int mx_h, int my_h, int canvasW, int canvasH,
                                            int x1, int y1, int x2, int y2, int x3, int y3,
                                            int threshold)
  {
   //--- Reconstruct the midpoint of P2-P3 through which the median passes
   int mpx = (x2 + x3) / 2;
   int mpy = (y2 + y3) / 2;
   //--- Build the median direction vector from P1 toward the midpoint
   double mdx  = (double)(mpx - x1);
   double mdy  = (double)(mpy - y1);
   double mlen = MathSqrt(mdx * mdx + mdy * mdy);
   //--- Reject the degenerate pivot
   if(mlen < 1.0) return false;
   //--- Extend the three primary rays to the canvas edge
   int medEndX = 0, medEndY = 0;
   int upEndX  = 0, upEndY  = 0;
   int loEndX  = 0, loEndY  = 0;
   PitchforkExtendToRight(canvasW, canvasH, mpx, mpy, mdx, mdy, medEndX, medEndY);
   PitchforkExtendToRight(canvasW, canvasH, x2,  y2,  mdx, mdy, upEndX,  upEndY);
   PitchforkExtendToRight(canvasW, canvasH, x3,  y3,  mdx, mdy, loEndX,  loEndY);
   //--- Reconstruct the inner (green) start and end anchor points
   int gUpStartX = (x2 + mpx) / 2, gUpStartY = (y2 + mpy) / 2;
   int gLoStartX = (x3 + mpx) / 2, gLoStartY = (y3 + mpy) / 2;
   int gUpEndX   = (upEndX + medEndX) / 2, gUpEndY = (upEndY + medEndY) / 2;
   int gLoEndX   = (loEndX + medEndX) / 2, gLoEndY = (loEndY + medEndY) / 2;
   //--- Test each of the 6 lines in order: base, median, outer up, outer lo, inner up, inner lo
   if(PointToSegmentDistance(mx_h, my_h, x2, y2, x3, y3) <= threshold) return true;
   if(PointToSegmentDistance(mx_h, my_h, x1, y1, medEndX, medEndY) <= threshold) return true;
   if(PointToSegmentDistance(mx_h, my_h, x2, y2, upEndX,  upEndY)  <= threshold) return true;
   if(PointToSegmentDistance(mx_h, my_h, x3, y3, loEndX,  loEndY)  <= threshold) return true;
   if(PointToSegmentDistance(mx_h, my_h, gUpStartX, gUpStartY, gUpEndX, gUpEndY) <= threshold) return true;
   if(PointToSegmentDistance(mx_h, my_h, gLoStartX, gLoStartY, gLoEndX, gLoEndY) <= threshold) return true;
   return false;
  }

//+------------------------------------------------------------------+
//| Draw Schiff Pitchfork onto the canvas                            |
//+------------------------------------------------------------------+
void CChannelTools::DrawSchiffPitchforkOn(CCanvas &canvas,
      int x1, int y1, int x2, int y2, int x3, int y3,
      color objColor, bool selected, bool hovered,
      bool medianVisible, color medianColor, int medianWidth, int medianStyle,
      bool outerVisible,  color outerColor,  int outerWidth,  int outerStyle,
      bool innerVisible,  color innerColor,  int innerWidth,  int innerStyle,
      int lineOpacity, int fillOpacity)
  {
   //--- Cache canvas dimensions for the ray extension calls
   const int cW = canvas.Width();
   const int cH = canvas.Height();
   //--- Build per-group ARGBs honoring the shared user opacity
   const uint medArgb = ColorWithPercentOpacity(medianColor, lineOpacity);
   const uint outArgb = ColorWithPercentOpacity(outerColor,  lineOpacity);
   const uint innArgb = ColorWithPercentOpacity(innerColor,  lineOpacity);
   //--- Schiff origin: shares P1's X but Y is the midpoint between P1 and P2
   const int origX = x1;
   const int origY = (y1 + y2) / 2;
   //--- Compute the midpoint of P2-P3 for the median direction
   const int mx = (x2 + x3) / 2;
   const int my = (y2 + y3) / 2;
   //--- Build the median direction vector from the Schiff origin
   const double mdx  = (double)(mx - origX);
   const double mdy  = (double)(my - origY);
   const double mlen = MathSqrt(mdx * mdx + mdy * mdy);
   //--- Reject the degenerate modified origin
   if(mlen < 1.0) return;
   //--- Extend all three primary rays to the canvas edge
   int medEndX = 0, medEndY = 0;
   int upEndX  = 0, upEndY  = 0;
   int loEndX  = 0, loEndY  = 0;
   PitchforkExtendToRight(cW, cH, origX, origY, mdx, mdy, medEndX, medEndY);
   PitchforkExtendToRight(cW, cH, x2,    y2,    mdx, mdy, upEndX,  upEndY);
   PitchforkExtendToRight(cW, cH, x3,    y3,    mdx, mdy, loEndX,  loEndY);
   //--- Compute the base midpoint of P2-P3 for inner-line anchor positions
   const int bmx = (x2 + x3) / 2;
   const int bmy = (y2 + y3) / 2;
   //--- Inner parallels start on the base P2-P3 at their 50% midpoints
   const int gUpStartX = (x2 + bmx) / 2, gUpStartY = (y2 + bmy) / 2;
   const int gLoStartX = (x3 + bmx) / 2, gLoStartY = (y3 + bmy) / 2;
   const int gUpEndX   = (upEndX + medEndX) / 2, gUpEndY = (upEndY + medEndY) / 2;
   const int gLoEndX   = (loEndX + medEndX) / 2, gLoEndY = (loEndY + medEndY) / 2;
   //--- Build fill ARGBs for the outer and inner band regions
   const uint outerFill = ColorWithPercentOpacity(outerColor, fillOpacity);
   const uint innerFill = ColorWithPercentOpacity(innerColor, fillOpacity);
   //--- Fill outer bands only when both bordering groups are visible
   if(outerVisible && innerVisible)
     {
      //--- Upper outer band quad and lower outer band quad
      ChannelFillQuad(canvas, x2, y2, upEndX, upEndY,
                      gUpEndX, gUpEndY, gUpStartX, gUpStartY, outerFill);
      ChannelFillQuad(canvas, gLoStartX, gLoStartY, gLoEndX, gLoEndY,
                      loEndX, loEndY, x3, y3, outerFill);
     }
   //--- Fill inner (green) band when the inner group is visible
   if(innerVisible)
     {
      //--- Inner band quad bounded by upper and lower inner parallels
      ChannelFillQuad(canvas, gUpStartX, gUpStartY, gUpEndX, gUpEndY,
                      gLoEndX, gLoEndY, gLoStartX, gLoStartY, innerFill);
     }
   //--- Stroke the median group: base P2-P3, median origX to medEnd, and swing P1-P2
   if(medianVisible)
     {
      //--- Resolve the effective median thickness with a sane default
      const int thM = (medianWidth > 0) ? medianWidth : 2;
      if(medianStyle == 0)
        {
         //--- Solid median path: base, median ray, and swing leg
         DrawThickLine(canvas, x2, y2, x3, y3,                 thM, medArgb);
         DrawThickLine(canvas, origX, origY, medEndX, medEndY, thM, medArgb);
         DrawThickLine(canvas, x1, y1, x2, y2,                 thM, medArgb);
        }
      else
        {
         //--- Styled median path: build the dash pattern and dispatch
         int pat[]; const int pn = BuildLineStylePattern(medianStyle, thM, pat);
         if(pn > 0)
           {
            WidgetDashedLineAA(canvas, x2, y2, x3, y3,                 thM, medArgb, pat);
            WidgetDashedLineAA(canvas, origX, origY, medEndX, medEndY, thM, medArgb, pat);
            WidgetDashedLineAA(canvas, x1, y1, x2, y2,                 thM, medArgb, pat);
           }
         else
           {
            //--- Fall back to solid lines if the pattern build fails
            DrawThickLine(canvas, x2, y2, x3, y3,                 thM, medArgb);
            DrawThickLine(canvas, origX, origY, medEndX, medEndY, thM, medArgb);
            DrawThickLine(canvas, x1, y1, x2, y2,                 thM, medArgb);
           }
        }
     }
   //--- Stroke the outer (blue) parallels from P2 and P3
   if(outerVisible)
     {
      //--- Resolve the effective outer thickness with a sane default
      const int thO = (outerWidth > 0) ? outerWidth : 2;
      if(outerStyle == 0)
        {
         //--- Solid outer path: upper and lower outer parallels
         DrawThickLine(canvas, x2, y2, upEndX, upEndY, thO, outArgb);
         DrawThickLine(canvas, x3, y3, loEndX, loEndY, thO, outArgb);
        }
      else
        {
         //--- Styled outer path: build the dash pattern and dispatch
         int pat[]; const int pn = BuildLineStylePattern(outerStyle, thO, pat);
         if(pn > 0)
           {
            WidgetDashedLineAA(canvas, x2, y2, upEndX, upEndY, thO, outArgb, pat);
            WidgetDashedLineAA(canvas, x3, y3, loEndX, loEndY, thO, outArgb, pat);
           }
         else
           {
            //--- Fall back to solid lines if the pattern build fails
            DrawThickLine(canvas, x2, y2, upEndX, upEndY, thO, outArgb);
            DrawThickLine(canvas, x3, y3, loEndX, loEndY, thO, outArgb);
           }
        }
     }
   //--- Stroke the inner (green) parallels
   if(innerVisible)
     {
      //--- Resolve the effective inner thickness with a sane default
      const int thI = (innerWidth > 0) ? innerWidth : 2;
      if(innerStyle == 0)
        {
         //--- Solid inner path: upper and lower inner parallels
         DrawThickLine(canvas, gUpStartX, gUpStartY, gUpEndX, gUpEndY, thI, innArgb);
         DrawThickLine(canvas, gLoStartX, gLoStartY, gLoEndX, gLoEndY, thI, innArgb);
        }
      else
        {
         //--- Styled inner path: build the dash pattern and dispatch
         int pat[]; const int pn = BuildLineStylePattern(innerStyle, thI, pat);
         if(pn > 0)
           {
            WidgetDashedLineAA(canvas, gUpStartX, gUpStartY, gUpEndX, gUpEndY, thI, innArgb, pat);
            WidgetDashedLineAA(canvas, gLoStartX, gLoStartY, gLoEndX, gLoEndY, thI, innArgb, pat);
           }
         else
           {
            //--- Fall back to solid lines if the pattern build fails
            DrawThickLine(canvas, gUpStartX, gUpStartY, gUpEndX, gUpEndY, thI, innArgb);
            DrawThickLine(canvas, gLoStartX, gLoStartY, gLoEndX, gLoEndY, thI, innArgb);
           }
        }
     }
   //--- Draw 3 handles at the anchor points when selected or hovered
   if(selected || hovered)
     {
      //--- Force a vivid blue handle color in selected/hovered state for contrast
      color handleColor = (hovered || selected) ? clrDodgerBlue : objColor;
      if(m_hideHandleIdx != 0) DrawHandleOnCanvas(canvas, x1, y1, selected, handleColor, m_haloHandleIdx == 0);
      if(m_hideHandleIdx != 1) DrawHandleOnCanvas(canvas, x2, y2, selected, handleColor, m_haloHandleIdx == 1);
      if(m_hideHandleIdx != 2) DrawHandleOnCanvas(canvas, x3, y3, selected, handleColor, m_haloHandleIdx == 2);
     }
  }

//+------------------------------------------------------------------+
//| Hit-test Schiff Pitchfork body (6 lines plus P1-P2 swing segment)|
//+------------------------------------------------------------------+
bool CChannelTools::HitTestSchiffPitchfork(int mx_h, int my_h, int canvasW, int canvasH,
                                           int x1, int y1, int x2, int y2, int x3, int y3,
                                           int threshold)
  {
   //--- Reconstruct the Schiff origin: P1's X with midpoint Y
   int origX = x1;
   int origY = (y1 + y2) / 2;
   //--- Compute the median direction from the Schiff origin
   int mpx = (x2 + x3) / 2;
   int mpy = (y2 + y3) / 2;
   double mdx  = (double)(mpx - origX);
   double mdy  = (double)(mpy - origY);
   double mlen = MathSqrt(mdx * mdx + mdy * mdy);
   //--- Reject the degenerate case
   if(mlen < 1.0) return false;
   //--- Extend all three primary rays to the canvas edge
   int medEndX = 0, medEndY = 0;
   int upEndX  = 0, upEndY  = 0;
   int loEndX  = 0, loEndY  = 0;
   PitchforkExtendToRight(canvasW, canvasH, origX, origY, mdx, mdy, medEndX, medEndY);
   PitchforkExtendToRight(canvasW, canvasH, x2,    y2,    mdx, mdy, upEndX,  upEndY);
   PitchforkExtendToRight(canvasW, canvasH, x3,    y3,    mdx, mdy, loEndX,  loEndY);
   //--- Reconstruct inner-line anchor positions from the base midpoint
   int bmx = (x2 + x3) / 2;
   int bmy = (y2 + y3) / 2;
   int gUpStartX = (x2 + bmx) / 2, gUpStartY = (y2 + bmy) / 2;
   int gLoStartX = (x3 + bmx) / 2, gLoStartY = (y3 + bmy) / 2;
   int gUpEndX   = (upEndX + medEndX) / 2, gUpEndY = (upEndY + medEndY) / 2;
   int gLoEndX   = (loEndX + medEndX) / 2, gLoEndY = (loEndY + medEndY) / 2;
   //--- Test all 7 segments: base, median, swing P1-P2, outer up, outer lo, inner up, inner lo
   if(PointToSegmentDistance(mx_h, my_h, x2, y2, x3, y3) <= threshold) return true;
   if(PointToSegmentDistance(mx_h, my_h, origX, origY, medEndX, medEndY) <= threshold) return true;
   if(PointToSegmentDistance(mx_h, my_h, x1, y1, x2, y2) <= threshold) return true;
   if(PointToSegmentDistance(mx_h, my_h, x2, y2, upEndX,  upEndY)  <= threshold) return true;
   if(PointToSegmentDistance(mx_h, my_h, x3, y3, loEndX,  loEndY)  <= threshold) return true;
   if(PointToSegmentDistance(mx_h, my_h, gUpStartX, gUpStartY, gUpEndX, gUpEndY) <= threshold) return true;
   if(PointToSegmentDistance(mx_h, my_h, gLoStartX, gLoStartY, gLoEndX, gLoEndY) <= threshold) return true;
   return false;
  }

//+------------------------------------------------------------------+
//| Draw Modified Schiff Pitchfork onto the canvas                   |
//+------------------------------------------------------------------+
void CChannelTools::DrawModSchiffPitchforkOn(CCanvas &canvas,
      int x1, int y1, int x2, int y2, int x3, int y3,
      color objColor, bool selected, bool hovered,
      bool medianVisible, color medianColor, int medianWidth, int medianStyle,
      bool outerVisible,  color outerColor,  int outerWidth,  int outerStyle,
      bool innerVisible,  color innerColor,  int innerWidth,  int innerStyle,
      int lineOpacity, int fillOpacity)
  {
   //--- Cache canvas dimensions for the ray extension calls
   const int cW = canvas.Width();
   const int cH = canvas.Height();
   //--- Build per-group ARGBs honoring the shared user opacity
   const uint medArgb = ColorWithPercentOpacity(medianColor, lineOpacity);
   const uint outArgb = ColorWithPercentOpacity(outerColor,  lineOpacity);
   const uint innArgb = ColorWithPercentOpacity(innerColor,  lineOpacity);
   //--- Modified origin: TRUE midpoint of P1-P2 on both axes
   const int origX = (x1 + x2) / 2;
   const int origY = (y1 + y2) / 2;
   //--- Compute the base midpoint (P2-P3) for the median direction
   const int bmx = (x2 + x3) / 2;
   const int bmy = (y2 + y3) / 2;
   //--- Build the median direction vector from the modified origin
   const double mdx  = (double)(bmx - origX);
   const double mdy  = (double)(bmy - origY);
   const double mlen = MathSqrt(mdx * mdx + mdy * mdy);
   //--- Reject the degenerate modified origin
   if(mlen < 1.0) return;
   //--- Extend the three primary rays to the canvas edge
   int medEndX = 0, medEndY = 0;
   int upEndX  = 0, upEndY  = 0;
   int loEndX  = 0, loEndY  = 0;
   PitchforkExtendToRight(cW, cH, origX, origY, mdx, mdy, medEndX, medEndY);
   PitchforkExtendToRight(cW, cH, x2,    y2,    mdx, mdy, upEndX,  upEndY);
   PitchforkExtendToRight(cW, cH, x3,    y3,    mdx, mdy, loEndX,  loEndY);
   //--- Inner parallels start on the base P2-P3 at their 50% midpoints
   const int gUpStartX = (x2 + bmx) / 2, gUpStartY = (y2 + bmy) / 2;
   const int gLoStartX = (x3 + bmx) / 2, gLoStartY = (y3 + bmy) / 2;
   const int gUpEndX   = (upEndX + medEndX) / 2, gUpEndY = (upEndY + medEndY) / 2;
   const int gLoEndX   = (loEndX + medEndX) / 2, gLoEndY = (loEndY + medEndY) / 2;
   //--- Build fill ARGBs for the outer and inner band regions
   const uint outerFill = ColorWithPercentOpacity(outerColor, fillOpacity);
   const uint innerFill = ColorWithPercentOpacity(innerColor, fillOpacity);
   //--- Fill outer bands when both bordering groups are visible
   if(outerVisible && innerVisible)
     {
      //--- Upper outer band quad and lower outer band quad
      ChannelFillQuad(canvas, x2, y2, upEndX, upEndY,
                      gUpEndX, gUpEndY, gUpStartX, gUpStartY, outerFill);
      ChannelFillQuad(canvas, gLoStartX, gLoStartY, gLoEndX, gLoEndY,
                      loEndX, loEndY, x3, y3, outerFill);
     }
   //--- Fill inner (green) band when the inner group is visible
   if(innerVisible)
     {
      //--- Inner band quad bounded by upper and lower inner parallels
      ChannelFillQuad(canvas, gUpStartX, gUpStartY, gUpEndX, gUpEndY,
                      gLoEndX, gLoEndY, gLoStartX, gLoStartY, innerFill);
     }
   //--- Stroke the median group: base P2-P3, median origX to medEnd, and swing P1-P2
   if(medianVisible)
     {
      //--- Resolve the effective median thickness with a sane default
      const int thM = (medianWidth > 0) ? medianWidth : 2;
      if(medianStyle == 0)
        {
         //--- Solid median path: base, median ray, and swing leg
         DrawThickLine(canvas, x2, y2, x3, y3,                 thM, medArgb);
         DrawThickLine(canvas, origX, origY, medEndX, medEndY, thM, medArgb);
         DrawThickLine(canvas, x1, y1, x2, y2,                 thM, medArgb);
        }
      else
        {
         //--- Styled median path: build the dash pattern and dispatch
         int pat[]; const int pn = BuildLineStylePattern(medianStyle, thM, pat);
         if(pn > 0)
           {
            WidgetDashedLineAA(canvas, x2, y2, x3, y3,                 thM, medArgb, pat);
            WidgetDashedLineAA(canvas, origX, origY, medEndX, medEndY, thM, medArgb, pat);
            WidgetDashedLineAA(canvas, x1, y1, x2, y2,                 thM, medArgb, pat);
           }
         else
           {
            //--- Fall back to solid lines if the pattern build fails
            DrawThickLine(canvas, x2, y2, x3, y3,                 thM, medArgb);
            DrawThickLine(canvas, origX, origY, medEndX, medEndY, thM, medArgb);
            DrawThickLine(canvas, x1, y1, x2, y2,                 thM, medArgb);
           }
        }
     }
   //--- Stroke the outer (blue) parallels from P2 and P3
   if(outerVisible)
     {
      //--- Resolve the effective outer thickness with a sane default
      const int thO = (outerWidth > 0) ? outerWidth : 2;
      if(outerStyle == 0)
        {
         //--- Solid outer path: upper and lower outer parallels
         DrawThickLine(canvas, x2, y2, upEndX, upEndY, thO, outArgb);
         DrawThickLine(canvas, x3, y3, loEndX, loEndY, thO, outArgb);
        }
      else
        {
         //--- Styled outer path: build the dash pattern and dispatch
         int pat[]; const int pn = BuildLineStylePattern(outerStyle, thO, pat);
         if(pn > 0)
           {
            WidgetDashedLineAA(canvas, x2, y2, upEndX, upEndY, thO, outArgb, pat);
            WidgetDashedLineAA(canvas, x3, y3, loEndX, loEndY, thO, outArgb, pat);
           }
         else
           {
            //--- Fall back to solid lines if the pattern build fails
            DrawThickLine(canvas, x2, y2, upEndX, upEndY, thO, outArgb);
            DrawThickLine(canvas, x3, y3, loEndX, loEndY, thO, outArgb);
           }
        }
     }
   //--- Stroke the inner (green) parallels
   if(innerVisible)
     {
      //--- Resolve the effective inner thickness with a sane default
      const int thI = (innerWidth > 0) ? innerWidth : 2;
      if(innerStyle == 0)
        {
         //--- Solid inner path: upper and lower inner parallels
         DrawThickLine(canvas, gUpStartX, gUpStartY, gUpEndX, gUpEndY, thI, innArgb);
         DrawThickLine(canvas, gLoStartX, gLoStartY, gLoEndX, gLoEndY, thI, innArgb);
        }
      else
        {
         //--- Styled inner path: build the dash pattern and dispatch
         int pat[]; const int pn = BuildLineStylePattern(innerStyle, thI, pat);
         if(pn > 0)
           {
            WidgetDashedLineAA(canvas, gUpStartX, gUpStartY, gUpEndX, gUpEndY, thI, innArgb, pat);
            WidgetDashedLineAA(canvas, gLoStartX, gLoStartY, gLoEndX, gLoEndY, thI, innArgb, pat);
           }
         else
           {
            //--- Fall back to solid lines if the pattern build fails
            DrawThickLine(canvas, gUpStartX, gUpStartY, gUpEndX, gUpEndY, thI, innArgb);
            DrawThickLine(canvas, gLoStartX, gLoStartY, gLoEndX, gLoEndY, thI, innArgb);
           }
        }
     }
   //--- Draw 3 handles at the anchor points when selected or hovered
   if(selected || hovered)
     {
      //--- Force a vivid blue handle color in selected/hovered state for contrast
      color handleColor = (hovered || selected) ? clrDodgerBlue : objColor;
      if(m_hideHandleIdx != 0) DrawHandleOnCanvas(canvas, x1, y1, selected, handleColor, m_haloHandleIdx == 0);
      if(m_hideHandleIdx != 1) DrawHandleOnCanvas(canvas, x2, y2, selected, handleColor, m_haloHandleIdx == 1);
      if(m_hideHandleIdx != 2) DrawHandleOnCanvas(canvas, x3, y3, selected, handleColor, m_haloHandleIdx == 2);
     }
  }

//+------------------------------------------------------------------+
//| Hit-test Modified Schiff Pitchfork body (same 7 segments)        |
//+------------------------------------------------------------------+
bool CChannelTools::HitTestModSchiffPitchfork(int mx_h, int my_h, int canvasW, int canvasH,
                                              int x1, int y1, int x2, int y2, int x3, int y3,
                                              int threshold)
  {
   //--- Reconstruct the modified origin: TRUE midpoint of P1-P2
   int origX = (x1 + x2) / 2;
   int origY = (y1 + y2) / 2;
   //--- Compute the base midpoint for the median direction
   int bmx = (x2 + x3) / 2;
   int bmy = (y2 + y3) / 2;
   //--- Build the median direction vector from the modified origin
   double mdx  = (double)(bmx - origX);
   double mdy  = (double)(bmy - origY);
   double mlen = MathSqrt(mdx * mdx + mdy * mdy);
   //--- Reject the degenerate case
   if(mlen < 1.0) return false;
   //--- Extend the three primary rays to the canvas edge
   int medEndX = 0, medEndY = 0;
   int upEndX  = 0, upEndY  = 0;
   int loEndX  = 0, loEndY  = 0;
   PitchforkExtendToRight(canvasW, canvasH, origX, origY, mdx, mdy, medEndX, medEndY);
   PitchforkExtendToRight(canvasW, canvasH, x2,    y2,    mdx, mdy, upEndX,  upEndY);
   PitchforkExtendToRight(canvasW, canvasH, x3,    y3,    mdx, mdy, loEndX,  loEndY);
   //--- Reconstruct inner-line anchor positions from the base midpoint
   int gUpStartX = (x2 + bmx) / 2, gUpStartY = (y2 + bmy) / 2;
   int gLoStartX = (x3 + bmx) / 2, gLoStartY = (y3 + bmy) / 2;
   int gUpEndX   = (upEndX + medEndX) / 2, gUpEndY = (upEndY + medEndY) / 2;
   int gLoEndX   = (loEndX + medEndX) / 2, gLoEndY = (loEndY + medEndY) / 2;
   //--- Test all 7 segments: base, median, swing P1-P2, outer up, outer lo, inner up, inner lo
   if(PointToSegmentDistance(mx_h, my_h, x2, y2, x3, y3) <= threshold) return true;
   if(PointToSegmentDistance(mx_h, my_h, origX, origY, medEndX, medEndY) <= threshold) return true;
   if(PointToSegmentDistance(mx_h, my_h, x1, y1, x2, y2) <= threshold) return true;
   if(PointToSegmentDistance(mx_h, my_h, x2, y2, upEndX,  upEndY)  <= threshold) return true;
   if(PointToSegmentDistance(mx_h, my_h, x3, y3, loEndX,  loEndY)  <= threshold) return true;
   if(PointToSegmentDistance(mx_h, my_h, gUpStartX, gUpStartY, gUpEndX, gUpEndY) <= threshold) return true;
   if(PointToSegmentDistance(mx_h, my_h, gLoStartX, gLoStartY, gLoEndX, gLoEndY) <= threshold) return true;
   return false;
  }

//+------------------------------------------------------------------+
//| Draw a text label with 2-pass black/white alpha extraction       |
//+------------------------------------------------------------------+
void GannDrawLabel(CCanvas &canvas, const string text, int anchorX, int anchorY,
                   color textColor, int fontPxSize = 8)
  {
   //--- Skip empty strings immediately
   if(StringLen(text) == 0) return;
   //--- Set the font for the upcoming size query and render calls
   TextSetFont("Arial", -(fontPxSize * 10));
   //--- Measure the label bounding box
   uint twU = 0, thU = 0;
   TextGetSize(text, twU, thU);
   int tw = (int)twU, th = (int)thU;
   //--- Skip if the font engine returned a zero-size bounding box
   if(tw <= 0 || th <= 0) return;
   //--- Compose the label ARGB at full opacity for the buffer renders
   uint textArgb = ColorToARGB(textColor, 255);
   //--- First pass: render on black to record per-pixel ink coverage
   uint bufB[]; ArrayResize(bufB, tw * th);
   ArrayFill(bufB, 0, tw * th, 0xFF000000);
   TextOut(text, 0, 0, TA_LEFT | TA_TOP, bufB, tw, th,
           textArgb, COLOR_FORMAT_ARGB_NORMALIZE);
   //--- Second pass: render on white to record per-pixel ink coverage
   uint bufW[]; ArrayResize(bufW, tw * th);
   ArrayFill(bufW, 0, tw * th, 0xFFFFFFFF);
   TextOut(text, 0, 0, TA_LEFT | TA_TOP, bufW, tw, th,
           textArgb, COLOR_FORMAT_ARGB_NORMALIZE);
   //--- Compute the canvas target origin and bounds
   int txtX = anchorX, txtY = anchorY;
   int cW = canvas.Width(), cH = canvas.Height();
   //--- Skip labels whose bounding box falls entirely outside the canvas
   if(txtX + tw < 0 || txtX >= cW) return;
   if(txtY + th < 0 || txtY >= cH) return;
   //--- Extract the source RGB from the caller-supplied text color
   uchar srcR = (uchar)((textColor)       & 0xFF);
   uchar srcG = (uchar)((textColor >> 8)  & 0xFF);
   uchar srcB = (uchar)((textColor >> 16) & 0xFF);
   //--- Composite each glyph pixel onto the canvas
   for(int py = 0; py < th; py++)
     {
      for(int px = 0; px < tw; px++)
        {
         //--- Derive per-pixel alpha from the black/white render difference
         int i = py * tw + px;
         int dR = (int)((bufW[i] >> 16) & 0xFF) - (int)((bufB[i] >> 16) & 0xFF);
         int dG = (int)((bufW[i] >>  8) & 0xFF) - (int)((bufB[i] >>  8) & 0xFF);
         int dB = (int)( bufW[i]        & 0xFF) - (int)( bufB[i]        & 0xFF);
         int a  = 255 - (dR + dG + dB) / 3;
         //--- Skip transparent pixels
         if(a <= 0) continue;
         if(a > 255) a = 255;
         //--- Compute the canvas target coordinate with bounds checking
         int dstX = txtX + px, dstY = txtY + py;
         if(dstX < 0 || dstX >= cW || dstY < 0 || dstY >= cH) continue;
         //--- Blend the label pixel over the existing canvas pixel
         uint existing = canvas.PixelGet(dstX, dstY);
         double sA = (double)a / 255.0;
         double dA = ((existing >> 24) & 0xFF) / 255.0;
         double oA = sA + dA * (1.0 - sA);
         if(oA <= 0.0) continue;
         //--- Normalize source and destination channels for compositing
         double sRf = srcR / 255.0, sGf = srcG / 255.0, sBf = srcB / 255.0;
         double dRf = ((existing >> 16) & 0xFF) / 255.0;
         double dGf = ((existing >>  8) & 0xFF) / 255.0;
         double dBf = ( existing        & 0xFF) / 255.0;
         //--- Assemble the final ARGB output pixel and write it back
         uint outPix = ((uint)(uchar)(oA * 255.0 + 0.5) << 24) |
                       ((uint)(uchar)((sRf*sA + dRf*dA*(1.0-sA)) / oA * 255.0 + 0.5) << 16) |
                       ((uint)(uchar)((sGf*sA + dGf*dA*(1.0-sA)) / oA * 255.0 + 0.5) <<  8) |
                        (uint)(uchar)((sBf*sA + dBf*dA*(1.0-sA)) / oA * 255.0 + 0.5);
         canvas.PixelSet(dstX, dstY, outPix);
        }
     }
  }

//+------------------------------------------------------------------+
//| Extend a ray from (x0, y0) in direction (dx, dy) to canvas edge  |
//+------------------------------------------------------------------+
void GannExtendRay(int canvasW, int canvasH, int x0, int y0,
                   double dx, double dy, int &outX, int &outY)
  {
   //--- Seed the maximum t with a very large sentinel value
   double tMax = 1e18;
   //--- Test intersection with the right edge
   if(dx > 1e-9)
     {
      double t = ((double)(canvasW - 1) - (double)x0) / dx;
      if(t < tMax) tMax = t;
     }
   //--- Test intersection with the bottom edge
   if(dy > 1e-9)
     {
      double t = ((double)(canvasH - 1) - (double)y0) / dy;
      if(t < tMax) tMax = t;
     }
   //--- Test intersection with the top edge
   if(dy < -1e-9)
     {
      double t = (0.0 - (double)y0) / dy;
      if(t < tMax) tMax = t;
     }
   //--- Clamp to zero if no valid forward intersection was found
   if(tMax < 0 || tMax > 1e17) tMax = 0;
   //--- Write the resulting canvas-edge endpoint
   outX = (int)MathRound((double)x0 + dx * tMax);
   outY = (int)MathRound((double)y0 + dy * tMax);
  }

//+------------------------------------------------------------------+
//| Draw Gann Line: single ray from P1 through P2, extended right    |
//+------------------------------------------------------------------+
void CChannelTools::DrawGannLineOn(CCanvas &canvas,
                                   int x1, int y1, int x2, int y2,
                                   color objColor, bool selected, bool hovered,
                                   int lineOpacity, int lineWidth, int lineStyle)
  {
   //--- Compose the ray ARGB and resolve the effective thickness
   const uint argb  = ColorWithPercentOpacity(objColor, lineOpacity);
   const int  thick = (lineWidth > 0) ? lineWidth : 2;
   const int  cW    = canvas.Width(), cH = canvas.Height();
   //--- Compute the direction vector from P1 to P2
   double dx = (double)(x2 - x1), dy = (double)(y2 - y1);
   //--- Reject a degenerate zero-length definition
   if(MathAbs(dx) < 1e-9 && MathAbs(dy) < 1e-9) return;
   //--- Extend the ray from P1 to the canvas edge along the P1-P2 direction
   int endX = x2, endY = y2;
   if(dx > 1e-9 || dy > 1e-9 || dx < -1e-9 || dy < -1e-9)
      GannExtendRay(cW, cH, x1, y1, dx, dy, endX, endY);
   //--- Stroke the extended ray using solid or styled line dispatch
   if(lineStyle == 0)
      DrawThickLine(canvas, x1, y1, endX, endY, thick, argb);
   else
     {
      //--- Build the dash pattern and dispatch with fallback to solid
      int pat[]; const int pn = BuildLineStylePattern(lineStyle, thick, pat);
      if(pn > 0) WidgetDashedLineAA(canvas, x1, y1, endX, endY, thick, argb, pat);
      else       DrawThickLine(canvas, x1, y1, endX, endY, thick, argb);
     }
   //--- Draw 2 handles at P1 and P2 when selected or hovered
   if(selected || hovered)
     {
      if(m_hideHandleIdx != 0) DrawHandleOnCanvas(canvas, x1, y1, selected, objColor, m_haloHandleIdx == 0);
      if(m_hideHandleIdx != 1) DrawHandleOnCanvas(canvas, x2, y2, selected, objColor, m_haloHandleIdx == 1);
     }
  }

//+------------------------------------------------------------------+
//| Hit-test Gann Line body (distance to extended ray)               |
//+------------------------------------------------------------------+
bool CChannelTools::HitTestGannLine(int mx, int my, int canvasW, int canvasH,
                                    int x1, int y1, int x2, int y2, int threshold)
  {
   //--- Compute the direction vector from P1 to P2
   double dx = (double)(x2 - x1), dy = (double)(y2 - y1);
   //--- Reject a zero-length definition
   if(MathAbs(dx) < 1e-9 && MathAbs(dy) < 1e-9) return false;
   //--- Extend the ray to match what was drawn
   int endX = x2, endY = y2;
   GannExtendRay(canvasW, canvasH, x1, y1, dx, dy, endX, endY);
   //--- Return true if the cursor falls within threshold of the extended ray
   return (PointToSegmentDistance(mx, my, x1, y1, endX, endY) <= threshold);
  }

//+------------------------------------------------------------------+
//| Draw Gann Fan: rays from P1 at canonical Gann ratios             |
//+------------------------------------------------------------------+
void CChannelTools::DrawGannFanOn(CCanvas &canvas,
                                  int x1, int y1, int x2, int y2,
                                  color objColor, bool selected, bool hovered,
                                  const double &lvlRatio[],
                                  const color  &lvlColor[],
                                  const int    &lvlOpacity[],
                                  const int    &lvlWidth[],
                                  const int    &lvlStyle[],
                                  const bool   &lvlVisible[],
                                  int fillOpacity)
  {
   //--- Cache canvas dimensions for the ray extension calls
   const int cW = canvas.Width(), cH = canvas.Height();
   //--- Derive the unit scale from the P1-P2 vector (dxUnit is the time unit)
   const double dxUnit = (double)(x2 - x1);
   const double dyUnit = (double)(y2 - y1);
   //--- Reject a degenerate zero-horizontal extent
   if(MathAbs(dxUnit) < 1e-6) return;
   const int nLev = ArraySize(lvlRatio);
   //--- Nothing to draw if no levels are defined
   if(nLev <= 0) return;
   //--- Pre-compute each ray's canvas-edge endpoint
   const int MAX_GFAN = 32;
   int endX[]; ArrayResize(endX, MAX_GFAN);
   int endY[]; ArrayResize(endY, MAX_GFAN);
   for(int i = 0; i < nLev; i++)
     {
      //--- Scale the unit vector by this level's ratio and extend to the canvas edge
      const double dxR = dxUnit;
      const double dyR = dyUnit * lvlRatio[i];
      int eX = x2, eY = y2;
      GannExtendRay(cW, cH, x1, y1, dxR, dyR, eX, eY);
      endX[i] = eX; endY[i] = eY;
     }
   //--- Draw translucent wedge fills between adjacent visible rays
   int cornerPts[4][2] = { {cW - 1, 0}, {cW - 1, cH - 1}, {0, cH - 1}, {0, 0} };
   int prevVis = -1;
   for(int i = 0; i < nLev; i++)
     {
      if(!lvlVisible[i]) continue;
      //--- Need at least two visible rays to form a wedge
      if(prevVis < 0) { prevVis = i; continue; }
      //--- Compose the wedge fill ARGB at the shared opacity
      const uint fillArgb = ColorWithPercentOpacity(lvlColor[i], fillOpacity);
      const int eaX = endX[prevVis], eaY = endY[prevVis];
      const int ebX = endX[i],       ebY = endY[i];
      //--- Determine which canvas edge each ray endpoint sits on
      int edgeA = -1, edgeB = -1;
      if(eaY <= 0)           edgeA = 0;
      else if(eaX >= cW - 1) edgeA = 1;
      else if(eaY >= cH - 1) edgeA = 2;
      else                   edgeA = 3;
      if(ebY <= 0)           edgeB = 0;
      else if(ebX >= cW - 1) edgeB = 1;
      else if(ebY >= cH - 1) edgeB = 2;
      else                   edgeB = 3;
      //--- Build the wedge polygon from P1, the two ray endpoints, and any corner vertices
      int polyX[8], polyY[8];
      int nPts = 0;
      polyX[nPts] = x1;  polyY[nPts] = y1;  nPts++;
      polyX[nPts] = eaX; polyY[nPts] = eaY; nPts++;
      //--- Determine the winding direction to walk corners in the correct order
      const double aDx = (double)(eaX - x1), aDy = (double)(eaY - y1);
      const double bDx = (double)(ebX - x1), bDy = (double)(ebY - y1);
      const double cross = aDx * bDy - aDy * bDx;
      const int step = (cross >= 0.0) ? 1 : 3;
      //--- Walk canvas corners from edgeA to edgeB in the correct winding
      if(edgeA != edgeB)
        {
         int e = edgeA;
         int guard = 0;
         while(e != edgeB && guard < 4)
           {
            //--- Pick the corner index based on the winding direction and append
            int cIdx = (step == 1) ? e : ((e + 3) % 4);
            polyX[nPts] = cornerPts[cIdx][0];
            polyY[nPts] = cornerPts[cIdx][1];
            nPts++;
            e = (e + step) % 4;
            guard++;
           }
        }
      //--- Append the second ray endpoint to close the polygon back toward P1
      polyX[nPts] = ebX; polyY[nPts] = ebY; nPts++;
      //--- Scanline rasterize the polygon with the even-odd rule
      int ymin = polyY[0], ymax = polyY[0];
      for(int k = 1; k < nPts; k++)
        {
         if(polyY[k] < ymin) ymin = polyY[k];
         if(polyY[k] > ymax) ymax = polyY[k];
        }
      //--- Clamp the vertical range to canvas bounds
      if(ymin < 0) ymin = 0;
      if(ymax >= cH) ymax = cH - 1;
      for(int yy = ymin; yy <= ymax; yy++)
        {
         //--- Collect intersection X values where this scanline crosses polygon edges
         double xs[16]; int nx = 0;
         for(int e = 0; e < nPts; e++)
           {
            //--- Identify the edge endpoints with wrap-around closure
            int e2 = (e + 1) % nPts;
            double ay = (double)polyY[e], by_ = (double)polyY[e2];
            //--- Skip edges that don't cross this scanline row
            if((ay > yy) == (by_ > yy)) continue;
            //--- Interpolate the intersection X at this row
            double ax = (double)polyX[e], bx_ = (double)polyX[e2];
            double tt = ((double)yy - ay) / (by_ - ay);
            if(nx < 16) xs[nx++] = ax + tt * (bx_ - ax);
           }
         //--- Need at least two intersections to span a row
         if(nx < 2) continue;
         //--- Sort intersection X values for paired span fill
         for(int a = 0; a < nx - 1; a++)
            for(int b = a + 1; b < nx; b++)
               if(xs[b] < xs[a]) { double tmp = xs[a]; xs[a] = xs[b]; xs[b] = tmp; }
         //--- Fill each span between paired intersections
         for(int p = 0; p + 1 < nx; p += 2)
           {
            //--- Snap span endpoints to integer columns
            int sxL = (int)MathCeil(xs[p]);
            int sxR = (int)MathFloor(xs[p + 1]);
            //--- Clamp the span to canvas horizontal bounds
            if(sxL < 0)   sxL = 0;
            if(sxR >= cW) sxR = cW - 1;
            //--- Paint each pixel in the span via the alpha-composited setter
            for(int xx = sxL; xx <= sxR; xx++)
               ChannelBlendPixelSet(canvas, xx, yy, fillArgb);
           }
        }
      prevVis = i;
     }
   //--- Draw the rays on top of the fills, gated by per-level visibility
   for(int i = 0; i < nLev; i++)
     {
      if(!lvlVisible[i]) continue;
      //--- Resolve per-level color, ARGB, thickness, and style
      const color lCol  = lvlColor[i];
      const uint  lArgb = ColorWithPercentOpacity(lCol, lvlOpacity[i]);
      const int   thick = (lvlWidth[i] > 0) ? lvlWidth[i] : 2;
      const int   style = lvlStyle[i];
      if(style == 0)
         DrawThickLine(canvas, x1, y1, endX[i], endY[i], thick, lArgb);
      else
        {
         //--- Styled-line path: build the dash pattern and dispatch with fallback
         int pat[]; const int pn = BuildLineStylePattern(style, thick, pat);
         if(pn > 0) WidgetDashedLineAA(canvas, x1, y1, endX[i], endY[i], thick, lArgb, pat);
         else       DrawThickLine(canvas, x1, y1, endX[i], endY[i], thick, lArgb);
        }
     }
   //--- Draw ratio labels at the crosshair through P2 per visible level
   for(int i = 0; i < nLev; i++)
     {
      if(!lvlVisible[i]) continue;
      //--- Read this level's ratio and rebuild its scaled direction vector
      const double r    = lvlRatio[i];
      const double dxR  = dxUnit;
      const double dyR  = dyUnit * r;
      int labX = x2, labY = y2;
      //--- Anchor the label on the horizontal or vertical P2 crosshair per ratio
      if(MathAbs(r - 1.0) < 0.001)
        {
         //--- Ratio == 1.0 (1/1 diagonal): label sits at P2 itself
         labX = x2 + 4;
         labY = y2 - 10;
        }
      else if(r > 1.0)
        {
         //--- Steep rays (r > 1): intersect the horizontal line y=y2
         if(MathAbs(dyR) > 1e-9)
           {
            //--- Solve for t at y=y2 and project the X coordinate
            double tt = (double)(y2 - y1) / dyR;
            labX = (int)MathRound((double)x1 + dxR * tt);
            labY = y2;
           }
         //--- Offset the anchor so the label sits above the crosshair intersection
         labX += 2;
         labY -= 12;
        }
      else
        {
         //--- Shallow rays (r < 1): intersect the vertical line x=x2
         if(MathAbs(dxR) > 1e-9)
           {
            //--- Solve for t at x=x2 and project the Y coordinate
            double tt = (double)(x2 - x1) / dxR;
            labX = x2;
            labY = (int)MathRound((double)y1 + dyR * tt);
           }
         //--- Offset the anchor so the label is vertically centered on the line
         const int gannLabelHalfH = 5;
         labX += 4;
         labY -= gannLabelHalfH;
        }
      //--- Build the label string: canonical Gann ratios use the "p/t" format
      string lbl = "";
      const double tol = 0.005;
      if(MathAbs(r - 8.0) < tol)              lbl = "8/1";
      else if(MathAbs(r - 4.0) < tol)         lbl = "4/1";
      else if(MathAbs(r - 3.0) < tol)         lbl = "3/1";
      else if(MathAbs(r - 2.0) < tol)         lbl = "2/1";
      else if(MathAbs(r - 1.0) < tol)         lbl = "1/1";
      else if(MathAbs(r - 0.5) < tol)         lbl = "1/2";
      else if(MathAbs(r - (1.0/3.0)) < tol)   lbl = "1/3";
      else if(MathAbs(r - 0.25) < tol)        lbl = "1/4";
      else if(MathAbs(r - 0.125) < tol)       lbl = "1/8";
      else
        {
         //--- Non-canonical ratio: format as decimal and strip trailing zeros
         lbl = DoubleToString(r, 3);
         while(StringLen(lbl) > 1
               && StringSubstr(lbl, StringLen(lbl) - 1, 1) == "0")
            lbl = StringSubstr(lbl, 0, StringLen(lbl) - 1);
         //--- Strip a trailing decimal point left after zero removal
         if(StringLen(lbl) > 0
            && StringSubstr(lbl, StringLen(lbl) - 1, 1) == ".")
            lbl = StringSubstr(lbl, 0, StringLen(lbl) - 1);
        }
      //--- Render the label at the computed position
      GannDrawLabel(canvas, lbl, labX, labY, lvlColor[i], 8);
     }
   //--- Draw 2 handles at P1 and P2 when selected or hovered
   if(selected || hovered)
     {
      if(m_hideHandleIdx != 0) DrawHandleOnCanvas(canvas, x1, y1, selected, objColor, m_haloHandleIdx == 0);
      if(m_hideHandleIdx != 1) DrawHandleOnCanvas(canvas, x2, y2, selected, objColor, m_haloHandleIdx == 1);
     }
  }

//+------------------------------------------------------------------+
//| Hit-test Gann Fan (cursor near any of the 9 rays)                |
//+------------------------------------------------------------------+
bool CChannelTools::HitTestGannFan(int mx, int my, int canvasW, int canvasH,
                                   int x1, int y1, int x2, int y2, int threshold)
  {
   //--- Derive the unit scale from the P1-P2 vector
   double dxUnit = (double)(x2 - x1);
   double dyUnit = (double)(y2 - y1);
   //--- Reject zero horizontal extent
   if(MathAbs(dxUnit) < 1e-6) return false;
   //--- Canonical Gann price-per-time and time-per-price ratios
   double ratios_p[9] = {8, 4, 3, 2, 1, 1, 1, 1, 1};
   double ratios_t[9] = {1, 1, 1, 1, 1, 2, 3, 4, 8};
   //--- Test cursor distance to each of the 9 extended rays
   for(int i = 0; i < 9; i++)
     {
      //--- Scale the unit vector by this level's price/time ratio
      double dxR = dxUnit * ratios_t[i];
      double dyR = dyUnit * ratios_p[i];
      //--- Extend the ray to the canvas edge and test cursor proximity
      int endX = 0, endY = 0;
      GannExtendRay(canvasW, canvasH, x1, y1, dxR, dyR, endX, endY);
      if(PointToSegmentDistance(mx, my, x1, y1, endX, endY) <= threshold) return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
//| Draw Gann Box: Fibonacci grid on both price and time axes        |
//+------------------------------------------------------------------+
void CChannelTools::DrawGannBoxOn(CCanvas &canvas,
                                  int x1, int y1, int x2, int y2,
                                  color objColor, bool selected, bool hovered,
                                  const double &lvlRatio[],
                                  const color  &lvlColor[],
                                  const int    &lvlOpacity[],
                                  const int    &lvlWidth[],
                                  const int    &lvlStyle[],
                                  const bool   &lvlVisible[],
                                  int fillOpacity)
  {
   //--- Normalize P1/P2 to canonical left/right and top/bottom corners
   const int xL = MathMin(x1, x2), xR = MathMax(x1, x2);
   const int yT = MathMin(y1, y2), yB = MathMax(y1, y2);
   //--- Reject boxes that are too small to render
   if(xR - xL < 2 || yB - yT < 2) return;
   const int nLev = ArraySize(lvlRatio);
   //--- Nothing to draw if no levels are defined
   if(nLev <= 0) return;
   //--- Pre-compute the Y pixel for each price-Fib level and X for each time-Fib level
   const int MAX_GBOX = 32;
   int fibY[]; ArrayResize(fibY, MAX_GBOX);
   int fibX[]; ArrayResize(fibX, MAX_GBOX);
   for(int i = 0; i < nLev; i++)
     {
      //--- Ratio 0 maps to the bottom; ratio 1 maps to the top
      fibY[i] = yB - (int)MathRound(lvlRatio[i] * (double)(yB - yT));
      fibX[i] = xL + (int)MathRound(lvlRatio[i] * (double)(xR - xL));
     }
   //--- Fill horizontal (price) bands between adjacent visible levels
   int prevVis = -1;
   for(int i = 0; i < nLev; i++)
     {
      if(!lvlVisible[i]) continue;
      if(prevVis >= 0)
        {
         //--- Clamp band top/bottom so fills don't invert on ratio ordering
         int yTop = fibY[i], yBot = fibY[prevVis];
         if(yTop > yBot) { int tmp = yTop; yTop = yBot; yBot = tmp; }
         //--- Compose the band fill ARGB and rasterize the quad
         const uint fArgb = ColorWithPercentOpacity(lvlColor[i], fillOpacity);
         ChannelFillQuad(canvas, xL, yTop, xR, yTop, xR, yBot, xL, yBot, fArgb);
        }
      prevVis = i;
     }
   //--- Fill vertical (time) bands at reduced opacity to avoid over-saturation
   const int vFillOp = (int)MathRound((double)fillOpacity * 0.55);
   prevVis = -1;
   for(int i = 0; i < nLev; i++)
     {
      if(!lvlVisible[i]) continue;
      if(prevVis >= 0)
        {
         //--- Clamp band left/right so fills don't invert on ratio ordering
         int xLeft = fibX[prevVis], xRight = fibX[i];
         if(xLeft > xRight) { int tmp = xLeft; xLeft = xRight; xRight = tmp; }
         //--- Compose the band fill ARGB at the reduced opacity and rasterize
         const uint fArgb = ColorWithPercentOpacity(lvlColor[i], vFillOp);
         ChannelFillQuad(canvas, xLeft, yT, xRight, yT, xRight, yB, xLeft, yB, fArgb);
        }
      prevVis = i;
     }
   //--- Draw horizontal and vertical Fib lines per visible level
   for(int i = 0; i < nLev; i++)
     {
      if(!lvlVisible[i]) continue;
      //--- Resolve per-level color, ARGB, thickness, and style
      const color lCol  = lvlColor[i];
      const uint  lArgb = ColorWithPercentOpacity(lCol, lvlOpacity[i]);
      const int   thick = (lvlWidth[i] > 0) ? lvlWidth[i] : 2;
      const int   style = lvlStyle[i];
      if(style == 0)
        {
         //--- Solid-line path: render horizontal and vertical Fib lines flat
         DrawThickLine(canvas, xL,      fibY[i], xR,      fibY[i], thick, lArgb);
         DrawThickLine(canvas, fibX[i], yT,      fibX[i], yB,      thick, lArgb);
        }
      else
        {
         //--- Styled-line path: build the dash pattern and dispatch
         int pat[]; const int pn = BuildLineStylePattern(style, thick, pat);
         if(pn > 0)
           {
            WidgetDashedLineAA(canvas, xL,      fibY[i], xR,      fibY[i], thick, lArgb, pat);
            WidgetDashedLineAA(canvas, fibX[i], yT,      fibX[i], yB,      thick, lArgb, pat);
           }
         else
           {
            //--- Fall back to solid lines if the pattern build fails
            DrawThickLine(canvas, xL,      fibY[i], xR,      fibY[i], thick, lArgb);
            DrawThickLine(canvas, fibX[i], yT,      fibX[i], yB,      thick, lArgb);
           }
        }
     }
   //--- Draw labels on all 4 sides of the box per visible level
   const int fontPx   = 8;
   const int labelGap = 7;
   const int glyphPadX = 3;
   TextSetFont("Arial", -(fontPx * 10));
   for(int i = 0; i < nLev; i++)
     {
      if(!lvlVisible[i]) continue;
      //--- Format the ratio as a decimal and strip trailing zeros
      string lbl = DoubleToString(lvlRatio[i], 3);
      while(StringLen(lbl) > 1
            && StringSubstr(lbl, StringLen(lbl) - 1, 1) == "0")
         lbl = StringSubstr(lbl, 0, StringLen(lbl) - 1);
      //--- Strip trailing decimal point if all fractional digits were removed
      if(StringLen(lbl) > 0
         && StringSubstr(lbl, StringLen(lbl) - 1, 1) == ".")
         lbl = StringSubstr(lbl, 0, StringLen(lbl) - 1);
      //--- Measure the label bounding box for placement math
      uint twU = 0, thU = 0;
      TextGetSize(lbl, twU, thU);
      const int tw = (int)twU, th = (int)thU;
      //--- Left price label: placed just outside the left edge
      const int lxLeft  = xL - (labelGap + glyphPadX) - tw;
      const int lyLeft  = fibY[i] - th / 2;
      GannDrawLabel(canvas, lbl, lxLeft, lyLeft, lvlColor[i], fontPx);
      //--- Right price label: placed just outside the right edge
      const int lxRight = xR + (labelGap + glyphPadX);
      const int lyRight = fibY[i] - th / 2;
      GannDrawLabel(canvas, lbl, lxRight, lyRight, lvlColor[i], fontPx);
      //--- Top time label: placed just above the top edge
      const int lxTop = fibX[i] - tw / 2;
      const int lyTop = yT - labelGap - th;
      GannDrawLabel(canvas, lbl, lxTop, lyTop, lvlColor[i], fontPx);
      //--- Bottom time label: placed just below the bottom edge
      const int lxBot = fibX[i] - tw / 2;
      const int lyBot = yB + labelGap;
      GannDrawLabel(canvas, lbl, lxBot, lyBot, lvlColor[i], fontPx);
     }
   //--- Draw 4 corner handles when selected or hovered
   if(selected || hovered)
     {
      if(m_hideHandleIdx != 0) DrawHandleOnCanvas(canvas, x1, y1, selected, objColor, m_haloHandleIdx == 0);
      if(m_hideHandleIdx != 1) DrawHandleOnCanvas(canvas, x2, y2, selected, objColor, m_haloHandleIdx == 1);
      if(m_hideHandleIdx != 2) DrawHandleOnCanvas(canvas, x1, y2, selected, objColor, m_haloHandleIdx == 2);
      if(m_hideHandleIdx != 3) DrawHandleOnCanvas(canvas, x2, y1, selected, objColor, m_haloHandleIdx == 3);
     }
  }

//+------------------------------------------------------------------+
//| Hit-test Gann Box (cursor near any outer edge or interior line)  |
//+------------------------------------------------------------------+
bool CChannelTools::HitTestGannBox(int mx, int my,
                                   int x1, int y1, int x2, int y2, int threshold)
  {
   //--- Normalize to canonical left/right and top/bottom corners
   int xL = MathMin(x1, x2), xR = MathMax(x1, x2);
   int yT = MathMin(y1, y2), yB = MathMax(y1, y2);
   //--- Reject boxes too small to have meaningful edges
   if(xR - xL < 2 || yB - yT < 2) return false;
   //--- Canonical Gann Box Fibonacci ratios (matching the draw path)
   double fibs[7] = {0.0, 0.25, 0.382, 0.5, 0.618, 0.75, 1.0};
   //--- Test all 7 horizontal (price) Fib lines
   for(int i = 0; i < 7; i++)
     {
      //--- Map this ratio to the Y pixel and test cursor proximity
      int ly = yB - (int)MathRound(fibs[i] * (double)(yB - yT));
      if(PointToSegmentDistance(mx, my, xL, ly, xR, ly) <= threshold) return true;
     }
   //--- Test all 7 vertical (time) Fib lines
   for(int i = 0; i < 7; i++)
     {
      //--- Map this ratio to the X pixel and test cursor proximity
      int lx = xL + (int)MathRound(fibs[i] * (double)(xR - xL));
      if(PointToSegmentDistance(mx, my, lx, yT, lx, yB) <= threshold) return true;
     }
   return false;
  }

#endif // TOOLS_PALETTE_CHANNELS_MQH
//+------------------------------------------------------------------+