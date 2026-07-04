//+------------------------------------------------------------------+
//|                                     ToolsPalette_Annotations.mqh |
//|                                            Copyright 2026, Om J. |
//|                                               https://t.me/HZFXI |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Om J."
#property link "https://t.me/HZFXI"
#property version "1.00"
#property strict

//--- Guard against multiple inclusion of this header
#ifndef TOOLS_PALETTE_ANNOTATIONS_MQH
#define TOOLS_PALETTE_ANNOTATIONS_MQH

//--- Pull in the base shape tools class that this class extends
#include "ToolsPalette_Shapes.mqh"

//+------------------------------------------------------------------+
//| Callout shaft attach case enum                                   |
//+------------------------------------------------------------------+
enum ENUM_CALLOUT_ATTACH
  {
   CA_E,    // East: right edge midpoint
   CA_NE,   // North-east corner
   CA_N,    // North: top edge midpoint
   CA_NW,   // North-west corner
   CA_W,    // West: left edge midpoint
   CA_SW,   // South-west corner
   CA_S,    // South: bottom edge midpoint
   CA_SE    // South-east corner
  };

//+------------------------------------------------------------------+
//| Arrow Up/Down fixed pixel parameters                             |
//+------------------------------------------------------------------+
const double ARROW_UPDOWN_TOTAL_H  = 28.0; // Total arrow length apex-to-base
const double ARROW_UPDOWN_HEAD_LEN = 13.0; // Head triangle height
const double ARROW_UPDOWN_SHAFT_HW = 4.0;  // Half-width of the shaft
const double ARROW_UPDOWN_HEAD_HW  = 9.0;  // Half-width of the wings

//+------------------------------------------------------------------+
//| CAnnotationTools class declaration                               |
//+------------------------------------------------------------------+
class CAnnotationTools : public CShapeTools
  {
public:
   //--- Draw a Text annotation box centered at (ax, ay)
   void   DrawTextAnnotationOn(CCanvas &canvas,
                                int ax, int ay,
                                const string committedText,
                                bool isEditing, const string editBuffer,
                                int caretPos,
                                color objColor, bool selected, bool hovered,
                                int &outL, int &outT, int &outR, int &outB,
                                int fontSize = 12, bool bold = false,
                                int vAlign = 0, int hAlign = 0,
                                int textOpacityPct = 100);
   //--- Hit-test for a Text annotation box
   bool   HitTestTextAnnotation(int mx, int my,
                                 int ax, int ay,
                                 const string committedText,
                                 bool isEditing, const string editBuffer,
                                 int fontSize = 12, bool bold = false);
   //--- Compute the Text annotation bounding box
   void   ComputeTextAnnotationBox(int ax, int ay,
                                    const string committedText,
                                    bool isEditing, const string editBuffer,
                                    int &outL, int &outT, int &outR, int &outB,
                                    int fontSize = 12, bool bold = false);
   //--- Draw a 2-click annotation Arrow with filled triangular head
   void   DrawArrowOn(CCanvas &canvas,
                       int x1, int y1, int x2, int y2,
                       color objColor, bool selected, bool hovered,
                       int lineWidth = 2, int lineOpacity = 100);
   //--- Hit-test for an Arrow shaft or either wing
   bool   HitTestArrow(int mx, int my, int x1, int y1, int x2, int y2, int threshold);
   //--- Draw an Arrow Marker (6-vertex filled dart silhouette)
   void   DrawArrowMarkerOn(CCanvas &canvas,
                             int x1, int y1, int x2, int y2,
                             color objColor, bool selected, bool hovered,
                             bool outlineOnly = false,
                             int lineOpacity = 100);
   //--- Hit-test for an Arrow Marker silhouette
   bool   HitTestArrowMarker(int mx, int my, int x1, int y1, int x2, int y2, int threshold);
   //--- Draw an Arrow Up/Down single-click fixed-size marker
   void   DrawArrowUpDownOn(CCanvas &canvas,
                             int ax, int ay,
                             bool pointsUp,
                             color objColor, bool selected, bool hovered,
                             bool outlineOnly = false,
                             int lineOpacity = 100);
   //--- Hit-test for an Arrow Up/Down marker
   bool   HitTestArrowUpDown(int mx, int my, int ax, int ay, bool pointsUp, int threshold);
   //--- Compute the 7 silhouette vertices for an Arrow Up/Down marker
   void   ComputeArrowUpDownVerts(int ax, int ay, bool pointsUp,
                                   double &vx[], double &vy[]);
   //--- Draw a Note (anchor P1 plus rectangle at P2 with connector line and shadow)
   void   DrawNoteOn(CCanvas &canvas,
                      int p1x, int p1y, int p2x, int p2y,
                      const string committedText,
                      bool isEditing, const string editBuffer,
                      int caretPos,
                      color objColor, bool selected, bool hovered,
                      int &outBoxL, int &outBoxT, int &outBoxR, int &outBoxB,
                      int lineOpacity = 100, int fontSize = 12,
                      bool bold = false,
                      color fillColor = clrNONE, int fillOpacity = 100,
                      color textColor = clrNONE, int textOpacity = 100);
   //--- Hit-test for a Note (rect, connector line, or anchor dot)
   bool   HitTestNote(int mx, int my,
                       int p1x, int p1y, int p2x, int p2y,
                       const string committedText,
                       bool isEditing, const string editBuffer,
                       int fontSize = 12);
   //--- Compute the Note rectangle bounds with edge-midpoint attach to P2
   void   ComputeNoteBox(int p1x, int p1y, int p2x, int p2y,
                          const string committedText,
                          bool isEditing, const string editBuffer,
                          int &outL, int &outT, int &outR, int &outB,
                          int fontSize = 12);
   //--- Draw a Price Note (Note variant showing formatted anchor price)
   void   DrawPriceNoteOn(CCanvas &canvas,
                           int p1x, int p1y, int p2x, int p2y,
                           double anchorPrice,
                           color objColor, bool selected, bool hovered,
                           int &outBoxL, int &outBoxT, int &outBoxR, int &outBoxB,
                           int lineOpacity = 100, int fontSize = 10,
                           color fillColor = clrNONE, int fillOpacity = 100,
                           color textColor = clrNONE, int textOpacity = 100);
   //--- Hit-test for a Price Note
   bool   HitTestPriceNote(int mx, int my,
                            int p1x, int p1y, int p2x, int p2y,
                            double anchorPrice,
                            int fontSize = 10);
   //--- Compute the Callout rectangle bounds plus shaft attach points and case
   void   ComputeCalloutGeometry(int p1x, int p1y, int p2x, int p2y,
                                  const string committedText,
                                  bool isEditing, const string editBuffer,
                                  int &outBoxL, int &outBoxT,
                                  int &outBoxR, int &outBoxB,
                                  int &outA1x, int &outA1y,
                                  int &outA2x, int &outA2y,
                                  ENUM_CALLOUT_ATTACH &outCase,
                                  int fontSize = 12);
   //--- Draw a Callout (rounded rect plus shaft to P1 with continuous border and fill)
   void   DrawCalloutOn(CCanvas &canvas,
                         int p1x, int p1y, int p2x, int p2y,
                         const string committedText,
                         bool isEditing, const string editBuffer,
                         int caretPos,
                         color objColor, bool selected, bool hovered,
                         int &outBoxL, int &outBoxT, int &outBoxR, int &outBoxB,
                         int lineOpacity = 100, int fontSize = 12,
                         bool bold = false,
                         color fillColor = clrNONE, int fillOpacity = 100,
                         color textColor = clrNONE, int textOpacity = 100);
   //--- Hit-test for a Callout (rect interior, shaft triangle, or P1 handle)
   bool   HitTestCallout(int mx, int my,
                          int p1x, int p1y, int p2x, int p2y,
                          const string text,
                          bool isEditing, const string editBuffer,
                          int fontSize = 12);
   //--- Draw a Comment (1-click rectangle with mixed corner radii; P1 = bottom-left)
   void   DrawCommentOn(CCanvas &canvas,
                         int p1x, int p1y,
                         const string committedText,
                         bool isEditing, const string editBuffer,
                         int caretPos,
                         color objColor, bool selected, bool hovered,
                         int &outBoxL, int &outBoxT, int &outBoxR, int &outBoxB,
                         int lineOpacity = 100, int fontSize = 12,
                         bool bold = false,
                         color fillColor = clrNONE, int fillOpacity = 100,
                         color textColor = clrNONE, int textOpacity = 100);
   //--- Compute the Comment rectangle bounds
   void   ComputeCommentBox(int p1x, int p1y,
                             const string committedText,
                             bool isEditing, const string editBuffer,
                             int &outL, int &outT, int &outR, int &outB,
                             int fontSize = 12);
   //--- Hit-test for a Comment rectangle
   bool   HitTestComment(int mx, int my, int p1x, int p1y,
                          const string text,
                          bool isEditing, const string editBuffer,
                          int fontSize = 12);
   //--- Compute the 6 silhouette vertices for an Arrow Marker dart shape
   void   ComputeArrowMarkerVerts(int x1, int y1, int x2, int y2,
                                   double &vx[], double &vy[]);
  };

//+------------------------------------------------------------------+
//| Lighten a color by adding delta to each RGB channel, clamped     |
//+------------------------------------------------------------------+
color BrightenColor(color base, int delta)
  {
   //--- Extract per-channel R, G, B values from the source color
   int r = (int)((base >>  0) & 0xFF);
   int g = (int)((base >>  8) & 0xFF);
   int b = (int)((base >> 16) & 0xFF);
   //--- Add delta and clamp the red channel into [0, 255]
   r += delta; if(r > 255) r = 255; if(r < 0) r = 0;
   //--- Add delta and clamp the green channel into [0, 255]
   g += delta; if(g > 255) g = 255; if(g < 0) g = 0;
   //--- Add delta and clamp the blue channel into [0, 255]
   b += delta; if(b > 255) b = 255; if(b < 0) b = 0;
   //--- Repack the channels into the BGR color encoding MQL5 uses
   return (color)((b << 16) | (g << 8) | r);
  }

//+------------------------------------------------------------------+
//| Alpha-composite a source ARGB pixel over the canvas destination  |
//+------------------------------------------------------------------+
void BlendPxNote(CCanvas &canvas, int x, int y, uint src)
  {
   //--- Reject pixels that fall outside the canvas bounds
   if(x < 0 || y < 0 || x >= canvas.Width() || y >= canvas.Height()) return;
   //--- Extract source alpha and skip fully transparent pixels
   uchar sA = (uchar)((src >> 24) & 0xFF);
   if(sA == 0) return;
   //--- Fast path: fully opaque source overwrites the destination directly
   if(sA == 255) { canvas.PixelSet(x, y, src); return; }
   //--- Read the destination pixel for source-over compositing
   uint dst = canvas.PixelGet(x, y);
   uchar dA = (uchar)((dst >> 24) & 0xFF);
   //--- Normalize alpha values into the [0, 1] range
   double sAf = sA / 255.0;
   double dAf = dA / 255.0;
   //--- Compute the combined output alpha via Porter-Duff source-over
   double oAf = sAf + dAf * (1.0 - sAf);
   if(oAf <= 0.0) return;
   //--- Unpack RGB channels of source and destination into [0, 1]
   double sR = ((src >> 16) & 0xFF) / 255.0;
   double sG = ((src >>  8) & 0xFF) / 255.0;
   double sB = ( src        & 0xFF) / 255.0;
   double dR = ((dst >> 16) & 0xFF) / 255.0;
   double dG = ((dst >>  8) & 0xFF) / 255.0;
   double dB = ( dst        & 0xFF) / 255.0;
   //--- Compute the blended output channels and clamp to bytes
   uchar oA = (uchar)(oAf * 255.0 + 0.5);
   uchar oR = (uchar)((sR * sAf + dR * dAf * (1.0 - sAf)) / oAf * 255.0 + 0.5);
   uchar oG = (uchar)((sG * sAf + dG * dAf * (1.0 - sAf)) / oAf * 255.0 + 0.5);
   uchar oB = (uchar)((sB * sAf + dB * dAf * (1.0 - sAf)) / oAf * 255.0 + 0.5);
   //--- Pack the final ARGB pixel and write it back to the canvas
   canvas.PixelSet(x, y, ((uint)oA << 24) | ((uint)oR << 16) | ((uint)oG << 8) | (uint)oB);
  }

//+------------------------------------------------------------------+
//| Compute wrapped text layout: visual lines plus buffer offsets    |
//+------------------------------------------------------------------+
void ComputeWrappedLayout(const string text,
                           const string fontName, int fontPt,
                           int wrapWidth,
                           string &outVisualLines[],
                           int &outBufferOffsets[],
                           int &outMaxW, int &outBlockH, int &outLineH)
  {
   //--- Use 4x supersampling for sub-pixel text measurement accuracy
   const int SS = 4;
   //--- Set the supersampled font for measurement queries
   TextSetFont(fontName, -(fontPt * SS * 10));
   //--- Measure a reference glyph pair to derive the single-line height
   uint refWu = 0, refHu = 0;
   TextGetSize("Mg", refWu, refHu);
   //--- Convert the HR line height down to screen units with floor of 1
   int lineH = ((int)refHu) / SS;
   if(lineH < 1) lineH = 1;
   //--- Reset output arrays and dimension counters
   ArrayResize(outVisualLines, 0);
   ArrayResize(outBufferOffsets, 0);
   outMaxW   = 0;
   outBlockH = 0;
   outLineH  = lineH;
   int  textLen = StringLen(text);
   //--- Walk the buffer splitting on newline characters to enumerate buffer-lines
   int bufLineStart = 0;
   for(int i = 0; i <= textLen; i++)
     {
      //--- Detect the end of the buffer and embedded newline characters
      bool atEnd = (i == textLen);
      bool atNL  = (!atEnd && StringGetCharacter(text, i) == '\n');
      if(!atEnd && !atNL) continue;
      //--- Extract this buffer line substring
      int bufLineLen = i - bufLineStart;
      string bufLine = StringSubstr(text, bufLineStart, bufLineLen);
      //--- Word-wrap this buffer line via a local-offset walk
      int localStart = 0;
      while(localStart <= bufLineLen)
        {
         //--- Extract the remaining un-emitted substring for this buffer line
         int remainLen = bufLineLen - localStart;
         string remain = StringSubstr(bufLine, localStart, remainLen);
         //--- No-wrap path or empty remainder: emit one visual line and stop
         if(wrapWidth <= 0 || remainLen == 0)
           {
            int sz = ArraySize(outVisualLines);
            ArrayResize(outVisualLines,   sz + 1);
            ArrayResize(outBufferOffsets, sz + 1);
            outVisualLines[sz]   = remain;
            outBufferOffsets[sz] = bufLineStart + localStart;
            //--- Measure non-empty remainders to update the widest-line tracker
            if(remainLen > 0)
              {
               uint wU = 0, hU = 0;
               TextGetSize(remain, wU, hU);
               int w = ((int)wU) / SS;
               if(w > outMaxW) outMaxW = w;
              }
            break;
           }
         //--- Measure the remainder and emit unchanged if it fits the wrap budget
         uint wholeWu = 0, wholeHu = 0;
         TextGetSize(remain, wholeWu, wholeHu);
         int wholeW = ((int)wholeWu) / SS;
         if(wholeW <= wrapWidth)
           {
            int sz = ArraySize(outVisualLines);
            ArrayResize(outVisualLines,   sz + 1);
            ArrayResize(outBufferOffsets, sz + 1);
            outVisualLines[sz]   = remain;
            outBufferOffsets[sz] = bufLineStart + localStart;
            if(wholeW > outMaxW) outMaxW = wholeW;
            break;
           }
         //--- Binary-search the largest prefix length that fits the wrap budget
         int lo = 1, hi = remainLen, fitK = 1;
         while(lo <= hi)
           {
            //--- Probe the mid prefix length and measure it
            int mid = (lo + hi) / 2;
            string prefix = StringSubstr(remain, 0, mid);
            uint pwU = 0, phU = 0;
            TextGetSize(prefix, pwU, phU);
            int pw = ((int)pwU) / SS;
            //--- Narrow the search range based on the measurement
            if(pw <= wrapWidth) { fitK = mid; lo = mid + 1; }
            else                { hi = mid - 1; }
           }
         //--- Scan backward from fitK looking for a space to break on (word-wrap)
         int breakAt = fitK;
         bool foundSpace = false;
         for(int k = fitK; k >= 1; k--)
           {
            ushort ch = StringGetCharacter(remain, k - 1);
            if(ch == ' ')
              {
               breakAt = k - 1;
               foundSpace = true;
               break;
              }
           }
         //--- Choose the visual line content and how much input was consumed
         int consume; string visualLine;
         if(foundSpace)
           {
            //--- Break at the space and consume one extra char for the space itself
            visualLine = StringSubstr(remain, 0, breakAt);
            consume    = breakAt + 1;
           }
         else
           {
            //--- No space found: hard-break at the binary-search fit point
            visualLine = StringSubstr(remain, 0, fitK);
            consume    = fitK;
           }
         //--- Append the visual line and its starting buffer offset
         int sz = ArraySize(outVisualLines);
         ArrayResize(outVisualLines,   sz + 1);
         ArrayResize(outBufferOffsets, sz + 1);
         outVisualLines[sz]   = visualLine;
         outBufferOffsets[sz] = bufLineStart + localStart;
         //--- Update the widest visual line tracker
         if(StringLen(visualLine) > 0)
           {
            uint vwU = 0, vhU = 0;
            TextGetSize(visualLine, vwU, vhU);
            int vw = ((int)vwU) / SS;
            if(vw > outMaxW) outMaxW = vw;
           }
         //--- Advance the local cursor past the consumed characters
         localStart += consume;
        }
      //--- Advance the buffer line start past the newline character
      bufLineStart = i + 1;
     }
   //--- Guarantee at least one visual line so callers never get zero-height blocks
   if(ArraySize(outVisualLines) == 0)
     {
      ArrayResize(outVisualLines,   1);
      ArrayResize(outBufferOffsets, 1);
      outVisualLines[0]   = "";
      outBufferOffsets[0] = 0;
     }
   //--- Compute the total block height as visual line count times line height
   outBlockH = lineH * ArraySize(outVisualLines);
  }

