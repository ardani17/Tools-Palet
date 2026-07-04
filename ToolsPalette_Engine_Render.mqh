//+------------------------------------------------------------------+
//|                                   ToolsPalette_Engine_Render.mqh |
//|                           Copyright 2026, Allan Munene Mutiiria. |
//|                                   https://t.me/Forex_Algo_Trader |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Allan Munene Mutiiria."
#property link "https://t.me/Forex_Algo_Trader"
#property version "1.00"
#property strict

//--- Guard against multiple inclusion of this header
#ifndef TOOLS_PALETTE_ENGINE_RENDER_MQH
#define TOOLS_PALETTE_ENGINE_RENDER_MQH

//--- Pull in CDrawingEngine class declaration (Tools.mqh include guard handles double-load)
#include "ToolsPalette_Tools.mqh"

//+------------------------------------------------------------------+
//| CDrawingEngine method bodies for the canvas render subsystem     |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Render permanent axis-label pills for HLine, VLine, and Cross    |
//+------------------------------------------------------------------+
void CDrawingEngine::RedrawPermanentAxisLabels()
  {
   //--- Pill pixels go directly onto m_canvasDrawings (single atomic Update, no flicker)
   int cW = m_canvasDrawings.Width();
   int cH = m_canvasDrawings.Height();
   //--- Symbol precision used for the price-pill text
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   //--- Walk every drawn object and render its permanent axis label(s)
   int n = ArraySize(m_drawnObjects);
   for(int i = 0; i < n; i++)
     {
      //--- Skip hidden objects
      if(!m_drawnObjects[i].visible) continue;
      //--- Only HLine, VLine, and Cross Line tools host a permanent axis label
      TOOL_TYPE tt = m_drawnObjects[i].toolType;
      if(tt != TOOL_HLINE && tt != TOOL_VLINE && tt != TOOL_CROSS_LINE) continue;
      //--- Cross Line renders TWO pills (price + time); HLine/VLine render ONE
      int passCount = (tt == TOOL_CROSS_LINE) ? 2 : 1;
      for(int pass = 0; pass < passCount; pass++)
        {
         //--- Resolve the effective tool type for this pill pass
         TOOL_TYPE effTT = tt;
         if(tt == TOOL_CROSS_LINE) effTT = (pass == 0) ? TOOL_HLINE : TOOL_VLINE;
         //--- Build the label text - price for HLine, time for VLine
         string labelText = (effTT == TOOL_HLINE)
            ? DoubleToString(m_drawnObjects[i].price1, digits)
            : TimeToString(m_drawnObjects[i].time1, TIME_DATE|TIME_MINUTES);
         if(StringLen(labelText) == 0) continue;
         //--- Map the line's stored anchor to canvas pixel coordinates
         int hx = 0, hy = 0;
         ChartTimePriceToXY(m_chartId, 0,
                            m_drawnObjects[i].time1,
                            m_drawnObjects[i].price1,
                            hx, hy);
         //--- Pill background uses the user's chosen line color; text color picked by luminance
         bool isActive = (m_drawnObjects[i].id == m_selectedObjectId ||
                          m_drawnObjects[i].id == m_hoveredObjectId);
         color pillBgColor = m_drawnObjects[i].objColor;
         //--- Extract RGB channels for the luminance calculation
         uchar lR = (uchar)((pillBgColor)       & 0xFF);
         uchar lG = (uchar)((pillBgColor >> 8)  & 0xFF);
         uchar lB = (uchar)((pillBgColor >> 16) & 0xFF);
         //--- ITU-R BT.601 luminance formula; dark backgrounds get white text
         double luminance = 0.299 * lR + 0.587 * lG + 0.114 * lB;
         bool   bgIsDark  = (luminance < 128.0);
         color  textColor = bgIsDark ? clrWhite : clrBlack;
         //--- Compose fully opaque ARGB values for the pill fill and the text
         uint   pillBgARGB   = ColorToARGB(pillBgColor, 255);
         uint   pillTextARGB = ColorToARGB(textColor,   255);
         //--- Measure the label text at the pill font (9pt Arial)
         TextSetFont("Arial", -(9 * 10));
         uint twU = 0, thU = 0;
         TextGetSize(labelText, twU, thU);
         int tw = (int)twU, th = (int)thU;
         //--- Compute pill dimensions with padding and minimum width/height enforced
         int padX = 4, padY = 2;
         int lw = tw + padX * 2;
         int lh = th + padY * 2;
         if(lw < 20) lw = 20;
         if(lh < 12) lh = 12;
         //--- Compute pill top-left on canvas based on the effective tool type
         int lx, ly;
         if(effTT == TOOL_HLINE)
           {
            //--- HLine pill pinned to the right edge, vertically centered on the line's Y
            lx = cW - lw;
            if(lx < 0) lx = 0;
            ly = hy - lh / 2;
            if(ly < 0) ly = 0;
            if(ly + lh > cH) ly = cH - lh;
           }
         else
           {
            //--- VLine pill pinned to the bottom edge, horizontally centered on the line's X
            lx = hx - lw / 2;
            if(lx < 0) lx = 0;
            if(lx + lw > cW) lx = cW - lw;
            ly = cH - lh;
            if(ly < 0) ly = 0;
           }
         //--- Render text into an offscreen buffer with the pill color as background
         uint buf[]; ArrayResize(buf, lw * lh);
         ArrayFill(buf, 0, lw * lh, pillBgARGB);
         TextOut(labelText, padX, padY, TA_LEFT | TA_TOP, buf, lw, lh,
                 pillTextARGB, COLOR_FORMAT_ARGB_NORMALIZE);
         //--- Blit the buffer onto the drawings canvas at the pill origin
         for(int py = 0; py < lh; py++)
           {
            int dy = ly + py;
            if(dy < 0 || dy >= cH) continue;
            for(int px = 0; px < lw; px++)
              {
               int dx = lx + px;
               if(dx < 0 || dx >= cW) continue;
               m_canvasDrawings.PixelSet(dx, dy, buf[py * lw + px]);
              }
           }
         //--- Paint the top and bottom 1px borders of the pill in the text color
         for(int px = 0; px < lw; px++)
           {
            int dx = lx + px;
            if(dx < 0 || dx >= cW) continue;
            if(ly            >= 0 && ly           < cH) m_canvasDrawings.PixelSet(dx, ly,           pillTextARGB);
            if(ly + lh - 1   >= 0 && ly + lh - 1  < cH) m_canvasDrawings.PixelSet(dx, ly + lh - 1,  pillTextARGB);
           }
         //--- Paint the left and right 1px borders of the pill in the text color
         for(int py = 0; py < lh; py++)
           {
            int dy = ly + py;
            if(dy < 0 || dy >= cH) continue;
            if(lx            >= 0 && lx           < cW) m_canvasDrawings.PixelSet(lx,           dy, pillTextARGB);
            if(lx + lw - 1   >= 0 && lx + lw - 1  < cW) m_canvasDrawings.PixelSet(lx + lw - 1,  dy, pillTextARGB);
           }
        }
     }
  }

//+------------------------------------------------------------------+
//| Delete the legacy permanent axis-label bitmap for an object ID   |
//+------------------------------------------------------------------+
void CDrawingEngine::DeletePermanentAxisLabelsFor(int objId)
  {
   //--- Legacy cleanup: pills now paint onto the canvas, but still remove any stale per-object bitmap
   string lblName = StringFormat("tp_axislbl_%d", objId);
   if(ObjectFind(0, lblName) >= 0) ObjectDelete(0, lblName);
  }

//+------------------------------------------------------------------+
//| Draw a rectangle by delegating to CShapeTools::DrawRectangleOn   |
//+------------------------------------------------------------------+
void CDrawingEngine::DrawRectangle(int x1, int y1, int x2, int y2, color objColor, bool selected, bool hovered)
  {
   //--- Thin engine-level wrapper around CShapeTools::DrawRectangleOn
   DrawRectangleOn(m_canvasDrawings, x1, y1, x2, y2, objColor, selected, hovered);
  }

//+------------------------------------------------------------------+
//| Draw a triangle by delegating to CShapeTools::DrawTriangleOn     |
//+------------------------------------------------------------------+
void CDrawingEngine::DrawTriangle(int x1, int y1, int x2, int y2, int x3, int y3, color objColor, bool selected, bool hovered)
  {
   //--- Thin engine-level wrapper around CShapeTools::DrawTriangleOn
   DrawTriangleOn(m_canvasDrawings, x1, y1, x2, y2, x3, y3, objColor, selected, hovered);
  }

//+------------------------------------------------------------------+
//| Draw an ellipse by delegating to CShapeTools::DrawEllipseOn      |
//+------------------------------------------------------------------+
void CDrawingEngine::DrawEllipse(int x1, int y1, int x2, int y2, int x3, int y3, color objColor, bool selected, bool hovered)
  {
   //--- Thin engine-level wrapper around CShapeTools::DrawEllipseOn
   DrawEllipseOn(m_canvasDrawings, x1, y1, x2, y2, x3, y3, objColor, selected, hovered);
  }

