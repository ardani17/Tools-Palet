//+------------------------------------------------------------------+
//|                                          ToolsPalette_Shapes.mqh |
//|                                            Copyright 2026, Om J. |
//|                                               https://t.me/HZFXI |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Om J."
#property link "https://t.me/HZFXI"
#property version "1.00"
#property strict

//--- Guard against multiple inclusion of this header
#ifndef TOOLS_PALETTE_SHAPES_MQH
#define TOOLS_PALETTE_SHAPES_MQH

//--- Pull in CFibonacciTools (the parent class in the tool chain)
#include "ToolsPalette_Fibonacci.mqh"

//+------------------------------------------------------------------+
//| CShapeTools owns the geometric shape drawing and hit-test paths  |
//+------------------------------------------------------------------+
class CShapeTools : public CFibonacciTools
  {
public:
   //--- Rectangle: 2 stored anchors (opposite corners) + 8 derived handles
   void   DrawRectangleOn(CCanvas &canvas, int x1, int y1, int x2, int y2,
                           color objColor, bool selected, bool hovered,
                           int lineWidth = 2, int lineOpacity = 100,
                           int lineStyle = 0,
                           color fillColor = clrNONE, int fillOpacity = 30);

   //--- Triangle: 3 vertex anchors (P1, P2, P3); each handle drags one vertex
   void   DrawTriangleOn(CCanvas &canvas,
                          int x1, int y1, int x2, int y2, int x3, int y3,
                          color objColor, bool selected, bool hovered,
                          int lineWidth = 2, int lineOpacity = 100,
                          int lineStyle = 0,
                          color fillColor = clrNONE, int fillOpacity = 30);
   bool   HitTestTriangle(int mx, int my,
                           int x1, int y1, int x2, int y2, int x3, int y3,
                           int threshold);
   //--- Sign-of-cross-product point-in-triangle test (helper for HitTestTriangle)
   bool   HitTestTriangleInside(int mx, int my,
                                 int x1, int y1, int x2, int y2, int x3, int y3);

   //--- Rotated Ellipse: P1, P2 = major-axis endpoints; P3 sets perpendicular semi-minor distance
   void   DrawEllipseOn(CCanvas &canvas, int x1, int y1, int x2, int y2, int x3, int y3,
                         color objColor, bool selected, bool hovered,
                         int lineWidth = 2, int lineOpacity = 100,
                         int lineStyle = 0,
                         color fillColor = clrNONE, int fillOpacity = 30);
   bool   HitTestEllipseRotated(int mx, int my,
                                 int x1, int y1, int x2, int y2, int x3, int y3,
                                 int threshold);

   //--- Compute the 6 handle positions for the rotated rectangle (canonical TL/TR/BR/BL order)
   void   ComputeRotatedRectHandles(int x1, int y1, int x2, int y2, int x3, int y3,
                                     int &outX[], int &outY[]);
   //--- Rotated Rectangle: P1-P2 sets the length/axis; P3 inflates the perpendicular width
   void   DrawRotatedRectangleOn(CCanvas &canvas,
                                  int x1, int y1, int x2, int y2, int x3, int y3,
                                  color objColor, bool selected, bool hovered,
                                  int lineWidth = 2, int lineOpacity = 100,
                                  int lineStyle = 0,
                                  color fillColor = clrNONE, int fillOpacity = 30);
   bool   HitTestRotatedRectangle(int mx, int my,
                                   int x1, int y1, int x2, int y2, int x3, int y3,
                                   int threshold);

   //--- Path (polyline): N-point arrays; draws N-1 SDF AA segments + optional arrowhead
   void   DrawPathOn(CCanvas &canvas,
                      const int &xs[], const int &ys[],
                      color objColor, bool selected, bool hovered,
                      bool drawArrowhead = true,
                      int lineWidth = 2, int lineOpacity = 100,
                      int lineStyle = 0);
   bool   HitTestPath(int mx, int my, const int &xs[], const int &ys[], int threshold);

   //--- Circle: P1 = center, P2 = border point; radius = screen-distance(P1, P2)
   void   DrawCircleOn(CCanvas &canvas,
                        int cx, int cy, int bx, int by,
                        color objColor, bool selected, bool hovered,
                        bool hideCenterHandle,
                        int lineWidth = 2, int lineOpacity = 100,
                        int lineStyle = 0,
                        color fillColor = clrNONE, int fillOpacity = 30);
   bool   HitTestCircle(int mx, int my, int cx, int cy, int bx, int by, int threshold);

   //--- Arc: 3-click quadratic Bezier (P1=start, P2=end, P3=clamped apex); chord-enclosed fill
   void   DrawArcOn(CCanvas &canvas,
                     int x1, int y1, int x2, int y2, int x3, int y3,
                     color objColor, bool selected, bool hovered,
                     int lineWidth = 2, int lineOpacity = 100,
                     int lineStyle = 0,
                     color fillColor = clrNONE, int fillOpacity = 30);
   bool   HitTestArc(int mx, int my, int x1, int y1, int x2, int y2, int x3, int y3,
                      int threshold);
   //--- Compute the clamped apex (apX, apY) and the X-component of the Bezier control point
   bool   ArcCircumcircle(int x1, int y1, int x2, int y2, int x3, int y3,
                           double &apX, double &apY, double &cpX);

   //--- Curve: 3-click quadratic Bezier with FREE apex (no clamp, no fill, no chord)
   void   DrawCurveOn(CCanvas &canvas,
                       int x1, int y1, int x2, int y2, int x3, int y3,
                       color objColor, bool selected, bool hovered,
                       int lineWidth = 2, int lineOpacity = 100,
                       int lineStyle = 0);
   bool   HitTestCurve(int mx, int my, int x1, int y1, int x2, int y2, int x3, int y3,
                        int threshold);
  };

//+------------------------------------------------------------------+
//| Draw a Rectangle: 30% fill + 2px border + 8 derived handles      |
//+------------------------------------------------------------------+
void CShapeTools::DrawRectangleOn(CCanvas &canvas,
                                   int x1, int y1, int x2, int y2,
                                   color objColor, bool selected, bool hovered,
                                   int lineWidth = 2, int lineOpacity = 100,
                                   int lineStyle = 0,
                                   color fillColor = clrNONE, int fillOpacity = 30)
  {
   //--- Clamp the line width into the [1, 4] px range
   if(lineWidth < 1) lineWidth = 1;
   if(lineWidth > 4) lineWidth = 4;
   //--- Clamp the line style into the [0, 3] range (solid/dash/dot/dash-dot)
   if(lineStyle < 0) lineStyle = 0;
   if(lineStyle > 3) lineStyle = 3;
   //--- fillColor=clrNONE means "use the object's stroke color for the fill" (default)
   color fc = (fillColor == clrNONE) ? objColor : fillColor;
   const int thick = lineWidth;
   //--- Normalize the corners so (xL, yT) is top-left and (xR, yB) is bottom-right
   int xL = (x1 < x2) ? x1 : x2;
   int xR = (x1 < x2) ? x2 : x1;
   int yT = (y1 < y2) ? y1 : y2;
   int yB = (y1 < y2) ? y2 : y1;
   //--- Reject rectangles too small to be visually meaningful
   if(xR - xL < 2 || yB - yT < 2) return;
   //--- Interior fill at fillOpacity% alpha via the inherited quad-fill primitive
   const uint fillArgb = ColorWithPercentOpacity(fc, fillOpacity);
   ChannelFillQuad(canvas, xL, yT, xR, yT, xR, yB, xL, yB, fillArgb);
   //--- Border stroke color at lineOpacity% alpha
   const uint borderArgb = ColorWithPercentOpacity(objColor, lineOpacity);
   //--- Solid border uses a hard-edge scan over the rectangle's bounding box
   if(lineStyle == 0)
     {
      //--- Walk every pixel in the bounding box and paint those that fall inside the border band
      for(int yy = yT; yy <= yB; yy++)
        {
         for(int xx = xL; xx <= xR; xx++)
           {
            //--- Inside the vertical edge band (left or right) or horizontal edge band (top or bottom)
            bool nearV = (xx <  xL + thick) || (xx >  xR - thick);
            bool nearH = (yy <  yT + thick) || (yy >  yB - thick);
            if(nearV || nearH)
               ChannelBlendPixelSet(canvas, xx, yy, borderArgb);
           }
        }
     }
   else
     {
      //--- Dashed/dotted/dash-dot border builds a stroke pattern and dispatches per-edge
      int pat[];
      const int n = BuildLineStylePattern(lineStyle, thick, pat);
      if(n > 0)
        {
         //--- Each of the 4 edges renders with the same dashed pattern
         WidgetDashedLineAA(canvas, xL, yT, xR, yT, thick, borderArgb, pat);
         WidgetDashedLineAA(canvas, xR, yT, xR, yB, thick, borderArgb, pat);
         WidgetDashedLineAA(canvas, xR, yB, xL, yB, thick, borderArgb, pat);
         WidgetDashedLineAA(canvas, xL, yB, xL, yT, thick, borderArgb, pat);
        }
      else
        {
         //--- Pattern build failed: fall back to the solid hard-edge scan
         for(int yy = yT; yy <= yB; yy++)
            for(int xx = xL; xx <= xR; xx++)
              {
               bool nearV = (xx <  xL + thick) || (xx >  xR - thick);
               bool nearH = (yy <  yT + thick) || (yy >  yB - thick);
               if(nearV || nearH)
                  ChannelBlendPixelSet(canvas, xx, yy, borderArgb);
              }
        }
     }
   //--- 8 handles when selected or hovered: 4 corners + 4 edge midpoints
   if(selected || hovered)
     {
      //--- Cache the midpoint coords for the edge-midpoint handles
      int midX = (x1 + x2) / 2;
      int midY = (y1 + y2) / 2;
      //--- 4 corner handles (idx 0-3) keyed to stored corners and the two mixed corners
      if(m_hideHandleIdx != 0) DrawHandleOnCanvas(canvas, x1,   y1,   selected, objColor, m_haloHandleIdx == 0);
      if(m_hideHandleIdx != 1) DrawHandleOnCanvas(canvas, x2,   y2,   selected, objColor, m_haloHandleIdx == 1);
      if(m_hideHandleIdx != 2) DrawHandleOnCanvas(canvas, x1,   y2,   selected, objColor, m_haloHandleIdx == 2);
      if(m_hideHandleIdx != 3) DrawHandleOnCanvas(canvas, x2,   y1,   selected, objColor, m_haloHandleIdx == 3);
      //--- 4 edge-midpoint handles (idx 4-7): top, right, bottom, left
      if(m_hideHandleIdx != 4) DrawHandleOnCanvas(canvas, midX, yT,   selected, objColor, m_haloHandleIdx == 4);
      if(m_hideHandleIdx != 5) DrawHandleOnCanvas(canvas, xR,   midY, selected, objColor, m_haloHandleIdx == 5);
      if(m_hideHandleIdx != 6) DrawHandleOnCanvas(canvas, midX, yB,   selected, objColor, m_haloHandleIdx == 6);
      if(m_hideHandleIdx != 7) DrawHandleOnCanvas(canvas, xL,   midY, selected, objColor, m_haloHandleIdx == 7);
     }
  }