//+------------------------------------------------------------------+
//| Measure a text block's overall dimensions                        |
//+------------------------------------------------------------------+
void MeasureTextBlock(const string text,
                       const string fontName, int fontPt,
                       int &outW, int &outH, int &outLineH,
                       int wrapWidth = 0)
  {
   //--- Delegate to ComputeWrappedLayout and discard the line content arrays
   string visLines[];
   int    bufOffsets[];
   ComputeWrappedLayout(text, fontName, fontPt, wrapWidth,
                         visLines, bufOffsets, outW, outH, outLineH);
  }

//+------------------------------------------------------------------+
//| Render multi-line editable text with caret at 4x SSAA            |
//+------------------------------------------------------------------+
void RenderEditableTextBlockAA(CCanvas &canvas,
                                const string text,
                                bool isEditing,
                                int caretPos,
                                int textL, int textT,
                                int clipL, int clipT, int clipR, int clipB,
                                const string fontName, int fontPt,
                                color textColor,
                                color cursorColor,
                                int wrapWidth = 0,
                                bool bold = false,
                                int vAlign = 0,
                                int hAlign = 0,
                                int textOpacityPct = 100)
  {
   //--- Use 4x supersampling for sub-pixel glyph rendering accuracy
   const int SS = 4;
   //--- Compute the wrapped visual layout for this text block
   string visLines[];
   int    bufOffsets[];
   int    maxW = 0, blockH = 0, lineH = 0;
   ComputeWrappedLayout(text, fontName, fontPt, wrapWidth,
                         visLines, bufOffsets, maxW, blockH, lineH);
   int nVisLines = ArraySize(visLines);
   if(nVisLines == 0) return;
   //--- Toggle the cursor blink every 500ms via microsecond clock
   bool cursorOn = ((GetMicrosecondCount() / 500000) % 2) == 0;
   //--- Map the absolute caret buffer position to visual (line, column)
   int caretVisLine = 0, caretVisCol = 0;
   if(isEditing)
     {
      //--- Clamp the caret target to the buffer length
      int target = caretPos;
      int len    = StringLen(text);
      if(target < 0)   target = 0;
      if(target > len) target = len;
      //--- Find the last visual line whose buffer offset is at or before the target
      caretVisLine = 0;
      for(int vl = 0; vl < nVisLines; vl++)
        {
         if(bufOffsets[vl] <= target) caretVisLine = vl;
         else break;
        }
      //--- Compute the visual column within that line and clamp to its length
      caretVisCol = target - bufOffsets[caretVisLine];
      int vlLen = StringLen(visLines[caretVisLine]);
      if(caretVisCol < 0)     caretVisCol = 0;
      if(caretVisCol > vlLen) caretVisCol = vlLen;
     }
   //--- Extract per-channel text and cursor colors into byte components
   uchar txR = (uchar)((textColor)       & 0xFF);
   uchar txG = (uchar)((textColor >> 8)  & 0xFF);
   uchar txB = (uchar)((textColor >> 16) & 0xFF);
   uchar curR = (uchar)((cursorColor)       & 0xFF);
   uchar curG = (uchar)((cursorColor >> 8)  & 0xFF);
   uchar curB = (uchar)((cursorColor >> 16) & 0xFF);
   //--- Set the supersampled font with bold flag if requested
   const uint fontFlags = bold ? (uint)700 : (uint)0;
   TextSetFont(fontName, -(fontPt * SS * 10), fontFlags);
   //--- Compute vertical alignment offset within the clip rectangle
   const int availH = clipB - clipT;
   int vAdjust = 0;
   if(vAlign == 1)      vAdjust = (availH - blockH) / 2;
   else if(vAlign == 2) vAdjust =  availH - blockH;
   if(vAdjust < 0) vAdjust = 0;
   //--- Compute the overall block width for per-line horizontal alignment
   const int blockW = maxW / SS;
   const int availW = clipR - clipL;
   //--- Convert text opacity percent to an 8-bit base alpha for glyph blending
   int textAlphaInt = (int)((double)textOpacityPct * 255.0 / 100.0 + 0.5);
   if(textAlphaInt < 0)   textAlphaInt = 0;
   if(textAlphaInt > 255) textAlphaInt = 255;
   const uchar textAlphaByte = (uchar)textAlphaInt;
   //--- Walk every visual line and render its glyphs plus optional caret
   for(int vl = 0; vl < nVisLines; vl++)
     {
      //--- Extract this visual line and compute its baseline Y
      string lineStr = visLines[vl];
      int lineY = textT + vAdjust + vl * lineH;
      //--- Reset the per-line horizontal offset and measured width
      int lineXOff = 0;
      int lineWidthScreen = 0;
      //--- Measure non-empty lines to know their pixel width on screen
      if(StringLen(lineStr) > 0)
        {
         uint hrTwU = 0, hrThU = 0;
         TextGetSize(lineStr, hrTwU, hrThU);
         int hrTw = (int)hrTwU, hrTh = (int)hrThU;
         if(hrTw > 0 && hrTh > 0)
           {
            int tw = hrTw / SS;
            int th = hrTh / SS;
            lineWidthScreen = tw;
           }
        }
      //--- Apply per-line horizontal alignment within the block width
      if(hAlign == 1)      lineXOff = (blockW - lineWidthScreen) / 2;
      else if(hAlign == 2) lineXOff =  blockW - lineWidthScreen;
      if(lineXOff < 0) lineXOff = 0;
      //--- Render glyphs into the canvas for non-empty lines
      if(StringLen(lineStr) > 0)
        {
         //--- Re-measure the line at HR resolution for glyph rasterization
         uint hrTwU = 0, hrThU = 0;
         TextGetSize(lineStr, hrTwU, hrThU);
         int hrTw = (int)hrTwU, hrTh = (int)hrThU;
         if(hrTw > 0 && hrTh > 0)
           {
            int tw = hrTw / SS;
            int th = hrTh / SS;
            if(tw > 0 && th > 0)
              {
               //--- Allocate two same-size buffers for delta-based alpha recovery
               uint bufB[]; ArrayResize(bufB, hrTw * hrTh);
               uint bufW[]; ArrayResize(bufW, hrTw * hrTh);
               ArrayFill(bufB, 0, hrTw * hrTh, 0xFF000000);
               ArrayFill(bufW, 0, hrTw * hrTh, 0xFFFFFFFF);
               //--- Render the text into each buffer to extract alpha from the channel delta
               TextOut(lineStr, 0, 0, TA_LEFT | TA_TOP, bufB, hrTw, hrTh,
                       ColorToARGB(clrBlack, 255), COLOR_FORMAT_ARGB_NORMALIZE);
               TextOut(lineStr, 0, 0, TA_LEFT | TA_TOP, bufW, hrTw, hrTh,
                       ColorToARGB(clrBlack, 255), COLOR_FORMAT_ARGB_NORMALIZE);
               //--- Extract per-pixel alpha from the buffer difference
               uchar hrA[]; ArrayResize(hrA, hrTw * hrTh);
               for(int p = 0; p < hrTw * hrTh; p++)
                 {
                  //--- Compute channel deltas and convert into alpha coverage
                  int dR = (int)((bufW[p] >> 16) & 0xFF) - (int)((bufB[p] >> 16) & 0xFF);
                  int dG = (int)((bufW[p] >>  8) & 0xFF) - (int)((bufB[p] >>  8) & 0xFF);
                  int dB = (int)( bufW[p]        & 0xFF) - (int)( bufB[p]        & 0xFF);
                  int a  = 255 - (dR + dG + dB) / 3;
                  if(a < 0) a = 0; else if(a > 255) a = 255;
                  hrA[p] = (uchar)a;
                 }
               //--- Downsample by averaging each SS x SS HR block and blend onto canvas
               for(int yy = 0; yy < th; yy++)
                 {
                  for(int xx = 0; xx < tw; xx++)
                    {
                     //--- Accumulate alpha samples from the corresponding HR block
                     int accum = 0, cnt = 0;
                     for(int sy = 0; sy < SS; sy++)
                       {
                        int hy = yy * SS + sy;
                        if(hy >= hrTh) break;
                        for(int sx = 0; sx < SS; sx++)
                          {
                           int hx = xx * SS + sx;
                           if(hx >= hrTw) break;
                           accum += (int)hrA[hy * hrTw + hx];
                           cnt++;
                          }
                       }
                     if(cnt == 0) continue;
                     int avgA = accum / cnt;
                     if(avgA <= 0) continue;
                     //--- Scale the averaged alpha by the user-supplied text opacity
                     int scaledA = (int)((double)avgA * (double)textAlphaByte / 255.0 + 0.5);
                     if(scaledA <= 0) continue;
                     if(scaledA > 255) scaledA = 255;
                     //--- Compose the final glyph pixel and blend with clip-rect testing
                     uint pxArgb = ((uint)(uchar)scaledA << 24) |
                                    ((uint)txR << 16) | ((uint)txG << 8) | (uint)txB;
                     int dx = textL + lineXOff + xx;
                     int dy = lineY + yy;
                     if(dx >= clipL && dy >= clipT && dx <= clipR && dy <= clipB &&
                        dx >= 0 && dy >= 0 && dx < canvas.Width() && dy < canvas.Height())
                        BlendPxNote(canvas, dx, dy, pxArgb);
                    }
                 }
              }
           }
        }
      //--- Draw the caret cursor on the caret line during a visible blink phase
      if(isEditing && cursorOn && vl == caretVisLine)
        {
         //--- Measure the text prefix up to the caret position
         string prefix = StringSubstr(lineStr, 0, caretVisCol);
         int prefixW = 0;
         if(StringLen(prefix) > 0)
           {
            uint pwU = 0, phU = 0;
            TextGetSize(prefix, pwU, phU);
            prefixW = ((int)pwU) / SS;
           }
         //--- Compute the caret column and vertical extent on screen
         int cursorX = textL + lineXOff + prefixW;
         int cy0 = lineY + 1;
         int cy1 = lineY + lineH - 2;
         if(cy1 <= cy0) cy1 = cy0;
         //--- Draw a vertical 1px caret line clipped to the text rectangle
         for(int cy = cy0; cy <= cy1; cy++)
           {
            int dx = cursorX, dy = cy;
            if(dx >= clipL && dy >= clipT && dx <= clipR && dy <= clipB &&
               dx >= 0 && dy >= 0 && dx < canvas.Width() && dy < canvas.Height())
              {
               uint cArgb = ((uint)0xFF << 24) |
                             ((uint)curR << 16) | ((uint)curG << 8) | (uint)curB;
               BlendPxNote(canvas, dx, dy, cArgb);
              }
           }
        }
     }
  }

//+------------------------------------------------------------------+
//| Point-in-polygon test for an Arrow Marker (even-odd rule)        |
//+------------------------------------------------------------------+
bool PointInArrowMarker(double px, double py, const double &vx[], const double &vy[])
  {
   //--- Walk every polygon edge toggling the inside flag on each crossing
   bool inside = false;
   int n = ArraySize(vx);
   int j = n - 1;
   for(int i = 0; i < n; i++)
     {
      //--- Detect a horizontal crossing and test which side the ray hits
      if(((vy[i] > py) != (vy[j] > py)) &&
         (px < (vx[j] - vx[i]) * (py - vy[i]) / (vy[j] - vy[i]) + vx[i]))
         inside = !inside;
      j = i;
     }
   return inside;
  }

//+------------------------------------------------------------------+
//| Point-in-polygon test for an Arrow Up/Down 7-vertex shape        |
//+------------------------------------------------------------------+
bool PointInArrowUpDown(double px, double py, const double &vx[], const double &vy[])
  {
   //--- Walk every polygon edge toggling the inside flag on each crossing
   bool inside = false;
   int n = ArraySize(vx);
   int j = n - 1;
   for(int i = 0; i < n; i++)
     {
      //--- Detect a horizontal crossing and test which side the ray hits
      if(((vy[i] > py) != (vy[j] > py)) &&
         (px < (vx[j] - vx[i]) * (py - vy[i]) / (vy[j] - vy[i]) + vx[i]))
         inside = !inside;
      j = i;
     }
   return inside;
  }

//+------------------------------------------------------------------+
//| Draw a 1px Note connector line with Wu AA for diagonals          |
//+------------------------------------------------------------------+
void DrawNoteConnectorLine(CCanvas &canvas,
                           double x0, double y0, double x1, double y1,
                           uint argb)
  {
   //--- Cache canvas dimensions for the inner clipping checks
   int cW = canvas.Width(), cH = canvas.Height();
   //--- Compute the line direction vector components
   double dx = x1 - x0;
   double dy = y1 - y0;
   //--- Fast path: nearly vertical line uses hard pixel painting
   if(MathAbs(dx) < 0.5)
     {
      //--- Snap to integer column and span the rounded Y endpoints
      int ix = (int)MathRound(x0);
      int iy0 = (int)MathRound(MathMin(y0, y1));
      int iy1 = (int)MathRound(MathMax(y0, y1));
      if(ix < 0 || ix >= cW) return;
      if(iy0 < 0) iy0 = 0;
      if(iy1 >= cH) iy1 = cH - 1;
      //--- Paint each pixel in the column span
      for(int yy = iy0; yy <= iy1; yy++) BlendPxNote(canvas, ix, yy, argb);
      return;
     }
   //--- Fast path: nearly horizontal line uses hard pixel painting
   if(MathAbs(dy) < 0.5)
     {
      //--- Snap to integer row and span the rounded X endpoints
      int iy = (int)MathRound(y0);
      int ix0 = (int)MathRound(MathMin(x0, x1));
      int ix1 = (int)MathRound(MathMax(x0, x1));
      if(iy < 0 || iy >= cH) return;
      if(ix0 < 0) ix0 = 0;
      if(ix1 >= cW) ix1 = cW - 1;
      //--- Paint each pixel in the row span
      for(int xx = ix0; xx <= ix1; xx++) BlendPxNote(canvas, xx, iy, argb);
      return;
     }
   //--- Diagonal path: choose steep vs shallow orientation for Wu AA
   bool steep = MathAbs(dy) > MathAbs(dx);
   if(steep)
     {
      //--- Walk along Y as the primary axis (steep case)
      if(y0 > y1) { double t; t = x0; x0 = x1; x1 = t; t = y0; y0 = y1; y1 = t; }
      //--- Compute the inverse slope dx/dy
      double grad = (y1 == y0) ? 0.0 : (x1 - x0) / (y1 - y0);
      int iy0 = (int)MathRound(y0), iy1 = (int)MathRound(y1);
      double xf = x0 + grad * (iy0 - y0);
      uchar baseA = (uchar)((argb >> 24) & 0xFF);
      uint  rgbMask = argb & 0x00FFFFFF;
      //--- Plot each row by distributing alpha coverage between two columns
      for(int iy = iy0; iy <= iy1; iy++)
        {
         //--- Compute fractional X and split coverage between adjacent columns
         int ix = (int)MathFloor(xf);
         double frac = xf - ix;
         double covA = 1.0 - frac, covB = frac;
         //--- Paint the left column at the inverse-fraction alpha
         if(ix >= 0 && ix < cW && iy >= 0 && iy < cH)
            BlendPxNote(canvas, ix, iy, ((uint)(uchar)(baseA * covA) << 24) | rgbMask);
         //--- Paint the right column at the fraction alpha
         if(ix + 1 >= 0 && ix + 1 < cW && iy >= 0 && iy < cH)
            BlendPxNote(canvas, ix + 1, iy, ((uint)(uchar)(baseA * covB) << 24) | rgbMask);
         xf += grad;
        }
     }
   else
     {
      //--- Walk along X as the primary axis (shallow case)
      if(x0 > x1) { double t; t = x0; x0 = x1; x1 = t; t = y0; y0 = y1; y1 = t; }
      //--- Compute the slope dy/dx
      double grad = (x1 == x0) ? 0.0 : (y1 - y0) / (x1 - x0);
      int ix0 = (int)MathRound(x0), ix1 = (int)MathRound(x1);
      double yf = y0 + grad * (ix0 - x0);
      uchar baseA = (uchar)((argb >> 24) & 0xFF);
      uint  rgbMask = argb & 0x00FFFFFF;
      //--- Plot each column by distributing alpha coverage between two rows
      for(int ix = ix0; ix <= ix1; ix++)
        {
         //--- Compute fractional Y and split coverage between adjacent rows
         int iy = (int)MathFloor(yf);
         double frac = yf - iy;
         double covA = 1.0 - frac, covB = frac;
         //--- Paint the upper row at the inverse-fraction alpha
         if(ix >= 0 && ix < cW && iy >= 0 && iy < cH)
            BlendPxNote(canvas, ix, iy, ((uint)(uchar)(baseA * covA) << 24) | rgbMask);
         //--- Paint the lower row at the fraction alpha
         if(ix >= 0 && ix < cW && iy + 1 >= 0 && iy + 1 < cH)
            BlendPxNote(canvas, ix, iy + 1, ((uint)(uchar)(baseA * covB) << 24) | rgbMask);
         yf += grad;
        }
     }
  }

