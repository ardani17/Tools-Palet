//+------------------------------------------------------------------+
//|                               ToolsPalette_Engine_Properties.mqh |
//|                           Copyright 2026, Allan Munene Mutiiria. |
//|                                   https://t.me/Forex_Algo_Trader |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Allan Munene Mutiiria."
#property link "https://t.me/Forex_Algo_Trader"
#property version "1.00"
#property strict

//--- Guard against multiple inclusion of this header
#ifndef TOOLS_PALETTE_ENGINE_PROPERTIES_MQH
#define TOOLS_PALETTE_ENGINE_PROPERTIES_MQH

//--- Pull in the Tools header so CDrawingEngine and DrawnObject are visible to the bodies below
#include "../core/ToolsPalette_Tools.mqh"

//+------------------------------------------------------------------+
//| Split "<prefix>:N:field" into (prefix, N, field) for level props |
//+------------------------------------------------------------------+
bool ParseLevelPropId(string propId, string &outPrefix, int &outIdx,
                       string &outField)
  {
   //--- Need a first colon to separate the prefix from the rest
   const int firstColon = StringFind(propId, ":");
   if(firstColon < 0) return false;
   //--- Need a second colon to separate the index from the field name
   const int secondColon = StringFind(propId, ":", firstColon + 1);
   if(secondColon < 0) return false;
   //--- Slice out the prefix - must be non-empty (e.g., "fibo", "fibex", "gannfan")
   const string prefix = StringSubstr(propId, 0, firstColon);
   if(StringLen(prefix) == 0) return false;
   //--- Slice out the index substring and parse it as an integer
   const string idxStr = StringSubstr(propId, firstColon + 1,
                                        secondColon - firstColon - 1);
   const int idxNum = (int)StringToInteger(idxStr);
   //--- Reject negative indices (defensive)
   if(idxNum < 0) return false;
   //--- Emit the parsed parts to the out-params + return success
   outPrefix = prefix;
   outIdx    = idxNum;
   outField  = StringSubstr(propId, secondColon + 1);
   return true;
  }

//+------------------------------------------------------------------+
//| Fibo-only back-compat shim that wraps ParseLevelPropId           |
//+------------------------------------------------------------------+
bool ParseFibLevelPropId(string propId, int &outIdx, string &outField)
  {
   //--- Delegate to the master parser and only succeed when the prefix is "fibo"
   string pfx;
   if(!ParseLevelPropId(propId, pfx, outIdx, outField)) return false;
   return (pfx == "fibo");
  }

//+------------------------------------------------------------------+
//| Read a color-typed property by string ID                         |
//+------------------------------------------------------------------+
bool CDrawingEngine::GetObjectProperty(int objId, string propId, color &outValue)
  {
   //--- Resolve the object's array index by ID; bail on unknown ID
   int idx = FindObjectIndexById(objId);
   if(idx < 0) return false;

   //--- Primary stroke/fill color of the object
   if(propId == "lineColor")
     {
      outValue = m_drawnObjects[idx].objColor;
      return true;
     }
   //--- Text color (for label-bearing tools)
   if(propId == "textColor")
     {
      outValue = m_drawnObjects[idx].textColor;
      return true;
     }
   //--- Fill color (for shapes with a fill)
   if(propId == "fillColor")
     {
      outValue = m_drawnObjects[idx].fillColor;
      return true;
     }
   //--- Channel midline color
   if(propId == "midColor")
     {
      outValue = m_drawnObjects[idx].midColor;
      return true;
     }
   //--- Secondary fill color (e.g., the second std-dev band fill)
   if(propId == "fillColor2")
     {
      outValue = m_drawnObjects[idx].fillColor2;
      return true;
     }
   //--- Regression centerline color
   if(propId == "centerColor")
     {
      outValue = m_drawnObjects[idx].centerColor;
      return true;
     }
   //--- Pitchfork per-part-group color getters
   if(propId == "medianColor") { outValue = m_drawnObjects[idx].medianColor; return true; }
   if(propId == "outerColor")  { outValue = m_drawnObjects[idx].outerColor;  return true; }
   if(propId == "innerColor")  { outValue = m_drawnObjects[idx].innerColor;  return true; }
   //--- Per-level color for ANY PROP_LEVEL_LIST tool (fibo/fibex/fibch/fibtz/fibfan/fibarc/gannfan/gannbox)
     {
      string pfx; int li; string fld;
      if(ParseLevelPropId(propId, pfx, li, fld) && fld == "color")
        {
         //--- Dispatch by prefix to the matching tool's level-color array
         if(pfx == "fibo")
           {
            if(li < ArraySize(m_drawnObjects[idx].fiboLevelColor))
              { outValue = m_drawnObjects[idx].fiboLevelColor[li]; return true; }
           }
         else if(pfx == "fibex")
           {
            if(li < ArraySize(m_drawnObjects[idx].fibexLevelColor))
              { outValue = m_drawnObjects[idx].fibexLevelColor[li]; return true; }
           }
         else if(pfx == "fibch")
           {
            if(li < ArraySize(m_drawnObjects[idx].fibchLevelColor))
              { outValue = m_drawnObjects[idx].fibchLevelColor[li]; return true; }
           }
         else if(pfx == "fibtz")
           {
            if(li < ArraySize(m_drawnObjects[idx].fibtzLevelColor))
              { outValue = m_drawnObjects[idx].fibtzLevelColor[li]; return true; }
           }
         else if(pfx == "fibfan")
           {
            if(li < ArraySize(m_drawnObjects[idx].fibfanLevelColor))
              { outValue = m_drawnObjects[idx].fibfanLevelColor[li]; return true; }
           }
         else if(pfx == "fibarc")
           {
            if(li < ArraySize(m_drawnObjects[idx].fibarcLevelColor))
              { outValue = m_drawnObjects[idx].fibarcLevelColor[li]; return true; }
           }
         else if(pfx == "gannfan")
           {
            if(li < ArraySize(m_drawnObjects[idx].gannfanLevelColor))
              { outValue = m_drawnObjects[idx].gannfanLevelColor[li]; return true; }
           }
         else if(pfx == "gannbox")
           {
            if(li < ArraySize(m_drawnObjects[idx].gannboxLevelColor))
              { outValue = m_drawnObjects[idx].gannboxLevelColor[li]; return true; }
           }
         //--- Unknown prefix or out-of-range level index
         return false;
        }
     }

   //--- Unrecognized property ID for the color type
   return false;
  }

