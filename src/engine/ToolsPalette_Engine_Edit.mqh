//+------------------------------------------------------------------+
//|                                     ToolsPalette_Engine_Edit.mqh |
//|                           Copyright 2026, Allan Munene Mutiiria. |
//|                                   https://t.me/Forex_Algo_Trader |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Allan Munene Mutiiria."
#property link "https://t.me/Forex_Algo_Trader"
#property version "1.00"
#property strict

//--- Guard against multiple inclusion of this header
#ifndef TOOLS_PALETTE_ENGINE_EDIT_MQH
#define TOOLS_PALETTE_ENGINE_EDIT_MQH

//--- Pull in CDrawingEngine class declaration (Tools.mqh include guard handles double-load)
#include "../core/ToolsPalette_Tools.mqh"

//+------------------------------------------------------------------+
//| CDrawingEngine method bodies for the in-place text edit subsystem|
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Test whether the label buffer has an active selection range      |
//+------------------------------------------------------------------+
bool CDrawingEngine::HasLabelSelection()
  {
   //--- Anchor at -1 means selection inactive
   if(m_labelSelectionAnchor < 0)                       return false;
   //--- Anchor equal to caret means zero-width selection (treated as none)
   if(m_labelSelectionAnchor == m_labelCaretPos)        return false;
   return true;
  }

//+------------------------------------------------------------------+
//| Read the ordered [start, end) range of the active selection      |
//+------------------------------------------------------------------+
bool CDrawingEngine::GetLabelSelectionRange(int &outStart, int &outEnd)
  {
   //--- Bail out when no selection is active and zero the outputs
   if(!HasLabelSelection()) { outStart = outEnd = 0; return false; }
   //--- Order anchor and caret so start <= end regardless of selection direction
   outStart = (m_labelSelectionAnchor < m_labelCaretPos) ? m_labelSelectionAnchor : m_labelCaretPos;
   outEnd   = (m_labelSelectionAnchor > m_labelCaretPos) ? m_labelSelectionAnchor : m_labelCaretPos;
   //--- Clamp defensively in case the buffer was mutated mid-edit
   const int len = StringLen(m_labelEditBuffer);
   if(outStart < 0)   outStart = 0;
   if(outEnd   > len) outEnd   = len;
   if(outStart > outEnd) outStart = outEnd;
   return outEnd > outStart;
  }

//+------------------------------------------------------------------+
//| Delete the active selection from the buffer and return success   |
//+------------------------------------------------------------------+
bool CDrawingEngine::DeleteLabelSelection()
  {
   //--- Bail out when there is no selection to delete
   int s, e;
   if(!GetLabelSelectionRange(s, e)) return false;
   //--- Compute the buffer slices before and after the selection
   const int len = StringLen(m_labelEditBuffer);
   const string before = (s > 0) ? StringSubstr(m_labelEditBuffer, 0, s) : "";
   const string after  = (e < len) ? StringSubstr(m_labelEditBuffer, e, len - e) : "";
   //--- Concatenate the slices, park the caret at the deleted region start
   m_labelEditBuffer = before + after;
   m_labelCaretPos        = s;
   m_labelSelectionAnchor = -1;
   return true;
  }

//+------------------------------------------------------------------+
//| Select the entire label buffer (Ctrl+A) and park caret at end    |
//+------------------------------------------------------------------+
void CDrawingEngine::LabelSelectAll()
  {
   //--- Skip when not in edit mode
   if(!m_isEditingLabel) return;
   const int len = StringLen(m_labelEditBuffer);
   //--- Empty buffer: clear any anchor and park caret at zero
   if(len <= 0)
     {
      m_labelSelectionAnchor = -1;
      m_labelCaretPos        = 0;
      RedrawAllObjects();
      return;
     }
   //--- Anchor at start, caret at end - selects the whole buffer
   m_labelSelectionAnchor = 0;
   m_labelCaretPos        = len;
   RedrawAllObjects();
  }

//+------------------------------------------------------------------+
//| Clear the label selection anchor without moving the caret        |
//+------------------------------------------------------------------+
void CDrawingEngine::ClearLabelSelection()
  {
   //--- Setting anchor to -1 disables the selection without touching caret
   m_labelSelectionAnchor = -1;
  }

//+------------------------------------------------------------------+
//| Suppress MT5 chart keyboard handling during in-place text edit   |
//+------------------------------------------------------------------+
void CDrawingEngine::BeginKeyboardOverride()
  {
   //--- Idempotent guard - don't clobber the original saved values on re-entry
   if(m_keyboardOverrideActive) return;
   //--- Capture the user's original chart keyboard settings for later restore
   m_savedKeyboardControl   = (bool)ChartGetInteger(0, CHART_KEYBOARD_CONTROL);
   m_savedQuickNavigation   = (bool)ChartGetInteger(0, CHART_QUICK_NAVIGATION);
   //--- Disable chart keyboard control so typing doesn't trigger chart navigation
   ChartSetInteger(0, CHART_KEYBOARD_CONTROL, false);
   ChartSetInteger(0, CHART_QUICK_NAVIGATION, false);
   //--- Mark the override as active so EndKeyboardOverride knows to restore
   m_keyboardOverrideActive = true;
  }