//+------------------------------------------------------------------+
//| Fill a rounded rectangle with 4x SSAA and downsample averaging   |
//+------------------------------------------------------------------+
void FillNoteRoundRect(CCanvas &canvas, int boxL, int boxT, int boxR, int boxB,
                       int cornerRadius, uint argb)
  {
   //--- Compute box dimensions and reject empty rectangles
   int w = boxR - boxL;
   int h = boxB - boxT;
   if(w <= 0 || h <= 0) return;
   //--- Configure the 4x supersampling factor and HR canvas dimensions
   const int SS = 4;
   int wHR = w * SS;
   int hHR = h * SS;
   int crHR = cornerRadius * SS;
   //--- Create the temporary high-res canvas; fall back to plain rendering on failure
   CCanvas tmpHR;
   if(!tmpHR.Create("NoteRectHR_tmp", wHR, hHR, COLOR_FORMAT_ARGB_NORMALIZE))
     {
      //--- Fallback path uses non-supersampled CCanvas primitives
      int radius = cornerRadius;
      //--- Clamp radius to half the shorter dimension
      if(radius > w / 2) radius = w / 2;
      if(radius > h / 2) radius = h / 2;
      //--- Zero-radius case is a plain rectangle
      if(radius <= 0)
        {
         canvas.FillRectangle(boxL, boxT, boxR - 1, boxB - 1, argb);
         return;
        }
      //--- Paint the four corner circles plus two cross strips for the rounded shape
      canvas.FillCircle(boxL + radius,     boxT + radius,     radius, argb);
      canvas.FillCircle(boxR - radius - 1, boxT + radius,     radius, argb);
      canvas.FillCircle(boxL + radius,     boxB - radius - 1, radius, argb);
      canvas.FillCircle(boxR - radius - 1, boxB - radius - 1, radius, argb);
      canvas.FillRectangle(boxL + radius, boxT,          boxR - radius - 1, boxB - 1,          argb);
      canvas.FillRectangle(boxL,          boxT + radius, boxR - 1,          boxB - radius - 1, argb);
      return;
     }
   //--- Render the rounded rect at high resolution into the temp canvas
   tmpHR.Erase(0x00000000);
   int radiusHR = crHR;
   //--- Clamp HR radius to half the HR dimension
   if(radiusHR > wHR / 2) radiusHR = wHR / 2;
   if(radiusHR > hHR / 2) radiusHR = hHR / 2;
   if(radiusHR <= 0)
     {
      //--- Zero-radius HR case is a plain rectangle
      tmpHR.FillRectangle(0, 0, wHR - 1, hHR - 1, argb);
     }
   else
     {
      //--- Paint four corner circles and two cross strips at high resolution
      tmpHR.FillCircle(radiusHR,         radiusHR,         radiusHR, argb);
      tmpHR.FillCircle(wHR - radiusHR - 1, radiusHR,         radiusHR, argb);
      tmpHR.FillCircle(radiusHR,         hHR - radiusHR - 1, radiusHR, argb);
      tmpHR.FillCircle(wHR - radiusHR - 1, hHR - radiusHR - 1, radiusHR, argb);
      tmpHR.FillRectangle(radiusHR, 0,        wHR - radiusHR - 1, hHR - 1,        argb);
      tmpHR.FillRectangle(0,        radiusHR, wHR - 1,            hHR - radiusHR - 1, argb);
     }
   //--- Downsample the high-res buffer by averaging each SS x SS block
   int ss2 = SS * SS;
   int cW = canvas.Width(), cH = canvas.Height();
   for(int py = 0; py < h; py++)
     {
      //--- Compute the canvas target Y row with clipping
      int targetY = boxT + py;
      if(targetY < 0 || targetY >= cH) continue;
      for(int px = 0; px < w; px++)
        {
         //--- Compute the canvas target X column with clipping
         int targetX = boxL + px;
         if(targetX < 0 || targetX >= cW) continue;
         //--- Accumulate alpha and RGB sums across the SS x SS source block
         int sumA = 0, sumR = 0, sumG = 0, sumB = 0, wc = 0;
         for(int dy = 0; dy < SS; dy++)
           {
            for(int dx = 0; dx < SS; dx++)
              {
               //--- Read the HR pixel and accumulate channel sums for opaque samples
               int sx = px * SS + dx;
               int sy = py * SS + dy;
               uint p = tmpHR.PixelGet(sx, sy);
               uchar pa = (uchar)((p >> 24) & 0xFF);
               sumA += pa;
               if(pa > 0)
                 {
                  sumR += (int)((p >> 16) & 0xFF);
                  sumG += (int)((p >>  8) & 0xFF);
                  sumB += (int)( p        & 0xFF);
                  wc++;
                 }
              }
           }
         //--- Compose the averaged pixel and blend onto the target canvas
         uchar fa = (uchar)(sumA / ss2);
         if(fa == 0 || wc == 0) continue;
         uchar fr = (uchar)(sumR / wc);
         uchar fg = (uchar)(sumG / wc);
         uchar fb = (uchar)(sumB / wc);
         uint outArgb = ((uint)fa << 24) | ((uint)fr << 16) | ((uint)fg << 8) | (uint)fb;
         BlendPxNote(canvas, targetX, targetY, outArgb);
        }
     }
   //--- Release the temporary high-res canvas
   tmpHR.Destroy();
  }

//+------------------------------------------------------------------+
//| Draw a Note drop shadow using a 2-pass separable box blur        |
//+------------------------------------------------------------------+
void DrawNoteDropShadow(CCanvas &canvas,
                        int boxL, int boxT, int boxR, int boxB,
                        int cornerRadius)
  {
   //--- Shadow tuning parameters: offset, blur radius, and base alpha
   int offX      = 1;
   int offY      = 1;
   int blurR     = 3;
   int baseAlpha = 80;
   //--- Compute the offset shadow silhouette bounds
   int shL = boxL + offX;
   int shT = boxT + offY;
   int shR = boxR + offX;
   int shB = boxB + offY;
   //--- Compute padding for the blur kernel plus offset overhang
   int padLeft   = blurR + (offX < 0 ? -offX : 0);
   int padTop    = blurR + (offY < 0 ? -offY : 0);
   int padRight  = blurR + (offX > 0 ?  offX : 0);
   int padBottom = blurR + (offY > 0 ?  offY : 0);
   //--- Compute the padded working buffer dimensions
   int bufL = boxL - padLeft;
   int bufT = boxT - padTop;
   int bufR = boxR + padRight;
   int bufB = boxB + padBottom;
   int bufW = bufR - bufL;
   int bufH = bufB - bufT;
   if(bufW <= 0 || bufH <= 0) return;
   //--- Allocate and zero-initialize the silhouette alpha buffer
   uchar silhouette[];
   ArrayResize(silhouette, bufW * bufH);
   ArrayInitialize(silhouette, 0);
   //--- Build the rounded-rect silhouette via SDF-style inner-rect distance
   double cr = (double)cornerRadius;
   double innerL = (double)shL + cr;
   double innerR = (double)shR - cr;
   double innerT = (double)shT + cr;
   double innerB = (double)shB - cr;
   for(int yy = 0; yy < bufH; yy++)
     {
      //--- Compute the pixel-center Y for the distance query
      double py = (double)(yy + bufT) + 0.5;
      for(int xx = 0; xx < bufW; xx++)
        {
         //--- Compute the pixel-center X for the distance query
         double px = (double)(xx + bufL) + 0.5;
         //--- Compute distance from the pixel to the inner rectangle
         double ddx = MathMax(MathMax(innerL - px, px - innerR), 0.0);
         double ddy = MathMax(MathMax(innerT - py, py - innerB), 0.0);
         double dist = MathSqrt(ddx * ddx + ddy * ddy);
         //--- Mark pixels inside the rounded boundary at the base alpha
         if(dist <= cr)
            silhouette[yy * bufW + xx] = (uchar)baseAlpha;
        }
     }
   //--- Horizontal box-blur pass writing into a temporary buffer
   uchar tempH[];
   ArrayResize(tempH, bufW * bufH);
   int kernelSize = 2 * blurR + 1;
   for(int yy = 0; yy < bufH; yy++)
     {
      //--- Compute the row base offset for this scanline
      int rowBase = yy * bufW;
      //--- Seed the sliding-window sum with the leftmost kernel placement
      int runSum = 0;
      for(int k = -blurR; k <= blurR; k++)
        {
         int sx = k;
         if(sx < 0) sx = 0;
         if(sx >= bufW) sx = bufW - 1;
         runSum += (int)silhouette[rowBase + sx];
        }
      //--- Slide the window across the row writing averaged output
      for(int xx = 0; xx < bufW; xx++)
        {
         //--- Write the averaged output pixel for this column
         tempH[rowBase + xx] = (uchar)(runSum / kernelSize);
         //--- Update the sliding sum: remove leftmost, add rightmost
         int subX = xx - blurR;
         if(subX < 0) subX = 0;
         int addX = xx + blurR + 1;
         if(addX >= bufW) addX = bufW - 1;
         runSum -= (int)silhouette[rowBase + subX];
         runSum += (int)silhouette[rowBase + addX];
        }
     }
   //--- Vertical box-blur pass writing back into the silhouette buffer
   for(int xx = 0; xx < bufW; xx++)
     {
      //--- Seed the column sliding-window sum with the topmost kernel placement
      int runSum = 0;
      for(int k = -blurR; k <= blurR; k++)
        {
         int sy = k;
         if(sy < 0) sy = 0;
         if(sy >= bufH) sy = bufH - 1;
         runSum += (int)tempH[sy * bufW + xx];
        }
      //--- Slide the window down the column writing averaged output
      for(int yy = 0; yy < bufH; yy++)
        {
         //--- Write the averaged output pixel for this row
         silhouette[yy * bufW + xx] = (uchar)(runSum / kernelSize);
         //--- Update the sliding sum: remove topmost, add bottommost
         int subY = yy - blurR;
         if(subY < 0) subY = 0;
         int addY = yy + blurR + 1;
         if(addY >= bufH) addY = bufH - 1;
         runSum -= (int)tempH[subY * bufW + xx];
         runSum += (int)tempH[addY * bufW + xx];
        }
     }
   //--- Composite the blurred shadow onto the destination canvas
   int cW = canvas.Width(), cH = canvas.Height();
   for(int yy = 0; yy < bufH; yy++)
     {
      //--- Compute the canvas target Y with clipping
      int canvasY = yy + bufT;
      if(canvasY < 0 || canvasY >= cH) continue;
      for(int xx = 0; xx < bufW; xx++)
        {
         //--- Compute the canvas target X with clipping
         int canvasX = xx + bufL;
         if(canvasX < 0 || canvasX >= cW) continue;
         //--- Skip fully transparent shadow pixels
         uchar a = silhouette[yy * bufW + xx];
         if(a == 0) continue;
         //--- Blend a black pixel at the blurred alpha onto the canvas
         uint shadowArgb = ((uint)a << 24) | 0x00000000;
         BlendPxNote(canvas, canvasX, canvasY, shadowArgb);
        }
     }
  }

//+------------------------------------------------------------------+
//| Fill a triangle on the canvas using edge-function scanline       |
//+------------------------------------------------------------------+
void FillCalloutTriangle(CCanvas &canvas,
                          int x0, int y0, int x1, int y1, int x2, int y2,
                          uint argb)
  {
   //--- Compute the triangle's axis-aligned bounding box
   int minX = x0 < x1 ? (x0 < x2 ? x0 : x2) : (x1 < x2 ? x1 : x2);
   int maxX = x0 > x1 ? (x0 > x2 ? x0 : x2) : (x1 > x2 ? x1 : x2);
   int minY = y0 < y1 ? (y0 < y2 ? y0 : y2) : (y1 < y2 ? y1 : y2);
   int maxY = y0 > y1 ? (y0 > y2 ? y0 : y2) : (y1 > y2 ? y1 : y2);
   //--- Clamp bounding box to canvas bounds
   int cW = canvas.Width(), cH = canvas.Height();
   if(minX < 0) minX = 0;
   if(minY < 0) minY = 0;
   if(maxX >= cW) maxX = cW - 1;
   if(maxY >= cH) maxY = cH - 1;
   //--- Scan every pixel in the bounding box and blend if inside the triangle
   for(int py = minY; py <= maxY; py++)
     {
      for(int px = minX; px <= maxX; px++)
        {
         //--- Compute the three edge-function values for this pixel
         double e0 = (double)(x1 - x0) * (double)(py - y0) - (double)(y1 - y0) * (double)(px - x0);
         double e1 = (double)(x2 - x1) * (double)(py - y1) - (double)(y2 - y1) * (double)(px - x1);
         double e2 = (double)(x0 - x2) * (double)(py - y2) - (double)(y0 - y2) * (double)(px - x2);
         //--- Inside test passes when all edge functions share the same sign
         bool inside = ((e0 >= 0 && e1 >= 0 && e2 >= 0) ||
                        (e0 <= 0 && e1 <= 0 && e2 <= 0));
         if(inside) BlendPxNote(canvas, px, py, argb);
        }
     }
  }

