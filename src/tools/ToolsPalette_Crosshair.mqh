//+------------------------------------------------------------------+
//|                                       ToolsPalette_Crosshair.mqh |
//|                                            Copyright 2026, Om J. |
//|                                               https://t.me/HZFXI |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Om J."
#property link "https://t.me/HZFXI"
#property version "1.00"
#property strict

//--- Guard against multiple inclusion of this header
#ifndef TOOLS_PALETTE_CROSSHAIR_MQH
#define TOOLS_PALETTE_CROSSHAIR_MQH

//--- Pull in the primitives layer (BlendPixelSet, DrawBresenhamLine, CThemeManager)
#include "../primitives/ToolsPalette_Primitives.mqh"

//+------------------------------------------------------------------+
//| Crosshair and magnifier configuration inputs                     |
//+------------------------------------------------------------------+
input group "Crosshair Settings"
input int    ReticleOffset     = 30;      // Crosshair Reticle Offset (px)
input int    ReticleTickLen    = 14;      // Crosshair Reticle Tick Length (px)
input int    ReticleThickness  = 2;       // Crosshair Reticle Tick Thickness (px)
input int    MagDiameter       = 180;     // Magnifier Diameter (px)
input double MagZoom           = 3.0;     // Magnifier Zoom Factor
input int    MagOffset         = 45;      // Magnifier Offset From Cursor (px)
input int    AxisLabelFontSize = 9;       // Axis Label Font Size (pt)
input string AxisLabelFont     = "Arial"; // Axis Label Font

//+------------------------------------------------------------------+
//| CCrosshairManager class declaration                              |
//+------------------------------------------------------------------+
class CCrosshairManager : public CThemeManager
  {
protected:
   //--- Canvas objects for every rendered crosshair element
   CCanvas  m_canvasReticle;
   CCanvas  m_canvasMagnifier;
   CCanvas  m_canvasCrossVertical;
   CCanvas  m_canvasCrossHorizontal;
   CCanvas  m_canvasCrossPriceLabel;
   CCanvas  m_canvasCrossTimeLabel;
   CCanvas  m_canvasMeasureVertical;
   CCanvas  m_canvasMeasureHorizontal;
   CCanvas  m_canvasMeasurePriceLabel;
   CCanvas  m_canvasMeasureTimeLabel;
   CCanvas  m_canvasMeasureDiagonalLine;

   //--- Chart object names matching each canvas (assigned by the owning EA)
   string   m_nameReticle;
   string   m_nameMagnifier;
   string   m_nameCrossVertical;
   string   m_nameCrossHorizontal;
   string   m_nameCrossPriceLabel;
   string   m_nameCrossTimeLabel;
   string   m_nameMeasureVertical;
   string   m_nameMeasureHorizontal;
   string   m_nameMeasurePriceLabel;
   string   m_nameMeasureTimeLabel;
   string   m_nameMeasureDiagonalLine;

   //--- Target chart identifier
   long     m_chartId;

   //--- Reticle visibility and sizing state
   int      m_reticleCanvasSize;
   bool     m_isReticleVisible;

   //--- Magnifier visibility and last-known cursor position for redraw skipping
   bool     m_isMagnifierVisible;
   int      m_lastMagMouseX;
   int      m_lastMagMouseY;

   //--- Crosshair line and label visibility flags
   bool     m_isCrossVertVisible;
   bool     m_isCrossHorizVisible;
   bool     m_isCrossPriceLabelVisible;
   bool     m_isCrossTimeLabelVisible;

   //--- Measure mode visibility flags and anchor state
   bool     m_isMeasureVertVisible;
   bool     m_isMeasureHorizVisible;
   bool     m_isMeasurePriceLabelVisible;
   bool     m_isMeasureTimeLabelVisible;
   bool     m_isMeasureDiagonalVisible;
   bool     m_isMeasuringActive;
   datetime m_measureAnchorTime;
   double   m_measureAnchorPrice;
   int      m_measureAnchorPixelX;
   int      m_measureAnchorPixelY;
   ulong    m_lastClickTimeMicros;

protected:
   //--- Fill the crosshair vertical line canvas with the foreground color
   void     DrawCrossVerticalLinePixels(int chartH);
   //--- Fill the crosshair horizontal line canvas with the foreground color
   void     DrawCrossHorizontalLinePixels(int chartW);
   //--- Fill the measure vertical line canvas at reduced opacity
   void     DrawMeasureVerticalLinePixels(int chartH);
   //--- Fill the measure horizontal line canvas at reduced opacity
   void     DrawMeasureHorizontalLinePixels(int chartW);
   //--- Draw the reticle tick-mark cross onto the reticle canvas
   void     DrawReticleTickMarks();
   //--- Draw and position one axis label canvas next to the crosshair
   void     DrawAndPositionAxisLabel(CCanvas &labelCanvas, string objectName, string labelText,
                                     bool isPriceAxis, int crosshairPixelPos, int chartWidth, int chartHeight);
   //--- Render the zoomed candle chart content inside the magnifier lens
   void     DrawMagnifierLensContent(int mouseX, int mouseY, datetime centerTime, double centerPrice);
   //--- Create all crosshair canvas objects on the chart
   bool     CreateCrosshairCanvases();
   //--- Destroy all crosshair canvas objects
   void     DestroyCrosshairCanvases();
   //--- Show the reticle on the chart
   void     ShowReticle();
   //--- Hide the reticle from the chart
   void     HideReticle();
   //--- Move the reticle to follow the mouse cursor
   void     UpdateReticlePosition(int mouseX, int mouseY);
   //--- Show the crosshair vertical line
   void     ShowCrossVertical();
   //--- Hide the crosshair vertical line
   void     HideCrossVertical();
   //--- Move the crosshair vertical line to track mouseX
   void     UpdateCrossVerticalPosition(int mouseX);
   //--- Show the crosshair horizontal line
   void     ShowCrossHorizontal();
   //--- Hide the crosshair horizontal line
   void     HideCrossHorizontal();
   //--- Move the crosshair horizontal line to track mouseY
   void     UpdateCrossHorizontalPosition(int mouseY);
   //--- Show the crosshair price axis label
   void     ShowCrossPriceLabel();
   //--- Hide the crosshair price axis label
   void     HideCrossPriceLabel();
   //--- Show the crosshair time axis label
   void     ShowCrossTimeLabel();
   //--- Hide the crosshair time axis label
   void     HideCrossTimeLabel();
   //--- Update both crosshair axis labels for the current mouse position
   void     UpdateCrosshairAxisLabels(int mouseX, int mouseY, datetime barTime, double barPrice);
   //--- Show all measure mode canvases
   void     ShowMeasureLines();
   //--- Hide all measure mode canvases and clear the diagonal canvas
   void     HideMeasureLines();
   //--- Position the measure anchor vertical line at pixelX
   void     UpdateMeasureVerticalPosition(int pixelX);
   //--- Position the measure anchor horizontal line at pixelY
   void     UpdateMeasureHorizontalPosition(int pixelY);
   //--- Refresh the measure anchor axis labels from the stored anchor
   void     UpdateMeasureAnchorLabels();
   //--- Redraw the measure diagonal line from the anchor to the cursor
   void     UpdateMeasureDiagonalLine(int currentMouseX, int currentMouseY);
   //--- Update the floating measure info label near the cursor
   void     UpdateMeasurementInfoLabel(int mouseX, int mouseY, datetime barTime, double barPrice);
   //--- Delete every measure chart object and hide the measure canvases
   void     DeleteAllMeasureObjects();
   //--- Show the magnifier on the chart
   void     ShowMagnifier();
   //--- Hide the magnifier from the chart
   void     HideMagnifier();
   //--- Move the magnifier and redraw its lens content when the cursor has moved
   void     UpdateMagnifierPosition(int mouseX, int mouseY, datetime barTime, double barPrice);
   //--- Show every crosshair element in one call
   void     ShowAllCrosshairElements();
   //--- Hide every crosshair element in one call
   void     HideAllCrosshairElements();
   //--- Handle a potential double-click to toggle measure mode anchor
   void     HandleCrosshairDoubleClick(int mouseX, int mouseY, datetime barTime, double barPrice);
   //--- Resize and redraw all crosshair canvases when the chart geometry changes
   void     OnCrosshairChartChange();
  };

