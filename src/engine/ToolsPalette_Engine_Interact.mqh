//+------------------------------------------------------------------+
//|                                 ToolsPalette_Engine_Interact.mqh |
//|                                            Copyright 2026, Om J. |
//|                                               https://t.me/HZFXI |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Om J."
#property link "https://t.me/HZFXI"
#property version "1.00"
#property strict

//--- Guard against multiple inclusion of this header
#ifndef TOOLS_PALETTE_ENGINE_INTERACT_MQH
#define TOOLS_PALETTE_ENGINE_INTERACT_MQH

//--- Pull in CDrawingEngine class declaration (Tools.mqh include guard handles double-load)
#include "../core/ToolsPalette_Tools.mqh"

//+------------------------------------------------------------------+
//| CDrawingEngine method bodies for the pointer-mode interaction    |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Test whether a point lies inside a convex quad (rotated rect)    |
//+------------------------------------------------------------------+
bool CDrawingEngine::PointInRotatedRect(int px, int py, const int &cx[], const int &cy[])
  {
   //--- Track whether any positive or negative cross-products have been seen
   bool anyPos = false, anyNeg = false;
   //--- Walk all 4 quad edges in winding order with wrap-around closure
   for(int i = 0; i < 4; i++)
     {
      int j = (i + 1) % 4;
      //--- Edge vector from corner i to corner j
      int ex = cx[j] - cx[i];
      int ey = cy[j] - cy[i];
      //--- Vector from corner i to the test point
      int fx = px - cx[i];
      int fy = py - cy[i];
      //--- 2D cross product (z-component) of the edge with the corner-to-point vector
      long crossZ = (long)ex * fy - (long)ey * fx;
      if(crossZ > 0) anyPos = true;
      if(crossZ < 0) anyNeg = true;
      //--- Early exit: if both signs appear, the point lies outside the convex quad
      if(anyPos && anyNeg) return false;
     }
   return true;
  }

//+------------------------------------------------------------------+
//| Hit-test the rectangle interior (including a hit-threshold band) |
//+------------------------------------------------------------------+
bool CDrawingEngine::HitTestRectangle(int mx, int my, int x1, int y1, int x2, int y2)
  {
   //--- Normalize the rectangle to canonical left/right and top/bottom
   int lx = MathMin(x1,x2), rx = MathMax(x1,x2);
   int ty = MathMin(y1,y2), by = MathMax(y1,y2);
   //--- Translucent fill makes the entire interior plus a hit-threshold band hittable
   return (mx >= lx - m_hitThreshold && mx <= rx + m_hitThreshold &&
           my >= ty - m_hitThreshold && my <= by + m_hitThreshold);
  }

//+------------------------------------------------------------------+
//| Hit-test the ellipse border circumference at the hit threshold   |
//+------------------------------------------------------------------+
bool CDrawingEngine::HitTestEllipse(int mx, int my, int cx, int cy, int rx, int ry)
  {
   //--- Reject degenerate axis-aligned ellipses with zero radii
   if(rx < 1 || ry < 1) return false;
   //--- Compute the normalized distance from the center (1.0 = on the border)
   double dx = (double)(mx - cx) / rx;
   double dy = (double)(my - cy) / ry;
   double dist = MathSqrt(dx*dx + dy*dy);
   //--- Convert the pixel hit threshold into normalized space approximately
   double normThresh = (double)m_hitThreshold / MathMin(rx, ry);
   return MathAbs(dist - 1.0) <= normThresh;
  }