//+------------------------------------------------------------------+
//| Restore the user's original MT5 chart keyboard settings          |
//+------------------------------------------------------------------+
void CDrawingEngine::EndKeyboardOverride()
  {
   //--- Idempotent guard - nothing to restore if override was never active
   if(!m_keyboardOverrideActive) return;
   //--- Restore the original keyboard control and quick-navigation values
   ChartSetInteger(0, CHART_KEYBOARD_CONTROL, m_savedKeyboardControl);
   ChartSetInteger(0, CHART_QUICK_NAVIGATION, m_savedQuickNavigation);
   //--- Clear the active flag so a subsequent Begin call will re-save state
   m_keyboardOverrideActive = false;
  }

//+------------------------------------------------------------------+
//| Resolve per-host text layout parameters (padding, font, wrap)    |
//+------------------------------------------------------------------+
bool CDrawingEngine::GetHostTextLayout(int objIdx,
                                        int &outPadX, int &outPadY,
                                        string &outFontName, int &outFontPt,
                                        int &outWrapWidth)
  {
   //--- Reject invalid object indices
   if(objIdx < 0 || objIdx >= ArraySize(m_drawnObjects)) return false;
   //--- Identify the host tool type to pick the right layout parameters
   TOOL_TYPE hostTool = m_drawnObjects[objIdx].toolType;
   //--- Default font and wrap settings for annotation-class hosts
   outFontName  = "Arial";
   outFontPt    = 12;
   outWrapWidth = 0;
   //--- Text annotation uses small padding for a tight bounding box
   if(hostTool == TOOL_TEXT)
     {
      outPadX = 8;  outPadY = 4;
     }
   //--- Note hosts use slightly larger padding for a roomier rectangle
   else if(hostTool == TOOL_NOTE)
     {
      outPadX = 10; outPadY = 6;
     }
   //--- Callout hosts use the largest padding to accommodate the shaft attach points
   else if(hostTool == TOOL_CALLOUT)
     {
      outPadX = 12; outPadY = 8;
     }
   //--- Comment host derives horizontal padding from its computed box height
   else if(hostTool == TOOL_COMMENT)
     {
      //--- Derive box height from hit corners (Comment's rect is axis-aligned)
      int boxH = MathAbs(m_labelHitCornerY[3] - m_labelHitCornerY[0]);
      outPadX = boxH / 2 + 4;
      outPadY = 7;
     }
   //--- Fixed-shape hosts wrap to their interior width with a smaller font
   else if(hostTool == TOOL_RECTANGLE ||
            hostTool == TOOL_CIRCLE   ||
            hostTool == TOOL_ELLIPSE)
     {
      //--- Switch to 11pt and zero padding for inscribed text fit
      outFontPt = 11;
      outPadX = 0;
      outPadY = 0;
      //--- Map the object's two anchor points to canvas pixels for wrap math
      int x1 = 0, y1 = 0, x2 = 0, y2 = 0;
      ChartTimePriceToXY(m_chartId, 0,
                          m_drawnObjects[objIdx].time1,
                          m_drawnObjects[objIdx].price1, x1, y1);
      ChartTimePriceToXY(m_chartId, 0,
                          m_drawnObjects[objIdx].time2,
                          m_drawnObjects[objIdx].price2, x2, y2);
      //--- Rectangle wrap width is the interior width minus 6px padding per side
      if(hostTool == TOOL_RECTANGLE)
        {
         int rxL = (x1 < x2) ? x1 : x2;
         int rxR = (x1 < x2) ? x2 : x1;
         int pad = 6;
         outWrapWidth = (rxR - rxL) - 2 * pad;
         if(outWrapWidth < 10) outWrapWidth = 10;
        }
      //--- Circle wrap width is twice the inscribed half (65% of radius)
      else if(hostTool == TOOL_CIRCLE)
        {
         double rdx = (double)(x2 - x1);
         double rdy = (double)(y2 - y1);
         double r   = MathSqrt(rdx * rdx + rdy * rdy);
         int inscribedHalf = (int)(r * 0.65);
         if(inscribedHalf < 5) inscribedHalf = 5;
         outWrapWidth = inscribedHalf * 2;
        }
      //--- Ellipse wrap width is 70% of the major axis length
      else
        {
         double exDx = (double)(x2 - x1);
         double exDy = (double)(y2 - y1);
         double major = MathSqrt(exDx * exDx + exDy * exDy);
         outWrapWidth = (int)(major * 0.70);
         if(outWrapWidth < 10) outWrapWidth = 10;
        }
     }
   //--- All other hosts (line tools, etc): 11pt, no padding, no wrap
   else
     {
      outFontPt = 11;
      outPadX = 0;
      outPadY = 0;
     }
   return true;
  }