//+------------------------------------------------------------------+
//| Read an int-typed property by string ID                          |
//+------------------------------------------------------------------+
bool CDrawingEngine::GetObjectProperty(int objId, string propId, int &outValue)
  {
   //--- Resolve the object's array index by ID; bail on unknown ID
   int idx = FindObjectIndexById(objId);
   if(idx < 0) return false;

   //--- Stroke width (pixels)
   if(propId == "lineWidth")
     {
      outValue = m_drawnObjects[idx].lineWidth;
      return true;
     }
   //--- Stroke style (0=solid, 1=dash, 2=dot, 3=dash-dot)
   if(propId == "lineStyle")
     {
      outValue = m_drawnObjects[idx].lineStyle;
      return true;
     }
   //--- Per-style opacity values (0..100 percent)
   if(propId == "lineOpacity")
     {
      outValue = m_drawnObjects[idx].lineOpacity;
      return true;
     }
   if(propId == "textOpacity")
     {
      outValue = m_drawnObjects[idx].textOpacity;
      return true;
     }
   if(propId == "fillOpacity")
     {
      outValue = m_drawnObjects[idx].fillOpacity;
      return true;
     }
   if(propId == "midOpacity")
     {
      outValue = m_drawnObjects[idx].midOpacity;
      return true;
     }
   if(propId == "fillOpacity2")
     {
      outValue = m_drawnObjects[idx].fillOpacity2;
      return true;
     }
   if(propId == "centerOpacity")
     {
      outValue = m_drawnObjects[idx].centerOpacity;
      return true;
     }
   //--- Channel midline width + style
   if(propId == "midWidth")
     {
      outValue = m_drawnObjects[idx].midWidth;
      return true;
     }
   if(propId == "midStyle")
     {
      outValue = m_drawnObjects[idx].midStyle;
      return true;
     }
   //--- Regression centerline width + style
   if(propId == "centerWidth")
     {
      outValue = m_drawnObjects[idx].centerWidth;
      return true;
     }
   if(propId == "centerStyle")
     {
      outValue = m_drawnObjects[idx].centerStyle;
      return true;
     }
   //--- Pitchfork per-part-group width/style int getters
   if(propId == "medianWidth") { outValue = m_drawnObjects[idx].medianWidth; return true; }
   if(propId == "medianStyle") { outValue = m_drawnObjects[idx].medianStyle; return true; }
   if(propId == "outerWidth")  { outValue = m_drawnObjects[idx].outerWidth;  return true; }
   if(propId == "outerStyle")  { outValue = m_drawnObjects[idx].outerStyle;  return true; }
   if(propId == "innerWidth")  { outValue = m_drawnObjects[idx].innerWidth;  return true; }
   if(propId == "innerStyle")  { outValue = m_drawnObjects[idx].innerStyle;  return true; }
   //--- Font sizing and alignment for text-bearing tools
   if(propId == "fontSize")
     {
      outValue = m_drawnObjects[idx].fontSize;
      return true;
     }
   if(propId == "vAlign")
     {
      outValue = m_drawnObjects[idx].vAlign;
      return true;
     }
   if(propId == "hAlign")
     {
      outValue = m_drawnObjects[idx].hAlign;
      return true;
     }
   //--- Level count for any PROP_LEVEL_LIST tool: "<prefix>:count"
   if(propId == "fibo:count")    { outValue = ArraySize(m_drawnObjects[idx].fiboLevelRatio);    return true; }
   if(propId == "fibex:count")   { outValue = ArraySize(m_drawnObjects[idx].fibexLevelRatio);   return true; }
   if(propId == "fibch:count")   { outValue = ArraySize(m_drawnObjects[idx].fibchLevelRatio);   return true; }
   if(propId == "fibtz:count")   { outValue = ArraySize(m_drawnObjects[idx].fibtzLevelRatio);   return true; }
   if(propId == "fibfan:count")  { outValue = ArraySize(m_drawnObjects[idx].fibfanLevelRatio);  return true; }
   if(propId == "fibarc:count")  { outValue = ArraySize(m_drawnObjects[idx].fibarcLevelRatio);  return true; }
   if(propId == "gannfan:count") { outValue = ArraySize(m_drawnObjects[idx].gannfanLevelRatio); return true; }
   if(propId == "gannbox:count") { outValue = ArraySize(m_drawnObjects[idx].gannboxLevelRatio); return true; }
   //--- Per-level int fields (opacity / width / style) - dispatched by parsed prefix
     {
      string pfx; int li; string fld;
      if(ParseLevelPropId(propId, pfx, li, fld))
        {
         if(pfx == "fibo")
           {
            if(fld=="opacity") { if(li<ArraySize(m_drawnObjects[idx].fiboLevelOpacity)) { outValue=m_drawnObjects[idx].fiboLevelOpacity[li]; return true; } return false; }
            if(fld=="width")   { if(li<ArraySize(m_drawnObjects[idx].fiboLevelWidth))   { outValue=m_drawnObjects[idx].fiboLevelWidth[li];   return true; } return false; }
            if(fld=="style")   { if(li<ArraySize(m_drawnObjects[idx].fiboLevelStyle))   { outValue=m_drawnObjects[idx].fiboLevelStyle[li];   return true; } return false; }
           }
         else if(pfx == "fibex")
           {
            if(fld=="opacity") { if(li<ArraySize(m_drawnObjects[idx].fibexLevelOpacity)){ outValue=m_drawnObjects[idx].fibexLevelOpacity[li]; return true; } return false; }
            if(fld=="width")   { if(li<ArraySize(m_drawnObjects[idx].fibexLevelWidth))  { outValue=m_drawnObjects[idx].fibexLevelWidth[li];   return true; } return false; }
            if(fld=="style")   { if(li<ArraySize(m_drawnObjects[idx].fibexLevelStyle))  { outValue=m_drawnObjects[idx].fibexLevelStyle[li];   return true; } return false; }
           }
         else if(pfx == "fibch")
           {
            if(fld=="opacity") { if(li<ArraySize(m_drawnObjects[idx].fibchLevelOpacity)){ outValue=m_drawnObjects[idx].fibchLevelOpacity[li]; return true; } return false; }
            if(fld=="width")   { if(li<ArraySize(m_drawnObjects[idx].fibchLevelWidth))  { outValue=m_drawnObjects[idx].fibchLevelWidth[li];   return true; } return false; }
            if(fld=="style")   { if(li<ArraySize(m_drawnObjects[idx].fibchLevelStyle))  { outValue=m_drawnObjects[idx].fibchLevelStyle[li];   return true; } return false; }
           }
         else if(pfx == "fibtz")
           {
            if(fld=="opacity") { if(li<ArraySize(m_drawnObjects[idx].fibtzLevelOpacity)){ outValue=m_drawnObjects[idx].fibtzLevelOpacity[li]; return true; } return false; }
            if(fld=="width")   { if(li<ArraySize(m_drawnObjects[idx].fibtzLevelWidth))  { outValue=m_drawnObjects[idx].fibtzLevelWidth[li];   return true; } return false; }
            if(fld=="style")   { if(li<ArraySize(m_drawnObjects[idx].fibtzLevelStyle))  { outValue=m_drawnObjects[idx].fibtzLevelStyle[li];   return true; } return false; }
           }
         else if(pfx == "fibfan")
           {
            if(fld=="opacity") { if(li<ArraySize(m_drawnObjects[idx].fibfanLevelOpacity)){ outValue=m_drawnObjects[idx].fibfanLevelOpacity[li]; return true; } return false; }
            if(fld=="width")   { if(li<ArraySize(m_drawnObjects[idx].fibfanLevelWidth))  { outValue=m_drawnObjects[idx].fibfanLevelWidth[li];   return true; } return false; }
            if(fld=="style")   { if(li<ArraySize(m_drawnObjects[idx].fibfanLevelStyle))  { outValue=m_drawnObjects[idx].fibfanLevelStyle[li];   return true; } return false; }
           }
         else if(pfx == "fibarc")
           {
            if(fld=="opacity") { if(li<ArraySize(m_drawnObjects[idx].fibarcLevelOpacity)){ outValue=m_drawnObjects[idx].fibarcLevelOpacity[li]; return true; } return false; }
            if(fld=="width")   { if(li<ArraySize(m_drawnObjects[idx].fibarcLevelWidth))  { outValue=m_drawnObjects[idx].fibarcLevelWidth[li];   return true; } return false; }
            if(fld=="style")   { if(li<ArraySize(m_drawnObjects[idx].fibarcLevelStyle))  { outValue=m_drawnObjects[idx].fibarcLevelStyle[li];   return true; } return false; }
           }
         else if(pfx == "gannfan")
           {
            if(fld=="opacity") { if(li<ArraySize(m_drawnObjects[idx].gannfanLevelOpacity)){ outValue=m_drawnObjects[idx].gannfanLevelOpacity[li]; return true; } return false; }
            if(fld=="width")   { if(li<ArraySize(m_drawnObjects[idx].gannfanLevelWidth))  { outValue=m_drawnObjects[idx].gannfanLevelWidth[li];   return true; } return false; }
            if(fld=="style")   { if(li<ArraySize(m_drawnObjects[idx].gannfanLevelStyle))  { outValue=m_drawnObjects[idx].gannfanLevelStyle[li];   return true; } return false; }
           }
         else if(pfx == "gannbox")
           {
            if(fld=="opacity") { if(li<ArraySize(m_drawnObjects[idx].gannboxLevelOpacity)){ outValue=m_drawnObjects[idx].gannboxLevelOpacity[li]; return true; } return false; }
            if(fld=="width")   { if(li<ArraySize(m_drawnObjects[idx].gannboxLevelWidth))  { outValue=m_drawnObjects[idx].gannboxLevelWidth[li];   return true; } return false; }
            if(fld=="style")   { if(li<ArraySize(m_drawnObjects[idx].gannboxLevelStyle))  { outValue=m_drawnObjects[idx].gannboxLevelStyle[li];   return true; } return false; }
           }
        }
     }

   //--- Unrecognized property ID for the int type
   return false;
  }

//+------------------------------------------------------------------+
//| Read a string-typed property by string ID                        |
//+------------------------------------------------------------------+
bool CDrawingEngine::GetObjectProperty(int objId, string propId, string &outValue)
  {
   //--- Resolve the object's array index by ID; bail on unknown ID
   int idx = FindObjectIndexById(objId);
   if(idx < 0) return false;

   //--- Label text on label-bearing tools
   if(propId == "text")
     {
      outValue = m_drawnObjects[idx].labelText;
      return true;
     }

   //--- Unrecognized property ID for the string type
   return false;
  }