//+------------------------------------------------------------------+
//| Hit-test object handles and return the matched handle index      |
//+------------------------------------------------------------------+
int CDrawingEngine::HitTestHandles(int mx, int my, int objIdx)
  {
   //--- Reject invalid object indices
   if(objIdx < 0 || objIdx >= ArraySize(m_drawnObjects)) return -1;
   //--- Cache pixel positions of the three primary anchor points
   int hx1=0,hy1=0,hx2=0,hy2=0,hx3=0,hy3=0;
   ChartTimePriceToXY(m_chartId,0,m_drawnObjects[objIdx].time1,m_drawnObjects[objIdx].price1,hx1,hy1);
   //--- HLine handle renders 150px in from the right edge; mirror that for hit-test
   if(m_drawnObjects[objIdx].toolType == TOOL_HLINE)
     {
      int cW = m_canvasDrawings.Width();
      hx1 = cW - 150;
      if(hx1 < 20) hx1 = cW - 20;
     }
   //--- VLine handle renders 150px up from the bottom edge; mirror that for hit-test
   else if(m_drawnObjects[objIdx].toolType == TOOL_VLINE)
     {
      int cH = m_canvasDrawings.Height();
      hy1 = cH - 150;
      if(hy1 < 20) hy1 = cH - 20;
     }
   //--- Circle: 2 handles - center (idx 0) and border (idx 1)
   if(m_drawnObjects[objIdx].toolType == TOOL_CIRCLE)
     {
      //--- Read the border anchor and test it first (always hittable)
      ChartTimePriceToXY(m_chartId,0,m_drawnObjects[objIdx].time2,m_drawnObjects[objIdx].price2,hx2,hy2);
      if(MathAbs(mx - hx2) <= 10 && MathAbs(my - hy2) <= 10) return 1;
      //--- Center handle visibility mirrors the render-loop's hide-logic exactly
      bool hasText = StringLen(m_drawnObjects[objIdx].labelText) > 0;
      bool isSel   = (m_drawnObjects[objIdx].id == m_selectedObjectId);
      bool isHov   = (m_drawnObjects[objIdx].id == m_hoveredObjectId);
      //--- Detect whether the cursor is on another handle of this same object
      bool cursorOnHandleForThisObj = (m_hoveredHandleHostId == m_drawnObjects[objIdx].id &&
                                        m_hoveredHandleIdx >= 0);
      //--- Detect whether any drag is currently in progress on the engine
      bool anyDragging_ = (m_isDraggingHandle || m_isDraggingObject);
      //--- Re-derive the prompt-shown condition from the same flags the renderer uses
      bool showingPrompt = isSel && isHov && !hasText && !m_isEditingLabel &&
                            !cursorOnHandleForThisObj && !anyDragging_;
      bool activelyEditing = m_isEditingLabel && isSel;
      bool centerHidden = hasText || showingPrompt || activelyEditing;
      //--- Center handle hits only when the center handle is visible
      if(!centerHidden &&
         MathAbs(mx - hx1) <= 10 && MathAbs(my - hy1) <= 10) return 0;
      return -1;
     }
   //--- Arc: 3 handles - idx 0/1 chord ends fall through to generic test; idx 2 is the apex
   if(m_drawnObjects[objIdx].toolType == TOOL_ARC &&
      m_drawnObjects[objIdx].time2 != 0 &&
      m_drawnObjects[objIdx].time3 != 0)
     {
      //--- Read pixel positions for the chord endpoints and the stored apex
      ChartTimePriceToXY(m_chartId,0,m_drawnObjects[objIdx].time2,m_drawnObjects[objIdx].price2,hx2,hy2);
      ChartTimePriceToXY(m_chartId,0,m_drawnObjects[objIdx].time3,m_drawnObjects[objIdx].price3,hx3,hy3);
      //--- Compute the chord vector and length
      double chx = (double)(hx2 - hx1);
      double chy = (double)(hy2 - hy1);
      double cLen = MathSqrt(chx * chx + chy * chy);
      if(cLen >= 2.0)
        {
         //--- Build chord-unit and perpendicular-unit vectors
         double ux = chx / cLen, uy = chy / cLen;
         double nx = -uy,        ny =  ux;
         //--- Compute the chord midpoint and the stored apex perpendicular component
         double midX = 0.5 * ((double)hx1 + (double)hx2);
         double midY = 0.5 * ((double)hy1 + (double)hy2);
         double perp = ((double)hx3 - midX) * nx + ((double)hy3 - midY) * ny;
         //--- Place the apex handle on the perpendicular bisector at the stored bulge
         int apxX = (int)MathRound(midX + perp * nx);
         int apxY = (int)MathRound(midY + perp * ny);
         if(MathAbs(mx - apxX) <= 10 && MathAbs(my - apxY) <= 10) return 2;
        }
     }
   //--- Path: N vertex handles - one per pathTimes[] entry, early-return on no match
   if(m_drawnObjects[objIdx].toolType == TOOL_PATH)
     {
      int N = ArraySize(m_drawnObjects[objIdx].pathTimes);
      for(int pi = 0; pi < N; pi++)
        {
         //--- Map this vertex to screen coords and test against the cursor
         int pxx=0, pyy=0;
         ChartTimePriceToXY(m_chartId, 0,
                             m_drawnObjects[objIdx].pathTimes[pi],
                             m_drawnObjects[objIdx].pathPrices[pi],
                             pxx, pyy);
         if(MathAbs(mx - pxx) <= 10 && MathAbs(my - pyy) <= 10)
            return pi;
        }
      return -1;
     }
   //--- Rotated Rectangle: 6 derived handles in canonical visual ordering
   if(m_drawnObjects[objIdx].toolType == TOOL_ROTATED_RECTANGLE &&
      m_drawnObjects[objIdx].time2 != 0 &&
      m_drawnObjects[objIdx].time3 != 0)
     {
      //--- Read pixel positions for the three stored anchors
      ChartTimePriceToXY(m_chartId,0,m_drawnObjects[objIdx].time2,m_drawnObjects[objIdx].price2,hx2,hy2);
      ChartTimePriceToXY(m_chartId,0,m_drawnObjects[objIdx].time3,m_drawnObjects[objIdx].price3,hx3,hy3);
      //--- Derive the 6 visual handle positions and test each one
      int hX[], hY[];
      ComputeRotatedRectHandles(hx1, hy1, hx2, hy2, hx3, hy3, hX, hY);
      for(int hi = 0; hi < 6; hi++)
         if(MathAbs(mx - hX[hi]) <= 10 && MathAbs(my - hY[hi]) <= 10)
            return hi;
      return -1;
     }
   //--- Rotated Ellipse: 4 handles - idx 0/1 fall through; idx 2/3 are derived minor-axis ends
   if(m_drawnObjects[objIdx].toolType == TOOL_ELLIPSE &&
      m_drawnObjects[objIdx].time2 != 0 &&
      m_drawnObjects[objIdx].time3 != 0)
     {
      //--- Read pixel positions for the three stored anchors
      ChartTimePriceToXY(m_chartId,0,m_drawnObjects[objIdx].time2,m_drawnObjects[objIdx].price2,hx2,hy2);
      ChartTimePriceToXY(m_chartId,0,m_drawnObjects[objIdx].time3,m_drawnObjects[objIdx].price3,hx3,hy3);
      //--- Compute ellipse center as the midpoint of P1-P2
      double cx = (hx1 + hx2) * 0.5;
      double cy = (hy1 + hy2) * 0.5;
      //--- Build the major-axis unit vector from the P1-P2 length
      double dxM = (double)(hx2 - hx1);
      double dyM = (double)(hy2 - hy1);
      double lenM = MathSqrt(dxM * dxM + dyM * dyM);
      if(lenM >= 2.0)
        {
         //--- Major-axis cosine and sine
         double cosT = dxM / lenM;
         double sinT = dyM / lenM;
         //--- Compute the perpendicular distance from P3 to the major axis (signed)
         double dx3p = (double)hx3 - cx;
         double dy3p = (double)hy3 - cy;
         double perpSide = -dx3p * sinT + dy3p * cosT;
         //--- Extract the minor-axis half-length and its sign
         double b = MathAbs(perpSide);
         if(b < 1.0) b = 1.0;
         double signP3 = (perpSide >= 0.0) ? 1.0 : -1.0;
         //--- Compute the perpendicular direction in the signP3 side
         double perpX = -sinT * signP3;
         double perpY =  cosT * signP3;
         //--- Compute the + and - minor-axis endpoints in screen space
         int m2x = (int)MathRound(cx + perpX * b);
         int m2y = (int)MathRound(cy + perpY * b);
         int m3x = (int)MathRound(cx - perpX * b);
         int m3y = (int)MathRound(cy - perpY * b);
         //--- Test the derived minor-axis endpoints against the cursor
         if(MathAbs(mx - m2x) <= 10 && MathAbs(my - m2y) <= 10) return 2;
         if(MathAbs(mx - m3x) <= 10 && MathAbs(my - m3y) <= 10) return 3;
        }
      //--- idx 0 and 1 (P1, P2) fall through to the generic anchor test below
     }
   //--- Generic anchor tests for tools that don't have a dedicated branch above
   if(MathAbs(mx-hx1)<=10 && MathAbs(my-hy1)<=10) return 0;
   if(m_drawnObjects[objIdx].time2!=0)
     {
      //--- Read P2 and test it
      ChartTimePriceToXY(m_chartId,0,m_drawnObjects[objIdx].time2,m_drawnObjects[objIdx].price2,hx2,hy2);
      if(MathAbs(mx-hx2)<=10 && MathAbs(my-hy2)<=10) return 1;
     }
   if(m_drawnObjects[objIdx].time3!=0)
     {
      //--- Read P3 and test it
      ChartTimePriceToXY(m_chartId,0,m_drawnObjects[objIdx].time3,m_drawnObjects[objIdx].price3,hx3,hy3);
      if(MathAbs(mx-hx3)<=10 && MathAbs(my-hy3)<=10) return 2;
     }
   //--- Parallel Channel: 3 extra handles beyond A/B/C - derived D plus two mid-line handles
   if(m_drawnObjects[objIdx].toolType == TOOL_PARALLEL_CHANNEL &&
      m_drawnObjects[objIdx].time3 != 0)
     {
      //--- D corner derived from A, B, C: D = B + (C - A)
      int hx4 = hx2 + (hx3 - hx1);
      int hy4 = hy2 + (hy3 - hy1);
      if(MathAbs(mx-hx4)<=10 && MathAbs(my-hy4)<=10) return 3;
      //--- Top-line mid-handle at the A-B midpoint
      int mABx = (hx1 + hx2) / 2, mABy = (hy1 + hy2) / 2;
      if(MathAbs(mx-mABx)<=10 && MathAbs(my-mABy)<=10) return 4;
      //--- Bottom-line mid-handle at the C-D midpoint
      int mCDx = (hx3 + hx4) / 2, mCDy = (hy3 + hy4) / 2;
      if(MathAbs(mx-mCDx)<=10 && MathAbs(my-mCDy)<=10) return 5;
     }
   //--- Regression / StdDev Channel: 2 dashed-center-line endpoints (re-derived from bar data)
   if((m_drawnObjects[objIdx].toolType == TOOL_REGRESSION_CHANNEL ||
       m_drawnObjects[objIdx].toolType == TOOL_STDDEV_CHANNEL) &&
      m_drawnObjects[objIdx].time1 != 0 &&
      m_drawnObjects[objIdx].time2 != 0)
     {
      //--- Resolve the chronologically left and right time anchors
      datetime t1 = m_drawnObjects[objIdx].time1;
      datetime t2 = m_drawnObjects[objIdx].time2;
      datetime tL = (t1 < t2) ? t1 : t2;
      datetime tR = (t1 < t2) ? t2 : t1;
      //--- Map the times to bar indices and ensure barL is the older one
      int barR = iBarShift(_Symbol, _Period, tR, false);
      int barL = iBarShift(_Symbol, _Period, tL, false);
      if(barL < barR) { int tmp = barL; barL = barR; barR = tmp; }
      int nBars = barL - barR + 1;
      if(nBars >= 2)
        {
         //--- Recompute the OLS regression sums over bars in the range
         double Sx = 0, Sy = 0, Sxx = 0, Sxy = 0;
         for(int i = 0; i < nBars; i++)
           {
            //--- Read the close price at this bar offset
            int shift = barL - i;
            double cls = iClose(_Symbol, _Period, shift);
            //--- Skip bars with no valid close price
            if(cls == 0.0) continue;
            //--- Accumulate the OLS sums for this sample
            double x = (double)i;
            Sx += x; Sy += cls; Sxx += x*x; Sxy += x*cls;
           }
         //--- Compute the regression slope and intercept (skip on degenerate variance)
         double dn = (double)nBars;
         double denom = dn*Sxx - Sx*Sx;
         if(MathAbs(denom) >= 1e-12)
           {
            double slope = (dn*Sxy - Sx*Sy) / denom;
            double intercept = (Sy - slope*Sx) / dn;
            //--- Recover bar datetimes and compute the center-line endpoint prices
            datetime leftTime  = (datetime)iTime(_Symbol, _Period, barL);
            datetime rightTime = (datetime)iTime(_Symbol, _Period, barR);
            double leftCP  = intercept;
            double rightCP = slope*(double)(nBars-1) + intercept;
            //--- Map the endpoints to canvas pixel coordinates
            int xL_p=0, yLc=0, xR_p=0, yRc=0;
            ChartTimePriceToXY(m_chartId, 0, leftTime,  leftCP,  xL_p, yLc);
            ChartTimePriceToXY(m_chartId, 0, rightTime, rightCP, xR_p, yRc);
            //--- idx 0 = left center endpoint
            if(MathAbs(mx - xL_p) <= 10 && MathAbs(my - yLc) <= 10) return 0;
            //--- idx 1 = right center endpoint
            if(MathAbs(mx - xR_p) <= 10 && MathAbs(my - yRc) <= 10) return 1;
           }
        }
     }
   //--- Gann Box: 4 handles - P1 (0), P2 (1) above; idx 2/3 are the two cross-corners
   if(m_drawnObjects[objIdx].toolType == TOOL_GANN_BOX &&
      m_drawnObjects[objIdx].time1 != 0 &&
      m_drawnObjects[objIdx].time2 != 0)
     {
      //--- Cross-corner (P1.x, P2.y): drags P1's X and P2's Y
      int hxCross2 = hx1, hyCross2 = hy2;
      if(MathAbs(mx - hxCross2) <= 10 && MathAbs(my - hyCross2) <= 10) return 2;
      //--- Cross-corner (P2.x, P1.y): drags P2's X and P1's Y
      int hxCross3 = hx2, hyCross3 = hy1;
      if(MathAbs(mx - hxCross3) <= 10 && MathAbs(my - hyCross3) <= 10) return 3;
     }
   //--- Rectangle: 8 handles - idx 0/1 stored corners, 2/3 cross-corners, 4-7 edge midpoints
   if(m_drawnObjects[objIdx].toolType == TOOL_RECTANGLE &&
      m_drawnObjects[objIdx].time1 != 0 &&
      m_drawnObjects[objIdx].time2 != 0)
     {
      //--- idx 2 = (P1.x, P2.y) cross-corner
      int hxCross2r = hx1, hyCross2r = hy2;
      if(MathAbs(mx - hxCross2r) <= 10 && MathAbs(my - hyCross2r) <= 10) return 2;
      //--- idx 3 = (P2.x, P1.y) cross-corner
      int hxCross3r = hx2, hyCross3r = hy1;
      if(MathAbs(mx - hxCross3r) <= 10 && MathAbs(my - hyCross3r) <= 10) return 3;
      //--- Normalize for the edge midpoints so visual top/right/bottom/left stay consistent
      int xLr = (hx1 < hx2) ? hx1 : hx2;
      int xRr = (hx1 < hx2) ? hx2 : hx1;
      int yTr = (hy1 < hy2) ? hy1 : hy2;
      int yBr = (hy1 < hy2) ? hy2 : hy1;
      //--- Compute the box center for the midpoint X/Y tests
      int midXr = (hx1 + hx2) / 2;
      int midYr = (hy1 + hy2) / 2;
      //--- TOP edge midpoint
      if(MathAbs(mx - midXr) <= 10 && MathAbs(my - yTr)   <= 10) return 4;
      //--- RIGHT edge midpoint
      if(MathAbs(mx - xRr)   <= 10 && MathAbs(my - midYr) <= 10) return 5;
      //--- BOTTOM edge midpoint
      if(MathAbs(mx - midXr) <= 10 && MathAbs(my - yBr)   <= 10) return 6;
      //--- LEFT edge midpoint
      if(MathAbs(mx - xLr)   <= 10 && MathAbs(my - midYr) <= 10) return 7;
     }
   return -1;
  }