//+------------------------------------------------------------------+
//| Stroke the continuous Callout border via SSAA outline rendering  |
//+------------------------------------------------------------------+
void DrawCalloutBorder(CCanvas &canvas,
                        int boxL, int boxT, int boxR, int boxB, int cr,
                        int a1x, int a1y, int a2x, int a2y,
                        int p1x, int p1y,
                        ENUM_CALLOUT_ATTACH acase,
                        uint argb, int borderW)
  {
   //--- Allocate vertex arrays for the traced outline
   double verts[][2];
   int    nv = 0;
   ArrayResize(verts, 512);
   //--- Build the full rect-border polyline (4 edges plus 4 corner arc sweeps)
   double rectPts[][2];
   int    np = 0;
   ArrayResize(rectPts, 512);
   //--- Add the top edge endpoints
   rectPts[np][0] = (double)(boxL + cr); rectPts[np][1] = (double)boxT; np++;
   rectPts[np][0] = (double)(boxR - cr); rectPts[np][1] = (double)boxT; np++;
   //--- Sweep the top-right corner arc
   for(int ad = 275; ad <= 360; ad += 5)
     {
      //--- Convert the sweep angle to radians and compute the arc point
      double a = (double)ad * M_PI / 180.0;
      rectPts[np][0] = (double)(boxR - cr) + (double)cr * MathCos(a);
      rectPts[np][1] = (double)(boxT + cr) + (double)cr * MathSin(a);
      np++;
     }
   //--- Add the right edge endpoints
   rectPts[np][0] = (double)boxR; rectPts[np][1] = (double)(boxT + cr); np++;
   rectPts[np][0] = (double)boxR; rectPts[np][1] = (double)(boxB - cr); np++;
   //--- Sweep the bottom-right corner arc
   for(int ad = 5; ad <= 90; ad += 5)
     {
      //--- Convert the sweep angle to radians and compute the arc point
      double a = (double)ad * M_PI / 180.0;
      rectPts[np][0] = (double)(boxR - cr) + (double)cr * MathCos(a);
      rectPts[np][1] = (double)(boxB - cr) + (double)cr * MathSin(a);
      np++;
     }
   //--- Add the bottom edge endpoints
   rectPts[np][0] = (double)(boxR - cr); rectPts[np][1] = (double)boxB; np++;
   rectPts[np][0] = (double)(boxL + cr); rectPts[np][1] = (double)boxB; np++;
   //--- Sweep the bottom-left corner arc
   for(int ad = 95; ad <= 180; ad += 5)
     {
      //--- Convert the sweep angle to radians and compute the arc point
      double a = (double)ad * M_PI / 180.0;
      rectPts[np][0] = (double)(boxL + cr) + (double)cr * MathCos(a);
      rectPts[np][1] = (double)(boxB - cr) + (double)cr * MathSin(a);
      np++;
     }
   //--- Add the left edge endpoints
   rectPts[np][0] = (double)boxL; rectPts[np][1] = (double)(boxB - cr); np++;
   rectPts[np][0] = (double)boxL; rectPts[np][1] = (double)(boxT + cr); np++;
   //--- Sweep the top-left corner arc
   for(int ad = 185; ad <= 270; ad += 5)
     {
      //--- Convert the sweep angle to radians and compute the arc point
      double a = (double)ad * M_PI / 180.0;
      rectPts[np][0] = (double)(boxL + cr) + (double)cr * MathCos(a);
      rectPts[np][1] = (double)(boxT + cr) + (double)cr * MathSin(a);
      np++;
     }
   //--- Resize to the actual count of polyline points
   ArrayResize(rectPts, np);
   //--- Find the rect-polyline indices closest to attach points a1 and a2
   int idxA1 = 0, idxA2 = 0;
   double bestA1 = 1e18, bestA2 = 1e18;
   for(int k = 0; k < np; k++)
     {
      //--- Track the smallest squared distance to a1
      double dxA1 = rectPts[k][0] - (double)a1x;
      double dyA1 = rectPts[k][1] - (double)a1y;
      double d1 = dxA1 * dxA1 + dyA1 * dyA1;
      if(d1 < bestA1) { bestA1 = d1; idxA1 = k; }
      //--- Track the smallest squared distance to a2
      double dxA2 = rectPts[k][0] - (double)a2x;
      double dyA2 = rectPts[k][1] - (double)a2y;
      double d2 = dxA2 * dxA2 + dyA2 * dyA2;
      if(d2 < bestA2) { bestA2 = d2; idxA2 = k; }
     }
   //--- Assemble the outline: start at a2, walk CW long-way to a1, then P1
   int nvMax = np + 4;
   ArrayResize(verts, nvMax);
   nv = 0;
   verts[nv][0] = (double)a2x; verts[nv][1] = (double)a2y; nv++;
   //--- Walk forward through the rect polyline with wrap-around
   int idx = idxA2 + 1;
   if(idx >= np) idx = 0;
   int safety = 0;
   while(idx != idxA1 && safety < np + 2)
     {
      //--- Append the next polyline point and advance the wrap-around index
      verts[nv][0] = rectPts[idx][0]; verts[nv][1] = rectPts[idx][1]; nv++;
      idx++;
      if(idx >= np) idx = 0;
      safety++;
     }
   //--- Append a1 then the shaft tip P1 (the closing edge back to a2 is implicit)
   verts[nv][0] = (double)a1x; verts[nv][1] = (double)a1y; nv++;
   verts[nv][0] = (double)p1x; verts[nv][1] = (double)p1y; nv++;
   ArrayResize(verts, nv);
   //--- Compute the outline bounding box for the temp HR canvas
   double minX = verts[0][0], maxX = verts[0][0];
   double minY = verts[0][1], maxY = verts[0][1];
   for(int k = 1; k < nv; k++)
     {
      if(verts[k][0] < minX) minX = verts[k][0];
      if(verts[k][0] > maxX) maxX = verts[k][0];
      if(verts[k][1] < minY) minY = verts[k][1];
      if(verts[k][1] > maxY) maxY = verts[k][1];
     }
   //--- Pad the bounding box for the stroke width and AA fringe
   int margin = borderW + 2;
   int bL = (int)MathFloor(minX) - margin;
   int bT = (int)MathFloor(minY) - margin;
   int bR = (int)MathCeil(maxX) + margin;
   int bB = (int)MathCeil(maxY) + margin;
   int bufW = bR - bL;
   int bufH = bB - bT;
   if(bufW <= 0 || bufH <= 0) return;
   //--- Allocate the 4x supersampled HR canvas
   const int SS = 4;
   int hrW = bufW * SS;
   int hrH = bufH * SS;
   CCanvas tmpHR;
   if(!tmpHR.Create("CalloutBorderHR_tmp", hrW, hrH, COLOR_FORMAT_ARGB_NORMALIZE))
      return;
   tmpHR.Erase(0x00000000);
   //--- Compute the HR border half-width for disc stamping
   int hrBorderW = borderW * SS;
   int hrR = hrBorderW / 2;
   //--- Stroke each outline edge by sweeping a filled disc along the segment
   uint solidArgb = argb | 0xFF000000;
   for(int k = 0; k < nv; k++)
     {
      //--- Pick the next vertex with wrap-around closure
      int kn = (k + 1) % nv;
      //--- Convert the vertex pair into HR canvas coordinates
      double x0d = (verts[k][0]  - (double)bL) * SS;
      double y0d = (verts[k][1]  - (double)bT) * SS;
      double x1d = (verts[kn][0] - (double)bL) * SS;
      double y1d = (verts[kn][1] - (double)bT) * SS;
      //--- Compute segment length for the stamping loop
      double dxL = x1d - x0d;
      double dyL = y1d - y0d;
      double lenL = MathSqrt(dxL * dxL + dyL * dyL);
      //--- Degenerate (zero-length) segment: stamp a single disc and continue
      if(lenL < 0.5)
        {
         tmpHR.FillCircle((int)x0d, (int)y0d, hrR, solidArgb);
         continue;
        }
      //--- Walk along the segment stamping a disc at each unit step
      int steps = (int)MathCeil(lenL);
      for(int s = 0; s <= steps; s++)
        {
         //--- Interpolate the segment parameter and stamp the disc
         double t = (double)s / (double)steps;
         int px = (int)MathRound(x0d + t * dxL);
         int py = (int)MathRound(y0d + t * dyL);
         tmpHR.FillCircle(px, py, hrR, solidArgb);
        }
      //--- Stamp a junction disc at the start vertex for smooth joins
      tmpHR.FillCircle((int)x0d, (int)y0d, hrR, solidArgb);
     }
   //--- Downsample by averaging SS x SS blocks and blend onto the target canvas
   int ss2 = SS * SS;
   int cW = canvas.Width(), cH = canvas.Height();
   uchar baseA = (uchar)((argb >> 24) & 0xFF);
   for(int py = 0; py < bufH; py++)
     {
      //--- Compute the canvas target Y row with clipping
      int targetY = bT + py;
      if(targetY < 0 || targetY >= cH) continue;
      for(int px = 0; px < bufW; px++)
        {
         //--- Compute the canvas target X column with clipping
         int targetX = bL + px;
         if(targetX < 0 || targetX >= cW) continue;
         //--- Accumulate alpha across the SS x SS HR block
         int sumA = 0;
         for(int dy = 0; dy < SS; dy++)
           {
            for(int dx = 0; dx < SS; dx++)
              {
               //--- Read the HR pixel and accumulate its alpha
               int sx = px * SS + dx;
               int sy = py * SS + dy;
               uint p = tmpHR.PixelGet(sx, sy);
               sumA += (int)((p >> 24) & 0xFF);
              }
           }
         //--- Scale by the original base alpha and blend the final pixel
         uchar fa = (uchar)(sumA / ss2);
         if(fa == 0) continue;
         uchar finalA = (uchar)((int)baseA * (int)fa / 255);
         if(finalA == 0) continue;
         uint outArgb = ((uint)finalA << 24) | (argb & 0x00FFFFFF);
         BlendPxNote(canvas, targetX, targetY, outArgb);
        }
     }
   //--- Release the temporary high-res canvas
   tmpHR.Destroy();
  }

//+------------------------------------------------------------------+
//| Fill a rect with mixed corner radii via 4x SSAA inside-test      |
//+------------------------------------------------------------------+
void FillCommentMixedRadiusRect(CCanvas &canvas,
                                 int boxL, int boxT, int boxR, int boxB,
                                 int crTL, int crTR, int crBL, int crBR,
                                 uint argb)
  {
   //--- Compute box dimensions and reject empty rectangles
   int w = boxR - boxL;
   int h = boxB - boxT;
   if(w <= 0 || h <= 0) return;
   //--- Clamp each corner radius to half the shorter dimension
   int maxCr = (w < h ? w : h) / 2;
   if(crTL > maxCr) crTL = maxCr;
   if(crTR > maxCr) crTR = maxCr;
   if(crBL > maxCr) crBL = maxCr;
   if(crBR > maxCr) crBR = maxCr;
   //--- Floor negative radii to zero
   if(crTL < 0) crTL = 0;
   if(crTR < 0) crTR = 0;
   if(crBL < 0) crBL = 0;
   if(crBR < 0) crBR = 0;
   //--- Configure the 4x supersampling factor and HR dimensions
   const int SS = 4;
   int hrW = w * SS;
   int hrH = h * SS;
   //--- Compute HR corner radii and corner-center positions
   int hrCrTL = crTL * SS;
   int hrCrTR = crTR * SS;
   int hrCrBL = crBL * SS;
   int hrCrBR = crBR * SS;
   int cxTL = hrCrTL;              int cyTL = hrCrTL;
   int cxTR = hrW - 1 - hrCrTR;    int cyTR = hrCrTR;
   int cxBL = hrCrBL;              int cyBL = hrH - 1 - hrCrBL;
   int cxBR = hrW - 1 - hrCrBR;    int cyBR = hrH - 1 - hrCrBR;
   //--- Allocate and zero-initialize the HR alpha buffer
   uchar hrAlpha[];
   ArrayResize(hrAlpha, hrW * hrH);
   ArrayInitialize(hrAlpha, 0);
   //--- Fill the HR buffer via per-pixel inside-test
   for(int hy = 0; hy < hrH; hy++)
     {
      for(int hx = 0; hx < hrW; hx++)
        {
         //--- Default to inside; corner regions override with arc tests
         bool inside = true;
         //--- Top-left corner region: test inside the TL arc
         if(hx < cxTL && hy < cyTL)
           {
            int dxh = hx - cxTL, dyh = hy - cyTL;
            inside = (dxh * dxh + dyh * dyh <= hrCrTL * hrCrTL);
           }
         //--- Top-right corner region: test inside the TR arc
         else if(hx > cxTR && hy < cyTR)
           {
            int dxh = hx - cxTR, dyh = hy - cyTR;
            inside = (dxh * dxh + dyh * dyh <= hrCrTR * hrCrTR);
           }
         //--- Bottom-left corner region: test inside the BL arc
         else if(hx < cxBL && hy > cyBL)
           {
            int dxh = hx - cxBL, dyh = hy - cyBL;
            inside = (dxh * dxh + dyh * dyh <= hrCrBL * hrCrBL);
           }
         //--- Bottom-right corner region: test inside the BR arc
         else if(hx > cxBR && hy > cyBR)
           {
            int dxh = hx - cxBR, dyh = hy - cyBR;
            inside = (dxh * dxh + dyh * dyh <= hrCrBR * hrCrBR);
           }
         //--- Mark the HR pixel as fully covered when inside the shape
         if(inside) hrAlpha[hy * hrW + hx] = 255;
        }
     }
   //--- Downsample by averaging each SS x SS block and blend onto the canvas
   int ss2 = SS * SS;
   int cW = canvas.Width(), cH = canvas.Height();
   uchar baseA = (uchar)((argb >> 24) & 0xFF);
   uchar rgbR  = (uchar)((argb >> 16) & 0xFF);
   uchar rgbG  = (uchar)((argb >>  8) & 0xFF);
   uchar rgbB  = (uchar)( argb        & 0xFF);
   for(int py = 0; py < h; py++)
     {
      //--- Compute the canvas target Y row with clipping
      int ty = boxT + py;
      if(ty < 0 || ty >= cH) continue;
      for(int px = 0; px < w; px++)
        {
         //--- Compute the canvas target X column with clipping
         int tx = boxL + px;
         if(tx < 0 || tx >= cW) continue;
         //--- Accumulate alpha across the SS x SS source block
         int sumA = 0;
         for(int dy = 0; dy < SS; dy++)
           {
            for(int dx = 0; dx < SS; dx++)
              {
               sumA += (int)hrAlpha[(py * SS + dy) * hrW + (px * SS + dx)];
              }
           }
         //--- Compute coverage and final alpha then blend the pixel
         int avgCov = sumA / ss2;
         if(avgCov == 0) continue;
         int finalA = (int)baseA * avgCov / 255;
         if(finalA == 0) continue;
         uint outArgb = ((uint)(uchar)finalA << 24) | ((uint)rgbR << 16) |
                        ((uint)rgbG << 8) | (uint)rgbB;
         BlendPxNote(canvas, tx, ty, outArgb);
        }
     }
  }

//+------------------------------------------------------------------+
//| Compute the Text annotation bounding box                         |
//+------------------------------------------------------------------+
void CAnnotationTools::ComputeTextAnnotationBox(int ax, int ay,
                                                 const string committedText,
                                                 bool isEditing, const string editBuffer,
                                                 int &outL, int &outT, int &outR, int &outB,
                                                 int fontSize = 12, bool bold = false)
  {
   //--- Pick the measurement text based on edit state and content presence
   string content    = isEditing ? editBuffer : committedText;
   bool   hasContent = (StringLen(content) > 0);
   string measure;
   if(isEditing && !hasContent)
      measure = "Add text";
   else if(StringLen(content) > 0)
      measure = content;
   else
      measure = "  ";
   //--- Measure the text block to get its width and height
   int textW = 0, textH = 0, lineH = 0;
   MeasureTextBlock(measure, "Arial", fontSize, textW, textH, lineH);
   if(textW < 1) textW = 1;
   if(textH < 1) textH = lineH;
   //--- Reserve horizontal slack for the end-of-line cursor
   int cursorReserve = 2;
   int padX = 8;
   int padY = 4;
   //--- Compute the final box dimensions and center the box on the anchor point
   int boxW = textW + cursorReserve + 2 * padX;
   int boxH = textH + 2 * padY;
   outL = ax - boxW / 2;
   outT = ay - boxH / 2;
   outR = outL + boxW;
   outB = outT + boxH;
  }

//+------------------------------------------------------------------+
//| Hit-test for a Text annotation box                               |
//+------------------------------------------------------------------+
bool CAnnotationTools::HitTestTextAnnotation(int mx, int my,
                                              int ax, int ay,
                                              const string committedText,
                                              bool isEditing, const string editBuffer,
                                              int fontSize = 12, bool bold = false)
  {
   //--- Compute the box bounds and test rectangle containment
   int L=0, T=0, R=0, B=0;
   ComputeTextAnnotationBox(ax, ay, committedText, isEditing, editBuffer,
                             L, T, R, B, fontSize, bold);
   return (mx >= L && mx <= R && my >= T && my <= B);
  }

//+------------------------------------------------------------------+
//| Draw a Text annotation box and its contents                      |
//+------------------------------------------------------------------+
void CAnnotationTools::DrawTextAnnotationOn(CCanvas &canvas,
                                             int ax, int ay,
                                             const string committedText,
                                             bool isEditing, const string editBuffer,
                                             int caretPos,
                                             color objColor, bool selected, bool hovered,
                                             int &outL, int &outT, int &outR, int &outB,
                                             int fontSize = 12, bool bold = false,
                                             int vAlign = 0, int hAlign = 0,
                                             int textOpacityPct = 100)
  {
   //--- Resolve which text to display and whether the placeholder is active
   string labelPart  = isEditing ? editBuffer : committedText;
   bool   hasContent = (StringLen(labelPart) > 0);
   bool   usePlaceholder = isEditing && !hasContent;
   //--- Compute the box bounds via the shared geometry helper
   int boxL=0, boxT=0, boxR=0, boxB=0;
   ComputeTextAnnotationBox(ax, ay, committedText, isEditing, editBuffer,
                             boxL, boxT, boxR, boxB,
                             fontSize, bold);
   outL = boxL; outT = boxT; outR = boxR; outB = boxB;
   //--- Choose border opacity based on edit, selection, and hover state
   uchar borderAlpha = 0;
   if(isEditing)
      borderAlpha = hasContent ? 255 : 128;
   else if(selected)
      borderAlpha = 255;
   else if(hovered)
      borderAlpha = 128;
   //--- Render the 2px border at the chosen opacity
   if(borderAlpha > 0)
     {
      //--- Compose the border ARGB and configure pixel-walk parameters
      uint borderArgb = ColorToARGB(objColor, borderAlpha);
      int  thick = 2;
      int cW = canvas.Width(), cH = canvas.Height();
      //--- Clamp the pixel-walk bounds to canvas dimensions
      int yLo = MathMax(boxT, 0);
      int yHi = MathMin(boxB, cH - 1);
      int xLo = MathMax(boxL, 0);
      int xHi = MathMin(boxR, cW - 1);
      //--- Walk the box bounds and paint only border-edge pixels
      for(int yy = yLo; yy <= yHi; yy++)
        {
         //--- Detect rows within the horizontal border thickness band
         bool nearH = (yy <  boxT + thick) || (yy >  boxB - thick);
         for(int xx = xLo; xx <= xHi; xx++)
           {
            //--- Detect columns within the vertical border thickness band
            bool nearV = (xx <  boxL + thick) || (xx >  boxR - thick);
            //--- Paint the pixel only when it sits on the border
            if(nearV || nearH)
               ChannelBlendPixelSet(canvas, xx, yy, borderArgb);
           }
        }
     }
   //--- Resolve the text content and color for the render pass
   string renderText;
   color  textColor;
   if(usePlaceholder)
     {
      //--- Use the placeholder prompt in the object color
      renderText = "Add text";
      textColor  = objColor;
     }
   else
     {
      //--- Use the committed or buffered text in the object color
      renderText = labelPart;
      textColor  = objColor;
     }
   //--- Match cursor color to the chart foreground so it stays readable on any theme
   color cursorColor = (color)ChartGetInteger(0, CHART_COLOR_FOREGROUND);
   //--- Compute the inner text rectangle after padding
   int textL = boxL + 8;
   int textT = boxT + 4;
   int textR = boxR - 8;
   int textB = boxB - 4;
   //--- Force the caret position to 0 when showing the placeholder text
   int effectiveCaret = usePlaceholder ? 0 : caretPos;
   //--- Delegate to the universal multi-line editable text renderer
   if(StringLen(renderText) > 0 || isEditing)
     {
      RenderEditableTextBlockAA(canvas, renderText, isEditing, effectiveCaret,
                                  textL, textT, textL, textT, textR, textB,
                                  "Arial", fontSize, textColor, cursorColor,
                                  0,
                                  bold, vAlign, hAlign, textOpacityPct);
     }
  }