//+------------------------------------------------------------------+
//| Build the wrapped visual layout for the currently edited object  |
//+------------------------------------------------------------------+
bool CDrawingEngine::ResolveCaretVisualLayout(string &outLines[],
                                               int &outBufOffsets[])
  {
   //--- Require active edit mode and a valid selected object
   if(!m_isEditingLabel || m_selectedObjectId < 0) return false;
   int idx = FindObjectIndexById(m_selectedObjectId);
   if(idx < 0) return false;
   //--- Resolve the host's padding, font, and wrap-width via the layout helper
   int padX = 0, padY = 0, fontPt = 12, wrapW = 0;
   string fontN = "Arial";
   if(!GetHostTextLayout(idx, padX, padY, fontN, fontPt, wrapW)) return false;
   //--- Discard the width/height/lineH outputs - callers only need lines and offsets
   int dummyW = 0, dummyH = 0, dummyLineH = 0;
   ComputeWrappedLayout(m_labelEditBuffer, fontN, fontPt, wrapW,
                         outLines, outBufOffsets,
                         dummyW, dummyH, dummyLineH);
   return ArraySize(outLines) > 0;
  }

//+------------------------------------------------------------------+
//| Split text on '\n' into the lines array (preserving empty tail)  |
//+------------------------------------------------------------------+
void CDrawingEngine::SplitTextIntoLines(const string text, string &lines[])
  {
   //--- Reset the output array to empty before populating it
   ArrayResize(lines, 0);
   int len = StringLen(text);
   int start = 0;
   //--- Walk the buffer, append a line at each newline boundary
   for(int i = 0; i < len; i++)
     {
      if(StringGetCharacter(text, i) == '\n')
        {
         //--- Append the substring up to (but not including) the newline
         int sz = ArraySize(lines);
         ArrayResize(lines, sz + 1);
         lines[sz] = StringSubstr(text, start, i - start);
         start = i + 1;
        }
     }
   //--- Append the trailing slice (or the entire text when no '\n' was found)
   int sz = ArraySize(lines);
   ArrayResize(lines, sz + 1);
   lines[sz] = StringSubstr(text, start, len - start);
  }

//+------------------------------------------------------------------+
//| Derive 0-based (line, col) of caret within the label buffer      |
//+------------------------------------------------------------------+
void CDrawingEngine::ComputeCaretLineColumn(int &outLine, int &outCol)
  {
   //--- Seed the outputs at origin
   outLine = 0;
   outCol  = 0;
   //--- Clamp the caret index defensively into [0, len]
   int target = m_labelCaretPos;
   int len    = StringLen(m_labelEditBuffer);
   if(target < 0)   target = 0;
   if(target > len) target = len;
   //--- Walk from buffer start to caret, counting line breaks and columns
   for(int i = 0; i < target; i++)
     {
      //--- Newline character advances the line and resets the column
      if(StringGetCharacter(m_labelEditBuffer, i) == '\n')
        {
         outLine++;
         outCol = 0;
        }
      else
        {
         outCol++;
        }
     }
  }

//+------------------------------------------------------------------+
//| Convert (line, col) into an absolute caret index in the buffer   |
//+------------------------------------------------------------------+
int CDrawingEngine::LineColumnToCaret(int line, int col)
  {
   //--- Split the buffer on '\n' into lines for the conversion
   string lines[];
   SplitTextIntoLines(m_labelEditBuffer, lines);
   int nLines = ArraySize(lines);
   if(nLines == 0) return 0;
   //--- Clamp the line index into [0, nLines-1]
   if(line < 0)            line = 0;
   if(line >= nLines)      line = nLines - 1;
   //--- Clamp the column index into [0, target_line_length]
   int targetLineLen = StringLen(lines[line]);
   if(col < 0)             col = 0;
   if(col > targetLineLen) col = targetLineLen;
   //--- Sum every prior line's length plus one for each separating '\n', then add col
   int caret = 0;
   for(int i = 0; i < line; i++)
      caret += StringLen(lines[i]) + 1;
   caret += col;
   return caret;
  }