//+------------------------------------------------------------------+
//| Iterate all drawn objects and return the topmost ID under cursor |
//+------------------------------------------------------------------+
int CDrawingEngine::HitTestAllObjects(int mouseX, int mouseY)
  {
   //--- Walk the objects in reverse so the most recently drawn wins on overlap
   int n = ArraySize(m_drawnObjects);
   for(int i = n-1; i >= 0; i--)
     {
      //--- Skip hidden objects
      if(!m_drawnObjects[i].visible) continue;
      //--- Read pixel positions for the three primary anchor points
      int x1=0,y1=0,x2=0,y2=0,x3=0,y3=0;
      ChartTimePriceToXY(m_chartId,0,m_drawnObjects[i].time1,m_drawnObjects[i].price1,x1,y1);
      if(m_drawnObjects[i].time2!=0)
         ChartTimePriceToXY(m_chartId,0,m_drawnObjects[i].time2,m_drawnObjects[i].price2,x2,y2);
      if(m_drawnObjects[i].time3!=0)
         ChartTimePriceToXY(m_chartId,0,m_drawnObjects[i].time3,m_drawnObjects[i].price3,x3,y3);
      //--- Dispatch to the tool-specific hit-test routine and remember the result
      bool hit = false;
      switch(m_drawnObjects[i].toolType)
        {
         //--- Trend / Ray / Extended / Trend Angle all use the same segment-distance test
         case TOOL_TRENDLINE:
         case TOOL_RAY:
         case TOOL_EXTENDED_LINE:
         case TOOL_TREND_ANGLE:
            hit = HitTestTrendLine(mouseX,mouseY,x1,y1,x2,y2,m_hitThreshold); break;
         //--- Info Line: line body OR floating info panel both count as hits
         case TOOL_INFO_LINE:
            hit = HitTestTrendLine(mouseX,mouseY,x1,y1,x2,y2,m_hitThreshold) ||
                  HitTestInfoLinePanel(mouseX,mouseY); break;
         //--- Horizontal line: row-distance test only
         case TOOL_HLINE:
            hit = HitTestHorizontalLine(mouseX,mouseY,y1,m_hitThreshold); break;
         //--- Vertical line: column-distance test only
         case TOOL_VLINE:
            hit = HitTestVerticalLine(mouseX,mouseY,x1,m_hitThreshold); break;
         //--- Cross line: hit if cursor is near EITHER the horizontal or vertical leg
         case TOOL_CROSS_LINE:
            hit = HitTestHorizontalLine(mouseX,mouseY,y1,m_hitThreshold) ||
                  HitTestVerticalLine(mouseX,mouseY,x1,m_hitThreshold); break;
         //--- Rectangle: interior plus hit-threshold band
         case TOOL_RECTANGLE:
            hit = HitTestRectangle(mouseX,mouseY,x1,y1,x2,y2); break;
         //--- Text annotation: delegated so the box math lives in one place
         case TOOL_TEXT:
           {
            bool isEdit = (m_isEditingLabel &&
                            m_drawnObjects[i].id == m_selectedObjectId);
            hit = HitTestTextAnnotation(mouseX, mouseY, x1, y1,
                                         m_drawnObjects[i].labelText,
                                         isEdit, m_labelEditBuffer,
                                         m_drawnObjects[i].fontSize,
                                         m_drawnObjects[i].bold);
            break;
           }
         //--- Rotated Rectangle: convex-quad interior plus edge proximity
         case TOOL_ROTATED_RECTANGLE:
            hit = HitTestRotatedRectangle(mouseX, mouseY, x1, y1, x2, y2, x3, y3, m_hitThreshold); break;
         //--- Arc: enclosed region (circle interior intersect P3-side) plus arc border
         case TOOL_ARC:
            hit = HitTestArc(mouseX, mouseY, x1, y1, x2, y2, x3, y3, m_hitThreshold); break;
         //--- Curve: stroke proximity only (no interior, since there is no fill)
         case TOOL_CURVE:
            hit = HitTestCurve(mouseX, mouseY, x1, y1, x2, y2, x3, y3, m_hitThreshold); break;
         //--- Arrow: shaft proximity OR filled arrowhead interior
         case TOOL_ARROW:
            hit = HitTestArrow(mouseX, mouseY, x1, y1, x2, y2, m_hitThreshold); break;
         //--- Arrow Marker: any pixel inside the filled silhouette
         case TOOL_ARROW_MARKER:
            hit = HitTestArrowMarker(mouseX, mouseY, x1, y1, x2, y2, m_hitThreshold); break;
         //--- Arrow Up / Down: pointing direction selects the dart orientation
         case TOOL_ARROW_UP:
            hit = HitTestArrowUpDown(mouseX, mouseY, x1, y1, true,  m_hitThreshold); break;
         case TOOL_ARROW_DOWN:
            hit = HitTestArrowUpDown(mouseX, mouseY, x1, y1, false, m_hitThreshold); break;
         //--- Note: inside rectangle, on the anchor dot, or on the connector line
         case TOOL_NOTE:
           {
            bool isEdit = (m_isEditingLabel && m_drawnObjects[i].id == m_selectedObjectId);
            hit = HitTestNote(mouseX, mouseY, x1, y1, x2, y2,
                               m_drawnObjects[i].labelText,
                               isEdit, m_labelEditBuffer,
                               m_drawnObjects[i].fontSize);
            break;
           }
         //--- Price Note: same as Note but with anchorPrice instead of free label
         case TOOL_PRICE_NOTE:
           {
            hit = HitTestPriceNote(mouseX, mouseY, x1, y1, x2, y2,
                                    m_drawnObjects[i].price1,
                                    m_drawnObjects[i].fontSize);
            break;
           }
         //--- Callout: rect interior, shaft triangle, or P1 handle
         case TOOL_CALLOUT:
           {
            bool isEdit = (m_isEditingLabel && m_drawnObjects[i].id == m_selectedObjectId);
            hit = HitTestCallout(mouseX, mouseY, x1, y1, x2, y2,
                                  m_drawnObjects[i].labelText,
                                  isEdit, m_labelEditBuffer,
                                  m_drawnObjects[i].fontSize);
            break;
           }
         //--- Comment: rectangle interior only
         case TOOL_COMMENT:
           {
            bool isEdit = (m_isEditingLabel && m_drawnObjects[i].id == m_selectedObjectId);
            hit = HitTestComment(mouseX, mouseY, x1, y1,
                                  m_drawnObjects[i].labelText,
                                  isEdit, m_labelEditBuffer,
                                  m_drawnObjects[i].fontSize);
            break;
           }
         //--- Circle: disc interior plus border band
         case TOOL_CIRCLE:
            hit = HitTestCircle(mouseX, mouseY, x1, y1, x2, y2, m_hitThreshold); break;
         //--- Path: segment proximity only (no interior since paths are open polylines)
         case TOOL_PATH:
           {
            //--- Map all N points to screen coords then test cursor against the polyline
            int N = ArraySize(m_drawnObjects[i].pathTimes);
            if(N >= 2)
              {
               //--- Allocate parallel pixel arrays for the segment-distance test
               int pxs[], pys[];
               ArrayResize(pxs, N);
               ArrayResize(pys, N);
               for(int pi = 0; pi < N; pi++)
                 {
                  //--- Map each path vertex to screen coordinates
                  int pxx=0, pyy=0;
                  ChartTimePriceToXY(m_chartId, 0,
                                      m_drawnObjects[i].pathTimes[pi],
                                      m_drawnObjects[i].pathPrices[pi],
                                      pxx, pyy);
                  pxs[pi] = pxx;
                  pys[pi] = pyy;
                 }
               //--- Test distance from cursor to every segment of the polyline
               hit = HitTestPath(mouseX, mouseY, pxs, pys, m_hitThreshold);
              }
            break;
           }
         //--- Triangle: interior fill plus edge proximity (mirrors Rectangle semantics)
         case TOOL_TRIANGLE:
            hit = HitTestTriangle(mouseX, mouseY, x1, y1, x2, y2, x3, y3, m_hitThreshold); break;
         //--- Rotated 3-point Ellipse: interior plus AA border
         case TOOL_ELLIPSE:
            hit = HitTestEllipseRotated(mouseX, mouseY, x1, y1, x2, y2, x3, y3, m_hitThreshold); break;
         //--- Fibonacci tools: each defers to its own per-tool hit-test routine
         case TOOL_FIBO_RETRACEMENT:
            hit = HitTestFibRetracement(mouseX,mouseY,
                                         m_canvasDrawings.Width(),
                                         x1,y1,x2,y2, m_hitThreshold,
                                         m_drawnObjects[i].fiboLevelRatio,
                                         m_drawnObjects[i].fiboLevelVisible); break;
         case TOOL_FIBO_EXPANSION:
            hit = HitTestFibExpansion(mouseX,mouseY,
                                       m_canvasDrawings.Width(),
                                       x1,y1,x2,y2,x3,y3, m_hitThreshold); break;
         case TOOL_FIBO_CHANNEL:
            hit = HitTestFibChannel(mouseX,mouseY,
                                     m_canvasDrawings.Width(),
                                     x1,y1,x2,y2,x3,y3, m_hitThreshold); break;
         case TOOL_FIBO_TIMEZONES:
            hit = HitTestFibTimeZone(mouseX,mouseY,
                                      m_canvasDrawings.Height(),
                                      x1,y1,x2,y2, m_hitThreshold); break;
         case TOOL_FIBO_FAN:
            hit = HitTestFibFan(mouseX,mouseY,
                                 m_canvasDrawings.Width(), m_canvasDrawings.Height(),
                                 x1,y1,x2,y2, m_hitThreshold); break;
         case TOOL_FIBO_ARCS:
            hit = HitTestFibArcs(mouseX,mouseY,
                                  x1,y1,x2,y2, m_hitThreshold); break;
         //--- Channel family: parallel, regression, and stddev
         case TOOL_PARALLEL_CHANNEL:
            hit = HitTestParallelChannel(mouseX,mouseY,x1,y1,x2,y2,x3,y3, m_hitThreshold); break;
         case TOOL_REGRESSION_CHANNEL:
            hit = HitTestRegressionChannel(mouseX,mouseY, m_chartId,
                                            m_drawnObjects[i].time1,
                                            m_drawnObjects[i].time2, m_hitThreshold); break;
         case TOOL_STDDEV_CHANNEL:
            hit = HitTestStdDevChannel(mouseX,mouseY, m_chartId,
                                        m_drawnObjects[i].time1,
                                        m_drawnObjects[i].time2, m_hitThreshold); break;
         //--- Pitchfork family: Andrew's, Schiff, and Modified Schiff
         case TOOL_PITCHFORK:
            hit = HitTestAndrewsPitchfork(mouseX,mouseY,
                                           m_canvasDrawings.Width(), m_canvasDrawings.Height(),
                                           x1,y1,x2,y2,x3,y3, m_hitThreshold); break;
         case TOOL_SCHIFF_PITCHFORK:
            hit = HitTestSchiffPitchfork(mouseX,mouseY,
                                          m_canvasDrawings.Width(), m_canvasDrawings.Height(),
                                          x1,y1,x2,y2,x3,y3, m_hitThreshold); break;
         case TOOL_MOD_SCHIFF:
            hit = HitTestModSchiffPitchfork(mouseX,mouseY,
                                             m_canvasDrawings.Width(), m_canvasDrawings.Height(),
                                             x1,y1,x2,y2,x3,y3, m_hitThreshold); break;
         //--- Gann family: Line, Fan, and Box
         case TOOL_GANN_LINE:
            hit = HitTestGannLine(mouseX,mouseY,
                                   m_canvasDrawings.Width(), m_canvasDrawings.Height(),
                                   x1,y1,x2,y2, m_hitThreshold); break;
         case TOOL_GANN_FAN:
            hit = HitTestGannFan(mouseX,mouseY,
                                  m_canvasDrawings.Width(), m_canvasDrawings.Height(),
                                  x1,y1,x2,y2, m_hitThreshold); break;
         case TOOL_GANN_BOX:
            hit = HitTestGannBox(mouseX,mouseY,
                                  x1,y1,x2,y2, m_hitThreshold); break;
         //--- Tools without a registered hit-test route never match
         default: break;
        }
      //--- Return the topmost matched object ID immediately
      if(hit) return m_drawnObjects[i].id;
     }
   //--- Nothing under the cursor
   return -1;
  }