//+------------------------------------------------------------------+
//| Write a color-typed property by string ID (with cascade logic)   |
//+------------------------------------------------------------------+
bool CDrawingEngine::SetObjectProperty(int objId, string propId, color value, bool preview)
  {
   if(!preview) MarkDrawingsDirty();
   //--- Resolve the object's array index by ID; bail on unknown ID
   int idx = FindObjectIndexById(objId);
   if(idx < 0) return false;

   //--- Primary line color - cascades onto per-level color arrays for fib/gann + onto pitchfork part-group colors
   if(propId == "lineColor")
     {
      m_drawnObjects[idx].objColor = value;
      //--- Fib + gann tools render from per-level color arrays - cascade so the global ribbon color picker stays meaningful
      const TOOL_TYPE tt = m_drawnObjects[idx].toolType;
      if(tt == TOOL_FIBO_RETRACEMENT)
        { const int n_=ArraySize(m_drawnObjects[idx].fiboLevelColor);
          for(int kk=0;kk<n_;kk++) m_drawnObjects[idx].fiboLevelColor[kk]=value; }
      else if(tt == TOOL_FIBO_EXPANSION)
        { const int n_=ArraySize(m_drawnObjects[idx].fibexLevelColor);
          for(int kk=0;kk<n_;kk++) m_drawnObjects[idx].fibexLevelColor[kk]=value; }
      else if(tt == TOOL_FIBO_CHANNEL)
        { const int n_=ArraySize(m_drawnObjects[idx].fibchLevelColor);
          for(int kk=0;kk<n_;kk++) m_drawnObjects[idx].fibchLevelColor[kk]=value; }
      else if(tt == TOOL_FIBO_TIMEZONES)
        { const int n_=ArraySize(m_drawnObjects[idx].fibtzLevelColor);
          for(int kk=0;kk<n_;kk++) m_drawnObjects[idx].fibtzLevelColor[kk]=value; }
      else if(tt == TOOL_FIBO_FAN)
        { const int n_=ArraySize(m_drawnObjects[idx].fibfanLevelColor);
          for(int kk=0;kk<n_;kk++) m_drawnObjects[idx].fibfanLevelColor[kk]=value; }
      else if(tt == TOOL_FIBO_ARCS)
        { const int n_=ArraySize(m_drawnObjects[idx].fibarcLevelColor);
          for(int kk=0;kk<n_;kk++) m_drawnObjects[idx].fibarcLevelColor[kk]=value; }
      else if(tt == TOOL_GANN_FAN)
        { const int n_=ArraySize(m_drawnObjects[idx].gannfanLevelColor);
          for(int kk=0;kk<n_;kk++) m_drawnObjects[idx].gannfanLevelColor[kk]=value; }
      else if(tt == TOOL_GANN_BOX)
        { const int n_=ArraySize(m_drawnObjects[idx].gannboxLevelColor);
          for(int kk=0;kk<n_;kk++) m_drawnObjects[idx].gannboxLevelColor[kk]=value; }
      //--- Pitchforks cascade onto all 3 part-group colors (median/outer/inner) which is what actually renders
      else if(tt == TOOL_PITCHFORK
              || tt == TOOL_SCHIFF_PITCHFORK
              || tt == TOOL_MOD_SCHIFF)
        {
         m_drawnObjects[idx].medianColor = value;
         m_drawnObjects[idx].outerColor  = value;
         m_drawnObjects[idx].innerColor  = value;
        }
      RedrawAllObjects();
      return true;
     }
   //--- Text color (no cascade needed)
   if(propId == "textColor")
     {
      m_drawnObjects[idx].textColor = value;
      RedrawAllObjects();
      return true;
     }
   //--- Fill color (no cascade)
   if(propId == "fillColor")
     {
      m_drawnObjects[idx].fillColor = value;
      RedrawAllObjects();
      return true;
     }
   //--- Channel midline color
   if(propId == "midColor")
     {
      m_drawnObjects[idx].midColor = value;
      RedrawAllObjects();
      return true;
     }
   //--- Secondary fill color
   if(propId == "fillColor2")
     {
      m_drawnObjects[idx].fillColor2 = value;
      RedrawAllObjects();
      return true;
     }
   //--- Regression centerline color
   if(propId == "centerColor")
     {
      m_drawnObjects[idx].centerColor = value;
      RedrawAllObjects();
      return true;
     }
   //--- Pitchfork per-part-group color setters
   if(propId == "medianColor")
     { m_drawnObjects[idx].medianColor = value; RedrawAllObjects(); return true; }
   if(propId == "outerColor")
     { m_drawnObjects[idx].outerColor  = value; RedrawAllObjects(); return true; }
   if(propId == "innerColor")
     { m_drawnObjects[idx].innerColor  = value; RedrawAllObjects(); return true; }
   //--- Per-level color set for any PROP_LEVEL_LIST tool
     {
      string pfx; int li; string fld;
      if(ParseLevelPropId(propId, pfx, li, fld) && fld == "color")
        {
         //--- Dispatch by prefix to the matching tool's level-color array
         if(pfx == "fibo")
           {
            if(li < ArraySize(m_drawnObjects[idx].fiboLevelColor))
              { m_drawnObjects[idx].fiboLevelColor[li]=value; RedrawAllObjects(); return true; }
           }
         else if(pfx == "fibex")
           {
            if(li < ArraySize(m_drawnObjects[idx].fibexLevelColor))
              { m_drawnObjects[idx].fibexLevelColor[li]=value; RedrawAllObjects(); return true; }
           }
         else if(pfx == "fibch")
           {
            if(li < ArraySize(m_drawnObjects[idx].fibchLevelColor))
              { m_drawnObjects[idx].fibchLevelColor[li]=value; RedrawAllObjects(); return true; }
           }
         else if(pfx == "fibtz")
           {
            if(li < ArraySize(m_drawnObjects[idx].fibtzLevelColor))
              { m_drawnObjects[idx].fibtzLevelColor[li]=value; RedrawAllObjects(); return true; }
           }
         else if(pfx == "fibfan")
           {
            if(li < ArraySize(m_drawnObjects[idx].fibfanLevelColor))
              { m_drawnObjects[idx].fibfanLevelColor[li]=value; RedrawAllObjects(); return true; }
           }
         else if(pfx == "fibarc")
           {
            if(li < ArraySize(m_drawnObjects[idx].fibarcLevelColor))
              { m_drawnObjects[idx].fibarcLevelColor[li]=value; RedrawAllObjects(); return true; }
           }
         else if(pfx == "gannfan")
           {
            if(li < ArraySize(m_drawnObjects[idx].gannfanLevelColor))
              { m_drawnObjects[idx].gannfanLevelColor[li]=value; RedrawAllObjects(); return true; }
           }
         else if(pfx == "gannbox")
           {
            if(li < ArraySize(m_drawnObjects[idx].gannboxLevelColor))
              { m_drawnObjects[idx].gannboxLevelColor[li]=value; RedrawAllObjects(); return true; }
           }
         //--- Unknown prefix or out-of-range level index
         return false;
        }
     }

   //--- Unrecognized property ID for the color type
   return false;
  }