//+------------------------------------------------------------------+
//| Insert a character at the caret (replaces selection if active)   |
//+------------------------------------------------------------------+
void CDrawingEngine::InsertCharAtCaret(string ch)
  {
   //--- Skip when not in edit mode or the character is empty
   if(!m_isEditingLabel) return;
   if(StringLen(ch) == 0) return;
   //--- Type-over behavior: deleting the selection lands caret at the start
   DeleteLabelSelection();
   //--- Clamp the caret index into [0, len] before splitting the buffer
   int len = StringLen(m_labelEditBuffer);
   if(m_labelCaretPos < 0)   m_labelCaretPos = 0;
   if(m_labelCaretPos > len) m_labelCaretPos = len;
   //--- Split, insert, and re-join the buffer around the caret position
   string before = StringSubstr(m_labelEditBuffer, 0, m_labelCaretPos);
   string after  = StringSubstr(m_labelEditBuffer, m_labelCaretPos, len - m_labelCaretPos);
   m_labelEditBuffer = before + ch + after;
   //--- Advance the caret past the inserted text
   m_labelCaretPos  += StringLen(ch);
   RedrawAllObjects();
  }

//+------------------------------------------------------------------+
//| Insert a newline character at the caret position                 |
//+------------------------------------------------------------------+
void CDrawingEngine::InsertNewlineAtCaret()
  {
   //--- Newline is just InsertCharAtCaret with the LF literal
   InsertCharAtCaret("\n");
  }

//+------------------------------------------------------------------+
//| Delete the character before the caret (or selection if active)   |
//+------------------------------------------------------------------+
void CDrawingEngine::BackspaceAtCaret()
  {
   //--- Skip when not in edit mode
   if(!m_isEditingLabel) return;
   //--- Selection-aware behavior: backspace deletes the selection atomically
   if(DeleteLabelSelection()) { RedrawAllObjects(); return; }
   //--- Nothing to delete when caret is already at buffer start
   if(m_labelCaretPos <= 0) return;
   //--- Split, drop the char before caret, and re-join the buffer
   int len = StringLen(m_labelEditBuffer);
   string before = StringSubstr(m_labelEditBuffer, 0, m_labelCaretPos - 1);
   string after  = (m_labelCaretPos < len)
                     ? StringSubstr(m_labelEditBuffer, m_labelCaretPos, len - m_labelCaretPos)
                     : "";
   m_labelEditBuffer = before + after;
   //--- Move the caret back one position
   m_labelCaretPos--;
   RedrawAllObjects();
  }

//+------------------------------------------------------------------+
//| Delete the character at the caret (or selection if active)       |
//+------------------------------------------------------------------+
void CDrawingEngine::DeleteAtCaret()
  {
   //--- Skip when not in edit mode
   if(!m_isEditingLabel) return;
   //--- Selection-aware behavior: delete drops the selection atomically
   if(DeleteLabelSelection()) { RedrawAllObjects(); return; }
   //--- Nothing to delete when caret is already at the buffer end
   int len = StringLen(m_labelEditBuffer);
   if(m_labelCaretPos >= len) return;
   //--- Split, drop the char at caret, and re-join the buffer
   string before = StringSubstr(m_labelEditBuffer, 0, m_labelCaretPos);
   string after  = StringSubstr(m_labelEditBuffer, m_labelCaretPos + 1,
                                  len - m_labelCaretPos - 1);
   m_labelEditBuffer = before + after;
   //--- Caret index stays - it now sits between `before` and the new `after`
   RedrawAllObjects();
  }

//+------------------------------------------------------------------+
//| Move the caret one position left (collapses selection if active) |
//+------------------------------------------------------------------+
void CDrawingEngine::MoveCaretLeft()
  {
   //--- Skip when not in edit mode
   if(!m_isEditingLabel) return;
   //--- Plain Left with active selection collapses to the SELECTION START
   int s, e;
   if(GetLabelSelectionRange(s, e))
     {
      m_labelCaretPos        = s;
      m_labelSelectionAnchor = -1;
      RedrawAllObjects();
      return;
     }
   //--- Default behavior: step the caret back by one position
   if(m_labelCaretPos > 0) m_labelCaretPos--;
   RedrawAllObjects();
  }

//+------------------------------------------------------------------+
//| Move the caret one position right (collapses selection if active)|
//+------------------------------------------------------------------+
void CDrawingEngine::MoveCaretRight()
  {
   //--- Skip when not in edit mode
   if(!m_isEditingLabel) return;
   //--- Plain Right with active selection collapses to the SELECTION END
   int s, e;
   if(GetLabelSelectionRange(s, e))
     {
      m_labelCaretPos        = e;
      m_labelSelectionAnchor = -1;
      RedrawAllObjects();
      return;
     }
   //--- Default behavior: step the caret forward by one position
   int len = StringLen(m_labelEditBuffer);
   if(m_labelCaretPos < len) m_labelCaretPos++;
   RedrawAllObjects();
  }