//+------------------------------------------------------------------+
//| Draw a Triangle: 30% fill + SDF-AA or dashed border + 3 handles  |
//+------------------------------------------------------------------+
void CShapeTools::DrawTriangleOn(CCanvas &canvas,
                                  int x1, int y1, int x2, int y2, int x3, int y3,
                                  color objColor, bool selected, bool hovered,
                                  int lineWidth = 2, int lineOpacity = 100,
                                  int lineStyle = 0,
                                  color fillColor = clrNONE, int fillOpacity = 30)
  {
   //--- Clamp the line width and style into the supported ranges
   if(lineWidth < 1) lineWidth = 1;
   if(lineWidth > 4) lineWidth = 4;
   if(lineStyle < 0) lineStyle = 0;
   if(lineStyle > 3) lineStyle = 3;
   //--- fillColor=clrNONE means "use the object's stroke color for the fill"
   color fc = (fillColor == clrNONE) ? objColor : fillColor;
   const int thick = lineWidth;
   //--- Interior fill at fillOpacity% alpha via the inherited HR triangle rasterizer
   const uint fillArgb = ColorWithPercentOpacity(fc, fillOpacity);
   FillTriangleHR(canvas, x1, y1, x2, y2, x3, y3, fillArgb);
   //--- Border stroke color at lineOpacity% alpha
   const uint borderFullArgb = ColorWithPercentOpacity(objColor, lineOpacity);
   //--- Dashed/dotted/dash-dot border: render each edge with the dashed AA path
   if(lineStyle != 0)
     {
      //--- Build the stroke pattern; n>0 means a valid pattern was produced
      int pat[];
      const int n = BuildLineStylePattern(lineStyle, thick, pat);
      if(n > 0)
        {
         //--- Render the 3 dashed edges in order
         WidgetDashedLineAA(canvas, x1, y1, x2, y2, thick, borderFullArgb, pat);
         WidgetDashedLineAA(canvas, x2, y2, x3, y3, thick, borderFullArgb, pat);
         WidgetDashedLineAA(canvas, x3, y3, x1, y1, thick, borderFullArgb, pat);
         //--- Handles when selected/hovered (early return so we skip the solid SDF path below)
         if(selected || hovered)
           {
            if(m_hideHandleIdx != 0) DrawHandleOnCanvas(canvas, x1, y1, selected, objColor, m_haloHandleIdx == 0);
            if(m_hideHandleIdx != 1) DrawHandleOnCanvas(canvas, x2, y2, selected, objColor, m_haloHandleIdx == 1);
            if(m_hideHandleIdx != 2) DrawHandleOnCanvas(canvas, x3, y3, selected, objColor, m_haloHandleIdx == 2);
           }
         return;
        }
      //--- Pattern build failed: fall through to the solid SDF AA border path below
     }
   //--- Solid SDF AA border: scan the bounding box and compute distance to nearest triangle edge
   uint  borderRGBmask  = borderFullArgb & 0x00FFFFFF;
   const uchar borderAlpha = (uchar)((borderFullArgb >> 24) & 0xFF);
   //--- Bounding box of the 3 vertices (with 1px padding for AA boundary)
   int xLo = x1; if(x2 < xLo) xLo = x2; if(x3 < xLo) xLo = x3;
   int xHi = x1; if(x2 > xHi) xHi = x2; if(x3 > xHi) xHi = x3;
   int yLo = y1; if(y2 < yLo) yLo = y2; if(y3 < yLo) yLo = y3;
   int yHi = y1; if(y2 > yHi) yHi = y2; if(y3 > yHi) yHi = y3;
   //--- Cache canvas extents and clip the bounding box accordingly
   int cWT = canvas.Width(), cHT = canvas.Height();
   xLo -= 1; yLo -= 1; xHi += 1; yHi += 1;
   if(xLo < 0)     xLo = 0;
   if(yLo < 0)     yLo = 0;
   if(xHi >= cWT)  xHi = cWT - 1;
   if(yHi >= cHT)  yHi = cHT - 1;
   //--- Cache half-thickness for the coverage formula
   double halfThick = (double)thick * 0.5;
   //--- Walk every pixel in the bounding box and compute its border coverage
   for(int yy = yLo; yy <= yHi; yy++)
     {
      for(int xx = xLo; xx <= xHi; xx++)
        {
         //--- Distance from the pixel to each of the 3 triangle edges
         double d1 = PointToSegmentDistance(xx, yy, x1, y1, x2, y2);
         double d2 = PointToSegmentDistance(xx, yy, x2, y2, x3, y3);
         double d3 = PointToSegmentDistance(xx, yy, x3, y3, x1, y1);
         //--- Use the smallest distance for the coverage calculation
         double dMin = d1;
         if(d2 < dMin) dMin = d2;
         if(d3 < dMin) dMin = d3;
         //--- Coverage shrinks linearly with distance from the nearest edge centerline
         double cov = halfThick + 0.5 - dMin;
         if(cov <= 0.0) continue;
         if(cov > 1.0) cov = 1.0;
         //--- Compose the coverage-weighted alpha and blend the pixel
         uchar aCov = (uchar)((double)borderAlpha * cov + 0.5);
         uint  covArgb = ((uint)aCov << 24) | borderRGBmask;
         ChannelBlendPixelSet(canvas, xx, yy, covArgb);
        }
     }
   //--- 3 vertex handles when selected/hovered
   if(selected || hovered)
     {
      if(m_hideHandleIdx != 0) DrawHandleOnCanvas(canvas, x1, y1, selected, objColor, m_haloHandleIdx == 0);
      if(m_hideHandleIdx != 1) DrawHandleOnCanvas(canvas, x2, y2, selected, objColor, m_haloHandleIdx == 1);
      if(m_hideHandleIdx != 2) DrawHandleOnCanvas(canvas, x3, y3, selected, objColor, m_haloHandleIdx == 2);
     }
  }

//+------------------------------------------------------------------+
//| Point-in-triangle test via sign of cross products                |
//+------------------------------------------------------------------+
bool CShapeTools::HitTestTriangleInside(int mx, int my,
                                         int x1, int y1, int x2, int y2, int x3, int y3)
  {
   //--- Cross-product sign for each triangle edge relative to the cursor point
   double d1 = (double)(mx - x2) * (double)(y1 - y2) - (double)(x1 - x2) * (double)(my - y2);
   double d2 = (double)(mx - x3) * (double)(y2 - y3) - (double)(x2 - x3) * (double)(my - y3);
   double d3 = (double)(mx - x1) * (double)(y3 - y1) - (double)(x3 - x1) * (double)(my - y1);
   //--- Inside the triangle iff all signs are the same (no mix of positive and negative)
   bool hasNeg = (d1 < 0) || (d2 < 0) || (d3 < 0);
   bool hasPos = (d1 > 0) || (d2 > 0) || (d3 > 0);
   return !(hasNeg && hasPos);
  }

//+------------------------------------------------------------------+
//| Hit-test Triangle: interior + edge proximity within threshold    |
//+------------------------------------------------------------------+
bool CShapeTools::HitTestTriangle(int mx, int my,
                                   int x1, int y1, int x2, int y2, int x3, int y3,
                                   int threshold)
  {
   //--- Interior hit always counts
   if(HitTestTriangleInside(mx, my, x1, y1, x2, y2, x3, y3)) return true;
   //--- Edge proximity test for each of the 3 triangle edges
   if(PointToSegmentDistance(mx, my, x1, y1, x2, y2) <= threshold) return true;
   if(PointToSegmentDistance(mx, my, x2, y2, x3, y3) <= threshold) return true;
   if(PointToSegmentDistance(mx, my, x3, y3, x1, y1) <= threshold) return true;
   return false;
  }