//+------------------------------------------------------------------+
//| Handle pointer-tool mouse move - hover detection only            |
//+------------------------------------------------------------------+
void CDrawingEngine::HandlePointerMouseMove(int mouseX, int mouseY)
  {
   //--- Run the body hit-test against every visible object
   int hitId = HitTestAllObjects(mouseX, mouseY);
   //--- Test handles against the SELECTED object first (highest priority)
   int newHoveredHandle = -1;
   int handleHostId     = -1;
   if(m_selectedObjectId >= 0)
     {
      //--- Resolve the selected object's index and test its handles
      int selIdx = FindObjectIndexById(m_selectedObjectId);
      if(selIdx >= 0)
        {
         int hh = HitTestHandles(mouseX, mouseY, selIdx);
         if(hh >= 0) { newHoveredHandle = hh; handleHostId = m_selectedObjectId; }
        }
     }
   //--- If selected-object handles missed, fall back to the hovered object's handles
   if(newHoveredHandle < 0 && hitId >= 0 && hitId != m_selectedObjectId)
     {
      //--- Resolve the hovered object's index and test its handles
      int hIdx = FindObjectIndexById(hitId);
      if(hIdx >= 0)
        {
         int hh = HitTestHandles(mouseX, mouseY, hIdx);
         if(hh >= 0) { newHoveredHandle = hh; handleHostId = hitId; }
        }
     }
   //--- Grace zone: keep hover on the selected object when the cursor enters the "Add text" prompt
   if(hitId < 0 &&
      m_addTextPromptObjId >= 0 &&
      m_addTextPromptObjId == m_selectedObjectId &&
      ArraySize(m_addTextPromptCornerX) >= 4 &&
      PointInRotatedRect(mouseX, mouseY,
                          m_addTextPromptCornerX,
                          m_addTextPromptCornerY))
     {
      hitId = m_addTextPromptObjId;
     }
   //--- Grace zone: same for the committed label rect of the selected object
   if(hitId < 0 &&
      m_labelHitObjIdForSelected >= 0 &&
      m_labelHitObjIdForSelected == m_selectedObjectId &&
      ArraySize(m_labelHitCornerX) >= 4 &&
      PointInRotatedRect(mouseX, mouseY,
                          m_labelHitCornerX,
                          m_labelHitCornerY))
     {
      hitId = m_labelHitObjIdForSelected;
     }
   //--- Trigger a redraw only when any of the hover-related state has changed
   if(hitId != m_hoveredObjectId ||
      newHoveredHandle != m_hoveredHandleIdx ||
      handleHostId != m_hoveredHandleHostId)
     {
      //--- Cache the new hover state and redraw to reflect it
      m_hoveredObjectId     = hitId;
      m_hoveredHandleIdx    = newHoveredHandle;
      m_hoveredHandleHostId = handleHostId;
      RedrawAllObjects();
     }
  }