//+------------------------------------------------------------------+
//| Fill the crosshair vertical line canvas with the foreground color|
//+------------------------------------------------------------------+
void CCrosshairManager::DrawCrossVerticalLinePixels(int chartH)
  {
   //--- Reset the canvas to fully transparent
   m_canvasCrossVertical.Erase(0x00000000);
   //--- Compose a fully opaque ARGB color from the chart foreground
   uint col = ColorToARGB((color)ChartGetInteger(0, CHART_COLOR_FOREGROUND), 255);
   //--- Paint every row in the single-column line canvas
   for(int y = 0; y < chartH; y++) m_canvasCrossVertical.PixelSet(0, y, col);
   //--- Push the pixel buffer to the chart object
   m_canvasCrossVertical.Update();
  }

//+------------------------------------------------------------------+
//| Fill the crosshair horizontal line canvas with the foreground    |
//+------------------------------------------------------------------+
void CCrosshairManager::DrawCrossHorizontalLinePixels(int chartW)
  {
   //--- Reset the canvas to fully transparent
   m_canvasCrossHorizontal.Erase(0x00000000);
   //--- Compose a fully opaque ARGB color from the chart foreground
   uint col = ColorToARGB((color)ChartGetInteger(0, CHART_COLOR_FOREGROUND), 255);
   //--- Paint every column in the single-row line canvas
   for(int x = 0; x < chartW; x++) m_canvasCrossHorizontal.PixelSet(x, 0, col);
   //--- Push the pixel buffer to the chart object
   m_canvasCrossHorizontal.Update();
  }

//+------------------------------------------------------------------+
//| Fill the measure vertical line canvas at reduced opacity         |
//+------------------------------------------------------------------+
void CCrosshairManager::DrawMeasureVerticalLinePixels(int chartH)
  {
   //--- Reset the canvas to fully transparent
   m_canvasMeasureVertical.Erase(0x00000000);
   //--- Compose a semi-transparent ARGB color (alpha 200) to differentiate from crosshair
   uint col = ColorToARGB((color)ChartGetInteger(0, CHART_COLOR_FOREGROUND), 200);
   //--- Paint every row in the single-column line canvas
   for(int y = 0; y < chartH; y++) m_canvasMeasureVertical.PixelSet(0, y, col);
   //--- Push the pixel buffer to the chart object
   m_canvasMeasureVertical.Update();
  }

//+------------------------------------------------------------------+
//| Fill the measure horizontal line canvas at reduced opacity       |
//+------------------------------------------------------------------+
void CCrosshairManager::DrawMeasureHorizontalLinePixels(int chartW)
  {
   //--- Reset the canvas to fully transparent
   m_canvasMeasureHorizontal.Erase(0x00000000);
   //--- Compose a semi-transparent ARGB color (alpha 200) to differentiate from crosshair
   uint col = ColorToARGB((color)ChartGetInteger(0, CHART_COLOR_FOREGROUND), 200);
   //--- Paint every column in the single-row line canvas
   for(int x = 0; x < chartW; x++) m_canvasMeasureHorizontal.PixelSet(x, 0, col);
   //--- Push the pixel buffer to the chart object
   m_canvasMeasureHorizontal.Update();
  }

//+------------------------------------------------------------------+
//| Draw the reticle tick-mark cross onto the reticle canvas         |
//+------------------------------------------------------------------+
void CCrosshairManager::DrawReticleTickMarks()
  {
   //--- Reset the reticle canvas to fully transparent
   m_canvasReticle.Erase(0x00000000);
   //--- Compute the canvas center and tick-mark offsets
   int cx = m_reticleCanvasSize / 2, cy = m_reticleCanvasSize / 2;
   int off = ReticleOffset, tl = ReticleTickLen / 2, th = ReticleThickness;
   //--- Compose the tick-mark ARGB color from the chart foreground
   uint col = ColorToARGB((color)ChartGetInteger(0, CHART_COLOR_FOREGROUND), 230);
   //--- Paint the left tick: top half above the center line
   m_canvasReticle.FillRectangle(cx - off - tl, cy - th - 1, cx - off + tl, cy - 2,      col);
   //--- Paint the left tick: bottom half below the center line
   m_canvasReticle.FillRectangle(cx - off - tl, cy + 2,      cx - off + tl, cy + th + 1, col);
   //--- Paint the right tick: top half above the center line
   m_canvasReticle.FillRectangle(cx + off - tl, cy - th - 1, cx + off + tl, cy - 2,      col);
   //--- Paint the right tick: bottom half below the center line
   m_canvasReticle.FillRectangle(cx + off - tl, cy + 2,      cx + off + tl, cy + th + 1, col);
   //--- Paint the top tick: left half before the center column
   m_canvasReticle.FillRectangle(cx - th - 1, cy - off - tl, cx - 2,      cy - off + tl, col);
   //--- Paint the top tick: right half after the center column
   m_canvasReticle.FillRectangle(cx + 2,      cy - off - tl, cx + th + 1, cy - off + tl, col);
   //--- Paint the bottom tick: left half before the center column
   m_canvasReticle.FillRectangle(cx - th - 1, cy + off - tl, cx - 2,      cy + off + tl, col);
   //--- Paint the bottom tick: right half after the center column
   m_canvasReticle.FillRectangle(cx + 2,      cy + off - tl, cx + th + 1, cy + off + tl, col);
   //--- Push the pixel buffer to the chart object
   m_canvasReticle.Update();
  }

//+------------------------------------------------------------------+
//| Draw and position one axis label canvas next to the crosshair    |
//+------------------------------------------------------------------+
void CCrosshairManager::DrawAndPositionAxisLabel(CCanvas &labelCanvas, string objectName,
                                                  string labelText, bool isPriceAxis,
                                                  int crosshairPixelPos, int chartWidth, int chartHeight)
  {
   //--- Read the chart foreground and background colors
   color fgColor = (color)ChartGetInteger(0, CHART_COLOR_FOREGROUND);
   color bgColor = (color)ChartGetInteger(0, CHART_COLOR_BACKGROUND);
   //--- Compose fully opaque ARGB values for text and background
   uint  fg = ColorToARGB(fgColor, 255), bg = ColorToARGB(bgColor, 255);
   //--- Configure the font for upcoming measurement and rendering
   TextSetFont(AxisLabelFont, -AxisLabelFontSize * 10);
   //--- Measure the label text dimensions
   uint tw = 0, th = 0;
   TextGetSize(labelText, tw, th);
   //--- Compute the canvas dimensions with padding
   int lw = (int)tw + 8, lh = (int)th + 4;
   //--- Resize the canvas only when dimensions actually change
   if(labelCanvas.Width() != lw || labelCanvas.Height() != lh) labelCanvas.Resize(lw, lh);
   //--- Sync the chart object dimensions with the canvas
   ObjectSetInteger(0, objectName, OBJPROP_XSIZE, lw);
   ObjectSetInteger(0, objectName, OBJPROP_YSIZE, lh);
   //--- Allocate a backing buffer for the off-screen text render
   uint textBuf[];
   int totalPx = lw * lh;
   ArrayResize(textBuf, totalPx);
   //--- Pre-fill the buffer with the background RGB so AA blends correctly
   ArrayFill(textBuf, 0, totalPx, bg & 0x00FFFFFF);
   //--- Render the label text into the backing buffer
   TextOut(labelText, 4, 2, TA_LEFT | TA_TOP, textBuf, lw, lh, fg & 0x00FFFFFF, COLOR_FORMAT_XRGB_NOALPHA);
   //--- Copy the buffer into the canvas with full alpha applied
   for(int py = 0; py < lh; py++)
      for(int px = 0; px < lw; px++)
         labelCanvas.PixelSet(px, py, textBuf[py * lw + px] | 0xFF000000);
   //--- Stroke a 1px foreground border around the label rectangle
   labelCanvas.Rectangle(0, 0, lw - 1, lh - 1, fg);
   //--- Push the pixel buffer to the chart object
   labelCanvas.Update();
   //--- Position the label canvas based on which axis it sits on
   if(isPriceAxis)
     {
      //--- Price axis label: anchored to the right edge at the crosshair Y
      ObjectSetInteger(0, objectName, OBJPROP_XDISTANCE, chartWidth - lw + 1);
      ObjectSetInteger(0, objectName, OBJPROP_YDISTANCE, crosshairPixelPos - lh / 2);
     }
   else
     {
      //--- Time axis label: anchored to the bottom edge at the crosshair X
      ObjectSetInteger(0, objectName, OBJPROP_XDISTANCE, crosshairPixelPos - lw / 2);
      ObjectSetInteger(0, objectName, OBJPROP_YDISTANCE, chartHeight - lh);
     }
  }