//+------------------------------------------------------------------+
//| Write an int-typed property by string ID (clamped + cascaded)    |
//+------------------------------------------------------------------+
bool CDrawingEngine::SetObjectProperty(int objId, string propId, int value, bool preview)
  {
   if(!preview) MarkDrawingsDirty();
   //--- Resolve the object's array index by ID; bail on unknown ID
   int idx = FindObjectIndexById(objId);
   if(idx < 0) return false;

   //--- Stroke width (1..4 - clamped defensively; ribbon widget only offers this range)
   if(propId == "lineWidth")
     {
      if(value < 1) value = 1;
      if(value > 4) value = 4;
      m_drawnObjects[idx].lineWidth = value;
      //--- Pitchforks render width from per-part-group fields - cascade so global lineWidth has visible effect
      const TOOL_TYPE tt_w = m_drawnObjects[idx].toolType;
      if(tt_w == TOOL_PITCHFORK
         || tt_w == TOOL_SCHIFF_PITCHFORK
         || tt_w == TOOL_MOD_SCHIFF)
        {
         m_drawnObjects[idx].medianWidth = value;
         m_drawnObjects[idx].outerWidth  = value;
         m_drawnObjects[idx].innerWidth  = value;
        }
      //--- Gann Fan + Gann Box: cascade onto per-level widths
      else if(tt_w == TOOL_GANN_FAN)
        { const int n_=ArraySize(m_drawnObjects[idx].gannfanLevelWidth);
          for(int kk=0;kk<n_;kk++) m_drawnObjects[idx].gannfanLevelWidth[kk]=value; }
      else if(tt_w == TOOL_GANN_BOX)
        { const int n_=ArraySize(m_drawnObjects[idx].gannboxLevelWidth);
          for(int kk=0;kk<n_;kk++) m_drawnObjects[idx].gannboxLevelWidth[kk]=value; }
      RedrawAllObjects();
      return true;
     }
   //--- Stroke style (0..3 - solid/dash/dot/dash-dot)
   if(propId == "lineStyle")
     {
      if(value < 0) value = 0;
      if(value > 3) value = 3;
      m_drawnObjects[idx].lineStyle = value;
      //--- Pitchfork cascade onto per-part-group styles
      const TOOL_TYPE tt_s = m_drawnObjects[idx].toolType;
      if(tt_s == TOOL_PITCHFORK
         || tt_s == TOOL_SCHIFF_PITCHFORK
         || tt_s == TOOL_MOD_SCHIFF)
        {
         m_drawnObjects[idx].medianStyle = value;
         m_drawnObjects[idx].outerStyle  = value;
         m_drawnObjects[idx].innerStyle  = value;
        }
      //--- Gann Fan + Gann Box cascade onto per-level styles
      else if(tt_s == TOOL_GANN_FAN)
        { const int n_=ArraySize(m_drawnObjects[idx].gannfanLevelStyle);
          for(int kk=0;kk<n_;kk++) m_drawnObjects[idx].gannfanLevelStyle[kk]=value; }
      else if(tt_s == TOOL_GANN_BOX)
        { const int n_=ArraySize(m_drawnObjects[idx].gannboxLevelStyle);
          for(int kk=0;kk<n_;kk++) m_drawnObjects[idx].gannboxLevelStyle[kk]=value; }
      RedrawAllObjects();
      return true;
     }
   //--- Per-style opacity setters (0..100 percent; engine renders via ColorWithPercentOpacity)
   if(propId == "lineOpacity")
     {
      if(value < 0)   value = 0;
      if(value > 100) value = 100;
      m_drawnObjects[idx].lineOpacity = value;
      RedrawAllObjects();
      return true;
     }
   if(propId == "textOpacity")
     {
      if(value < 0)   value = 0;
      if(value > 100) value = 100;
      m_drawnObjects[idx].textOpacity = value;
      RedrawAllObjects();
      return true;
     }
   if(propId == "fillOpacity")
     {
      if(value < 0)   value = 0;
      if(value > 100) value = 100;
      m_drawnObjects[idx].fillOpacity = value;
      RedrawAllObjects();
      return true;
     }
   if(propId == "midOpacity")
     {
      if(value < 0)   value = 0;
      if(value > 100) value = 100;
      m_drawnObjects[idx].midOpacity = value;
      RedrawAllObjects();
      return true;
     }
   if(propId == "fillOpacity2")
     {
      if(value < 0)   value = 0;
      if(value > 100) value = 100;
      m_drawnObjects[idx].fillOpacity2 = value;
      RedrawAllObjects();
      return true;
     }
   if(propId == "centerOpacity")
     {
      if(value < 0)   value = 0;
      if(value > 100) value = 100;
      m_drawnObjects[idx].centerOpacity = value;
      RedrawAllObjects();
      return true;
     }
   //--- Channel midline width + style (same 1..4 / 0..3 clamping as the global stroke)
   if(propId == "midWidth")
     {
      if(value < 1) value = 1;
      if(value > 4) value = 4;
      m_drawnObjects[idx].midWidth = value;
      RedrawAllObjects();
      return true;
     }
   if(propId == "midStyle")
     {
      if(value < 0) value = 0;
      if(value > 3) value = 3;
      m_drawnObjects[idx].midStyle = value;
      RedrawAllObjects();
      return true;
     }
   //--- Regression centerline width + style
   if(propId == "centerWidth")
     {
      if(value < 1) value = 1;
      if(value > 4) value = 4;
      m_drawnObjects[idx].centerWidth = value;
      RedrawAllObjects();
      return true;
     }
   if(propId == "centerStyle")
     {
      if(value < 0) value = 0;
      if(value > 3) value = 3;
      m_drawnObjects[idx].centerStyle = value;
      RedrawAllObjects();
      return true;
     }
   //--- Pitchfork per-part-group width/style int setters (same 1..4 / 0..3 clamping)
   if(propId == "medianWidth")
     { if(value<1) value=1; if(value>4) value=4;
       m_drawnObjects[idx].medianWidth = value; RedrawAllObjects(); return true; }
   if(propId == "medianStyle")
     { if(value<0) value=0; if(value>3) value=3;
       m_drawnObjects[idx].medianStyle = value; RedrawAllObjects(); return true; }
   if(propId == "outerWidth")
     { if(value<1) value=1; if(value>4) value=4;
       m_drawnObjects[idx].outerWidth = value; RedrawAllObjects(); return true; }
   if(propId == "outerStyle")
     { if(value<0) value=0; if(value>3) value=3;
       m_drawnObjects[idx].outerStyle = value; RedrawAllObjects(); return true; }
   if(propId == "innerWidth")
     { if(value<1) value=1; if(value>4) value=4;
       m_drawnObjects[idx].innerWidth = value; RedrawAllObjects(); return true; }
   if(propId == "innerStyle")
     { if(value<0) value=0; if(value>3) value=3;
       m_drawnObjects[idx].innerStyle = value; RedrawAllObjects(); return true; }
   //--- Font size (clamped to a wide 6..96 outer band; ribbon dropdown chooses the canonical values)
   if(propId == "fontSize")
     {
      if(value < 6)   value = 6;
      if(value > 96)  value = 96;
      m_drawnObjects[idx].fontSize = value;
      RedrawAllObjects();
      return true;
     }
   //--- Vertical alignment (0=Top, 1=Middle, 2=Bottom)
   if(propId == "vAlign")
     {
      if(value < 0) value = 0;
      if(value > 2) value = 2;
      m_drawnObjects[idx].vAlign = value;
      RedrawAllObjects();
      return true;
     }
   //--- Horizontal alignment (0=Left, 1=Center, 2=Right)
   if(propId == "hAlign")
     {
      if(value < 0) value = 0;
      if(value > 2) value = 2;
      m_drawnObjects[idx].hAlign = value;
      RedrawAllObjects();
      return true;
     }
   //--- Per-level int fields (opacity 0..100, width 1..4, style 0..3)
     {
      string pfx; int li; string fld;
      if(ParseLevelPropId(propId, pfx, li, fld))
        {
         //--- Apply the per-field clamp once before dispatching to the matching tool's level array
         int v = value;
         if(fld == "opacity") { if(v<0) v=0; if(v>100) v=100; }
         else if(fld == "width")   { if(v<1) v=1; if(v>4) v=4; }
         else if(fld == "style")   { if(v<0) v=0; if(v>3) v=3; }
         else return false;
         //--- Dispatch by prefix
         if(pfx == "fibo")
           {
            if(fld=="opacity"&& li<ArraySize(m_drawnObjects[idx].fiboLevelOpacity)) { m_drawnObjects[idx].fiboLevelOpacity[li]=v; RedrawAllObjects(); return true; }
            if(fld=="width"  && li<ArraySize(m_drawnObjects[idx].fiboLevelWidth))   { m_drawnObjects[idx].fiboLevelWidth[li]  =v; RedrawAllObjects(); return true; }
            if(fld=="style"  && li<ArraySize(m_drawnObjects[idx].fiboLevelStyle))   { m_drawnObjects[idx].fiboLevelStyle[li]  =v; RedrawAllObjects(); return true; }
           }
         else if(pfx == "fibex")
           {
            if(fld=="opacity"&& li<ArraySize(m_drawnObjects[idx].fibexLevelOpacity)){ m_drawnObjects[idx].fibexLevelOpacity[li]=v; RedrawAllObjects(); return true; }
            if(fld=="width"  && li<ArraySize(m_drawnObjects[idx].fibexLevelWidth))  { m_drawnObjects[idx].fibexLevelWidth[li]  =v; RedrawAllObjects(); return true; }
            if(fld=="style"  && li<ArraySize(m_drawnObjects[idx].fibexLevelStyle))  { m_drawnObjects[idx].fibexLevelStyle[li]  =v; RedrawAllObjects(); return true; }
           }
         else if(pfx == "fibch")
           {
            if(fld=="opacity"&& li<ArraySize(m_drawnObjects[idx].fibchLevelOpacity)){ m_drawnObjects[idx].fibchLevelOpacity[li]=v; RedrawAllObjects(); return true; }
            if(fld=="width"  && li<ArraySize(m_drawnObjects[idx].fibchLevelWidth))  { m_drawnObjects[idx].fibchLevelWidth[li]  =v; RedrawAllObjects(); return true; }
            if(fld=="style"  && li<ArraySize(m_drawnObjects[idx].fibchLevelStyle))  { m_drawnObjects[idx].fibchLevelStyle[li]  =v; RedrawAllObjects(); return true; }
           }
         else if(pfx == "fibtz")
           {
            if(fld=="opacity"&& li<ArraySize(m_drawnObjects[idx].fibtzLevelOpacity)){ m_drawnObjects[idx].fibtzLevelOpacity[li]=v; RedrawAllObjects(); return true; }
            if(fld=="width"  && li<ArraySize(m_drawnObjects[idx].fibtzLevelWidth))  { m_drawnObjects[idx].fibtzLevelWidth[li]  =v; RedrawAllObjects(); return true; }
            if(fld=="style"  && li<ArraySize(m_drawnObjects[idx].fibtzLevelStyle))  { m_drawnObjects[idx].fibtzLevelStyle[li]  =v; RedrawAllObjects(); return true; }
           }
         else if(pfx == "fibfan")
           {
            if(fld=="opacity"&& li<ArraySize(m_drawnObjects[idx].fibfanLevelOpacity)){ m_drawnObjects[idx].fibfanLevelOpacity[li]=v; RedrawAllObjects(); return true; }
            if(fld=="width"  && li<ArraySize(m_drawnObjects[idx].fibfanLevelWidth))  { m_drawnObjects[idx].fibfanLevelWidth[li]  =v; RedrawAllObjects(); return true; }
            if(fld=="style"  && li<ArraySize(m_drawnObjects[idx].fibfanLevelStyle))  { m_drawnObjects[idx].fibfanLevelStyle[li]  =v; RedrawAllObjects(); return true; }
           }
         else if(pfx == "fibarc")
           {
            if(fld=="opacity"&& li<ArraySize(m_drawnObjects[idx].fibarcLevelOpacity)){ m_drawnObjects[idx].fibarcLevelOpacity[li]=v; RedrawAllObjects(); return true; }
            if(fld=="width"  && li<ArraySize(m_drawnObjects[idx].fibarcLevelWidth))  { m_drawnObjects[idx].fibarcLevelWidth[li]  =v; RedrawAllObjects(); return true; }
            if(fld=="style"  && li<ArraySize(m_drawnObjects[idx].fibarcLevelStyle))  { m_drawnObjects[idx].fibarcLevelStyle[li]  =v; RedrawAllObjects(); return true; }
           }
         else if(pfx == "gannfan")
           {
            if(fld=="opacity"&& li<ArraySize(m_drawnObjects[idx].gannfanLevelOpacity)){ m_drawnObjects[idx].gannfanLevelOpacity[li]=v; RedrawAllObjects(); return true; }
            if(fld=="width"  && li<ArraySize(m_drawnObjects[idx].gannfanLevelWidth))  { m_drawnObjects[idx].gannfanLevelWidth[li]  =v; RedrawAllObjects(); return true; }
            if(fld=="style"  && li<ArraySize(m_drawnObjects[idx].gannfanLevelStyle))  { m_drawnObjects[idx].gannfanLevelStyle[li]  =v; RedrawAllObjects(); return true; }
           }
         else if(pfx == "gannbox")
           {
            if(fld=="opacity"&& li<ArraySize(m_drawnObjects[idx].gannboxLevelOpacity)){ m_drawnObjects[idx].gannboxLevelOpacity[li]=v; RedrawAllObjects(); return true; }
            if(fld=="width"  && li<ArraySize(m_drawnObjects[idx].gannboxLevelWidth))  { m_drawnObjects[idx].gannboxLevelWidth[li]  =v; RedrawAllObjects(); return true; }
            if(fld=="style"  && li<ArraySize(m_drawnObjects[idx].gannboxLevelStyle))  { m_drawnObjects[idx].gannboxLevelStyle[li]  =v; RedrawAllObjects(); return true; }
           }
        }
     }

   //--- Unrecognized property ID for the int type
   return false;
  }

//+------------------------------------------------------------------+
//| Write a string-typed property by string ID                       |
//+------------------------------------------------------------------+
bool CDrawingEngine::SetObjectProperty(int objId, string propId, string value, bool preview)
  {
   if(!preview) MarkDrawingsDirty();
   //--- Resolve the object's array index by ID; bail on unknown ID
   int idx = FindObjectIndexById(objId);
   if(idx < 0) return false;

   //--- Label text on label-bearing tools
   if(propId == "text")
     {
      m_drawnObjects[idx].labelText = value;
      RedrawAllObjects();
      return true;
     }

   //--- Unrecognized property ID for the string type
   return false;
  }