//+------------------------------------------------------------------+
//| Move the caret to the start of the current visual line           |
//+------------------------------------------------------------------+
void CDrawingEngine::MoveCaretHome()
  {
   //--- Skip when not in edit mode; clear any active selection first
   if(!m_isEditingLabel) return;
   ClearLabelSelection();
   //--- Resolve the wrapped visual layout, falling back to buffer-line Home
   string visLines[]; int bufOffsets[];
   if(!ResolveCaretVisualLayout(visLines, bufOffsets))
     {
      //--- Fallback: walk back to the previous '\n' or buffer start
      int p = m_labelCaretPos;
      if(p > StringLen(m_labelEditBuffer)) p = StringLen(m_labelEditBuffer);
      while(p > 0 && StringGetCharacter(m_labelEditBuffer, p - 1) != '\n') p--;
      m_labelCaretPos = p;
      RedrawAllObjects();
      return;
     }
   //--- Find which visual line contains the caret
   int n = ArraySize(visLines);
   int line = 0;
   for(int i = 0; i < n; i++)
     {
      if(bufOffsets[i] <= m_labelCaretPos) line = i;
      else break;
     }
   //--- Park the caret at the start of that visual line
   m_labelCaretPos = bufOffsets[line];
   RedrawAllObjects();
  }

//+------------------------------------------------------------------+
//| Move the caret to the end of the current visual line             |
//+------------------------------------------------------------------+
void CDrawingEngine::MoveCaretEnd()
  {
   //--- Skip when not in edit mode; clear any active selection first
   if(!m_isEditingLabel) return;
   ClearLabelSelection();
   //--- Resolve the wrapped visual layout, falling back to buffer-line End
   string visLines[]; int bufOffsets[];
   if(!ResolveCaretVisualLayout(visLines, bufOffsets))
     {
      //--- Fallback: walk forward to the next '\n' or buffer end
      int p   = m_labelCaretPos;
      int len = StringLen(m_labelEditBuffer);
      while(p < len && StringGetCharacter(m_labelEditBuffer, p) != '\n') p++;
      m_labelCaretPos = p;
      RedrawAllObjects();
      return;
     }
   //--- Find which visual line contains the caret
   int n = ArraySize(visLines);
   int line = 0;
   for(int i = 0; i < n; i++)
     {
      if(bufOffsets[i] <= m_labelCaretPos) line = i;
      else break;
     }
   //--- Park the caret at the end of that visual line
   m_labelCaretPos = bufOffsets[line] + StringLen(visLines[line]);
   RedrawAllObjects();
  }

//+------------------------------------------------------------------+
//| Move the caret up one visual line, preserving the column         |
//+------------------------------------------------------------------+
void CDrawingEngine::MoveCaretUp()
  {
   //--- Skip when not in edit mode; clear any active selection first
   if(!m_isEditingLabel) return;
   ClearLabelSelection();
   //--- Resolve the wrapped visual layout (no fallback - up has no meaning without it)
   string visLines[]; int bufOffsets[];
   if(!ResolveCaretVisualLayout(visLines, bufOffsets)) return;
   int n = ArraySize(visLines);
   //--- Identify the current visual line and column
   int line = 0;
   for(int i = 0; i < n; i++)
     {
      if(bufOffsets[i] <= m_labelCaretPos) line = i;
      else break;
     }
   int col = m_labelCaretPos - bufOffsets[line];
   //--- Already on the first visual line - nowhere to go
   if(line <= 0) return;
   //--- Clamp column to the previous line's length, then update caret index
   int prevLineLen = StringLen(visLines[line - 1]);
   int newCol = (col <= prevLineLen) ? col : prevLineLen;
   m_labelCaretPos = bufOffsets[line - 1] + newCol;
   RedrawAllObjects();
  }

//+------------------------------------------------------------------+
//| Move the caret down one visual line, preserving the column       |
//+------------------------------------------------------------------+
void CDrawingEngine::MoveCaretDown()
  {
   //--- Skip when not in edit mode; clear any active selection first
   if(!m_isEditingLabel) return;
   ClearLabelSelection();
   //--- Resolve the wrapped visual layout (no fallback - down has no meaning without it)
   string visLines[]; int bufOffsets[];
   if(!ResolveCaretVisualLayout(visLines, bufOffsets)) return;
   int n = ArraySize(visLines);
   //--- Identify the current visual line and column
   int line = 0;
   for(int i = 0; i < n; i++)
     {
      if(bufOffsets[i] <= m_labelCaretPos) line = i;
      else break;
     }
   int col = m_labelCaretPos - bufOffsets[line];
   //--- Already on the last visual line - nowhere to go
   if(line >= n - 1) return;
   //--- Clamp column to the next line's length, then update caret index
   int nextLineLen = StringLen(visLines[line + 1]);
   int newCol = (col <= nextLineLen) ? col : nextLineLen;
   m_labelCaretPos = bufOffsets[line + 1] + newCol;
   RedrawAllObjects();
  }