//+------------------------------------------------------------------+
//| Handle pointer-tool single click - select object or arm drag     |
//+------------------------------------------------------------------+
void CDrawingEngine::HandlePointerClick(int mouseX, int mouseY)
  {
   //--- Finalize any in-progress label edit when the click lands outside the editing rect
   if(m_isEditingLabel)
     {
      //--- Test if the click landed inside the currently-editing label's rotated rectangle
      bool clickInsideEditedLabel = false;
      if(m_labelHitObjIdForSelected >= 0 &&
         m_labelHitObjIdForSelected == m_selectedObjectId &&
         ArraySize(m_labelHitCornerX) == 4 &&
         PointInRotatedRect(mouseX, mouseY, m_labelHitCornerX, m_labelHitCornerY))
        {
         clickInsideEditedLabel = true;
        }
      if(clickInsideEditedLabel)
        {
         //--- Click INSIDE the editing label: reposition the caret without committing
         int editIdx = FindObjectIndexById(m_selectedObjectId);
         int padX = 0, padY = 0, fontPt = 12, wrapW = 0;
         string fontN = "Arial";
         //--- Use the same wrap/pad/font params the renderer used so the caret lands accurately
         if(GetHostTextLayout(editIdx, padX, padY, fontN, fontPt, wrapW))
            SetCaretFromMouseClick(mouseX, mouseY, padX, padY, fontN, fontPt, wrapW);
         return;
        }
      //--- Click OUTSIDE: commit non-empty buffer or discard empty text-annotation; then fall through
      FinalizeOpenLabelEdit();
     }
   //--- Click on the committed label of the selected object enters edit mode (or arms drag for TEXT)
   if(m_labelHitObjIdForSelected >= 0 &&
      m_labelHitObjIdForSelected == m_selectedObjectId &&
      PointInRotatedRect(mouseX, mouseY, m_labelHitCornerX, m_labelHitCornerY))
     {
      //--- Identify whether the host is a text-annotation tool (Text, Note, Callout, Comment)
      int labIdx = FindObjectIndexById(m_labelHitObjIdForSelected);
      bool isTextAnnot = (labIdx >= 0 &&
                          (m_drawnObjects[labIdx].toolType == TOOL_TEXT ||
                           m_drawnObjects[labIdx].toolType == TOOL_NOTE ||
                           m_drawnObjects[labIdx].toolType == TOOL_CALLOUT ||
                           m_drawnObjects[labIdx].toolType == TOOL_COMMENT));
      if(isTextAnnot)
        {
         //--- Locked text annotations remain editable, but must not arm a geometry drag
         if(m_drawnObjects[labIdx].locked)
           {
            StartLabelEdit();
            RedrawAllObjects();
            return;
           }
         //--- Text-annotation: arm a drag AND mark the click as a pending edit
         m_isDraggingObject = true;
         m_dragLastMouseX   = mouseX;
         m_dragLastMouseY   = mouseY;
         //--- Pending-edit state: drag-release decides between edit (no move) and drag (moved)
         m_pendingTextEditArmed   = true;
         m_pendingTextEditObjId   = m_labelHitObjIdForSelected;
         m_pendingTextEditStartX  = mouseX;
         m_pendingTextEditStartY  = mouseY;
         ChartSetInteger(0, CHART_MOUSE_SCROLL, false);
         return;
        }
      //--- Non-text host with a label: click always enters edit mode (no ambiguity)
      StartLabelEdit();
      RedrawAllObjects();
      return;
     }
   //--- "+ Add text" prompt is showing for the selected line and the cursor sits inside it
   if(m_addTextPromptObjId >= 0 &&
      m_addTextPromptObjId == m_selectedObjectId &&
      PointInRotatedRect(mouseX, mouseY, m_addTextPromptCornerX, m_addTextPromptCornerY))
     {
      //--- Enter label-edit mode for the prompted object
      StartLabelEdit();
      RedrawAllObjects();
      return;
     }
   //--- Handle hit on the selected object's handles takes priority over body hit-tests
   if(m_selectedObjectId >= 0)
     {
      //--- Resolve the selected object's index and test its handles against the cursor
      int selIdx    = FindObjectIndexById(m_selectedObjectId);
      int handleIdx = HitTestHandles(mouseX, mouseY, selIdx);
      if(handleIdx >= 0)
        {
         //--- Keep locked handles hittable and selected, but consume clicks without arming a drag
         if(selIdx >= 0 && m_drawnObjects[selIdx].locked)
            return;
         //--- TREND_ANGLE special case: handle 0 (anchor 1) drags the whole object
         if(selIdx >= 0 &&
            m_drawnObjects[selIdx].toolType == TOOL_TREND_ANGLE &&
            handleIdx == 0)
           {
            //--- Arm a whole-object drag and lock chart scroll
            m_isDraggingObject = true;
            m_dragLastMouseX   = mouseX;
            m_dragLastMouseY   = mouseY;
            ChartSetInteger(0, CHART_MOUSE_SCROLL, false);
            return;
           }
         //--- Default: arm a single-handle drag with the matched handle index
         m_isDraggingHandle  = true;
         m_draggedHandleIdx  = handleIdx;
         return;
        }
     }
   //--- Body hit-test against every visible object
   int hitId = HitTestAllObjects(mouseX, mouseY);
   //--- Body hit: update selection and arm a whole-object drag (press-and-drag semantics)
   if(hitId >= 0)
     {
      //--- Update the selection if the click landed on a different object
      if(m_selectedObjectId != hitId)
         SelectObjectById(hitId);
      //--- Locked objects select normally but cannot arm a whole-object drag
      int hitIdx = FindObjectIndexById(hitId);
      if(hitIdx >= 0 && m_drawnObjects[hitIdx].locked)
        {
         RedrawAllObjects();
         return;
        }
      //--- Arm the drag; release without movement degrades to a click-to-select
      m_isDraggingObject = true;
      m_dragLastMouseX   = mouseX;
      m_dragLastMouseY   = mouseY;
      ChartSetInteger(0, CHART_MOUSE_SCROLL, false);
      RedrawAllObjects();
      return;
     }
   //--- Click landed on empty space: deselect whatever was previously selected
   if(m_selectedObjectId >= 0)
     {
      SelectObjectById(-1);
      RedrawAllObjects();
     }
  }

//+------------------------------------------------------------------+
//| Handle pointer-tool double click - start whole-object drag       |
//+------------------------------------------------------------------+
void CDrawingEngine::HandlePointerDoubleClick(int mouseX, int mouseY)
  {
   //--- Body hit-test under the cursor; bail out when nothing is hit
   int hitId = HitTestAllObjects(mouseX, mouseY);
   if(hitId < 0) return;
   //--- Update the selection if the double-click landed on a different object
   if(m_selectedObjectId != hitId)
      SelectObjectById(hitId);
   //--- Locked objects select normally but cannot arm a whole-object drag
   int hitIdx = FindObjectIndexById(hitId);
   if(hitIdx >= 0 && m_drawnObjects[hitIdx].locked)
      return;
   //--- Arm a whole-object drag and lock chart scroll
   m_isDraggingObject = true;
   m_dragLastMouseX   = mouseX;
   m_dragLastMouseY   = mouseY;
   ChartSetInteger(0, CHART_MOUSE_SCROLL, false);
  }