//+------------------------------------------------------------------+
//| Read a bool-typed property by string ID                          |
//+------------------------------------------------------------------+
bool CDrawingEngine::GetObjectProperty(int objId, string propId, bool &outValue)
  {
   //--- Resolve the object's array index by ID; bail on unknown ID
   int idx = FindObjectIndexById(objId);
   if(idx < 0) return false;

   //--- Bold text flag for label-bearing tools
   if(propId == "bold")
     {
      outValue = m_drawnObjects[idx].bold;
      return true;
     }
   //--- Channel midline visibility
   if(propId == "midVisible")
     {
      outValue = m_drawnObjects[idx].midVisible;
      return true;
     }
   //--- Regression centerline + std-dev band visibility flags
   if(propId == "centerVisible")
     {
      outValue = m_drawnObjects[idx].centerVisible;
      return true;
     }
   if(propId == "upperBandVisible")
     {
      outValue = m_drawnObjects[idx].upperBandVisible;
      return true;
     }
   if(propId == "lowerBandVisible")
     {
      outValue = m_drawnObjects[idx].lowerBandVisible;
      return true;
     }
   //--- Pearson correlation badge visibility (regression channel)
   if(propId == "pearsonVisible")
     {
      outValue = m_drawnObjects[idx].pearsonVisible;
      return true;
     }
   //--- Pitchfork per-part-group visibility getters
   if(propId == "medianVisible") { outValue = m_drawnObjects[idx].medianVisible; return true; }
   if(propId == "outerVisible")  { outValue = m_drawnObjects[idx].outerVisible;  return true; }
   if(propId == "innerVisible")  { outValue = m_drawnObjects[idx].innerVisible;  return true; }
   //--- Per-level visibility for any PROP_LEVEL_LIST tool
     {
      string pfx; int li; string fld;
      if(ParseLevelPropId(propId, pfx, li, fld) && fld == "visible")
        {
         //--- Dispatch by prefix
         if(pfx=="fibo")   { if(li<ArraySize(m_drawnObjects[idx].fiboLevelVisible))   { outValue=m_drawnObjects[idx].fiboLevelVisible[li];   return true; } return false; }
         if(pfx=="fibex")  { if(li<ArraySize(m_drawnObjects[idx].fibexLevelVisible))  { outValue=m_drawnObjects[idx].fibexLevelVisible[li];  return true; } return false; }
         if(pfx=="fibch")  { if(li<ArraySize(m_drawnObjects[idx].fibchLevelVisible))  { outValue=m_drawnObjects[idx].fibchLevelVisible[li];  return true; } return false; }
         if(pfx=="fibtz")  { if(li<ArraySize(m_drawnObjects[idx].fibtzLevelVisible))  { outValue=m_drawnObjects[idx].fibtzLevelVisible[li];  return true; } return false; }
         if(pfx=="fibfan") { if(li<ArraySize(m_drawnObjects[idx].fibfanLevelVisible)) { outValue=m_drawnObjects[idx].fibfanLevelVisible[li]; return true; } return false; }
         if(pfx=="fibarc") { if(li<ArraySize(m_drawnObjects[idx].fibarcLevelVisible)) { outValue=m_drawnObjects[idx].fibarcLevelVisible[li]; return true; } return false; }
         if(pfx=="gannfan"){ if(li<ArraySize(m_drawnObjects[idx].gannfanLevelVisible)){ outValue=m_drawnObjects[idx].gannfanLevelVisible[li];return true; } return false; }
         if(pfx=="gannbox"){ if(li<ArraySize(m_drawnObjects[idx].gannboxLevelVisible)){ outValue=m_drawnObjects[idx].gannboxLevelVisible[li];return true; } return false; }
        }
     }

   //--- Unrecognized property ID for the bool type
   return false;
  }

//+------------------------------------------------------------------+
//| Write a bool-typed property by string ID                         |
//+------------------------------------------------------------------+
bool CDrawingEngine::SetObjectProperty(int objId, string propId, bool value, bool preview)
  {
   if(!preview) MarkDrawingsDirty();
   //--- Resolve the object's array index by ID; bail on unknown ID
   int idx = FindObjectIndexById(objId);
   if(idx < 0) return false;

   //--- Bold text flag
   if(propId == "bold")
     {
      m_drawnObjects[idx].bold = value;
      RedrawAllObjects();
      return true;
     }
   //--- Channel midline visibility
   if(propId == "midVisible")
     {
      m_drawnObjects[idx].midVisible = value;
      RedrawAllObjects();
      return true;
     }
   //--- Regression centerline + std-dev band visibility flags
   if(propId == "centerVisible")
     {
      m_drawnObjects[idx].centerVisible = value;
      RedrawAllObjects();
      return true;
     }
   if(propId == "upperBandVisible")
     {
      m_drawnObjects[idx].upperBandVisible = value;
      RedrawAllObjects();
      return true;
     }
   if(propId == "lowerBandVisible")
     {
      m_drawnObjects[idx].lowerBandVisible = value;
      RedrawAllObjects();
      return true;
     }
   //--- Pearson correlation badge visibility
   if(propId == "pearsonVisible")
     {
      m_drawnObjects[idx].pearsonVisible = value;
      RedrawAllObjects();
      return true;
     }
   //--- Pitchfork per-part-group visibility setters
   if(propId == "medianVisible")
     { m_drawnObjects[idx].medianVisible = value; RedrawAllObjects(); return true; }
   if(propId == "outerVisible")
     { m_drawnObjects[idx].outerVisible  = value; RedrawAllObjects(); return true; }
   if(propId == "innerVisible")
     { m_drawnObjects[idx].innerVisible  = value; RedrawAllObjects(); return true; }
   //--- Per-level visibility set for any PROP_LEVEL_LIST tool
     {
      string pfx; int li; string fld;
      if(ParseLevelPropId(propId, pfx, li, fld) && fld == "visible")
        {
         //--- Dispatch by prefix
         if(pfx=="fibo")   { if(li<ArraySize(m_drawnObjects[idx].fiboLevelVisible))   { m_drawnObjects[idx].fiboLevelVisible[li]  =value; RedrawAllObjects(); return true; } return false; }
         if(pfx=="fibex")  { if(li<ArraySize(m_drawnObjects[idx].fibexLevelVisible))  { m_drawnObjects[idx].fibexLevelVisible[li] =value; RedrawAllObjects(); return true; } return false; }
         if(pfx=="fibch")  { if(li<ArraySize(m_drawnObjects[idx].fibchLevelVisible))  { m_drawnObjects[idx].fibchLevelVisible[li] =value; RedrawAllObjects(); return true; } return false; }
         if(pfx=="fibtz")  { if(li<ArraySize(m_drawnObjects[idx].fibtzLevelVisible))  { m_drawnObjects[idx].fibtzLevelVisible[li] =value; RedrawAllObjects(); return true; } return false; }
         if(pfx=="fibfan") { if(li<ArraySize(m_drawnObjects[idx].fibfanLevelVisible)) { m_drawnObjects[idx].fibfanLevelVisible[li]=value; RedrawAllObjects(); return true; } return false; }
         if(pfx=="fibarc") { if(li<ArraySize(m_drawnObjects[idx].fibarcLevelVisible)) { m_drawnObjects[idx].fibarcLevelVisible[li]=value; RedrawAllObjects(); return true; } return false; }
         if(pfx=="gannfan"){ if(li<ArraySize(m_drawnObjects[idx].gannfanLevelVisible)){ m_drawnObjects[idx].gannfanLevelVisible[li]=value;RedrawAllObjects(); return true; } return false; }
         if(pfx=="gannbox"){ if(li<ArraySize(m_drawnObjects[idx].gannboxLevelVisible)){ m_drawnObjects[idx].gannboxLevelVisible[li]=value;RedrawAllObjects(); return true; } return false; }
        }
     }

   //--- Unrecognized property ID for the bool type
   return false;
  }

//+------------------------------------------------------------------+
//| Read a double-typed property by string ID                        |
//+------------------------------------------------------------------+
bool CDrawingEngine::GetObjectProperty(int objId, string propId, double &outValue)
  {
   //--- Resolve the object's array index by ID; bail on unknown ID
   int idx = FindObjectIndexById(objId);
   if(idx < 0) return false;

   //--- Channel midline offset (fractional position between the two channel lines)
   if(propId == "midOffset")
     {
      outValue = m_drawnObjects[idx].midOffset;
      return true;
     }
   //--- Regression std-dev band sigmas (upper + lower)
   if(propId == "upperBandSigma")
     {
      outValue = m_drawnObjects[idx].upperBandSigma;
      return true;
     }
   if(propId == "lowerBandSigma")
     {
      outValue = m_drawnObjects[idx].lowerBandSigma;
      return true;
     }
   //--- Per-level ratio for any PROP_LEVEL_LIST tool
     {
      string pfx; int li; string fld;
      if(ParseLevelPropId(propId, pfx, li, fld) && fld == "ratio")
        {
         //--- Dispatch by prefix
         if(pfx=="fibo")   { if(li<ArraySize(m_drawnObjects[idx].fiboLevelRatio))   { outValue=m_drawnObjects[idx].fiboLevelRatio[li];   return true; } return false; }
         if(pfx=="fibex")  { if(li<ArraySize(m_drawnObjects[idx].fibexLevelRatio))  { outValue=m_drawnObjects[idx].fibexLevelRatio[li];  return true; } return false; }
         if(pfx=="fibch")  { if(li<ArraySize(m_drawnObjects[idx].fibchLevelRatio))  { outValue=m_drawnObjects[idx].fibchLevelRatio[li];  return true; } return false; }
         if(pfx=="fibtz")  { if(li<ArraySize(m_drawnObjects[idx].fibtzLevelRatio))  { outValue=m_drawnObjects[idx].fibtzLevelRatio[li];  return true; } return false; }
         if(pfx=="fibfan") { if(li<ArraySize(m_drawnObjects[idx].fibfanLevelRatio)) { outValue=m_drawnObjects[idx].fibfanLevelRatio[li]; return true; } return false; }
         if(pfx=="fibarc") { if(li<ArraySize(m_drawnObjects[idx].fibarcLevelRatio)) { outValue=m_drawnObjects[idx].fibarcLevelRatio[li]; return true; } return false; }
         if(pfx=="gannfan"){ if(li<ArraySize(m_drawnObjects[idx].gannfanLevelRatio)){ outValue=m_drawnObjects[idx].gannfanLevelRatio[li];return true; } return false; }
         if(pfx=="gannbox"){ if(li<ArraySize(m_drawnObjects[idx].gannboxLevelRatio)){ outValue=m_drawnObjects[idx].gannboxLevelRatio[li];return true; } return false; }
        }
     }
   //--- Unrecognized property ID for the double type
   return false;
  }