//+------------------------------------------------------------------+
//| Draw a rotated Ellipse: 30% fill + SDF AA border + 4 handles     |
//+------------------------------------------------------------------+
void CShapeTools::DrawEllipseOn(CCanvas &canvas,
                                 int x1, int y1, int x2, int y2, int x3, int y3,
                                 color objColor, bool selected, bool hovered,
                                 int lineWidth = 2, int lineOpacity = 100,
                                 int lineStyle = 0,
                                 color fillColor = clrNONE, int fillOpacity = 30)
  {
   //--- Clamp the line width into the [1, 4] px range
   if(lineWidth < 1) lineWidth = 1;
   if(lineWidth > 4) lineWidth = 4;
   //--- fillColor=clrNONE means "use the object's stroke color for the fill"
   color fc = (fillColor == clrNONE) ? objColor : fillColor;
   const int thick = lineWidth;
   //--- Center = midpoint of the major axis (P1-P2)
   double cx = (x1 + x2) * 0.5;
   double cy = (y1 + y2) * 0.5;
   //--- Major-axis vector and length; reject degenerate ellipses
   double dxM = (double)(x2 - x1);
   double dyM = (double)(y2 - y1);
   double lenM = MathSqrt(dxM * dxM + dyM * dyM);
   if(lenM < 2.0) return;
   //--- Semi-major (a) = half of the major-axis length
   double a = lenM * 0.5;
   //--- Rotation angle's cosine and sine come from the major-axis direction
   double cosT = dxM / lenM;
   double sinT = dyM / lenM;
   //--- P3 relative to the center; its perpendicular projection onto the minor axis = b
   double dx3 = (double)x3 - cx;
   double dy3 = (double)y3 - cy;
   double b   = MathAbs(-dx3 * sinT + dy3 * cosT);
   //--- Clamp the semi-minor to at least 1 pixel so degenerate ellipses still render
   if(b < 1.0) b = 1.0;
   //--- Fill color at fillOpacity% alpha
   const uint fillArgb = ColorWithPercentOpacity(fc, fillOpacity);
   //--- Cache canvas extents for the bounding-box clip
   int   cWE       = canvas.Width();
   int   cHE       = canvas.Height();
   //--- Axis-aligned bounding box of the rotated ellipse (from the extremum formula)
   double halfW = MathSqrt(a * a * cosT * cosT + b * b * sinT * sinT);
   double halfH = MathSqrt(a * a * sinT * sinT + b * b * cosT * cosT);
   int   bxLo = (int)MathFloor(cx - halfW) - 1;
   int   bxHi = (int)MathCeil (cx + halfW) + 1;
   int   byLo = (int)MathFloor(cy - halfH) - 1;
   int   byHi = (int)MathCeil (cy + halfH) + 1;
   //--- Clip the bounding box to canvas bounds
   if(bxLo < 0)    bxLo = 0;
   if(byLo < 0)    byLo = 0;
   if(bxHi >= cWE) bxHi = cWE - 1;
   if(byHi >= cHE) byHi = cHE - 1;
   //--- Cached squared semi-axes for the ellipse-equation tests
   double aSq = a * a;
   double bSq = b * b;
   //--- PASS 1: interior fill - walk bounding box and paint pixels where F<=1
   for(int yy = byLo; yy <= byHi; yy++)
     {
      for(int xx = bxLo; xx <= bxHi; xx++)
        {
         //--- Translate to center origin, then inverse-rotate into the ellipse's local (u, v) frame
         double dxp =  (double)xx - cx;
         double dyp =  (double)yy - cy;
         double u   =  dxp * cosT + dyp * sinT;
         double v   = -dxp * sinT + dyp * cosT;
         //--- Ellipse equation: F = (u^2)/(a^2) + (v^2)/(b^2). F<=1 means inside
         double F   = (u * u) / aSq + (v * v) / bSq;
         if(F <= 1.0)
            ChannelBlendPixelSet(canvas, xx, yy, fillArgb);
        }
     }
   //--- PASS 2: SDF AA border - signed-distance approximation to the ellipse boundary
   uint  borderFullArgb = ColorWithPercentOpacity(objColor, lineOpacity);
   uint  borderRGBmask  = borderFullArgb & 0x00FFFFFF;
   const uchar borderAlpha = (uchar)((borderFullArgb >> 24) & 0xFF);
   double halfThick = (double)thick * 0.5;
   //--- Safety margin so the bounding box covers the AA boundary
   double safety = halfThick + 1.5;
   //--- Walk every pixel in the bounding box and compute its border coverage
   for(int yy = byLo; yy <= byHi; yy++)
     {
      for(int xx = bxLo; xx <= bxHi; xx++)
        {
         //--- Translate to center origin and inverse-rotate into the ellipse's local frame
         double dxp =  (double)xx - cx;
         double dyp =  (double)yy - cy;
         double u   =  dxp * cosT + dyp * sinT;
         double v   = -dxp * sinT + dyp * cosT;
         //--- Quick reject: skip pixels well outside the [a + safety, b + safety] envelope
         double absU = MathAbs(u);
         double absV = MathAbs(v);
         if(absU > a + safety || absV > b + safety) continue;
         //--- Ellipse equation and its square root (used as the F-distance to the boundary)
         double F   = (u * u) / aSq + (v * v) / bSq;
         double sqrtF = MathSqrt(F);
         if(sqrtF < 1e-9) continue;
         //--- Gradient magnitude (used to convert F into approximate Euclidean distance)
         double gu = u / aSq;
         double gv = v / bSq;
         double gmag = MathSqrt(gu * gu + gv * gv);
         if(gmag < 1e-12) continue;
         //--- Perpendicular distance from the pixel to the ellipse boundary
         double dist = MathAbs((sqrtF - 1.0) / gmag);
         //--- Edge-case rejects outside the ellipse: prevent the AA from leaking into far pixels
         if(absV > b + halfThick + 1.0 && sqrtF > 1.0) continue;
         if(absU > a + halfThick + 1.0 && sqrtF > 1.0) continue;
         //--- Coverage shrinks linearly with distance from the boundary centerline
         double cov  = halfThick + 0.5 - dist;
         if(cov <= 0.0) continue;
         if(cov > 1.0) cov = 1.0;
         //--- Compose the coverage-weighted alpha and blend the pixel
         uchar aCov = (uchar)((double)borderAlpha * cov + 0.5);
         uint  covArgb = ((uint)aCov << 24) | borderRGBmask;
         ChannelBlendPixelSet(canvas, xx, yy, covArgb);
        }
     }
   //--- 4 handles when selected or hovered: 2 major-axis ends + 2 minor-axis ends
   if(selected || hovered)
     {
      //--- P3's sign determines which side of the major axis the (+) minor handle lands on
      double perpSide = -dx3 * sinT + dy3 * cosT;
      double signP3 = (perpSide >= 0.0) ? 1.0 : -1.0;
      //--- Perpendicular unit vector pointing toward P3's side of the major axis
      double perpX = -sinT * signP3;
      double perpY =  cosT * signP3;
      //--- Major-axis handles sit at the stored P1 and P2 positions
      int h0x = x1,                               h0y = y1;
      int h1x = x2,                               h1y = y2;
      //--- Minor-axis handles sit at center +/- b along the perpendicular
      int h2x = (int)MathRound(cx + perpX * b);   int h2y = (int)MathRound(cy + perpY * b);
      int h3x = (int)MathRound(cx - perpX * b);   int h3y = (int)MathRound(cy - perpY * b);
      //--- Render the 4 handles honoring hide/halo state
      if(m_hideHandleIdx != 0) DrawHandleOnCanvas(canvas, h0x, h0y, selected, objColor, m_haloHandleIdx == 0);
      if(m_hideHandleIdx != 1) DrawHandleOnCanvas(canvas, h1x, h1y, selected, objColor, m_haloHandleIdx == 1);
      if(m_hideHandleIdx != 2) DrawHandleOnCanvas(canvas, h2x, h2y, selected, objColor, m_haloHandleIdx == 2);
      if(m_hideHandleIdx != 3) DrawHandleOnCanvas(canvas, h3x, h3y, selected, objColor, m_haloHandleIdx == 3);
     }
  }

//+------------------------------------------------------------------+
//| Hit-test rotated Ellipse: inside-ellipse or near boundary        |
//+------------------------------------------------------------------+
bool CShapeTools::HitTestEllipseRotated(int mx, int my,
                                         int x1, int y1, int x2, int y2, int x3, int y3,
                                         int threshold)
  {
   //--- Center of the rotated ellipse = midpoint of the major axis (P1-P2)
   double cx = (x1 + x2) * 0.5;
   double cy = (y1 + y2) * 0.5;
   //--- Major-axis vector and length; reject degenerate ellipses
   double dxM = (double)(x2 - x1);
   double dyM = (double)(y2 - y1);
   double lenM = MathSqrt(dxM * dxM + dyM * dyM);
   if(lenM < 2.0) return false;
   //--- Semi-major (a) and rotation cosine/sine
   double a = lenM * 0.5;
   double cosT = dxM / lenM;
   double sinT = dyM / lenM;
   //--- Semi-minor (b) = perpendicular distance from P3 to the major axis
   double dx3 = (double)x3 - cx;
   double dy3 = (double)y3 - cy;
   double b   = MathAbs(-dx3 * sinT + dy3 * cosT);
   if(b < 1.0) b = 1.0;
   //--- Translate the cursor to center origin and inverse-rotate into the ellipse's local frame
   double dxp =  (double)mx - cx;
   double dyp =  (double)my - cy;
   double u   =  dxp * cosT + dyp * sinT;
   double v   = -dxp * sinT + dyp * cosT;
   //--- F<=1 means inside the ellipse: interior hit
   double F   = (u * u) / (a * a) + (v * v) / (b * b);
   if(F <= 1.0) return true;
   //--- Outside the ellipse: estimate distance to boundary via gradient magnitude
   double sqrtF = MathSqrt(F);
   if(sqrtF < 1e-9) return true;
   double gu = u / (a * a);
   double gv = v / (b * b);
   double gmag = MathSqrt(gu * gu + gv * gv);
   if(gmag < 1e-12) return true;
   double dist = MathAbs((sqrtF - 1.0) / gmag);
   //--- Hit iff cursor is within threshold pixels of the ellipse boundary
   return (dist <= (double)threshold);
  }

//+------------------------------------------------------------------+
//| Compute 6 rotated-rect handle positions in canonical TL/TR/BR/BL |
//+------------------------------------------------------------------+
void CShapeTools::ComputeRotatedRectHandles(int x1, int y1, int x2, int y2, int x3, int y3,
                                             int &outX[], int &outY[])
  {
   //--- Output arrays sized to 6 (4 corners + 2 side-midpoints)
   ArrayResize(outX, 6);
   ArrayResize(outY, 6);
   //--- Major-axis vector and length; degenerate case collapses all handles
   double dxM = (double)(x2 - x1);
   double dyM = (double)(y2 - y1);
   double lenM = MathSqrt(dxM * dxM + dyM * dyM);
   if(lenM < 2.0)
     {
      //--- All 4 corners collapse onto P1; side-midpoints keep P1 and P2 verbatim
      for(int i = 0; i < 4; i++) { outX[i] = x1; outY[i] = y1; }
      outX[4] = x1; outY[4] = y1;
      outX[5] = x2; outY[5] = y2;
      return;
     }
   //--- Perpendicular unit vector (rotated 90deg from the major-axis direction)
   double vx = -dyM / lenM;
   double vy =  dxM / lenM;
   //--- Signed half-width from P1 toward P3 along the perpendicular
   double halfW = ((double)x3 - (double)x1) * vx + ((double)y3 - (double)y1) * vy;
   //--- Compute the 4 raw corners (signed offset along the perpendicular from each P endpoint)
   double rawX[4], rawY[4];
   rawX[0] = (double)x1 + halfW * vx;   rawY[0] = (double)y1 + halfW * vy;
   rawX[1] = (double)x2 + halfW * vx;   rawY[1] = (double)y2 + halfW * vy;
   rawX[2] = (double)x2 - halfW * vx;   rawY[2] = (double)y2 - halfW * vy;
   rawX[3] = (double)x1 - halfW * vx;   rawY[3] = (double)y1 - halfW * vy;
   //--- Sort the 4 corners by Y (smallest Y = top) via tiny bubble sort over the index array
   int idxByY[4] = {0, 1, 2, 3};
   for(int i = 0; i < 4; i++)
      for(int j = 0; j < 3 - i; j++)
         if(rawY[idxByY[j]] > rawY[idxByY[j+1]])
           {
            int tmp = idxByY[j]; idxByY[j] = idxByY[j+1]; idxByY[j+1] = tmp;
           }
   //--- Among the 2 top corners, pick the one with smaller X = top-left
   int topL = idxByY[0], topR = idxByY[1];
   if(rawX[topL] > rawX[topR]) { int tmp = topL; topL = topR; topR = tmp; }
   //--- Among the 2 bottom corners, pick the one with smaller X = bottom-left
   int botL = idxByY[2], botR = idxByY[3];
   if(rawX[botL] > rawX[botR]) { int tmp = botL; botL = botR; botR = tmp; }
   //--- Write the 4 corners in canonical TL/TR/BR/BL order to the output arrays
   outX[0] = (int)MathRound(rawX[topL]); outY[0] = (int)MathRound(rawY[topL]);
   outX[1] = (int)MathRound(rawX[topR]); outY[1] = (int)MathRound(rawY[topR]);
   outX[2] = (int)MathRound(rawX[botR]); outY[2] = (int)MathRound(rawY[botR]);
   outX[3] = (int)MathRound(rawX[botL]); outY[3] = (int)MathRound(rawY[botL]);
   //--- Indices 4 and 5 = stored P1 and P2 (the side-midpoint handles - identity preserved)
   outX[4] = x1; outY[4] = y1;
   outX[5] = x2; outY[5] = y2;
  }