//+------------------------------------------------------------------+
//| Draw a 2-click annotation Arrow (shaft plus filled triangle head)|
//+------------------------------------------------------------------+
void CAnnotationTools::DrawArrowOn(CCanvas &canvas,
                                    int x1, int y1, int x2, int y2,
                                    color objColor, bool selected, bool hovered,
                                    int lineWidth, int lineOpacity)
  {
   //--- Clamp the line width to the supported [1, 4] range
   if(lineWidth < 1) lineWidth = 1;
   if(lineWidth > 4) lineWidth = 4;
   const int thick = lineWidth;
   //--- Compute the shaft direction vector and length
   double dxS = (double)(x2 - x1);
   double dyS = (double)(y2 - y1);
   double lenS = MathSqrt(dxS * dxS + dyS * dyS);
   //--- Degenerate (zero-length) arrow: just render the handles so the user can reshape
   if(lenS < 1.0)
     {
      if(selected || hovered)
        {
         if(m_hideHandleIdx != 0) DrawHandleOnCanvas(canvas, x1, y1, selected, objColor, m_haloHandleIdx == 0);
         if(m_hideHandleIdx != 1) DrawHandleOnCanvas(canvas, x2, y2, selected, objColor, m_haloHandleIdx == 1);
        }
      return;
     }
   //--- Compute the unit direction vector along the shaft
   double ux = dxS / lenS;
   double uy = dyS / lenS;
   //--- Wing geometry: 12px long at 25 degrees from the shaft axis
   double wingLen = 12.0;
   double wingAng = 25.0 * 3.14159265358979 / 180.0;
   double cA = MathCos(wingAng);
   double sA = MathSin(wingAng);
   //--- Compute the two wing direction vectors by rotating the negative shaft direction
   double w1dx = -(ux * cA - uy * sA);
   double w1dy = -(uy * cA + ux * sA);
   double w2dx = -(ux * cA + uy * sA);
   double w2dy = -(uy * cA - ux * sA);
   //--- Compute the wing endpoint pixel coordinates
   int w1x = (int)MathRound((double)x2 + w1dx * wingLen);
   int w1y = (int)MathRound((double)y2 + w1dy * wingLen);
   int w2x = (int)MathRound((double)x2 + w2dx * wingLen);
   int w2y = (int)MathRound((double)y2 + w2dy * wingLen);
   //--- Extract ARGB components and compute the half thickness for SDF AA
   uint  borderFullArgb = ColorWithPercentOpacity(objColor, lineOpacity);
   uint  borderRGBmask  = borderFullArgb & 0x00FFFFFF;
   uchar borderBaseA    = (uchar)((borderFullArgb >> 24) & 0xFF);
   double halfThick = (double)thick * 0.5;
   //--- Compute a bounding box covering the shaft and both wings with AA padding
   int xLo = MathMin(MathMin(x1, x2), MathMin(w1x, w2x)) - 2;
   int xHi = MathMax(MathMax(x1, x2), MathMax(w1x, w2x)) + 2;
   int yLo = MathMin(MathMin(y1, y2), MathMin(w1y, w2y)) - 2;
   int yHi = MathMax(MathMax(y1, y2), MathMax(w1y, w2y)) + 2;
   //--- Clamp the bounding box to canvas bounds
   int cW = canvas.Width(), cH = canvas.Height();
   if(xLo < 0)   xLo = 0;
   if(yLo < 0)   yLo = 0;
   if(xHi >= cW) xHi = cW - 1;
   if(yHi >= cH) yHi = cH - 1;
   //--- Pack segment endpoints for the inner loop: shaft, right wing, left wing
   int segAx[3] = { x1, x2, x2 };
   int segAy[3] = { y1, y2, y2 };
   int segBx[3] = { x2, w1x, w2x };
   int segBy[3] = { y2, w1y, w2y };
   //--- Single SDF AA pass over the bounding box
   for(int yy = yLo; yy <= yHi; yy++)
     {
      for(int xx = xLo; xx <= xHi; xx++)
        {
         //--- Compute distance to each of the three segments and take the minimum
         double d0 = PointToSegmentDistance(xx, yy, segAx[0], segAy[0], segBx[0], segBy[0]);
         double d1 = PointToSegmentDistance(xx, yy, segAx[1], segAy[1], segBx[1], segBy[1]);
         double d2 = PointToSegmentDistance(xx, yy, segAx[2], segAy[2], segBx[2], segBy[2]);
         double d  = MathMin(d0, MathMin(d1, d2));
         //--- Compute fractional coverage with a 0.5px AA fringe
         double cov = halfThick + 0.5 - d;
         if(cov <= 0.0) continue;
         if(cov > 1.0) cov = 1.0;
         //--- Scale base alpha by coverage and blend the pixel
         uchar aCov = (uchar)((double)borderBaseA * cov + 0.5);
         uint  covArgb = ((uint)aCov << 24) | borderRGBmask;
         ChannelBlendPixelSet(canvas, xx, yy, covArgb);
        }
     }
   //--- Draw selection handles at the tail and the tip
   if(selected || hovered)
     {
      if(m_hideHandleIdx != 0) DrawHandleOnCanvas(canvas, x1, y1, selected, objColor, m_haloHandleIdx == 0);
      if(m_hideHandleIdx != 1) DrawHandleOnCanvas(canvas, x2, y2, selected, objColor, m_haloHandleIdx == 1);
     }
  }

