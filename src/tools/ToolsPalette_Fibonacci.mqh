//+------------------------------------------------------------------+
//|                                       ToolsPalette_Fibonacci.mqh |
//|                           Copyright 2026, Allan Munene Mutiiria. |
//|                                   https://t.me/Forex_Algo_Trader |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Allan Munene Mutiiria."
#property link "https://t.me/Forex_Algo_Trader"
#property version "1.00"
#property strict

//--- Guard against multiple inclusion of this header
#ifndef TOOLS_PALETTE_FIBONACCI_MQH
#define TOOLS_PALETTE_FIBONACCI_MQH

//--- Pull in CChannelTools (the parent class in the tool chain)
#include "ToolsPalette_Channels.mqh"

//+------------------------------------------------------------------+
//| CFibonacciTools owns all 6 Fibonacci tool draw and hit-test paths|
//+------------------------------------------------------------------+
class CFibonacciTools : public CChannelTools
  {
protected:
   //--- Map a Fibonacci ratio to its canonical display color
   color   FibColorForLevel(double lvl) const;
   //--- Thin wrapper over GannDrawLabel for readable call sites
   void    FiboDrawLabel(CCanvas &canvas, const string text,
                          int anchorX, int anchorY, color textColor,
                          int fontPxSize = 8);
   //--- Parametric anti-aliased arc renderer (math convention, screen-Y flipped)
   void    FiboDrawArc(CCanvas &canvas, int cx, int cy, double radius,
                        double startAngle, double endAngle,
                        uint argb, int thickness);

public:
   //--- Fib Retracement: horizontal ratio lines between two price anchors
   void   DrawFibRetracementOn(CCanvas &canvas,
                                int x1, int y1, int x2, int y2,
                                color objColor, bool selected, bool hovered,
                                const double &lvlRatio[],
                                const color  &lvlColor[],
                                const int    &lvlOpacity[],
                                const int    &lvlWidth[],
                                const int    &lvlStyle[],
                                const bool   &lvlVisible[]);
   bool   HitTestFibRetracement(int mx, int my, int canvasW,
                                 int x1, int y1, int x2, int y2, int threshold);
   //--- Fib Expansion: 3-click; extensions project from P3 along the P1-P2 swing
   void   DrawFibExpansionOn(CCanvas &canvas,
                              int x1, int y1, int x2, int y2, int x3, int y3,
                              color objColor, bool selected, bool hovered,
                              const double &lvlRatio[],
                              const color  &lvlColor[],
                              const int    &lvlOpacity[],
                              const int    &lvlWidth[],
                              const int    &lvlStyle[],
                              const bool   &lvlVisible[]);
   bool   HitTestFibExpansion(int mx, int my, int canvasW,
                               int x1, int y1, int x2, int y2, int x3, int y3,
                               int threshold);
   //--- Fib Channel: 3-click parallel channel with Fib-ratio parallel lines
   void   DrawFibChannelOn(CCanvas &canvas,
                            int x1, int y1, int x2, int y2, int x3, int y3,
                            color objColor, bool selected, bool hovered,
                            const double &lvlRatio[],
                            const color  &lvlColor[],
                            const int    &lvlOpacity[],
                            const int    &lvlWidth[],
                            const int    &lvlStyle[],
                            const bool   &lvlVisible[]);
   bool   HitTestFibChannel(int mx, int my, int canvasW,
                             int x1, int y1, int x2, int y2, int x3, int y3,
                             int threshold);
   //--- Fib Time Zone: 2-click; vertical lines at Fibonacci integer multiples of P1-P2 X-delta
   void   DrawFibTimeZoneOn(CCanvas &canvas,
                             int x1, int y1, int x2, int y2,
                             color objColor, bool selected, bool hovered,
                             const double &lvlRatio[],
                             const color  &lvlColor[],
                             const int    &lvlOpacity[],
                             const int    &lvlWidth[],
                             const int    &lvlStyle[],
                             const bool   &lvlVisible[]);
   bool   HitTestFibTimeZone(int mx, int my, int canvasH,
                              int x1, int y1, int x2, int y2, int threshold);
   //--- Fib Speed Resistance Fan: 2-click; two ray families from P1 at Fib ratios
   void   DrawFibFanOn(CCanvas &canvas,
                        int x1, int y1, int x2, int y2,
                        color objColor, bool selected, bool hovered,
                        const double &lvlRatio[],
                        const color  &lvlColor[],
                        const int    &lvlOpacity[],
                        const int    &lvlWidth[],
                        const int    &lvlStyle[],
                        const bool   &lvlVisible[]);
   bool   HitTestFibFan(int mx, int my, int canvasW, int canvasH,
                         int x1, int y1, int x2, int y2, int threshold);
   //--- Fib Speed Resistance Arcs: 2-click; concentric semicircular arcs at Fib radii
   void   DrawFibArcsOn(CCanvas &canvas,
                         int x1, int y1, int x2, int y2,
                         color objColor, bool selected, bool hovered,
                         const double &lvlRatio[],
                         const color  &lvlColor[],
                         const int    &lvlOpacity[],
                         const int    &lvlWidth[],
                         const int    &lvlStyle[],
                         const bool   &lvlVisible[]);
   bool   HitTestFibArcs(int mx, int my,
                          int x1, int y1, int x2, int y2, int threshold);
  };

//+------------------------------------------------------------------+
//| Look up the canonical color for a given Fibonacci ratio          |
//+------------------------------------------------------------------+
color CFibonacciTools::FibColorForLevel(double lvl) const
  {
   //--- Match with a small epsilon so floating-point comparisons stay safe
   double eps = 1e-4;
   //--- 0 anchor: low-visibility gray (reference line)
   if(MathAbs(lvl - 0.0)   < eps) return clrGray;
   //--- 0.236: first pullback level, rendered red
   if(MathAbs(lvl - 0.236) < eps) return clrCrimson;
   //--- 0.382: weak retracement, rendered orange
   if(MathAbs(lvl - 0.382) < eps) return clrOrange;
   //--- 0.5: courtesy mid level (technically non-Fib), rendered yellow-green
   if(MathAbs(lvl - 0.5)   < eps) return clrGoldenrod;
   //--- 0.618: classical Fibonacci level, rendered sea green
   if(MathAbs(lvl - 0.618) < eps) return clrSeaGreen;
   //--- 0.786: deep retracement, rendered dark cyan
   if(MathAbs(lvl - 0.786) < eps) return clrDarkCyan;
   //--- 1.0 anchor: paired with the 0 anchor, rendered gray
   if(MathAbs(lvl - 1.0)   < eps) return clrGray;
   //--- 1.618: first extension (golden ratio), rendered dodger blue
   if(MathAbs(lvl - 1.618) < eps) return clrDodgerBlue;
   //--- 2.618: deeper extension, rendered medium orchid
   if(MathAbs(lvl - 2.618) < eps) return clrMediumOrchid;
   //--- 3.618: deeper extension, rendered blue violet
   if(MathAbs(lvl - 3.618) < eps) return clrBlueViolet;
   //--- 4.236: deep extension, rendered crimson
   if(MathAbs(lvl - 4.236) < eps) return clrCrimson;
   //--- 4.618: outer extension, rendered deep pink
   if(MathAbs(lvl - 4.618) < eps) return clrDeepPink;
   //--- Fallback for unrecognized ratios: the project's common dodger blue
   return clrDodgerBlue;
  }

//+------------------------------------------------------------------+
//| Render a label via the inherited 2-pass alpha-extraction routine |
//+------------------------------------------------------------------+
void CFibonacciTools::FiboDrawLabel(CCanvas &canvas, const string text,
                                     int anchorX, int anchorY, color textColor,
                                     int fontPxSize)
  {
   //--- Delegate to GannDrawLabel which owns the actual rendering technique
   GannDrawLabel(canvas, text, anchorX, anchorY, textColor, fontPxSize);
  }