//+------------------------------------------------------------------+
//| Draw a rotated Rectangle: 30% fill + SDF border + 6 handles      |
//+------------------------------------------------------------------+
void CShapeTools::DrawRotatedRectangleOn(CCanvas &canvas,
                                          int x1, int y1, int x2, int y2, int x3, int y3,
                                          color objColor, bool selected, bool hovered,
                                          int lineWidth, int lineOpacity,
                                          int lineStyle,
                                          color fillColor, int fillOpacity)
  {
   //--- Clamp line width and style into supported ranges
   if(lineWidth < 1) lineWidth = 1;
   if(lineWidth > 4) lineWidth = 4;
   if(lineStyle < 0) lineStyle = 0;
   if(lineStyle > 3) lineStyle = 3;
   //--- fillColor=clrNONE means "use the object's stroke color for the fill"
   color fc = (fillColor == clrNONE) ? objColor : fillColor;
   const int thick = lineWidth;
   //--- Major-axis vector and length; reject degenerate rectangles
   double dxM = (double)(x2 - x1);
   double dyM = (double)(y2 - y1);
   double lenM = MathSqrt(dxM * dxM + dyM * dyM);
   if(lenM < 2.0) return;
   //--- Unit-along (u) and unit-perpendicular (v) vectors derived from the major axis
   double ux = dxM / lenM;
   double uy = dyM / lenM;
   double vx = -uy;
   double vy =  ux;
   //--- Signed half-width from P1 toward P3 along the perpendicular
   double halfW = ((double)x3 - (double)x1) * vx + ((double)y3 - (double)y1) * vy;
   //--- Compute the 4 rotated rectangle corners (P1/P2 +/- halfW along the perpendicular)
   double C0x = (double)x1 + halfW * vx, C0y = (double)y1 + halfW * vy;
   double C1x = (double)x2 + halfW * vx, C1y = (double)y2 + halfW * vy;
   double C2x = (double)x2 - halfW * vx, C2y = (double)y2 - halfW * vy;
   double C3x = (double)x1 - halfW * vx, C3y = (double)y1 - halfW * vy;
   //--- Compose the fill color at fillOpacity% alpha
   const uint fillArgb = ColorWithPercentOpacity(fc, fillOpacity);
   //--- Round the 4 corners to integer pixel positions for the quad-fill primitive
   int iC0x = (int)MathRound(C0x), iC0y = (int)MathRound(C0y);
   int iC1x = (int)MathRound(C1x), iC1y = (int)MathRound(C1y);
   int iC2x = (int)MathRound(C2x), iC2y = (int)MathRound(C2y);
   int iC3x = (int)MathRound(C3x), iC3y = (int)MathRound(C3y);
   //--- Interior fill rendered as a single rotated quad via the inherited fill primitive
   ChannelFillQuad(canvas, iC0x, iC0y, iC1x, iC1y, iC2x, iC2y, iC3x, iC3y, fillArgb);
   //--- Border stroke color at lineOpacity% alpha
   const uint borderFullArgb = ColorWithPercentOpacity(objColor, lineOpacity);
   //--- Solid border: scan the bounding box with SDF AA against the 4 edges
   if(lineStyle == 0)
     {
      //--- Cache the border RGB mask and base alpha for coverage-weighted blending
      const uint borderRGBmask = borderFullArgb & 0x00FFFFFF;
      const uchar baseAlpha    = (uchar)((borderFullArgb >> 24) & 0xFF);
      const double halfThick = (double)thick * 0.5;
      //--- Compute the bounding box of the 4 corners
      double xLo_ = C0x, xHi_ = C0x, yLo_ = C0y, yHi_ = C0y;
      if(C1x < xLo_) xLo_ = C1x;  if(C1x > xHi_) xHi_ = C1x;
      if(C2x < xLo_) xLo_ = C2x;  if(C2x > xHi_) xHi_ = C2x;
      if(C3x < xLo_) xLo_ = C3x;  if(C3x > xHi_) xHi_ = C3x;
      if(C1y < yLo_) yLo_ = C1y;  if(C1y > yHi_) yHi_ = C1y;
      if(C2y < yLo_) yLo_ = C2y;  if(C2y > yHi_) yHi_ = C2y;
      if(C3y < yLo_) yLo_ = C3y;  if(C3y > yHi_) yHi_ = C3y;
      //--- Integer bounding box with 1px padding for AA boundary
      int xLo = (int)MathFloor(xLo_) - 1;
      int xHi = (int)MathCeil (xHi_) + 1;
      int yLo = (int)MathFloor(yLo_) - 1;
      int yHi = (int)MathCeil (yHi_) + 1;
      //--- Cache canvas extents and clip the bounding box accordingly
      int cWR = canvas.Width(), cHR = canvas.Height();
      if(xLo < 0)     xLo = 0;
      if(yLo < 0)     yLo = 0;
      if(xHi >= cWR)  xHi = cWR - 1;
      if(yHi >= cHR)  yHi = cHR - 1;
      //--- Pack the 4 edges into parallel arrays for the per-pixel distance loop
      double eX1[4], eY1[4], eX2[4], eY2[4];
      eX1[0] = C0x; eY1[0] = C0y; eX2[0] = C1x; eY2[0] = C1y;
      eX1[1] = C1x; eY1[1] = C1y; eX2[1] = C2x; eY2[1] = C2y;
      eX1[2] = C2x; eY1[2] = C2y; eX2[2] = C3x; eY2[2] = C3y;
      eX1[3] = C3x; eY1[3] = C3y; eX2[3] = C0x; eY2[3] = C0y;
      //--- Walk every pixel in the bounding box and compute coverage from the nearest edge
      for(int yy = yLo; yy <= yHi; yy++)
        {
         for(int xx = xLo; xx <= xHi; xx++)
           {
            //--- Find the minimum distance to any of the 4 edges
            double dMin = 1e9;
            for(int e = 0; e < 4; e++)
              {
               double d = PointToSegmentDistance(xx, yy,
                                                  (int)MathRound(eX1[e]), (int)MathRound(eY1[e]),
                                                  (int)MathRound(eX2[e]), (int)MathRound(eY2[e]));
               if(d < dMin) dMin = d;
              }
            //--- Coverage shrinks linearly with distance from the nearest edge centerline
            double cov = halfThick + 0.5 - dMin;
            if(cov <= 0.0) continue;
            if(cov > 1.0) cov = 1.0;
            //--- Compose the coverage-weighted alpha and blend the pixel
            uchar aCov = (uchar)(((double)baseAlpha * cov) + 0.5);
            uint  covArgb = ((uint)aCov << 24) | borderRGBmask;
            ChannelBlendPixelSet(canvas, xx, yy, covArgb);
           }
        }
     }
   else
     {
      //--- Dashed/dotted/dash-dot border: build a stroke pattern and dispatch per-edge
      int pat[];
      const int n = BuildLineStylePattern(lineStyle, thick, pat);
      if(n > 0)
        {
         //--- Each of the 4 rotated-rect edges renders with the same dashed pattern
         WidgetDashedLineAA(canvas, iC0x, iC0y, iC1x, iC1y, thick, borderFullArgb, pat);
         WidgetDashedLineAA(canvas, iC1x, iC1y, iC2x, iC2y, thick, borderFullArgb, pat);
         WidgetDashedLineAA(canvas, iC2x, iC2y, iC3x, iC3y, thick, borderFullArgb, pat);
         WidgetDashedLineAA(canvas, iC3x, iC3y, iC0x, iC0y, thick, borderFullArgb, pat);
        }
      else
        {
         //--- Pattern build failed: fall back to solid thick lines on each edge
         DrawThickLine(canvas, iC0x, iC0y, iC1x, iC1y, thick, borderFullArgb);
         DrawThickLine(canvas, iC1x, iC1y, iC2x, iC2y, thick, borderFullArgb);
         DrawThickLine(canvas, iC2x, iC2y, iC3x, iC3y, thick, borderFullArgb);
         DrawThickLine(canvas, iC3x, iC3y, iC0x, iC0y, thick, borderFullArgb);
        }
     }
   //--- 6 handles when selected or hovered: 4 corners + 2 side-midpoints
   if(selected || hovered)
     {
      //--- Resolve the 6 handle positions via the helper (returns canonical TL/TR/BR/BL ordering)
      int hX[], hY[];
      ComputeRotatedRectHandles(x1, y1, x2, y2, x3, y3, hX, hY);
      //--- Render each handle honoring hide/halo state
      for(int hi = 0; hi < 6; hi++)
         if(m_hideHandleIdx != hi)
            DrawHandleOnCanvas(canvas, hX[hi], hY[hi], selected, objColor, m_haloHandleIdx == hi);
     }
  }