//+------------------------------------------------------------------+
//| Render the text label attached to an object onto the canvas      |
//+------------------------------------------------------------------+
void CDrawingEngine::DrawObjectLabel(int mx, int my, int x1, int y1, int x2, int y2,
                                      const string labelText, bool selected, bool hovered,
                                      color objColor, int anchorMode, bool recordHitRect,
                                      int wrapWidth,
                                      int hostClipL, int hostClipT,
                                      int hostClipR, int hostClipB,
                                      int shapeKind,
                                      double shapeRadiusA,
                                      double shapeRadiusB,
                                      int maxVisibleLines,
                                      int shapeCenterX,
                                      int shapeCenterY,
                                      int availableHeight,
                                      int textOpacity,
                                      int fontSize,
                                      bool bold,
                                      int vAlign,
                                      int hAlign)
  {
   //--- Clamp the text opacity into the valid [0, 100] percentage range
   if(textOpacity < 0)   textOpacity = 0;
   if(textOpacity > 100) textOpacity = 100;
   //--- Identify whether this object is the currently active edit target
   bool isBeingEdited = (m_isEditingLabel && selected);
   bool hasText       = (StringLen(labelText) > 0);
   //--- Bail out when there is nothing to render
   if(!hasText && !isBeingEdited) return;
   //--- Pick the text source - the live edit buffer when editing, otherwise the committed label
   string sourceText = isBeingEdited ? m_labelEditBuffer : labelText;
   bool   sourceEmpty = (StringLen(sourceText) == 0);
   //--- Use an "Add text" placeholder when the edit buffer is currently empty
   string renderText;
   bool   placeholderMode = (isBeingEdited && sourceEmpty);
   if(placeholderMode)
      renderText = "Add text";
   else
      renderText = sourceText;
   //--- Nothing left to render after placeholder selection
   if(StringLen(renderText) == 0) return;
   //--- Compute the line rotation angle (math convention, screen-Y flipped)
   double dxL = (double)(x2 - x1), dyL = (double)(y2 - y1);
   double angleDeg = 0.0;
   if(dxL != 0.0 || dyL != 0.0)
      angleDeg = MathArctan2(-dyL, dxL) * 180.0 / M_PI;
   //--- Keep text right-side-up by normalizing the angle into [-90, +90]
   if(angleDeg > 90.0)  angleDeg -= 180.0;
   if(angleDeg < -90.0) angleDeg += 180.0;
   //--- Pre-compute trig terms for the rotation transform
   double rad = angleDeg * M_PI / 180.0;
   double ca  = MathCos(rad), sa = MathSin(rad);
   double ssa = -sa;
   //--- Normal direction (away from line, "above" in math-up sense)
   double normSX = -sa, normSY = -ca;
   //--- Extract source RGB channels for the label color
   color lblColor = objColor;
   uchar lblR = (uchar)((lblColor)       & 0xFF);
   uchar lblG = (uchar)((lblColor >> 8)  & 0xFF);
   uchar lblB = (uchar)((lblColor >> 16) & 0xFF);
   //--- Extract source RGB channels for the caret color (chart foreground)
   color curColor = (color)ChartGetInteger(0, CHART_COLOR_FOREGROUND);
   uchar curR = (uchar)((curColor)       & 0xFF);
   uchar curG = (uchar)((curColor >> 8)  & 0xFF);
   uchar curB = (uchar)((curColor >> 16) & 0xFF);
   //--- Resolve and clamp the effective font size into a sane range
   string fontName = "Arial";
   int    effFontSize = (fontSize > 0) ? fontSize : 11;
   if(effFontSize < 6)  effFontSize = 6;
   if(effFontSize > 96) effFontSize = 96;
   //--- Super-sampling factor for AA glyph rendering
   const int SS = 4;
   int    hrFontSize = effFontSize * SS;
   //--- Font weight flags (FW_BOLD = 700 in MQL5; matches Win32 LOGFONT lfWeight)
   const int FW_NORMAL_LCL = 400;
   const int FW_BOLD_LCL   = 700;
   int fontFlags = bold ? FW_BOLD_LCL : FW_NORMAL_LCL;
   //--- Apply font at the supersampled size for high-res glyph generation
   TextSetFont(fontName, -(hrFontSize * 10), fontFlags);
   //--- Compute the wrapped visual layout for the source text
   string lines[];
   int    bufOffsets[];
   int    measMaxW = 0, measBlockH = 0, measLineH = 0;
   ComputeWrappedLayout(renderText, fontName, fontSize, wrapWidth,
                         lines, bufOffsets, measMaxW, measBlockH, measLineH);
   int nLinesTotal = ArraySize(lines);
   if(nLinesTotal == 0) return;
   //--- Re-apply font flags after ComputeWrappedLayout (which clobbers them)
   TextSetFont(fontName, -(hrFontSize * 10), fontFlags);
   //--- Reference HR line height measured against the canonical "Mg" pair
   uint hrRefWu = 0, hrRefHu = 0;
   TextGetSize("Mg", hrRefWu, hrRefHu);
   int hrLineH = (int)hrRefHu;
   if(hrLineH < 1) hrLineH = 1;
   //--- Down-sampled line height in target canvas units
   int lineH = hrLineH / SS;
   if(lineH < 1) lineH = 1;
   //--- Decide the effective anchor mode (AUTO_FIT collapses to CENTERED or TOP based on fit)
   int nLines           = nLinesTotal;
   int effectiveAnchor  = anchorMode;
   if(anchorMode == LBL_ANCHOR_AUTO_FIT)
     {
      //--- Auto-fit decision: full block height vs the host's available interior height
      int totalBlockH = nLinesTotal * lineH;
      if(availableHeight > 0 && totalBlockH > availableHeight)
        {
         //--- Block overflows: switch to TOP anchor and clamp the visible line count
         effectiveAnchor = LBL_ANCHOR_TOP;
         nLines = availableHeight / lineH;
         if(nLines < 1) nLines = 1;
        }
      else
        {
         //--- Block fits: render all lines centered on the host
         effectiveAnchor = LBL_ANCHOR_CENTERED;
        }
     }
   else
     {
      //--- Non-AUTO modes: apply existing per-mode clamping logic
      if(maxVisibleLines > 0 && nLines > maxVisibleLines)
         nLines = maxVisibleLines;
      //--- LBL_ANCHOR_TOP clamps to the host's bottom clip; ellipse handled below
      if(anchorMode == LBL_ANCHOR_TOP && hostClipB != -1 &&
         shapeKind != LBL_SHAPE_ELLIPSE)
        {
         int availV = hostClipB - my;
         if(availV < 0) availV = 0;
         int derivedMax = availV / lineH;
         if(derivedMax < 1) derivedMax = 1;
         if(derivedMax < nLines) nLines = derivedMax;
        }
      //--- Ellipse host: derive the interior cap from the minor-axis radius
      if(shapeKind == LBL_SHAPE_ELLIPSE && shapeRadiusB > 0.0)
        {
         double interiorH_e = 1.40 * shapeRadiusB;
         int derivedMaxEll = (int)(interiorH_e / (double)lineH);
         if(derivedMaxEll < 1) derivedMaxEll = 1;
         if(derivedMaxEll < nLines) nLines = derivedMaxEll;
        }
     }
   //--- Guarantee at least one rendered line
   if(nLines < 1) nLines = 1;
   //--- Measure each rendered line's HR pixel width and track the maximum
   int hrLineW[]; ArrayResize(hrLineW, nLines);
   int hrMaxW = 0;
   for(int li = 0; li < nLines; li++)
     {
      //--- Skip empty lines; they consume vertical space but no width
      if(StringLen(lines[li]) == 0) { hrLineW[li] = 0; continue; }
      uint lwU = 0, lhU = 0;
      TextGetSize(lines[li], lwU, lhU);
      hrLineW[li] = (int)lwU;
      if(hrLineW[li] > hrMaxW) hrMaxW = hrLineW[li];
     }
   //--- Reserve a small horizontal slack for the end-of-line caret bar
   int cursorReserveHR = 2 * SS;
   //--- HR (super-sampled) and down-sampled block dimensions
   int hrTw = hrMaxW + cursorReserveHR;
   int hrTh = hrLineH * nLines;
   int tw = hrTw / SS;
   int th = hrTh / SS;
   //--- Reject degenerate zero-size blocks
   if(tw <= 0 || th <= 0) return;
   double halfW = tw / 2.0, halfH = th / 2.0;
   //--- Derive caret visual line/column from the bufOffsets table
   int caretLine = 0, caretCol = 0;
   int caretTrueLine = 0, caretTrueCol = 0;
   bool drawCaret = isBeingEdited;
   //--- Blink the caret on/off at 1Hz using the system microsecond counter
   bool cursorOn  = ((GetMicrosecondCount() / 500000) % 2) == 0;
   if(drawCaret && !placeholderMode)
     {
      //--- Clamp caret buffer index defensively into [0, len]
      int target = m_labelCaretPos;
      int len    = StringLen(m_labelEditBuffer);
      if(target < 0)   target = 0;
      if(target > len) target = len;
      //--- Walk the offsets table to find the visual line that contains the caret
      caretTrueLine = 0;
      int nVisAll = ArraySize(lines);
      for(int vl = 0; vl < nVisAll; vl++)
        {
         if(bufOffsets[vl] <= target) caretTrueLine = vl;
         else break;
        }
      //--- Column within the visual line (clamped to line length)
      caretTrueCol = target - bufOffsets[caretTrueLine];
      int vlLenT = StringLen(lines[caretTrueLine]);
      if(caretTrueCol < 0)     caretTrueCol = 0;
      if(caretTrueCol > vlLenT) caretTrueCol = vlLenT;
      //--- Visible caret line falls within nLines; otherwise mark caret as off-screen
      if(caretTrueLine < nLines)
        {
         caretLine = caretTrueLine;
         caretCol  = caretTrueCol;
        }
      else
        {
         caretLine = -1;
         caretCol  = 0;
        }
     }
   //--- Measure the HR pixel X of the caret within its line (sum of prefix width)
   int caretHRX = 0;
   if(drawCaret)
     {
      //--- Build the prefix substring up to the caret column on this line
      string prefix = "";
      if(!placeholderMode && caretLine >= 0 && caretLine < nLines)
         prefix = StringSubstr(lines[caretLine], 0, caretCol);
      if(StringLen(prefix) > 0)
        {
         uint pwU = 0, phU = 0;
         TextGetSize(prefix, pwU, phU);
         caretHRX = (int)pwU;
        }
     }
   //--- Paragraph alignment applies for ABOVE_LINE and CENTERED modes
   const bool applyParaAlign = (effectiveAnchor == LBL_ANCHOR_ABOVE_LINE
                                || effectiveAnchor == LBL_ANCHOR_CENTERED);
   const int  blockHRW       = hrTw - cursorReserveHR;
   //--- Allocate the HR alpha buffer that aggregates all line ink coverage
   uchar hrAlpha[]; ArrayResize(hrAlpha, hrTw * hrTh);
   ArrayFill(hrAlpha, 0, hrTw * hrTh, 0);
   //--- Per-line horizontal offset (for left/center/right paragraph alignment)
   int linexOff[]; ArrayResize(linexOff, nLines);
   for(int li = 0; li < nLines; li++) linexOff[li] = 0;
   //--- Render each line's glyphs and stamp them into the HR alpha buffer
   for(int li = 0; li < nLines; li++)
     {
      //--- Skip empty lines; they advance Y but produce no pixels
      if(StringLen(lines[li]) == 0) continue;
      int lineHRW = hrLineW[li];
      if(lineHRW <= 0) continue;
      //--- Compute the horizontal offset within the block for this line
      int xOff = 0;
      if(applyParaAlign)
        {
         if(hAlign == 1)        xOff = (blockHRW - lineHRW) / 2;
         else if(hAlign == 2)   xOff =  blockHRW - lineHRW;
         if(xOff < 0) xOff = 0;
        }
      linexOff[li] = xOff;
      //--- Two-pass black/white text render for AA ink extraction
      uint bufB[]; ArrayResize(bufB, lineHRW * hrLineH);
      uint bufW[]; ArrayResize(bufW, lineHRW * hrLineH);
      ArrayFill(bufB, 0, lineHRW * hrLineH, 0xFF000000);
      ArrayFill(bufW, 0, lineHRW * hrLineH, 0xFFFFFFFF);
      //--- First pass on black background
      TextOut(lines[li], 0, 0, TA_LEFT | TA_TOP, bufB, lineHRW, hrLineH,
              ColorToARGB(clrBlack, 255), COLOR_FORMAT_ARGB_NORMALIZE);
      //--- Second pass on white background
      TextOut(lines[li], 0, 0, TA_LEFT | TA_TOP, bufW, lineHRW, hrLineH,
              ColorToARGB(clrBlack, 255), COLOR_FORMAT_ARGB_NORMALIZE);
      //--- Compute the per-pixel alpha as the diff between white-bg and black-bg renders
      int yOffset = li * hrLineH;
      for(int yi = 0; yi < hrLineH; yi++)
        {
         for(int xi = 0; xi < lineHRW; xi++)
           {
            //--- Skip pixels outside the HR block bounds
            const int dstX = xOff + xi;
            if(dstX < 0 || dstX >= hrTw) continue;
            //--- Derive per-pixel alpha from the white-vs-black render difference
            int p = yi * lineHRW + xi;
            int dR = (int)((bufW[p] >> 16) & 0xFF) - (int)((bufB[p] >> 16) & 0xFF);
            int dG = (int)((bufW[p] >>  8) & 0xFF) - (int)((bufB[p] >>  8) & 0xFF);
            int dB = (int)( bufW[p]        & 0xFF) - (int)( bufB[p]        & 0xFF);
            int a  = 255 - (dR + dG + dB) / 3;
            if(a < 0) a = 0; else if(a > 255) a = 255;
            //--- Write the per-pixel alpha into the HR aggregate buffer
            hrAlpha[(yOffset + yi) * hrTw + dstX] = (uchar)a;
           }
        }
     }
   //--- Stamp caret pixels into a parallel HR cursor buffer (separate from text alpha)
   uchar hrCursor[]; ArrayResize(hrCursor, hrTw * hrTh);
   ArrayFill(hrCursor, 0, hrTw * hrTh, 0);
   if(drawCaret && cursorOn && caretLine >= 0)
     {
      //--- Caret bar height: line height minus 2px padding at top and bottom (in HR space)
      int cyTop    = caretLine * hrLineH + 2 * SS;
      int cyBottom = (caretLine + 1) * hrLineH - 2 * SS;
      if(cyBottom <= cyTop) cyBottom = cyTop;
      int barWidth = SS;
      //--- Apply this line's paragraph-alignment X offset to the caret X position
      const int caretLineXOff = (caretLine >= 0 && caretLine < ArraySize(linexOff))
                                 ? linexOff[caretLine] : 0;
      int xLo = caretHRX + caretLineXOff;
      int xHi = xLo + barWidth - 1;
      //--- Clamp caret bar X range into the HR buffer bounds
      if(xLo < 0) xLo = 0;
      if(xHi >= hrTw) xHi = hrTw - 1;
      //--- Fill the caret bar pixels at full alpha
      for(int yy = cyTop; yy <= cyBottom; yy++)
        {
         if(yy < 0 || yy >= hrTh) continue;
         for(int xx = xLo; xx <= xHi; xx++)
            hrCursor[yy * hrTw + xx] = 255;
        }
     }
   //--- Compute the block midpoint based on the effective anchor mode
   double midTX_d = (double)mx;
   double midTY_d = (double)my;
   if(effectiveAnchor == LBL_ANCHOR_ABOVE_LINE)
     {
      //--- Above-line: perpendicular offset depends on vAlign; horizontal shift on hAlign
      const int    perpOffset = 11;
      const double halfLineH  = (double)lineH * 0.5;
      double anchorDist;
      if(vAlign == 0)      anchorDist =  (double)perpOffset + halfH - halfLineH;
      else if(vAlign == 1) anchorDist = 0.0;
      else                 anchorDist = -((double)perpOffset + halfH - halfLineH);
      //--- Horizontal shift limit so the label stays inside the line's body
      double halfLineLen = MathSqrt((double)dxL * dxL + (double)dyL * dyL) * 0.5;
      double hShiftMax = halfLineLen - halfW - 4.0;
      if(hShiftMax < 0.0) hShiftMax = 0.0;
      double hShift = 0.0;
      if(hAlign == 0)      hShift = -hShiftMax;
      else if(hAlign == 2) hShift =  hShiftMax;
      //--- Project the shift along the line direction and the perpendicular offset
      midTX_d = (double)mx + ca * hShift + normSX * anchorDist;
      midTY_d = (double)my + ssa * hShift + normSY * anchorDist;
     }
   else if(effectiveAnchor == LBL_ANCHOR_TOP)
     {
      //--- Top-anchored: block top pins to the host top, content stacks down
      double downSX =  sa;
      double downSY =  ca;
      double topAnchorX = (double)mx;
      double topAnchorY = (double)my;
      //--- AUTO_FIT overflow path: shift up by half-availableHeight to align top to host top
      if(anchorMode == LBL_ANCHOR_AUTO_FIT && availableHeight > 0)
        {
         double halfAvail = (double)availableHeight / 2.0;
         topAnchorX = (double)mx - downSX * halfAvail;
         topAnchorY = (double)my - downSY * halfAvail;
        }
      //--- Block center sits half-block down from the top anchor
      midTX_d = topAnchorX + downSX * halfH;
      midTY_d = topAnchorY + downSY * halfH;
     }
   else if(effectiveAnchor == LBL_ANCHOR_CENTERED)
     {
      //--- Centered: same shift logic as ABOVE_LINE but anchor stays at center
      const int    perpOffset = 11;
      const double halfLineH  = (double)lineH * 0.5;
      double anchorDist;
      if(vAlign == 0)      anchorDist =  (double)perpOffset + halfH - halfLineH;
      else if(vAlign == 1) anchorDist = 0.0;
      else                 anchorDist = -((double)perpOffset + halfH - halfLineH);
      double halfLineLen = MathSqrt((double)dxL * dxL + (double)dyL * dyL) * 0.5;
      double hShiftMax = halfLineLen - halfW - 4.0;
      if(hShiftMax < 0.0) hShiftMax = 0.0;
      double hShift = 0.0;
      if(hAlign == 0)      hShift = -hShiftMax;
      else if(hAlign == 2) hShift =  hShiftMax;
      midTX_d = (double)mx + ca * hShift + normSX * anchorDist;
      midTY_d = (double)my + ssa * hShift + normSY * anchorDist;
     }
   int midTargetX = (int)MathRound(midTX_d);
   int midTargetY = (int)MathRound(midTY_d);
   //--- Compute the 4 rotated corners of the text block in canvas coordinates
   int cx1 = (int)MathRound(midTargetX + (-halfW)*ca - (-halfH)*ssa);
   int cy1 = (int)MathRound(midTargetY + (-halfW)*ssa + (-halfH)*ca);
   int cx2 = (int)MathRound(midTargetX + ( halfW)*ca - (-halfH)*ssa);
   int cy2 = (int)MathRound(midTargetY + ( halfW)*ssa + (-halfH)*ca);
   int cx3 = (int)MathRound(midTargetX + ( halfW)*ca - ( halfH)*ssa);
   int cy3 = (int)MathRound(midTargetY + ( halfW)*ssa + ( halfH)*ca);
   int cx4 = (int)MathRound(midTargetX + (-halfW)*ca - ( halfH)*ssa);
   int cy4 = (int)MathRound(midTargetY + (-halfW)*ssa + ( halfH)*ca);
   //--- Axis-aligned bounding box (with 2px slack) for the per-pixel clip range
   int bbMinX = MathMin(MathMin(cx1,cx2), MathMin(cx3,cx4)) - 2;
   int bbMaxX = MathMax(MathMax(cx1,cx2), MathMax(cx3,cx4)) + 2;
   int bbMinY = MathMin(MathMin(cy1,cy2), MathMin(cy3,cy4)) - 2;
   int bbMaxY = MathMax(MathMax(cy1,cy2), MathMax(cy3,cy4)) + 2;
   //--- Cache canvas dimensions and clamp the iteration range to canvas bounds
   int cW = m_canvasDrawings.Width();
   int cH = m_canvasDrawings.Height();
   int clipMinX = MathMax(0, bbMinX);
   int clipMinY = MathMax(0, bbMinY);
   int clipMaxX = MathMin(cW - 1, bbMaxX);
   int clipMaxY = MathMin(cH - 1, bbMaxY);
   //--- Supersampling step constants for the inverse-mapped AA composite pass
   double subStep  = 1.0 / SS;
   double subStart = -0.5 + subStep * 0.5;
   int    subCount = SS * SS;
   //--- Walk every canvas pixel in the AABB clip range
   for(int py = clipMinY; py <= clipMaxY; py++)
     {
      for(int px = clipMinX; px <= clipMaxX; px++)
        {
         //--- Apply the optional host AABB clip (rectangle tool, etc.)
         bool clipActive = (hostClipL != -1 || hostClipT != -1 ||
                            hostClipR != -1 || hostClipB != -1);
         if(clipActive)
           {
            if(px < hostClipL || px > hostClipR ||
               py < hostClipT || py > hostClipB) continue;
           }
         //--- Apply the optional shape-equation clip (circle / ellipse interior)
         if(shapeKind != LBL_SHAPE_NONE)
           {
            //--- Transform pixel into the shape's local frame for the equation test
            double scx = (double)px - (double)shapeCenterX;
            double scy = (double)py - (double)shapeCenterY;
            double localShapeX =  scx * ca + scy * ssa;
            double localShapeY = -scx * ssa + scy * ca;
            //--- Circle: reject pixels outside the radius
            if(shapeKind == LBL_SHAPE_CIRCLE)
              {
               double rA = shapeRadiusA;
               if(rA <= 0.0) rA = 1.0;
               double r2 = rA * rA;
               if(localShapeX * localShapeX + localShapeY * localShapeY > r2)
                  continue;
              }
            //--- Ellipse: reject pixels outside the (x/a)^2 + (y/b)^2 = 1 boundary
            else if(shapeKind == LBL_SHAPE_ELLIPSE)
              {
               double a = shapeRadiusA;
               double b = shapeRadiusB;
               if(a <= 0.0) a = 1.0;
               if(b <= 0.0) b = 1.0;
               double tx = localShapeX / a;
               double ty = localShapeY / b;
               if(tx * tx + ty * ty > 1.0)
                  continue;
              }
           }
         //--- Accumulate label and cursor alpha samples over the SS x SS subpixel grid
         int alphaLabel  = 0;
         int alphaCursor = 0;
         for(int sy = 0; sy < SS; sy++)
           {
            for(int sx = 0; sx < SS; sx++)
              {
               //--- Subpixel canvas-space position
               double subX = (double)px + subStart + subStep * sx;
               double subY = (double)py + subStart + subStep * sy;
               //--- Translate into block-relative coordinates
               double rx = subX - midTargetX;
               double ry = subY - midTargetY;
               //--- Inverse rotate into the block's source frame
               double srcCX =  rx * ca + ry * ssa;
               double srcCY = -rx * ssa + ry * ca;
               //--- Map source coords to HR buffer coords (offset by half-extent)
               double srcXHR = (srcCX + halfW) * SS;
               double srcYHR = (srcCY + halfH) * SS;
               //--- Reject samples outside the HR buffer bounds
               if(srcXHR < 0.0 || srcXHR >= (double)hrTw) continue;
               if(srcYHR < 0.0 || srcYHR >= (double)hrTh) continue;
               //--- Sample the HR buffers at the nearest integer position
               int ix = (int)srcXHR;
               int iy = (int)srcYHR;
               if(ix < 0 || ix >= hrTw || iy < 0 || iy >= hrTh) continue;
               int p = iy * hrTw + ix;
               alphaLabel  += (int)hrAlpha[p];
               alphaCursor += (int)hrCursor[p];
              }
           }
         //--- Average the SS x SS samples to get the final per-pixel alpha
         int aLbl = alphaLabel  / subCount;
         int aCur = alphaCursor / subCount;
         //--- Skip fully transparent pixels
         if(aLbl <= 0 && aCur <= 0) continue;
         //--- Clamp final alphas into the valid byte range
         if(aLbl > 255) aLbl = 255;
         if(aCur > 255) aCur = 255;
         //--- Apply the text opacity percentage and dim placeholder text further
         aLbl = (aLbl * textOpacity) / 100;
         if(placeholderMode) aLbl = (aLbl * 128) / 255;
         //--- Read the existing canvas pixel as the destination color
         uint existing = m_canvasDrawings.PixelGet(px, py);
         double dA = ((existing >> 24) & 0xFF) / 255.0;
         double dR = ((existing >> 16) & 0xFF) / 255.0;
         double dG = ((existing >>  8) & 0xFF) / 255.0;
         double dB = ( existing        & 0xFF) / 255.0;
         //--- Composite the label color over the destination using Porter-Duff source-over
         if(aLbl > 0) {
            double sA = aLbl / 255.0;
            double outA = sA + dA * (1.0 - sA);
            if(outA > 0.0) {
               double sR = lblR / 255.0, sG = lblG / 255.0, sB = lblB / 255.0;
               double nR = (sR*sA + dR*dA*(1.0-sA)) / outA;
               double nG = (sG*sA + dG*dA*(1.0-sA)) / outA;
               double nB = (sB*sA + dB*dA*(1.0-sA)) / outA;
               dA = outA; dR = nR; dG = nG; dB = nB;
            }
         }
         //--- Composite the caret color over the in-progress pixel (caret renders ABOVE text)
         if(aCur > 0) {
            double sA = aCur / 255.0;
            double outA = sA + dA * (1.0 - sA);
            if(outA > 0.0) {
               double sR = curR / 255.0, sG = curG / 255.0, sB = curB / 255.0;
               double nR = (sR*sA + dR*dA*(1.0-sA)) / outA;
               double nG = (sG*sA + dG*dA*(1.0-sA)) / outA;
               double nB = (sB*sA + dB*dA*(1.0-sA)) / outA;
               dA = outA; dR = nR; dG = nG; dB = nB;
            }
         }
         //--- Assemble the final ARGB pixel and write it back to the canvas
         uint blended = ((uint)(uchar)(dA * 255.0 + 0.5) << 24) |
                       ((uint)(uchar)(dR * 255.0 + 0.5) << 16) |
                       ((uint)(uchar)(dG * 255.0 + 0.5) <<  8) |
                        (uint)(uchar)(dB * 255.0 + 0.5);
         m_canvasDrawings.PixelSet(px, py, blended);
        }
     }
   //--- Second-pass caret render: tracks the TRUE buffer position even when off-screen
   if(drawCaret && cursorOn && caretLine < 0)
     {
      //--- Measure the HR prefix width for the true caret position on the true line
      int prefixWHR = 0;
      if(caretTrueLine >= 0 && caretTrueLine < ArraySize(lines) &&
         caretTrueCol > 0)
        {
         string trPrefix = StringSubstr(lines[caretTrueLine], 0, caretTrueCol);
         if(StringLen(trPrefix) > 0)
           {
            uint twU = 0, thU = 0;
            TextGetSize(trPrefix, twU, thU);
            prefixWHR = (int)twU;
           }
        }
      //--- Down-sample HR prefix width into canvas pixels
      double prefixW = (double)prefixWHR / (double)SS;
      //--- Apply paragraph-alignment X offset for the true caret line
      double caretLineXOff = 0.0;
      if(applyParaAlign
         && caretTrueLine >= 0
         && caretTrueLine < ArraySize(lines)
         && (hAlign == 1 || hAlign == 2))
        {
         uint clwU = 0, clhU = 0;
         TextGetSize(lines[caretTrueLine], clwU, clhU);
         const int caretLineHRW = (int)clwU;
         int xOffHR = 0;
         if(hAlign == 1)      xOffHR = (blockHRW - caretLineHRW) / 2;
         else if(hAlign == 2) xOffHR =  blockHRW - caretLineHRW;
         if(xOffHR < 0) xOffHR = 0;
         caretLineXOff = (double)xOffHR / (double)SS;
        }
      //--- Compute caret offset within the block (right and down components)
      double rOff = -halfW + prefixW + caretLineXOff;
      double dOff = -halfH + (double)caretTrueLine * (double)lineH + (double)lineH * 0.5;
      //--- Block's local right/down axes in canvas space
      double rAxisX =  ca;
      double rAxisY =  ssa;
      double dAxisX =  sa;
      double dAxisY =  ca;
      //--- Caret center position in canvas coords
      double cxC = midTargetX + rOff * rAxisX + dOff * dAxisX;
      double cyC = midTargetY + rOff * rAxisY + dOff * dAxisY;
      //--- Caret bar half-height (matches the in-block bar bounds minus 2px padding)
      double barHalfH = (double)lineH * 0.5 - 2.0;
      if(barHalfH < 1.0) barHalfH = 1.0;
      //--- Compose the caret bar ARGB at full opacity
      uint cArgb = ((uint)0xFF << 24) |
                    ((uint)curR << 16) | ((uint)curG << 8) | (uint)curB;
      //--- Paint a vertical bar along the local down axis at 0.5px steps
      for(double t = -barHalfH; t <= barHalfH; t += 0.5)
        {
         double pxd = cxC + t * dAxisX;
         double pyd = cyC + t * dAxisY;
         int    px_ = (int)MathRound(pxd);
         int    py_ = (int)MathRound(pyd);
         //--- Skip pixels outside the canvas bounds
         if(px_ < 0 || py_ < 0 ||
            px_ >= m_canvasDrawings.Width() ||
            py_ >= m_canvasDrawings.Height()) continue;
         m_canvasDrawings.PixelSet(px_, py_, cArgb);
        }
     }
   //--- Record the label's rotated hit rect for the SELECTED object's click router
   if(recordHitRect)
     {
      //--- Cache AABB extents for fast pre-filter tests
      m_labelHitX1 = bbMinX; m_labelHitY1 = bbMinY;
      m_labelHitX2 = bbMaxX; m_labelHitY2 = bbMaxY;
      //--- Cache the 4 rotated corners (TL, TR, BR, BL) for precise point-in-quad test
      m_labelHitCornerX[0] = cx1; m_labelHitCornerY[0] = cy1;
      m_labelHitCornerX[1] = cx2; m_labelHitCornerY[1] = cy2;
      m_labelHitCornerX[2] = cx3; m_labelHitCornerY[2] = cy3;
      m_labelHitCornerX[3] = cx4; m_labelHitCornerY[3] = cy4;
     }
  }