//+------------------------------------------------------------------+
//| Trace an anti-aliased circular arc with optional 2px thickness   |
//+------------------------------------------------------------------+
void CFibonacciTools::FiboDrawArc(CCanvas &canvas, int cx, int cy, double radius,
                                   double startAngle, double endAngle,
                                   uint argb, int thickness)
  {
   //--- Reject degenerate radii below 0.5px
   if(radius < 0.5) return;
   //--- Cache canvas extents for bounds checks
   int cW = canvas.Width(), cH = canvas.Height();
   //--- Step size targets roughly one pixel of arc length per step
   double arcLen = MathAbs(endAngle - startAngle) * radius;
   int steps = (int)MathCeil(arcLen);
   //--- Clamp step count into a reasonable [8, 4000] range
   if(steps < 8) steps = 8;
   if(steps > 4000) steps = 4000;
   //--- Angular increment per step
   double da = (endAngle - startAngle) / (double)steps;
   //--- 2px thickness traces two offset circles; 1px traces just the centerline
   int passes = (thickness >= 2) ? 2 : 1;
   //--- Walk every step along the arc
   for(int s = 0; s <= steps; s++)
     {
      //--- Compute the arc-center point at this step in screen coords
      double a = startAngle + da * (double)s;
      double xCenter = (double)cx + radius * MathCos(a);
      double yCenter = (double)cy - radius * MathSin(a);
      //--- Render each thickness pass at the appropriate offset
      for(int p = 0; p < passes; p++)
        {
         //--- Offset along the tangent direction for 2px thickness
         double off = (passes == 1) ? 0.0 : (p == 0 ? -0.5 : 0.5);
         double xf = xCenter + off * MathCos(a);
         double yf = yCenter + off * (-MathSin(a));
         //--- Integer pixel position and fractional offsets for AA
         int ix = (int)MathFloor(xf), iy = (int)MathFloor(yf);
         double dx = xf - ix, dy = yf - iy;
         //--- 4-pixel bilinear coverage weights for clean anti-aliasing
         double covs[4] = { (1.0-dx)*(1.0-dy), dx*(1.0-dy), (1.0-dx)*dy, dx*dy };
         int    pxs[4]  = { ix, ix+1, ix, ix+1 };
         int    pys[4]  = { iy, iy, iy+1, iy+1 };
         //--- Blend each of the 4 pixels at its computed coverage weight
         for(int k = 0; k < 4; k++)
           {
            //--- Reject out-of-bounds samples
            int px = pxs[k], py = pys[k];
            if(px < 0 || px >= cW || py < 0 || py >= cH) continue;
            //--- Skip zero-coverage samples
            double cov = covs[k];
            if(cov <= 0.0) continue;
            //--- Unpack source ARGB components for compositing
            uchar srcA = (uchar)((argb >> 24) & 0xFF);
            uchar srcR = (uchar)((argb >> 16) & 0xFF);
            uchar srcG = (uchar)((argb >>  8) & 0xFF);
            uchar srcB = (uchar)( argb        & 0xFF);
            //--- Effective alpha = source alpha * coverage weight
            double effA = (double)srcA / 255.0 * cov;
            //--- Sample the existing destination pixel for Porter-Duff over compositing
            uint existing = canvas.PixelGet(px, py);
            double dA = ((existing >> 24) & 0xFF) / 255.0;
            //--- Output alpha via the standard source-over formula
            double oA = effA + dA * (1.0 - effA);
            if(oA <= 0.0) continue;
            //--- Unpack destination RGB components
            double dRf = ((existing >> 16) & 0xFF) / 255.0;
            double dGf = ((existing >>  8) & 0xFF) / 255.0;
            double dBf = ( existing        & 0xFF) / 255.0;
            //--- Normalize source RGB into floating-point
            double sRf = srcR / 255.0, sGf = srcG / 255.0, sBf = srcB / 255.0;
            //--- Compose final ARGB pixel via premultiplied source-over compositing
            uint outPix = ((uint)(uchar)(oA * 255.0 + 0.5) << 24) |
                          ((uint)(uchar)((sRf*effA + dRf*dA*(1.0-effA)) / oA * 255.0 + 0.5) << 16) |
                          ((uint)(uchar)((sGf*effA + dGf*dA*(1.0-effA)) / oA * 255.0 + 0.5) <<  8) |
                           (uint)(uchar)((sBf*effA + dBf*dA*(1.0-effA)) / oA * 255.0 + 0.5);
            canvas.PixelSet(px, py, outPix);
           }
        }
     }
  }

//+------------------------------------------------------------------+
//| Draw Fib Retracement - horizontal ratio lines + fill bands       |
//+------------------------------------------------------------------+
void CFibonacciTools::DrawFibRetracementOn(CCanvas &canvas,
                                            int x1, int y1, int x2, int y2,
                                            color objColor, bool selected, bool hovered,
                                            const double &lvlRatio[],
                                            const color  &lvlColor[],
                                            const int    &lvlOpacity[],
                                            const int    &lvlWidth[],
                                            const int    &lvlStyle[],
                                            const bool   &lvlVisible[])
  {
   //--- Reject empty level arrays
   const int nLev = ArraySize(lvlRatio);
   if(nLev <= 0) return;
   //--- Horizontal span strictly between P1 and P2 X-coordinates
   const int xL = MathMin(x1, x2);
   const int xR = MathMax(x1, x2);
   //--- Translucent fill bands between adjacent VISIBLE levels (30% alpha)
   const uchar bandAlpha = 77;
   int prevVisIdx = -1;
   for(int i = 0; i < nLev; i++)
     {
      //--- Skip hidden levels (also keeps the band loop walking visible-only pairs)
      if(!lvlVisible[i]) continue;
      //--- Render a band only after the first visible level has been recorded
      if(prevVisIdx >= 0)
        {
         //--- Top and bottom Y-coords of the band derived from level ratios
         const int ly1 = y1 + (int)MathRound((double)(y2 - y1) * lvlRatio[prevVisIdx]);
         const int ly2 = y1 + (int)MathRound((double)(y2 - y1) * lvlRatio[i]);
         //--- Band color uses the upper level's color at the fixed 30% alpha
         const uint fArgb = ColorToARGB(lvlColor[i], bandAlpha);
         //--- Normalize the Y-range (top < bottom in screen coords)
         const int yTop = MathMin(ly1, ly2);
         const int yBot = MathMax(ly1, ly2);
         //--- Render the fill band as an axis-aligned quad
         ChannelFillQuad(canvas, xL, yTop, xR, yTop, xR, yBot, xL, yBot, fArgb);
        }
      prevVisIdx = i;
     }
   //--- Draw each visible ratio line with its style + label
   for(int i = 0; i < nLev; i++)
     {
      //--- Skip hidden levels
      if(!lvlVisible[i]) continue;
      //--- Y-coord of this ratio line interpolated between P1 and P2
      const int   ly    = y1 + (int)MathRound((double)(y2 - y1) * lvlRatio[i]);
      //--- Cache per-level style attributes
      const color lCol  = lvlColor[i];
      const int   lOp   = lvlOpacity[i];
      const uint  lArgb = ColorWithPercentOpacity(lCol, lOp);
      const int   thick = (lvlWidth[i] > 0) ? lvlWidth[i] : 2;
      const int   style = lvlStyle[i];
      //--- Solid style 0 uses the thick-line primitive directly
      if(style == 0)
        {
         DrawThickLine(canvas, xL, ly, xR, ly, thick, lArgb);
        }
      else
        {
         //--- Dashed/dotted styles 1..3 build a stroke pattern and use the dashed AA path
         int pat[];
         const int pn = BuildLineStylePattern(style, thick, pat);
         if(pn > 0)
            WidgetDashedLineAA(canvas, xL, ly, xR, ly, thick, lArgb, pat);
         else
            //--- Fallback to solid when the pattern builder produced no segments
            DrawThickLine(canvas, xL, ly, xR, ly, thick, lArgb);
        }
      //--- Format the ratio for display, trimming trailing zeros and decimal point
      string lbl = DoubleToString(lvlRatio[i], 3);
      while(StringLen(lbl) > 1
            && StringSubstr(lbl, StringLen(lbl) - 1, 1) == "0")
         lbl = StringSubstr(lbl, 0, StringLen(lbl) - 1);
      if(StringLen(lbl) > 0
         && StringSubstr(lbl, StringLen(lbl) - 1, 1) == ".")
         lbl = StringSubstr(lbl, 0, StringLen(lbl) - 1);
      //--- Label sizing and gap constants
      const int fontPx    = 8;
      const int labelGap  = 7;
      const int glyphPadX = 3;
      //--- Apply the label font for the measurement pass
      TextSetFont("Arial", -(fontPx * 10));
      uint twU = 0, thU = 0;
      TextGetSize(lbl, twU, thU);
      const int tw = (int)twU, th = (int)thU;
      //--- Anchor the label to the LEFT of the line with vertical centering
      const int anchorX = xL - (labelGap + glyphPadX) - tw;
      const int anchorY = ly - th / 2;
      //--- Render the label via the 2-pass alpha-extraction helper
      FiboDrawLabel(canvas, lbl, anchorX, anchorY, lCol, fontPx);
     }
   //--- Dashed connector P1 -> P2 showing the swing the user anchored
   ChannelDrawDashedLine(canvas, x1, y1, x2, y2, ColorToARGB(clrDodgerBlue, 200));
   //--- 2 handles at the anchor points (with hide/halo state honored)
   if(selected || hovered)
     {
      if(m_hideHandleIdx != 0) DrawHandleOnCanvas(canvas, x1, y1, selected, objColor, m_haloHandleIdx == 0);
      if(m_hideHandleIdx != 1) DrawHandleOnCanvas(canvas, x2, y2, selected, objColor, m_haloHandleIdx == 1);
     }
  }