//+------------------------------------------------------------------+
//| Hit-test for an Arrow shaft or either wing                       |
//+------------------------------------------------------------------+
bool CAnnotationTools::HitTestArrow(int mx, int my, int x1, int y1, int x2, int y2, int threshold)
  {
   //--- Compute the shaft direction and length
   double dxS = (double)(x2 - x1);
   double dyS = (double)(y2 - y1);
   double lenS = MathSqrt(dxS * dxS + dyS * dyS);
   //--- Degenerate arrow: use tail-point proximity only
   if(lenS < 1.0)
     {
      double d = MathSqrt((double)(mx-x1)*(mx-x1) + (double)(my-y1)*(my-y1));
      return d <= threshold;
     }
   //--- Compute the unit direction vector for the shaft
   double ux = dxS / lenS;
   double uy = dyS / lenS;
   //--- Project (mx, my) onto the shaft segment and clamp to [0, lenS]
   double rx = (double)mx - (double)x1;
   double ry = (double)my - (double)y1;
   double t = rx * ux + ry * uy;
   if(t < 0.0) t = 0.0;
   if(t > lenS) t = lenS;
   //--- Compute the closest point on the shaft and the distance to the cursor
   double qx = (double)x1 + t * ux;
   double qy = (double)y1 + t * uy;
   double shaftDist = MathSqrt((mx - qx)*(mx - qx) + (my - qy)*(my - qy));
   if(shaftDist <= threshold) return true;
   //--- Compute the wing endpoints for the wing-segment proximity test
   double wingLen = 12.0;
   double wingAng = 25.0 * 3.14159265358979 / 180.0;
   double cA = MathCos(wingAng);
   double sA = MathSin(wingAng);
   double w1dx = -(ux * cA - uy * sA);
   double w1dy = -(uy * cA + ux * sA);
   double w2dx = -(ux * cA + uy * sA);
   double w2dy = -(uy * cA - ux * sA);
   double w1ex = (double)x2 + w1dx * wingLen;
   double w1ey = (double)y2 + w1dy * wingLen;
   double w2ex = (double)x2 + w2dx * wingLen;
   double w2ey = (double)y2 + w2dy * wingLen;
   //--- Test cursor proximity to each wing segment
   for(int w = 0; w < 2; w++)
     {
      //--- Pick the active wing endpoint for this iteration
      double ex = (w == 0) ? w1ex : w2ex;
      double ey = (w == 0) ? w1ey : w2ey;
      double wdx = ex - (double)x2;
      double wdy = ey - (double)y2;
      double wlen2 = wdx * wdx + wdy * wdy;
      if(wlen2 < 1e-9) continue;
      //--- Project the cursor onto the wing segment with clamping
      double tw = (((double)mx - (double)x2) * wdx + ((double)my - (double)y2) * wdy) / wlen2;
      if(tw < 0.0) tw = 0.0;
      if(tw > 1.0) tw = 1.0;
      //--- Compute the closest point on the wing and the distance to the cursor
      double wqx = (double)x2 + tw * wdx;
      double wqy = (double)y2 + tw * wdy;
      double wd = MathSqrt((mx - wqx)*(mx - wqx) + (my - wqy)*(my - wqy));
      if(wd <= threshold) return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
//| Compute the 6 silhouette vertices for an Arrow Marker dart       |
//+------------------------------------------------------------------+
void CAnnotationTools::ComputeArrowMarkerVerts(int x1, int y1, int x2, int y2,
                                                double &vx[], double &vy[])
  {
   //--- Allocate the 6-vertex polygon arrays
   ArrayResize(vx, 6);
   ArrayResize(vy, 6);
   //--- Compute the tail-to-tip direction vector and length
   double dxS = (double)(x2 - x1);
   double dyS = (double)(y2 - y1);
   double lenS = MathSqrt(dxS * dxS + dyS * dyS);
   //--- Degenerate (zero-length) marker: collapse all vertices to the tail
   if(lenS < 1.0)
     {
      for(int i = 0; i < 6; i++) { vx[i] = x1; vy[i] = y1; }
      return;
     }
   //--- Compute unit forward and perpendicular vectors
   double ux = dxS / lenS;
   double uy = dyS / lenS;
   double nx = -uy;
   double ny =  ux;
   //--- Compute axial positions for the wing and shaft-base junctions
   double wingAlong      = lenS * 0.67;
   double shaftBaseAlong = lenS * 0.72;
   double wgX = (double)x1 + ux * wingAlong;
   double wgY = (double)y1 + uy * wingAlong;
   double sbX = (double)x1 + ux * shaftBaseAlong;
   double sbY = (double)y1 + uy * shaftBaseAlong;
   //--- Compute the shaft and head half-widths proportional to length
   double shaftHalfW = lenS * 0.060;
   double headHalfW  = lenS * 0.140;
   //--- Fill the 6 vertices in CCW order starting from the tail
   vx[0] = (double)x1;
   vy[0] = (double)y1;
   vx[1] = sbX + nx * shaftHalfW;
   vy[1] = sbY + ny * shaftHalfW;
   vx[2] = wgX + nx * headHalfW;
   vy[2] = wgY + ny * headHalfW;
   vx[3] = (double)x2;
   vy[3] = (double)y2;
   vx[4] = wgX - nx * headHalfW;
   vy[4] = wgY - ny * headHalfW;
   vx[5] = sbX - nx * shaftHalfW;
   vy[5] = sbY - ny * shaftHalfW;
  }

//+------------------------------------------------------------------+
//| Draw an Arrow Marker silhouette via SDF AA pass                  |
//+------------------------------------------------------------------+
void CAnnotationTools::DrawArrowMarkerOn(CCanvas &canvas,
                                          int x1, int y1, int x2, int y2,
                                          color objColor, bool selected, bool hovered,
                                          bool outlineOnly,
                                          int lineOpacity)
  {
   //--- Compute the silhouette vertices via the geometry helper
   double vx[], vy[];
   ComputeArrowMarkerVerts(x1, y1, x2, y2, vx, vy);
   //--- Compute the tail-to-tip distance for the degenerate check
   double dxS = (double)(x2 - x1);
   double dyS = (double)(y2 - y1);
   double lenS = MathSqrt(dxS * dxS + dyS * dyS);
   //--- Degenerate marker: just render the handles
   if(lenS < 1.0)
     {
      if(selected || hovered)
        {
         if(m_hideHandleIdx != 0) DrawHandleOnCanvas(canvas, x1, y1, selected, objColor, m_haloHandleIdx == 0);
         if(m_hideHandleIdx != 1) DrawHandleOnCanvas(canvas, x2, y2, selected, objColor, m_haloHandleIdx == 1);
        }
      return;
     }
   //--- Extract ARGB components for the fill blend
   uint  fullArgb = ColorWithPercentOpacity(objColor, lineOpacity);
   uint  rgbMask  = fullArgb & 0x00FFFFFF;
   uchar baseA    = (uchar)((fullArgb >> 24) & 0xFF);
   //--- Compute the polygon's axis-aligned bounding box
   double bMinX = vx[0], bMaxX = vx[0];
   double bMinY = vy[0], bMaxY = vy[0];
   for(int k = 1; k < 6; k++)
     {
      if(vx[k] < bMinX) bMinX = vx[k];
      if(vx[k] > bMaxX) bMaxX = vx[k];
      if(vy[k] < bMinY) bMinY = vy[k];
      if(vy[k] > bMaxY) bMaxY = vy[k];
     }
   //--- Pad bounding box for AA and clamp to canvas bounds
   int xLo = (int)MathFloor(bMinX) - 2;
   int xHi = (int)MathCeil (bMaxX) + 2;
   int yLo = (int)MathFloor(bMinY) - 2;
   int yHi = (int)MathCeil (bMaxY) + 2;
   int cW = canvas.Width(), cH = canvas.Height();
   if(xLo < 0)   xLo = 0;
   if(yLo < 0)   yLo = 0;
   if(xHi >= cW) xHi = cW - 1;
   if(yHi >= cH) yHi = cH - 1;
   //--- Single SDF AA pass over the bounding box
   for(int yy = yLo; yy <= yHi; yy++)
     {
      for(int xx = xLo; xx <= xHi; xx++)
        {
         //--- Cast pixel coordinates to doubles for the SDF evaluation
         double px = (double)xx, py = (double)yy;
         //--- Compute the minimum distance from the pixel to any polygon edge
         double polyDist = 1e18;
         for(int e = 0; e < 6; e++)
           {
            //--- Compute the segment vector for this edge
            int nexte = (e + 1) % 6;
            double sdx = vx[nexte] - vx[e];
            double sdy = vy[nexte] - vy[e];
            double slen2 = sdx * sdx + sdy * sdy;
            //--- Project the pixel onto the segment and clamp the parameter
            double tSeg = 0.0;
            if(slen2 > 1e-12)
               tSeg = ((px - vx[e]) * sdx + (py - vy[e]) * sdy) / slen2;
            if(tSeg < 0.0) tSeg = 0.0;
            if(tSeg > 1.0) tSeg = 1.0;
            //--- Compute the closest segment point and its distance to the pixel
            double qx = vx[e] + tSeg * sdx;
            double qy = vy[e] + tSeg * sdy;
            double ddx = px - qx, ddy = py - qy;
            double d = MathSqrt(ddx * ddx + ddy * ddy);
            if(d < polyDist) polyDist = d;
           }
         //--- Sign the distance by polygon containment
         bool inside = PointInArrowMarker(px, py, vx, vy);
         double signedDist = inside ? polyDist : -polyDist;
         //--- Outline-only mode: paint a 1px AA stroke on the boundary
         if(outlineOnly)
           {
            //--- Convert signed distance into stroke coverage
            double halfThick = 0.5;
            double strokeCov = halfThick + 0.5 - MathAbs(signedDist);
            if(strokeCov <= 0.0) continue;
            if(strokeCov > 1.0) strokeCov = 1.0;
            //--- Blend the stroke pixel at the computed coverage
            uchar aCov = (uchar)((double)baseA * strokeCov + 0.5);
            uint argb = ((uint)aCov << 24) | rgbMask;
            ChannelBlendPixelSet(canvas, xx, yy, argb);
            continue;
           }
         //--- Filled mode: convert signed distance into coverage and blend
         double cov = 0.5 + signedDist;
         if(cov <= 0.0) continue;
         if(cov > 1.0) cov = 1.0;
         uchar aCov = (uchar)((double)baseA * cov + 0.5);
         uint argb = ((uint)aCov << 24) | rgbMask;
         ChannelBlendPixelSet(canvas, xx, yy, argb);
        }
     }
   //--- Draw selection handles at the tail and tip
   if(selected || hovered)
     {
      if(m_hideHandleIdx != 0) DrawHandleOnCanvas(canvas, x1, y1, selected, objColor, m_haloHandleIdx == 0);
      if(m_hideHandleIdx != 1) DrawHandleOnCanvas(canvas, x2, y2, selected, objColor, m_haloHandleIdx == 1);
     }
  }

//+------------------------------------------------------------------+
//| Hit-test for an Arrow Marker silhouette                          |
//+------------------------------------------------------------------+
bool CAnnotationTools::HitTestArrowMarker(int mx, int my, int x1, int y1, int x2, int y2, int threshold)
  {
   //--- Compute the silhouette vertices and the degenerate threshold
   double vx[], vy[];
   ComputeArrowMarkerVerts(x1, y1, x2, y2, vx, vy);
   double dxS = (double)(x2 - x1);
   double dyS = (double)(y2 - y1);
   double lenS = MathSqrt(dxS * dxS + dyS * dyS);
   //--- Degenerate marker: test tail-point proximity
   if(lenS < 1.0)
     {
      double d = MathSqrt((double)(mx-x1)*(mx-x1) + (double)(my-y1)*(my-y1));
      return d <= threshold;
     }
   //--- Test cursor containment in the polygon
   return PointInArrowMarker((double)mx, (double)my, vx, vy);
  }

//+------------------------------------------------------------------+
//| Compute the 7 silhouette vertices for an Arrow Up/Down marker    |
//+------------------------------------------------------------------+
void CAnnotationTools::ComputeArrowUpDownVerts(int ax, int ay, bool pointsUp,
                                                double &vx[], double &vy[])
  {
   //--- Allocate the 7-vertex polygon arrays
   ArrayResize(vx, 7);
   ArrayResize(vy, 7);
   //--- yDir flips the Y layout based on the pointing direction
   double yDir = pointsUp ? 1.0 : -1.0;
   double apex_x = (double)ax;
   double apex_y = (double)ay;
   //--- Compute the head-base Y where the wings attach
   double headBaseY = apex_y + yDir * ARROW_UPDOWN_HEAD_LEN;
   //--- Compute the back-of-shaft Y
   double baseY     = apex_y + yDir * ARROW_UPDOWN_TOTAL_H;
   //--- Fill the 7 vertices: apex, right wing, shaft-junction R, base R, base L, shaft-junction L, left wing
   vx[0] = apex_x;                                  vy[0] = apex_y;
   vx[1] = apex_x + ARROW_UPDOWN_HEAD_HW;           vy[1] = headBaseY;
   vx[2] = apex_x + ARROW_UPDOWN_SHAFT_HW;          vy[2] = headBaseY;
   vx[3] = apex_x + ARROW_UPDOWN_SHAFT_HW;          vy[3] = baseY;
   vx[4] = apex_x - ARROW_UPDOWN_SHAFT_HW;          vy[4] = baseY;
   vx[5] = apex_x - ARROW_UPDOWN_SHAFT_HW;          vy[5] = headBaseY;
   vx[6] = apex_x - ARROW_UPDOWN_HEAD_HW;           vy[6] = headBaseY;
  }

//+------------------------------------------------------------------+
//| Draw an Arrow Up/Down silhouette via single-pass SDF AA          |
//+------------------------------------------------------------------+
void CAnnotationTools::DrawArrowUpDownOn(CCanvas &canvas,
                                          int ax, int ay,
                                          bool pointsUp,
                                          color objColor, bool selected, bool hovered,
                                          bool outlineOnly,
                                          int lineOpacity)
  {
   //--- Compute the 7-vertex silhouette via the geometry helper
   double vx[], vy[];
   ComputeArrowUpDownVerts(ax, ay, pointsUp, vx, vy);
   //--- Extract ARGB components for the fill blend
   uint  fullArgb = ColorWithPercentOpacity(objColor, lineOpacity);
   uint  rgbMask  = fullArgb & 0x00FFFFFF;
   uchar baseA    = (uchar)((fullArgb >> 24) & 0xFF);
   //--- Compute the polygon's axis-aligned bounding box
   double bMinX = vx[0], bMaxX = vx[0];
   double bMinY = vy[0], bMaxY = vy[0];
   for(int k = 1; k < 7; k++)
     {
      if(vx[k] < bMinX) bMinX = vx[k];
      if(vx[k] > bMaxX) bMaxX = vx[k];
      if(vy[k] < bMinY) bMinY = vy[k];
      if(vy[k] > bMaxY) bMaxY = vy[k];
     }
   //--- Pad bounding box for AA and clamp to canvas bounds
   int xLo = (int)MathFloor(bMinX) - 2;
   int xHi = (int)MathCeil (bMaxX) + 2;
   int yLo = (int)MathFloor(bMinY) - 2;
   int yHi = (int)MathCeil (bMaxY) + 2;
   int cW = canvas.Width(), cH = canvas.Height();
   if(xLo < 0)   xLo = 0;
   if(yLo < 0)   yLo = 0;
   if(xHi >= cW) xHi = cW - 1;
   if(yHi >= cH) yHi = cH - 1;
   //--- Single SDF AA fill pass over the bounding box
   for(int yy = yLo; yy <= yHi; yy++)
     {
      for(int xx = xLo; xx <= xHi; xx++)
        {
         //--- Cast pixel coordinates to doubles for the SDF evaluation
         double px = (double)xx, py = (double)yy;
         //--- Find the minimum distance from the pixel to any polygon edge
         double polyDist = 1e18;
         for(int e = 0; e < 7; e++)
           {
            //--- Compute the segment vector for this edge
            int nexte = (e + 1) % 7;
            double sdx = vx[nexte] - vx[e];
            double sdy = vy[nexte] - vy[e];
            double slen2 = sdx * sdx + sdy * sdy;
            //--- Project the pixel onto the segment and clamp the parameter
            double tSeg = 0.0;
            if(slen2 > 1e-12)
               tSeg = ((px - vx[e]) * sdx + (py - vy[e]) * sdy) / slen2;
            if(tSeg < 0.0) tSeg = 0.0;
            if(tSeg > 1.0) tSeg = 1.0;
            //--- Compute the closest segment point and its distance to the pixel
            double qx = vx[e] + tSeg * sdx;
            double qy = vy[e] + tSeg * sdy;
            double ddx = px - qx, ddy = py - qy;
            double d = MathSqrt(ddx * ddx + ddy * ddy);
            if(d < polyDist) polyDist = d;
           }
         //--- Sign the distance by polygon containment
         bool inside = PointInArrowUpDown(px, py, vx, vy);
         double signedDist = inside ? polyDist : -polyDist;
         //--- Outline-only path: paint a 1px AA stroke
         if(outlineOnly)
           {
            //--- Convert signed distance into stroke coverage
            double halfThick = 0.5;
            double strokeCov = halfThick + 0.5 - MathAbs(signedDist);
            if(strokeCov <= 0.0) continue;
            if(strokeCov > 1.0) strokeCov = 1.0;
            //--- Blend the stroke pixel at the computed coverage
            uchar aCov = (uchar)((double)baseA * strokeCov + 0.5);
            uint argb = ((uint)aCov << 24) | rgbMask;
            ChannelBlendPixelSet(canvas, xx, yy, argb);
            continue;
           }
         //--- Filled path: convert signed distance into coverage and blend
         double cov = 0.5 + signedDist;
         if(cov <= 0.0) continue;
         if(cov > 1.0) cov = 1.0;
         uchar aCov = (uchar)((double)baseA * cov + 0.5);
         uint argb = ((uint)aCov << 24) | rgbMask;
         ChannelBlendPixelSet(canvas, xx, yy, argb);
        }
     }
   //--- Draw the single apex handle on selection or hover
   if(selected || hovered)
     {
      if(m_hideHandleIdx != 0) DrawHandleOnCanvas(canvas, ax, ay, selected, objColor, m_haloHandleIdx == 0);
     }
  }

//+------------------------------------------------------------------+
//| Hit-test for an Arrow Up/Down marker                             |
//+------------------------------------------------------------------+
bool CAnnotationTools::HitTestArrowUpDown(int mx, int my, int ax, int ay, bool pointsUp, int threshold)
  {
   //--- Compute the silhouette and test cursor containment
   double vx[], vy[];
   ComputeArrowUpDownVerts(ax, ay, pointsUp, vx, vy);
   return PointInArrowUpDown((double)mx, (double)my, vx, vy);
  }

//+------------------------------------------------------------------+
//| Compute the Note rectangle bounds with edge-midpoint attach      |
//+------------------------------------------------------------------+
void CAnnotationTools::ComputeNoteBox(int p1x, int p1y, int p2x, int p2y,
                                       const string committedText,
                                       bool isEditing, const string editBuffer,
                                       int &outL, int &outT, int &outR, int &outB,
                                       int fontSize)
  {
   //--- Resolve the text used for sizing the rectangle
   string content    = isEditing ? editBuffer : committedText;
   bool   hasContent = (StringLen(content) > 0);
   string measure;
   if(isEditing && !hasContent)
      measure = "Add text";
   else if(StringLen(content) > 0)
      measure = content;
   else
      measure = "  ";
   //--- Measure the multi-line text block via the shared helper
   int textW = 0, textH = 0, lineH = 0;
   MeasureTextBlock(measure, "Arial", fontSize, textW, textH, lineH);
   if(textW < 1) textW = 1;
   if(textH < 1) textH = lineH;
   //--- Compute the total box dimensions including padding and cursor slack
   int cursorReserve = 2;
   int padX = 10;
   int padY = 6;
   int boxW = textW + cursorReserve + 2 * padX;
   int boxH = textH + 2 * padY;
   //--- Pick the attaching edge based on the dominant direction from P1 to P2
   int dx = p2x - p1x;
   int dy = p2y - p1y;
   bool horizontalDominant = (MathAbs(dx) >= MathAbs(dy));
   if(horizontalDominant)
     {
      //--- Horizontal dominant: attach the rect's left or right edge midpoint at P2
      if(dx >= 0)
        { outL = p2x; outR = p2x + boxW; }
      else
        { outR = p2x; outL = p2x - boxW; }
      outT = p2y - boxH / 2;
      outB = outT + boxH;
     }
   else
     {
      //--- Vertical dominant: attach the rect's top or bottom edge midpoint at P2
      if(dy >= 0)
        { outT = p2y; outB = p2y + boxH; }
      else
        { outB = p2y; outT = p2y - boxH; }
      outL = p2x - boxW / 2;
      outR = outL + boxW;
     }
  }

//+------------------------------------------------------------------+
//| Draw a Note (anchor dot, connector line, rect with text)         |
//+------------------------------------------------------------------+
void CAnnotationTools::DrawNoteOn(CCanvas &canvas,
                                   int p1x, int p1y, int p2x, int p2y,
                                   const string committedText,
                                   bool isEditing, const string editBuffer,
                                   int caretPos,
                                   color objColor, bool selected, bool hovered,
                                   int &outBoxL, int &outBoxT, int &outBoxR, int &outBoxB,
                                   int lineOpacity, int fontSize, bool bold,
                                   color fillColor, int fillOpacity,
                                   color textColor, int textOpacity)
  {
   //--- Clamp all opacity values to [0, 100]
   if(lineOpacity < 0)   lineOpacity = 0;
   if(lineOpacity > 100) lineOpacity = 100;
   if(fillOpacity < 0)   fillOpacity = 0;
   if(fillOpacity > 100) fillOpacity = 100;
   if(textOpacity < 0)   textOpacity = 0;
   if(textOpacity > 100) textOpacity = 100;
   //--- Clamp the font size to a sane range
   if(fontSize < 6)  fontSize = 6;
   if(fontSize > 32) fontSize = 32;
   //--- Resolve the effective fill color (user-set or chart background)
   color effFillColor = (fillColor == clrNONE)
                         ? (color)ChartGetInteger(0, CHART_COLOR_BACKGROUND)
                         : fillColor;
   //--- Resolve the effective text color (user-set or object color)
   color effTextColor = (textColor == clrNONE) ? objColor : textColor;
   //--- Compose the connector line ARGB at the requested opacity
   uint  connectorArgb = ColorWithPercentOpacity(objColor, lineOpacity);
   //--- Compute the rectangle bounds via the shared geometry helper
   int boxL=0, boxT=0, boxR=0, boxB=0;
   ComputeNoteBox(p1x, p1y, p2x, p2y, committedText, isEditing, editBuffer,
                   boxL, boxT, boxR, boxB, fontSize);
   outBoxL = boxL; outBoxT = boxT; outBoxR = boxR; outBoxB = boxB;
   int boxW = boxR - boxL;
   int boxH = boxB - boxT;
   int radius = 4;
   //--- Draw the soft drop shadow first so the rect renders on top
   DrawNoteDropShadow(canvas, boxL, boxT, boxR, boxB, radius);
   //--- Draw the connector line between the anchor point and the rectangle
   DrawNoteConnectorLine(canvas, (double)p1x, (double)p1y,
                          (double)p2x, (double)p2y, connectorArgb);
   //--- Fill the rounded rectangle body
   uint rectFillArgb = ColorWithPercentOpacity(effFillColor, fillOpacity);
   FillNoteRoundRect(canvas, boxL, boxT, boxR, boxB, radius, rectFillArgb);
   //--- Resolve which text to render (committed, placeholder, or buffer)
   string labelPart  = isEditing ? editBuffer : committedText;
   bool   hasContent = (StringLen(labelPart) > 0);
   bool   usePlaceholder = isEditing && !hasContent;
   string renderText = usePlaceholder ? "Add text" : labelPart;
   int effectiveCaret = usePlaceholder ? 0 : caretPos;
   //--- Compute the inner text rectangle from rect padding
   int textL = boxL + 10;
   int textT = boxT + 6;
   int textR = boxR - 10;
   int textB = boxB - 6;
   //--- Center the text block within the rectangle interior
   if(StringLen(renderText) > 0)
     {
      //--- Measure the wrapped block for centering math
      int measW = 0, measH = 0, measLineH = 0;
      MeasureTextBlock(renderText, "Arial", fontSize, measW, measH, measLineH);
      //--- Vertically center if the block is shorter than the available height
      int avail = (boxB - boxT) - 12;
      if(measH < avail)
         textT = boxT + 6 + (avail - measH) / 2;
      //--- Horizontally center if the block is narrower than the available width
      int availW = (boxB - boxT > 0) ? (boxR - boxL) - 20 : 0;
      if(availW > 0 && measW < availW)
         textL = boxL + 10 + (availW - measW) / 2;
     }
   //--- Render the text into the rectangle interior
   if(StringLen(renderText) > 0 || isEditing)
     {
      RenderEditableTextBlockAA(canvas, renderText, isEditing, effectiveCaret,
                                  textL, textT, boxL + 10, boxT + 6,
                                  boxR - 10, boxB - 6,
                                  "Arial", fontSize, effTextColor, effTextColor,
                                  0, bold, 0, 0, textOpacity);
     }
   //--- Render the anchor dot only when idle (the handle takes over on hover/select)
   if(!(selected || hovered))
     {
      int dotR = 3;
      //--- Paint a small AA-filled disc at P1
      for(int dy = -dotR; dy <= dotR; dy++)
        {
         for(int dx = -dotR; dx <= dotR; dx++)
           {
            //--- Subsample inside the candidate pixel to compute coverage
            double sub = 4.0;
            int inside = 0, tot = 0;
            for(int sy = 0; sy < 4; sy++)
               for(int sx = 0; sx < 4; sx++)
                 {
                  //--- Compute the subpixel sample offset and test against the disc
                  double sdx = dx - 0.5 + (sx + 0.5) / sub;
                  double sdy = dy - 0.5 + (sy + 0.5) / sub;
                  if(sdx * sdx + sdy * sdy <= (double)dotR * dotR) inside++;
                  tot++;
                 }
            if(inside == 0) continue;
            //--- Compose the dot pixel ARGB at the coverage alpha
            uchar aCov = (uchar)(255 * inside / tot);
            uint dotArgb = ((uint)aCov << 24) | (connectorArgb & 0x00FFFFFF);
            int px = p1x + dx, py = p1y + dy;
            if(px >= 0 && py >= 0 && px < canvas.Width() && py < canvas.Height())
               BlendPxNote(canvas, px, py, dotArgb);
           }
        }
     }
   //--- Draw selection handles at P1 and P2
   if(selected || hovered)
     {
      if(m_hideHandleIdx != 0) DrawHandleOnCanvas(canvas, p1x, p1y, selected, objColor, m_haloHandleIdx == 0);
      if(m_hideHandleIdx != 1) DrawHandleOnCanvas(canvas, p2x, p2y, selected, objColor, m_haloHandleIdx == 1);
     }
  }

//+------------------------------------------------------------------+
//| Hit-test for a Note (rect, connector line, or anchor dot)        |
//+------------------------------------------------------------------+
bool CAnnotationTools::HitTestNote(int mx, int my,
                                    int p1x, int p1y, int p2x, int p2y,
                                    const string committedText,
                                    bool isEditing, const string editBuffer,
                                    int fontSize)
  {
   //--- Compute the rectangle bounds via the shared geometry helper
   int boxL=0, boxT=0, boxR=0, boxB=0;
   ComputeNoteBox(p1x, p1y, p2x, p2y, committedText, isEditing, editBuffer,
                   boxL, boxT, boxR, boxB, fontSize);
   //--- Inside the rectangle counts as a hit
   if(mx >= boxL && mx <= boxR && my >= boxT && my <= boxB) return true;
   //--- Inside the small anchor dot counts as a hit
   double dotR = 4.0;
   double dxP = mx - p1x, dyP = my - p1y;
   if(dxP * dxP + dyP * dyP <= dotR * dotR) return true;
   //--- Near the connector line counts as a hit
   double dx = p2x - p1x, dy = p2y - p1y;
   double len2 = dx * dx + dy * dy;
   if(len2 > 1e-6)
     {
      //--- Project (mx, my) onto the line and clamp to the segment
      double t = ((mx - p1x) * dx + (my - p1y) * dy) / len2;
      if(t < 0) t = 0; else if(t > 1) t = 1;
      //--- Compute the closest segment point and its distance to the cursor
      double qx = p1x + t * dx, qy = p1y + t * dy;
      double d  = MathSqrt((mx - qx)*(mx - qx) + (my - qy)*(my - qy));
      if(d <= 4.0) return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
//| Draw a Price Note (Note variant showing the formatted price)     |
//+------------------------------------------------------------------+
void CAnnotationTools::DrawPriceNoteOn(CCanvas &canvas,
                                        int p1x, int p1y, int p2x, int p2y,
                                        double anchorPrice,
                                        color objColor, bool selected, bool hovered,
                                        int &outBoxL, int &outBoxT, int &outBoxR, int &outBoxB,
                                        int lineOpacity, int fontSize,
                                        color fillColor, int fillOpacity,
                                        color textColor, int textOpacity)
  {
   //--- Clamp all opacity values to [0, 100]
   if(lineOpacity < 0)   lineOpacity = 0;
   if(lineOpacity > 100) lineOpacity = 100;
   if(fillOpacity < 0)   fillOpacity = 0;
   if(fillOpacity > 100) fillOpacity = 100;
   if(textOpacity < 0)   textOpacity = 0;
   if(textOpacity > 100) textOpacity = 100;
   //--- Clamp the font size to a sane range
   if(fontSize < 6)  fontSize = 6;
   if(fontSize > 32) fontSize = 32;
   //--- Format the anchor price to the symbol's digit precision
   int digits = (int)_Digits;
   string priceText = DoubleToString(anchorPrice, digits);
   //--- Resolve effective colors (defaults preserve the legacy white-on-blue look)
   color effFillColor = (fillColor == clrNONE) ? objColor : fillColor;
   color effTextColor = (textColor == clrNONE) ? clrWhite : textColor;
   uint  fillArgb = ColorWithPercentOpacity(effFillColor, fillOpacity);
   uint  textArgb = ColorWithPercentOpacity(effTextColor, textOpacity);
   //--- Measure the price text at the user font size
   int measureFontSize = fontSize;
   TextSetFont("Arial", -(measureFontSize * 10));
   uint measTwU = 0, measThU = 0;
   TextGetSize(priceText, measTwU, measThU);
   int measTw = (int)measTwU;
   int measTh = (int)measThU;
   if(measTw < 1) measTw = 1;
   if(measTh < 1) measTh = 1;
   //--- Compute total box dimensions including padding
   int padX = 8;
   int padY = 4;
   int boxW = measTw + 2 * padX;
   int boxH = measTh + 2 * padY;
   //--- Pick the attaching edge based on the dominant direction P1 to P2
   int ddx = p2x - p1x;
   int ddy = p2y - p1y;
   bool horizontalDominant = (MathAbs(ddx) >= MathAbs(ddy));
   int boxL = 0, boxT = 0, boxR = 0, boxB = 0;
   if(horizontalDominant)
     {
      //--- Horizontal dominant: attach left or right edge midpoint at P2
      if(ddx >= 0) { boxL = p2x; boxR = p2x + boxW; }
      else         { boxR = p2x; boxL = p2x - boxW; }
      boxT = p2y - boxH / 2;
      boxB = boxT + boxH;
     }
   else
     {
      //--- Vertical dominant: attach top or bottom edge midpoint at P2
      if(ddy >= 0) { boxT = p2y; boxB = p2y + boxH; }
      else         { boxB = p2y; boxT = p2y - boxH; }
      boxL = p2x - boxW / 2;
      boxR = boxL + boxW;
     }
   outBoxL = boxL; outBoxT = boxT; outBoxR = boxR; outBoxB = boxB;
   //--- Corner radius is one px larger than Note for a slightly softer look
   int radius = 4;
   //--- Draw the connector line first so the rect overlays it cleanly
   DrawNoteConnectorLine(canvas, (double)p1x, (double)p1y,
                          (double)p2x, (double)p2y, fillArgb);
   //--- Fill the rounded rectangle body
   FillNoteRoundRect(canvas, boxL, boxT, boxR, boxB, radius, fillArgb);
   //--- Render the price text using plain TextOut into a small buffer
   TextSetFont("Arial", -(fontSize * 10));
   uint twU = 0, thU = 0;
   TextGetSize(priceText, twU, thU);
   int tw = (int)twU;
   int th = (int)thU;
   if(tw > 0 && th > 0)
     {
      //--- Center the text horizontally and vertically within the box
      int textScreenX = boxL + (boxW - tw) / 2;
      int textScreenY = boxT + (boxH - th) / 2;
      //--- Allocate a buffer pre-filled with the fill RGB so AA blends correctly
      uint tBuf[];
      int tTot = tw * th;
      ArrayResize(tBuf, tTot);
      uint fillRgb = fillArgb & 0x00FFFFFF;
      ArrayFill(tBuf, 0, tTot, fillRgb);
      //--- Render the price string into the buffer
      uint penRgb = textArgb & 0x00FFFFFF;
      TextOut(priceText, 0, 0, TA_LEFT | TA_TOP, tBuf, tw, th,
              penRgb, COLOR_FORMAT_XRGB_NOALPHA);
      //--- Composite the buffer onto the canvas at text opacity
      const uchar textBaseA = (uchar)((textArgb >> 24) & 0xFF);
      for(int py = 0; py < th; py++)
        {
         //--- Compute the canvas target Y row with clipping
         int targetY = textScreenY + py;
         if(targetY < 0 || targetY >= canvas.Height()) continue;
         for(int px = 0; px < tw; px++)
           {
            //--- Compute the canvas target X column with clipping
            int targetX = textScreenX + px;
            if(targetX < 0 || targetX >= canvas.Width()) continue;
            //--- Extract this pixel's RGB and skip cells that are still pure fill
            uint pixel = tBuf[py * tw + px] & 0x00FFFFFF;
            if(pixel == fillRgb) continue;
            //--- Compose the final glyph pixel and blend onto the canvas
            uint argb = ((uint)textBaseA << 24) | pixel;
            BlendPxNote(canvas, targetX, targetY, argb);
           }
        }
     }
   //--- Render the anchor dot only when idle
   if(!(selected || hovered))
     {
      int dotR = 3;
      //--- Paint a small AA-filled disc at P1
      for(int dy = -dotR; dy <= dotR; dy++)
        {
         for(int dx = -dotR; dx <= dotR; dx++)
           {
            //--- Subsample inside the candidate pixel for coverage
            double sub = 4.0;
            int inside = 0, tot = 0;
            for(int sy = 0; sy < 4; sy++)
               for(int sx = 0; sx < 4; sx++)
                 {
                  //--- Compute the subpixel sample offset and test against the disc
                  double sdx = dx - 0.5 + (sx + 0.5) / sub;
                  double sdy = dy - 0.5 + (sy + 0.5) / sub;
                  if(sdx * sdx + sdy * sdy <= (double)dotR * dotR) inside++;
                  tot++;
                 }
            if(inside == 0) continue;
            //--- Compose the dot pixel ARGB at the coverage alpha
            uchar aCov = (uchar)(255 * inside / tot);
            uint dotArgb = ((uint)aCov << 24) | (fillArgb & 0x00FFFFFF);
            int px = p1x + dx, py = p1y + dy;
            if(px >= 0 && py >= 0 && px < canvas.Width() && py < canvas.Height())
               BlendPxNote(canvas, px, py, dotArgb);
           }
        }
     }
   //--- Draw selection handles at P1 and P2
   if(selected || hovered)
     {
      if(m_hideHandleIdx != 0) DrawHandleOnCanvas(canvas, p1x, p1y, selected, objColor, m_haloHandleIdx == 0);
      if(m_hideHandleIdx != 1) DrawHandleOnCanvas(canvas, p2x, p2y, selected, objColor, m_haloHandleIdx == 1);
     }
  }

//+------------------------------------------------------------------+
//| Hit-test for a Price Note                                        |
//+------------------------------------------------------------------+
bool CAnnotationTools::HitTestPriceNote(int mx, int my,
                                         int p1x, int p1y, int p2x, int p2y,
                                         double anchorPrice,
                                         int fontSize)
  {
   //--- Clamp the font size to match the draw path
   if(fontSize < 6)  fontSize = 6;
   if(fontSize > 32) fontSize = 32;
   //--- Format and measure the price text
   int digits = (int)_Digits;
   string priceText = DoubleToString(anchorPrice, digits);
   int measureFontSize = fontSize;
   TextSetFont("Arial", -(measureFontSize * 10));
   uint measTwU = 0, measThU = 0;
   TextGetSize(priceText, measTwU, measThU);
   int measTw = (int)measTwU;
   int measTh = (int)measThU;
   if(measTw < 1) measTw = 1;
   if(measTh < 1) measTh = 1;
   //--- Compute box dimensions using the same padding as the draw path
   int padX = 8;
   int padY = 4;
   int boxW = measTw + 2 * padX;
   int boxH = measTh + 2 * padY;
   //--- Replicate the edge-attach logic to find the rectangle bounds
   int ddx = p2x - p1x;
   int ddy = p2y - p1y;
   bool horizontalDominant = (MathAbs(ddx) >= MathAbs(ddy));
   int boxL, boxT, boxR, boxB;
   if(horizontalDominant)
     {
      //--- Horizontal dominant: attach left or right edge midpoint at P2
      if(ddx >= 0) { boxL = p2x; boxR = p2x + boxW; }
      else         { boxR = p2x; boxL = p2x - boxW; }
      boxT = p2y - boxH / 2;
      boxB = boxT + boxH;
     }
   else
     {
      //--- Vertical dominant: attach top or bottom edge midpoint at P2
      if(ddy >= 0) { boxT = p2y; boxB = p2y + boxH; }
      else         { boxB = p2y; boxT = p2y - boxH; }
      boxL = p2x - boxW / 2;
      boxR = boxL + boxW;
     }
   //--- Inside the rectangle counts as a hit
   if(mx >= boxL && mx <= boxR && my >= boxT && my <= boxB) return true;
   //--- Inside the anchor dot counts as a hit
   double dotR = 4.0;
   double dxP = mx - p1x, dyP = my - p1y;
   if(dxP * dxP + dyP * dyP <= dotR * dotR) return true;
   //--- Near the connector line counts as a hit
   double dx = p2x - p1x, dy = p2y - p1y;
   double len2 = dx * dx + dy * dy;
   if(len2 > 1e-6)
     {
      //--- Project (mx, my) onto the connector segment and clamp
      double t = ((mx - p1x) * dx + (my - p1y) * dy) / len2;
      if(t < 0) t = 0; else if(t > 1) t = 1;
      //--- Compute the closest segment point and its distance to the cursor
      double qx = p1x + t * dx, qy = p1y + t * dy;
      double d  = MathSqrt((mx - qx) * (mx - qx) + (my - qy) * (my - qy));
      if(d <= 4.0) return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
//| Compute the Callout rectangle bounds plus shaft attach points    |
//+------------------------------------------------------------------+
void CAnnotationTools::ComputeCalloutGeometry(int p1x, int p1y, int p2x, int p2y,
                                                const string committedText,
                                                bool isEditing, const string editBuffer,
                                                int &outBoxL, int &outBoxT,
                                                int &outBoxR, int &outBoxB,
                                                int &outA1x, int &outA1y,
                                                int &outA2x, int &outA2y,
                                                ENUM_CALLOUT_ATTACH &outCase,
                                                int fontSize)
  {
   //--- Clamp the font size to a sane range
   if(fontSize < 6)  fontSize = 6;
   if(fontSize > 32) fontSize = 32;
   //--- Pick the sizing text and measure it via the shared helper
   string sizingText = (isEditing ? editBuffer : committedText);
   if(StringLen(sizingText) == 0) sizingText = "Add text";
   int textW = 0, textH = 0, lineH = 0;
   MeasureTextBlock(sizingText, "Arial", fontSize, textW, textH, lineH);
   if(textW < 1) textW = 1;
   if(textH < 1) textH = lineH;
   //--- Compute the total box dimensions with cursor slack and padding
   int cursorReserve = 2;
   int padX = 12;
   int padY = 8;
   int boxW = textW + cursorReserve + 2 * padX;
   int boxH = textH + 2 * padY;
   //--- Position the box centered on P2 and return the bounds
   int boxL = p2x - boxW / 2;
   int boxT = p2y - boxH / 2;
   int boxR = boxL + boxW;
   int boxB = boxT + boxH;
   outBoxL = boxL; outBoxT = boxT; outBoxR = boxR; outBoxB = boxB;
   //--- Compute the direction vector from rect center P2 to shaft tip P1
   int dx = p1x - p2x;
   int dy = p1y - p2y;
   int adx = (int)MathAbs(dx);
   int ady = (int)MathAbs(dy);
   //--- Use tan(67.5 degrees) as the threshold between edge and corner attach
   const double THR = 2.414;
   int cornerRadius = 4;
   int spEdge   = 6;
   int spCorner = 2;
   int a1x = 0, a1y = 0, a2x = 0, a2y = 0;
   ENUM_CALLOUT_ATTACH acase = CA_E;
   if((double)adx > THR * (double)ady)
     {
      //--- Dominant horizontal direction picks the east or west edge midpoint
      int midY = (boxT + boxB) / 2;
      if(dx > 0)
        {
         //--- East edge: a1 above midpoint, a2 below
         acase = CA_E;
         a1x = boxR; a1y = midY - spEdge;
         a2x = boxR; a2y = midY + spEdge;
        }
      else
        {
         //--- West edge: CW order runs bottom-to-top
         acase = CA_W;
         a1x = boxL; a1y = midY + spEdge;
         a2x = boxL; a2y = midY - spEdge;
        }
     }
   else if((double)ady > THR * (double)adx)
     {
      //--- Dominant vertical direction picks the north or south edge midpoint
      int midX = (boxL + boxR) / 2;
      if(dy > 0)
        {
         //--- South edge: CW order runs right-to-left
         acase = CA_S;
         a1x = midX + spEdge; a1y = boxB;
         a2x = midX - spEdge; a2y = boxB;
        }
      else
        {
         //--- North edge: CW order runs left-to-right
         acase = CA_N;
         a1x = midX - spEdge; a1y = boxT;
         a2x = midX + spEdge; a2y = boxT;
        }
     }
   else
     {
      //--- Diagonal direction picks one of the four corners
      if(dx > 0 && dy < 0)
        {
         //--- North-east corner: a1 on top edge, a2 on right edge
         acase = CA_NE;
         a1x = boxR - cornerRadius - spCorner; a1y = boxT;
         a2x = boxR; a2y = boxT + cornerRadius + spCorner;
        }
      else if(dx > 0 && dy > 0)
        {
         //--- South-east corner: a1 on right edge, a2 on bottom edge
         acase = CA_SE;
         a1x = boxR; a1y = boxB - cornerRadius - spCorner;
         a2x = boxR - cornerRadius - spCorner; a2y = boxB;
        }
      else if(dx < 0 && dy > 0)
        {
         //--- South-west corner: a1 on bottom edge, a2 on left edge
         acase = CA_SW;
         a1x = boxL + cornerRadius + spCorner; a1y = boxB;
         a2x = boxL; a2y = boxB - cornerRadius - spCorner;
        }
      else
        {
         //--- North-west corner: a1 on left edge, a2 on top edge
         acase = CA_NW;
         a1x = boxL; a1y = boxT + cornerRadius + spCorner;
         a2x = boxL + cornerRadius + spCorner; a2y = boxT;
        }
     }
   //--- Return the attach points and the chosen case
   outA1x = a1x; outA1y = a1y; outA2x = a2x; outA2y = a2y;
   outCase = acase;
  }

//+------------------------------------------------------------------+
//| Draw a Callout (rect plus shaft with continuous border and fill) |
//+------------------------------------------------------------------+
void CAnnotationTools::DrawCalloutOn(CCanvas &canvas,
                                      int p1x, int p1y, int p2x, int p2y,
                                      const string committedText,
                                      bool isEditing, const string editBuffer,
                                      int caretPos,
                                      color objColor, bool selected, bool hovered,
                                      int &outBoxL, int &outBoxT, int &outBoxR, int &outBoxB,
                                      int lineOpacity, int fontSize, bool bold,
                                      color fillColorArg, int fillOpacity,
                                      color textColorArg, int textOpacity)
  {
   //--- Clamp opacity inputs to [0, 100]
   if(lineOpacity < 0)   lineOpacity = 0;
   if(lineOpacity > 100) lineOpacity = 100;
   if(fillOpacity < 0)   fillOpacity = 0;
   if(fillOpacity > 100) fillOpacity = 100;
   if(textOpacity < 0)   textOpacity = 0;
   if(textOpacity > 100) textOpacity = 100;
   //--- Clamp the font size to a sane range
   if(fontSize < 6)  fontSize = 6;
   if(fontSize > 32) fontSize = 32;
   //--- Resolve effective fill, border, and text colors
   color borderColor = objColor;
   color fillColor   = (fillColorArg == clrNONE)
                        ? BrightenColor(borderColor, 35)
                        : fillColorArg;
   color textColorE  = (textColorArg == clrNONE) ? clrWhite : textColorArg;
   //--- Compose ARGB values for each element at its own opacity
   uint  fillArgb    = ColorWithPercentOpacity(fillColor,   fillOpacity);
   uint  borderArgb  = ColorWithPercentOpacity(borderColor, lineOpacity);
   uint  textArgb    = ColorWithPercentOpacity(textColorE,  textOpacity);
   //--- Compute the placeholder prompt ARGB at 50% of text opacity
   uchar promptA     = (uchar)(((double)textOpacity / 100.0) * 255 * 0.50 + 0.5);
   uint  promptArgb  = ((uint)promptA << 24) | (ColorToARGB(textColorE, 255) & 0x00FFFFFF);
   //--- Compute the callout geometry (box plus shaft attach points plus case)
   int boxL, boxT, boxR, boxB;
   int a1x, a1y, a2x, a2y;
   ENUM_CALLOUT_ATTACH acase;
   ComputeCalloutGeometry(p1x, p1y, p2x, p2y, committedText, isEditing, editBuffer,
                           boxL, boxT, boxR, boxB, a1x, a1y, a2x, a2y, acase,
                           fontSize);
   outBoxL = boxL; outBoxT = boxT; outBoxR = boxR; outBoxB = boxB;
   int boxW = boxR - boxL;
   int boxH = boxB - boxT;
   int cornerRadius = 4;
   //--- Hide the shaft entirely when P1 (the tip) falls inside the rect
   bool p1Inside = (p1x >= boxL && p1x <= boxR && p1y >= boxT && p1y <= boxB);
   //--- Render the silhouette body (rect plus optional shaft union)
   if(p1Inside)
     {
      //--- Shaft hidden: just fill the rect alone
      FillNoteRoundRect(canvas, boxL, boxT, boxR, boxB, cornerRadius, fillArgb);
     }
   else
     {
      //--- Compute the silhouette bounding box covering rect plus shaft tip
      int silL = boxL, silT = boxT, silR = boxR, silB = boxB;
      if(p1x < silL) silL = p1x;
      if(p1y < silT) silT = p1y;
      if(p1x > silR) silR = p1x;
      if(p1y > silB) silB = p1y;
      //--- Pad the silhouette bounding box for AA edges
      int silMargin = 2;
      silL -= silMargin; silT -= silMargin;
      silR += silMargin; silB += silMargin;
      int silW = silR - silL;
      int silH = silB - silT;
      if(silW <= 0 || silH <= 0) return;
      //--- Create a temporary canvas for the unified silhouette
      CCanvas tmpSil;
      if(tmpSil.Create("CalloutSilhouette_tmp", silW, silH, COLOR_FORMAT_ARGB_NORMALIZE))
        {
         tmpSil.Erase(0x00000000);
         //--- Render rect and triangle at full alpha so overlaps saturate cleanly
         uint solidArgb = (fillArgb & 0x00FFFFFF) | 0xFF000000;
         //--- Fill the rounded rectangle into the temp canvas
         FillNoteRoundRect(tmpSil,
                            boxL - silL, boxT - silT,
                            boxR - silL, boxB - silT,
                            cornerRadius, solidArgb);
         //--- Fill the shaft triangle into the temp canvas
         FillCalloutTriangle(tmpSil,
                              a1x - silL, a1y - silT,
                              p1x - silL, p1y - silT,
                              a2x - silL, a2y - silT,
                              solidArgb);
         //--- Composite the silhouette onto the main canvas
         int cW = canvas.Width(), cH = canvas.Height();
         for(int py = 0; py < silH; py++)
           {
            //--- Compute the canvas target Y row with clipping
            int targetY = silT + py;
            if(targetY < 0 || targetY >= cH) continue;
            for(int px = 0; px < silW; px++)
              {
               //--- Compute the canvas target X column with clipping
               int targetX = silL + px;
               if(targetX < 0 || targetX >= cW) continue;
               //--- Read the silhouette pixel and skip transparent samples
               uint p = tmpSil.PixelGet(px, py);
               uchar pa = (uchar)((p >> 24) & 0xFF);
               if(pa == 0) continue;
               //--- Use silhouette alpha directly to avoid double-blend seams
               uint outArgb = ((uint)pa << 24) | (p & 0x00FFFFFF);
               BlendPxNote(canvas, targetX, targetY, outArgb);
              }
           }
         //--- Release the temporary silhouette canvas
         tmpSil.Destroy();
        }
     }
   //--- Draw the continuous border around the silhouette
   if(p1Inside)
     {
      //--- Plain rounded-rect border: collapse the shaft segment to zero length
      int dummyX = (boxL + boxR) / 2;
      int dummyY = boxB;
      DrawCalloutBorder(canvas, boxL, boxT, boxR, boxB, cornerRadius,
                         dummyX, dummyY, dummyX, dummyY, dummyX, dummyY,
                         acase, borderArgb, 2);
     }
   else
     {
      //--- Full continuous border: rect outline plus shaft edges
      DrawCalloutBorder(canvas, boxL, boxT, boxR, boxB, cornerRadius,
                         a1x, a1y, a2x, a2y, p1x, p1y, acase, borderArgb, 2);
     }
   //--- Resolve the text content (committed, placeholder, or buffer)
   string labelPart = isEditing ? editBuffer : committedText;
   bool   hasContent = (StringLen(labelPart) > 0);
   bool   usePlaceholder = isEditing && !hasContent;
   string renderText = usePlaceholder ? "Add text" : labelPart;
   int effectiveCaret = usePlaceholder ? 0 : caretPos;
   //--- Center the text block within the rectangle and render it
   if(StringLen(renderText) > 0)
     {
      //--- Measure the wrapped block for centering math
      int measW = 0, measH = 0, measLineH = 0;
      MeasureTextBlock(renderText, "Arial", fontSize, measW, measH, measLineH);
      //--- Compute centered text origin with floor at padding edges
      int textL = boxL + 12 + (boxW - 24 - measW) / 2;
      int textT = boxT +  8 + (boxH - 16 - measH) / 2;
      if(textL < boxL + 12) textL = boxL + 12;
      if(textT < boxT +  8) textT = boxT +  8;
      //--- Render the text via the universal multi-line helper
      RenderEditableTextBlockAA(canvas, renderText, isEditing, effectiveCaret,
                                  textL, textT, boxL + 12, boxT + 8,
                                  boxR - 12, boxB - 8,
                                  "Arial", fontSize,
                                  textColorE, textColorE,
                                  0, bold, 0, 0,
                                  usePlaceholder ? (textOpacity / 2) : textOpacity);
     }
   //--- Draw the single P1 (shaft tip) handle on selection or hover
   if(selected || hovered)
     {
      if(m_hideHandleIdx != 0) DrawHandleOnCanvas(canvas, p1x, p1y, selected, objColor, m_haloHandleIdx == 0);
     }
  }

//+------------------------------------------------------------------+
//| Hit-test for a Callout (rect, shaft triangle, or P1 handle)      |
//+------------------------------------------------------------------+
bool CAnnotationTools::HitTestCallout(int mx, int my,
                                       int p1x, int p1y, int p2x, int p2y,
                                       const string text,
                                       bool isEditing, const string editBuffer,
                                       int fontSize)
  {
   //--- Compute the callout geometry via the shared helper
   int boxL, boxT, boxR, boxB;
   int a1x, a1y, a2x, a2y;
   ENUM_CALLOUT_ATTACH acase;
   ComputeCalloutGeometry(p1x, p1y, p2x, p2y, text, isEditing, editBuffer,
                           boxL, boxT, boxR, boxB, a1x, a1y, a2x, a2y, acase,
                           fontSize);
   //--- Inside the rectangle counts as a hit
   if(mx >= boxL && mx <= boxR && my >= boxT && my <= boxB) return true;
   //--- Skip shaft hit test when the shaft is hidden (P1 inside the rect)
   bool p1Inside = (p1x >= boxL && p1x <= boxR && p1y >= boxT && p1y <= boxB);
   if(!p1Inside)
     {
      //--- Edge-function test for the shaft triangle (a1, p1, a2)
      double e0 = (double)(p1x - a1x) * (double)(my - a1y) - (double)(p1y - a1y) * (double)(mx - a1x);
      double e1 = (double)(a2x - p1x) * (double)(my - p1y) - (double)(a2y - p1y) * (double)(mx - p1x);
      double e2 = (double)(a1x - a2x) * (double)(my - a2y) - (double)(a1y - a2y) * (double)(mx - a2x);
      //--- Inside test passes when all edge functions share the same sign
      if((e0 >= 0 && e1 >= 0 && e2 >= 0) ||
         (e0 <= 0 && e1 <= 0 && e2 <= 0))
         return true;
      //--- Near the P1 shaft-tip handle counts as a hit
      double dxP = mx - p1x, dyP = my - p1y;
      if(dxP * dxP + dyP * dyP <= 16.0) return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
//| Compute the Comment rectangle bounds (P1 = bottom-left corner)   |
//+------------------------------------------------------------------+
void CAnnotationTools::ComputeCommentBox(int p1x, int p1y,
                                          const string committedText,
                                          bool isEditing, const string editBuffer,
                                          int &outL, int &outT, int &outR, int &outB,
                                          int fontSize)
  {
   //--- Clamp the font size to a sane range
   if(fontSize < 6)  fontSize = 6;
   if(fontSize > 32) fontSize = 32;
   //--- Pick the sizing text for the auto-sized box
   string sizingText = (isEditing ? editBuffer : committedText);
   if(StringLen(sizingText) == 0) sizingText = "Add text";
   //--- Measure the multi-line text block via the shared helper
   int textW = 0, textH = 0, lineH = 0;
   MeasureTextBlock(sizingText, "Arial", fontSize, textW, textH, lineH);
   if(textW < 1) textW = 1;
   if(textH < 1) textH = lineH;
   //--- Compute padding and total box dimensions
   int cursorReserve = 2;
   int padY = 7;
   int boxH = textH + 2 * padY;
   int padX = boxH / 2 + 4;
   int boxW = textW + cursorReserve + 2 * padX;
   //--- P1 anchors the bottom-left corner; the rest follows
   outL = p1x;
   outB = p1y;
   outR = p1x + boxW;
   outT = p1y - boxH;
  }

//+------------------------------------------------------------------+
//| Draw a Comment (1-click rect with mixed corner radii)            |
//+------------------------------------------------------------------+
void CAnnotationTools::DrawCommentOn(CCanvas &canvas,
                                      int p1x, int p1y,
                                      const string committedText,
                                      bool isEditing, const string editBuffer,
                                      int caretPos,
                                      color objColor, bool selected, bool hovered,
                                      int &outBoxL, int &outBoxT, int &outBoxR, int &outBoxB,
                                      int lineOpacity, int fontSize, bool bold,
                                      color fillColorArg, int fillOpacity,
                                      color textColorArg, int textOpacity)
  {
   //--- Clamp opacity inputs to [0, 100]
   if(lineOpacity < 0)   lineOpacity = 0;
   if(lineOpacity > 100) lineOpacity = 100;
   if(fillOpacity < 0)   fillOpacity = 0;
   if(fillOpacity > 100) fillOpacity = 100;
   if(textOpacity < 0)   textOpacity = 0;
   if(textOpacity > 100) textOpacity = 100;
   //--- Clamp the font size to a sane range
   if(fontSize < 6)  fontSize = 6;
   if(fontSize > 32) fontSize = 32;
   //--- Resolve effective fill and text colors with legacy defaults
   color fillColor   = (fillColorArg == clrNONE) ? objColor : fillColorArg;
   color textColorE  = (textColorArg == clrNONE) ? clrWhite : textColorArg;
   //--- Compose ARGB values per element
   uint  fillArgb    = ColorWithPercentOpacity(fillColor, fillOpacity);
   uint  textArgb    = ColorWithPercentOpacity(textColorE, textOpacity);
   uchar promptA     = (uchar)(((double)textOpacity / 100.0) * 255 * 0.50 + 0.5);
   uint  promptArgb  = ((uint)promptA << 24) | (ColorToARGB(textColorE, 255) & 0x00FFFFFF);
   //--- Compute the rectangle bounds via the shared geometry helper
   int boxL, boxT, boxR, boxB;
   ComputeCommentBox(p1x, p1y, committedText, isEditing, editBuffer,
                      boxL, boxT, boxR, boxB, fontSize);
   outBoxL = boxL; outBoxT = boxT; outBoxR = boxR; outBoxB = boxB;
   int boxW = boxR - boxL;
   int boxH = boxB - boxT;
   //--- Configure mixed corner radii: tight BL plus pill-like other corners
   int crTL = boxH / 2;
   int crTR = boxH / 2;
   int crBL = 3;
   int crBR = boxH / 2;
   //--- Fill the mixed-radius rectangle
   FillCommentMixedRadiusRect(canvas, boxL, boxT, boxR, boxB,
                               crTL, crTR, crBL, crBR, fillArgb);
   //--- Resolve the text content for rendering
   string labelPart = isEditing ? editBuffer : committedText;
   bool   hasContent = (StringLen(labelPart) > 0);
   bool   usePlaceholder = isEditing && !hasContent;
   string renderText = usePlaceholder ? "Add text" : labelPart;
   int effectiveCaret = usePlaceholder ? 0 : caretPos;
   //--- Center the text block within the rectangle and render it
   if(StringLen(renderText) > 0)
     {
      //--- Measure the wrapped block for centering math
      int measW = 0, measH = 0, measLineH = 0;
      MeasureTextBlock(renderText, "Arial", fontSize, measW, measH, measLineH);
      //--- Compute centered text origin with floor at padding edges
      int padX = boxH / 2 + 4;
      int padY = 7;
      int textL = boxL + padX + (boxW - 2 * padX - measW) / 2;
      int textT = boxT + padY + (boxH - 2 * padY - measH) / 2;
      if(textL < boxL + padX) textL = boxL + padX;
      if(textT < boxT + padY) textT = boxT + padY;
      //--- Render the text via the universal multi-line helper
      RenderEditableTextBlockAA(canvas, renderText, isEditing, effectiveCaret,
                                  textL, textT,
                                  boxL + padX, boxT + padY,
                                  boxR - padX, boxB - padY,
                                  "Arial", fontSize,
                                  textColorE, textColorE,
                                  0, bold, 0, 0,
                                  usePlaceholder ? (textOpacity / 2) : textOpacity);
     }
   //--- Draw the single P1 handle on selection or hover (no permanent dot)
   if(selected || hovered)
     {
      if(m_hideHandleIdx != 0)
         DrawHandleOnCanvas(canvas, p1x, p1y, selected, objColor, m_haloHandleIdx == 0);
     }
  }

//+------------------------------------------------------------------+
//| Hit-test for a Comment rectangle                                 |
//+------------------------------------------------------------------+
bool CAnnotationTools::HitTestComment(int mx, int my, int p1x, int p1y,
                                       const string text,
                                       bool isEditing, const string editBuffer,
                                       int fontSize)
  {
   //--- Compute the rectangle bounds and test cursor containment
   int boxL, boxT, boxR, boxB;
   ComputeCommentBox(p1x, p1y, text, isEditing, editBuffer,
                      boxL, boxT, boxR, boxB, fontSize);
   return (mx >= boxL && mx <= boxR && my >= boxT && my <= boxB);
  }

#endif // TOOLS_PALETTE_ANNOTATIONS_MQH
//+------------------------------------------------------------------+