//+------------------------------------------------------------------+
//| Shift-extend the selection by moving the caret one position left |
//+------------------------------------------------------------------+
void CDrawingEngine::ShiftExtendCaretLeft()
  {
   //--- Skip when not in edit mode
   if(!m_isEditingLabel) return;
   //--- Park the anchor at the current caret on the first shift-press
   if(m_labelSelectionAnchor < 0) m_labelSelectionAnchor = m_labelCaretPos;
   //--- Step the caret back by one position
   if(m_labelCaretPos > 0) m_labelCaretPos--;
   RedrawAllObjects();
  }

//+------------------------------------------------------------------+
//| Shift-extend the selection by moving the caret one position right|
//+------------------------------------------------------------------+
void CDrawingEngine::ShiftExtendCaretRight()
  {
   //--- Skip when not in edit mode
   if(!m_isEditingLabel) return;
   //--- Park the anchor at the current caret on the first shift-press
   if(m_labelSelectionAnchor < 0) m_labelSelectionAnchor = m_labelCaretPos;
   //--- Step the caret forward by one position
   const int len = StringLen(m_labelEditBuffer);
   if(m_labelCaretPos < len) m_labelCaretPos++;
   RedrawAllObjects();
  }

//+------------------------------------------------------------------+
//| Shift-extend the selection by moving the caret up one visual line|
//+------------------------------------------------------------------+
void CDrawingEngine::ShiftExtendCaretUp()
  {
   //--- Skip when not in edit mode
   if(!m_isEditingLabel) return;
   //--- Park the anchor at the current caret on the first shift-press
   if(m_labelSelectionAnchor < 0) m_labelSelectionAnchor = m_labelCaretPos;
   //--- Column-preserving up move - identical to MoveCaretUp minus the selection clear
   string visLines[]; int bufOffsets[];
   if(!ResolveCaretVisualLayout(visLines, bufOffsets)) return;
   const int n = ArraySize(visLines);
   //--- Identify the current visual line
   int line = 0;
   for(int i = 0; i < n; i++)
     {
      if(bufOffsets[i] <= m_labelCaretPos) line = i;
      else break;
     }
   const int col = m_labelCaretPos - bufOffsets[line];
   //--- Already on the first visual line - just redraw to update the selection visual
   if(line <= 0) { RedrawAllObjects(); return; }
   //--- Clamp column to the previous line's length, then update caret index
   const int prevLineLen = StringLen(visLines[line - 1]);
   const int newCol = (col <= prevLineLen) ? col : prevLineLen;
   m_labelCaretPos = bufOffsets[line - 1] + newCol;
   RedrawAllObjects();
  }

//+------------------------------------------------------------------+
//| Shift-extend the selection by moving the caret down one line     |
//+------------------------------------------------------------------+
void CDrawingEngine::ShiftExtendCaretDown()
  {
   //--- Skip when not in edit mode
   if(!m_isEditingLabel) return;
   //--- Park the anchor at the current caret on the first shift-press
   if(m_labelSelectionAnchor < 0) m_labelSelectionAnchor = m_labelCaretPos;
   //--- Column-preserving down move - identical to MoveCaretDown minus the selection clear
   string visLines[]; int bufOffsets[];
   if(!ResolveCaretVisualLayout(visLines, bufOffsets)) return;
   const int n = ArraySize(visLines);
   //--- Identify the current visual line
   int line = 0;
   for(int i = 0; i < n; i++)
     {
      if(bufOffsets[i] <= m_labelCaretPos) line = i;
      else break;
     }
   const int col = m_labelCaretPos - bufOffsets[line];
   //--- Already on the last visual line - just redraw to update the selection visual
   if(line >= n - 1) { RedrawAllObjects(); return; }
   //--- Clamp column to the next line's length, then update caret index
   const int nextLineLen = StringLen(visLines[line + 1]);
   const int newCol = (col <= nextLineLen) ? col : nextLineLen;
   m_labelCaretPos = bufOffsets[line + 1] + newCol;
   RedrawAllObjects();
  }

//+------------------------------------------------------------------+
//| Shift-extend the selection to the start of the current line      |
//+------------------------------------------------------------------+
void CDrawingEngine::ShiftExtendCaretHome()
  {
   //--- Skip when not in edit mode
   if(!m_isEditingLabel) return;
   //--- Park the anchor at the current caret on the first shift-press
   if(m_labelSelectionAnchor < 0) m_labelSelectionAnchor = m_labelCaretPos;
   //--- Mirror MoveCaretHome but skip the selection-clear step
   string visLines[]; int bufOffsets[];
   if(!ResolveCaretVisualLayout(visLines, bufOffsets))
     {
      //--- Fallback: walk back to the previous '\n' or buffer start
      int p = m_labelCaretPos;
      if(p > StringLen(m_labelEditBuffer)) p = StringLen(m_labelEditBuffer);
      while(p > 0 && StringGetCharacter(m_labelEditBuffer, p - 1) != '\n') p--;
      m_labelCaretPos = p;
      RedrawAllObjects();
      return;
     }
   //--- Find which visual line contains the caret
   const int n = ArraySize(visLines);
   int line = 0;
   for(int i = 0; i < n; i++)
     {
      if(bufOffsets[i] <= m_labelCaretPos) line = i;
      else break;
     }
   //--- Park the caret at the start of that visual line
   m_labelCaretPos = bufOffsets[line];
   RedrawAllObjects();
  }