//+------------------------------------------------------------------+
//| Write a double-typed property by string ID (clamped)             |
//+------------------------------------------------------------------+
bool CDrawingEngine::SetObjectProperty(int objId, string propId, double value, bool preview)
  {
   if(!preview) MarkDrawingsDirty();
   //--- Resolve the object's array index by ID; bail on unknown ID
   int idx = FindObjectIndexById(objId);
   if(idx < 0) return false;

   //--- Channel midline offset (clamped 0.05..0.95 to avoid degenerate placement)
   if(propId == "midOffset")
     {
      if(value < 0.05) value = 0.05;
      if(value > 0.95) value = 0.95;
      m_drawnObjects[idx].midOffset = value;
      RedrawAllObjects();
      return true;
     }
   //--- Regression std-dev band sigmas (clamped 0.1..10.0)
   if(propId == "upperBandSigma")
     {
      if(value < 0.1)  value = 0.1;
      if(value > 10.0) value = 10.0;
      m_drawnObjects[idx].upperBandSigma = value;
      RedrawAllObjects();
      return true;
     }
   if(propId == "lowerBandSigma")
     {
      if(value < 0.1)  value = 0.1;
      if(value > 10.0) value = 10.0;
      m_drawnObjects[idx].lowerBandSigma = value;
      RedrawAllObjects();
      return true;
     }
   //--- Per-level ratio set - permissive range -10..10
     {
      string pfx; int li; string fld;
      if(ParseLevelPropId(propId, pfx, li, fld) && fld == "ratio")
        {
         if(value < -10.0) value = -10.0;
         if(value >  10.0) value =  10.0;
         //--- Dispatch by prefix
         if(pfx=="fibo")   { if(li<ArraySize(m_drawnObjects[idx].fiboLevelRatio))   { m_drawnObjects[idx].fiboLevelRatio[li]  =value; RedrawAllObjects(); return true; } return false; }
         if(pfx=="fibex")  { if(li<ArraySize(m_drawnObjects[idx].fibexLevelRatio))  { m_drawnObjects[idx].fibexLevelRatio[li] =value; RedrawAllObjects(); return true; } return false; }
         if(pfx=="fibch")  { if(li<ArraySize(m_drawnObjects[idx].fibchLevelRatio))  { m_drawnObjects[idx].fibchLevelRatio[li] =value; RedrawAllObjects(); return true; } return false; }
         if(pfx=="fibtz")  { if(li<ArraySize(m_drawnObjects[idx].fibtzLevelRatio))  { m_drawnObjects[idx].fibtzLevelRatio[li] =value; RedrawAllObjects(); return true; } return false; }
         if(pfx=="fibfan") { if(li<ArraySize(m_drawnObjects[idx].fibfanLevelRatio)) { m_drawnObjects[idx].fibfanLevelRatio[li]=value; RedrawAllObjects(); return true; } return false; }
         if(pfx=="fibarc") { if(li<ArraySize(m_drawnObjects[idx].fibarcLevelRatio)) { m_drawnObjects[idx].fibarcLevelRatio[li]=value; RedrawAllObjects(); return true; } return false; }
         if(pfx=="gannfan"){ if(li<ArraySize(m_drawnObjects[idx].gannfanLevelRatio)){ m_drawnObjects[idx].gannfanLevelRatio[li]=value;RedrawAllObjects(); return true; } return false; }
         if(pfx=="gannbox"){ if(li<ArraySize(m_drawnObjects[idx].gannboxLevelRatio)){ m_drawnObjects[idx].gannboxLevelRatio[li]=value;RedrawAllObjects(); return true; } return false; }
        }
     }
   //--- Unrecognized property ID for the double type
   return false;
  }

//+------------------------------------------------------------------+
//| Snapshot the full state of an object (for Cancel-revert)         |
//+------------------------------------------------------------------+
bool CDrawingEngine::SnapshotProperties(int objId)
  {
   //--- Resolve the object's array index by ID
   int idx = FindObjectIndexById(objId);
   if(idx < 0)
     {
      //--- No such object - clear the backup defensively so a later RestoreProperties() doesn't restore stale data
      m_propertyBackupValid = false;
      return false;
     }

   //--- Stash the object ID + bulk-copy the current state into the backup struct
   m_propertyBackupValid    = true;
   m_propertyBackupObjectId = objId;
   m_propertyBackupSnapshot = m_drawnObjects[idx];
   //--- Deep-copy every parallel level-array for fibo retracement (struct assignment in MQL5 doesn't deep-copy dynamic arrays)
   ArrayCopy(m_propertyBackupSnapshot.fiboLevelRatio,    m_drawnObjects[idx].fiboLevelRatio);
   ArrayCopy(m_propertyBackupSnapshot.fiboLevelColor,    m_drawnObjects[idx].fiboLevelColor);
   ArrayCopy(m_propertyBackupSnapshot.fiboLevelOpacity,  m_drawnObjects[idx].fiboLevelOpacity);
   ArrayCopy(m_propertyBackupSnapshot.fiboLevelWidth,    m_drawnObjects[idx].fiboLevelWidth);
   ArrayCopy(m_propertyBackupSnapshot.fiboLevelStyle,    m_drawnObjects[idx].fiboLevelStyle);
   ArrayCopy(m_propertyBackupSnapshot.fiboLevelVisible,  m_drawnObjects[idx].fiboLevelVisible);

   //--- Fibo expansion levels
   ArrayCopy(m_propertyBackupSnapshot.fibexLevelRatio,   m_drawnObjects[idx].fibexLevelRatio);
   ArrayCopy(m_propertyBackupSnapshot.fibexLevelColor,   m_drawnObjects[idx].fibexLevelColor);
   ArrayCopy(m_propertyBackupSnapshot.fibexLevelOpacity, m_drawnObjects[idx].fibexLevelOpacity);
   ArrayCopy(m_propertyBackupSnapshot.fibexLevelWidth,   m_drawnObjects[idx].fibexLevelWidth);
   ArrayCopy(m_propertyBackupSnapshot.fibexLevelStyle,   m_drawnObjects[idx].fibexLevelStyle);
   ArrayCopy(m_propertyBackupSnapshot.fibexLevelVisible, m_drawnObjects[idx].fibexLevelVisible);

   //--- Fibo channel levels
   ArrayCopy(m_propertyBackupSnapshot.fibchLevelRatio,   m_drawnObjects[idx].fibchLevelRatio);
   ArrayCopy(m_propertyBackupSnapshot.fibchLevelColor,   m_drawnObjects[idx].fibchLevelColor);
   ArrayCopy(m_propertyBackupSnapshot.fibchLevelOpacity, m_drawnObjects[idx].fibchLevelOpacity);
   ArrayCopy(m_propertyBackupSnapshot.fibchLevelWidth,   m_drawnObjects[idx].fibchLevelWidth);
   ArrayCopy(m_propertyBackupSnapshot.fibchLevelStyle,   m_drawnObjects[idx].fibchLevelStyle);
   ArrayCopy(m_propertyBackupSnapshot.fibchLevelVisible, m_drawnObjects[idx].fibchLevelVisible);

   //--- Fibo time-zone levels
   ArrayCopy(m_propertyBackupSnapshot.fibtzLevelRatio,   m_drawnObjects[idx].fibtzLevelRatio);
   ArrayCopy(m_propertyBackupSnapshot.fibtzLevelColor,   m_drawnObjects[idx].fibtzLevelColor);
   ArrayCopy(m_propertyBackupSnapshot.fibtzLevelOpacity, m_drawnObjects[idx].fibtzLevelOpacity);
   ArrayCopy(m_propertyBackupSnapshot.fibtzLevelWidth,   m_drawnObjects[idx].fibtzLevelWidth);
   ArrayCopy(m_propertyBackupSnapshot.fibtzLevelStyle,   m_drawnObjects[idx].fibtzLevelStyle);
   ArrayCopy(m_propertyBackupSnapshot.fibtzLevelVisible, m_drawnObjects[idx].fibtzLevelVisible);

   //--- Fibo fan levels
   ArrayCopy(m_propertyBackupSnapshot.fibfanLevelRatio,   m_drawnObjects[idx].fibfanLevelRatio);
   ArrayCopy(m_propertyBackupSnapshot.fibfanLevelColor,   m_drawnObjects[idx].fibfanLevelColor);
   ArrayCopy(m_propertyBackupSnapshot.fibfanLevelOpacity, m_drawnObjects[idx].fibfanLevelOpacity);
   ArrayCopy(m_propertyBackupSnapshot.fibfanLevelWidth,   m_drawnObjects[idx].fibfanLevelWidth);
   ArrayCopy(m_propertyBackupSnapshot.fibfanLevelStyle,   m_drawnObjects[idx].fibfanLevelStyle);
   ArrayCopy(m_propertyBackupSnapshot.fibfanLevelVisible, m_drawnObjects[idx].fibfanLevelVisible);

   //--- Fibo arc levels
   ArrayCopy(m_propertyBackupSnapshot.fibarcLevelRatio,   m_drawnObjects[idx].fibarcLevelRatio);
   ArrayCopy(m_propertyBackupSnapshot.fibarcLevelColor,   m_drawnObjects[idx].fibarcLevelColor);
   ArrayCopy(m_propertyBackupSnapshot.fibarcLevelOpacity, m_drawnObjects[idx].fibarcLevelOpacity);
   ArrayCopy(m_propertyBackupSnapshot.fibarcLevelWidth,   m_drawnObjects[idx].fibarcLevelWidth);
   ArrayCopy(m_propertyBackupSnapshot.fibarcLevelStyle,   m_drawnObjects[idx].fibarcLevelStyle);
   ArrayCopy(m_propertyBackupSnapshot.fibarcLevelVisible, m_drawnObjects[idx].fibarcLevelVisible);

   //--- Gann fan levels
   ArrayCopy(m_propertyBackupSnapshot.gannfanLevelRatio,   m_drawnObjects[idx].gannfanLevelRatio);
   ArrayCopy(m_propertyBackupSnapshot.gannfanLevelColor,   m_drawnObjects[idx].gannfanLevelColor);
   ArrayCopy(m_propertyBackupSnapshot.gannfanLevelOpacity, m_drawnObjects[idx].gannfanLevelOpacity);
   ArrayCopy(m_propertyBackupSnapshot.gannfanLevelWidth,   m_drawnObjects[idx].gannfanLevelWidth);
   ArrayCopy(m_propertyBackupSnapshot.gannfanLevelStyle,   m_drawnObjects[idx].gannfanLevelStyle);
   ArrayCopy(m_propertyBackupSnapshot.gannfanLevelVisible, m_drawnObjects[idx].gannfanLevelVisible);

   //--- Gann box levels
   ArrayCopy(m_propertyBackupSnapshot.gannboxLevelRatio,   m_drawnObjects[idx].gannboxLevelRatio);
   ArrayCopy(m_propertyBackupSnapshot.gannboxLevelColor,   m_drawnObjects[idx].gannboxLevelColor);
   ArrayCopy(m_propertyBackupSnapshot.gannboxLevelOpacity, m_drawnObjects[idx].gannboxLevelOpacity);
   ArrayCopy(m_propertyBackupSnapshot.gannboxLevelWidth,   m_drawnObjects[idx].gannboxLevelWidth);
   ArrayCopy(m_propertyBackupSnapshot.gannboxLevelStyle,   m_drawnObjects[idx].gannboxLevelStyle);
   ArrayCopy(m_propertyBackupSnapshot.gannboxLevelVisible, m_drawnObjects[idx].gannboxLevelVisible);
   return true;
  }