//+------------------------------------------------------------------+
//| Hit-test rotated Rectangle: interior OR edge proximity           |
//+------------------------------------------------------------------+
bool CShapeTools::HitTestRotatedRectangle(int mx, int my,
                                           int x1, int y1, int x2, int y2, int x3, int y3,
                                           int threshold)
  {
   //--- Major-axis vector and length; reject degenerate rectangles
   double dxM = (double)(x2 - x1);
   double dyM = (double)(y2 - y1);
   double lenM = MathSqrt(dxM * dxM + dyM * dyM);
   if(lenM < 2.0) return false;
   //--- Unit-along (u) and unit-perpendicular (v) vectors
   double ux = dxM / lenM;
   double uy = dyM / lenM;
   double vx = -uy;
   double vy =  ux;
   //--- Signed half-width from P1 toward P3 along the perpendicular
   double halfW = ((double)x3 - (double)x1) * vx + ((double)y3 - (double)y1) * vy;
   //--- Compute the 4 rotated rectangle corners (in CCW order around the quad)
   int cX[4];
   int cY[4];
   cX[0] = (int)MathRound((double)x1 + halfW * vx);   cY[0] = (int)MathRound((double)y1 + halfW * vy);
   cX[1] = (int)MathRound((double)x2 + halfW * vx);   cY[1] = (int)MathRound((double)y2 + halfW * vy);
   cX[2] = (int)MathRound((double)x2 - halfW * vx);   cY[2] = (int)MathRound((double)y2 - halfW * vy);
   cX[3] = (int)MathRound((double)x1 - halfW * vx);   cY[3] = (int)MathRound((double)y1 - halfW * vy);
   //--- Sign-of-cross-product test: cursor is inside the quad iff all 4 edge tests have the same sign
   bool anyPos = false, anyNeg = false;
   for(int i = 0; i < 4; i++)
     {
      //--- Edge vector (P[i] -> P[i+1]) and edge-to-cursor vector
      int j = (i + 1) % 4;
      long ex = cX[j] - cX[i];
      long ey = cY[j] - cY[i];
      long fx = mx    - cX[i];
      long fy = my    - cY[i];
      //--- Z-component of the 2D cross product = the sign test for this edge
      long crossZ = ex * fy - ey * fx;
      if(crossZ > 0) anyPos = true;
      if(crossZ < 0) anyNeg = true;
      //--- Once we have both signs, the cursor is OUTSIDE - bail out of the loop
      if(anyPos && anyNeg) break;
     }
   //--- All same sign means cursor is INSIDE the quad
   if(!(anyPos && anyNeg)) return true;
   //--- Outside the quad: test edge proximity for each of the 4 edges
   for(int i = 0; i < 4; i++)
     {
      int j = (i + 1) % 4;
      if(PointToSegmentDistance(mx, my, cX[i], cY[i], cX[j], cY[j]) <= threshold) return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
//| Draw a Path (polyline): N-1 SDF segments + optional arrowhead    |
//+------------------------------------------------------------------+
void CShapeTools::DrawPathOn(CCanvas &canvas,
                              const int &xs[], const int &ys[],
                              color objColor, bool selected, bool hovered,
                              bool drawArrowhead,
                              int lineWidth = 2, int lineOpacity = 100,
                              int lineStyle = 0)
  {
   //--- Reject paths with fewer than 2 points (no segments to render)
   int N = ArraySize(xs);
   if(N < 2) return;
   //--- Clamp line width and style into supported ranges
   if(lineWidth < 1) lineWidth = 1;
   if(lineWidth > 4) lineWidth = 4;
   if(lineStyle < 0) lineStyle = 0;
   if(lineStyle > 3) lineStyle = 3;
   const int thick = lineWidth;
   //--- Border stroke ARGB and unpacked alpha/RGB for coverage-weighted blending
   const uint  borderFullArgb = ColorWithPercentOpacity(objColor, lineOpacity);
   uint  borderRGBmask  = borderFullArgb & 0x00FFFFFF;
   const uchar borderAlpha = (uchar)((borderFullArgb >> 24) & 0xFF);
   //--- Cache half-thickness and canvas extents for the per-segment scan
   double halfThick = (double)thick * 0.5;
   int cW = canvas.Width();
   int cH = canvas.Height();
   //--- Walk every segment in the polyline (N-1 segments for N points)
   for(int s = 0; s < N - 1; s++)
     {
      //--- Endpoints of this segment
      int ax = xs[s],     ay = ys[s];
      int bx = xs[s + 1], by = ys[s + 1];
      //--- Dashed/dotted/dash-dot path: build a stroke pattern and dispatch dashed AA
      if(lineStyle != 0)
        {
         int pat[];
         const int n = BuildLineStylePattern(lineStyle, thick, pat);
         if(n > 0)
           {
            WidgetDashedLineAA(canvas, ax, ay, bx, by, thick, borderFullArgb, pat);
            continue;
           }
        }
      //--- Solid SDF AA path: scan the segment's bounding box for per-pixel coverage
      int xLo = (ax < bx) ? ax : bx;
      int xHi = (ax < bx) ? bx : ax;
      int yLo = (ay < by) ? ay : by;
      int yHi = (ay < by) ? by : ay;
      //--- 2px padding around the bounding box for AA boundary
      xLo -= 2;  xHi += 2;  yLo -= 2;  yHi += 2;
      //--- Clip the bounding box to canvas bounds
      if(xLo < 0)     xLo = 0;
      if(yLo < 0)     yLo = 0;
      if(xHi >= cW)   xHi = cW - 1;
      if(yHi >= cH)   yHi = cH - 1;
      //--- Walk every pixel in the bounding box and compute its segment coverage
      for(int yy = yLo; yy <= yHi; yy++)
        {
         for(int xx = xLo; xx <= xHi; xx++)
           {
            //--- Distance from the pixel to the segment
            double d = PointToSegmentDistance(xx, yy, ax, ay, bx, by);
            //--- Coverage shrinks linearly with distance from the segment centerline
            double cov = halfThick + 0.5 - d;
            if(cov <= 0.0) continue;
            if(cov > 1.0) cov = 1.0;
            //--- Compose the coverage-weighted alpha and blend the pixel
            uchar aCov = (uchar)((double)borderAlpha * cov + 0.5);
            uint  covArgb = ((uint)aCov << 24) | borderRGBmask;
            ChannelBlendPixelSet(canvas, xx, yy, covArgb);
           }
        }
     }
   //--- Arrowhead at the final vertex (two wing segments back along the last shaft direction)
   if(drawArrowhead && N >= 2)
     {
      //--- End vertex and the prior vertex (defines the incoming shaft direction)
      int ex = xs[N - 1];
      int ey = ys[N - 1];
      int px = xs[N - 2];
      int py = ys[N - 2];
      //--- Final segment vector and length
      double dxS = (double)(ex - px);
      double dyS = (double)(ey - py);
      double lenS = MathSqrt(dxS * dxS + dyS * dyS);
      //--- Skip arrowhead if the final segment is degenerate
      if(lenS >= 1.0)
        {
         //--- Unit direction along the final segment
         double ux = dxS / lenS;
         double uy = dyS / lenS;
         //--- Wing length and spread half-angle (each wing rotated +/-25deg from the shaft)
         double wingLen = 12.0;
         double wingAng = 25.0 * 3.14159265358979 / 180.0;
         double cA = MathCos(wingAng);
         double sA = MathSin(wingAng);
         //--- Two wing direction vectors (back along the shaft, rotated +/-25deg)
         double w1dx = -(ux * cA - uy * sA);
         double w1dy = -(uy * cA + ux * sA);
         double w2dx = -(ux * cA + uy * sA);
         double w2dy = -(uy * cA - ux * sA);
         //--- Wing endpoints in canvas coords
         int w1x = (int)MathRound((double)ex + w1dx * wingLen);
         int w1y = (int)MathRound((double)ey + w1dy * wingLen);
         int w2x = (int)MathRound((double)ex + w2dx * wingLen);
         int w2y = (int)MathRound((double)ey + w2dy * wingLen);
         //--- Pack the 2 wing endpoints into parallel arrays for the rendering loop
         int wxs[2] = {w1x, w2x};
         int wys[2] = {w1y, w2y};
         //--- Render each wing as an SDF AA segment from the tip back along the wing direction
         for(int w = 0; w < 2; w++)
           {
            //--- Bounding box of this wing segment with 2px AA padding
            int wxLo = (ex < wxs[w]) ? ex : wxs[w];
            int wxHi = (ex < wxs[w]) ? wxs[w] : ex;
            int wyLo = (ey < wys[w]) ? ey : wys[w];
            int wyHi = (ey < wys[w]) ? wys[w] : ey;
            wxLo -= 2; wxHi += 2; wyLo -= 2; wyHi += 2;
            //--- Clip the bounding box to canvas bounds
            if(wxLo < 0)    wxLo = 0;
            if(wyLo < 0)    wyLo = 0;
            if(wxHi >= cW)  wxHi = cW - 1;
            if(wyHi >= cH)  wyHi = cH - 1;
            //--- Walk every pixel in the wing's bounding box and compute its segment coverage
            for(int yy = wyLo; yy <= wyHi; yy++)
              {
               for(int xx = wxLo; xx <= wxHi; xx++)
                 {
                  //--- Distance from the pixel to the wing segment
                  double d = PointToSegmentDistance(xx, yy, ex, ey, wxs[w], wys[w]);
                  //--- Coverage shrinks linearly with distance from the segment centerline
                  double cov = halfThick + 0.5 - d;
                  if(cov <= 0.0) continue;
                  if(cov > 1.0) cov = 1.0;
                  //--- Compose the coverage-weighted alpha and blend the pixel
                  uchar aCov = (uchar)((double)borderAlpha * cov + 0.5);
                  uint  covArgb = ((uint)aCov << 24) | borderRGBmask;
                  ChannelBlendPixelSet(canvas, xx, yy, covArgb);
                 }
              }
           }
        }
     }
   //--- N handles when selected or hovered (one per path vertex)
   if(selected || hovered)
     {
      for(int hi = 0; hi < N; hi++)
         if(m_hideHandleIdx != hi)
            DrawHandleOnCanvas(canvas, xs[hi], ys[hi], selected, objColor, m_haloHandleIdx == hi);
     }
  }

//+------------------------------------------------------------------+
//| Hit-test Path: cursor within threshold of any of the N-1 segments|
//+------------------------------------------------------------------+
bool CShapeTools::HitTestPath(int mx, int my, const int &xs[], const int &ys[], int threshold)
  {
   //--- Reject paths with fewer than 2 points
   int N = ArraySize(xs);
   if(N < 2) return false;
   //--- Test every segment in turn; any match returns true
   for(int s = 0; s < N - 1; s++)
     {
      if(PointToSegmentDistance(mx, my, xs[s], ys[s], xs[s + 1], ys[s + 1]) <= threshold)
         return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
//| Draw a Circle: 30% fill + SDF AA border + center/border handles  |
//+------------------------------------------------------------------+
void CShapeTools::DrawCircleOn(CCanvas &canvas,
                                int cx, int cy, int bx, int by,
                                color objColor, bool selected, bool hovered,
                                bool hideCenterHandle,
                                int lineWidth = 2, int lineOpacity = 100,
                                int lineStyle = 0,
                                color fillColor = clrNONE, int fillOpacity = 30)
  {
   //--- Clamp line width into the [1, 4] px range
   if(lineWidth < 1) lineWidth = 1;
   if(lineWidth > 4) lineWidth = 4;
   //--- fillColor=clrNONE means "use the object's stroke color for the fill"
   color fc = (fillColor == clrNONE) ? objColor : fillColor;
   const int thick = lineWidth;
   //--- Radius = screen-distance from center to border point; reject degenerate circles
   double dxr = (double)(bx - cx);
   double dyr = (double)(by - cy);
   double r   = MathSqrt(dxr * dxr + dyr * dyr);
   if(r < 1.0) return;
   //--- Compose fill ARGB and unpack alpha for coverage-weighted blending
   const uint  fillArgb  = ColorWithPercentOpacity(fc, fillOpacity);
   const uchar fillAlpha = (uchar)((fillArgb >> 24) & 0xFF);
   //--- Compose border ARGB and unpack alpha + RGB mask for the SDF AA pass
   const uint  borderFullArgb = ColorWithPercentOpacity(objColor, lineOpacity);
   uint  borderRGBmask  = borderFullArgb & 0x00FFFFFF;
   const uchar borderAlpha = (uchar)((borderFullArgb >> 24) & 0xFF);
   double halfThick = (double)thick * 0.5;
   //--- Axis-aligned bounding box of the disc + border (with 1px AA padding)
   int xLo = (int)MathFloor((double)cx - r) - 1;
   int xHi = (int)MathCeil ((double)cx + r) + 1;
   int yLo = (int)MathFloor((double)cy - r) - 1;
   int yHi = (int)MathCeil ((double)cy + r) + 1;
   //--- Cache canvas extents and clip the bounding box accordingly
   int cW = canvas.Width(), cH = canvas.Height();
   if(xLo < 0)     xLo = 0;
   if(yLo < 0)     yLo = 0;
   if(xHi >= cW)   xHi = cW - 1;
   if(yHi >= cH)   yHi = cH - 1;
   //--- Walk every pixel in the bounding box: paint fill AND border in a single pass
   for(int yy = yLo; yy <= yHi; yy++)
     {
      //--- Cache the Y delta and its square for the per-row pixel loop
      double dyp = (double)yy - (double)cy;
      double dyp2 = dyp * dyp;
      for(int xx = xLo; xx <= xHi; xx++)
        {
         //--- Squared distance from the pixel to the center
         double dxp = (double)xx - (double)cx;
         double distSq = dxp * dxp + dyp2;
         //--- Quick-reject: skip pixels well outside the disc+border envelope
         double outerCut = r + halfThick + 1.0;
         if(distSq > outerCut * outerCut) continue;
         //--- Actual distance from the center
         double dist = MathSqrt(distSq);
         //--- Fill coverage: full inside, AA boundary, zero outside
         double fillCov = r + halfThick + 0.5 - dist;
         if(fillCov > 1.0) fillCov = 1.0;
         if(fillCov > 0.0)
           {
            //--- Compose the coverage-weighted fill alpha and blend the pixel
            uchar aFill = (uchar)((double)fillAlpha * fillCov + 0.5);
            uint  argb  = ((uint)aFill << 24) | (fillArgb & 0x00FFFFFF);
            ChannelBlendPixelSet(canvas, xx, yy, argb);
           }
         //--- Border coverage: only nonzero near the disc boundary
         double dFromBorder = MathAbs(dist - r);
         if(dFromBorder <= halfThick + 0.5)
           {
            //--- Coverage shrinks linearly with distance from the boundary centerline
            double cov = halfThick + 0.5 - dFromBorder;
            if(cov > 1.0) cov = 1.0;
            if(cov > 0.0)
              {
               //--- Compose the coverage-weighted border alpha and blend the pixel
               uchar aCov = (uchar)((double)borderAlpha * cov + 0.5);
               uint  covArgb = ((uint)aCov << 24) | borderRGBmask;
               ChannelBlendPixelSet(canvas, xx, yy, covArgb);
              }
           }
        }
     }
   //--- Up to 2 handles when selected or hovered (center may be hidden when text/prompt overlay)
   if(selected || hovered)
     {
      //--- Center handle (idx 0) suppressed when hideCenterHandle is true
      if(!hideCenterHandle && m_hideHandleIdx != 0)
         DrawHandleOnCanvas(canvas, cx, cy, selected, objColor, m_haloHandleIdx == 0);
      //--- Border handle (idx 1) always renders when shown (and always lies ON the circle border)
      if(m_hideHandleIdx != 1)
         DrawHandleOnCanvas(canvas, bx, by, selected, objColor, m_haloHandleIdx == 1);
     }
  }

//+------------------------------------------------------------------+
//| Hit-test Circle: inside disc OR within threshold of the border   |
//+------------------------------------------------------------------+
bool CShapeTools::HitTestCircle(int mx, int my, int cx, int cy, int bx, int by, int threshold)
  {
   //--- Radius = screen-distance from center to border point; reject degenerate circles
   double dxr = (double)(bx - cx);
   double dyr = (double)(by - cy);
   double r   = MathSqrt(dxr * dxr + dyr * dyr);
   if(r < 1.0) return false;
   //--- Cursor's distance to the center
   double dxp = (double)mx - (double)cx;
   double dyp = (double)my - (double)cy;
   double dist = MathSqrt(dxp * dxp + dyp * dyp);
   //--- Cursor inside the disc always counts
   if(dist <= r) return true;
   //--- Cursor outside but within threshold pixels of the border still counts
   return (dist - r) <= threshold;
  }

//+------------------------------------------------------------------+
//| Compute the apex + Bezier control X for the Arc 3-click input    |
//+------------------------------------------------------------------+
bool CShapeTools::ArcCircumcircle(int x1, int y1, int x2, int y2, int x3, int y3,
                                   double &apX, double &apY, double &cpX)
  {
   //--- Chord vector and length; reject degenerate chords
   double chx = (double)(x2 - x1);
   double chy = (double)(y2 - y1);
   double chordLen = MathSqrt(chx * chx + chy * chy);
   if(chordLen < 2.0) return false;
   //--- Unit-along and unit-perpendicular vectors of the chord
   double ux = chx / chordLen;
   double uy = chy / chordLen;
   double nx = -uy;
   double ny =  ux;
   //--- Project P3 onto the perpendicular to get the signed perpendicular distance from the chord
   double dx3 = (double)x3 - (double)x1;
   double dy3 = (double)y3 - (double)y1;
   double perp = dx3 * nx + dy3 * ny;
   //--- Chord midpoint - the symmetric apex sits at midpoint + perp * perpendicular_unit
   double midCX = 0.5 * ((double)x1 + (double)x2);
   double midCY = 0.5 * ((double)y1 + (double)y2);
   //--- Symmetric apex on the perpendicular bisector at distance perp from the midpoint
   apX = midCX + perp * nx;
   apY = midCY + perp * ny;
   //--- Bezier control X = reflection of midpoint through apex (so the curve midpoint hits apex)
   cpX = 2.0 * apX - midCX;
   return true;
  }

//+------------------------------------------------------------------+
//| Evaluate a quadratic Bezier curve at parameter t                 |
//+------------------------------------------------------------------+
void ArcBezierEval(double p1x, double p1y, double cpX, double cpY,
                    double p2x, double p2y, double t,
                    double &outX, double &outY)
  {
   //--- Standard quadratic Bezier formula: B(t) = (1-t)^2*P1 + 2(1-t)t*CP + t^2*P2
   double u = 1.0 - t;
   outX = u * u * p1x + 2.0 * u * t * cpX + t * t * p2x;
   outY = u * u * p1y + 2.0 * u * t * cpY + t * t * p2y;
  }

//+------------------------------------------------------------------+
//| Approximate distance from a point to a quadratic Bezier curve    |
//+------------------------------------------------------------------+
double ArcDistToBezier(double px, double py,
                        double p1x, double p1y, double cpX, double cpY,
                        double p2x, double p2y)
  {
   //--- Sample the curve in 64 line segments and find the minimum point-to-segment distance
   const int N = 64;
   double prevX, prevY;
   //--- Start at t=0 (curve start point)
   ArcBezierEval(p1x, p1y, cpX, cpY, p2x, p2y, 0.0, prevX, prevY);
   double dMin = 1e18;
   //--- Walk every sample step and accumulate the minimum squared distance
   for(int i = 1; i <= N; i++)
     {
      //--- Evaluate the curve at parameter t for the current segment endpoint
      double t = (double)i / (double)N;
      double cx, cy;
      ArcBezierEval(p1x, p1y, cpX, cpY, p2x, p2y, t, cx, cy);
      //--- Segment vector and squared length for the projection math
      double sdx = cx - prevX;
      double sdy = cy - prevY;
      double slen2 = sdx * sdx + sdy * sdy;
      //--- Project the point onto the segment; clamp parameter to [0, 1]
      double tSeg = 0.0;
      if(slen2 > 1e-12)
         tSeg = ((px - prevX) * sdx + (py - prevY) * sdy) / slen2;
      if(tSeg < 0.0) tSeg = 0.0;
      if(tSeg > 1.0) tSeg = 1.0;
      //--- Compute the projected foot and its squared distance to the input point
      double qx = prevX + tSeg * sdx;
      double qy = prevY + tSeg * sdy;
      double dx = px - qx, dy = py - qy;
      double d2 = dx * dx + dy * dy;
      //--- Track the minimum squared distance across all segments
      if(d2 < dMin) dMin = d2;
      //--- Advance to the next segment's starting point
      prevX = cx; prevY = cy;
     }
   return MathSqrt(dMin);
  }

//+------------------------------------------------------------------+
//| Draw an Arc (quadratic Bezier): chord-enclosed fill + AA curve   |
//+------------------------------------------------------------------+
void CShapeTools::DrawArcOn(CCanvas &canvas,
                             int x1, int y1, int x2, int y2, int x3, int y3,
                             color objColor, bool selected, bool hovered,
                             int lineWidth, int lineOpacity,
                             int lineStyle,
                             color fillColor, int fillOpacity)
  {
   //--- Clamp line width into the [1, 4] px range
   if(lineWidth < 1) lineWidth = 1;
   if(lineWidth > 4) lineWidth = 4;
   //--- fillColor=clrNONE means "use the object's stroke color for the fill"
   color fc = (fillColor == clrNONE) ? objColor : fillColor;
   const int thick = lineWidth;
   //--- Compute the clamped apex and the Bezier control point X via the helper
   double apX = 0, apY = 0, cpX = 0;
   bool ok = ArcCircumcircle(x1, y1, x2, y2, x3, y3, apX, apY, cpX);
   //--- Degenerate chord: skip the curve render but still draw the 3 handles
   if(!ok)
     {
      if(selected || hovered)
        {
         if(m_hideHandleIdx != 0) DrawHandleOnCanvas(canvas, x1, y1, selected, objColor, m_haloHandleIdx == 0);
         if(m_hideHandleIdx != 1) DrawHandleOnCanvas(canvas, x2, y2, selected, objColor, m_haloHandleIdx == 1);
         if(m_hideHandleIdx != 2) DrawHandleOnCanvas(canvas, x3, y3, selected, objColor, m_haloHandleIdx == 2);
        }
      return;
     }
   //--- CP.y is the mirror of the chord midpoint Y through the apex Y
   double cpY = 2.0 * apY - 0.5 * ((double)y1 + (double)y2);
   //--- Cache endpoint coordinates as doubles for the Bezier math
   double p1x = (double)x1, p1y = (double)y1;
   double p2x = (double)x2, p2y = (double)y2;
   //--- Chord vector (used for side-of-chord testing)
   double chx = p2x - p1x;
   double chy = p2y - p1y;
   //--- Side of the chord that the apex sits on (sign of the cross product)
   double sideApex = chx * (apY - p1y) - chy * (apX - p1x);
   if(MathAbs(sideApex) < 1e-9) sideApex = 1.0;
   double signApex = (sideApex >= 0.0) ? 1.0 : -1.0;
   //--- Bounding box of the curve: start from chord endpoints, expand via sampled curve points
   double bMinX = MathMin(p1x, p2x);
   double bMaxX = MathMax(p1x, p2x);
   double bMinY = MathMin(p1y, p2y);
   double bMaxY = MathMax(p1y, p2y);
   //--- Sample the curve in 16 steps to find the true axis-aligned bounding box
   const int samp = 16;
   for(int i = 0; i <= samp; i++)
     {
      //--- Evaluate the Bezier curve at parameter t and expand the bounding box
      double t = (double)i / (double)samp;
      double cx_, cy_;
      ArcBezierEval(p1x, p1y, cpX, cpY, p2x, p2y, t, cx_, cy_);
      if(cx_ < bMinX) bMinX = cx_;
      if(cx_ > bMaxX) bMaxX = cx_;
      if(cy_ < bMinY) bMinY = cy_;
      if(cy_ > bMaxY) bMaxY = cy_;
     }
   //--- Integer bounding box with 2px AA padding
   int xLo = (int)MathFloor(bMinX) - 2;
   int xHi = (int)MathCeil (bMaxX) + 2;
   int yLo = (int)MathFloor(bMinY) - 2;
   int yHi = (int)MathCeil (bMaxY) + 2;
   //--- Cache canvas extents and clip the bounding box accordingly
   int cW = canvas.Width(), cH = canvas.Height();
   if(xLo < 0)    xLo = 0;
   if(yLo < 0)    yLo = 0;
   if(xHi >= cW)  xHi = cW - 1;
   if(yHi >= cH)  yHi = cH - 1;
   //--- Compose fill and border ARGB values + unpacked alpha/RGB masks
   const uint  fillArgb       = ColorWithPercentOpacity(fc, fillOpacity);
   const uint  borderFullArgb = ColorWithPercentOpacity(objColor, lineOpacity);
   const uint  borderRGBmask  = borderFullArgb & 0x00FFFFFF;
   const uchar borderBaseA    = (uchar)((borderFullArgb >> 24) & 0xFF);
   double halfThick = (double)thick * 0.5;
   //--- Chord unit-along (u) and unit-perpendicular (n) vectors
   double ux_c, uy_c, nx_c, ny_c;
   {
      double cLen = MathSqrt(chx * chx + chy * chy);
      ux_c = chx / cLen;  uy_c = chy / cLen;
      nx_c = -uy_c;       ny_c =  ux_c;
   }
   //--- Sample the Bezier curve into N line segments for the per-pixel distance + side-of-curve tests
   const int N = 64;
   double segAx[64], segAy[64], segBx[64], segBy[64];
   {
      //--- Walk every sample step and fill the segment endpoint arrays
      double prevX, prevY;
      ArcBezierEval(p1x, p1y, cpX, cpY, p2x, p2y, 0.0, prevX, prevY);
      for(int si = 0; si < N; si++)
        {
         //--- Current segment's end-of-segment point at parameter t
         double t = (double)(si + 1) / (double)N;
         double cx_, cy_;
         ArcBezierEval(p1x, p1y, cpX, cpY, p2x, p2y, t, cx_, cy_);
         segAx[si] = prevX; segAy[si] = prevY;
         segBx[si] = cx_;   segBy[si] = cy_;
         prevX = cx_; prevY = cy_;
        }
   }
   //--- Walk every pixel in the bounding box and compute fill + border coverage
   for(int yy = yLo; yy <= yHi; yy++)
     {
      for(int xx = xLo; xx <= xHi; xx++)
        {
         //--- Pixel relative to P1; decomposed into along-chord and perp-to-chord components
         double rx = (double)xx - p1x;
         double ry = (double)yy - p1y;
         double alongPx = rx * ux_c + ry * uy_c;
         //--- Signed perpendicular distance (positive on the apex side via signApex)
         double perpPx  = (rx * nx_c + ry * ny_c) * signApex;
         //--- Depth from the chord (positive inside the arc, negative outside)
         double depthChord = perpPx;
         //--- Find the minimum squared distance from the pixel to any of the curve's N sampled segments
         double dMin2 = 1e18;
         for(int si = 0; si < N; si++)
           {
            //--- Segment vector and squared length for the projection math
            double sdx = segBx[si] - segAx[si];
            double sdy = segBy[si] - segAy[si];
            double slen2 = sdx * sdx + sdy * sdy;
            //--- Project the pixel onto the segment; clamp parameter into [0, 1]
            double tSeg = 0.0;
            if(slen2 > 1e-12)
               tSeg = (((double)xx - segAx[si]) * sdx + ((double)yy - segAy[si]) * sdy) / slen2;
            if(tSeg < 0.0) tSeg = 0.0;
            if(tSeg > 1.0) tSeg = 1.0;
            //--- Compute the projected foot and its squared distance to the pixel
            double qx = segAx[si] + tSeg * sdx;
            double qy = segAy[si] + tSeg * sdy;
            double ddx = (double)xx - qx, ddy = (double)yy - qy;
            double d2 = ddx * ddx + ddy * ddy;
            //--- Track the minimum across all curve segments
            if(d2 < dMin2) dMin2 = d2;
           }
         //--- Convert minimum squared distance into actual distance to the curve
         double distCurve = MathSqrt(dMin2);
         //--- Determine the curve's perpendicular depth at the same along-chord coordinate (side-of-curve test)
         double curvePerp = 0.0;
         bool   found = false;
         for(int si = 0; si < N; si++)
           {
            //--- Each segment's along-chord range
            double ax_ = segAx[si], ay_ = segAy[si];
            double bx_ = segBx[si], by_ = segBy[si];
            double aA = (ax_ - p1x) * ux_c + (ay_ - p1y) * uy_c;
            double aB = (bx_ - p1x) * ux_c + (by_ - p1y) * uy_c;
            double lo = MathMin(aA, aB), hi = MathMax(aA, aB);
            //--- Test whether the pixel's along-chord coordinate falls inside this segment's range
            if(alongPx >= lo && alongPx <= hi)
              {
               //--- Interpolate along the segment to find the curve point at the same alongPx
               double rng = aB - aA;
               double tt  = (MathAbs(rng) > 1e-9) ? (alongPx - aA) / rng : 0.0;
               double cxs = ax_ + tt * (bx_ - ax_);
               double cys = ay_ + tt * (by_ - ay_);
               //--- Perpendicular depth of the curve at this along-chord position
               double rxc = cxs - p1x;
               double ryc = cys - p1y;
               double perpC = (rxc * nx_c + ryc * ny_c) * signApex;
               //--- Track the maximum curve depth across all matching segments
               if(perpC > curvePerp) curvePerp = perpC;
               found = true;
              }
           }
         //--- Chord length (cached for the along-range test below)
         double cLen2 = MathSqrt(chx * chx + chy * chy);
         //--- Along-chord range test: pixel must be within [0, chord-length]
         bool alongInRange = (alongPx >= 0.0 && alongPx <= cLen2);
         //--- Pixel is "inside" the arc region iff inside the chord X-range AND on the apex side of the curve
         bool insideCurveSide = found && alongInRange && (perpPx <= curvePerp);
         //--- Curve-depth signed distance (positive when inside, negative when outside)
         double depthCurve = insideCurveSide ? distCurve : -distCurve;
         //--- The smaller of chord-depth and curve-depth is the inside-region SDF value
         double depthInside = (depthChord < depthCurve) ? depthChord : depthCurve;
         //--- Fill coverage: depth-based smooth boundary at 0.5 transition
         double fillCov = 0.5 + depthInside;
         if(fillCov > 1.0) fillCov = 1.0;
         if(fillCov > 0.0)
           {
            //--- Compose the coverage-weighted fill alpha and blend the pixel
            const uchar fillBaseA = (uchar)((fillArgb >> 24) & 0xFF);
            uchar aFill = (uchar)((double)fillBaseA * fillCov + 0.5);
            uint  argb  = ((uint)aFill << 24) | (fillArgb & 0x00FFFFFF);
            ChannelBlendPixelSet(canvas, xx, yy, argb);
           }
         //--- Border coverage: only nonzero near the curve
         if(distCurve <= halfThick + 0.5)
           {
            //--- Coverage shrinks linearly with distance from the curve centerline
            double cov = halfThick + 0.5 - distCurve;
            if(cov > 1.0) cov = 1.0;
            if(cov > 0.0)
              {
               //--- Compose the coverage-weighted border alpha and blend the pixel
               uchar aCov = (uchar)((double)borderBaseA * cov + 0.5);
               uint  covArgb = ((uint)aCov << 24) | borderRGBmask;
               ChannelBlendPixelSet(canvas, xx, yy, covArgb);
              }
           }
        }
     }
   //--- 3 handles when selected or hovered: P1, P2, and the CLAMPED apex
   if(selected || hovered)
     {
      //--- Round the clamped apex to integer pixel coords for the handle (idx 2 lands on the curve midpoint)
      int iApX = (int)MathRound(apX);
      int iApY = (int)MathRound(apY);
      //--- Render handles honoring hide/halo state
      if(m_hideHandleIdx != 0) DrawHandleOnCanvas(canvas, x1, y1, selected, objColor, m_haloHandleIdx == 0);
      if(m_hideHandleIdx != 1) DrawHandleOnCanvas(canvas, x2, y2, selected, objColor, m_haloHandleIdx == 1);
      if(m_hideHandleIdx != 2) DrawHandleOnCanvas(canvas, iApX, iApY, selected, objColor, m_haloHandleIdx == 2);
     }
  }

//+------------------------------------------------------------------+
//| Hit-test Arc: cursor near the curve OR inside the enclosed region|
//+------------------------------------------------------------------+
bool CShapeTools::HitTestArc(int mx, int my, int x1, int y1, int x2, int y2, int x3, int y3,
                              int threshold)
  {
   //--- Compute the clamped apex and the Bezier control X via the helper; reject degenerate chords
   double apX = 0, apY = 0, cpX = 0;
   if(!ArcCircumcircle(x1, y1, x2, y2, x3, y3, apX, apY, cpX)) return false;
   //--- CP.y is the mirror of the chord midpoint Y through the apex Y
   double cpY = 2.0 * apY - 0.5 * ((double)y1 + (double)y2);
   //--- Cache endpoint coords as doubles
   double p1x = (double)x1, p1y = (double)y1;
   double p2x = (double)x2, p2y = (double)y2;
   //--- Approximate distance from the cursor to the Bezier curve
   double d = ArcDistToBezier((double)mx, (double)my, p1x, p1y, cpX, cpY, p2x, p2y);
   //--- Cursor within threshold of the curve always counts
   if(d <= threshold) return true;
   //--- Otherwise test whether the cursor sits in the enclosed (chord-to-curve) region
   double chx = p2x - p1x;
   double chy = p2y - p1y;
   //--- Side of the chord that the apex sits on (sign of the cross product)
   double sideApex = chx * (apY - p1y) - chy * (apX - p1x);
   if(MathAbs(sideApex) < 1e-9) return false;
   double signApex = (sideApex >= 0.0) ? 1.0 : -1.0;
   //--- Side of the chord that the cursor sits on; reject if opposite the apex
   double sideM = chx * ((double)my - p1y) - chy * ((double)mx - p1x);
   if(sideM * signApex < 0.0) return false;
   //--- Chord length (reject degenerate chords)
   double cLen = MathSqrt(chx * chx + chy * chy);
   if(cLen < 1e-9) return false;
   //--- Chord unit-along (u) and unit-perpendicular (n) vectors
   double ux_c = chx / cLen, uy_c = chy / cLen;
   double nx_c = -uy_c,      ny_c =  ux_c;
   //--- Cursor decomposed into along-chord and signed perp-to-chord components
   double alongPx = ((double)mx - p1x) * ux_c + ((double)my - p1y) * uy_c;
   double perpPx  = (((double)mx - p1x) * nx_c + ((double)my - p1y) * ny_c) * signApex;
   //--- Along-chord range test: cursor must be within [0, chord-length]
   if(alongPx < 0.0 || alongPx > cLen) return false;
   //--- Determine the curve's perpendicular depth at the cursor's along-chord position
   const int N = 64;
   double prevX, prevY;
   ArcBezierEval(p1x, p1y, cpX, cpY, p2x, p2y, 0.0, prevX, prevY);
   double curvePerp = 0.0;
   for(int si = 0; si < N; si++)
     {
      //--- Sample the curve at parameter t for this segment's endpoint
      double t = (double)(si + 1) / (double)N;
      double cx_, cy_;
      ArcBezierEval(p1x, p1y, cpX, cpY, p2x, p2y, t, cx_, cy_);
      //--- Along-chord range of this segment
      double aA = (prevX - p1x) * ux_c + (prevY - p1y) * uy_c;
      double aB = (cx_   - p1x) * ux_c + (cy_   - p1y) * uy_c;
      double lo = MathMin(aA, aB), hi = MathMax(aA, aB);
      //--- Does the cursor's along-chord position fall in this segment's range?
      if(alongPx >= lo && alongPx <= hi)
        {
         //--- Interpolate along the segment to find the curve point at the same alongPx
         double rng = aB - aA;
         double tt  = (MathAbs(rng) > 1e-9) ? (alongPx - aA) / rng : 0.0;
         double cxs = prevX + tt * (cx_ - prevX);
         double cys = prevY + tt * (cy_ - prevY);
         //--- Perpendicular depth of the curve at this along-chord position
         double perpC = ((cxs - p1x) * nx_c + (cys - p1y) * ny_c) * signApex;
         //--- Track the maximum curve depth across matching segments
         if(perpC > curvePerp) curvePerp = perpC;
        }
      prevX = cx_; prevY = cy_;
     }
   //--- Cursor is inside the enclosed region iff its perp depth is between 0 (chord) and curvePerp (curve)
   return (perpPx >= 0.0 && perpPx <= curvePerp);
  }

//+------------------------------------------------------------------+
//| Draw a Curve (quadratic Bezier with FREE apex, no fill, no chord)|
//+------------------------------------------------------------------+
void CShapeTools::DrawCurveOn(CCanvas &canvas,
                               int x1, int y1, int x2, int y2, int x3, int y3,
                               color objColor, bool selected, bool hovered,
                               int lineWidth, int lineOpacity,
                               int lineStyle)
  {
   //--- Clamp line width into the [1, 4] px range
   if(lineWidth < 1) lineWidth = 1;
   if(lineWidth > 4) lineWidth = 4;
   const int thick = lineWidth;
   //--- Cache endpoint and apex coords as doubles for the Bezier math
   double p1x = (double)x1, p1y = (double)y1;
   double p2x = (double)x2, p2y = (double)y2;
   double p3x = (double)x3, p3y = (double)y3;
   //--- Chord vector and length (used to reject degenerate curves below)
   double chx = p2x - p1x;
   double chy = p2y - p1y;
   double chordLen = MathSqrt(chx * chx + chy * chy);
   //--- Chord midpoint (used to compute the reflected control point)
   double midX = 0.5 * (p1x + p2x);
   double midY = 0.5 * (p1y + p2y);
   //--- Bezier control point = reflection of midpoint through the free apex P3
   double cpX  = 2.0 * p3x - midX;
   double cpY  = 2.0 * p3y - midY;
   //--- Render the curve only when the chord is not degenerate
   if(chordLen >= 2.0)
     {
      //--- Sample the Bezier curve into N line segments for the per-pixel distance loop
      const int N = 64;
      double segAx[64], segAy[64], segBx[64], segBy[64];
      {
         //--- Walk every sample step and fill the segment endpoint arrays
         double prevX, prevY;
         ArcBezierEval(p1x, p1y, cpX, cpY, p2x, p2y, 0.0, prevX, prevY);
         for(int si = 0; si < N; si++)
           {
            //--- Evaluate the curve at parameter t for the current segment endpoint
            double t = (double)(si + 1) / (double)N;
            double cx_, cy_;
            ArcBezierEval(p1x, p1y, cpX, cpY, p2x, p2y, t, cx_, cy_);
            segAx[si] = prevX; segAy[si] = prevY;
            segBx[si] = cx_;   segBy[si] = cy_;
            prevX = cx_; prevY = cy_;
           }
      }
      //--- Bounding box of the curve from the sampled segment endpoints
      double bMinX = segAx[0], bMaxX = segAx[0];
      double bMinY = segAy[0], bMaxY = segAy[0];
      for(int si = 0; si < N; si++)
        {
         //--- Expand the bounding box from both endpoints of each segment
         if(segAx[si] < bMinX) bMinX = segAx[si];
         if(segAx[si] > bMaxX) bMaxX = segAx[si];
         if(segAy[si] < bMinY) bMinY = segAy[si];
         if(segAy[si] > bMaxY) bMaxY = segAy[si];
         if(segBx[si] < bMinX) bMinX = segBx[si];
         if(segBx[si] > bMaxX) bMaxX = segBx[si];
         if(segBy[si] < bMinY) bMinY = segBy[si];
         if(segBy[si] > bMaxY) bMaxY = segBy[si];
        }
      //--- Integer bounding box with 2px AA padding
      int xLo = (int)MathFloor(bMinX) - 2;
      int xHi = (int)MathCeil (bMaxX) + 2;
      int yLo = (int)MathFloor(bMinY) - 2;
      int yHi = (int)MathCeil (bMaxY) + 2;
      //--- Cache canvas extents and clip the bounding box accordingly
      int cW = canvas.Width(), cH = canvas.Height();
      if(xLo < 0)    xLo = 0;
      if(yLo < 0)    yLo = 0;
      if(xHi >= cW)  xHi = cW - 1;
      if(yHi >= cH)  yHi = cH - 1;
      //--- Compose border ARGB and unpack alpha + RGB mask for coverage-weighted blending
      const uint  borderFullArgb = ColorWithPercentOpacity(objColor, lineOpacity);
      const uint  borderRGBmask  = borderFullArgb & 0x00FFFFFF;
      const uchar borderBaseA    = (uchar)((borderFullArgb >> 24) & 0xFF);
      double halfThick = (double)thick * 0.5;
      //--- Walk every pixel in the bounding box and compute its curve coverage
      for(int yy = yLo; yy <= yHi; yy++)
        {
         for(int xx = xLo; xx <= xHi; xx++)
           {
            //--- Find the minimum squared distance from the pixel to any of the N sampled segments
            double dMin2 = 1e18;
            for(int si = 0; si < N; si++)
              {
               //--- Segment vector and squared length for the projection math
               double sdx = segBx[si] - segAx[si];
               double sdy = segBy[si] - segAy[si];
               double slen2 = sdx * sdx + sdy * sdy;
               //--- Project the pixel onto the segment; clamp parameter into [0, 1]
               double tSeg = 0.0;
               if(slen2 > 1e-12)
                  tSeg = (((double)xx - segAx[si]) * sdx + ((double)yy - segAy[si]) * sdy) / slen2;
               if(tSeg < 0.0) tSeg = 0.0;
               if(tSeg > 1.0) tSeg = 1.0;
               //--- Compute the projected foot and its squared distance to the pixel
               double qx = segAx[si] + tSeg * sdx;
               double qy = segAy[si] + tSeg * sdy;
               double ddx = (double)xx - qx, ddy = (double)yy - qy;
               double d2 = ddx * ddx + ddy * ddy;
               //--- Track the minimum across all curve segments
               if(d2 < dMin2) dMin2 = d2;
              }
            //--- Convert minimum squared distance into actual distance to the curve
            double dist = MathSqrt(dMin2);
            //--- Skip pixels too far from the curve for the AA boundary
            if(dist > halfThick + 0.5) continue;
            //--- Coverage shrinks linearly with distance from the curve centerline
            double cov = halfThick + 0.5 - dist;
            if(cov > 1.0) cov = 1.0;
            if(cov <= 0.0) continue;
            //--- Compose the coverage-weighted alpha and blend the pixel
            uchar aCov = (uchar)((double)borderBaseA * cov + 0.5);
            uint  covArgb = ((uint)aCov << 24) | borderRGBmask;
            ChannelBlendPixelSet(canvas, xx, yy, covArgb);
           }
        }
     }
   //--- 3 handles when selected or hovered: P1, P2, P3 (free apex, no clamp)
   if(selected || hovered)
     {
      if(m_hideHandleIdx != 0) DrawHandleOnCanvas(canvas, x1, y1, selected, objColor, m_haloHandleIdx == 0);
      if(m_hideHandleIdx != 1) DrawHandleOnCanvas(canvas, x2, y2, selected, objColor, m_haloHandleIdx == 1);
      if(m_hideHandleIdx != 2) DrawHandleOnCanvas(canvas, x3, y3, selected, objColor, m_haloHandleIdx == 2);
     }
  }

//+------------------------------------------------------------------+
//| Hit-test Curve: cursor within threshold of the Bezier curve      |
//+------------------------------------------------------------------+
bool CShapeTools::HitTestCurve(int mx, int my, int x1, int y1, int x2, int y2, int x3, int y3,
                                int threshold)
  {
   //--- Cache endpoint and apex coords as doubles for the Bezier math
   double p1x = (double)x1, p1y = (double)y1;
   double p2x = (double)x2, p2y = (double)y2;
   double p3x = (double)x3, p3y = (double)y3;
   //--- Chord vector and length; reject degenerate curves
   double chx = p2x - p1x;
   double chy = p2y - p1y;
   double chordLen = MathSqrt(chx * chx + chy * chy);
   if(chordLen < 2.0) return false;
   //--- Chord midpoint and the Bezier control point (reflection of midpoint through apex P3)
   double midX = 0.5 * (p1x + p2x);
   double midY = 0.5 * (p1y + p2y);
   double cpX  = 2.0 * p3x - midX;
   double cpY  = 2.0 * p3y - midY;
   //--- Approximate distance from the cursor to the Bezier curve via 64-segment sampling
   double d = ArcDistToBezier((double)mx, (double)my, p1x, p1y, cpX, cpY, p2x, p2y);
   //--- Hit iff cursor is within threshold pixels of the curve
   return (d <= threshold);
  }

#endif // TOOLS_PALETTE_SHAPES_MQH
//+------------------------------------------------------------------+