//+------------------------------------------------------------------+
//| Render zoomed candle chart content inside the magnifier lens     |
//+------------------------------------------------------------------+
void CCrosshairManager::DrawMagnifierLensContent(int mouseX, int mouseY, datetime centerTime, double centerPrice)
  {
   //--- Resolve lens diameter, radius, and zoom factor from inputs
   int    diam   = MagDiameter, radius = diam / 2;
   double zoom   = MagZoom;
   //--- Resize the lens canvas only when dimensions actually change
   if(m_canvasMagnifier.Width() != diam || m_canvasMagnifier.Height() != diam)
      m_canvasMagnifier.Resize(diam, diam);
   //--- Reset the lens canvas to fully transparent
   m_canvasMagnifier.Erase(0x00000000);
   //--- Read every chart color used by the magnified candle drawing
   color bgColor  = (color)ChartGetInteger(0, CHART_COLOR_BACKGROUND);
   color fgColor  = (color)ChartGetInteger(0, CHART_COLOR_FOREGROUND);
   color bullBody = (color)ChartGetInteger(0, CHART_COLOR_CANDLE_BULL);
   color bearBody = (color)ChartGetInteger(0, CHART_COLOR_CANDLE_BEAR);
   color bullBord = (color)ChartGetInteger(0, CHART_COLOR_CHART_UP);
   color bearBord = (color)ChartGetInteger(0, CHART_COLOR_CHART_DOWN);
   color askColor = (color)ChartGetInteger(0, CHART_COLOR_ASK);
   color bidColor = (color)ChartGetInteger(0, CHART_COLOR_BID);
   //--- Read the Bid/Ask line visibility flags from the chart configuration
   bool  showAsk  = (ChartGetInteger(0, CHART_SHOW_ASK_LINE) != 0);
   bool  showBid  = (ChartGetInteger(0, CHART_SHOW_BID_LINE) != 0);
   //--- Read chart geometry and price scale parameters for coordinate mapping
   int    chartH      = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
   double chartMax    = ChartGetDouble(0, CHART_PRICE_MAX, 0);
   double chartMin    = ChartGetDouble(0, CHART_PRICE_MIN, 0);
   //--- Guard the price range against degenerate near-zero values
   double chartRange  = MathMax(chartMax - chartMin, _Point * 100);
   //--- Compute the on-chart bar pixel width from the current chart scale
   int    barWidth    = (int)MathPow(2.0, (int)ChartGetInteger(0, CHART_SCALE));
   //--- Compute price-per-pixel and the lens content radius squared
   double pricePerPixel = chartRange / chartH;
   double radiusSq    = (double)(radius - 3) * (radius - 3);
   //--- Fill the circular background of the lens
   uint   bgARGB  = ColorToARGB(bgColor, 255);
   double bgRSq   = (double)(radius - 2) * (radius - 2);
   for(int py = 0; py < diam; py++)
      for(int px = 0; px < diam; px++)
        {
         //--- Test pixel distance to the canvas center; paint inside the circle
         double ddx = px - radius, ddy = py - radius;
         if(ddx * ddx + ddy * ddy <= bgRSq) m_canvasMagnifier.PixelSet(px, py, bgARGB);
        }
   //--- Fetch bars centered on the cursor for the lens candle render
   int chartVisibleBars = (int)ChartGetInteger(0, CHART_VISIBLE_BARS);
   //--- Cap the half-range to avoid reading more bars than the chart shows
   int halfRange = MathMin((int)((radius * 2.0 / zoom) / MathMax(1, barWidth)) / 2 + 2, chartVisibleBars / 2 + 2);
   //--- Locate the bar at the cursor time
   int cursorBar = iBarShift(_Symbol, _Period, centerTime, false);
   if(cursorBar < 0) cursorBar = 0;
   //--- Copy the bar window centered on cursorBar into a MqlRates array
   MqlRates rates[];
   ArraySetAsSeries(rates, false);
   int startBar = MathMax(0, cursorBar - halfRange);
   int copied   = CopyRates(_Symbol, _Period, startBar, cursorBar + halfRange + 1 - startBar, rates);
   //--- Compute wick and border thicknesses scaled by the zoom factor
   int wickThickness   = MathMax(1, (int)MathRound(zoom * 0.55));
   int borderThickness = MathMax(1, (int)MathRound(zoom * 0.45));
   //--- Render each fetched bar as a candle within the lens
   if(copied > 0)
     {
      for(int i = 0; i < copied; i++)
        {
         //--- Map this bar's close time and price to absolute chart pixel coordinates
         int barPxX = 0, barPxY = 0;
         if(!ChartTimePriceToXY(m_chartId, 0, rates[i].time, rates[i].close, barPxX, barPxY)) continue;
         //--- Translate the chart pixel X into a lens-relative X (zoomed)
         int lensX = radius + (int)((barPxX - mouseX) * zoom);
         //--- Compute the zoomed candle body half-width with odd-pixel correction
         int zbw = MathMax(3, (int)(barWidth * zoom * 0.65)); if(zbw % 2 == 0) zbw++;
         int bh  = zbw / 2;
         //--- Skip bars whose body falls entirely outside the lens
         if(lensX + bh < 0 || lensX - bh >= diam) continue;
         //--- Determine bull vs bear coloring for this bar
         bool isBull     = (rates[i].close >= rates[i].open);
         uint wickARGB   = ColorToARGB(isBull ? bullBord : bearBord, 255);
         uint bodyARGB   = ColorToARGB(isBull ? bullBody : bearBody, 255);
         uint borderARGB = ColorToARGB(isBull ? bullBord : bearBord, 255);
         //--- Compute the lens-relative wick high and low Y coordinates
         int lensHi = radius - (int)((rates[i].high  - centerPrice) / pricePerPixel * zoom);
         int lensLo = radius - (int)((rates[i].low   - centerPrice) / pricePerPixel * zoom);
         //--- Identify the body top and bottom prices based on bull/bear orientation
         double bTop = isBull ? rates[i].close : rates[i].open;
         double bBot = isBull ? rates[i].open  : rates[i].close;
         //--- Compute the lens-relative body top and bottom Y coordinates
         int lensBT  = radius - (int)((bTop - centerPrice) / pricePerPixel * zoom);
         int lensBB  = radius - (int)((bBot - centerPrice) / pricePerPixel * zoom);
         //--- Guarantee a minimum 1px body height
         if(lensBB - lensBT < 1) lensBB = lensBT + 1;
         //--- Paint the wick column with circular-clip masking
         int wickHalf = wickThickness / 2;
         for(int wy = MathMax(0, lensHi); wy <= MathMin(diam - 1, lensLo); wy++)
            for(int wx = lensX - wickHalf; wx <= lensX + wickHalf; wx++)
              {
               //--- Skip pixels outside the lens horizontal bounds
               if(wx < 0 || wx >= diam) continue;
               //--- Test pixel against the lens circle and paint the wick color
               double ddx = wx - radius, ddy = wy - radius;
               if(ddx * ddx + ddy * ddy < radiusSq) m_canvasMagnifier.PixelSet(wx, wy, wickARGB);
              }
         //--- Fill the candle body with circular-clip masking
         for(int by = MathMax(0, lensBT); by <= MathMin(diam - 1, lensBB); by++)
            for(int bx = lensX - bh; bx <= lensX + bh; bx++)
              {
               //--- Skip pixels outside the lens horizontal bounds
               if(bx < 0 || bx >= diam) continue;
               //--- Test pixel against the lens circle and paint the body color
               double ddx = bx - radius, ddy = by - radius;
               if(ddx * ddx + ddy * ddy < radiusSq) m_canvasMagnifier.PixelSet(bx, by, bodyARGB);
              }
         //--- Stroke the body border rows at top and bottom
         for(int bt = 0; bt < borderThickness; bt++)
           {
            //--- Compute the border row Y coordinates with lens clamping
            int topRow = MathMax(0, lensBT + bt), botRow = MathMin(diam - 1, lensBB - bt);
            for(int bx = lensX - bh; bx <= lensX + bh; bx++)
              {
               //--- Skip pixels outside the lens horizontal bounds
               if(bx < 0 || bx >= diam) continue;
               //--- Test the top and bottom border pixels against the lens circle
               double ddx = bx - radius;
               double ddyT = topRow - radius, ddyB = botRow - radius;
               if(ddx * ddx + ddyT * ddyT < radiusSq) m_canvasMagnifier.PixelSet(bx, topRow, borderARGB);
               if(ddx * ddx + ddyB * ddyB < radiusSq) m_canvasMagnifier.PixelSet(bx, botRow, borderARGB);
              }
            //--- Compute the left and right border column X positions for this row
            int leftCol = lensX - bh + bt, rightCol = lensX + bh - bt;
            for(int by = MathMax(0, lensBT); by <= MathMin(diam - 1, lensBB); by++)
              {
               //--- Test the left and right border pixels against the lens circle
               double ddy  = by - radius;
               double ddxL = leftCol  - radius, ddxR = rightCol - radius;
               if(leftCol  >= 0 && leftCol  < diam && ddxL * ddxL + ddy * ddy < radiusSq) m_canvasMagnifier.PixelSet(leftCol,  by, borderARGB);
               if(rightCol >= 0 && rightCol < diam && ddxR * ddxR + ddy * ddy < radiusSq) m_canvasMagnifier.PixelSet(rightCol, by, borderARGB);
              }
           }
        }
     }
   //--- Overlay Bid line if the chart shows it
   if(showBid)
     {
      //--- Read the current Bid price and map it into the lens Y coordinate
      double bidPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      int    bidY     = radius - (int)((bidPrice - centerPrice) / pricePerPixel * zoom);
      uint   bidARGB  = ColorToARGB(bidColor, 200);
      //--- Paint the Bid line across the lens with circular clipping
      for(int gx = 0; gx < diam; gx++)
        {
         double ddx = gx - radius, ddy = bidY - radius;
         if(ddx * ddx + ddy * ddy < radiusSq) BlendPixelSet(m_canvasMagnifier, gx, bidY, bidARGB);
        }
     }
   //--- Overlay Ask line if the chart shows it
   if(showAsk)
     {
      //--- Read the current Ask price and map it into the lens Y coordinate
      double askPrice = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      int    askY     = radius - (int)((askPrice - centerPrice) / pricePerPixel * zoom);
      uint   askARGB  = ColorToARGB(askColor, 200);
      //--- Paint the Ask line across the lens with circular clipping
      for(int gx = 0; gx < diam; gx++)
        {
         double ddx = gx - radius, ddy = askY - radius;
         if(ddx * ddx + ddy * ddy < radiusSq) BlendPixelSet(m_canvasMagnifier, gx, askY, askARGB);
        }
     }
   //--- Stroke the AA ring border around the lens edge
   uint   ringARGB = ColorToARGB(m_isDarkTheme ? C'140,150,170' : C'80,90,110', 255);
   double outerR   = radius - 1.0, innerR = outerR - 2.5;
   for(int py = 0; py < diam; py++)
      for(int px = 0; px < diam; px++)
        {
         //--- Compute distance from the pixel center to the lens center
         double ddx = px - radius + 0.5, ddy = py - radius + 0.5;
         double dist = MathSqrt(ddx * ddx + ddy * ddy);
         //--- Skip pixels outside the ring annulus
         if(dist < innerR - 1.0 || dist > outerR + 1.0) continue;
         //--- Compute the AA coverage alpha at the ring edges
         double alpha = MathMin(MathMin(1.0, dist - (innerR - 1.0)), MathMin(1.0, outerR + 1.0 - dist));
         if(alpha <= 0.0) continue;
         //--- Blend the ring pixel with computed alpha onto the lens
         BlendPixelSet(m_canvasMagnifier, px, py, ((uint)(uchar)(alpha * 255.0) << 24) | (ringARGB & 0x00FFFFFF));
        }
   //--- Draw a faint dashed crosshair through the lens center
   uint crossARGB = ColorToARGB(fgColor, 60);
   //--- Horizontal dashed center line across the lens
   for(int px = 0; px < diam; px++)
     {
      //--- 4-pixel dash pattern (skip every 4th pixel for the gap)
      if(px % 4 == 0) continue;
      //--- Skip pixels outside the lens circle
      double ddx = (double)(px - radius);
      if(ddx * ddx >= radiusSq) continue;
      //--- Blend the crosshair pixel onto the lens
      BlendPixelSet(m_canvasMagnifier, px, radius, crossARGB);
     }
   //--- Vertical dashed center line down the lens
   for(int py = 0; py < diam; py++)
     {
      //--- 4-pixel dash pattern (skip every 4th pixel for the gap)
      if(py % 4 == 0) continue;
      //--- Skip pixels outside the lens circle
      double ddy = (double)(py - radius);
      if(ddy * ddy >= radiusSq) continue;
      //--- Blend the crosshair pixel onto the lens
      BlendPixelSet(m_canvasMagnifier, radius, py, crossARGB);
     }
   //--- Render the center price label inside the lower portion of the lens
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   m_canvasMagnifier.FontSet("Arial Bold", 11);
   //--- Format the price at the symbol's digit precision
   string priceStr = DoubleToString(centerPrice, digits);
   //--- Measure the text dimensions for centering math
   int tw = m_canvasMagnifier.TextWidth(priceStr), th = m_canvasMagnifier.TextHeight(priceStr);
   //--- Compute the label origin centered horizontally in the lower band
   int tx = radius - tw / 2, ty = diam - th - 16;
   double tdy = ty - radius;
   //--- Render the label only when it fits inside the lens circle
   if(tdy * tdy + 4 < radiusSq)
     {
      //--- Paint an opaque background rectangle behind the price text
      m_canvasMagnifier.FillRectangle(tx - 4, ty - 1, tx + tw + 4, ty + th + 1,
         (ringARGB & 0x00FFFFFF) | 0xFF000000);
      //--- Draw the price text in white over the background rectangle
      m_canvasMagnifier.TextOut(tx, ty, priceStr, ColorToARGB(clrWhite, 255));
     }
   //--- Push the pixel buffer to the chart object
   m_canvasMagnifier.Update();
  }