//+------------------------------------------------------------------+
//| Restore the snapshotted object state (called on Cancel)          |
//+------------------------------------------------------------------+
bool CDrawingEngine::RestoreProperties()
  {
   //--- Nothing to restore if no snapshot was taken
   if(!m_propertyBackupValid) return false;

   //--- Resolve where the snapshotted object now lives in the array
   int idx = FindObjectIndexById(m_propertyBackupObjectId);
   if(idx < 0)
     {
      //--- Object was deleted while the edit session was open - invalidate the snapshot
      m_propertyBackupValid = false;
      return false;
     }

   //--- Bulk-copy the snapshot back into the live object
   m_drawnObjects[idx]   = m_propertyBackupSnapshot;
   //--- Mirror the deep-copy from SnapshotProperties for fibo retracement - clone each parallel level-array back
   ArrayCopy(m_drawnObjects[idx].fiboLevelRatio,    m_propertyBackupSnapshot.fiboLevelRatio);
   ArrayCopy(m_drawnObjects[idx].fiboLevelColor,    m_propertyBackupSnapshot.fiboLevelColor);
   ArrayCopy(m_drawnObjects[idx].fiboLevelOpacity,  m_propertyBackupSnapshot.fiboLevelOpacity);
   ArrayCopy(m_drawnObjects[idx].fiboLevelWidth,    m_propertyBackupSnapshot.fiboLevelWidth);
   ArrayCopy(m_drawnObjects[idx].fiboLevelStyle,    m_propertyBackupSnapshot.fiboLevelStyle);
   ArrayCopy(m_drawnObjects[idx].fiboLevelVisible,  m_propertyBackupSnapshot.fiboLevelVisible);

   //--- Fibo expansion levels
   ArrayCopy(m_drawnObjects[idx].fibexLevelRatio,   m_propertyBackupSnapshot.fibexLevelRatio);
   ArrayCopy(m_drawnObjects[idx].fibexLevelColor,   m_propertyBackupSnapshot.fibexLevelColor);
   ArrayCopy(m_drawnObjects[idx].fibexLevelOpacity, m_propertyBackupSnapshot.fibexLevelOpacity);
   ArrayCopy(m_drawnObjects[idx].fibexLevelWidth,   m_propertyBackupSnapshot.fibexLevelWidth);
   ArrayCopy(m_drawnObjects[idx].fibexLevelStyle,   m_propertyBackupSnapshot.fibexLevelStyle);
   ArrayCopy(m_drawnObjects[idx].fibexLevelVisible, m_propertyBackupSnapshot.fibexLevelVisible);

   //--- Fibo channel levels
   ArrayCopy(m_drawnObjects[idx].fibchLevelRatio,   m_propertyBackupSnapshot.fibchLevelRatio);
   ArrayCopy(m_drawnObjects[idx].fibchLevelColor,   m_propertyBackupSnapshot.fibchLevelColor);
   ArrayCopy(m_drawnObjects[idx].fibchLevelOpacity, m_propertyBackupSnapshot.fibchLevelOpacity);
   ArrayCopy(m_drawnObjects[idx].fibchLevelWidth,   m_propertyBackupSnapshot.fibchLevelWidth);
   ArrayCopy(m_drawnObjects[idx].fibchLevelStyle,   m_propertyBackupSnapshot.fibchLevelStyle);
   ArrayCopy(m_drawnObjects[idx].fibchLevelVisible, m_propertyBackupSnapshot.fibchLevelVisible);

   //--- Fibo time-zone levels
   ArrayCopy(m_drawnObjects[idx].fibtzLevelRatio,   m_propertyBackupSnapshot.fibtzLevelRatio);
   ArrayCopy(m_drawnObjects[idx].fibtzLevelColor,   m_propertyBackupSnapshot.fibtzLevelColor);
   ArrayCopy(m_drawnObjects[idx].fibtzLevelOpacity, m_propertyBackupSnapshot.fibtzLevelOpacity);
   ArrayCopy(m_drawnObjects[idx].fibtzLevelWidth,   m_propertyBackupSnapshot.fibtzLevelWidth);
   ArrayCopy(m_drawnObjects[idx].fibtzLevelStyle,   m_propertyBackupSnapshot.fibtzLevelStyle);
   ArrayCopy(m_drawnObjects[idx].fibtzLevelVisible, m_propertyBackupSnapshot.fibtzLevelVisible);

   //--- Fibo fan levels
   ArrayCopy(m_drawnObjects[idx].fibfanLevelRatio,   m_propertyBackupSnapshot.fibfanLevelRatio);
   ArrayCopy(m_drawnObjects[idx].fibfanLevelColor,   m_propertyBackupSnapshot.fibfanLevelColor);
   ArrayCopy(m_drawnObjects[idx].fibfanLevelOpacity, m_propertyBackupSnapshot.fibfanLevelOpacity);
   ArrayCopy(m_drawnObjects[idx].fibfanLevelWidth,   m_propertyBackupSnapshot.fibfanLevelWidth);
   ArrayCopy(m_drawnObjects[idx].fibfanLevelStyle,   m_propertyBackupSnapshot.fibfanLevelStyle);
   ArrayCopy(m_drawnObjects[idx].fibfanLevelVisible, m_propertyBackupSnapshot.fibfanLevelVisible);

   //--- Fibo arc levels
   ArrayCopy(m_drawnObjects[idx].fibarcLevelRatio,   m_propertyBackupSnapshot.fibarcLevelRatio);
   ArrayCopy(m_drawnObjects[idx].fibarcLevelColor,   m_propertyBackupSnapshot.fibarcLevelColor);
   ArrayCopy(m_drawnObjects[idx].fibarcLevelOpacity, m_propertyBackupSnapshot.fibarcLevelOpacity);
   ArrayCopy(m_drawnObjects[idx].fibarcLevelWidth,   m_propertyBackupSnapshot.fibarcLevelWidth);
   ArrayCopy(m_drawnObjects[idx].fibarcLevelStyle,   m_propertyBackupSnapshot.fibarcLevelStyle);
   ArrayCopy(m_drawnObjects[idx].fibarcLevelVisible, m_propertyBackupSnapshot.fibarcLevelVisible);

   //--- Gann fan levels
   ArrayCopy(m_drawnObjects[idx].gannfanLevelRatio,   m_propertyBackupSnapshot.gannfanLevelRatio);
   ArrayCopy(m_drawnObjects[idx].gannfanLevelColor,   m_propertyBackupSnapshot.gannfanLevelColor);
   ArrayCopy(m_drawnObjects[idx].gannfanLevelOpacity, m_propertyBackupSnapshot.gannfanLevelOpacity);
   ArrayCopy(m_drawnObjects[idx].gannfanLevelWidth,   m_propertyBackupSnapshot.gannfanLevelWidth);
   ArrayCopy(m_drawnObjects[idx].gannfanLevelStyle,   m_propertyBackupSnapshot.gannfanLevelStyle);
   ArrayCopy(m_drawnObjects[idx].gannfanLevelVisible, m_propertyBackupSnapshot.gannfanLevelVisible);

   //--- Gann box levels
   ArrayCopy(m_drawnObjects[idx].gannboxLevelRatio,   m_propertyBackupSnapshot.gannboxLevelRatio);
   ArrayCopy(m_drawnObjects[idx].gannboxLevelColor,   m_propertyBackupSnapshot.gannboxLevelColor);
   ArrayCopy(m_drawnObjects[idx].gannboxLevelOpacity, m_propertyBackupSnapshot.gannboxLevelOpacity);
   ArrayCopy(m_drawnObjects[idx].gannboxLevelWidth,   m_propertyBackupSnapshot.gannboxLevelWidth);
   ArrayCopy(m_drawnObjects[idx].gannboxLevelStyle,   m_propertyBackupSnapshot.gannboxLevelStyle);
   ArrayCopy(m_drawnObjects[idx].gannboxLevelVisible, m_propertyBackupSnapshot.gannboxLevelVisible);
   //--- Invalidate the snapshot and force a redraw to make the restore visible
   m_propertyBackupValid = false;
   RedrawAllObjects();
   return true;
  }

//+------------------------------------------------------------------+
//| Discard the snapshot (called on OK) + capture per-tool memory    |
//+------------------------------------------------------------------+
void CDrawingEngine::DiscardSnapshot()
  {
   //--- Capture per-tool memory BEFORE clearing the snapshot flag - so future placements of the same tool seed from these committed values
   if(m_propertyBackupValid)
     {
      const int idx = FindObjectIndexById(m_propertyBackupObjectId);
      if(idx >= 0) CaptureToolMemory(idx);
     }
   m_propertyBackupValid = false;
  }