//+------------------------------------------------------------------+
//| Shift-extend the selection to the end of the current line        |
//+------------------------------------------------------------------+
void CDrawingEngine::ShiftExtendCaretEnd()
  {
   //--- Skip when not in edit mode
   if(!m_isEditingLabel) return;
   //--- Park the anchor at the current caret on the first shift-press
   if(m_labelSelectionAnchor < 0) m_labelSelectionAnchor = m_labelCaretPos;
   //--- Mirror MoveCaretEnd but skip the selection-clear step
   string visLines[]; int bufOffsets[];
   if(!ResolveCaretVisualLayout(visLines, bufOffsets))
     {
      //--- Fallback: walk forward to the next '\n' or buffer end
      int p   = m_labelCaretPos;
      const int len = StringLen(m_labelEditBuffer);
      while(p < len && StringGetCharacter(m_labelEditBuffer, p) != '\n') p++;
      m_labelCaretPos = p;
      RedrawAllObjects();
      return;
     }
   //--- Find which visual line contains the caret
   const int n = ArraySize(visLines);
   int line = 0;
   for(int i = 0; i < n; i++)
     {
      if(bufOffsets[i] <= m_labelCaretPos) line = i;
      else break;
     }
   //--- Park the caret at the end of that visual line
   m_labelCaretPos = bufOffsets[line] + StringLen(visLines[line]);
   RedrawAllObjects();
  }

//+------------------------------------------------------------------+
//| Position the caret at the character boundary nearest a click pt  |
//+------------------------------------------------------------------+
void CDrawingEngine::SetCaretFromMouseClick(int mx, int my,
                                             int hostPaddingX, int hostPaddingY,
                                             const string fontName, int fontPt,
                                             int wrapWidth)
  {
   //--- Bail out when not in edit mode or hit corners aren't populated
   if(!m_isEditingLabel) return;
   if(ArraySize(m_labelHitCornerX) != 4) return;
   //--- Hit corners are stored in TL, TR, BR, BL order
   double tlx = (double)m_labelHitCornerX[0];
   double tly = (double)m_labelHitCornerY[0];
   double trx = (double)m_labelHitCornerX[1];
   double try_= (double)m_labelHitCornerY[1];
   double blx = (double)m_labelHitCornerX[3];
   double bly = (double)m_labelHitCornerY[3];
   //--- Derive local right axis from the TL->TR vector
   double rightX = trx - tlx;
   double rightY = try_- tly;
   double rightLen = MathSqrt(rightX * rightX + rightY * rightY);
   if(rightLen < 1.0) return;
   //--- Normalize the right axis into a unit vector
   double rightUX = rightX / rightLen;
   double rightUY = rightY / rightLen;
   //--- Derive local down axis from the TL->BL vector
   double downX = blx - tlx;
   double downY = bly - tly;
   double downLen = MathSqrt(downX * downX + downY * downY);
   if(downLen < 1.0) return;
   //--- Normalize the down axis into a unit vector
   double downUX = downX / downLen;
   double downUY = downY / downLen;
   //--- Translate the click into the label's local frame via dot products
   double cx = (double)mx - tlx;
   double cy = (double)my - tly;
   double localX = cx * rightUX + cy * rightUY;
   double localY = cx * downUX  + cy * downUY;
   //--- Subtract host padding so coordinates reference the text region origin
   double textX = localX - (double)hostPaddingX;
   double textY = localY - (double)hostPaddingY;
   if(textX < 0.0) textX = 0.0;
   if(textY < 0.0) textY = 0.0;
   //--- Build the wrapped layout - same algorithm the renderer used
   string visLines[];
   int    bufOffsets[];
   int    measMaxW = 0, measBlockH = 0, lineH = 0;
   ComputeWrappedLayout(m_labelEditBuffer, fontName, fontPt, wrapWidth,
                         visLines, bufOffsets, measMaxW, measBlockH, lineH);
   int nVis = ArraySize(visLines);
   //--- Empty layout: park caret at zero and redraw
   if(nVis == 0) { m_labelCaretPos = 0; RedrawAllObjects(); return; }
   //--- Identify which visual line the click falls on, clamped into [0, nVis-1]
   int visLineIdx = (lineH > 0) ? (int)(textY / (double)lineH) : 0;
   if(visLineIdx < 0)      visLineIdx = 0;
   if(visLineIdx >= nVis)  visLineIdx = nVis - 1;
   //--- Walk that visual line's characters to find the closest column boundary
   const int SS = 4;
   TextSetFont(fontName, -(fontPt * SS * 10));
   string lineStr = visLines[visLineIdx];
   int lineLen = StringLen(lineStr);
   //--- Seed best-column with column 0 (start of line) distance
   int bestCol = 0;
   double bestDist = MathAbs(textX - 0.0);
   for(int k = 1; k <= lineLen; k++)
     {
      //--- Measure each prefix and remember the column with the smallest delta to textX
      string prefix = StringSubstr(lineStr, 0, k);
      uint pwU = 0, phU = 0;
      TextGetSize(prefix, pwU, phU);
      double w = ((double)pwU) / SS;
      double d = MathAbs(textX - w);
      if(d < bestDist) { bestDist = d; bestCol = k; }
     }
   //--- Convert (visualLine, visualCol) into a buffer caret index via the offsets table
   m_labelCaretPos = bufOffsets[visLineIdx] + bestCol;
   RedrawAllObjects();
  }