//+------------------------------------------------------------------+
//| Create all crosshair canvas objects                              |
//+------------------------------------------------------------------+
bool CCrosshairManager::CreateCrosshairCanvases()
  {
   //--- Read the current chart width and height in pixels
   int chartW = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
   int chartH = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
   //--- Compute the reticle canvas size big enough to host its tick marks
   int reticleSize = 2 * (ReticleOffset + ReticleTickLen / 2) + 6;
   m_reticleCanvasSize = reticleSize;
   //--- Create the reticle canvas as a square bitmap label
   if(!m_canvasReticle.CreateBitmapLabel(0, 0, m_nameReticle, 0, 0, reticleSize, reticleSize, COLOR_FORMAT_ARGB_NORMALIZE))
     { Print("Failed to create reticle canvas"); return false; }
   //--- Hide on all periods initially and set a high z-order for overlay rendering
   ObjectSetInteger(0, m_nameReticle, OBJPROP_TIMEFRAMES, OBJ_NO_PERIODS);
   ObjectSetInteger(0, m_nameReticle, OBJPROP_ZORDER, 90);
   //--- Create the magnifier lens canvas
   if(!m_canvasMagnifier.CreateBitmapLabel(0, 0, m_nameMagnifier, 0, 0, MagDiameter, MagDiameter, COLOR_FORMAT_ARGB_NORMALIZE))
     { Print("Failed to create magnifier canvas"); return false; }
   //--- Hide on all periods initially and set the highest z-order in this group
   ObjectSetInteger(0, m_nameMagnifier, OBJPROP_TIMEFRAMES, OBJ_NO_PERIODS);
   ObjectSetInteger(0, m_nameMagnifier, OBJPROP_ZORDER, 95);
   //--- Create the crosshair vertical line (1px wide, full chart height)
   if(!m_canvasCrossVertical.CreateBitmapLabel(0, 0, m_nameCrossVertical, 0, 0, 1, chartH, COLOR_FORMAT_ARGB_NORMALIZE))
     { Print("Failed to create cross vertical canvas"); return false; }
   ObjectSetInteger(0, m_nameCrossVertical, OBJPROP_TIMEFRAMES, OBJ_NO_PERIODS);
   ObjectSetInteger(0, m_nameCrossVertical, OBJPROP_ZORDER, 80);
   //--- Pre-paint the vertical line pixels so toggling visibility is instant
   DrawCrossVerticalLinePixels(chartH);
   //--- Create the crosshair horizontal line (full chart width, 1px tall)
   if(!m_canvasCrossHorizontal.CreateBitmapLabel(0, 0, m_nameCrossHorizontal, 0, 0, chartW, 1, COLOR_FORMAT_ARGB_NORMALIZE))
     { Print("Failed to create cross horizontal canvas"); return false; }
   ObjectSetInteger(0, m_nameCrossHorizontal, OBJPROP_TIMEFRAMES, OBJ_NO_PERIODS);
   ObjectSetInteger(0, m_nameCrossHorizontal, OBJPROP_ZORDER, 80);
   //--- Pre-paint the horizontal line pixels so toggling visibility is instant
   DrawCrossHorizontalLinePixels(chartW);
   //--- Create the crosshair price axis label canvas
   if(!m_canvasCrossPriceLabel.CreateBitmapLabel(0, 0, m_nameCrossPriceLabel, 0, 0, 80, 18, COLOR_FORMAT_ARGB_NORMALIZE))
     { Print("Failed to create cross price label canvas"); return false; }
   ObjectSetInteger(0, m_nameCrossPriceLabel, OBJPROP_TIMEFRAMES, OBJ_NO_PERIODS);
   ObjectSetInteger(0, m_nameCrossPriceLabel, OBJPROP_ZORDER, 85);
   //--- Create the crosshair time axis label canvas
   if(!m_canvasCrossTimeLabel.CreateBitmapLabel(0, 0, m_nameCrossTimeLabel, 0, 0, 140, 18, COLOR_FORMAT_ARGB_NORMALIZE))
     { Print("Failed to create cross time label canvas"); return false; }
   ObjectSetInteger(0, m_nameCrossTimeLabel, OBJPROP_TIMEFRAMES, OBJ_NO_PERIODS);
   ObjectSetInteger(0, m_nameCrossTimeLabel, OBJPROP_ZORDER, 85);
   //--- Create the measure mode vertical line
   if(!m_canvasMeasureVertical.CreateBitmapLabel(0, 0, m_nameMeasureVertical, 0, 0, 1, chartH, COLOR_FORMAT_ARGB_NORMALIZE))
     { Print("Failed to create measure vertical canvas"); return false; }
   ObjectSetInteger(0, m_nameMeasureVertical, OBJPROP_TIMEFRAMES, OBJ_NO_PERIODS);
   ObjectSetInteger(0, m_nameMeasureVertical, OBJPROP_ZORDER, 79);
   //--- Pre-paint the measure vertical line pixels for instant toggle
   DrawMeasureVerticalLinePixels(chartH);
   //--- Create the measure mode horizontal line
   if(!m_canvasMeasureHorizontal.CreateBitmapLabel(0, 0, m_nameMeasureHorizontal, 0, 0, chartW, 1, COLOR_FORMAT_ARGB_NORMALIZE))
     { Print("Failed to create measure horizontal canvas"); return false; }
   ObjectSetInteger(0, m_nameMeasureHorizontal, OBJPROP_TIMEFRAMES, OBJ_NO_PERIODS);
   ObjectSetInteger(0, m_nameMeasureHorizontal, OBJPROP_ZORDER, 79);
   //--- Pre-paint the measure horizontal line pixels for instant toggle
   DrawMeasureHorizontalLinePixels(chartW);
   //--- Create the measure mode price axis label canvas
   if(!m_canvasMeasurePriceLabel.CreateBitmapLabel(0, 0, m_nameMeasurePriceLabel, 0, 0, 80, 18, COLOR_FORMAT_ARGB_NORMALIZE))
     { Print("Failed to create measure price label canvas"); return false; }
   ObjectSetInteger(0, m_nameMeasurePriceLabel, OBJPROP_TIMEFRAMES, OBJ_NO_PERIODS);
   ObjectSetInteger(0, m_nameMeasurePriceLabel, OBJPROP_ZORDER, 84);
   //--- Create the measure mode time axis label canvas
   if(!m_canvasMeasureTimeLabel.CreateBitmapLabel(0, 0, m_nameMeasureTimeLabel, 0, 0, 140, 18, COLOR_FORMAT_ARGB_NORMALIZE))
     { Print("Failed to create measure time label canvas"); return false; }
   ObjectSetInteger(0, m_nameMeasureTimeLabel, OBJPROP_TIMEFRAMES, OBJ_NO_PERIODS);
   ObjectSetInteger(0, m_nameMeasureTimeLabel, OBJPROP_ZORDER, 84);
   //--- Create the measure diagonal line canvas (full chart size for arbitrary diagonals)
   if(!m_canvasMeasureDiagonalLine.CreateBitmapLabel(0, 0, m_nameMeasureDiagonalLine, 0, 0, chartW, chartH, COLOR_FORMAT_ARGB_NORMALIZE))
     { Print("Failed to create measure diagonal canvas"); return false; }
   ObjectSetInteger(0, m_nameMeasureDiagonalLine, OBJPROP_TIMEFRAMES, OBJ_NO_PERIODS);
   ObjectSetInteger(0, m_nameMeasureDiagonalLine, OBJPROP_ZORDER, 78);
   //--- Erase the diagonal canvas to fully transparent and push the empty state
   m_canvasMeasureDiagonalLine.Erase(0x00000000);
   m_canvasMeasureDiagonalLine.Update();
   return true;
  }