//+------------------------------------------------------------------+
//| AppendFibLevel - extend the parallel level-arrays by one         |
//+------------------------------------------------------------------+
bool CDrawingEngine::AppendFibLevel(int objId)
  {
   //--- Resolve the object's array index by ID
   int idx = FindObjectIndexById(objId);
   if(idx < 0) return false;
   //--- Compute new size = old size + 1 + grow all 6 parallel arrays
   const int oldN = ArraySize(m_drawnObjects[idx].fiboLevelRatio);
   const int newN = oldN + 1;
   ArrayResize(m_drawnObjects[idx].fiboLevelRatio,    newN);
   ArrayResize(m_drawnObjects[idx].fiboLevelColor,    newN);
   ArrayResize(m_drawnObjects[idx].fiboLevelOpacity,  newN);
   ArrayResize(m_drawnObjects[idx].fiboLevelWidth,    newN);
   ArrayResize(m_drawnObjects[idx].fiboLevelStyle,    newN);
   ArrayResize(m_drawnObjects[idx].fiboLevelVisible,  newN);
   //--- Seed the new level's ratio as (last + 0.382), falling back to 0.5 when the array was empty
   const double seedRatio = (oldN > 0)
                              ? m_drawnObjects[idx].fiboLevelRatio[oldN - 1] + 0.382
                              : 0.5;
   //--- Cycle a 6-color palette so successive adds look visually distinct
   const color palette[] = {clrSeaGreen, clrDodgerBlue, clrCrimson,
                              clrGoldenrod, clrMediumOrchid, clrDarkCyan};
   const color seedColor = palette[oldN % 6];
   //--- Populate the new level slot with the seeded values + safe defaults
   m_drawnObjects[idx].fiboLevelRatio[oldN]    = seedRatio;
   m_drawnObjects[idx].fiboLevelColor[oldN]    = seedColor;
   m_drawnObjects[idx].fiboLevelOpacity[oldN]  = 100;
   m_drawnObjects[idx].fiboLevelWidth[oldN]    = 2;
   m_drawnObjects[idx].fiboLevelStyle[oldN]    = 0;
   m_drawnObjects[idx].fiboLevelVisible[oldN]  = true;
   RedrawAllObjects();
   return true;
  }

//+------------------------------------------------------------------+
//| RemoveFibLevel - drop one level (refuses to drop below 1)        |
//+------------------------------------------------------------------+
bool CDrawingEngine::RemoveFibLevel(int objId, int levelIdx)
  {
   //--- Resolve the object's array index by ID
   int idx = FindObjectIndexById(objId);
   if(idx < 0) return false;
   //--- Refuse to drop the last level - we always keep at least one
   const int oldN = ArraySize(m_drawnObjects[idx].fiboLevelRatio);
   if(oldN <= 1) return false;     // keep at least 1 level
   //--- Bounds-check the level index
   if(levelIdx < 0 || levelIdx >= oldN) return false;
   //--- Shift every element after levelIdx one slot to the left across all 6 parallel arrays
   for(int k = levelIdx; k < oldN - 1; k++)
     {
      m_drawnObjects[idx].fiboLevelRatio[k]   = m_drawnObjects[idx].fiboLevelRatio[k + 1];
      m_drawnObjects[idx].fiboLevelColor[k]   = m_drawnObjects[idx].fiboLevelColor[k + 1];
      m_drawnObjects[idx].fiboLevelOpacity[k] = m_drawnObjects[idx].fiboLevelOpacity[k + 1];
      m_drawnObjects[idx].fiboLevelWidth[k]   = m_drawnObjects[idx].fiboLevelWidth[k + 1];
      m_drawnObjects[idx].fiboLevelStyle[k]   = m_drawnObjects[idx].fiboLevelStyle[k + 1];
      m_drawnObjects[idx].fiboLevelVisible[k] = m_drawnObjects[idx].fiboLevelVisible[k + 1];
     }
   //--- Truncate all 6 parallel arrays by one slot
   ArrayResize(m_drawnObjects[idx].fiboLevelRatio,    oldN - 1);
   ArrayResize(m_drawnObjects[idx].fiboLevelColor,    oldN - 1);
   ArrayResize(m_drawnObjects[idx].fiboLevelOpacity,  oldN - 1);
   ArrayResize(m_drawnObjects[idx].fiboLevelWidth,    oldN - 1);
   ArrayResize(m_drawnObjects[idx].fiboLevelStyle,    oldN - 1);
   ArrayResize(m_drawnObjects[idx].fiboLevelVisible,  oldN - 1);
   RedrawAllObjects();
   return true;
  }

//+------------------------------------------------------------------+
//| GetObjectPointCount - number of anchor points for the tool       |
//+------------------------------------------------------------------+
int CDrawingEngine::GetObjectPointCount(int objId)
  {
   //--- Resolve the object's array index by ID; bail on unknown ID
   int idx = FindObjectIndexById(objId);
   if(idx < 0) return 0;
   //--- Dispatch by tool type to determine the point count
   const TOOL_TYPE t = m_drawnObjects[idx].toolType;
   //--- Path tool uses the dynamic pathTimes array
   if(t == TOOL_PATH) return ArraySize(m_drawnObjects[idx].pathTimes);
   //--- Horizontal/vertical lines have a single anchor
   if(t == TOOL_HLINE || t == TOOL_VLINE) return 1;
   //--- Triangle is a 3-point tool
   if(t == TOOL_TRIANGLE) return 3;
   //--- Default: 2-point tools (trendline, ray, rectangle, channels, fibs, etc.)
   return 2;
  }

//+------------------------------------------------------------------+
//| GetObjectPointPrice - read the price at anchor point pointIdx    |
//+------------------------------------------------------------------+
bool CDrawingEngine::GetObjectPointPrice(int objId, int pointIdx, double &outPrice)
  {
   //--- Resolve the object's array index by ID; bail on unknown ID
   int idx = FindObjectIndexById(objId);
   if(idx < 0) return false;
   //--- Path tool reads from its dynamic pathPrices array
   const TOOL_TYPE t = m_drawnObjects[idx].toolType;
   if(t == TOOL_PATH)
     {
      const int n = ArraySize(m_drawnObjects[idx].pathPrices);
      if(pointIdx < 0 || pointIdx >= n) return false;
      outPrice = m_drawnObjects[idx].pathPrices[pointIdx];
      return true;
     }
   //--- Non-path tools map point index 0/1/2 to price1/price2/price3
   if(pointIdx == 0) { outPrice = m_drawnObjects[idx].price1; return true; }
   if(pointIdx == 1) { outPrice = m_drawnObjects[idx].price2; return true; }
   if(pointIdx == 2) { outPrice = m_drawnObjects[idx].price3; return true; }
   //--- Out-of-range point index
   return false;
  }

//+------------------------------------------------------------------+
//| GetObjectPointTime - read the time at anchor point pointIdx      |
//+------------------------------------------------------------------+
bool CDrawingEngine::GetObjectPointTime(int objId, int pointIdx, datetime &outTime)
  {
   //--- Resolve the object's array index by ID; bail on unknown ID
   int idx = FindObjectIndexById(objId);
   if(idx < 0) return false;
   //--- Path tool reads from its dynamic pathTimes array
   const TOOL_TYPE t = m_drawnObjects[idx].toolType;
   if(t == TOOL_PATH)
     {
      const int n = ArraySize(m_drawnObjects[idx].pathTimes);
      if(pointIdx < 0 || pointIdx >= n) return false;
      outTime = m_drawnObjects[idx].pathTimes[pointIdx];
      return true;
     }
   //--- Non-path tools map point index 0/1/2 to time1/time2/time3
   if(pointIdx == 0) { outTime = m_drawnObjects[idx].time1; return true; }
   if(pointIdx == 1) { outTime = m_drawnObjects[idx].time2; return true; }
   if(pointIdx == 2) { outTime = m_drawnObjects[idx].time3; return true; }
   //--- Out-of-range point index
   return false;
  }

//+------------------------------------------------------------------+
//| SetObjectPointPrice - write the price at anchor point pointIdx   |
//+------------------------------------------------------------------+
bool CDrawingEngine::SetObjectPointPrice(int objId, int pointIdx, double newPrice, bool preview)
  {
   //--- Resolve the object's array index by ID; bail on unknown ID
   int idx = FindObjectIndexById(objId);
   if(idx < 0) return false;
   //--- Dispatch by tool type + track whether the write actually landed (drives the redraw)
   const TOOL_TYPE t = m_drawnObjects[idx].toolType;
   bool ok = false;
   //--- Path tool writes into its dynamic pathPrices array
   if(t == TOOL_PATH)
     {
      const int n = ArraySize(m_drawnObjects[idx].pathPrices);
      if(pointIdx >= 0 && pointIdx < n)
        { m_drawnObjects[idx].pathPrices[pointIdx] = newPrice; ok = true; }
     }
   else
     {
      //--- Non-path tools map point index 0/1/2 to price1/price2/price3
      if(pointIdx == 0) { m_drawnObjects[idx].price1 = newPrice; ok = true; }
      else if(pointIdx == 1) { m_drawnObjects[idx].price2 = newPrice; ok = true; }
      else if(pointIdx == 2) { m_drawnObjects[idx].price3 = newPrice; ok = true; }
     }
   //--- Only redraw if the write actually landed (avoid redraw on bad point indices)
   if(ok) RedrawAllObjects();
   return ok;
  }

//+------------------------------------------------------------------+
//| SetObjectPointTime - write the time at anchor point pointIdx     |
//+------------------------------------------------------------------+
bool CDrawingEngine::SetObjectPointTime(int objId, int pointIdx, datetime newTime, bool preview)
  {
   //--- Resolve the object's array index by ID; bail on unknown ID
   int idx = FindObjectIndexById(objId);
   if(idx < 0) return false;
   //--- Dispatch by tool type + track whether the write actually landed (drives the redraw)
   const TOOL_TYPE t = m_drawnObjects[idx].toolType;
   bool ok = false;
   //--- Path tool writes into its dynamic pathTimes array
   if(t == TOOL_PATH)
     {
      const int n = ArraySize(m_drawnObjects[idx].pathTimes);
      if(pointIdx >= 0 && pointIdx < n)
        { m_drawnObjects[idx].pathTimes[pointIdx] = newTime; ok = true; }
     }
   else
     {
      //--- Non-path tools map point index 0/1/2 to time1/time2/time3
      if(pointIdx == 0) { m_drawnObjects[idx].time1 = newTime; ok = true; }
      else if(pointIdx == 1) { m_drawnObjects[idx].time2 = newTime; ok = true; }
      else if(pointIdx == 2) { m_drawnObjects[idx].time3 = newTime; ok = true; }
     }
   //--- Only redraw if the write actually landed
   if(ok) RedrawAllObjects();
   return ok;
  }

#endif // TOOLS_PALETTE_ENGINE_PROPERTIES_MQH
//+------------------------------------------------------------------+