//+------------------------------------------------------------------+
//| Start editing the label of the currently selected object         |
//+------------------------------------------------------------------+
void CDrawingEngine::StartLabelEdit()
  {
   //--- Defensive guard: finalize any in-progress edit on a different object
   if(m_isEditingLabel)
      FinalizeOpenLabelEdit();
   //--- Require a currently selected object with a resolvable index
   if(m_selectedObjectId < 0) return;
   int idx = FindObjectIndexById(m_selectedObjectId);
   if(idx < 0) return;
   //--- Enter edit mode and seed the buffer with the object's current label
   m_isEditingLabel  = true;
   m_labelEditBuffer = m_drawnObjects[idx].labelText;
   //--- Caret starts at end of existing text - natural re-entry position
   m_labelCaretPos   = StringLen(m_labelEditBuffer);
   //--- Selection starts empty - anchor is set on first Ctrl+A or shift-press
   m_labelSelectionAnchor = -1;
   //--- Suppress MT5's built-in keyboard handling for the duration of the edit
   BeginKeyboardOverride();
   //--- Start a 500ms timer so the caret blinks even when the cursor is still
   EventSetMillisecondTimer(500);
   RedrawAllObjects();
  }

//+------------------------------------------------------------------+
//| Commit the in-place edit buffer back to the object's labelText   |
//+------------------------------------------------------------------+
void CDrawingEngine::CommitLabel()
  {
   //--- Skip when there is no active edit to commit
   if(!m_isEditingLabel) return;
   //--- Write the buffer back to the selected object's labelText
   int idx = FindObjectIndexById(m_selectedObjectId);
   if(idx >= 0) m_drawnObjects[idx].labelText = m_labelEditBuffer;
   //--- Tear down the edit state (buffer, caret, selection)
   m_isEditingLabel  = false;
   m_labelEditBuffer = "";
   m_labelCaretPos   = 0;
   m_labelSelectionAnchor = -1;
   //--- Restore the chart keyboard control values captured at edit start
   EndKeyboardOverride();
   //--- Re-arm the persistent heartbeat (do not kill it - it drives the persistence flush)
   EventSetMillisecondTimer(500);
   //--- Label text changed -> persist it
   MarkDrawingsDirty();
   RedrawAllObjects();
  }

//+------------------------------------------------------------------+
//| Cancel label editing without saving the buffer changes           |
//+------------------------------------------------------------------+
void CDrawingEngine::CancelLabel()
  {
   //--- Discard the edit buffer without committing back to the object
   m_isEditingLabel  = false;
   m_labelEditBuffer = "";
   m_labelCaretPos   = 0;
   m_labelSelectionAnchor = -1;
   //--- Restore the chart keyboard control values captured at edit start
   EndKeyboardOverride();
   //--- Re-arm the persistent heartbeat (do not kill it - it drives the persistence flush)
   EventSetMillisecondTimer(500);
   RedrawAllObjects();
  }

//+------------------------------------------------------------------+
//| Legacy append-char entry point - delegates to InsertCharAtCaret  |
//+------------------------------------------------------------------+
void CDrawingEngine::AppendLabelChar(string ch)
  {
   //--- Source-compatibility shim for older callers
   InsertCharAtCaret(ch);
  }

//+------------------------------------------------------------------+
//| Legacy backspace entry point - delegates to BackspaceAtCaret     |
//+------------------------------------------------------------------+
void CDrawingEngine::BackspaceLabelChar()
  {
   //--- Source-compatibility shim for older callers
   BackspaceAtCaret();
  }

#endif // TOOLS_PALETTE_ENGINE_EDIT_MQH
//+------------------------------------------------------------------+