//+------------------------------------------------------------------+
//| Hit-test Fib Retracement - cursor near any horizontal ratio line |
//+------------------------------------------------------------------+
bool CFibonacciTools::HitTestFibRetracement(int mx, int my, int canvasW,
                                             int x1, int y1, int x2, int y2, int threshold)
  {
   //--- Canonical Fib Retracement levels for the hit-test (must match commit defaults)
   double levels[] = {0.0, 0.236, 0.382, 0.5, 0.618, 0.786, 1.0,
                      1.618, 2.618, 3.618, 4.236};
   int nLev = ArraySize(levels);
   //--- Restrict the hit zone to the P1-P2 X-range
   int xL = MathMin(x1, x2);
   int xR = MathMax(x1, x2);
   //--- Walk every level and test proximity to its horizontal line
   for(int i = 0; i < nLev; i++)
     {
      //--- Y-coord of this level interpolated between P1 and P2
      int ly = y1 + (int)MathRound((double)(y2 - y1) * levels[i]);
      if(PointToSegmentDistance(mx, my, xL, ly, xR, ly) <= threshold) return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
//| Draw Fib Expansion - extensions projected from P3 along the swing|
//+------------------------------------------------------------------+
void CFibonacciTools::DrawFibExpansionOn(CCanvas &canvas,
                                          int x1, int y1, int x2, int y2, int x3, int y3,
                                          color objColor, bool selected, bool hovered,
                                          const double &lvlRatio[],
                                          const color  &lvlColor[],
                                          const int    &lvlOpacity[],
                                          const int    &lvlWidth[],
                                          const int    &lvlStyle[],
                                          const bool   &lvlVisible[])
  {
   //--- Reject empty level arrays
   const int nLev = ArraySize(lvlRatio);
   if(nLev <= 0) return;
   //--- Swing vertical and horizontal deltas drive the projection from P3
   const double dy = (double)(y2 - y1);
   const int swingDx = x2 - x1;
   //--- Horizontal span of the extension lines mirrors the swing's X width starting at P3
   const int xL = MathMin(x3, x3 + swingDx);
   const int xR = MathMax(x3, x3 + swingDx);
   //--- Translucent fill bands between adjacent VISIBLE extension levels (30% alpha)
   const uchar bandAlpha = 77;
   int prevVisIdx = -1;
   for(int i = 0; i < nLev; i++)
     {
      //--- Skip hidden levels
      if(!lvlVisible[i]) continue;
      //--- Render a band only after the first visible level has been recorded
      if(prevVisIdx >= 0)
        {
         //--- Top and bottom Y-coords of the band projected from P3
         const int ly1 = y3 + (int)MathRound(dy * lvlRatio[prevVisIdx]);
         const int ly2 = y3 + (int)MathRound(dy * lvlRatio[i]);
         //--- Band color uses the upper level's color at the fixed 30% alpha
         const uint fArgb = ColorToARGB(lvlColor[i], bandAlpha);
         //--- Normalize the Y-range and render the fill quad
         const int yTop = MathMin(ly1, ly2);
         const int yBot = MathMax(ly1, ly2);
         ChannelFillQuad(canvas, xL, yTop, xR, yTop, xR, yBot, xL, yBot, fArgb);
        }
      prevVisIdx = i;
     }
   //--- Draw each visible extension line with its style + label
   for(int i = 0; i < nLev; i++)
     {
      //--- Skip hidden levels
      if(!lvlVisible[i]) continue;
      //--- Y-coord of this extension line projected from P3 along the swing
      const int   ly    = y3 + (int)MathRound(dy * lvlRatio[i]);
      //--- Cache per-level style attributes
      const color lCol  = lvlColor[i];
      const uint  lArgb = ColorWithPercentOpacity(lCol, lvlOpacity[i]);
      const int   thick = (lvlWidth[i] > 0) ? lvlWidth[i] : 2;
      const int   style = lvlStyle[i];
      //--- Solid style 0 uses the thick-line primitive directly
      if(style == 0) DrawThickLine(canvas, xL, ly, xR, ly, thick, lArgb);
      else
        {
         //--- Dashed styles build a stroke pattern; fall back to solid on empty pattern
         int pat[]; const int pn = BuildLineStylePattern(style, thick, pat);
         if(pn > 0) WidgetDashedLineAA(canvas, xL, ly, xR, ly, thick, lArgb, pat);
         else       DrawThickLine(canvas, xL, ly, xR, ly, thick, lArgb);
        }
      //--- Format the ratio for display, trimming trailing zeros and decimal point
      string lbl = DoubleToString(lvlRatio[i], 3);
      while(StringLen(lbl) > 1
            && StringSubstr(lbl, StringLen(lbl) - 1, 1) == "0")
         lbl = StringSubstr(lbl, 0, StringLen(lbl) - 1);
      if(StringLen(lbl) > 0
         && StringSubstr(lbl, StringLen(lbl) - 1, 1) == ".")
         lbl = StringSubstr(lbl, 0, StringLen(lbl) - 1);
      //--- Label sizing constants
      const int fontPx = 8, labelGap = 7, glyphPadX = 3;
      //--- Apply the label font for the measurement pass
      TextSetFont("Arial", -(fontPx * 10));
      uint twU = 0, thU = 0;
      TextGetSize(lbl, twU, thU);
      const int tw = (int)twU, th = (int)thU;
      //--- Anchor the label to the LEFT of the extension line with vertical centering
      const int anchorX = xL - (labelGap + glyphPadX) - tw;
      const int anchorY = ly - th / 2;
      FiboDrawLabel(canvas, lbl, anchorX, anchorY, lCol, fontPx);
     }
   //--- Dashed connectors showing the swing (P1->P2) and the retracement (P2->P3)
   const uint dashArgb = ColorToARGB(clrDodgerBlue, 200);
   ChannelDrawDashedLine(canvas, x1, y1, x2, y2, dashArgb);
   ChannelDrawDashedLine(canvas, x2, y2, x3, y3, dashArgb);
   //--- 3 handles at the anchor points (with hide/halo state honored)
   if(selected || hovered)
     {
      if(m_hideHandleIdx != 0) DrawHandleOnCanvas(canvas, x1, y1, selected, objColor, m_haloHandleIdx == 0);
      if(m_hideHandleIdx != 1) DrawHandleOnCanvas(canvas, x2, y2, selected, objColor, m_haloHandleIdx == 1);
      if(m_hideHandleIdx != 2) DrawHandleOnCanvas(canvas, x3, y3, selected, objColor, m_haloHandleIdx == 2);
     }
  }

//+------------------------------------------------------------------+
//| Hit-test Fib Expansion - cursor near any horizontal level line   |
//+------------------------------------------------------------------+
bool CFibonacciTools::HitTestFibExpansion(int mx, int my, int canvasW,
                                           int x1, int y1, int x2, int y2, int x3, int y3,
                                           int threshold)
  {
   //--- Canonical Fib Expansion levels (must match commit defaults)
   double levels[] = {0.0, 0.236, 0.382, 0.5, 0.618, 0.786, 1.0,
                      1.618, 2.618, 3.618, 4.236};
   int nLev = ArraySize(levels);
   //--- Swing deltas drive the projection from P3
   double dy = (double)(y2 - y1);
   int swingDx = x2 - x1;
   //--- Horizontal span of the extension lines mirrors the swing's X width starting at P3
   int xL = MathMin(x3, x3 + swingDx);
   int xR = MathMax(x3, x3 + swingDx);
   //--- Walk every level and test proximity to its horizontal extension line
   for(int i = 0; i < nLev; i++)
     {
      int ly = y3 + (int)MathRound(dy * levels[i]);
      if(PointToSegmentDistance(mx, my, xL, ly, xR, ly) <= threshold) return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
//| Draw Fib Channel - parallel lines at Fib ratios of the channel   |
//+------------------------------------------------------------------+
void CFibonacciTools::DrawFibChannelOn(CCanvas &canvas,
                                        int x1, int y1, int x2, int y2, int x3, int y3,
                                        color objColor, bool selected, bool hovered,
                                        const double &lvlRatio[],
                                        const color  &lvlColor[],
                                        const int    &lvlOpacity[],
                                        const int    &lvlWidth[],
                                        const int    &lvlStyle[],
                                        const bool   &lvlVisible[])
  {
   //--- Reject empty level arrays
   const int nLev = ArraySize(lvlRatio);
   if(nLev <= 0) return;
   //--- Offset vector from edge 0 (P1-P2 line) to edge 1 (line through P3)
   const double offX = (double)(x3 - x1);
   const double offY = (double)(y3 - y1);
   //--- Translucent fill bands between adjacent VISIBLE parallel levels (30% alpha)
   const uchar bandAlpha = 77;
   int prevVisIdx = -1;
   for(int i = 0; i < nLev; i++)
     {
      //--- Skip hidden levels
      if(!lvlVisible[i]) continue;
      //--- Render a band only after the first visible level has been recorded
      if(prevVisIdx >= 0)
        {
         //--- Endpoints of the previous-level line (left = P1+offset, right = P2+offset)
         const int aLx = x1 + (int)MathRound(offX * lvlRatio[prevVisIdx]);
         const int aLy = y1 + (int)MathRound(offY * lvlRatio[prevVisIdx]);
         const int aRx = x2 + (int)MathRound(offX * lvlRatio[prevVisIdx]);
         const int aRy = y2 + (int)MathRound(offY * lvlRatio[prevVisIdx]);
         //--- Endpoints of the current-level line
         const int bLx = x1 + (int)MathRound(offX * lvlRatio[i]);
         const int bLy = y1 + (int)MathRound(offY * lvlRatio[i]);
         const int bRx = x2 + (int)MathRound(offX * lvlRatio[i]);
         const int bRy = y2 + (int)MathRound(offY * lvlRatio[i]);
         //--- Band color uses the upper level's color at the fixed 30% alpha
         const uint fArgb = ColorToARGB(lvlColor[i], bandAlpha);
         //--- Render the band as a parallelogram (4 ordered corners)
         ChannelFillQuad(canvas, aLx, aLy, aRx, aRy, bRx, bRy, bLx, bLy, fArgb);
        }
      prevVisIdx = i;
     }
   //--- Draw each visible parallel ratio line + label
   for(int i = 0; i < nLev; i++)
     {
      //--- Skip hidden levels
      if(!lvlVisible[i]) continue;
      //--- Compute the two endpoints of this parallel line (parallel to P1-P2, offset by ratio)
      const int lLx = x1 + (int)MathRound(offX * lvlRatio[i]);
      const int lLy = y1 + (int)MathRound(offY * lvlRatio[i]);
      const int lRx = x2 + (int)MathRound(offX * lvlRatio[i]);
      const int lRy = y2 + (int)MathRound(offY * lvlRatio[i]);
      //--- Cache per-level style attributes
      const color lCol  = lvlColor[i];
      const uint  lArgb = ColorWithPercentOpacity(lCol, lvlOpacity[i]);
      const int   thick = (lvlWidth[i] > 0) ? lvlWidth[i] : 2;
      const int   style = lvlStyle[i];
      //--- Solid style 0 uses the thick-line primitive directly
      if(style == 0) DrawThickLine(canvas, lLx, lLy, lRx, lRy, thick, lArgb);
      else
        {
         //--- Dashed styles build a stroke pattern; fall back to solid on empty pattern
         int pat[]; const int pn = BuildLineStylePattern(style, thick, pat);
         if(pn > 0) WidgetDashedLineAA(canvas, lLx, lLy, lRx, lRy, thick, lArgb, pat);
         else       DrawThickLine(canvas, lLx, lLy, lRx, lRy, thick, lArgb);
        }
      //--- Anchor the label to whichever endpoint is the LEFT side in screen space
      const int leftEndX = (x1 <= x2) ? lLx : lRx;
      const int leftEndY = (x1 <= x2) ? lLy : lRy;
      //--- Format the ratio for display, trimming trailing zeros and decimal point
      string lbl = DoubleToString(lvlRatio[i], 3);
      while(StringLen(lbl) > 1
            && StringSubstr(lbl, StringLen(lbl) - 1, 1) == "0")
         lbl = StringSubstr(lbl, 0, StringLen(lbl) - 1);
      if(StringLen(lbl) > 0
         && StringSubstr(lbl, StringLen(lbl) - 1, 1) == ".")
         lbl = StringSubstr(lbl, 0, StringLen(lbl) - 1);
      //--- Label sizing constants
      const int fontPx = 8, labelGap = 7, glyphPadX = 3;
      //--- Apply the label font for the measurement pass
      TextSetFont("Arial", -(fontPx * 10));
      uint twU = 0, thU = 0;
      TextGetSize(lbl, twU, thU);
      const int tw = (int)twU, th = (int)thU;
      //--- Anchor the label to the left of the line's left endpoint
      const int anchorX = leftEndX - (labelGap + glyphPadX) - tw;
      const int anchorY = leftEndY - th / 2;
      FiboDrawLabel(canvas, lbl, anchorX, anchorY, lCol, fontPx);
     }
   //--- 3 handles at the anchor points (with hide/halo state honored)
   if(selected || hovered)
     {
      if(m_hideHandleIdx != 0) DrawHandleOnCanvas(canvas, x1, y1, selected, objColor, m_haloHandleIdx == 0);
      if(m_hideHandleIdx != 1) DrawHandleOnCanvas(canvas, x2, y2, selected, objColor, m_haloHandleIdx == 1);
      if(m_hideHandleIdx != 2) DrawHandleOnCanvas(canvas, x3, y3, selected, objColor, m_haloHandleIdx == 2);
     }
  }

//+------------------------------------------------------------------+
//| Hit-test Fib Channel - cursor near any parallel ratio line       |
//+------------------------------------------------------------------+
bool CFibonacciTools::HitTestFibChannel(int mx, int my, int canvasW,
                                         int x1, int y1, int x2, int y2, int x3, int y3,
                                         int threshold)
  {
   //--- Offset vector from edge 0 to edge 1 (P3 sets the opposite edge)
   double offX = (double)(x3 - x1);
   double offY = (double)(y3 - y1);
   //--- Canonical Fib Channel ratios (must match commit defaults)
   double ratios[] = {0.0, 0.382, 0.5, 0.618, 0.786, 1.0,
                      1.618, 2.618, 3.618, 4.236};
   int nLev = ArraySize(ratios);
   //--- Walk every ratio and test proximity to its parallel line bounded to the P1-P2 X-range
   for(int i = 0; i < nLev; i++)
     {
      int lLx = x1 + (int)MathRound(offX * ratios[i]);
      int lLy = y1 + (int)MathRound(offY * ratios[i]);
      int lRx = x2 + (int)MathRound(offX * ratios[i]);
      int lRy = y2 + (int)MathRound(offY * ratios[i]);
      if(PointToSegmentDistance(mx, my, lLx, lLy, lRx, lRy) <= threshold) return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
//| Draw Fib Time Zone - vertical lines at Fib multiples of P1-P2 X  |
//+------------------------------------------------------------------+
void CFibonacciTools::DrawFibTimeZoneOn(CCanvas &canvas,
                                         int x1, int y1, int x2, int y2,
                                         color objColor, bool selected, bool hovered,
                                         const double &lvlRatio[],
                                         const color  &lvlColor[],
                                         const int    &lvlOpacity[],
                                         const int    &lvlWidth[],
                                         const int    &lvlStyle[],
                                         const bool   &lvlVisible[])
  {
   //--- Cache canvas extents for bounds checks
   const int cW = canvas.Width(), cH = canvas.Height();
   //--- Unit interval width derived from P1-P2 X-delta; reject degenerate units
   const int unit = x2 - x1;
   if(MathAbs(unit) < 2) return;
   //--- Walk every level and render a vertical line at the Fib multiple of the unit
   const int nLev = ArraySize(lvlRatio);
   for(int i = 0; i < nLev; i++)
     {
      //--- Skip hidden levels
      if(!lvlVisible[i]) continue;
      //--- X-coord of this zone = P1.x + ratio * unit (ratios here are Fibonacci integers)
      const int lx = x1 + (int)MathRound(lvlRatio[i] * (double)unit);
      //--- Skip lines that would fall outside the visible canvas
      if(lx < 0 || lx >= cW) continue;
      //--- Cache per-level style attributes
      const color lCol  = lvlColor[i];
      const uint  lArgb = ColorWithPercentOpacity(lCol, lvlOpacity[i]);
      const int   thick = (lvlWidth[i] > 0) ? lvlWidth[i] : 2;
      const int   style = lvlStyle[i];
      //--- Solid style 0 uses the thick-line primitive directly
      if(style == 0)
         DrawThickLine(canvas, lx, 0, lx, cH - 1, thick, lArgb);
      else
        {
         //--- Dashed styles build a stroke pattern; fall back to solid on empty pattern
         int pat[]; const int pn = BuildLineStylePattern(style, thick, pat);
         if(pn > 0) WidgetDashedLineAA(canvas, lx, 0, lx, cH - 1, thick, lArgb, pat);
         else       DrawThickLine(canvas, lx, 0, lx, cH - 1, thick, lArgb);
        }
      //--- Format the ratio for display, trimming trailing zeros and decimal point
      string lbl = DoubleToString(lvlRatio[i], 3);
      while(StringLen(lbl) > 1
            && StringSubstr(lbl, StringLen(lbl) - 1, 1) == "0")
         lbl = StringSubstr(lbl, 0, StringLen(lbl) - 1);
      if(StringLen(lbl) > 0
         && StringSubstr(lbl, StringLen(lbl) - 1, 1) == ".")
         lbl = StringSubstr(lbl, 0, StringLen(lbl) - 1);
      //--- Apply the label font for the measurement pass
      const int fontPx = 8;
      TextSetFont("Arial", -(fontPx * 10));
      uint twU = 0, thU = 0;
      TextGetSize(lbl, twU, thU);
      const int tw = (int)twU, th = (int)thU;
      //--- Anchor the label near the bottom-right of each vertical zone line
      const int anchorX = lx + 3;
      const int anchorY = cH - th - 4;
      FiboDrawLabel(canvas, lbl, anchorX, anchorY, lCol, fontPx);
     }
   //--- Dashed connector P1 -> P2 showing the unit interval the user anchored
   ChannelDrawDashedLine(canvas, x1, y1, x2, y2,
                          ColorToARGB(clrDodgerBlue, 200));
   //--- 2 handles at the anchor points (with hide/halo state honored)
   if(selected || hovered)
     {
      if(m_hideHandleIdx != 0) DrawHandleOnCanvas(canvas, x1, y1, selected, objColor, m_haloHandleIdx == 0);
      if(m_hideHandleIdx != 1) DrawHandleOnCanvas(canvas, x2, y2, selected, objColor, m_haloHandleIdx == 1);
     }
  }

//+------------------------------------------------------------------+
//| Hit-test Fib Time Zone - cursor near any vertical zone line      |
//+------------------------------------------------------------------+
bool CFibonacciTools::HitTestFibTimeZone(int mx, int my, int canvasH,
                                          int x1, int y1, int x2, int y2, int threshold)
  {
   //--- Reject degenerate unit intervals
   int unit = x2 - x1;
   if(MathAbs(unit) < 2) return false;
   //--- Canonical Fibonacci integer sequence for the zones (must match commit defaults)
   int fibSeq[] = {0, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89};
   int nSeq = ArraySize(fibSeq);
   //--- Walk every Fibonacci index and test proximity to its vertical zone line
   for(int i = 0; i < nSeq; i++)
     {
      int lx = x1 + fibSeq[i] * unit;
      if(PointToSegmentDistance(mx, my, lx, 0, lx, canvasH - 1) <= threshold) return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
//| Draw Fib Speed Resistance Fan - dual ray families from P1 anchor |
//+------------------------------------------------------------------+
void CFibonacciTools::DrawFibFanOn(CCanvas &canvas,
                                    int x1, int y1, int x2, int y2,
                                    color objColor, bool selected, bool hovered,
                                    const double &lvlRatio[],
                                    const color  &lvlColor[],
                                    const int    &lvlOpacity[],
                                    const int    &lvlWidth[],
                                    const int    &lvlStyle[],
                                    const bool   &lvlVisible[])
  {
   //--- Cache canvas extents for ray extension and bounds checks
   int cW = canvas.Width(), cH = canvas.Height();
   //--- Reference rectangle deltas; reject degenerate references
   double dxRect = (double)(x2 - x1), dyRect = (double)(y2 - y1);
   if(MathAbs(dxRect) < 1.0 || MathAbs(dyRect) < 1.0) return;
   //--- Reject empty level arrays
   const int nLev = ArraySize(lvlRatio);
   if(nLev <= 0) return;
   //--- Normalized reference-rectangle corners for the inner grid
   int gxL = MathMin(x1, x2), gxR = MathMax(x1, x2);
   int gyT = MathMin(y1, y2), gyB = MathMax(y1, y2);
   //--- Precompute ray endpoint coords for both fan families (price + time)
   const int MAX_FAN = 32;
   int pEndX[];   ArrayResize(pEndX, MAX_FAN);
   int pEndY[];   ArrayResize(pEndY, MAX_FAN);
   int tEndX[];   ArrayResize(tEndX, MAX_FAN);
   int tEndY[];   ArrayResize(tEndY, MAX_FAN);
   //--- For every level, derive the ray endpoint on the two opposite walls
   for(int i = 0; i < nLev; i++)
     {
      //--- Inverted ratio (r=1 at P1, r=0 at P2) matches the visual convention
      double r  = lvlRatio[i];
      double ri = 1.0 - r;
      //--- PRICE family ray: from P1 through (x2, y1 + r*dyRect), extended to canvas edge
      double prdx = dxRect;
      double prdy = dyRect * ri;
      int prX = x2, prY = y1 + (int)MathRound(prdy);
      GannExtendRay(cW, cH, x1, y1, prdx, prdy, prX, prY);
      pEndX[i] = prX; pEndY[i] = prY;
      //--- TIME family ray: from P1 through (x1 + r*dxRect, y2), extended to canvas edge
      double trdx = dxRect * ri;
      double trdy = dyRect;
      int trX = x1 + (int)MathRound(trdx), trY = y2;
      GannExtendRay(cW, cH, x1, y1, trdx, trdy, trX, trY);
      tEndX[i] = trX; tEndY[i] = trY;
     }
   //--- Translucent wedge fills between adjacent rays for each family (30% alpha)
   uchar bandAlpha = 77;
   //--- Canvas corner table indexed clockwise from top-right: TR, BR, BL, TL
   int cornerPts[4][2] = { {cW - 1, 0}, {cW - 1, cH - 1}, {0, cH - 1}, {0, 0} };
   //--- Loop over the two ray families (0 = price, 1 = time)
   for(int fam = 0; fam < 2; fam++)
     {
      int prevVis = -1;
      //--- Walk every level looking for visible-pair bands
      for(int i = 0; i < nLev; i++)
        {
         //--- Skip hidden levels (still tracks them via the prevVis index logic below)
         if(!lvlVisible[i]) continue;
         //--- The first visible level seeds prevVis; subsequent visibles trigger band fills
         if(prevVis < 0) { prevVis = i; continue; }
         //--- Resolve the two ray endpoints for this family at the band's bounding levels
         int eaX, eaY, ebX, ebY;
         if(fam == 0) { eaX = pEndX[prevVis]; eaY = pEndY[prevVis]; ebX = pEndX[i]; ebY = pEndY[i]; }
         else         { eaX = tEndX[prevVis]; eaY = tEndY[prevVis]; ebX = tEndX[i]; ebY = tEndY[i]; }
         //--- Band fill color uses the upper-level color at the fixed 30% alpha
         color bandCol = lvlColor[i];
         uint  fArgb   = ColorToARGB(bandCol, bandAlpha);
         //--- Classify which canvas edge each ray endpoint lands on (0=top, 1=right, 2=bottom, 3=left)
         int edgeA = 3, edgeB = 3;
         if(eaY <= 0)            edgeA = 0;
         else if(eaX >= cW - 1)  edgeA = 1;
         else if(eaY >= cH - 1)  edgeA = 2;
         else                    edgeA = 3;
         if(ebY <= 0)            edgeB = 0;
         else if(ebX >= cW - 1)  edgeB = 1;
         else if(ebY >= cH - 1)  edgeB = 2;
         else                    edgeB = 3;
         //--- Determine the winding direction of the wedge via the cross product
         double aDx = (double)(eaX - x1), aDy = (double)(eaY - y1);
         double bDx = (double)(ebX - x1), bDy = (double)(ebY - y1);
         double cross = aDx * bDy - aDy * bDx;
         //--- step=+1 walks corners CW; step=+3 walks CCW (mod 4 equivalent)
         int step = (cross >= 0.0) ? 1 : 3;
         //--- Build the wedge polygon: anchor P1, ray-end A, corner(s) along the boundary, ray-end B
         int polyX[8], polyY[8];
         int nPts = 0;
         polyX[nPts] = x1;  polyY[nPts] = y1;  nPts++;
         polyX[nPts] = eaX; polyY[nPts] = eaY; nPts++;
         //--- Insert corner vertices when the two endpoints land on different canvas edges
         if(edgeA != edgeB)
           {
            int e = edgeA;
            int guard = 0;
            //--- Step through canvas corners until we reach edge B (guard caps at 4 corners)
            while(e != edgeB && guard < 4)
              {
               //--- For each edge transition, append the next canvas corner along the winding
               int cIdx = (step == 1) ? e : ((e + 3) % 4);
               polyX[nPts] = cornerPts[cIdx][0];
               polyY[nPts] = cornerPts[cIdx][1];
               nPts++;
               e = (e + step) % 4;
               guard++;
              }
           }
         //--- Final vertex closes the wedge at ray-end B
         polyX[nPts] = ebX; polyY[nPts] = ebY; nPts++;
         //--- Find the Y-range of the wedge polygon for the scanline fill loop
         int ymin = polyY[0], ymax = polyY[0];
         for(int k = 1; k < nPts; k++)
           {
            if(polyY[k] < ymin) ymin = polyY[k];
            if(polyY[k] > ymax) ymax = polyY[k];
           }
         //--- Clamp Y-range to canvas bounds
         if(ymin < 0) ymin = 0;
         if(ymax >= cH) ymax = cH - 1;
         //--- Scanline fill: for each Y, intersect with each polygon edge and fill spans
         for(int yy = ymin; yy <= ymax; yy++)
           {
            double xs[16]; int nx = 0;
            //--- Compute the X intersection for every edge that crosses this Y
            for(int e = 0; e < nPts; e++)
              {
               int e2 = (e + 1) % nPts;
               double ay = (double)polyY[e], by_ = (double)polyY[e2];
               //--- Skip edges that don't straddle this Y
               if((ay > yy) == (by_ > yy)) continue;
               //--- Linear interpolate the X at scanline Y
               double ax = (double)polyX[e], bx_ = (double)polyX[e2];
               double tt = ((double)yy - ay) / (by_ - ay);
               if(nx < 16) xs[nx++] = ax + tt * (bx_ - ax);
              }
            //--- Need at least 2 X crossings to form a fill span
            if(nx < 2) continue;
            //--- Sort X crossings ascending using a tiny bubble sort
            for(int a = 0; a < nx - 1; a++)
               for(int b = a + 1; b < nx; b++)
                  if(xs[b] < xs[a]) { double tmp = xs[a]; xs[a] = xs[b]; xs[b] = tmp; }
            //--- Fill spans between consecutive crossing pairs
            for(int p = 0; p + 1 < nx; p += 2)
              {
               int sxL = (int)MathCeil(xs[p]);
               int sxR = (int)MathFloor(xs[p + 1]);
               //--- Clamp span endpoints to canvas bounds
               if(sxL < 0)   sxL = 0;
               if(sxR >= cW) sxR = cW - 1;
               //--- Apply alpha-blended pixel set across the span
               for(int xx = sxL; xx <= sxR; xx++)
                  ChannelBlendPixelSet(canvas, xx, yy, fArgb);
              }
           }
         //--- Advance to the next band's lower bound
         prevVis = i;
        }
     }
   //--- 1px reference-rectangle grid: faint horizontal + vertical lines at each visible ratio
   uint gridArgb = ColorToARGB(clrGray, 100);
   for(int i = 0; i < nLev; i++)
     {
      //--- Skip hidden levels
      if(!lvlVisible[i]) continue;
      //--- Inverted ratio matches the ray endpoint convention
      double ri = 1.0 - lvlRatio[i];
      //--- Horizontal grid line at this ratio's Y inside the reference rectangle
      int hy = y1 + (int)MathRound(dyRect * ri);
      DrawThickLine(canvas, gxL, hy, gxR, hy, 1, gridArgb);
      //--- Vertical grid line at this ratio's X inside the reference rectangle
      int vx = x1 + (int)MathRound(dxRect * ri);
      DrawThickLine(canvas, vx, gyT, vx, gyB, 1, gridArgb);
     }
   //--- Draw the two ray families on top of the wedge fills + grid
   for(int i = 0; i < nLev; i++)
     {
      //--- Skip hidden levels
      if(!lvlVisible[i]) continue;
      //--- Cache per-level style attributes
      const color lCol  = lvlColor[i];
      const uint  lArgb = ColorWithPercentOpacity(lCol, lvlOpacity[i]);
      const int   thick = (lvlWidth[i] > 0) ? lvlWidth[i] : 2;
      const int   style = lvlStyle[i];
      //--- Solid style 0 uses the thick-line primitive directly for both rays
      if(style == 0)
        {
         DrawThickLine(canvas, x1, y1, pEndX[i], pEndY[i], thick, lArgb);
         DrawThickLine(canvas, x1, y1, tEndX[i], tEndY[i], thick, lArgb);
        }
      else
        {
         //--- Dashed styles build a stroke pattern and use the dashed AA path for both rays
         int pat[]; const int pn = BuildLineStylePattern(style, thick, pat);
         if(pn > 0)
           {
            WidgetDashedLineAA(canvas, x1, y1, pEndX[i], pEndY[i], thick, lArgb, pat);
            WidgetDashedLineAA(canvas, x1, y1, tEndX[i], tEndY[i], thick, lArgb, pat);
           }
         else
           {
            //--- Fallback to solid when the pattern builder produced no segments
            DrawThickLine(canvas, x1, y1, pEndX[i], pEndY[i], thick, lArgb);
            DrawThickLine(canvas, x1, y1, tEndX[i], tEndY[i], thick, lArgb);
           }
        }
     }
   //--- Labels on all four sides of the reference rectangle
   int fontPx    = 8;
   int labelGap  = 7;
   int glyphPadX = 3;
   TextSetFont("Arial", -(fontPx * 10));
   //--- Walk every level and emit four labels (left, right, top, bottom of the rectangle)
   for(int i = 0; i < nLev; i++)
     {
      //--- Skip hidden levels
      if(!lvlVisible[i]) continue;
      //--- Cache the level color for label rendering
      const color lCol = lvlColor[i];
      //--- Format the ratio for display, trimming trailing zeros and decimal point
      string lbl = DoubleToString(lvlRatio[i], 3);
      while(StringLen(lbl) > 1
            && StringSubstr(lbl, StringLen(lbl) - 1, 1) == "0")
         lbl = StringSubstr(lbl, 0, StringLen(lbl) - 1);
      if(StringLen(lbl) > 0
         && StringSubstr(lbl, StringLen(lbl) - 1, 1) == ".")
         lbl = StringSubstr(lbl, 0, StringLen(lbl) - 1);
      //--- Measure the label so each side can position it correctly
      uint twU = 0, thU = 0;
      TextGetSize(lbl, twU, thU);
      int tw = (int)twU, th = (int)thU;
      //--- Compute the horizontal-line Y at this ratio (inverted convention)
      double ri = 1.0 - lvlRatio[i];
      int hy = y1 + (int)MathRound(dyRect * ri);
      //--- LEFT-side label sits outside the rectangle on the left
      FiboDrawLabel(canvas, lbl,
                     gxL - (labelGap + glyphPadX) - tw,
                     hy - th / 2, lCol, fontPx);
      //--- RIGHT-side label sits outside the rectangle on the right
      FiboDrawLabel(canvas, lbl,
                     gxR + (labelGap + glyphPadX),
                     hy - th / 2, lCol, fontPx);
      //--- Compute the vertical-line X at this ratio for the top/bottom labels
      int vx = x1 + (int)MathRound(dxRect * ri);
      //--- TOP-side label sits above the rectangle, horizontally centered on the vertical line
      FiboDrawLabel(canvas, lbl,
                     vx - tw / 2,
                     gyT - labelGap - th, lCol, fontPx);
      //--- BOTTOM-side label sits below the rectangle, horizontally centered on the vertical line
      FiboDrawLabel(canvas, lbl,
                     vx - tw / 2,
                     gyB + labelGap, lCol, fontPx);
     }
   //--- 2 handles at the anchor points (with hide/halo state honored)
   if(selected || hovered)
     {
      if(m_hideHandleIdx != 0) DrawHandleOnCanvas(canvas, x1, y1, selected, objColor, m_haloHandleIdx == 0);
      if(m_hideHandleIdx != 1) DrawHandleOnCanvas(canvas, x2, y2, selected, objColor, m_haloHandleIdx == 1);
     }
  }

//+------------------------------------------------------------------+
//| Hit-test Fib Fan - cursor near any price-ray or time-ray         |
//+------------------------------------------------------------------+
bool CFibonacciTools::HitTestFibFan(int mx, int my, int canvasW, int canvasH,
                                     int x1, int y1, int x2, int y2, int threshold)
  {
   //--- Reference rectangle deltas; reject degenerate references
   double dxRect = (double)(x2 - x1), dyRect = (double)(y2 - y1);
   if(MathAbs(dxRect) < 1.0 || MathAbs(dyRect) < 1.0) return false;
   //--- Canonical Fib Fan ratios (must match commit defaults)
   double ratios[] = {0.0, 0.25, 0.382, 0.5, 0.618, 0.75, 1.0};
   int nLev = ArraySize(ratios);
   //--- Walk every ratio and test proximity to both the price ray and the time ray
   for(int i = 0; i < nLev; i++)
     {
      //--- Inverted ratio matches the draw convention (r=1 at P1, r=0 at P2)
      double ri = 1.0 - ratios[i];
      //--- Price ray endpoint at (x2, y1 + ri*dyRect), then extended to the canvas edge
      double pyEnd = (double)y1 + dyRect * ri;
      double prdx = (double)x2 - (double)x1, prdy = pyEnd - (double)y1;
      int prX = 0, prY = 0;
      GannExtendRay(canvasW, canvasH, x1, y1, prdx, prdy, prX, prY);
      if(PointToSegmentDistance(mx, my, x1, y1, prX, prY) <= threshold) return true;
      //--- Time ray endpoint at (x1 + ri*dxRect, y2), then extended to the canvas edge
      double txEnd = (double)x1 + dxRect * ri;
      double trdx = txEnd - (double)x1, trdy = (double)y2 - (double)y1;
      int trX = 0, trY = 0;
      GannExtendRay(canvasW, canvasH, x1, y1, trdx, trdy, trX, trY);
      if(PointToSegmentDistance(mx, my, x1, y1, trX, trY) <= threshold) return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
//| Draw Fib Speed Resistance Arcs - concentric semicircles at radii |
//+------------------------------------------------------------------+
void CFibonacciTools::DrawFibArcsOn(CCanvas &canvas,
                                     int x1, int y1, int x2, int y2,
                                     color objColor, bool selected, bool hovered,
                                     const double &lvlRatio[],
                                     const color  &lvlColor[],
                                     const int    &lvlOpacity[],
                                     const int    &lvlWidth[],
                                     const int    &lvlStyle[],
                                     const bool   &lvlVisible[])
  {
   //--- Base radius derived from P1-P2 Euclidean distance; reject degenerate radii
   double dx = (double)(x2 - x1), dy = (double)(y2 - y1);
   double baseR = MathSqrt(dx*dx + dy*dy);
   if(baseR < 2.0) return;
   //--- Reject empty level arrays
   const int nLev = ArraySize(lvlRatio);
   if(nLev <= 0) return;
   //--- Arc spans the upper semicircle: from 0 (east) to pi (west) in math-up convention
   const double startA = 0.0;
   const double endA   = 3.14159265358979;
   //--- Cache canvas extents for bounds checks
   int cW = canvas.Width(), cH = canvas.Height();
   //--- 30% fill alpha for the inner disc and the annular bands
   const uchar bandAlpha = 77;
   //--- Inner-disc fill: the region inside the smallest visible arc gets one solid fill
   int firstVis = -1;
   for(int i = 0; i < nLev; i++) if(lvlVisible[i]) { firstVis = i; break; }
   if(firstVis >= 0)
     {
      //--- Inner radius and its square for the scanline fill
      double rInner  = lvlRatio[firstVis] * baseR;
      double rInner2 = rInner * rInner;
      //--- Use the inner level's color at the fixed 30% alpha
      color  innerCol = lvlColor[firstVis];
      uint   iArgb    = ColorToARGB(innerCol, bandAlpha);
      //--- Restrict fill to the upper semicircle (yTop above center, yBot at center)
      int yTop = y1 - (int)MathCeil(rInner);
      int yBot = y1;
      //--- Clamp Y-range to canvas bounds
      if(yTop < 0) yTop = 0;
      if(yBot > cH - 1) yBot = cH - 1;
      //--- Scanline fill: for each Y, the disc spans [center-half, center+half]
      for(int yy = yTop; yy <= yBot; yy++)
        {
         double dyC = (double)(yy - y1);
         //--- Disc equation: x^2 = rInner^2 - dyC^2; skip when out of disc
         double inVal = rInner2 - dyC * dyC;
         if(inVal <= 0.0) continue;
         double halfIn = MathSqrt(inVal);
         //--- Fill span endpoints clamped to canvas bounds
         int xL = (int)MathCeil ((double)x1 - halfIn);
         int xR = (int)MathFloor((double)x1 + halfIn);
         if(xL < 0) xL = 0;
         if(xR >= cW) xR = cW - 1;
         //--- Apply alpha-blended pixel set across the disc span
         for(int xx = xL; xx <= xR; xx++)
            ChannelBlendPixelSet(canvas, xx, yy, iArgb);
        }
     }
   //--- Annular fills between consecutive visible arcs (30% alpha bands)
   int prevVis = firstVis;
   //--- Start from firstVis+1; if no visibles exist, the loop never runs
   for(int i = (firstVis < 0) ? nLev : firstVis + 1; i < nLev; i++)
     {
      //--- Skip hidden levels (still advance through them looking for the next visible)
      if(!lvlVisible[i]) continue;
      //--- Inner and outer radii of this annular band (and their squares)
      double rIn  = lvlRatio[prevVis] * baseR;
      double rOut = lvlRatio[i]       * baseR;
      double rIn2 = rIn * rIn, rOut2 = rOut * rOut;
      //--- Use the outer level's color at the fixed 30% alpha
      color  bandCol = lvlColor[i];
      uint   fArgb   = ColorToARGB(bandCol, bandAlpha);
      //--- Restrict fill to the upper semicircle
      int yTop = y1 - (int)MathCeil(rOut);
      int yBot = y1;
      //--- Clamp Y-range to canvas bounds
      if(yTop < 0) yTop = 0;
      if(yBot > cH - 1) yBot = cH - 1;
      //--- Scanline fill: each Y has two horizontal spans (left + right of the inner disc hole)
      for(int yy = yTop; yy <= yBot; yy++)
        {
         double dyC = (double)(yy - y1);
         double dyC2 = dyC * dyC;
         //--- Skip scanlines that fall outside the outer arc
         double outVal = rOut2 - dyC2;
         if(outVal <= 0.0) continue;
         double halfOut = MathSqrt(outVal);
         //--- Inner half-extent; 0 means the scanline misses the inner disc entirely
         double innerVal = rIn2 - dyC2;
         double halfIn  = (innerVal > 0.0) ? MathSqrt(innerVal) : 0.0;
         //--- Left fill span goes from outer-left to inner-left (or to outer-right when no inner)
         int xL1 = (int)MathCeil ((double)x1 - halfOut);
         int xR1 = (int)MathFloor((double)x1 - halfIn);
         if(halfIn == 0.0) xR1 = (int)MathFloor((double)x1 + halfOut);
         //--- Right fill span goes from inner-right to outer-right (only when inner exists)
         int xL2 = (int)MathCeil ((double)x1 + halfIn);
         int xR2 = (int)MathFloor((double)x1 + halfOut);
         if(halfIn == 0.0)
           {
            //--- No inner hole: single full-width fill
            if(xL1 < 0) xL1 = 0;
            if(xR1 >= cW) xR1 = cW - 1;
            for(int xx = xL1; xx <= xR1; xx++)
               ChannelBlendPixelSet(canvas, xx, yy, fArgb);
           }
         else
           {
            //--- Inner hole exists: render the left span first
            if(xL1 < 0) xL1 = 0;
            if(xR1 >= cW) xR1 = cW - 1;
            for(int xx = xL1; xx <= xR1; xx++)
               ChannelBlendPixelSet(canvas, xx, yy, fArgb);
            //--- Then the right span (clamped to canvas)
            if(xL2 < 0) xL2 = 0;
            if(xR2 >= cW) xR2 = cW - 1;
            for(int xx = xL2; xx <= xR2; xx++)
               ChannelBlendPixelSet(canvas, xx, yy, fArgb);
           }
        }
      //--- Advance to the next band's lower bound
      prevVis = i;
     }
   //--- Draw the arc strokes on top of the fills plus their labels
   for(int i = 0; i < nLev; i++)
     {
      //--- Skip hidden levels
      if(!lvlVisible[i]) continue;
      //--- Radius in pixels for this arc
      double rPx  = lvlRatio[i] * baseR;
      //--- Cache per-level style attributes
      const color lCol  = lvlColor[i];
      const uint  lArgb = ColorWithPercentOpacity(lCol, lvlOpacity[i]);
      const int   thick = (lvlWidth[i] > 0) ? lvlWidth[i] : 2;
      //--- Parametric arcs don't support dashed styles; styles 1-3 fall back to solid here
      FiboDrawArc(canvas, x1, y1, rPx, startA, endA, lArgb, thick);
      //--- Format the ratio for display, trimming trailing zeros and decimal point
      string lbl = DoubleToString(lvlRatio[i], 3);
      while(StringLen(lbl) > 1
            && StringSubstr(lbl, StringLen(lbl) - 1, 1) == "0")
         lbl = StringSubstr(lbl, 0, StringLen(lbl) - 1);
      if(StringLen(lbl) > 0
         && StringSubstr(lbl, StringLen(lbl) - 1, 1) == ".")
         lbl = StringSubstr(lbl, 0, StringLen(lbl) - 1);
      //--- Apply the label font for the measurement pass
      const int fontPx = 8;
      TextSetFont("Arial", -(fontPx * 10));
      uint twU = 0, thU = 0;
      TextGetSize(lbl, twU, thU);
      const int tw = (int)twU, th = (int)thU;
      //--- Anchor the label directly above each arc's apex
      const int anchorX = x1 - tw / 2;
      const int anchorY = y1 - (int)MathRound(rPx) - th - 2;
      FiboDrawLabel(canvas, lbl, anchorX, anchorY, lCol, fontPx);
     }
   //--- Dashed connector P1 -> P2 showing the base-radius direction
   ChannelDrawDashedLine(canvas, x1, y1, x2, y2,
                          ColorToARGB(clrDodgerBlue, 200));
   //--- 2 handles at the anchor points (with hide/halo state honored)
   if(selected || hovered)
     {
      if(m_hideHandleIdx != 0) DrawHandleOnCanvas(canvas, x1, y1, selected, objColor, m_haloHandleIdx == 0);
      if(m_hideHandleIdx != 1) DrawHandleOnCanvas(canvas, x2, y2, selected, objColor, m_haloHandleIdx == 1);
     }
  }

//+------------------------------------------------------------------+
//| Hit-test Fib Arcs - cursor within threshold of any semicircle    |
//+------------------------------------------------------------------+
bool CFibonacciTools::HitTestFibArcs(int mx, int my,
                                      int x1, int y1, int x2, int y2, int threshold)
  {
   //--- Base radius derived from P1-P2 Euclidean distance; reject degenerate radii
   double dx = (double)(x2 - x1), dy = (double)(y2 - y1);
   double baseR = MathSqrt(dx*dx + dy*dy);
   if(baseR < 2.0) return false;
   //--- Arcs span only the upper semicircle, so cursor Y must be at or above center Y
   if(my > y1) return false;
   //--- Cursor distance to the arc center
   double distCtr = MathSqrt((double)((mx - x1) * (mx - x1) + (my - y1) * (my - y1)));
   //--- Canonical Fib Arcs radii (must match commit defaults)
   double radii[] = {0.236, 0.382, 0.5, 0.618, 0.786, 1.0,
                     1.618, 2.618, 3.618, 4.236, 4.618};
   int nLev = ArraySize(radii);
   //--- Walk every radius and test cursor's distance-to-center against radius +/- threshold
   for(int i = 0; i < nLev; i++)
     {
      double rPx = radii[i] * baseR;
      if(MathAbs(distCtr - rPx) <= (double)threshold) return true;
     }
   return false;
  }

#endif // TOOLS_PALETTE_FIBONACCI_MQH
//+------------------------------------------------------------------+