//+------------------------------------------------------------------+
//| Destroy all crosshair canvas objects                             |
//+------------------------------------------------------------------+
void CCrosshairManager::DestroyCrosshairCanvases()
  {
   //--- Destroy each canvas and delete its matching chart object
   m_canvasReticle.Destroy();             ObjectDelete(0, m_nameReticle);
   m_canvasMagnifier.Destroy();           ObjectDelete(0, m_nameMagnifier);
   m_canvasCrossVertical.Destroy();       ObjectDelete(0, m_nameCrossVertical);
   m_canvasCrossHorizontal.Destroy();     ObjectDelete(0, m_nameCrossHorizontal);
   m_canvasCrossPriceLabel.Destroy();     ObjectDelete(0, m_nameCrossPriceLabel);
   m_canvasCrossTimeLabel.Destroy();      ObjectDelete(0, m_nameCrossTimeLabel);
   m_canvasMeasureVertical.Destroy();     ObjectDelete(0, m_nameMeasureVertical);
   m_canvasMeasureHorizontal.Destroy();   ObjectDelete(0, m_nameMeasureHorizontal);
   m_canvasMeasurePriceLabel.Destroy();   ObjectDelete(0, m_nameMeasurePriceLabel);
   m_canvasMeasureTimeLabel.Destroy();    ObjectDelete(0, m_nameMeasureTimeLabel);
   m_canvasMeasureDiagonalLine.Destroy(); ObjectDelete(0, m_nameMeasureDiagonalLine);
  }

//+------------------------------------------------------------------+
//| Show the reticle on the chart                                    |
//+------------------------------------------------------------------+
void CCrosshairManager::ShowReticle()
  {
   //--- No-op when already visible
   if(m_isReticleVisible) return;
   //--- Repaint the tick marks before revealing the canvas
   DrawReticleTickMarks();
   //--- Reveal the canvas across all chart periods and flag visible
   ObjectSetInteger(0, m_nameReticle, OBJPROP_TIMEFRAMES, OBJ_ALL_PERIODS);
   m_isReticleVisible = true;
  }

//+------------------------------------------------------------------+
//| Hide the reticle from the chart                                  |
//+------------------------------------------------------------------+
void CCrosshairManager::HideReticle()
  {
   //--- No-op when already hidden
   if(!m_isReticleVisible) return;
   //--- Hide the canvas on every chart period and clear the flag
   ObjectSetInteger(0, m_nameReticle, OBJPROP_TIMEFRAMES, OBJ_NO_PERIODS);
   m_isReticleVisible = false;
  }