//+------------------------------------------------------------------+
//| Handle pointer drag move - translate object or reshape via handle|
//+------------------------------------------------------------------+
void CDrawingEngine::HandlePointerDragMove(int mouseX, int mouseY)
  {
   //--- A lock may be enabled while a drag is active; stop before any anchor mutation
   if(m_selectedObjectId >= 0 &&
      (m_isDraggingObject || m_isDraggingHandle || m_pendingTextEditArmed))
     {
      int selectedIdx = FindObjectIndexById(m_selectedObjectId);
      if(selectedIdx >= 0 && m_drawnObjects[selectedIdx].locked)
        {
         m_isDraggingObject      = false;
         m_isDraggingHandle      = false;
         m_draggedHandleIdx      = -1;
         m_pendingTextEditArmed  = false;
         RedrawAllObjects();
         return;
        }
     }
   //--- Whole-object drag path: shift every anchor by the (dt, dp) delta
   if(m_isDraggingObject && m_selectedObjectId >= 0)
     {
      //--- Resolve the selected object's index; bail out on resolution failure
      int idx = FindObjectIndexById(m_selectedObjectId);
      if(idx < 0) return;
      //--- Convert previous and current cursor pixels to (time, price) for the delta
      datetime t1, t2; double p1, p2; int sub;
      ChartXYToTimePrice(m_chartId, m_dragLastMouseX, m_dragLastMouseY, sub, t1, p1);
      ChartXYToTimePrice(m_chartId, mouseX,           mouseY,           sub, t2, p2);
      //--- Compute the time and price deltas to apply to every anchor
      long   dtDelta    = (long)t2 - (long)t1;
      double priceDelta = p2 - p1;
      //--- Shift the primary anchor (P1) by the delta
      m_drawnObjects[idx].time1  = (datetime)((long)m_drawnObjects[idx].time1  + dtDelta);
      m_drawnObjects[idx].price1 =             m_drawnObjects[idx].price1 + priceDelta;
      //--- Shift P2 by the same delta when present
      if(m_drawnObjects[idx].time2 != 0)
        {
         m_drawnObjects[idx].time2  = (datetime)((long)m_drawnObjects[idx].time2  + dtDelta);
         m_drawnObjects[idx].price2 =             m_drawnObjects[idx].price2 + priceDelta;
        }
      //--- Shift P3 by the same delta when present
      if(m_drawnObjects[idx].time3 != 0)
        {
         m_drawnObjects[idx].time3  = (datetime)((long)m_drawnObjects[idx].time3  + dtDelta);
         m_drawnObjects[idx].price3 =             m_drawnObjects[idx].price3 + priceDelta;
        }
      //--- Path tool: shift every vertex in the pathTimes / pathPrices arrays too
      if(m_drawnObjects[idx].toolType == TOOL_PATH)
        {
         //--- Walk the path arrays and translate each vertex by the same delta
         int N = ArraySize(m_drawnObjects[idx].pathTimes);
         for(int pi = 0; pi < N; pi++)
           {
            m_drawnObjects[idx].pathTimes[pi]  =
               (datetime)((long)m_drawnObjects[idx].pathTimes[pi] + dtDelta);
            m_drawnObjects[idx].pathPrices[pi] =
               m_drawnObjects[idx].pathPrices[pi] + priceDelta;
           }
        }
      //--- Cache the current cursor pixel for the next drag-move delta computation
      m_dragLastMouseX = mouseX;
      m_dragLastMouseY = mouseY;
      //--- Preview color matches commit color so the drag is WYSIWYG
      RedrawAllObjects();
      return;
     }
   //--- Single-handle drag path: reshape the object based on the dragged handle index
   if(m_isDraggingHandle && m_selectedObjectId >= 0)
     {
      //--- Resolve the selected object's index; bail out on resolution failure
      int idx = FindObjectIndexById(m_selectedObjectId);
      if(idx < 0) return;
      //--- Map the cursor pixel to (time, price); bail out on chart mapping failure
      datetime newTime; double newPrice; int sub;
      if(!ChartXYToTimePrice(m_chartId, mouseX, mouseY, sub, newTime, newPrice)) return;
      //--- Parallel Channel: 6-handle drag with VERTICAL ALIGNMENT invariant preserved
      if(m_drawnObjects[idx].toolType == TOOL_PARALLEL_CHANNEL)
        {
         //--- Snapshot the stored anchors A, B, C and derive D = B + (C - A)
         datetime tA = m_drawnObjects[idx].time1;  double pA = m_drawnObjects[idx].price1;
         datetime tB = m_drawnObjects[idx].time2;  double pB = m_drawnObjects[idx].price2;
         datetime tC = m_drawnObjects[idx].time3;  double pC = m_drawnObjects[idx].price3;
         //--- D's price is derived from A, B, C under the vertical-alignment invariant
         double pD = pB + (pC - pA);
         //--- D's time always equals B's time under vertical alignment
         datetime tD = tB;
         //--- Dispatch on the dragged handle index
         switch(m_draggedHandleIdx)
           {
            case 0: {
               //--- Drag A to the cursor; C shifts by the same (dt, dp) delta to preserve height
               long   dt = (long)newTime - (long)tA;
               double dp = newPrice       - pA;
               m_drawnObjects[idx].time1  = newTime;
               m_drawnObjects[idx].price1 = newPrice;
               m_drawnObjects[idx].time3  = (datetime)((long)tC + dt);
               m_drawnObjects[idx].price3 = pC + dp;
               break;
            }
            case 1: {
               //--- Drag B to the cursor; D shifts implicitly through pB and tD = tB
               long   dt = (long)newTime - (long)tB;
               double dp = newPrice       - pB;
               m_drawnObjects[idx].time2  = newTime;
               m_drawnObjects[idx].price2 = newPrice;
               break;
            }
            case 2: {
               //--- Drag C to the cursor; A shifts by the same (dt, dp) delta to preserve height
               long   dt = (long)newTime - (long)tC;
               double dp = newPrice       - pC;
               m_drawnObjects[idx].time3  = newTime;
               m_drawnObjects[idx].price3 = newPrice;
               m_drawnObjects[idx].time1  = (datetime)((long)tA + dt);
               m_drawnObjects[idx].price1 = pA + dp;
               break;
            }
            case 3: {
               //--- Drag D to the cursor; B shifts by the same (dt, dp) since D.price = pB + offset
               long   dt = (long)newTime - (long)tD;
               double dp = newPrice       - pD;
               m_drawnObjects[idx].time2  = (datetime)((long)tB + dt);
               m_drawnObjects[idx].price2 = pB + dp;
               break;
            }
            case 4: {
               //--- midAB drag: PRICE ONLY (channel height); A and B prices shift by the same dp
               double midABP = (pA + pB) / 2.0;
               double dp     = newPrice - midABP;
               m_drawnObjects[idx].price1 = pA + dp;
               m_drawnObjects[idx].price2 = pB + dp;
               break;
            }
            case 5: {
               //--- midCD drag: PRICE ONLY (channel height); C's price shifts (D derives)
               double midCDP = (pC + pD) / 2.0;
               double dp     = newPrice - midCDP;
               m_drawnObjects[idx].price3 = pC + dp;
               break;
            }
           }
        }
      //--- Regression / StdDev Channel: 2 endpoint handles, time-only edits (regression sets Y)
      else if(m_drawnObjects[idx].toolType == TOOL_REGRESSION_CHANNEL ||
              m_drawnObjects[idx].toolType == TOOL_STDDEV_CHANNEL)
        {
         //--- Identify which stored slot is older (left) vs newer (right)
         datetime tOld = m_drawnObjects[idx].time1;
         datetime tNew = m_drawnObjects[idx].time2;
         bool time1IsLeft = (tOld < tNew);
         datetime tLeft  = time1IsLeft ? tOld : tNew;
         datetime tRight = time1IsLeft ? tNew : tOld;
         //--- Current bar time bounds the right anchor (no future regression)
         datetime tMaxBar = (datetime)iTime(_Symbol, _Period, 0);
         if(m_draggedHandleIdx == 0)
           {
            //--- LEFT handle: update the older time anchor (clamp 1 minute below right)
            datetime newLeft = newTime;
            if(newLeft >= tRight) newLeft = tRight - 60;
            if(time1IsLeft) m_drawnObjects[idx].time1 = newLeft;
            else             m_drawnObjects[idx].time2 = newLeft;
           }
         else if(m_draggedHandleIdx == 1)
           {
            //--- RIGHT handle: update the newer time anchor (clamp to current bar; 1 min above left)
            datetime newRight = newTime;
            if(newRight > tMaxBar) newRight = tMaxBar;
            if(newRight <= tLeft)  newRight = tLeft + 60;
            if(time1IsLeft) m_drawnObjects[idx].time2 = newRight;
            else             m_drawnObjects[idx].time1 = newRight;
           }
         //--- Recompute the regression endpoints and refresh stored price1/price2 to stay in sync
         {
            double lp = 0, rp = 0;
            if(ComputeRegressionEndpoints(m_drawnObjects[idx].time1,
                                           m_drawnObjects[idx].time2,
                                           lp, rp))
              {
               m_drawnObjects[idx].price1 = lp;
               m_drawnObjects[idx].price2 = rp;
              }
         }
        }
      //--- Gann Box: 4 handles - 0/1 stored corners, 2/3 cross-corners
      else if(m_drawnObjects[idx].toolType == TOOL_GANN_BOX)
        {
         //--- Dispatch on the dragged handle index
         switch(m_draggedHandleIdx)
           {
            case 0:
               //--- P1 corner: drag stored P1 directly
               m_drawnObjects[idx].time1  = newTime;
               m_drawnObjects[idx].price1 = newPrice;
               break;
            case 1:
               //--- P2 corner: drag stored P2 directly
               m_drawnObjects[idx].time2  = newTime;
               m_drawnObjects[idx].price2 = newPrice;
               break;
            case 2:
               //--- Cross-corner (P1.x, P2.y): updates time1 and price2
               m_drawnObjects[idx].time1  = newTime;
               m_drawnObjects[idx].price2 = newPrice;
               break;
            case 3:
               //--- Cross-corner (P2.x, P1.y): updates time2 and price1
               m_drawnObjects[idx].time2  = newTime;
               m_drawnObjects[idx].price1 = newPrice;
               break;
           }
        }
      //--- Rectangle: 8 handles - 0/1 stored, 2/3 cross-corners, 4-7 edge midpoints
      else if(m_drawnObjects[idx].toolType == TOOL_RECTANGLE)
        {
         //--- Snapshot the stored anchors for the edge-midpoint orientation tests
         datetime tA = m_drawnObjects[idx].time1;
         datetime tB = m_drawnObjects[idx].time2;
         double   pA = m_drawnObjects[idx].price1;
         double   pB = m_drawnObjects[idx].price2;
         //--- Identify which stored anchor sits on the top/bottom and left/right sides
         bool aIsTop   = (pA >= pB);
         bool aIsLeft  = (tA <= tB);
         //--- Dispatch on the dragged handle index
         switch(m_draggedHandleIdx)
           {
            case 0:
               //--- P1 free corner drag
               m_drawnObjects[idx].time1  = newTime;
               m_drawnObjects[idx].price1 = newPrice;
               break;
            case 1:
               //--- P2 free corner drag
               m_drawnObjects[idx].time2  = newTime;
               m_drawnObjects[idx].price2 = newPrice;
               break;
            case 2:
               //--- (P1.x, P2.y) cross-corner: P1.time and P2.price update
               m_drawnObjects[idx].time1  = newTime;
               m_drawnObjects[idx].price2 = newPrice;
               break;
            case 3:
               //--- (P2.x, P1.y) cross-corner: P2.time and P1.price update
               m_drawnObjects[idx].time2  = newTime;
               m_drawnObjects[idx].price1 = newPrice;
               break;
            case 4:
               //--- TOP edge midpoint: update the price of the top-side anchor (greater price)
               if(aIsTop) m_drawnObjects[idx].price1 = newPrice;
               else       m_drawnObjects[idx].price2 = newPrice;
               break;
            case 5:
               //--- RIGHT edge midpoint: update the time of the right-side anchor (greater time)
               if(aIsLeft) m_drawnObjects[idx].time2 = newTime;
               else        m_drawnObjects[idx].time1 = newTime;
               break;
            case 6:
               //--- BOTTOM edge midpoint: update the price of the bottom-side anchor (smaller price)
               if(aIsTop) m_drawnObjects[idx].price2 = newPrice;
               else       m_drawnObjects[idx].price1 = newPrice;
               break;
            case 7:
               //--- LEFT edge midpoint: update the time of the left-side anchor (smaller time)
               if(aIsLeft) m_drawnObjects[idx].time1 = newTime;
               else        m_drawnObjects[idx].time2 = newTime;
               break;
           }
        }
      //--- Curve: 3 free anchors with no symmetry or clamps - drag each independently
      else if(m_drawnObjects[idx].toolType == TOOL_CURVE)
        {
         //--- Dispatch on the dragged handle index
         switch(m_draggedHandleIdx)
           {
            case 0: m_drawnObjects[idx].time1 = newTime; m_drawnObjects[idx].price1 = newPrice; break;
            case 1: m_drawnObjects[idx].time2 = newTime; m_drawnObjects[idx].price2 = newPrice; break;
            case 2: m_drawnObjects[idx].time3 = newTime; m_drawnObjects[idx].price3 = newPrice; break;
           }
        }
      //--- Arc: 3 handles - 0/1 chord ends free, 2 (apex) symmetric on the perpendicular bisector
      else if(m_drawnObjects[idx].toolType == TOOL_ARC)
        {
         if(m_draggedHandleIdx == 0)
           {
            //--- Chord start (P1) drags freely
            m_drawnObjects[idx].time1 = newTime;  m_drawnObjects[idx].price1 = newPrice;
           }
         else if(m_draggedHandleIdx == 1)
           {
            //--- Chord end (P2) drags freely
            m_drawnObjects[idx].time2 = newTime;  m_drawnObjects[idx].price2 = newPrice;
           }
         else if(m_draggedHandleIdx == 2)
           {
            //--- Apex (P3): keep on the perpendicular bisector by extracting perp component only
            int sP1x=0, sP1y=0, sP2x=0, sP2y=0;
            ChartTimePriceToXY(m_chartId, 0,
                                m_drawnObjects[idx].time1, m_drawnObjects[idx].price1, sP1x, sP1y);
            ChartTimePriceToXY(m_chartId, 0,
                                m_drawnObjects[idx].time2, m_drawnObjects[idx].price2, sP2x, sP2y);
            //--- Map the cursor (time, price) to screen coords for geometric reasoning
            int mxS=0, myS=0;
            ChartTimePriceToXY(m_chartId, 0, newTime, newPrice, mxS, myS);
            //--- Build chord-unit and perpendicular-unit vectors
            double chx = (double)(sP2x - sP1x);
            double chy = (double)(sP2y - sP1y);
            double cLen = MathSqrt(chx * chx + chy * chy);
            if(cLen >= 2.0)
              {
               //--- Compute chord-unit and chord-perpendicular vectors
               double ux = chx / cLen, uy = chy / cLen;
               double nx = -uy,        ny =  ux;
               //--- Chord midpoint
               double midX = 0.5 * ((double)sP1x + (double)sP2x);
               double midY = 0.5 * ((double)sP1y + (double)sP2y);
               //--- Project the cursor onto the perpendicular - discard the along-chord component
               double perp = ((double)mxS - midX) * nx + ((double)myS - midY) * ny;
               //--- Park the apex on the perpendicular bisector at the cursor's perp distance
               double apX = midX + perp * nx;
               double apY = midY + perp * ny;
               //--- Convert the apex pixel back to (time, price) and store
               datetime apT; double apP; int apSub;
               if(ChartXYToTimePrice(m_chartId, (int)MathRound(apX), (int)MathRound(apY),
                                      apSub, apT, apP))
                 {
                  m_drawnObjects[idx].time3  = apT;
                  m_drawnObjects[idx].price3 = apP;
                 }
              }
           }
        }
      //--- Path: handle index equals vertex index - move just that vertex
      else if(m_drawnObjects[idx].toolType == TOOL_PATH)
        {
         //--- Update the dragged vertex if the index is in range
         int pi = m_draggedHandleIdx;
         int N = ArraySize(m_drawnObjects[idx].pathTimes);
         if(pi >= 0 && pi < N)
           {
            //--- Move the vertex to the cursor's time and price
            m_drawnObjects[idx].pathTimes[pi]  = newTime;
            m_drawnObjects[idx].pathPrices[pi] = newPrice;
            //--- Keep the object's primary anchors in sync with the first two path points
            if(pi == 0) { m_drawnObjects[idx].time1 = newTime; m_drawnObjects[idx].price1 = newPrice; }
            if(pi == 1) { m_drawnObjects[idx].time2 = newTime; m_drawnObjects[idx].price2 = newPrice; }
           }
        }
      //--- Circle: 2 handles - center (idx 0) translates P2; border (idx 1) tracks cursor directly
      else if(m_drawnObjects[idx].toolType == TOOL_CIRCLE)
        {
         if(m_draggedHandleIdx == 0)
           {
            //--- Center drag: shift P2 by the same (dt, dp) delta to preserve radius
            long    dtDelta = (long)newTime  - (long)m_drawnObjects[idx].time1;
            double  dpDelta =       newPrice -        m_drawnObjects[idx].price1;
            m_drawnObjects[idx].time1  = newTime;
            m_drawnObjects[idx].price1 = newPrice;
            m_drawnObjects[idx].time2  = (datetime)((long)m_drawnObjects[idx].time2 + dtDelta);
            m_drawnObjects[idx].price2 =             m_drawnObjects[idx].price2     + dpDelta;
           }
         else if(m_draggedHandleIdx == 1)
           {
            //--- Border drag: P2 tracks the cursor; radius becomes cursor-to-center distance
            m_drawnObjects[idx].time2  = newTime;
            m_drawnObjects[idx].price2 = newPrice;
           }
        }
      //--- Rotated Rectangle: 6 handles - corners change width only; mid-points rotate around the pin
      else if(m_drawnObjects[idx].toolType == TOOL_ROTATED_RECTANGLE)
        {
         //--- Snapshot screen positions of P1, P2, P3 to reason about the current geometry
         int sP1x=0, sP1y=0, sP2x=0, sP2y=0, sP3x=0, sP3y=0;
         ChartTimePriceToXY(m_chartId, 0, m_drawnObjects[idx].time1, m_drawnObjects[idx].price1, sP1x, sP1y);
         ChartTimePriceToXY(m_chartId, 0, m_drawnObjects[idx].time2, m_drawnObjects[idx].price2, sP2x, sP2y);
         ChartTimePriceToXY(m_chartId, 0, m_drawnObjects[idx].time3, m_drawnObjects[idx].price3, sP3x, sP3y);
         //--- Build the current midline-unit and perpendicular vectors
         double curDxM = (double)(sP2x - sP1x);
         double curDyM = (double)(sP2y - sP1y);
         double curLenM = MathSqrt(curDxM * curDxM + curDyM * curDyM);
         double curUx = (curLenM > 1e-9) ? curDxM / curLenM : 1.0;
         double curUy = (curLenM > 1e-9) ? curDyM / curLenM : 0.0;
         double curVx = -curUy;
         double curVy =  curUx;
         //--- Current signed half-width from P3's projection onto the perpendicular
         double curHalfW = ((double)sP3x - (double)sP1x) * curVx + ((double)sP3y - (double)sP1y) * curVy;
         //--- Map the cursor (time, price) to screen for geometric reasoning
         int mxS = 0, myS = 0;
         ChartTimePriceToXY(m_chartId, 0, newTime, newPrice, mxS, myS);
         //--- Dispatch on the dragged handle index
         switch(m_draggedHandleIdx)
           {
            case 0: case 1: case 2: case 3:
              {
               //--- Corner drag: change half-width magnitude only; side sign stays locked
               double newPerp = ((double)mxS - (double)sP1x) * curVx + ((double)myS - (double)sP1y) * curVy;
               double origSign = (curHalfW >= 0.0) ? 1.0 : -1.0;
               double newHalfW = MathAbs(newPerp) * origSign;
               //--- Place P3 on the perpendicular through P1 at the new signed half-width
               int newP3x = (int)MathRound((double)sP1x + newHalfW * curVx);
               int newP3y = (int)MathRound((double)sP1y + newHalfW * curVy);
               //--- Convert P3 back to (time, price) storage
               datetime newP3t; double newP3p; int subP3;
               if(ChartXYToTimePrice(m_chartId, newP3x, newP3y, subP3, newP3t, newP3p))
                 {
                  m_drawnObjects[idx].time3  = newP3t;
                  m_drawnObjects[idx].price3 = newP3p;
                 }
               break;
              }
            case 4: case 5:
              {
               //--- Side-midpoint drag: dragged endpoint follows cursor; other endpoint pins
               if(m_draggedHandleIdx == 4)
                 {
                  //--- P1 follows cursor (P2 pins)
                  m_drawnObjects[idx].time1  = newTime;
                  m_drawnObjects[idx].price1 = newPrice;
                 }
               else
                 {
                  //--- P2 follows cursor (P1 pins)
                  m_drawnObjects[idx].time2  = newTime;
                  m_drawnObjects[idx].price2 = newPrice;
                 }
               //--- Rebuild the midline-unit and perpendicular vectors in the NEW frame
               int nP1x=0, nP1y=0, nP2x=0, nP2y=0;
               ChartTimePriceToXY(m_chartId, 0, m_drawnObjects[idx].time1, m_drawnObjects[idx].price1, nP1x, nP1y);
               ChartTimePriceToXY(m_chartId, 0, m_drawnObjects[idx].time2, m_drawnObjects[idx].price2, nP2x, nP2y);
               double nDx = (double)(nP2x - nP1x);
               double nDy = (double)(nP2y - nP1y);
               double nLen = MathSqrt(nDx * nDx + nDy * nDy);
               if(nLen < 1e-9) break;
               double nUx = nDx / nLen;
               double nUy = nDy / nLen;
               double nVx = -nUy;
               double nVy =  nUx;
               //--- Re-anchor P3 at the same signed half-width on the new perpendicular
               int newP3x = (int)MathRound((double)nP1x + curHalfW * nVx);
               int newP3y = (int)MathRound((double)nP1y + curHalfW * nVy);
               //--- Convert P3 back to (time, price) storage
               datetime newP3t; double newP3p; int subP3;
               if(ChartXYToTimePrice(m_chartId, newP3x, newP3y, subP3, newP3t, newP3p))
                 {
                  m_drawnObjects[idx].time3  = newP3t;
                  m_drawnObjects[idx].price3 = newP3p;
                 }
               break;
              }
           }
        }
      //--- Rotated Ellipse: 4 handles - P1/P2 rotate; minor-axis endpoints change b only
      else if(m_drawnObjects[idx].toolType == TOOL_ELLIPSE)
        {
         //--- Snapshot screen positions of P1, P2, P3 to reason about current geometry
         int sP1x = 0, sP1y = 0, sP2x = 0, sP2y = 0, sP3x = 0, sP3y = 0;
         ChartTimePriceToXY(m_chartId, 0, m_drawnObjects[idx].time1, m_drawnObjects[idx].price1, sP1x, sP1y);
         ChartTimePriceToXY(m_chartId, 0, m_drawnObjects[idx].time2, m_drawnObjects[idx].price2, sP2x, sP2y);
         ChartTimePriceToXY(m_chartId, 0, m_drawnObjects[idx].time3, m_drawnObjects[idx].price3, sP3x, sP3y);
         //--- Compute the current ellipse center
         double curCx  = (sP1x + sP2x) * 0.5;
         double curCy  = (sP1y + sP2y) * 0.5;
         //--- Compute the current major-axis vector and unit cos/sin
         double curDx  = (double)(sP2x - sP1x);
         double curDy  = (double)(sP2y - sP1y);
         double curLen = MathSqrt(curDx * curDx + curDy * curDy);
         double curCosT = (curLen > 1e-9) ? curDx / curLen : 1.0;
         double curSinT = (curLen > 1e-9) ? curDy / curLen : 0.0;
         //--- Compute P3's perpendicular distance to the major axis and its sign
         double curDx3  = (double)sP3x - curCx;
         double curDy3  = (double)sP3y - curCy;
         double curPerpSide = -curDx3 * curSinT + curDy3 * curCosT;
         double curB = MathAbs(curPerpSide);
         if(curB < 1.0) curB = 1.0;
         double curSignP3 = (curPerpSide >= 0.0) ? 1.0 : -1.0;
         //--- Dispatch on the dragged handle index
         switch(m_draggedHandleIdx)
           {
            case 0:
            case 1:
              {
               //--- P1 or P2 dragged: update the stored endpoint directly
               if(m_draggedHandleIdx == 0)
                 {
                  m_drawnObjects[idx].time1  = newTime;
                  m_drawnObjects[idx].price1 = newPrice;
                 }
               else
                 {
                  m_drawnObjects[idx].time2  = newTime;
                  m_drawnObjects[idx].price2 = newPrice;
                 }
               //--- Re-read the new P1 and P2 in screen coords to build the NEW major axis
               int nP1x = 0, nP1y = 0, nP2x = 0, nP2y = 0;
               ChartTimePriceToXY(m_chartId, 0, m_drawnObjects[idx].time1, m_drawnObjects[idx].price1, nP1x, nP1y);
               ChartTimePriceToXY(m_chartId, 0, m_drawnObjects[idx].time2, m_drawnObjects[idx].price2, nP2x, nP2y);
               //--- Compute the new center, unit vector cos/sin
               double nCx  = (nP1x + nP2x) * 0.5;
               double nCy  = (nP1y + nP2y) * 0.5;
               double nDx  = (double)(nP2x - nP1x);
               double nDy  = (double)(nP2y - nP1y);
               double nLen = MathSqrt(nDx * nDx + nDy * nDy);
               if(nLen < 1e-9) break;
               double nCosT = nDx / nLen;
               double nSinT = nDy / nLen;
               //--- Place new P3 at the same minor-axis length curB on the same curSignP3 side
               double perpX = -nSinT * curSignP3;
               double perpY =  nCosT * curSignP3;
               int newP3x = (int)MathRound(nCx + perpX * curB);
               int newP3y = (int)MathRound(nCy + perpY * curB);
               //--- Convert P3 back to (time, price) storage
               datetime newP3t; double newP3p; int subP3;
               if(ChartXYToTimePrice(m_chartId, newP3x, newP3y, subP3, newP3t, newP3p))
                 {
                  m_drawnObjects[idx].time3  = newP3t;
                  m_drawnObjects[idx].price3 = newP3p;
                 }
               break;
              }
            case 2:
            case 3:
              {
               //--- Minor-axis endpoint drag: change b only, preserve side
               int mxS = 0, myS = 0;
               ChartTimePriceToXY(m_chartId, 0, newTime, newPrice, mxS, myS);
               //--- Project the cursor onto the current major-axis perpendicular for new b
               double dxM = (double)mxS - curCx;
               double dyM = (double)myS - curCy;
               double newPerp = -dxM * curSinT + dyM * curCosT;
               double newB = MathAbs(newPerp);
               if(newB < 1.0) newB = 1.0;
               //--- P3 stays on its original side curSignP3; only the magnitude (b) changes
               double perpX = -curSinT * curSignP3;
               double perpY =  curCosT * curSignP3;
               int newP3x = (int)MathRound(curCx + perpX * newB);
               int newP3y = (int)MathRound(curCy + perpY * newB);
               //--- Convert P3 back to (time, price) storage
               datetime newP3t; double newP3p; int subP3;
               if(ChartXYToTimePrice(m_chartId, newP3x, newP3y, subP3, newP3t, newP3p))
                 {
                  m_drawnObjects[idx].time3  = newP3t;
                  m_drawnObjects[idx].price3 = newP3p;
                 }
               break;
              }
           }
        }
      //--- All other tools: dragged handle moves directly to the cursor (no symmetry)
      else
        {
         //--- Dispatch on the dragged handle index for the generic 3-anchor tools
         switch(m_draggedHandleIdx)
           {
            case 0: m_drawnObjects[idx].time1 = newTime; m_drawnObjects[idx].price1 = newPrice; break;
            case 1: m_drawnObjects[idx].time2 = newTime; m_drawnObjects[idx].price2 = newPrice; break;
            case 2: m_drawnObjects[idx].time3 = newTime; m_drawnObjects[idx].price3 = newPrice; break;
           }
        }
      //--- Trigger a redraw so the user sees the reshape in real time
      RedrawAllObjects();
     }
  }