//+------------------------------------------------------------------+
//| Redraw every stored object onto the canvas (main render dispatch)|
//+------------------------------------------------------------------+
void CDrawingEngine::RedrawAllObjects()
  {
   //--- Clear the drawings canvas to fully transparent before the new frame
   m_canvasDrawings.Erase(0x00000000);
   //--- Reset per-frame hit state for the prompt and label hit-rects
   m_addTextPromptObjId       = -1;
   m_labelHitObjIdForSelected = -1;
   //--- Walk every drawn object and render it
   int n = ArraySize(m_drawnObjects);
   for(int i = 0; i < n; i++)
     {
      //--- Skip hidden objects
      if(!m_drawnObjects[i].visible) continue;
      //--- Snapshot the object's primary stroke color
      color col     = m_drawnObjects[i].objColor;
      //--- Snapshot the per-object text color (independent of stroke color)
      color colText = m_drawnObjects[i].textColor;
      //--- Derive selection from the canonical engine state (single source of truth)
      bool  sel     = (m_drawnObjects[i].id == m_selectedObjectId);
      bool  hovered = (m_drawnObjects[i].id == m_hoveredObjectId);
      //--- Map the three anchor (time, price) pairs to canvas pixels
      int x1=0,y1=0,x2=0,y2=0,x3=0,y3=0;
      ChartTimePriceToXY(m_chartId,0,m_drawnObjects[i].time1,m_drawnObjects[i].price1,x1,y1);
      if(m_drawnObjects[i].time2!=0)
         ChartTimePriceToXY(m_chartId,0,m_drawnObjects[i].time2,m_drawnObjects[i].price2,x2,y2);
      if(m_drawnObjects[i].time3!=0)
         ChartTimePriceToXY(m_chartId,0,m_drawnObjects[i].time3,m_drawnObjects[i].price3,x3,y3);
      //--- Configure per-object handle hide/halo state for this draw call
      bool isThisSelected = (m_drawnObjects[i].id == m_selectedObjectId);
      //--- Hide the dragged handle so it appears "picked up" by the cursor
      m_hideHandleIdx = (isThisSelected && m_isDraggingHandle) ? m_draggedHandleIdx : -1;
      //--- Halo the hovered handle (no halo during active drag - reduces visual noise)
      bool isThisHandleHost = (m_drawnObjects[i].id == m_hoveredHandleHostId);
      m_haloHandleIdx = (isThisHandleHost && !m_isDraggingHandle && !m_isDraggingObject)
                        ? m_hoveredHandleIdx : -1;
      //--- Dispatch to the appropriate per-tool render routine
      switch(m_drawnObjects[i].toolType)
        {
         //--- Trend line: 2-anchor, straight stroke between P1 and P2
         case TOOL_TRENDLINE:          DrawTrendLineOn(m_canvasDrawings,x1,y1,x2,y2,col,sel,hovered,
                                          m_drawnObjects[i].lineWidth,
                                          m_drawnObjects[i].lineOpacity,
                                          m_drawnObjects[i].lineStyle);                              break;
         //--- Horizontal line: 1-anchor, full-width row at Y1
         case TOOL_HLINE:              DrawHorizontalLineOn(m_canvasDrawings,y1,col,sel,hovered,
                                          m_drawnObjects[i].lineWidth,
                                          m_drawnObjects[i].lineOpacity,
                                          m_drawnObjects[i].lineStyle);                              break;
         //--- Vertical line: 1-anchor, full-height column at X1
         case TOOL_VLINE:              DrawVerticalLineOn(m_canvasDrawings,x1,col,sel,hovered,
                                          m_drawnObjects[i].lineWidth,
                                          m_drawnObjects[i].lineOpacity,
                                          m_drawnObjects[i].lineStyle);                              break;
         //--- Cross line: 1-anchor crosshair through (X1, Y1)
         case TOOL_CROSS_LINE:         DrawCrossLineOn(m_canvasDrawings,x1,y1,col,sel,hovered,
                                          m_drawnObjects[i].lineWidth,
                                          m_drawnObjects[i].lineOpacity,
                                          m_drawnObjects[i].lineStyle);                              break;
         //--- Ray: 2-anchor stroke extending past P2 to the right edge
         case TOOL_RAY:                DrawRayLineOn(m_canvasDrawings,x1,y1,x2,y2,col,sel,hovered,
                                          m_drawnObjects[i].lineWidth,
                                          m_drawnObjects[i].lineOpacity,
                                          m_drawnObjects[i].lineStyle);                              break;
         //--- Extended line: 2-anchor stroke extending past both ends to the canvas edges
         case TOOL_EXTENDED_LINE:      DrawExtendedLineOn(m_canvasDrawings,x1,y1,x2,y2,col,sel,hovered,
                                          m_drawnObjects[i].lineWidth,
                                          m_drawnObjects[i].lineOpacity,
                                          m_drawnObjects[i].lineStyle);                              break;
         //--- Info line: 2-anchor trendline plus a floating info panel showing ΔT / ΔP / slope
         case TOOL_INFO_LINE:          DrawInfoLineOn(m_canvasDrawings,x1,y1,x2,y2,col,
                                          m_drawnObjects[i].time1,m_drawnObjects[i].time2,
                                          m_drawnObjects[i].price1,m_drawnObjects[i].price2,
                                          sel,hovered,m_isDarkTheme,
                                          m_drawnObjects[i].lineWidth,
                                          m_drawnObjects[i].lineOpacity,
                                          m_drawnObjects[i].lineStyle);                              break;
         //--- Trend angle: 2-anchor trendline plus the inscribed angle arcs at P1
         case TOOL_TREND_ANGLE:        DrawTrendAngleOn(m_canvasDrawings,x1,y1,x2,y2,col,sel,hovered,
                                          m_isDarkTheme,
                                          m_drawnObjects[i].lineWidth,
                                          m_drawnObjects[i].lineOpacity,
                                          m_drawnObjects[i].lineStyle);                              break;
         //--- Rectangle: 2-anchor axis-aligned box with translucent fill + 2px border
         case TOOL_RECTANGLE:          DrawRectangleOn(m_canvasDrawings,x1,y1,x2,y2,col,sel,hovered,
                                          m_drawnObjects[i].lineWidth,
                                          m_drawnObjects[i].lineOpacity,
                                          m_drawnObjects[i].lineStyle,
                                          m_drawnObjects[i].fillColor,
                                          m_drawnObjects[i].fillOpacity);                            break;
         //--- Text annotation: horizontal box centered on P1 with editable text inside
         case TOOL_TEXT:
           {
            //--- Edit state and rendered text source for this Text object
            bool isEdit = (m_isEditingLabel && sel);
            string commitText = m_drawnObjects[i].labelText;
            int boxL=0, boxT=0, boxR=0, boxB=0;
            //--- Delegate to CAnnotationTools::DrawTextAnnotationOn for the actual rendering
            DrawTextAnnotationOn(m_canvasDrawings, x1, y1,
                                  commitText, isEdit, m_labelEditBuffer,
                                  m_labelCaretPos,
                                  m_drawnObjects[i].textColor,
                                  sel, hovered,
                                  boxL, boxT, boxR, boxB,
                                  m_drawnObjects[i].fontSize,
                                  m_drawnObjects[i].bold,
                                  m_drawnObjects[i].vAlign,
                                  m_drawnObjects[i].hAlign,
                                  m_drawnObjects[i].textOpacity);
            //--- Record the box bounds as the label hit-rect for click-to-edit routing
            if(sel)
              {
               m_labelHitActive           = true;
               m_labelHitObjIdForSelected = m_drawnObjects[i].id;
               m_labelHitX1 = boxL; m_labelHitY1 = boxT;
               m_labelHitX2 = boxR; m_labelHitY2 = boxB;
               //--- Axis-aligned corners since Text annotations don't rotate
               ArrayResize(m_labelHitCornerX, 4);
               ArrayResize(m_labelHitCornerY, 4);
               m_labelHitCornerX[0] = boxL; m_labelHitCornerY[0] = boxT;
               m_labelHitCornerX[1] = boxR; m_labelHitCornerY[1] = boxT;
               m_labelHitCornerX[2] = boxR; m_labelHitCornerY[2] = boxB;
               m_labelHitCornerX[3] = boxL; m_labelHitCornerY[3] = boxB;
              }
            break;
           }
         //--- Rotated rectangle: 3-anchor convex quad with translucent fill + 2px border
         case TOOL_ROTATED_RECTANGLE:
            DrawRotatedRectangleOn(m_canvasDrawings, x1,y1,x2,y2,x3,y3, col, sel, hovered,
                                    m_drawnObjects[i].lineWidth,
                                    m_drawnObjects[i].lineOpacity,
                                    m_drawnObjects[i].lineStyle,
                                    m_drawnObjects[i].fillColor,
                                    m_drawnObjects[i].fillOpacity);
            break;
         //--- Arc: 3-anchor circular arc with enclosed-region fill
         case TOOL_ARC:
            DrawArcOn(m_canvasDrawings, x1,y1,x2,y2,x3,y3, col, sel, hovered,
                       m_drawnObjects[i].lineWidth,
                       m_drawnObjects[i].lineOpacity,
                       m_drawnObjects[i].lineStyle,
                       m_drawnObjects[i].fillColor,
                       m_drawnObjects[i].fillOpacity);
            break;
         //--- Curve: 3-anchor quadratic Bezier stroke (no fill)
         case TOOL_CURVE:
            DrawCurveOn(m_canvasDrawings, x1,y1,x2,y2,x3,y3, col, sel, hovered,
                         m_drawnObjects[i].lineWidth,
                         m_drawnObjects[i].lineOpacity,
                         m_drawnObjects[i].lineStyle);
            break;
         //--- Arrow: 2-anchor straight arrow with filled head at P2
         case TOOL_ARROW:
            DrawArrowOn(m_canvasDrawings, x1,y1,x2,y2, col, sel, hovered,
                         m_drawnObjects[i].lineWidth,
                         m_drawnObjects[i].lineOpacity);
            break;
         //--- Arrow Marker: 2-anchor solid silhouette pointing from P1 to P2
         case TOOL_ARROW_MARKER:
            DrawArrowMarkerOn(m_canvasDrawings, x1,y1,x2,y2, col, sel, hovered, false,
                               m_drawnObjects[i].lineOpacity);
            break;
         //--- Arrow Up: 1-anchor solid up-pointing dart at P1
         case TOOL_ARROW_UP:
            DrawArrowUpDownOn(m_canvasDrawings, x1, y1, true,  col, sel, hovered, false,
                               m_drawnObjects[i].lineOpacity);
            break;
         //--- Arrow Down: 1-anchor solid down-pointing dart at P1
         case TOOL_ARROW_DOWN:
            DrawArrowUpDownOn(m_canvasDrawings, x1, y1, false, col, sel, hovered, false,
                               m_drawnObjects[i].lineOpacity);
            break;
         //--- Note: 2-anchor connector + rounded rect at P2 with editable text
         case TOOL_NOTE:
           {
            //--- Edit state and rendered text source for this Note object
            bool isEdit = (m_isEditingLabel && sel);
            string commitText = m_drawnObjects[i].labelText;
            int noteBoxL=0, noteBoxT=0, noteBoxR=0, noteBoxB=0;
            //--- Delegate to CAnnotationTools::DrawNoteOn for the actual rendering
            DrawNoteOn(m_canvasDrawings, x1, y1, x2, y2,
                        commitText, isEdit, m_labelEditBuffer,
                        m_labelCaretPos,
                        col, sel, hovered,
                        noteBoxL, noteBoxT, noteBoxR, noteBoxB,
                        m_drawnObjects[i].lineOpacity,
                        m_drawnObjects[i].fontSize,
                        m_drawnObjects[i].bold,
                        m_drawnObjects[i].fillColor,
                        m_drawnObjects[i].fillOpacity,
                        m_drawnObjects[i].textColor,
                        m_drawnObjects[i].textOpacity);
            //--- Record the note's rect as the label hit-rect for click-to-edit routing
            if(sel)
              {
               m_labelHitActive           = true;
               m_labelHitObjIdForSelected = m_drawnObjects[i].id;
               m_labelHitX1 = noteBoxL; m_labelHitY1 = noteBoxT;
               m_labelHitX2 = noteBoxR; m_labelHitY2 = noteBoxB;
               //--- Axis-aligned corners since Note rects don't rotate
               ArrayResize(m_labelHitCornerX, 4);
               ArrayResize(m_labelHitCornerY, 4);
               m_labelHitCornerX[0] = noteBoxL; m_labelHitCornerY[0] = noteBoxT;
               m_labelHitCornerX[1] = noteBoxR; m_labelHitCornerY[1] = noteBoxT;
               m_labelHitCornerX[2] = noteBoxR; m_labelHitCornerY[2] = noteBoxB;
               m_labelHitCornerX[3] = noteBoxL; m_labelHitCornerY[3] = noteBoxB;
              }
            break;
           }
         //--- Price Note: 2-anchor connector + DodgerBlue rect showing the anchored price
         case TOOL_PRICE_NOTE:
           {
            int priceBoxL=0, priceBoxT=0, priceBoxR=0, priceBoxB=0;
            //--- Delegate to CAnnotationTools::DrawPriceNoteOn (no edit mode)
            DrawPriceNoteOn(m_canvasDrawings, x1, y1, x2, y2,
                             m_drawnObjects[i].price1,
                             col, sel, hovered,
                             priceBoxL, priceBoxT, priceBoxR, priceBoxB,
                             m_drawnObjects[i].lineOpacity,
                             m_drawnObjects[i].fontSize,
                             m_drawnObjects[i].fillColor,
                             m_drawnObjects[i].fillOpacity,
                             m_drawnObjects[i].textColor,
                             m_drawnObjects[i].textOpacity);
            break;
           }
         //--- Callout: 2-anchor shaft from P1 to a rounded box at P2 with editable text
         case TOOL_CALLOUT:
           {
            //--- Edit state and rendered text source for this Callout object
            bool isEdit = (m_isEditingLabel && sel);
            string commitText = m_drawnObjects[i].labelText;
            int coBoxL=0, coBoxT=0, coBoxR=0, coBoxB=0;
            //--- Delegate to CAnnotationTools::DrawCalloutOn for the actual rendering
            DrawCalloutOn(m_canvasDrawings, x1, y1, x2, y2,
                           commitText, isEdit, m_labelEditBuffer,
                           m_labelCaretPos,
                           col, sel, hovered,
                           coBoxL, coBoxT, coBoxR, coBoxB,
                           m_drawnObjects[i].lineOpacity,
                           m_drawnObjects[i].fontSize,
                           m_drawnObjects[i].bold,
                           m_drawnObjects[i].fillColor,
                           m_drawnObjects[i].fillOpacity,
                           m_drawnObjects[i].textColor,
                           m_drawnObjects[i].textOpacity);
            //--- Record the callout box as the label hit-rect for click-to-edit routing
            if(sel)
              {
               m_labelHitActive           = true;
               m_labelHitObjIdForSelected = m_drawnObjects[i].id;
               m_labelHitX1 = coBoxL; m_labelHitY1 = coBoxT;
               m_labelHitX2 = coBoxR; m_labelHitY2 = coBoxB;
               //--- Axis-aligned corners since Callout boxes don't rotate
               ArrayResize(m_labelHitCornerX, 4);
               ArrayResize(m_labelHitCornerY, 4);
               m_labelHitCornerX[0] = coBoxL; m_labelHitCornerY[0] = coBoxT;
               m_labelHitCornerX[1] = coBoxR; m_labelHitCornerY[1] = coBoxT;
               m_labelHitCornerX[2] = coBoxR; m_labelHitCornerY[2] = coBoxB;
               m_labelHitCornerX[3] = coBoxL; m_labelHitCornerY[3] = coBoxB;
              }
            break;
           }
         //--- Comment: 1-click mixed-radius rounded rect anchored bottom-left at P1
         case TOOL_COMMENT:
           {
            //--- Edit state and rendered text source for this Comment object
            bool isEdit = (m_isEditingLabel && sel);
            string commitText = m_drawnObjects[i].labelText;
            int cmBoxL=0, cmBoxT=0, cmBoxR=0, cmBoxB=0;
            //--- Delegate to CAnnotationTools::DrawCommentOn for the actual rendering
            DrawCommentOn(m_canvasDrawings, x1, y1,
                           commitText, isEdit, m_labelEditBuffer,
                           m_labelCaretPos,
                           col, sel, hovered,
                           cmBoxL, cmBoxT, cmBoxR, cmBoxB,
                           m_drawnObjects[i].lineOpacity,
                           m_drawnObjects[i].fontSize,
                           m_drawnObjects[i].bold,
                           m_drawnObjects[i].fillColor,
                           m_drawnObjects[i].fillOpacity,
                           m_drawnObjects[i].textColor,
                           m_drawnObjects[i].textOpacity);
            //--- Record the comment box as the label hit-rect for click-to-edit routing
            if(sel)
              {
               m_labelHitActive           = true;
               m_labelHitObjIdForSelected = m_drawnObjects[i].id;
               m_labelHitX1 = cmBoxL; m_labelHitY1 = cmBoxT;
               m_labelHitX2 = cmBoxR; m_labelHitY2 = cmBoxB;
               //--- Axis-aligned corners since Comment boxes don't rotate
               ArrayResize(m_labelHitCornerX, 4);
               ArrayResize(m_labelHitCornerY, 4);
               m_labelHitCornerX[0] = cmBoxL; m_labelHitCornerY[0] = cmBoxT;
               m_labelHitCornerX[1] = cmBoxR; m_labelHitCornerY[1] = cmBoxT;
               m_labelHitCornerX[2] = cmBoxR; m_labelHitCornerY[2] = cmBoxB;
               m_labelHitCornerX[3] = cmBoxL; m_labelHitCornerY[3] = cmBoxB;
              }
            break;
           }
         //--- Circle: 2-anchor disc with one-of {center handle, prompt, label} center-occupant rule
         case TOOL_CIRCLE:
           {
            //--- Detect whether the object has a committed label (occupies the center)
            bool hasText = StringLen(m_drawnObjects[i].labelText) > 0;
            //--- Detect whether the cursor is hovering any handle of this object
            bool cursorOnHandleForThisObj = (m_hoveredHandleHostId == m_drawnObjects[i].id &&
                                              m_hoveredHandleIdx >= 0);
            //--- Detect whether ANY drag is in progress on the engine
            bool anyDragging_ = (m_isDraggingHandle || m_isDraggingObject);
            //--- Prompt visibility gates (matches HandlePointerMouseMove's grace zones)
            bool showingPrompt = sel && hovered && !hasText && !m_isEditingLabel &&
                                  !cursorOnHandleForThisObj && !anyDragging_;
            //--- Active edit state for this object
            bool activelyEditing = m_isEditingLabel && sel;
            //--- Center handle hides whenever something else occupies the center
            bool hideCenter = hasText || showingPrompt || activelyEditing;
            //--- Delegate to CShapeTools::DrawCircleOn for the actual rendering
            DrawCircleOn(m_canvasDrawings, x1, y1, x2, y2, col, sel, hovered, hideCenter,
                          m_drawnObjects[i].lineWidth,
                          m_drawnObjects[i].lineOpacity,
                          m_drawnObjects[i].lineStyle,
                          m_drawnObjects[i].fillColor,
                          m_drawnObjects[i].fillOpacity);
            break;
           }
         //--- Path: N-vertex polyline with arrowhead at the last point
         case TOOL_PATH:
           {
            //--- Map every vertex from (time, price) to canvas pixels into parallel arrays
            int N = ArraySize(m_drawnObjects[i].pathTimes);
            if(N >= 2)
              {
               //--- Allocate parallel pixel arrays sized to the path vertex count
               int pxs[], pys[];
               ArrayResize(pxs, N);
               ArrayResize(pys, N);
               for(int pi = 0; pi < N; pi++)
                 {
                  //--- Map each vertex to canvas coordinates
                  int pxx=0, pyy=0;
                  ChartTimePriceToXY(m_chartId, 0,
                                      m_drawnObjects[i].pathTimes[pi],
                                      m_drawnObjects[i].pathPrices[pi],
                                      pxx, pyy);
                  pxs[pi] = pxx;
                  pys[pi] = pyy;
                 }
               //--- Delegate to CShapeTools::DrawPathOn (N-1 segments + N handles + arrowhead)
               DrawPathOn(m_canvasDrawings, pxs, pys, col, sel, hovered,
                           true,
                           m_drawnObjects[i].lineWidth,
                           m_drawnObjects[i].lineOpacity,
                           m_drawnObjects[i].lineStyle);
              }
            break;
           }
         //--- Triangle: 3-anchor closed shape with translucent fill + 2px border
         case TOOL_TRIANGLE:           DrawTriangleOn(m_canvasDrawings,x1,y1,x2,y2,x3,y3,col,sel,hovered,
                                          m_drawnObjects[i].lineWidth,
                                          m_drawnObjects[i].lineOpacity,
                                          m_drawnObjects[i].lineStyle,
                                          m_drawnObjects[i].fillColor,
                                          m_drawnObjects[i].fillOpacity);                            break;
         //--- Rotated 3-point ellipse: P1/P2 = major axis ends, P3 = minor-axis defining point
         case TOOL_ELLIPSE:            DrawEllipseOn(m_canvasDrawings,x1,y1,x2,y2,x3,y3,col,sel,hovered,
                                          m_drawnObjects[i].lineWidth,
                                          m_drawnObjects[i].lineOpacity,
                                          m_drawnObjects[i].lineStyle,
                                          m_drawnObjects[i].fillColor,
                                          m_drawnObjects[i].fillOpacity);                            break;
         //--- Gann line: 2-anchor 1:1 ratio line extended past the canvas edges
         case TOOL_GANN_LINE:
            DrawGannLineOn(m_canvasDrawings, x1,y1,x2,y2, col, sel, hovered,
                            m_drawnObjects[i].lineOpacity,
                            m_drawnObjects[i].lineWidth,
                            m_drawnObjects[i].lineStyle);
            break;
         //--- Gann fan: 2-anchor multi-ratio fan radiating from P1
         case TOOL_GANN_FAN:
            DrawGannFanOn(m_canvasDrawings, x1,y1,x2,y2, col, sel, hovered,
                           m_drawnObjects[i].gannfanLevelRatio,
                           m_drawnObjects[i].gannfanLevelColor,
                           m_drawnObjects[i].gannfanLevelOpacity,
                           m_drawnObjects[i].gannfanLevelWidth,
                           m_drawnObjects[i].gannfanLevelStyle,
                           m_drawnObjects[i].gannfanLevelVisible,
                           m_drawnObjects[i].fillOpacity);
            break;
         //--- Gann box: 2-anchor box with internal grid at level ratios
         case TOOL_GANN_BOX:
            DrawGannBoxOn(m_canvasDrawings, x1,y1,x2,y2, col, sel, hovered,
                           m_drawnObjects[i].gannboxLevelRatio,
                           m_drawnObjects[i].gannboxLevelColor,
                           m_drawnObjects[i].gannboxLevelOpacity,
                           m_drawnObjects[i].gannboxLevelWidth,
                           m_drawnObjects[i].gannboxLevelStyle,
                           m_drawnObjects[i].gannboxLevelVisible,
                           m_drawnObjects[i].fillOpacity);
            break;
         //--- Fibonacci Retracement: 2-anchor horizontal level lines at Fib ratios of P1-P2
         case TOOL_FIBO_RETRACEMENT:
            DrawFibRetracementOn(m_canvasDrawings, x1,y1,x2,y2, col, sel, hovered,
                                  m_drawnObjects[i].fiboLevelRatio,
                                  m_drawnObjects[i].fiboLevelColor,
                                  m_drawnObjects[i].fiboLevelOpacity,
                                  m_drawnObjects[i].fiboLevelWidth,
                                  m_drawnObjects[i].fiboLevelStyle,
                                  m_drawnObjects[i].fiboLevelVisible);
            break;
         //--- Fibonacci Expansion: 3-anchor expansion projecting Fib levels past P3
         case TOOL_FIBO_EXPANSION:
            DrawFibExpansionOn(m_canvasDrawings, x1,y1,x2,y2,x3,y3, col, sel, hovered,
                                m_drawnObjects[i].fibexLevelRatio,
                                m_drawnObjects[i].fibexLevelColor,
                                m_drawnObjects[i].fibexLevelOpacity,
                                m_drawnObjects[i].fibexLevelWidth,
                                m_drawnObjects[i].fibexLevelStyle,
                                m_drawnObjects[i].fibexLevelVisible);
            break;
         //--- Fibonacci Channel: 3-anchor channel with parallel lines at Fib ratios
         case TOOL_FIBO_CHANNEL:
            DrawFibChannelOn(m_canvasDrawings, x1,y1,x2,y2,x3,y3, col, sel, hovered,
                              m_drawnObjects[i].fibchLevelRatio,
                              m_drawnObjects[i].fibchLevelColor,
                              m_drawnObjects[i].fibchLevelOpacity,
                              m_drawnObjects[i].fibchLevelWidth,
                              m_drawnObjects[i].fibchLevelStyle,
                              m_drawnObjects[i].fibchLevelVisible);
            break;
         //--- Fibonacci Time Zones: 2-anchor vertical lines at Fib time intervals from P1-P2
         case TOOL_FIBO_TIMEZONES:
            DrawFibTimeZoneOn(m_canvasDrawings, x1,y1,x2,y2, col, sel, hovered,
                               m_drawnObjects[i].fibtzLevelRatio,
                               m_drawnObjects[i].fibtzLevelColor,
                               m_drawnObjects[i].fibtzLevelOpacity,
                               m_drawnObjects[i].fibtzLevelWidth,
                               m_drawnObjects[i].fibtzLevelStyle,
                               m_drawnObjects[i].fibtzLevelVisible);
            break;
         //--- Fibonacci Fan: 2-anchor rays radiating from P1 at Fib angle ratios
         case TOOL_FIBO_FAN:
            DrawFibFanOn(m_canvasDrawings, x1,y1,x2,y2, col, sel, hovered,
                          m_drawnObjects[i].fibfanLevelRatio,
                          m_drawnObjects[i].fibfanLevelColor,
                          m_drawnObjects[i].fibfanLevelOpacity,
                          m_drawnObjects[i].fibfanLevelWidth,
                          m_drawnObjects[i].fibfanLevelStyle,
                          m_drawnObjects[i].fibfanLevelVisible);
            break;
         //--- Fibonacci Arcs: 2-anchor concentric arcs at Fib radius ratios from P1
         case TOOL_FIBO_ARCS:
            DrawFibArcsOn(m_canvasDrawings, x1,y1,x2,y2, col, sel, hovered,
                           m_drawnObjects[i].fibarcLevelRatio,
                           m_drawnObjects[i].fibarcLevelColor,
                           m_drawnObjects[i].fibarcLevelOpacity,
                           m_drawnObjects[i].fibarcLevelWidth,
                           m_drawnObjects[i].fibarcLevelStyle,
                           m_drawnObjects[i].fibarcLevelVisible);
            break;
         //--- Parallel Channel: 3-anchor channel A-B with C/D derived under vertical alignment
         case TOOL_PARALLEL_CHANNEL:
            DrawParallelChannelOn(m_canvasDrawings, x1,y1,x2,y2,x3,y3, col, sel, hovered,
                                   m_drawnObjects[i].lineWidth,
                                   m_drawnObjects[i].lineOpacity,
                                   m_drawnObjects[i].lineStyle,
                                   m_drawnObjects[i].midColor,
                                   m_drawnObjects[i].midOpacity,
                                   m_drawnObjects[i].midStyle,
                                   m_drawnObjects[i].fillColor,
                                   m_drawnObjects[i].fillOpacity,
                                   m_drawnObjects[i].midVisible,
                                   m_drawnObjects[i].midWidth,
                                   m_drawnObjects[i].midOffset);     break;
         //--- Regression Channel: 2-time-anchor regression line + sigma bands recomputed from bars
         case TOOL_REGRESSION_CHANNEL:
            DrawRegressionChannelOn(m_canvasDrawings, m_chartId,
                                     m_drawnObjects[i].time1,
                                     m_drawnObjects[i].time2,
                                     col, sel, hovered,
                                     m_drawnObjects[i].lineWidth,
                                     m_drawnObjects[i].lineOpacity,
                                     m_drawnObjects[i].lineStyle,
                                     m_drawnObjects[i].fillColor,
                                     m_drawnObjects[i].fillOpacity,
                                     m_drawnObjects[i].fillColor2,
                                     m_drawnObjects[i].fillOpacity2,
                                     m_drawnObjects[i].textColor,
                                     m_drawnObjects[i].textOpacity,
                                     m_drawnObjects[i].centerVisible,
                                     m_drawnObjects[i].centerColor,
                                     m_drawnObjects[i].centerOpacity,
                                     m_drawnObjects[i].centerWidth,
                                     m_drawnObjects[i].centerStyle,
                                     m_drawnObjects[i].upperBandVisible,
                                     m_drawnObjects[i].upperBandSigma,
                                     m_drawnObjects[i].lowerBandVisible,
                                     m_drawnObjects[i].lowerBandSigma,
                                     m_drawnObjects[i].pearsonVisible); break;
         //--- StdDev Channel: 2-time-anchor regression with stddev-band fill (no Pearson info)
         case TOOL_STDDEV_CHANNEL:
            DrawStdDevChannelOn(m_canvasDrawings, m_chartId,
                                 m_drawnObjects[i].time1,
                                 m_drawnObjects[i].time2,
                                 col, sel, hovered,
                                 m_drawnObjects[i].lineWidth,
                                 m_drawnObjects[i].lineOpacity,
                                 m_drawnObjects[i].lineStyle,
                                 m_drawnObjects[i].fillColor,
                                 m_drawnObjects[i].fillOpacity,
                                 m_drawnObjects[i].centerVisible,
                                 m_drawnObjects[i].centerColor,
                                 m_drawnObjects[i].centerOpacity,
                                 m_drawnObjects[i].centerWidth,
                                 m_drawnObjects[i].centerStyle,
                                 m_drawnObjects[i].upperBandVisible,
                                 m_drawnObjects[i].upperBandSigma,
                                 m_drawnObjects[i].lowerBandVisible,
                                 m_drawnObjects[i].lowerBandSigma);    break;
         //--- Andrew's Pitchfork: 3-anchor median line + 2 parallel outer + 2 inner (Schiff variants)
         case TOOL_PITCHFORK:
            DrawAndrewsPitchforkOn(m_canvasDrawings, x1,y1,x2,y2,x3,y3, col, sel, hovered,
                                    m_drawnObjects[i].medianVisible,
                                    m_drawnObjects[i].medianColor,
                                    m_drawnObjects[i].medianWidth,
                                    m_drawnObjects[i].medianStyle,
                                    m_drawnObjects[i].outerVisible,
                                    m_drawnObjects[i].outerColor,
                                    m_drawnObjects[i].outerWidth,
                                    m_drawnObjects[i].outerStyle,
                                    m_drawnObjects[i].innerVisible,
                                    m_drawnObjects[i].innerColor,
                                    m_drawnObjects[i].innerWidth,
                                    m_drawnObjects[i].innerStyle,
                                    m_drawnObjects[i].lineOpacity,
                                    m_drawnObjects[i].fillOpacity);
            break;
         //--- Schiff Pitchfork: variant with median originating at midpoint of P1-P2 chord
         case TOOL_SCHIFF_PITCHFORK:
            DrawSchiffPitchforkOn(m_canvasDrawings, x1,y1,x2,y2,x3,y3, col, sel, hovered,
                                   m_drawnObjects[i].medianVisible,
                                   m_drawnObjects[i].medianColor,
                                   m_drawnObjects[i].medianWidth,
                                   m_drawnObjects[i].medianStyle,
                                   m_drawnObjects[i].outerVisible,
                                   m_drawnObjects[i].outerColor,
                                   m_drawnObjects[i].outerWidth,
                                   m_drawnObjects[i].outerStyle,
                                   m_drawnObjects[i].innerVisible,
                                   m_drawnObjects[i].innerColor,
                                   m_drawnObjects[i].innerWidth,
                                   m_drawnObjects[i].innerStyle,
                                   m_drawnObjects[i].lineOpacity,
                                   m_drawnObjects[i].fillOpacity);
            break;
         //--- Modified Schiff: variant where median origin uses P1.x and chord-midpoint Y
         case TOOL_MOD_SCHIFF:
            DrawModSchiffPitchforkOn(m_canvasDrawings, x1,y1,x2,y2,x3,y3, col, sel, hovered,
                                      m_drawnObjects[i].medianVisible,
                                      m_drawnObjects[i].medianColor,
                                      m_drawnObjects[i].medianWidth,
                                      m_drawnObjects[i].medianStyle,
                                      m_drawnObjects[i].outerVisible,
                                      m_drawnObjects[i].outerColor,
                                      m_drawnObjects[i].outerWidth,
                                      m_drawnObjects[i].outerStyle,
                                      m_drawnObjects[i].innerVisible,
                                      m_drawnObjects[i].innerColor,
                                      m_drawnObjects[i].innerWidth,
                                      m_drawnObjects[i].innerStyle,
                                      m_drawnObjects[i].lineOpacity,
                                      m_drawnObjects[i].fillOpacity);
            break;
         //--- Tools with no registered render route fall through silently
         default: break;
        }

      //--- Draw the committed label (or live edit buffer) when applicable
      bool hasLabel = StringLen(m_drawnObjects[i].labelText) > 0;
      bool isBeingEdited = (m_isEditingLabel && sel);
      //--- TOOL_TEXT family renders its own text inside its box; skip the generic label path
      bool isTextAnnotTool = (m_drawnObjects[i].toolType == TOOL_TEXT ||
                               m_drawnObjects[i].toolType == TOOL_NOTE ||
                               m_drawnObjects[i].toolType == TOOL_PRICE_NOTE ||
                               m_drawnObjects[i].toolType == TOOL_CALLOUT ||
                               m_drawnObjects[i].toolType == TOOL_COMMENT);
      if((hasLabel || isBeingEdited) && !isTextAnnotTool)
        {
         //--- Per-tool layout parameters fed to DrawObjectLabel
         int la_x1 = x1, la_y1 = y1, la_x2 = x2, la_y2 = y2;
         //--- Override anchor flag: when true, labMxOverride/labMyOverride drive the anchor
         bool useOverrideAnchor = false;
         int labMxOverride = 0;
         int labMyOverride = 0;
         //--- Defaults: above-line anchor, no wrap, no host clip, no shape clip
         int anchorMode_ = LBL_ANCHOR_ABOVE_LINE;
         int wrapW   = 0;
         int clipL_  = -1;
         int clipT_  = -1;
         int clipR_  = -1;
         int clipB_  = -1;
         int shapeKind_  = LBL_SHAPE_NONE;
         double shapeRA  = 0.0;
         double shapeRB  = 0.0;
         int shapeCx_    = 0;
         int shapeCy_    = 0;
         int maxLines_   = 0;
         int availableH_ = 0;
         //--- Approximate 11pt Arial line height at 4x SSAA (conservative for AUTO_FIT decisions)
         const int lineH_estimate = 14;
         if(m_drawnObjects[i].toolType == TOOL_HLINE)
           {
            //--- HLine: synthesize full-canvas endpoints so the label centers horizontally
            int cW = m_canvasDrawings.Width();
            la_x1 = 0;      la_y1 = y1;
            la_x2 = cW - 1; la_y2 = y1;
            anchorMode_ = LBL_ANCHOR_CENTERED;
           }
         else if(m_drawnObjects[i].toolType == TOOL_VLINE)
           {
            //--- VLine: reversed endpoints (bottom -> top) so text reads bottom-to-top (+90deg)
            int cH = m_canvasDrawings.Height();
            la_x1 = x1; la_y1 = cH - 1;
            la_x2 = x1; la_y2 = 0;
            anchorMode_ = LBL_ANCHOR_CENTERED;
           }
         else if(m_drawnObjects[i].toolType == TOOL_RECTANGLE)
           {
            //--- Rectangle: horizontal text, AUTO_FIT anchor mode (centered or top on overflow)
            int rxL = (x1 < x2) ? x1 : x2;
            int rxR = (x1 < x2) ? x2 : x1;
            int ryT = (y1 < y2) ? y1 : y2;
            int ryB = (y1 < y2) ? y2 : y1;
            int pad = 6;
            //--- Horizontal endpoint pair defines the text direction (axis-aligned)
            la_x1 = rxL; la_y1 = (ryT + ryB) / 2;
            la_x2 = rxR; la_y2 = (ryT + ryB) / 2;
            anchorMode_  = LBL_ANCHOR_AUTO_FIT;
            //--- AUTO_FIT anchor = host center; renderer collapses to CENTERED or TOP on overflow
            labMxOverride = (rxL + rxR) / 2;
            labMyOverride = (ryT + ryB) / 2;
            useOverrideAnchor = true;
            //--- Wrap width = interior horizontal extent minus padding
            wrapW  = (rxR - rxL) - 2 * pad;
            if(wrapW < 10) wrapW = 10;
            //--- Inner-clip rectangle matches the padded host interior
            clipL_ = rxL + pad;
            clipT_ = ryT + pad;
            clipR_ = rxR - pad;
            clipB_ = ryB - pad;
            //--- Available vertical extent drives the AUTO_FIT decision
            availableH_ = (ryB - ryT) - 2 * pad;
            if(availableH_ < lineH_estimate) availableH_ = lineH_estimate;
            //--- maxLines as a coarse upper bound (informational; AUTO_FIT uses availableH directly)
            maxLines_ = availableH_ / lineH_estimate;
            if(maxLines_ < 1) maxLines_ = 1;
            //--- Rectangle has no shape equation; the AABB clip alone handles boundary
            shapeKind_ = LBL_SHAPE_NONE;
           }
         else if(m_drawnObjects[i].toolType == TOOL_ELLIPSE)
           {
            //--- Ellipse: text runs along the major axis (P1 -> P2) with per-pixel shape clip
            la_x1 = x1; la_y1 = y1;
            la_x2 = x2; la_y2 = y2;
            anchorMode_ = LBL_ANCHOR_AUTO_FIT;
            //--- Compute major-axis length from P1-P2 in canvas pixels
            double exDx = (double)(x2 - x1);
            double exDy = (double)(y2 - y1);
            double major = MathSqrt(exDx * exDx + exDy * exDy);
            //--- Default minor = 0.5 * major when P3 isn't available yet
            double minor = major * 0.5;
            int x3=0, y3=0;
            ChartTimePriceToXY(m_chartId, 0,
                                m_drawnObjects[i].time3,
                                m_drawnObjects[i].price3, x3, y3);
            //--- When P3 exists, derive minor from its perpendicular distance to the P1-P2 line
            if(x3 != 0 || y3 != 0)
              {
               double pdx = (double)(x3 - x1);
               double pdy = (double)(y3 - y1);
               double perpX = -exDy / major;
               double perpY =  exDx / major;
               minor = MathAbs(pdx * perpX + pdy * perpY) * 2.0;
               if(minor < 4.0) minor = 4.0;
              }
            //--- Half-extents (a = semi-major, b = semi-minor)
            double a = major / 2.0;
            double b = minor / 2.0;
            //--- Wrap width = approximate inscribed-rect width (a * 1.3 ~ 2a / sqrt(2) margin)
            wrapW = (int)(a * 1.30);
            if(wrapW < 10) wrapW = 10;
            //--- AUTO_FIT anchor = ellipse center; renderer handles centered/top overflow shift
            int ecx = (x1 + x2) / 2;
            int ecy = (y1 + y2) / 2;
            labMxOverride = ecx;
            labMyOverride = ecy;
            useOverrideAnchor = true;
            //--- Loose AABB host clip; the per-pixel ellipse equation does the tight clip
            int eAabbL = MathMin(x1, x2) - (int)b;
            int eAabbT = MathMin(y1, y2) - (int)b;
            int eAabbR = MathMax(x1, x2) + (int)b;
            int eAabbB = MathMax(y1, y2) + (int)b;
            clipL_ = eAabbL; clipT_ = eAabbT;
            clipR_ = eAabbR; clipB_ = eAabbB;
            //--- Enable per-pixel ellipse equation clip with radii (a, b) and center
            shapeKind_ = LBL_SHAPE_ELLIPSE;
            shapeRA    = a;
            shapeRB    = b;
            shapeCx_   = ecx;
            shapeCy_   = ecy;
            //--- Available vertical extent ~ 1.4 * b (inscribed-rect height)
            availableH_ = (int)(b * 1.40);
            if(availableH_ < lineH_estimate) availableH_ = lineH_estimate;
            maxLines_ = availableH_ / lineH_estimate;
            if(maxLines_ < 1) maxLines_ = 1;
           }
         else if(m_drawnObjects[i].toolType == TOOL_CIRCLE)
           {
            //--- Circle: horizontal text centered at P1 with per-pixel circle equation clip
            la_x1 = x1 - 1; la_y1 = y1;
            la_x2 = x1 + 1; la_y2 = y1;
            anchorMode_ = LBL_ANCHOR_AUTO_FIT;
            //--- Compute radius from P1-P2 distance
            double rdx = (double)(x2 - x1);
            double rdy = (double)(y2 - y1);
            double r   = MathSqrt(rdx * rdx + rdy * rdy);
            //--- Inscribed square half-extent ~ r * 0.65 keeps text comfortably inside the disc
            int inscribedHalf = (int)(r * 0.65);
            if(inscribedHalf < 5) inscribedHalf = 5;
            wrapW = inscribedHalf * 2;
            //--- AUTO_FIT anchor = circle center; renderer handles centered/top overflow shift
            labMxOverride = x1;
            labMyOverride = y1;
            useOverrideAnchor = true;
            //--- Loose inscribed-square clip; the per-pixel circle equation does the tight clip
            clipL_ = x1 - inscribedHalf;
            clipT_ = y1 - inscribedHalf;
            clipR_ = x1 + inscribedHalf;
            clipB_ = y1 + inscribedHalf;
            //--- Enable per-pixel circle equation clip with radius r and center (x1, y1)
            shapeKind_ = LBL_SHAPE_CIRCLE;
            shapeRA    = r;
            shapeRB    = r;
            shapeCx_   = x1;
            shapeCy_   = y1;
            //--- Available vertical extent = inscribed square's full edge length
            availableH_ = inscribedHalf * 2;
            if(availableH_ < lineH_estimate) availableH_ = lineH_estimate;
            maxLines_ = availableH_ / lineH_estimate;
            if(maxLines_ < 1) maxLines_ = 1;
           }
         //--- Compute the label block's anchor midpoint (override or midpoint of synthetic endpoints)
         int labMx = useOverrideAnchor ? labMxOverride : (la_x1 + la_x2) / 2;
         int labMy = useOverrideAnchor ? labMyOverride : (la_y1 + la_y2) / 2;
         //--- Delegate label rendering with all per-tool layout parameters
         DrawObjectLabel(labMx, labMy, la_x1, la_y1, la_x2, la_y2,
                         m_drawnObjects[i].labelText, sel, hovered, colText,
                         anchorMode_, sel,
                         wrapW, clipL_, clipT_, clipR_, clipB_,
                         shapeKind_, shapeRA, shapeRB,
                         maxLines_, shapeCx_, shapeCy_,
                         availableH_,
                         m_drawnObjects[i].textOpacity,
                         m_drawnObjects[i].fontSize,
                         m_drawnObjects[i].bold,
                         m_drawnObjects[i].vAlign,
                         m_drawnObjects[i].hAlign);
         //--- Cache the label's hit-rect owner for click-to-edit routing on the selected object
         if(sel)
            m_labelHitObjIdForSelected = m_drawnObjects[i].id;
        }
      //--- Set of tools that show the "+ Add text" prompt (despite the name, also includes shapes)
      bool isLineTool = (m_drawnObjects[i].toolType == TOOL_TRENDLINE ||
                         m_drawnObjects[i].toolType == TOOL_RAY        ||
                         m_drawnObjects[i].toolType == TOOL_EXTENDED_LINE ||
                         m_drawnObjects[i].toolType == TOOL_INFO_LINE   ||
                         m_drawnObjects[i].toolType == TOOL_TREND_ANGLE ||
                         m_drawnObjects[i].toolType == TOOL_HLINE       ||
                         m_drawnObjects[i].toolType == TOOL_VLINE       ||
                         m_drawnObjects[i].toolType == TOOL_RECTANGLE   ||
                         m_drawnObjects[i].toolType == TOOL_ELLIPSE     ||
                         m_drawnObjects[i].toolType == TOOL_CIRCLE      ||
                         m_drawnObjects[i].toolType == TOOL_TRIANGLE    ||
                         m_drawnObjects[i].toolType == TOOL_ROTATED_RECTANGLE ||
                         m_drawnObjects[i].toolType == TOOL_ARC         ||
                         m_drawnObjects[i].toolType == TOOL_ARROW);
      //--- Prompt suppressed when the cursor sits on any handle of THIS object
      bool cursorOnHandle = (m_hoveredHandleHostId == m_drawnObjects[i].id &&
                             m_hoveredHandleIdx >= 0);
      bool anyDragging    = (m_isDraggingHandle || m_isDraggingObject);
      //--- All gates must be true: line-family, selected + hovered, no label, not editing, not on handle, not dragging
      if(isLineTool && sel && hovered && !hasLabel && !m_isEditingLabel &&
         !cursorOnHandle && !anyDragging)
        {
         //--- Choose prompt endpoints based on tool type (full span for HLine/VLine)
         int pa_x = x1, pa_y = y1, pb_x = x2, pb_y = y2;
         bool centerOn = false;
         if(m_drawnObjects[i].toolType == TOOL_HLINE)
           {
            //--- HLine: synthesize full-canvas endpoints; prompt centers on Y1
            int cW = m_canvasDrawings.Width();
            pa_x = 0;      pa_y = y1;
            pb_x = cW - 1; pb_y = y1;
            centerOn = true;
           }
         else if(m_drawnObjects[i].toolType == TOOL_VLINE)
           {
            //--- VLine: reversed endpoints (bottom -> top) so prompt reads bottom-to-top
            int cH = m_canvasDrawings.Height();
            pa_x = x1; pa_y = cH - 1;
            pb_x = x1; pb_y = 0;
            centerOn = true;
           }
         else if(m_drawnObjects[i].toolType == TOOL_RECTANGLE)
           {
            //--- Rectangle: horizontal prompt centered inside the box
            int rxL = (x1 < x2) ? x1 : x2;
            int rxR = (x1 < x2) ? x2 : x1;
            int ryT = (y1 < y2) ? y1 : y2;
            int ryB = (y1 < y2) ? y2 : y1;
            int rCy = (ryT + ryB) / 2;
            pa_x = rxL; pa_y = rCy;
            pb_x = rxR; pb_y = rCy;
            centerOn = true;
           }
         else if(m_drawnObjects[i].toolType == TOOL_ELLIPSE)
           {
            //--- Ellipse: prompt runs along the major axis matching committed text orientation
            pa_x = x1; pa_y = y1;
            pb_x = x2; pb_y = y2;
            centerOn = true;
           }
         else if(m_drawnObjects[i].toolType == TOOL_CIRCLE)
           {
            //--- Circle: horizontal prompt at the center matching committed text position
            pa_x = x1 - 1; pa_y = y1;
            pb_x = x1 + 1; pb_y = y1;
            centerOn = true;
           }
         //--- Render the prompt and capture its rotated corners for click-to-enter-edit routing
         int px1 = 0, py1 = 0, px2 = 0, py2 = 0;
         DrawAddTextPromptOn(m_canvasDrawings, pa_x, pa_y, pb_x, pb_y,
                             m_drawnObjects[i].textColor,
                             m_isDarkTheme, px1, py1, px2, py2,
                             m_addTextPromptCornerX, m_addTextPromptCornerY,
                             centerOn);
         //--- Cache the prompt's owner ID and AABB for the click router and hover grace zone
         m_addTextPromptObjId = m_drawnObjects[i].id;
         m_addTextPromptX1    = px1;
         m_addTextPromptY1    = py1;
         m_addTextPromptX2    = px2;
         m_addTextPromptY2    = py2;
        }
     }
   //--- Reset handle hide/halo state after the per-object loop so it doesn't leak into previews
   m_hideHandleIdx = -1;
   m_haloHandleIdx = -1;

   //--- PATH preview: variable-length tool with N accumulated points + cursor as virtual final vertex
   if(m_isPreviewActive && m_previewToolType == TOOL_PATH)
     {
      //--- Render only when at least one point has been committed
      int nPts = ArraySize(m_pathBuildTimes);
      if(nPts >= 1)
        {
         //--- Preview color matches commit color (single source of truth)
         color previewColor = GetToolDefaultColor(TOOL_PATH);
         //--- Build a single pixel array of N committed points plus the cursor as the final tip
         int pxs[], pys[];
         ArrayResize(pxs, nPts + 1);
         ArrayResize(pys, nPts + 1);
         for(int pi = 0; pi < nPts; pi++)
           {
            //--- Map each committed vertex to canvas coordinates
            int pxx=0, pyy=0;
            ChartTimePriceToXY(m_chartId, 0,
                                m_pathBuildTimes[pi], m_pathBuildPrices[pi],
                                pxx, pyy);
            pxs[pi] = pxx;
            pys[pi] = pyy;
           }
         //--- Append the live cursor position as the virtual last vertex (arrowhead tip)
         pxs[nPts] = m_previewMouseX;
         pys[nPts] = m_previewMouseY;
         //--- Render the full polyline solid with arrowhead at the cursor and handles at every vertex
         DrawPathOn(m_canvasDrawings, pxs, pys, previewColor, false, true);
        }
     }
   else if(m_isPreviewActive && m_toolDrawingClickCount == 1)
     {
      //--- Click-count = 1 preview branches: 2-click tools showing rubber-band or full-shape preview
      int px1=0,py1=0;
      ChartTimePriceToXY(m_chartId,0,m_drawPoint1Time,m_drawPoint1Price,px1,py1);
      //--- Preview color == commit color (single source of truth)
      color previewColor = GetToolDefaultColor(m_previewToolType);
      if(m_previewToolType == TOOL_GANN_LINE)
        {
         //--- Gann Line preview: full committed-style 1:1 line with default style params
         DrawGannLineOn(m_canvasDrawings, px1, py1,
                         m_previewMouseX, m_previewMouseY,
                         previewColor, false, true,
                         100, 2, 0);
        }
      else if(m_previewToolType == TOOL_GANN_FAN)
        {
         //--- Gann Fan preview: build the canonical 9-level default arrays for committed-style preview
         double pRatio[]; color pCol[]; int pOp[]; int pW[]; int pS[]; bool pVis[];
         const int N = 9;
         ArrayResize(pRatio,N); ArrayResize(pCol,N); ArrayResize(pOp,N);
         ArrayResize(pW,N);     ArrayResize(pS,N);   ArrayResize(pVis,N);
         //--- Canonical Gann Fan default ratios and per-level colors
         const double dr[] = {8.0,4.0,3.0,2.0,1.0,0.5,1.0/3.0,0.25,0.125};
         const color  dc[] = {clrRed,clrCrimson,clrBlueViolet,clrRoyalBlue,
                                clrDodgerBlue,clrDarkCyan,clrSeaGreen,clrTeal,clrOrange};
         //--- Populate per-level style arrays uniformly (visible, width 2, solid)
         for(int k = 0; k < N; k++)
           { pRatio[k]=dr[k]; pCol[k]=dc[k]; pOp[k]=100;
             pW[k]=2; pS[k]=0; pVis[k]=true; }
         //--- Delegate to the main draw routine with 30% fill opacity for the wedge
         DrawGannFanOn(m_canvasDrawings, px1, py1,
                        m_previewMouseX, m_previewMouseY,
                        previewColor, false, true,
                        pRatio, pCol, pOp, pW, pS, pVis,
                        30);
        }
      else if(m_previewToolType == TOOL_CIRCLE)
        {
         //--- Circle preview: full disc with P1 as center and cursor as candidate P2 (border)
         DrawCircleOn(m_canvasDrawings, px1, py1,
                       m_previewMouseX, m_previewMouseY,
                       previewColor, false, true, false);
        }
      else if(m_previewToolType == TOOL_ARROW)
        {
         //--- Arrow preview: full shaft + filled head from P1 (tail) to cursor (tip)
         DrawArrowOn(m_canvasDrawings, px1, py1,
                      m_previewMouseX, m_previewMouseY,
                      previewColor, false, true);
        }
      else if(m_previewToolType == TOOL_ARROW_MARKER)
        {
         //--- Arrow Marker preview: filled silhouette scaled by cursor distance from P1
         DrawArrowMarkerOn(m_canvasDrawings, px1, py1,
                            m_previewMouseX, m_previewMouseY,
                            previewColor, false, true, false);
        }
      else if(m_previewToolType == TOOL_NOTE)
        {
         //--- Note preview: razor-sharp connector line from P1 (anchor) to cursor + handle at P1
         color fgCol = (color)ChartGetInteger(0, CHART_COLOR_FOREGROUND);
         uint  fgArgb = ColorToARGB(fgCol, 255);
         //--- Draw the connector line in chart foreground color
         DrawNoteConnectorLine(m_canvasDrawings, (double)px1, (double)py1,
                                (double)m_previewMouseX, (double)m_previewMouseY,
                                fgArgb);
         //--- Selected-style handle at P1 hides the dot under it (matches committed look)
         DrawHandleOnCanvas(m_canvasDrawings, px1, py1, true, fgCol, false);
        }
      else if(m_previewToolType == TOOL_PRICE_NOTE)
        {
         //--- Price Note preview: connector + handle in DodgerBlue (matches committed style)
         uint previewArgb = ColorToARGB(previewColor, 255);
         //--- Draw the connector line in tool color
         DrawNoteConnectorLine(m_canvasDrawings, (double)px1, (double)py1,
                                (double)m_previewMouseX, (double)m_previewMouseY,
                                previewArgb);
         //--- Selected-style handle at P1 in tool color
         DrawHandleOnCanvas(m_canvasDrawings, px1, py1, true, previewColor, false);
        }
      else if(m_previewToolType == TOOL_CALLOUT)
        {
         //--- Callout preview: full committed-style silhouette sized to the "Add text" placeholder
         int coBoxL=0, coBoxT=0, coBoxR=0, coBoxB=0;
         //--- Render the callout shape with empty text and no edit state
         DrawCalloutOn(m_canvasDrawings, px1, py1,
                        m_previewMouseX, m_previewMouseY,
                        "", false, "",
                        0,
                        previewColor, false, false,
                        coBoxL, coBoxT, coBoxR, coBoxB);
         //--- Handle at P1 (shaft tip) in tool color
         DrawHandleOnCanvas(m_canvasDrawings, px1, py1, true, previewColor, false);
        }
      else if(m_previewToolType == TOOL_GANN_BOX)
        {
         //--- Gann Box preview: build the canonical 7-level default arrays for committed-style preview
         double pRatio[]; color pCol[]; int pOp[]; int pW[]; int pS[]; bool pVis[];
         const int N = 7;
         ArrayResize(pRatio,N); ArrayResize(pCol,N); ArrayResize(pOp,N);
         ArrayResize(pW,N);     ArrayResize(pS,N);   ArrayResize(pVis,N);
         //--- Canonical Gann Box default ratios and per-level colors
         const double dr[] = {0.0, 0.25, 0.382, 0.5, 0.618, 0.75, 1.0};
         const color  dc[] = {clrGray,clrOrange,clrDarkCyan,clrSeaGreen,
                                clrTeal,clrDodgerBlue,clrGray};
         //--- Populate per-level style arrays uniformly (visible, width 2, solid)
         for(int k = 0; k < N; k++)
           { pRatio[k]=dr[k]; pCol[k]=dc[k]; pOp[k]=100;
             pW[k]=2; pS[k]=0; pVis[k]=true; }
         //--- Delegate to the main draw routine with 30% fill opacity for the box interior
         DrawGannBoxOn(m_canvasDrawings, px1, py1,
                        m_previewMouseX, m_previewMouseY,
                        previewColor, false, true,
                        pRatio, pCol, pOp, pW, pS, pVis,
                        30);
        }
      else if(m_previewToolType == TOOL_FIBO_RETRACEMENT)
        {
         //--- Fibo Retracement preview: build canonical 11-level defaults matching post-commit
         double pRatio[];   color  pCol[];     int pOp[];
         int    pW[];       int    pS[];       bool pVis[];
         const int N = 11;
         ArrayResize(pRatio, N); ArrayResize(pCol, N);
         ArrayResize(pOp,    N); ArrayResize(pW,   N);
         ArrayResize(pS,     N); ArrayResize(pVis, N);
         //--- Canonical Fibo Retracement default ratios and per-level colors
         const double dr[] = {0.0, 0.236, 0.382, 0.5, 0.618, 0.786,
                               1.0, 1.618, 2.618, 3.618, 4.236};
         const color  dc[] = {clrGray,        clrCrimson,    clrOrange,
                               clrGoldenrod,   clrSeaGreen,   clrDarkCyan,
                               clrGray,        clrDodgerBlue, clrMediumOrchid,
                               clrBlueViolet,  clrCrimson};
         //--- Populate per-level style arrays uniformly (visible, width 2, solid)
         for(int k = 0; k < N; k++)
           {
            pRatio[k] = dr[k]; pCol[k]   = dc[k]; pOp[k] = 100;
            pW[k]     = 2;     pS[k]     = 0;     pVis[k] = true;
           }
         //--- Delegate to the main draw routine for pixel-perfect preview-commit match
         DrawFibRetracementOn(m_canvasDrawings, px1, py1,
                               m_previewMouseX, m_previewMouseY,
                               previewColor, false, true,
                               pRatio, pCol, pOp, pW, pS, pVis);
        }
      else if(m_previewToolType == TOOL_FIBO_TIMEZONES)
        {
         //--- Fibo TimeZones preview: build canonical Fibonacci-index defaults
         double pRatio[]; color pCol[]; int pOp[]; int pW[]; int pS[]; bool pVis[];
         const int N = 11;
         ArrayResize(pRatio,N); ArrayResize(pCol,N); ArrayResize(pOp,N);
         ArrayResize(pW,N);     ArrayResize(pS,N);   ArrayResize(pVis,N);
         //--- Canonical Fibonacci indices used as zone offsets
         const double dr[] = {0,1,2,3,5,8,13,21,34,55,89};
         //--- Populate per-level style arrays uniformly with the tool color
         for(int k = 0; k < N; k++)
           { pRatio[k]=dr[k]; pCol[k]=previewColor; pOp[k]=100;
             pW[k]=2; pS[k]=0; pVis[k]=true; }
         //--- Delegate to the main draw routine for committed-style preview
         DrawFibTimeZoneOn(m_canvasDrawings, px1, py1,
                            m_previewMouseX, m_previewMouseY,
                            previewColor, false, true,
                            pRatio, pCol, pOp, pW, pS, pVis);
        }
      else if(m_previewToolType == TOOL_FIBO_FAN)
        {
         //--- Fibo Fan preview: build canonical 7-level default ratios and colors
         double pRatio[]; color pCol[]; int pOp[]; int pW[]; int pS[]; bool pVis[];
         const int N = 7;
         ArrayResize(pRatio,N); ArrayResize(pCol,N); ArrayResize(pOp,N);
         ArrayResize(pW,N);     ArrayResize(pS,N);   ArrayResize(pVis,N);
         //--- Canonical Fibo Fan default ratios and per-level colors
         const double dr[] = {0.0, 0.25, 0.382, 0.5, 0.618, 0.75, 1.0};
         const color  dc[] = {clrGray, clrCrimson, clrOrange, clrGoldenrod,
                                clrSeaGreen, clrDarkCyan, clrGray};
         //--- Populate per-level style arrays uniformly (visible, width 2, solid)
         for(int k = 0; k < N; k++)
           { pRatio[k]=dr[k]; pCol[k]=dc[k]; pOp[k]=100;
             pW[k]=2; pS[k]=0; pVis[k]=true; }
         //--- Delegate to the main draw routine for committed-style preview
         DrawFibFanOn(m_canvasDrawings, px1, py1,
                       m_previewMouseX, m_previewMouseY,
                       previewColor, false, true,
                       pRatio, pCol, pOp, pW, pS, pVis);
        }
      else if(m_previewToolType == TOOL_FIBO_ARCS)
        {
         //--- Fibo Arcs preview: build canonical 11-level default ratios and colors
         double pRatio[]; color pCol[]; int pOp[]; int pW[]; int pS[]; bool pVis[];
         const int N = 11;
         ArrayResize(pRatio,N); ArrayResize(pCol,N); ArrayResize(pOp,N);
         ArrayResize(pW,N);     ArrayResize(pS,N);   ArrayResize(pVis,N);
         //--- Canonical Fibo Arcs default ratios and per-level colors
         const double dr[] = {0.236,0.382,0.5,0.618,0.786,1.0,1.618,2.618,3.618,4.236,4.618};
         const color  dc[] = {clrCrimson,clrOrange,clrGoldenrod,clrSeaGreen,clrDarkCyan,clrGray,
                                clrDodgerBlue,clrMediumOrchid,clrBlueViolet,clrCrimson,clrDeepPink};
         //--- Populate per-level style arrays uniformly (visible, width 2, solid)
         for(int k = 0; k < N; k++)
           { pRatio[k]=dr[k]; pCol[k]=dc[k]; pOp[k]=100;
             pW[k]=2; pS[k]=0; pVis[k]=true; }
         //--- Delegate to the main draw routine for committed-style preview
         DrawFibArcsOn(m_canvasDrawings, px1, py1,
                        m_previewMouseX, m_previewMouseY,
                        previewColor, false, true,
                        pRatio, pCol, pOp, pW, pS, pVis);
        }
      else if(m_previewToolType == TOOL_RECTANGLE)
        {
         //--- Rectangle preview: full committed style (30% fill + 2px border + 8 handles)
         DrawRectangleOn(m_canvasDrawings, px1, py1,
                          m_previewMouseX, m_previewMouseY,
                          previewColor, false, true);
        }
      else
        {
         //--- Fallback for other 2-click tools: dashed rubber-band line from P1 to cursor
         DrawRubberBand(px1, py1, m_previewMouseX, m_previewMouseY, m_previewToolType, previewColor);
        }
      //--- Resolve preview cursor's chart coordinates for any axis-label rendering
      double previewPrice; datetime previewTime; int sub;
      ChartXYToTimePrice(m_chartId, m_previewMouseX, m_previewMouseY, sub, previewTime, previewPrice);
     }

   //--- Parallel Channel: third-click preview with VERTICAL ALIGNMENT invariant preserved
   else if(m_isPreviewActive && m_toolDrawingClickCount == 2 &&
           m_previewToolType == TOOL_PARALLEL_CHANNEL)
     {
      //--- Map the committed A and B anchors to canvas pixels
      int ax=0, ay=0, bx=0, by=0;
      ChartTimePriceToXY(m_chartId, 0, m_drawPoint1Time, m_drawPoint1Price, ax, ay);
      ChartTimePriceToXY(m_chartId, 0, m_drawPoint2Time, m_drawPoint2Price, bx, by);
      //--- Compute the perpendicular offset based on cursor distance to the A-B trendline
      double offsetY = 0.0;
      if(bx != ax)
        {
         //--- Project the cursor onto the trendline by interpolating Y at cursor's X
         double t = (double)(m_previewMouseX - ax) / (double)(bx - ax);
         double trendlineY = ay + t * (by - ay);
         offsetY = (double)m_previewMouseY - trendlineY;
        }
      else
        {
         //--- Degenerate vertical trendline case: fall back to raw cursor-Y minus A-Y
         offsetY = (double)m_previewMouseY - (double)ay;
        }
      //--- Derive C and D from A, B, and the offset (vertical alignment: C.x=A.x, D.x=B.x)
      int cx_p = ax;
      int cy_p = ay + (int)MathRound(offsetY);
      int dx_p = bx;
      int dy_p = by + (int)MathRound(offsetY);
      //--- Preview color and pre-computed ARGB values
      color previewColor = clrDodgerBlue;
      uint  solidArgb    = ColorToARGB(previewColor, 255);
      uint  fillArgb     = ColorToARGB(previewColor, 77);
      uint  dashArgb     = ColorToARGB(previewColor, 204);
      int   cW_p         = m_canvasDrawings.Width();
      int   cH_p         = m_canvasDrawings.Height();
      //--- Fill the parallelogram A-B-D-C using a scanline fill
      {
         //--- Cache parallelogram corners in clockwise traversal order
         int pxs[4]; int pys[4];
         pxs[0] = ax;   pys[0] = ay;
         pxs[1] = bx;   pys[1] = by;
         pxs[2] = dx_p; pys[2] = dy_p;
         pxs[3] = cx_p; pys[3] = cy_p;
         //--- Find the Y-range of the parallelogram for the scanline loop
         int ymin = pys[0], ymax = pys[0];
         for(int k = 1; k < 4; k++) { if(pys[k] < ymin) ymin = pys[k]; if(pys[k] > ymax) ymax = pys[k]; }
         //--- Clamp to canvas bounds
         if(ymin < 0)     ymin = 0;
         if(ymax >= cH_p) ymax = cH_p - 1;
         //--- For each scanline Y, intersect with each edge and fill the spans between crossings
         for(int yy = ymin; yy <= ymax; yy++) {
            double xs[4]; int nx = 0;
            for(int e = 0; e < 4; e++) {
               //--- Test edge from corner e to corner e+1 (mod 4) for Y crossing
               int e2 = (e + 1) & 3;
               double ay_ = (double)pys[e], by_ = (double)pys[e2];
               if((ay_ > yy) == (by_ > yy)) continue;
               //--- Interpolate X at the scanline Y
               double ax_ = (double)pxs[e], bx_ = (double)pxs[e2];
               double t_  = ((double)yy - ay_) / (by_ - ay_);
               xs[nx++] = ax_ + t_ * (bx_ - ax_);
            }
            //--- Need at least 2 X crossings to define a fill span
            if(nx < 2) continue;
            //--- Sort the X crossings using a small bubble sort (max 4 elements)
            for(int a = 0; a < nx - 1; a++)
               for(int b = a + 1; b < nx; b++)
                  if(xs[b] < xs[a]) { double tmp = xs[a]; xs[a] = xs[b]; xs[b] = tmp; }
            //--- Fill spans between consecutive crossing pairs
            for(int p = 0; p + 1 < nx; p += 2) {
               int xL = (int)MathCeil(xs[p]);
               int xR = (int)MathFloor(xs[p + 1]);
               //--- Clamp the span endpoints to canvas bounds
               if(xL < 0)     xL = 0;
               if(xR >= cW_p) xR = cW_p - 1;
               //--- Apply alpha-blended fill pixel by pixel for translucent overlay
               for(int xx = xL; xx <= xR; xx++)
                  BlendPixelSet(m_canvasDrawings, xx, yy, fillArgb);
            }
         }
      }
      //--- Solid trendline (committed A -> B)
      DrawThickLine(m_canvasDrawings, ax, ay, bx, by, 2, solidArgb);
      //--- Solid parallel line (live C -> D, sharing A-B's time range)
      DrawThickLine(m_canvasDrawings, cx_p, cy_p, dx_p, dy_p, 2, solidArgb);
      //--- 1px dashed center line matching DrawParallelChannelOn's mid-line render path
      {
         //--- Center line endpoints (midpoint of A-C on left, midpoint of B-D on right)
         int d1x = ax,                    d1y = (ay + cy_p) / 2;
         int d2x = bx,                    d2y = (by + dy_p) / 2;
         //--- Build the dashed line pattern for style=1 (dashed), width=1
         int mpat[];
         const int mn = BuildLineStylePattern(1, 1, mpat);
         if(mn > 0)
            WidgetDashedLineAA(m_canvasDrawings, d1x, d1y, d2x, d2y, 1, dashArgb, mpat);
      }
      //--- Four preview handles at the parallelogram corners (deselected style)
      DrawHandleOnCanvas(m_canvasDrawings, ax,   ay,   false, previewColor);
      DrawHandleOnCanvas(m_canvasDrawings, bx,   by,   false, previewColor);
      DrawHandleOnCanvas(m_canvasDrawings, cx_p, cy_p, false, previewColor);
      DrawHandleOnCanvas(m_canvasDrawings, dx_p, dy_p, false, previewColor);
     }
   //--- Pitchforks: third-click preview for Andrews, Schiff, and Modified Schiff variants
   else if(m_isPreviewActive && m_toolDrawingClickCount == 2 &&
           (m_previewToolType == TOOL_PITCHFORK ||
            m_previewToolType == TOOL_SCHIFF_PITCHFORK ||
            m_previewToolType == TOOL_MOD_SCHIFF))
     {
      //--- Resolve the committed P1 and P2 in canvas coords (P3 = live cursor)
      int p1x=0, p1y=0, p2x=0, p2y=0;
      ChartTimePriceToXY(m_chartId, 0, m_drawPoint1Time, m_drawPoint1Price, p1x, p1y);
      ChartTimePriceToXY(m_chartId, 0, m_drawPoint2Time, m_drawPoint2Price, p2x, p2y);
      int p3x = m_previewMouseX;
      int p3y = m_previewMouseY;
      //--- Dispatch to the correct pitchfork variant with canonical default styling
      if(m_previewToolType == TOOL_PITCHFORK)
         DrawAndrewsPitchforkOn(m_canvasDrawings,
                                 p1x, p1y, p2x, p2y, p3x, p3y,
                                 clrDodgerBlue, false, true,
                                 true, clrCrimson,        2, 0,
                                 true, clrDodgerBlue,     2, 0,
                                 true, clrMediumSeaGreen, 2, 0,
                                 100, 30);
      //--- Schiff variant: median originates at midpoint of P1-P2 chord
      else if(m_previewToolType == TOOL_SCHIFF_PITCHFORK)
         DrawSchiffPitchforkOn(m_canvasDrawings,
                                p1x, p1y, p2x, p2y, p3x, p3y,
                                clrDodgerBlue, false, true,
                                true, clrCrimson,        2, 0,
                                true, clrDodgerBlue,     2, 0,
                                true, clrMediumSeaGreen, 2, 0,
                                100, 30);
      //--- Modified Schiff: variant where median origin uses P1.x and chord-midpoint Y
      else
         DrawModSchiffPitchforkOn(m_canvasDrawings,
                                   p1x, p1y, p2x, p2y, p3x, p3y,
                                   clrDodgerBlue, false, true,
                                   true, clrCrimson,        2, 0,
                                   true, clrDodgerBlue,     2, 0,
                                   true, clrMediumSeaGreen, 2, 0,
                                   100, 30);
     }
   //--- Generic 3-click tools (Fibo Expansion / Channel, Triangle, Ellipse, Rotated Rect, Arc, Curve)
   else if(m_isPreviewActive && m_toolDrawingClickCount == 2 &&
           (m_previewToolType == TOOL_FIBO_EXPANSION ||
            m_previewToolType == TOOL_FIBO_CHANNEL   ||
            m_previewToolType == TOOL_TRIANGLE       ||
            m_previewToolType == TOOL_ELLIPSE        ||
            m_previewToolType == TOOL_ROTATED_RECTANGLE ||
            m_previewToolType == TOOL_ARC            ||
            m_previewToolType == TOOL_CURVE))
     {
      //--- Resolve the committed P1 and P2 in canvas coords (P3 = live cursor)
      int p1x=0, p1y=0, p2x=0, p2y=0;
      ChartTimePriceToXY(m_chartId, 0, m_drawPoint1Time, m_drawPoint1Price, p1x, p1y);
      ChartTimePriceToXY(m_chartId, 0, m_drawPoint2Time, m_drawPoint2Price, p2x, p2y);
      int p3x = m_previewMouseX;
      int p3y = m_previewMouseY;
      color previewColor = GetToolDefaultColor(m_previewToolType);
      if(m_previewToolType == TOOL_FIBO_EXPANSION)
        {
         //--- Fibo Expansion preview: build canonical 11-level default ratios and colors
         double pRatio[]; color pCol[]; int pOp[]; int pW[]; int pS[]; bool pVis[];
         const int N = 11;
         ArrayResize(pRatio,N); ArrayResize(pCol,N); ArrayResize(pOp,N);
         ArrayResize(pW,N);     ArrayResize(pS,N);   ArrayResize(pVis,N);
         //--- Canonical Fibo Expansion default ratios and per-level colors
         const double dr[] = {0.0,0.236,0.382,0.5,0.618,0.786,1.0,1.618,2.618,3.618,4.236};
         const color  dc[] = {clrGray,clrCrimson,clrOrange,clrGoldenrod,clrSeaGreen,clrDarkCyan,
                                clrGray,clrDodgerBlue,clrMediumOrchid,clrBlueViolet,clrCrimson};
         //--- Populate per-level style arrays uniformly (visible, width 2, solid)
         for(int k = 0; k < N; k++)
           { pRatio[k]=dr[k]; pCol[k]=dc[k]; pOp[k]=100;
             pW[k]=2; pS[k]=0; pVis[k]=true; }
         //--- Delegate to the main draw routine for committed-style preview
         DrawFibExpansionOn(m_canvasDrawings,
                             p1x, p1y, p2x, p2y, p3x, p3y,
                             previewColor, false, true,
                             pRatio, pCol, pOp, pW, pS, pVis);
        }
      else if(m_previewToolType == TOOL_FIBO_CHANNEL)
        {
         //--- Fibo Channel preview: build canonical 10-level default ratios and colors
         double pRatio[]; color pCol[]; int pOp[]; int pW[]; int pS[]; bool pVis[];
         const int N = 10;
         ArrayResize(pRatio,N); ArrayResize(pCol,N); ArrayResize(pOp,N);
         ArrayResize(pW,N);     ArrayResize(pS,N);   ArrayResize(pVis,N);
         //--- Canonical Fibo Channel default ratios and per-level colors
         const double dr[] = {0.0,0.382,0.5,0.618,0.786,1.0,1.618,2.618,3.618,4.236};
         const color  dc[] = {clrGray,clrOrange,clrGoldenrod,clrSeaGreen,clrDarkCyan,clrGray,
                                clrDodgerBlue,clrMediumOrchid,clrBlueViolet,clrCrimson};
         //--- Populate per-level style arrays uniformly (visible, width 2, solid)
         for(int k = 0; k < N; k++)
           { pRatio[k]=dr[k]; pCol[k]=dc[k]; pOp[k]=100;
             pW[k]=2; pS[k]=0; pVis[k]=true; }
         //--- Delegate to the main draw routine for committed-style preview
         DrawFibChannelOn(m_canvasDrawings,
                           p1x, p1y, p2x, p2y, p3x, p3y,
                           previewColor, false, true,
                           pRatio, pCol, pOp, pW, pS, pVis);
        }
      //--- Triangle preview: green committed-style shape with 30% fill + 3 vertex handles
      else if(m_previewToolType == TOOL_TRIANGLE)
         DrawTriangleOn(m_canvasDrawings,
                         p1x, p1y, p2x, p2y, p3x, p3y,
                         previewColor, false, true);
      //--- Rotated Ellipse preview: red rotated ellipse with P3 as minor-axis defining point
      else if(m_previewToolType == TOOL_ELLIPSE)
         DrawEllipseOn(m_canvasDrawings,
                        p1x, p1y, p2x, p2y, p3x, p3y,
                        previewColor, false, true);
      //--- Arc preview: pink circular arc through P1/P3/P2 with the enclosed region filled
      else if(m_previewToolType == TOOL_ARC)
         DrawArcOn(m_canvasDrawings,
                    p1x, p1y, p2x, p2y, p3x, p3y,
                    previewColor, false, true);
      //--- Curve preview: dodger-blue quadratic Bezier through P1/P3/P2 (no fill)
      else if(m_previewToolType == TOOL_CURVE)
         DrawCurveOn(m_canvasDrawings,
                      p1x, p1y, p2x, p2y, p3x, p3y,
                      previewColor, false, true);
      else
        {
         //--- Rotated Rectangle preview: apply baseline -> midline shift to match committed storage
         double dxB_p = (double)(p2x - p1x);
         double dyB_p = (double)(p2y - p1y);
         double lenB_p = MathSqrt(dxB_p * dxB_p + dyB_p * dyB_p);
         //--- Defaults: P1/P2 unchanged if the baseline is degenerate
         int p1x_m = p1x, p1y_m = p1y, p2x_m = p2x, p2y_m = p2y;
         if(lenB_p >= 2.0)
           {
            //--- Build baseline-unit and perpendicular vectors for the shift computation
            double ux_p = dxB_p / lenB_p;
            double uy_p = dyB_p / lenB_p;
            double vx_p = -uy_p;
            double vy_p =  ux_p;
            //--- Compute cursor's signed perpendicular distance to the baseline
            double perpSide_p = ((double)p3x - (double)p1x) * vx_p + ((double)p3y - (double)p1y) * vy_p;
            //--- Shift = half the perpendicular distance to move the baseline to the midline
            double shift_p = perpSide_p * 0.5;
            //--- Apply the shift along the perpendicular direction to P1 and P2
            p1x_m = (int)MathRound((double)p1x + shift_p * vx_p);
            p1y_m = (int)MathRound((double)p1y + shift_p * vy_p);
            p2x_m = (int)MathRound((double)p2x + shift_p * vx_p);
            p2y_m = (int)MathRound((double)p2y + shift_p * vy_p);
           }
         //--- Delegate to the main draw routine with the shifted midline endpoints
         DrawRotatedRectangleOn(m_canvasDrawings,
                                 p1x_m, p1y_m, p2x_m, p2y_m, p3x, p3y,
                                 previewColor, false, true);
        }
     }
   //--- Final triple call: pills onto canvas, atomic canvas update, then per-object axis labels
   RedrawPermanentAxisLabels();
   m_canvasDrawings.Update();
   UpdateObjLabels();
  }

#endif // TOOLS_PALETTE_ENGINE_RENDER_MQH
//+------------------------------------------------------------------+