//+------------------------------------------------------------------+
//| Move the reticle to follow the mouse cursor                      |
//+------------------------------------------------------------------+
void CCrosshairManager::UpdateReticlePosition(int mouseX, int mouseY)
  {
   //--- Skip when the reticle is hidden
   if(!m_isReticleVisible) return;
   //--- Center the reticle canvas on the cursor by subtracting its half-size
   int half = m_reticleCanvasSize / 2;
   ObjectSetInteger(0, m_nameReticle, OBJPROP_XDISTANCE, mouseX - half);
   ObjectSetInteger(0, m_nameReticle, OBJPROP_YDISTANCE, mouseY - half);
  }

//+------------------------------------------------------------------+
//| Show the crosshair vertical line                                 |
//+------------------------------------------------------------------+
void CCrosshairManager::ShowCrossVertical()
  {
   //--- No-op when already visible
   if(m_isCrossVertVisible) return;
   //--- Reveal the canvas across all chart periods and flag visible
   ObjectSetInteger(0, m_nameCrossVertical, OBJPROP_TIMEFRAMES, OBJ_ALL_PERIODS);
   m_isCrossVertVisible = true;
  }

//+------------------------------------------------------------------+
//| Hide the crosshair vertical line                                 |
//+------------------------------------------------------------------+
void CCrosshairManager::HideCrossVertical()
  {
   //--- No-op when already hidden
   if(!m_isCrossVertVisible) return;
   //--- Hide the canvas on every chart period and clear the flag
   ObjectSetInteger(0, m_nameCrossVertical, OBJPROP_TIMEFRAMES, OBJ_NO_PERIODS);
   m_isCrossVertVisible = false;
  }

//+------------------------------------------------------------------+
//| Move the crosshair vertical line to track mouseX                 |
//+------------------------------------------------------------------+
void CCrosshairManager::UpdateCrossVerticalPosition(int mouseX)
  {
   //--- Skip when the vertical line is hidden
   if(!m_isCrossVertVisible) return;
   //--- Anchor the 1px-wide canvas at mouseX, top of chart
   ObjectSetInteger(0, m_nameCrossVertical, OBJPROP_XDISTANCE, mouseX);
   ObjectSetInteger(0, m_nameCrossVertical, OBJPROP_YDISTANCE, 0);
  }

//+------------------------------------------------------------------+
//| Show the crosshair horizontal line                               |
//+------------------------------------------------------------------+
void CCrosshairManager::ShowCrossHorizontal()
  {
   //--- No-op when already visible
   if(m_isCrossHorizVisible) return;
   //--- Reveal the canvas across all chart periods and flag visible
   ObjectSetInteger(0, m_nameCrossHorizontal, OBJPROP_TIMEFRAMES, OBJ_ALL_PERIODS);
   m_isCrossHorizVisible = true;
  }

//+------------------------------------------------------------------+
//| Hide the crosshair horizontal line                               |
//+------------------------------------------------------------------+
void CCrosshairManager::HideCrossHorizontal()
  {
   //--- No-op when already hidden
   if(!m_isCrossHorizVisible) return;
   //--- Hide the canvas on every chart period and clear the flag
   ObjectSetInteger(0, m_nameCrossHorizontal, OBJPROP_TIMEFRAMES, OBJ_NO_PERIODS);
   m_isCrossHorizVisible = false;
  }

//+------------------------------------------------------------------+
//| Move the crosshair horizontal line to track mouseY               |
//+------------------------------------------------------------------+
void CCrosshairManager::UpdateCrossHorizontalPosition(int mouseY)
  {
   //--- Skip when the horizontal line is hidden
   if(!m_isCrossHorizVisible) return;
   //--- Anchor the full-width 1px-tall canvas at left edge, mouseY
   ObjectSetInteger(0, m_nameCrossHorizontal, OBJPROP_XDISTANCE, 0);
   ObjectSetInteger(0, m_nameCrossHorizontal, OBJPROP_YDISTANCE, mouseY);
  }

//+------------------------------------------------------------------+
//| Show the crosshair price axis label                              |
//+------------------------------------------------------------------+
void CCrosshairManager::ShowCrossPriceLabel()
  {
   //--- No-op when already visible
   if(m_isCrossPriceLabelVisible) return;
   //--- Reveal the canvas across all chart periods and flag visible
   ObjectSetInteger(0, m_nameCrossPriceLabel, OBJPROP_TIMEFRAMES, OBJ_ALL_PERIODS);
   m_isCrossPriceLabelVisible = true;
  }

//+------------------------------------------------------------------+
//| Hide the crosshair price axis label                              |
//+------------------------------------------------------------------+
void CCrosshairManager::HideCrossPriceLabel()
  {
   //--- No-op when already hidden
   if(!m_isCrossPriceLabelVisible) return;
   //--- Hide the canvas on every chart period and clear the flag
   ObjectSetInteger(0, m_nameCrossPriceLabel, OBJPROP_TIMEFRAMES, OBJ_NO_PERIODS);
   m_isCrossPriceLabelVisible = false;
  }

//+------------------------------------------------------------------+
//| Show the crosshair time axis label                               |
//+------------------------------------------------------------------+
void CCrosshairManager::ShowCrossTimeLabel()
  {
   //--- No-op when already visible
   if(m_isCrossTimeLabelVisible) return;
   //--- Reveal the canvas across all chart periods and flag visible
   ObjectSetInteger(0, m_nameCrossTimeLabel, OBJPROP_TIMEFRAMES, OBJ_ALL_PERIODS);
   m_isCrossTimeLabelVisible = true;
  }

//+------------------------------------------------------------------+
//| Hide the crosshair time axis label                               |
//+------------------------------------------------------------------+
void CCrosshairManager::HideCrossTimeLabel()
  {
   //--- No-op when already hidden
   if(!m_isCrossTimeLabelVisible) return;
   //--- Hide the canvas on every chart period and clear the flag
   ObjectSetInteger(0, m_nameCrossTimeLabel, OBJPROP_TIMEFRAMES, OBJ_NO_PERIODS);
   m_isCrossTimeLabelVisible = false;
  }

//+------------------------------------------------------------------+
//| Update both crosshair axis labels for the current mouse position |
//+------------------------------------------------------------------+
void CCrosshairManager::UpdateCrosshairAxisLabels(int mouseX, int mouseY, datetime barTime, double barPrice)
  {
   //--- Read chart dimensions and symbol precision for the label render
   int chartW = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
   int chartH = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   //--- Render the price axis label aligned to the crosshair Y position
   DrawAndPositionAxisLabel(m_canvasCrossPriceLabel, m_nameCrossPriceLabel,
      DoubleToString(barPrice, digits), true, mouseY, chartW, chartH);
   //--- Render the time axis label aligned to the crosshair X position
   DrawAndPositionAxisLabel(m_canvasCrossTimeLabel, m_nameCrossTimeLabel,
      TimeToString(barTime, TIME_DATE | TIME_MINUTES), false, mouseX, chartW, chartH);
  }

//+------------------------------------------------------------------+
//| Show all measure mode canvases                                   |
//+------------------------------------------------------------------+
void CCrosshairManager::ShowMeasureLines()
  {
   //--- Reveal the measure vertical line if currently hidden
   if(!m_isMeasureVertVisible)
     { ObjectSetInteger(0, m_nameMeasureVertical,     OBJPROP_TIMEFRAMES, OBJ_ALL_PERIODS); m_isMeasureVertVisible     = true; }
   //--- Reveal the measure horizontal line if currently hidden
   if(!m_isMeasureHorizVisible)
     { ObjectSetInteger(0, m_nameMeasureHorizontal,   OBJPROP_TIMEFRAMES, OBJ_ALL_PERIODS); m_isMeasureHorizVisible    = true; }
   //--- Reveal the measure diagonal line canvas if currently hidden
   if(!m_isMeasureDiagonalVisible)
     { ObjectSetInteger(0, m_nameMeasureDiagonalLine, OBJPROP_TIMEFRAMES, OBJ_ALL_PERIODS); m_isMeasureDiagonalVisible = true; }
   //--- Reveal the measure price axis label if currently hidden
   if(!m_isMeasurePriceLabelVisible)
     { ObjectSetInteger(0, m_nameMeasurePriceLabel,   OBJPROP_TIMEFRAMES, OBJ_ALL_PERIODS); m_isMeasurePriceLabelVisible = true; }
   //--- Reveal the measure time axis label if currently hidden
   if(!m_isMeasureTimeLabelVisible)
     { ObjectSetInteger(0, m_nameMeasureTimeLabel,    OBJPROP_TIMEFRAMES, OBJ_ALL_PERIODS); m_isMeasureTimeLabelVisible  = true; }
  }