//+------------------------------------------------------------------+
//| Handle pointer drag release - resolve pending edits and clean up |
//+------------------------------------------------------------------+
void CDrawingEngine::HandlePointerDragRelease()
  {
   //--- Pending Text-annotation edit: decide between drag and edit based on movement
   if(m_pendingTextEditArmed)
     {
      //--- Compare cumulative cursor movement against a 4px hand-jitter threshold
      int dx = m_dragLastMouseX - m_pendingTextEditStartX;
      int dy = m_dragLastMouseY - m_pendingTextEditStartY;
      bool movedMeaningfully = (dx * dx + dy * dy) > (4 * 4);
      if(!movedMeaningfully)
        {
         //--- Pure click on the Text body: clear drag state and enter edit mode
         m_isDraggingObject = false;
         m_draggedHandleIdx = -1;
         m_isDraggingHandle = false;
         m_pendingTextEditArmed = false;
         StartLabelEdit();
         RedrawAllObjects();
         return;
        }
      //--- The cursor moved meaningfully: it was a real drag, fall through to normal release
      m_pendingTextEditArmed = false;
     }
   //--- Cache whether any drag actually occurred so we know whether to redraw afterwards
   bool wasDragging = (m_isDraggingHandle || m_isDraggingObject);
   //--- Clear all drag-state flags so a new click starts fresh
   m_isDraggingHandle = false;
   m_isDraggingObject = false;
   m_draggedHandleIdx = -1;
   //--- Redraw to restore the hidden-during-drag handle and any prompt visibility
   if(wasDragging) { MarkDrawingsDirty(); RedrawAllObjects(); }
   //--- Do not restore chart scroll here; pointer mode keeps it locked until tool switch
  }

//+------------------------------------------------------------------+
//| Delete the currently selected drawn object and clear hover state |
//+------------------------------------------------------------------+
void CDrawingEngine::DeleteSelectedObject()
  {
   //--- Bail out when nothing is selected
   if(m_selectedObjectId < 0) return;
   //--- Remove the object from the engine's drawn list
   RemoveDrawnObject(m_selectedObjectId);
   //--- Clear selection and hover so stale IDs don't linger after removal
   m_selectedObjectId = -1;
   m_hoveredObjectId  = -1;
  }

#endif // TOOLS_PALETTE_ENGINE_INTERACT_MQH
//+------------------------------------------------------------------+