//+------------------------------------------------------------------+
//| Hide all measure mode canvases and clear the diagonal canvas     |
//+------------------------------------------------------------------+
void CCrosshairManager::HideMeasureLines()
  {
   //--- Hide the measure vertical line if currently visible
   if(m_isMeasureVertVisible)
     { ObjectSetInteger(0, m_nameMeasureVertical,     OBJPROP_TIMEFRAMES, OBJ_NO_PERIODS); m_isMeasureVertVisible     = false; }
   //--- Hide the measure horizontal line if currently visible
   if(m_isMeasureHorizVisible)
     { ObjectSetInteger(0, m_nameMeasureHorizontal,   OBJPROP_TIMEFRAMES, OBJ_NO_PERIODS); m_isMeasureHorizVisible    = false; }
   //--- Hide the diagonal line and wipe its canvas to leave no stale pixels
   if(m_isMeasureDiagonalVisible)
     {
      ObjectSetInteger(0, m_nameMeasureDiagonalLine, OBJPROP_TIMEFRAMES, OBJ_NO_PERIODS);
      m_canvasMeasureDiagonalLine.Erase(0x00000000);
      m_canvasMeasureDiagonalLine.Update();
      m_isMeasureDiagonalVisible = false;
     }
   //--- Hide the measure price axis label if currently visible
   if(m_isMeasurePriceLabelVisible)
     { ObjectSetInteger(0, m_nameMeasurePriceLabel,   OBJPROP_TIMEFRAMES, OBJ_NO_PERIODS); m_isMeasurePriceLabelVisible = false; }
   //--- Hide the measure time axis label if currently visible
   if(m_isMeasureTimeLabelVisible)
     { ObjectSetInteger(0, m_nameMeasureTimeLabel,    OBJPROP_TIMEFRAMES, OBJ_NO_PERIODS); m_isMeasureTimeLabelVisible  = false; }
  }

//+------------------------------------------------------------------+
//| Position the measure anchor vertical line at pixelX              |
//+------------------------------------------------------------------+
void CCrosshairManager::UpdateMeasureVerticalPosition(int pixelX)
  {
   //--- Skip when the measure vertical line is hidden
   if(!m_isMeasureVertVisible) return;
   //--- Anchor the 1px-wide canvas at pixelX, top of chart
   ObjectSetInteger(0, m_nameMeasureVertical, OBJPROP_XDISTANCE, pixelX);
   ObjectSetInteger(0, m_nameMeasureVertical, OBJPROP_YDISTANCE, 0);
  }

//+------------------------------------------------------------------+
//| Position the measure anchor horizontal line at pixelY            |
//+------------------------------------------------------------------+
void CCrosshairManager::UpdateMeasureHorizontalPosition(int pixelY)
  {
   //--- Skip when the measure horizontal line is hidden
   if(!m_isMeasureHorizVisible) return;
   //--- Anchor the full-width 1px-tall canvas at left edge, pixelY
   ObjectSetInteger(0, m_nameMeasureHorizontal, OBJPROP_XDISTANCE, 0);
   ObjectSetInteger(0, m_nameMeasureHorizontal, OBJPROP_YDISTANCE, pixelY);
  }

//+------------------------------------------------------------------+
//| Refresh the measure anchor axis labels from the stored anchor    |
//+------------------------------------------------------------------+
void CCrosshairManager::UpdateMeasureAnchorLabels()
  {
   //--- Read chart dimensions and symbol precision for the label render
   int chartW = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
   int chartH = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   //--- Map the anchor's time/price back to canvas pixel coordinates; abort on failure
   int fx = 0, fy = 0;
   if(!ChartTimePriceToXY(m_chartId, 0, m_measureAnchorTime, m_measureAnchorPrice, fx, fy)) return;
   //--- Render the price axis label at the anchor Y coordinate
   DrawAndPositionAxisLabel(m_canvasMeasurePriceLabel, m_nameMeasurePriceLabel,
      DoubleToString(m_measureAnchorPrice, digits), true, fy, chartW, chartH);
   //--- Render the time axis label at the anchor X coordinate
   DrawAndPositionAxisLabel(m_canvasMeasureTimeLabel, m_nameMeasureTimeLabel,
      TimeToString(m_measureAnchorTime, TIME_DATE | TIME_MINUTES), false, fx, chartW, chartH);
  }

//+------------------------------------------------------------------+
//| Redraw the measure diagonal line from anchor to cursor           |
//+------------------------------------------------------------------+
void CCrosshairManager::UpdateMeasureDiagonalLine(int currentMouseX, int currentMouseY)
  {
   //--- Skip when the diagonal canvas is hidden
   if(!m_isMeasureDiagonalVisible) return;
   //--- Wipe the previous diagonal stroke from the canvas
   m_canvasMeasureDiagonalLine.Erase(0x00000000);
   //--- Stroke a fresh diagonal from the anchor to the current cursor position
   DrawBresenhamLine(m_canvasMeasureDiagonalLine,
      m_measureAnchorPixelX, m_measureAnchorPixelY, currentMouseX, currentMouseY,
      ColorToARGB((color)ChartGetInteger(0, CHART_COLOR_FOREGROUND), 220));
   //--- Push the pixel buffer to the chart object
   m_canvasMeasureDiagonalLine.Update();
  }

//+------------------------------------------------------------------+
//| Update the floating measure info label near the cursor           |
//+------------------------------------------------------------------+
void CCrosshairManager::UpdateMeasurementInfoLabel(int mouseX, int mouseY, datetime barTime, double barPrice)
  {
   //--- Fixed name for the floating info label object on the chart
   string labelName = "ToolsPalette_MeasureInfoLabel";
   //--- Compute bar-count and pip-distance deltas from anchor to cursor
   long   periodSec = PeriodSeconds(_Period);
   int    barCount  = (int)MathAbs(m_measureAnchorTime / periodSec - barTime / periodSec);
   double pointSize = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   long   digits    = SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   //--- 3 and 5 digit quotes use pip = 10 points; 2 and 4 digit quotes use pip = point
   double pipSize   = (digits == 3 || digits == 5) ? pointSize * 10.0 : pointSize;
   double pips      = MathAbs(barPrice - m_measureAnchorPrice) / pipSize;
   //--- Format the readable measurement summary string
   string labelText = StringFormat("%d bars, %.1f pips, Diff: %s",
      barCount, pips, DoubleToString(MathAbs(barPrice - m_measureAnchorPrice), (int)digits));
   //--- Lazily create the chart label object on first use
   if(ObjectFind(m_chartId, labelName) < 0)
     {
      //--- Create the label object and configure its appearance
      ObjectCreate(m_chartId, labelName, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(m_chartId, labelName, OBJPROP_CORNER,   CORNER_LEFT_UPPER);
      ObjectSetInteger(m_chartId, labelName, OBJPROP_FONTSIZE, 9);
      ObjectSetString(m_chartId,  labelName, OBJPROP_FONT,     "Arial");
      ObjectSetInteger(m_chartId, labelName, OBJPROP_COLOR,
         (color)ChartGetInteger(0, CHART_COLOR_FOREGROUND));
     }
   //--- Position the label just below-right of the cursor and write the text
   ObjectSetInteger(m_chartId, labelName, OBJPROP_XDISTANCE, mouseX + 20);
   ObjectSetInteger(m_chartId, labelName, OBJPROP_YDISTANCE, mouseY + 3);
   ObjectSetString(m_chartId,  labelName, OBJPROP_TEXT,      labelText);
  }

//+------------------------------------------------------------------+
//| Delete every measure chart object and hide the measure canvases  |
//+------------------------------------------------------------------+
void CCrosshairManager::DeleteAllMeasureObjects()
  {
   //--- Hide the measure canvases first so they don't briefly outlive the labels
   HideMeasureLines();
   //--- Remove the floating measurement info label from the chart
   ObjectDelete(m_chartId, "ToolsPalette_MeasureInfoLabel");
  }

//+------------------------------------------------------------------+
//| Show the magnifier on the chart                                  |
//+------------------------------------------------------------------+
void CCrosshairManager::ShowMagnifier()
  {
   //--- No-op when already visible
   if(m_isMagnifierVisible) return;
   //--- Reveal the canvas across all chart periods and flag visible
   ObjectSetInteger(0, m_nameMagnifier, OBJPROP_TIMEFRAMES, OBJ_ALL_PERIODS);
   m_isMagnifierVisible = true;
  }

//+------------------------------------------------------------------+
//| Hide the magnifier from the chart                                |
//+------------------------------------------------------------------+
void CCrosshairManager::HideMagnifier()
  {
   //--- No-op when already hidden
   if(!m_isMagnifierVisible) return;
   //--- Hide the canvas on every chart period and clear the flag
   ObjectSetInteger(0, m_nameMagnifier, OBJPROP_TIMEFRAMES, OBJ_NO_PERIODS);
   m_isMagnifierVisible = false;
  }

//+------------------------------------------------------------------+
//| Move magnifier and redraw lens content if the cursor moved       |
//+------------------------------------------------------------------+
void CCrosshairManager::UpdateMagnifierPosition(int mouseX, int mouseY, datetime barTime, double barPrice)
  {
   //--- Skip when the magnifier is hidden
   if(!m_isMagnifierVisible) return;
   //--- Read chart dimensions and the lens diameter from inputs
   int chartW = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
   int chartH = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
   int diam   = MagDiameter;
   //--- Place the lens to the upper-right of the cursor when possible, else to the upper-left
   int magX = (mouseX + MagOffset + diam < chartW) ? mouseX + MagOffset : mouseX - MagOffset - diam;
   int magY = (mouseY - MagOffset - diam > 0)      ? mouseY - MagOffset - diam : mouseY + MagOffset;
   //--- Clamp the lens position so it stays within a 2px margin of the canvas edge
   magX = MathMax(2, MathMin(chartW - diam - 2, magX));
   magY = MathMax(2, MathMin(chartH - diam - 2, magY));
   //--- Apply the computed position to the lens chart object
   ObjectSetInteger(0, m_nameMagnifier, OBJPROP_XDISTANCE, magX);
   ObjectSetInteger(0, m_nameMagnifier, OBJPROP_YDISTANCE, magY);
   //--- Skip redrawing the lens content if the cursor pixel position has not changed
   if(mouseX == m_lastMagMouseX && mouseY == m_lastMagMouseY) return;
   //--- Cache the new cursor position and redraw the lens content
   m_lastMagMouseX = mouseX;
   m_lastMagMouseY = mouseY;
   DrawMagnifierLensContent(mouseX, mouseY, barTime, barPrice);
  }

//+------------------------------------------------------------------+
//| Show every crosshair element in one call                         |
//+------------------------------------------------------------------+
void CCrosshairManager::ShowAllCrosshairElements()
  {
   //--- Bulk show: reticle, magnifier, cross lines, axis labels
   ShowReticle();
   ShowMagnifier();
   ShowCrossVertical();
   ShowCrossHorizontal();
   ShowCrossPriceLabel();
   ShowCrossTimeLabel();
  }

//+------------------------------------------------------------------+
//| Hide every crosshair element in one call                         |
//+------------------------------------------------------------------+
void CCrosshairManager::HideAllCrosshairElements()
  {
   //--- Bulk hide: reticle, magnifier, cross lines, axis labels
   HideReticle();
   HideMagnifier();
   HideCrossVertical();
   HideCrossHorizontal();
   HideCrossPriceLabel();
   HideCrossTimeLabel();
  }

//+------------------------------------------------------------------+
//| Handle a potential double-click to toggle measure mode anchor    |
//+------------------------------------------------------------------+
void CCrosshairManager::HandleCrosshairDoubleClick(int mouseX, int mouseY, datetime barTime, double barPrice)
  {
   //--- Read the current high-precision timestamp for the double-click window check
   ulong nowMicros = GetMicrosecondCount();
   //--- Treat clicks within 500ms (500000us) of the last click as a double-click
   if(nowMicros - m_lastClickTimeMicros < 500000)
     {
      if(!m_isMeasuringActive)
        {
         //--- Activate measure mode: store the anchor and disable chart scrolling
         m_measureAnchorTime   = barTime;
         m_measureAnchorPrice  = barPrice;
         m_measureAnchorPixelX = mouseX;
         m_measureAnchorPixelY = mouseY;
         m_isMeasuringActive   = true;
         ChartSetInteger(0, CHART_MOUSE_SCROLL, false);
        }
      else
        {
         //--- Deactivate measure mode: clear the canvases and restore chart scrolling
         m_isMeasuringActive = false;
         DeleteAllMeasureObjects();
         ChartSetInteger(0, CHART_MOUSE_SCROLL, true);
        }
      //--- Reset the click timestamp so a triple-click does not re-trigger
      m_lastClickTimeMicros = 0;
     }
   else
     {
      //--- First click: just record the timestamp for the next click's window check
      m_lastClickTimeMicros = nowMicros;
     }
  }

//+------------------------------------------------------------------+
//| Resize and redraw all crosshair canvases on chart geometry change|
//+------------------------------------------------------------------+
void CCrosshairManager::OnCrosshairChartChange()
  {
   //--- Read the new chart dimensions in pixels
   int chartH = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
   int chartW = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
   //--- Resize the crosshair vertical line canvas and repaint its pixels
   m_canvasCrossVertical.Resize(1, chartH);
   DrawCrossVerticalLinePixels(chartH);
   ObjectSetInteger(0, m_nameCrossVertical, OBJPROP_YSIZE, chartH);
   //--- Resize the crosshair horizontal line canvas and repaint its pixels
   m_canvasCrossHorizontal.Resize(chartW, 1);
   DrawCrossHorizontalLinePixels(chartW);
   ObjectSetInteger(0, m_nameCrossHorizontal, OBJPROP_XSIZE, chartW);
   //--- Resize the measure vertical line canvas and repaint its pixels
   m_canvasMeasureVertical.Resize(1, chartH);
   DrawMeasureVerticalLinePixels(chartH);
   ObjectSetInteger(0, m_nameMeasureVertical, OBJPROP_YSIZE, chartH);
   //--- Resize the measure horizontal line canvas and repaint its pixels
   m_canvasMeasureHorizontal.Resize(chartW, 1);
   DrawMeasureHorizontalLinePixels(chartW);
   ObjectSetInteger(0, m_nameMeasureHorizontal, OBJPROP_XSIZE, chartW);
   //--- Resize the measure diagonal canvas, wipe it, and sync the chart object dimensions
   m_canvasMeasureDiagonalLine.Resize(chartW, chartH);
   m_canvasMeasureDiagonalLine.Erase(0x00000000);
   m_canvasMeasureDiagonalLine.Update();
   ObjectSetInteger(0, m_nameMeasureDiagonalLine, OBJPROP_XSIZE, chartW);
   ObjectSetInteger(0, m_nameMeasureDiagonalLine, OBJPROP_YSIZE, chartH);
   //--- Update measure anchor screen positions if measuring is currently active
   if(m_isMeasuringActive)
     {
      //--- Remap the anchor time/price back to canvas pixels in the resized chart
      int fx = 0, fy = 0;
      if(ChartTimePriceToXY(m_chartId, 0, m_measureAnchorTime, m_measureAnchorPrice, fx, fy))
        {
         //--- Cache the new anchor pixel position and refresh the dependent visuals
         m_measureAnchorPixelX = fx;
         m_measureAnchorPixelY = fy;
         UpdateMeasureVerticalPosition(fx);
         UpdateMeasureHorizontalPosition(fy);
         UpdateMeasureAnchorLabels();
        }
     }
  }

#endif // TOOLS_PALETTE_CROSSHAIR_MQH
//+------------------------------------------------------------------+