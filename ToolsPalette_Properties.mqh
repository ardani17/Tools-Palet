//+------------------------------------------------------------------+
//|                                      ToolsPalette_Properties.mqh |
//|                           Copyright 2026, Allan Munene Mutiiria. |
//|                                   https://t.me/Forex_Algo_Trader |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Allan Munene Mutiiria."
#property link "https://t.me/Forex_Algo_Trader"
#property version "1.00"
#property strict

//--- Guard against multiple inclusion of this header
#ifndef TOOLS_PALETTE_PROPERTIES_MQH
#define TOOLS_PALETTE_PROPERTIES_MQH

//--- Pull in the Tools header so TOOL_TYPE and DrawnObject are visible
#include "ToolsPalette_Tools.mqh"

//+------------------------------------------------------------------+
//| Widget-type enum - drives which UI widget renders each property  |
//+------------------------------------------------------------------+
enum PROP_TYPE
  {
   PROP_COLOR,        // color swatch + popup grid + opacity slider
   PROP_LINE_WIDTH,   // dropdown of 1px/2px/3px/4px line previews
   PROP_LINE_STYLE,   // dropdown of continuous/dashed/dotted
   PROP_FONT_SIZE,    // dropdown of common font sizes
   PROP_TEXT,         // single-line text input
   PROP_MULTITEXT,    // multi-line text input (text-tab content)
   PROP_BOOL,         // checkbox
   PROP_OPACITY,      // slider 0..100 percent (used inside color picker)
   PROP_DROPDOWN_INT, // generic int dropdown with string options
   PROP_NUMERIC,      // number input with optional spinners
   PROP_PRICE,        // price input (for coordinate-tab rows)
   PROP_TIME,         // time/bar input (for coordinate-tab rows)
   PROP_FLOAT,        // bounded double with min/max/step/decimals
   PROP_COMPACT_ROW,  // composite row: checkbox + value + color + width + style mini-cubes on one line
   PROP_LEVEL_LIST,   // meta descriptor that expands at runtime into N compact rows + "Add level" row
   PROP_ACTION        // sentinel for action-button ribbon icons (Settings, Remove)
  };

//--- Settings-window tab group names
#define PROP_GROUP_STYLE        "Style"
#define PROP_GROUP_TEXT         "Text"
#define PROP_GROUP_COORDS       "Coordinates"
#define PROP_GROUP_VISIBILITY   "Visibility"

//+------------------------------------------------------------------+
//| SToolProperty - one descriptor entry per editable tool property  |
//+------------------------------------------------------------------+
struct SToolProperty
  {
   //--- Identity + display label + widget type + tab grouping
   string id;
   string label;
   PROP_TYPE type;
   string group;
   bool   showInRibbon;
   bool   showInSettings;
   string tooltip;

   //--- Default value (one slot per supported value type)
   color  defaultColor;
   int    defaultInt;
   double defaultDouble;
   string defaultString;
   bool   defaultBool;

   //--- Dropdown options (used by PROP_DROPDOWN_INT and similar)
   string options[];
   int    optionInts[];

   //--- Numeric bounds + step + decimal-places (used by PROP_FLOAT and PROP_LEVEL_LIST)
   double minValue;
   double maxValue;
   double stepValue;
   int    decimals;

   //--- Sub-property IDs for PROP_COMPACT_ROW (the row's checkbox/value/color/width/style cubes)
   string subVisibleId;
   string subValueId;
   string subColorId;
   string subWidthId;
   string subStyleId;

   //--- Runtime-set fields used by PROP_LEVEL_LIST pseudo-row synthesis
   int    levelIdx;
   bool   isAddLevelRow;
   string levelListPrefix;
  };

//+------------------------------------------------------------------+
//| Map a color property ID to its sibling opacity property ID       |
//+------------------------------------------------------------------+
string ColorToOpacityProp(string colorPropId)
  {
   //--- Hand-rolled mapping for the 5 known top-level color properties
   if(colorPropId == "textColor")    return "textOpacity";
   if(colorPropId == "fillColor")    return "fillOpacity";
   if(colorPropId == "fillColor2")   return "fillOpacity2";
   if(colorPropId == "midColor")     return "midOpacity";
   if(colorPropId == "centerColor")  return "centerOpacity";
   //--- Per-level color IDs end with ":color"; rewrite the suffix to ":opacity"
   const int trailLen = StringLen(":color");
   const int propLen  = StringLen(colorPropId);
   if(propLen > trailLen
      && StringSubstr(colorPropId, propLen - trailLen, trailLen) == ":color")
     {
      return StringSubstr(colorPropId, 0, propLen - trailLen) + ":opacity";
     }
   //--- Default fallback: every unknown color maps to the main line opacity
   return "lineOpacity";
  }

//+------------------------------------------------------------------+
//| Append a compact-row descriptor (checkbox + value + color cubes) |
//+------------------------------------------------------------------+
void AddCompactRowDescriptor(SToolProperty &props[],
                              string id, string label,
                              string subVisibleId, string subValueId,
                              string subColorId, string subWidthId,
                              string subStyleId,
                              string group = "Style",
                              double minValue = 0.0, double maxValue = 100.0,
                              double stepValue = 0.1, int decimals = 2)
  {
   //--- Grow the array by one + populate the new entry
   const int n = ArraySize(props);
   ArrayResize(props, n + 1);
   props[n].id              = id;
   props[n].label           = label;
   props[n].type            = PROP_COMPACT_ROW;
   props[n].group           = group;
   //--- Compact rows live only in the settings window, never in the ribbon
   props[n].showInRibbon    = false;
   props[n].showInSettings  = true;
   props[n].tooltip         = "";
   //--- Default-value slots (compact rows themselves don't carry a value, but populate for safety)
   props[n].defaultColor    = clrBlack;
   props[n].defaultInt      = 0;
   props[n].defaultDouble   = 0.0;
   props[n].defaultString   = "";
   props[n].defaultBool     = false;
   //--- Numeric stepper bounds for the row's value cube
   props[n].minValue        = minValue;
   props[n].maxValue        = maxValue;
   props[n].stepValue       = stepValue;
   props[n].decimals        = decimals;
   //--- Sub-property IDs that wire each mini-cube to its underlying engine property
   props[n].subVisibleId    = subVisibleId;
   props[n].subValueId      = subValueId;
   props[n].subColorId      = subColorId;
   props[n].subWidthId      = subWidthId;
   props[n].subStyleId      = subStyleId;
   //--- Not a level pseudo-row (those get their levelIdx set at runtime)
   props[n].levelIdx        = -1;
   props[n].isAddLevelRow   = false;
   props[n].levelListPrefix = "";
  }

//+------------------------------------------------------------------+
//| Append a single SToolProperty entry to a property list           |
//+------------------------------------------------------------------+
void AddPropertyDescriptor(SToolProperty &props[],
                            string id,
                            string label,
                            PROP_TYPE type,
                            string group,
                            bool showInRibbon,
                            bool showInSettings,
                            string tooltip = "")
  {
   //--- Grow the array by one + populate the new entry's identity fields
   int n = ArraySize(props);
   ArrayResize(props, n + 1);
   props[n].id              = id;
   props[n].label           = label;
   props[n].type            = type;
   props[n].group           = group;
   props[n].showInRibbon    = showInRibbon;
   props[n].showInSettings  = showInSettings;
   props[n].tooltip         = tooltip;
   //--- Not a level pseudo-row (caller can override later for the level-list case)
   props[n].levelIdx        = -1;
   props[n].isAddLevelRow   = false;
   props[n].levelListPrefix = "";
  }

//+------------------------------------------------------------------+
//| Register standard property set for line tools WITHOUT text label |
//+------------------------------------------------------------------+
void RegisterLineToolBaseProperties(SToolProperty &props[])
  {
   //--- Line color (shown in both ribbon and settings)
   AddPropertyDescriptor(props, "lineColor", "Line color",
                          PROP_COLOR, PROP_GROUP_STYLE,
                          true, true, "Line tool colors");
   //--- Line width (default 2 px)
   AddPropertyDescriptor(props, "lineWidth", "Width",
                          PROP_LINE_WIDTH, PROP_GROUP_STYLE,
                          true, true, "Line tool widths");
   props[ArraySize(props) - 1].defaultInt = 2;
   //--- Line style (default solid = 0)
   AddPropertyDescriptor(props, "lineStyle", "Style",
                          PROP_LINE_STYLE, PROP_GROUP_STYLE,
                          true, true, "Style");
   props[ArraySize(props) - 1].defaultInt = 0;
   //--- Line opacity (settings-only; default fully opaque)
   AddPropertyDescriptor(props, "lineOpacity", "Line opacity",
                          PROP_OPACITY, PROP_GROUP_STYLE,
                          false, true, "");
   props[ArraySize(props) - 1].defaultInt = 100;
  }

//+------------------------------------------------------------------+
//| Register standard property set for line tools WITH text label    |
//+------------------------------------------------------------------+
void RegisterLineToolWithLabelProperties(SToolProperty &props[])
  {
   //--- Line color (ribbon + settings)
   AddPropertyDescriptor(props, "lineColor", "Line color",
                          PROP_COLOR, PROP_GROUP_STYLE,
                          true, true, "Line tool colors");
   //--- Text color (ribbon + settings, lives in the Text tab)
   AddPropertyDescriptor(props, "textColor", "Text color",
                          PROP_COLOR, PROP_GROUP_TEXT,
                          true, true, "Line tool text colors");
   //--- Line width + style (default 2 px, solid)
   AddPropertyDescriptor(props, "lineWidth", "Width",
                          PROP_LINE_WIDTH, PROP_GROUP_STYLE,
                          true, true, "Line tool widths");
   props[ArraySize(props) - 1].defaultInt = 2;
   AddPropertyDescriptor(props, "lineStyle", "Style",
                          PROP_LINE_STYLE, PROP_GROUP_STYLE,
                          true, true, "Style");
   props[ArraySize(props) - 1].defaultInt = 0;
   //--- Line opacity (settings only)
   AddPropertyDescriptor(props, "lineOpacity", "Line opacity",
                          PROP_OPACITY, PROP_GROUP_STYLE,
                          false, true, "");
   props[ArraySize(props) - 1].defaultInt = 100;
   //--- Label text + per-text opacity + font size + bold + alignment
   AddPropertyDescriptor(props, "text", "Text",
                          PROP_TEXT, PROP_GROUP_TEXT,
                          false, true, "");
   AddPropertyDescriptor(props, "textOpacity", "Text opacity",
                          PROP_OPACITY, PROP_GROUP_TEXT,
                          false, true, "");
   props[ArraySize(props) - 1].defaultInt = 100;
   AddPropertyDescriptor(props, "fontSize", "Font size",
                          PROP_FONT_SIZE, PROP_GROUP_TEXT,
                          false, true, "");
   props[ArraySize(props) - 1].defaultInt = 11;
   AddPropertyDescriptor(props, "bold", "Bold",
                          PROP_BOOL, PROP_GROUP_TEXT,
                          false, true, "");
   props[ArraySize(props) - 1].defaultBool = false;
   //--- Vertical alignment (default Top = 0)
   AddPropertyDescriptor(props, "vAlign", "Vertical alignment",
                          PROP_DROPDOWN_INT, PROP_GROUP_TEXT,
                          false, true, "");
   props[ArraySize(props) - 1].defaultInt = 0;
   //--- Horizontal alignment (default Center = 1)
   AddPropertyDescriptor(props, "hAlign", "Horizontal alignment",
                          PROP_DROPDOWN_INT, PROP_GROUP_TEXT,
                          false, true, "");
   props[ArraySize(props) - 1].defaultInt = 1;
  }

//+------------------------------------------------------------------+
//| Register property set for closed shapes (rect/triangle/ellipse)  |
//+------------------------------------------------------------------+
void RegisterClosedShapeProperties(SToolProperty &props[],
                                    bool supportsDashedStroke = true)
  {
   //--- Stroke + fill colors (border + interior)
   AddPropertyDescriptor(props, "lineColor", "Line color",
                          PROP_COLOR, PROP_GROUP_STYLE,
                          true, true, "Border color");
   AddPropertyDescriptor(props, "fillColor", "Fill color",
                          PROP_COLOR, PROP_GROUP_STYLE,
                          true, true, "Interior fill color");
   //--- Label text color (Text tab)
   AddPropertyDescriptor(props, "textColor", "Text color",
                          PROP_COLOR, PROP_GROUP_TEXT,
                          true, true, "Label color");
   //--- Border width (default 2 px)
   AddPropertyDescriptor(props, "lineWidth", "Width",
                          PROP_LINE_WIDTH, PROP_GROUP_STYLE,
                          true, true, "Border width");
   props[ArraySize(props) - 1].defaultInt = 2;
   //--- Line style is only registered for tools that support it (curved edges don't dash properly)
   if(supportsDashedStroke)
     {
      AddPropertyDescriptor(props, "lineStyle", "Style",
                             PROP_LINE_STYLE, PROP_GROUP_STYLE,
                             true, true, "Border style");
      props[ArraySize(props) - 1].defaultInt = 0;
     }
   //--- Border + fill opacity (default border fully opaque, fill 30 percent)
   AddPropertyDescriptor(props, "lineOpacity", "Line opacity",
                          PROP_OPACITY, PROP_GROUP_STYLE,
                          false, true, "");
   props[ArraySize(props) - 1].defaultInt = 100;
   AddPropertyDescriptor(props, "fillOpacity", "Fill opacity",
                          PROP_OPACITY, PROP_GROUP_STYLE,
                          false, true, "");
   props[ArraySize(props) - 1].defaultInt = 30;
   //--- Label text + opacity + font + bold + alignment (Text tab)
   AddPropertyDescriptor(props, "text", "Text",
                          PROP_TEXT, PROP_GROUP_TEXT,
                          false, true, "");
   AddPropertyDescriptor(props, "textOpacity", "Text opacity",
                          PROP_OPACITY, PROP_GROUP_TEXT,
                          false, true, "");
   props[ArraySize(props) - 1].defaultInt = 100;
   AddPropertyDescriptor(props, "fontSize", "Font size",
                          PROP_FONT_SIZE, PROP_GROUP_TEXT,
                          false, true, "");
   props[ArraySize(props) - 1].defaultInt = 11;
   AddPropertyDescriptor(props, "bold", "Bold",
                          PROP_BOOL, PROP_GROUP_TEXT,
                          false, true, "");
   props[ArraySize(props) - 1].defaultBool = false;
   AddPropertyDescriptor(props, "vAlign", "Vertical alignment",
                          PROP_DROPDOWN_INT, PROP_GROUP_TEXT,
                          false, true, "");
   props[ArraySize(props) - 1].defaultInt = 0;
   AddPropertyDescriptor(props, "hAlign", "Horizontal alignment",
                          PROP_DROPDOWN_INT, PROP_GROUP_TEXT,
                          false, true, "");
   props[ArraySize(props) - 1].defaultInt = 1;
  }

//+------------------------------------------------------------------+
//| Register Curve shape property set (open curve, no fill or text)  |
//+------------------------------------------------------------------+
void RegisterCurveShapeProperties(SToolProperty &props[])
  {
   //--- Curve color
   AddPropertyDescriptor(props, "lineColor", "Line color",
                          PROP_COLOR, PROP_GROUP_STYLE,
                          true, true, "Curve color");
   //--- Curve width (default 2 px)
   AddPropertyDescriptor(props, "lineWidth", "Width",
                          PROP_LINE_WIDTH, PROP_GROUP_STYLE,
                          true, true, "Curve width");
   props[ArraySize(props) - 1].defaultInt = 2;
   //--- Curve opacity (default fully opaque)
   AddPropertyDescriptor(props, "lineOpacity", "Line opacity",
                          PROP_OPACITY, PROP_GROUP_STYLE,
                          false, true, "");
   props[ArraySize(props) - 1].defaultInt = 100;
  }

//+------------------------------------------------------------------+
//| Register Text annotation property set                            |
//+------------------------------------------------------------------+
void RegisterTextAnnotationProperties(SToolProperty &props[])
  {
   //--- Text color + opacity (default fully opaque)
   AddPropertyDescriptor(props, "textColor", "Text color",
                          PROP_COLOR, PROP_GROUP_TEXT,
                          true, true, "Text color");
   AddPropertyDescriptor(props, "textOpacity", "Text opacity",
                          PROP_OPACITY, PROP_GROUP_TEXT,
                          false, true, "");
   props[ArraySize(props) - 1].defaultInt = 100;
   //--- Font size (default 12 pt, slightly larger than the default line label)
   AddPropertyDescriptor(props, "fontSize", "Font size",
                          PROP_FONT_SIZE, PROP_GROUP_TEXT,
                          false, true, "");
   props[ArraySize(props) - 1].defaultInt = 12;
   //--- Bold + alignment (default Middle + Center)
   AddPropertyDescriptor(props, "bold", "Bold",
                          PROP_BOOL, PROP_GROUP_TEXT,
                          false, true, "");
   props[ArraySize(props) - 1].defaultBool = false;
   AddPropertyDescriptor(props, "vAlign", "Vertical alignment",
                          PROP_DROPDOWN_INT, PROP_GROUP_TEXT,
                          false, true, "");
   props[ArraySize(props) - 1].defaultInt = 1;
   AddPropertyDescriptor(props, "hAlign", "Horizontal alignment",
                          PROP_DROPDOWN_INT, PROP_GROUP_TEXT,
                          false, true, "");
   props[ArraySize(props) - 1].defaultInt = 1;
   //--- The text body itself
   AddPropertyDescriptor(props, "text", "Text",
                          PROP_TEXT, PROP_GROUP_TEXT,
                          false, true, "");
  }

//+------------------------------------------------------------------+
//| Register Arrow annotation property set                           |
//+------------------------------------------------------------------+
void RegisterArrowAnnotationProperties(SToolProperty &props[])
  {
   //--- Arrow shaft + head color
   AddPropertyDescriptor(props, "lineColor", "Line color",
                          PROP_COLOR, PROP_GROUP_STYLE,
                          true, true, "Arrow shaft + head color");
   //--- Floating label color (separate from shaft)
   AddPropertyDescriptor(props, "textColor", "Text color",
                          PROP_COLOR, PROP_GROUP_TEXT,
                          true, true, "Floating-label color");
   //--- Shaft width (default 2 px) + opacity (default fully opaque)
   AddPropertyDescriptor(props, "lineWidth", "Width",
                          PROP_LINE_WIDTH, PROP_GROUP_STYLE,
                          true, true, "Arrow shaft width");
   props[ArraySize(props) - 1].defaultInt = 2;
   AddPropertyDescriptor(props, "lineOpacity", "Line opacity",
                          PROP_OPACITY, PROP_GROUP_STYLE,
                          false, true, "");
   props[ArraySize(props) - 1].defaultInt = 100;
   //--- Floating label text + opacity + font + bold + alignment (Text tab)
   AddPropertyDescriptor(props, "text", "Text",
                          PROP_TEXT, PROP_GROUP_TEXT,
                          false, true, "");
   AddPropertyDescriptor(props, "textOpacity", "Text opacity",
                          PROP_OPACITY, PROP_GROUP_TEXT,
                          false, true, "");
   props[ArraySize(props) - 1].defaultInt = 100;
   AddPropertyDescriptor(props, "fontSize", "Font size",
                          PROP_FONT_SIZE, PROP_GROUP_TEXT,
                          false, true, "");
   props[ArraySize(props) - 1].defaultInt = 11;
   AddPropertyDescriptor(props, "bold", "Bold",
                          PROP_BOOL, PROP_GROUP_TEXT,
                          false, true, "");
   props[ArraySize(props) - 1].defaultBool = false;
   AddPropertyDescriptor(props, "vAlign", "Vertical alignment",
                          PROP_DROPDOWN_INT, PROP_GROUP_TEXT,
                          false, true, "");
   props[ArraySize(props) - 1].defaultInt = 0;
   AddPropertyDescriptor(props, "hAlign", "Horizontal alignment",
                          PROP_DROPDOWN_INT, PROP_GROUP_TEXT,
                          false, true, "");
   props[ArraySize(props) - 1].defaultInt = 1;
  }

//+------------------------------------------------------------------+
//| Register simple-marker annotation property set (color + opacity) |
//+------------------------------------------------------------------+
void RegisterSimpleMarkerProperties(SToolProperty &props[])
  {
   //--- Marker fill color
   AddPropertyDescriptor(props, "lineColor", "Marker color",
                          PROP_COLOR, PROP_GROUP_STYLE,
                          true, true, "Marker fill color");
   //--- Marker opacity (default fully opaque)
   AddPropertyDescriptor(props, "lineOpacity", "Marker opacity",
                          PROP_OPACITY, PROP_GROUP_STYLE,
                          false, true, "");
   props[ArraySize(props) - 1].defaultInt = 100;
  }

//+------------------------------------------------------------------+
//| Register Note annotation property set                            |
//+------------------------------------------------------------------+
void RegisterNoteAnnotationProperties(SToolProperty &props[])
  {
   //--- Connector line color + box fill color
   AddPropertyDescriptor(props, "lineColor", "Connector color",
                          PROP_COLOR, PROP_GROUP_STYLE,
                          true, true, "Connector line color");
   AddPropertyDescriptor(props, "fillColor", "Box fill",
                          PROP_COLOR, PROP_GROUP_STYLE,
                          true, true, "Note box background");
   //--- Text color (Text tab)
   AddPropertyDescriptor(props, "textColor", "Text color",
                          PROP_COLOR, PROP_GROUP_TEXT,
                          true, true, "Text color");
   //--- Line + fill opacity (both default fully opaque)
   AddPropertyDescriptor(props, "lineOpacity", "Line opacity",
                          PROP_OPACITY, PROP_GROUP_STYLE,
                          false, true, "");
   props[ArraySize(props) - 1].defaultInt = 100;
   AddPropertyDescriptor(props, "fillOpacity", "Fill opacity",
                          PROP_OPACITY, PROP_GROUP_STYLE,
                          false, true, "");
   props[ArraySize(props) - 1].defaultInt = 100;
   //--- Label text + opacity + font + bold (Text tab)
   AddPropertyDescriptor(props, "text", "Text",
                          PROP_TEXT, PROP_GROUP_TEXT,
                          false, true, "");
   AddPropertyDescriptor(props, "textOpacity", "Text opacity",
                          PROP_OPACITY, PROP_GROUP_TEXT,
                          false, true, "");
   props[ArraySize(props) - 1].defaultInt = 100;
   AddPropertyDescriptor(props, "fontSize", "Font size",
                          PROP_FONT_SIZE, PROP_GROUP_TEXT,
                          false, true, "");
   props[ArraySize(props) - 1].defaultInt = 12;
   AddPropertyDescriptor(props, "bold", "Bold",
                          PROP_BOOL, PROP_GROUP_TEXT,
                          false, true, "");
   props[ArraySize(props) - 1].defaultBool = false;
  }

//+------------------------------------------------------------------+
//| Register Price Note annotation property set (no body text)       |
//+------------------------------------------------------------------+
void RegisterPriceNoteAnnotationProperties(SToolProperty &props[])
  {
   //--- Border + fill colors (price-note has both)
   AddPropertyDescriptor(props, "lineColor", "Border color",
                          PROP_COLOR, PROP_GROUP_STYLE,
                          true, true, "Border (when stroked)");
   AddPropertyDescriptor(props, "fillColor", "Fill color",
                          PROP_COLOR, PROP_GROUP_STYLE,
                          true, true, "Rectangle fill");
   //--- Text color (Text tab)
   AddPropertyDescriptor(props, "textColor", "Text color",
                          PROP_COLOR, PROP_GROUP_TEXT,
                          true, true, "Price text color");
   //--- Opacity settings (line + fill + text, all default fully opaque)
   AddPropertyDescriptor(props, "lineOpacity", "Line opacity",
                          PROP_OPACITY, PROP_GROUP_STYLE,
                          false, true, "");
   props[ArraySize(props) - 1].defaultInt = 100;
   AddPropertyDescriptor(props, "fillOpacity", "Fill opacity",
                          PROP_OPACITY, PROP_GROUP_STYLE,
                          false, true, "");
   props[ArraySize(props) - 1].defaultInt = 100;
   AddPropertyDescriptor(props, "textOpacity", "Text opacity",
                          PROP_OPACITY, PROP_GROUP_TEXT,
                          false, true, "");
   props[ArraySize(props) - 1].defaultInt = 100;
   //--- Font size (default 10 pt - compact for a price tag)
   AddPropertyDescriptor(props, "fontSize", "Font size",
                          PROP_FONT_SIZE, PROP_GROUP_TEXT,
                          false, true, "");
   props[ArraySize(props) - 1].defaultInt = 10;
  }

//+------------------------------------------------------------------+
//| Register Callout annotation property set                         |
//+------------------------------------------------------------------+
void RegisterCalloutAnnotationProperties(SToolProperty &props[])
  {
   //--- Border (also colors the leader shaft) + body fill
   AddPropertyDescriptor(props, "lineColor", "Border color",
                          PROP_COLOR, PROP_GROUP_STYLE,
                          true, true, "Border + shaft color");
   AddPropertyDescriptor(props, "fillColor", "Fill color",
                          PROP_COLOR, PROP_GROUP_STYLE,
                          true, true, "Body fill");
   //--- Text color (Text tab)
   AddPropertyDescriptor(props, "textColor", "Text color",
                          PROP_COLOR, PROP_GROUP_TEXT,
                          true, true, "Text color");
   //--- Line + fill opacity (both default fully opaque)
   AddPropertyDescriptor(props, "lineOpacity", "Line opacity",
                          PROP_OPACITY, PROP_GROUP_STYLE,
                          false, true, "");
   props[ArraySize(props) - 1].defaultInt = 100;
   AddPropertyDescriptor(props, "fillOpacity", "Fill opacity",
                          PROP_OPACITY, PROP_GROUP_STYLE,
                          false, true, "");
   props[ArraySize(props) - 1].defaultInt = 100;
   //--- Label text + opacity + font + bold (Text tab)
   AddPropertyDescriptor(props, "text", "Text",
                          PROP_TEXT, PROP_GROUP_TEXT,
                          false, true, "");
   AddPropertyDescriptor(props, "textOpacity", "Text opacity",
                          PROP_OPACITY, PROP_GROUP_TEXT,
                          false, true, "");
   props[ArraySize(props) - 1].defaultInt = 100;
   AddPropertyDescriptor(props, "fontSize", "Font size",
                          PROP_FONT_SIZE, PROP_GROUP_TEXT,
                          false, true, "");
   props[ArraySize(props) - 1].defaultInt = 12;
   AddPropertyDescriptor(props, "bold", "Bold",
                          PROP_BOOL, PROP_GROUP_TEXT,
                          false, true, "");
   props[ArraySize(props) - 1].defaultBool = false;
  }

//+------------------------------------------------------------------+
//| Register Comment annotation property set (speech-bubble shape)   |
//+------------------------------------------------------------------+
void RegisterCommentAnnotationProperties(SToolProperty &props[])
  {
   //--- Border (reserved for outline) + bubble fill
   AddPropertyDescriptor(props, "lineColor", "Border color",
                          PROP_COLOR, PROP_GROUP_STYLE,
                          true, true, "Reserved for outline");
   AddPropertyDescriptor(props, "fillColor", "Fill color",
                          PROP_COLOR, PROP_GROUP_STYLE,
                          true, true, "Bubble fill");
   //--- Text color (Text tab)
   AddPropertyDescriptor(props, "textColor", "Text color",
                          PROP_COLOR, PROP_GROUP_TEXT,
                          true, true, "Text color");
   //--- Line + fill opacity (both default fully opaque)
   AddPropertyDescriptor(props, "lineOpacity", "Line opacity",
                          PROP_OPACITY, PROP_GROUP_STYLE,
                          false, true, "");
   props[ArraySize(props) - 1].defaultInt = 100;
   AddPropertyDescriptor(props, "fillOpacity", "Fill opacity",
                          PROP_OPACITY, PROP_GROUP_STYLE,
                          false, true, "");
   props[ArraySize(props) - 1].defaultInt = 100;
   //--- Label text + opacity + font + bold (Text tab)
   AddPropertyDescriptor(props, "text", "Text",
                          PROP_TEXT, PROP_GROUP_TEXT,
                          false, true, "");
   AddPropertyDescriptor(props, "textOpacity", "Text opacity",
                          PROP_OPACITY, PROP_GROUP_TEXT,
                          false, true, "");
   props[ArraySize(props) - 1].defaultInt = 100;
   AddPropertyDescriptor(props, "fontSize", "Font size",
                          PROP_FONT_SIZE, PROP_GROUP_TEXT,
                          false, true, "");
   props[ArraySize(props) - 1].defaultInt = 12;
   AddPropertyDescriptor(props, "bold", "Bold",
                          PROP_BOOL, PROP_GROUP_TEXT,
                          false, true, "");
   props[ArraySize(props) - 1].defaultBool = false;
  }

//+------------------------------------------------------------------+
//| Register property set for a parallel channel (2 lines + mid)     |
//+------------------------------------------------------------------+
void RegisterParallelChannelProperties(SToolProperty &props[])
  {
   //--- Trendline color + parallelogram fill
   AddPropertyDescriptor(props, "lineColor", "Line color",
                          PROP_COLOR, PROP_GROUP_STYLE,
                          true, true, "Trendline color");
   AddPropertyDescriptor(props, "fillColor", "Fill color",
                          PROP_COLOR, PROP_GROUP_STYLE,
                          true, true, "Parallelogram fill");
   //--- Trendline width (default 2 px) + style (default solid)
   AddPropertyDescriptor(props, "lineWidth", "Width",
                          PROP_LINE_WIDTH, PROP_GROUP_STYLE,
                          true, true, "Trendline width");
   props[ArraySize(props) - 1].defaultInt = 2;
   AddPropertyDescriptor(props, "lineStyle", "Style",
                          PROP_LINE_STYLE, PROP_GROUP_STYLE,
                          true, true, "Trendline style");
   props[ArraySize(props) - 1].defaultInt = 0;
   //--- Line + fill opacity (line opaque, fill 30 percent)
   AddPropertyDescriptor(props, "lineOpacity", "Line opacity",
                          PROP_OPACITY, PROP_GROUP_STYLE,
                          false, true, "");
   props[ArraySize(props) - 1].defaultInt = 100;
   AddPropertyDescriptor(props, "fillOpacity", "Fill opacity",
                          PROP_OPACITY, PROP_GROUP_STYLE,
                          false, true, "");
   props[ArraySize(props) - 1].defaultInt = 30;
   //--- Mid-line compact row (visibility + offset value + color + width + style mini-cubes)
   AddCompactRowDescriptor(props, "mid", "Mid-line",
                            "midVisible", "midOffset", "midColor",
                            "midWidth", "midStyle",
                            PROP_GROUP_STYLE,
                            0.05, 0.95, 0.05, 2);
  }

//+------------------------------------------------------------------+
//| Register property set for Fibonacci retracement (PROP_LEVEL_LIST)|
//+------------------------------------------------------------------+
void RegisterFibonacciRetracementProperties(SToolProperty &props[])
  {
   //--- Default level color (ribbon-only; cascades onto per-level colors when changed)
   AddPropertyDescriptor(props, "lineColor", "Default level color",
                          PROP_COLOR, PROP_GROUP_STYLE,
                          true, false, "Default color for new levels");
   //--- Levels list descriptor - manually populated (predates AddLevelListDescriptor below)
   const int n = ArraySize(props);
   ArrayResize(props, n + 1);
   props[n].id              = "fibo";
   props[n].label           = "Levels";
   props[n].type            = PROP_LEVEL_LIST;
   props[n].group           = PROP_GROUP_STYLE;
   //--- Levels live only in the settings window, never in the ribbon
   props[n].showInRibbon    = false;
   props[n].showInSettings  = true;
   props[n].tooltip         = "";
   //--- Default-value slots
   props[n].defaultColor    = clrBlack;
   props[n].defaultInt      = 0;
   props[n].defaultDouble   = 0.0;
   props[n].defaultString   = "";
   props[n].defaultBool     = false;
   //--- Ratio bounds for each level's value cube: -10..10 with 0.01 step and 3 decimal places
   props[n].minValue        = -10.0;
   props[n].maxValue        =  10.0;
   props[n].stepValue       = 0.01;
   props[n].decimals        = 3;
   //--- The level-list itself has no per-row sub-IDs (rows are synthesized at runtime)
   props[n].subVisibleId    = "";
   props[n].subValueId      = "";
   props[n].subColorId      = "";
   props[n].subWidthId      = "";
   props[n].subStyleId      = "";
   props[n].levelIdx        = -1;
   props[n].isAddLevelRow   = false;
   props[n].levelListPrefix = "";
  }

//+------------------------------------------------------------------+
//| Append a PROP_LEVEL_LIST descriptor (helper for other Fib/Gann)  |
//+------------------------------------------------------------------+
void AddLevelListDescriptor(SToolProperty &props[],
                             string id, string label,
                             double minR, double maxR, double stepR, int dec)
  {
   //--- Grow + populate the new descriptor
   const int n = ArraySize(props);
   ArrayResize(props, n + 1);
   props[n].id              = id;
   props[n].label           = label;
   props[n].type            = PROP_LEVEL_LIST;
   props[n].group           = PROP_GROUP_STYLE;
   //--- Levels live only in the settings window
   props[n].showInRibbon    = false;
   props[n].showInSettings  = true;
   props[n].tooltip         = "";
   //--- Default-value slots
   props[n].defaultColor    = clrBlack;
   props[n].defaultInt      = 0;
   props[n].defaultDouble   = 0.0;
   props[n].defaultString   = "";
   props[n].defaultBool     = false;
   //--- Caller-supplied per-level ratio bounds + step + decimal places
   props[n].minValue        = minR;
   props[n].maxValue        = maxR;
   props[n].stepValue       = stepR;
   props[n].decimals        = dec;
   //--- No per-row sub-IDs (rows are synthesized at runtime from the level data)
   props[n].subVisibleId    = "";
   props[n].subValueId      = "";
   props[n].subColorId      = "";
   props[n].subWidthId      = "";
   props[n].subStyleId      = "";
   props[n].levelIdx        = -1;
   props[n].isAddLevelRow   = false;
   props[n].levelListPrefix = "";
  }

//+------------------------------------------------------------------+
//| Register Fibonacci expansion property set                        |
//+------------------------------------------------------------------+
void RegisterFibonacciExpansionProperties(SToolProperty &props[])
  {
   //--- Default level color (ribbon-only)
   AddPropertyDescriptor(props, "lineColor", "Default level color",
                          PROP_COLOR, PROP_GROUP_STYLE,
                          true, false, "Default color for all levels");
   //--- Level list with -10..10 ratio bounds (3 decimal places)
   AddLevelListDescriptor(props, "fibex", "Levels",
                          -10.0, 10.0, 0.01, 3);
  }

//+------------------------------------------------------------------+
//| Register Fibonacci channel property set                          |
//+------------------------------------------------------------------+
void RegisterFibonacciChannelProperties(SToolProperty &props[])
  {
   //--- Default level color (ribbon-only)
   AddPropertyDescriptor(props, "lineColor", "Default level color",
                          PROP_COLOR, PROP_GROUP_STYLE,
                          true, false, "Default color for all levels");
   //--- Level list with -10..10 ratio bounds (3 decimal places)
   AddLevelListDescriptor(props, "fibch", "Levels",
                          -10.0, 10.0, 0.01, 3);
  }

//+------------------------------------------------------------------+
//| Register Fibonacci time-zones property set                       |
//+------------------------------------------------------------------+
void RegisterFibonacciTimezonesProperties(SToolProperty &props[])
  {
   //--- Default bar color (ribbon-only)
   AddPropertyDescriptor(props, "lineColor", "Default level color",
                          PROP_COLOR, PROP_GROUP_STYLE,
                          true, false, "Default color for all bars");
   //--- Level list with 0..200 bar count (integer step, 0 decimal places)
   AddLevelListDescriptor(props, "fibtz", "Bars",
                          0.0, 200.0, 1.0, 0);
  }

//+------------------------------------------------------------------+
//| Register Fibonacci fan property set                              |
//+------------------------------------------------------------------+
void RegisterFibonacciFanProperties(SToolProperty &props[])
  {
   //--- Default ray color (ribbon-only)
   AddPropertyDescriptor(props, "lineColor", "Default level color",
                          PROP_COLOR, PROP_GROUP_STYLE,
                          true, false, "Default color for all rays");
   //--- Level list with -10..10 ratio bounds (3 decimal places)
   AddLevelListDescriptor(props, "fibfan", "Levels",
                          -10.0, 10.0, 0.01, 3);
  }

//+------------------------------------------------------------------+
//| Register Fibonacci arcs property set                             |
//+------------------------------------------------------------------+
void RegisterFibonacciArcsProperties(SToolProperty &props[])
  {
   //--- Default arc color (ribbon-only)
   AddPropertyDescriptor(props, "lineColor", "Default level color",
                          PROP_COLOR, PROP_GROUP_STYLE,
                          true, false, "Default color for all arcs");
   //--- Level list with 0..10 ratio bounds (arcs are non-negative; 3 decimal places)
   AddLevelListDescriptor(props, "fibarc", "Levels",
                          0.0, 10.0, 0.01, 3);
  }

//+------------------------------------------------------------------+
//| Register property set for a regression channel (center + bands)  |
//+------------------------------------------------------------------+
void RegisterRegressionChannelProperties(SToolProperty &props[])
  {
   //--- Boundary line color + upper/lower fill colors
   AddPropertyDescriptor(props, "lineColor", "Line color",
                          PROP_COLOR, PROP_GROUP_STYLE,
                          true, true, "Boundary line color");
   AddPropertyDescriptor(props, "fillColor", "Upper fill",
                          PROP_COLOR, PROP_GROUP_STYLE,
                          false, true, "Upper band fill (compact row)");
   AddPropertyDescriptor(props, "fillColor2", "Lower fill",
                          PROP_COLOR, PROP_GROUP_STYLE,
                          false, true, "Lower band fill (compact row)");
   //--- Boundary line width (default 2) + style (default solid)
   AddPropertyDescriptor(props, "lineWidth", "Width",
                          PROP_LINE_WIDTH, PROP_GROUP_STYLE,
                          true, true, "Boundary line width");
   props[ArraySize(props) - 1].defaultInt = 2;
   AddPropertyDescriptor(props, "lineStyle", "Style",
                          PROP_LINE_STYLE, PROP_GROUP_STYLE,
                          true, true, "Boundary line style");
   props[ArraySize(props) - 1].defaultInt = 0;
   //--- Line + upper-fill + lower-fill opacity (line opaque, fills 30 percent)
   AddPropertyDescriptor(props, "lineOpacity", "Line opacity",
                          PROP_OPACITY, PROP_GROUP_STYLE,
                          false, true, "");
   props[ArraySize(props) - 1].defaultInt = 100;
   AddPropertyDescriptor(props, "fillOpacity", "Upper fill opacity",
                          PROP_OPACITY, PROP_GROUP_STYLE,
                          false, true, "");
   props[ArraySize(props) - 1].defaultInt = 30;
   AddPropertyDescriptor(props, "fillOpacity2", "Lower fill opacity",
                          PROP_OPACITY, PROP_GROUP_STYLE,
                          false, true, "");
   props[ArraySize(props) - 1].defaultInt = 30;
   //--- Center line compact row (visibility + color + width + style; no value cube)
   AddCompactRowDescriptor(props, "center", "Center line",
                            "centerVisible", "", "centerColor",
                            "centerWidth", "centerStyle",
                            PROP_GROUP_STYLE);
   //--- Upper + lower std-dev band compact rows (visibility + color cube only)
   AddCompactRowDescriptor(props, "upperBand", "Upper +σ band",
                            "upperBandVisible", "", "fillColor",
                            "", "",
                            PROP_GROUP_STYLE);
   AddCompactRowDescriptor(props, "lowerBand", "Lower –σ band",
                            "lowerBandVisible", "", "fillColor2",
                            "", "",
                            PROP_GROUP_STYLE);
   //--- Upper band sigma multiplier (default 2.0, range 0.1..10.0, 0.1 step, 2 decimals)
   AddPropertyDescriptor(props, "upperBandSigma", "Upper deviation",
                          PROP_FLOAT, PROP_GROUP_STYLE,
                          false, true, "Multiplier for upper band (×σ)");
   props[ArraySize(props) - 1].defaultDouble = 2.0;
   props[ArraySize(props) - 1].minValue      = 0.1;
   props[ArraySize(props) - 1].maxValue      = 10.0;
   props[ArraySize(props) - 1].stepValue     = 0.1;
   props[ArraySize(props) - 1].decimals      = 2;
   //--- Lower band sigma multiplier (same bounds as upper)
   AddPropertyDescriptor(props, "lowerBandSigma", "Lower deviation",
                          PROP_FLOAT, PROP_GROUP_STYLE,
                          false, true, "Multiplier for lower band (×σ)");
   props[ArraySize(props) - 1].defaultDouble = 2.0;
   props[ArraySize(props) - 1].minValue      = 0.1;
   props[ArraySize(props) - 1].maxValue      = 10.0;
   props[ArraySize(props) - 1].stepValue     = 0.1;
   props[ArraySize(props) - 1].decimals      = 2;
   //--- Pearson R correlation badge visibility (default true)
   AddPropertyDescriptor(props, "pearsonVisible", "Show Pearson's R",
                          PROP_BOOL, PROP_GROUP_STYLE,
                          false, true, "Show R correlation value on chart");
   props[ArraySize(props) - 1].defaultBool = true;
   //--- Pearson R text color + opacity (Text tab)
   AddPropertyDescriptor(props, "textColor", "Pearson R color",
                          PROP_COLOR, PROP_GROUP_TEXT,
                          true, true, "Pearson R label color");
   AddPropertyDescriptor(props, "textOpacity", "Pearson R opacity",
                          PROP_OPACITY, PROP_GROUP_TEXT,
                          false, true, "");
   props[ArraySize(props) - 1].defaultInt = 100;
  }

//+------------------------------------------------------------------+
//| Register property set for a std-dev channel (center + bands)     |
//+------------------------------------------------------------------+
void RegisterStdDevChannelProperties(SToolProperty &props[])
  {
   //--- Boundary line color + band fill color
   AddPropertyDescriptor(props, "lineColor", "Line color",
                          PROP_COLOR, PROP_GROUP_STYLE,
                          true, true, "Boundary line color");
   AddPropertyDescriptor(props, "fillColor", "Fill color",
                          PROP_COLOR, PROP_GROUP_STYLE,
                          true, true, "Band fill color");
   //--- Boundary line width (default 2) + style (default solid)
   AddPropertyDescriptor(props, "lineWidth", "Width",
                          PROP_LINE_WIDTH, PROP_GROUP_STYLE,
                          true, true, "Boundary line width");
   props[ArraySize(props) - 1].defaultInt = 2;
   AddPropertyDescriptor(props, "lineStyle", "Style",
                          PROP_LINE_STYLE, PROP_GROUP_STYLE,
                          true, true, "Boundary line style");
   props[ArraySize(props) - 1].defaultInt = 0;
   //--- Line + fill opacity (line opaque, fill 30 percent)
   AddPropertyDescriptor(props, "lineOpacity", "Line opacity",
                          PROP_OPACITY, PROP_GROUP_STYLE,
                          false, true, "");
   props[ArraySize(props) - 1].defaultInt = 100;
   AddPropertyDescriptor(props, "fillOpacity", "Fill opacity",
                          PROP_OPACITY, PROP_GROUP_STYLE,
                          false, true, "");
   props[ArraySize(props) - 1].defaultInt = 30;
   //--- Center line compact row
   AddCompactRowDescriptor(props, "center", "Center line",
                            "centerVisible", "", "centerColor",
                            "centerWidth", "centerStyle",
                            PROP_GROUP_STYLE);
   //--- Upper + lower band compact rows (both share fillColor as the bound color cube)
   AddCompactRowDescriptor(props, "upperBand", "Upper +σ band",
                            "upperBandVisible", "", "fillColor",
                            "", "",
                            PROP_GROUP_STYLE);
   AddCompactRowDescriptor(props, "lowerBand", "Lower –σ band",
                            "lowerBandVisible", "", "fillColor",
                            "", "",
                            PROP_GROUP_STYLE);
   //--- Upper band sigma multiplier (default 2.0, range 0.1..10.0)
   AddPropertyDescriptor(props, "upperBandSigma", "Upper deviation",
                          PROP_FLOAT, PROP_GROUP_STYLE,
                          false, true, "Multiplier for upper band (×σ)");
   props[ArraySize(props) - 1].defaultDouble = 2.0;
   props[ArraySize(props) - 1].minValue      = 0.1;
   props[ArraySize(props) - 1].maxValue      = 10.0;
   props[ArraySize(props) - 1].stepValue     = 0.1;
   props[ArraySize(props) - 1].decimals      = 2;
   //--- Lower band sigma multiplier
   AddPropertyDescriptor(props, "lowerBandSigma", "Lower deviation",
                          PROP_FLOAT, PROP_GROUP_STYLE,
                          false, true, "Multiplier for lower band (×σ)");
   props[ArraySize(props) - 1].defaultDouble = 2.0;
   props[ArraySize(props) - 1].minValue      = 0.1;
   props[ArraySize(props) - 1].maxValue      = 10.0;
   props[ArraySize(props) - 1].stepValue     = 0.1;
   props[ArraySize(props) - 1].decimals      = 2;
  }

//+------------------------------------------------------------------+
//| Register Gann Line property set (single line, no levels)         |
//+------------------------------------------------------------------+
void RegisterGannLineProperties(SToolProperty &props[])
  {
   //--- Line color
   AddPropertyDescriptor(props, "lineColor", "Line color",
                          PROP_COLOR, PROP_GROUP_STYLE,
                          true, true, "Line color");
   //--- Width (default 2) + style (default solid)
   AddPropertyDescriptor(props, "lineWidth", "Width",
                          PROP_LINE_WIDTH, PROP_GROUP_STYLE,
                          true, true, "Line width");
   props[ArraySize(props) - 1].defaultInt = 2;
   AddPropertyDescriptor(props, "lineStyle", "Style",
                          PROP_LINE_STYLE, PROP_GROUP_STYLE,
                          true, true, "Line style");
   props[ArraySize(props) - 1].defaultInt = 0;
   //--- Line opacity (default fully opaque)
   AddPropertyDescriptor(props, "lineOpacity", "Line opacity",
                          PROP_OPACITY, PROP_GROUP_STYLE,
                          false, true, "");
   props[ArraySize(props) - 1].defaultInt = 100;
  }

//+------------------------------------------------------------------+
//| Register Gann Fan property set (multi-ray with levels)           |
//+------------------------------------------------------------------+
void RegisterGannFanProperties(SToolProperty &props[])
  {
   //--- Default ray color (ribbon-only, cascades onto per-level colors)
   AddPropertyDescriptor(props, "lineColor", "Default level color",
                          PROP_COLOR, PROP_GROUP_STYLE,
                          true, false, "Default color for all rays");
   //--- Default ray width (ribbon-only, cascades onto per-level widths)
   AddPropertyDescriptor(props, "lineWidth", "Width",
                          PROP_LINE_WIDTH, PROP_GROUP_STYLE,
                          true, false, "Default ray width");
   props[ArraySize(props) - 1].defaultInt = 2;
   //--- Default ray style (ribbon-only, cascades onto per-level styles)
   AddPropertyDescriptor(props, "lineStyle", "Style",
                          PROP_LINE_STYLE, PROP_GROUP_STYLE,
                          true, false, "Default ray style");
   props[ArraySize(props) - 1].defaultInt = 0;
   //--- Line opacity (default fully opaque) + wedge fill opacity (default 30 percent)
   AddPropertyDescriptor(props, "lineOpacity", "Line opacity",
                          PROP_OPACITY, PROP_GROUP_STYLE,
                          false, true, "");
   props[ArraySize(props) - 1].defaultInt = 100;
   AddPropertyDescriptor(props, "fillOpacity", "Wedge fill opacity",
                          PROP_OPACITY, PROP_GROUP_STYLE,
                          false, true, "Translucent wedges between rays");
   props[ArraySize(props) - 1].defaultInt = 30;
   //--- Level list with 0.05..16 ratio bounds (3 decimal places) - covers the Gann ratios
   AddLevelListDescriptor(props, "gannfan", "Levels",
                          0.05, 16.0, 0.01, 3);
  }

//+------------------------------------------------------------------+
//| Register Gann Box property set (grid lines with levels)          |
//+------------------------------------------------------------------+
void RegisterGannBoxProperties(SToolProperty &props[])
  {
   //--- Default grid color (ribbon-only)
   AddPropertyDescriptor(props, "lineColor", "Default level color",
                          PROP_COLOR, PROP_GROUP_STYLE,
                          true, false, "Default color for all grid lines");
   //--- Default grid width + style (both ribbon-only, cascade onto per-level fields)
   AddPropertyDescriptor(props, "lineWidth", "Width",
                          PROP_LINE_WIDTH, PROP_GROUP_STYLE,
                          true, false, "Default grid line width");
   props[ArraySize(props) - 1].defaultInt = 2;
   AddPropertyDescriptor(props, "lineStyle", "Style",
                          PROP_LINE_STYLE, PROP_GROUP_STYLE,
                          true, false, "Default grid line style");
   props[ArraySize(props) - 1].defaultInt = 0;
   //--- Line opacity (default fully opaque) + band fill opacity (default 30 percent)
   AddPropertyDescriptor(props, "lineOpacity", "Line opacity",
                          PROP_OPACITY, PROP_GROUP_STYLE,
                          false, true, "");
   props[ArraySize(props) - 1].defaultInt = 100;
   AddPropertyDescriptor(props, "fillOpacity", "Band fill opacity",
                          PROP_OPACITY, PROP_GROUP_STYLE,
                          false, true, "Horizontal + vertical band fills");
   props[ArraySize(props) - 1].defaultInt = 30;
   //--- Level list with -2..2 ratio bounds (3 decimal places)
   AddLevelListDescriptor(props, "gannbox", "Levels",
                          -2.0, 2.0, 0.01, 3);
  }

//+------------------------------------------------------------------+
//| Register pitchfork property set (Andrews + Schiff + Modified)    |
//+------------------------------------------------------------------+
void RegisterPitchforkProperties(SToolProperty &props[])
  {
   //--- Global line color (cascades onto all 3 part-group colors)
   AddPropertyDescriptor(props, "lineColor", "Line color",
                          PROP_COLOR, PROP_GROUP_STYLE,
                          true, true, "Pitchfork line color (applies to all 3 parts)");
   //--- Default line width + style (both cascade onto per-part-group fields)
   AddPropertyDescriptor(props, "lineWidth", "Width",
                          PROP_LINE_WIDTH, PROP_GROUP_STYLE,
                          true, true, "Default line width");
   props[ArraySize(props) - 1].defaultInt = 2;
   AddPropertyDescriptor(props, "lineStyle", "Style",
                          PROP_LINE_STYLE, PROP_GROUP_STYLE,
                          true, true, "Default line style");
   props[ArraySize(props) - 1].defaultInt = 0;
   //--- Line opacity (default fully opaque)
   AddPropertyDescriptor(props, "lineOpacity", "Line opacity",
                          PROP_OPACITY, PROP_GROUP_STYLE,
                          false, true, "");
   props[ArraySize(props) - 1].defaultInt = 100;
   //--- Band fill opacity (outer + inner band fills, default 30 percent)
   AddPropertyDescriptor(props, "fillOpacity", "Band fill opacity",
                          PROP_OPACITY, PROP_GROUP_STYLE,
                          false, true, "Outer + inner band fill alpha");
   props[ArraySize(props) - 1].defaultInt = 30;
   //--- Median line compact row
   AddCompactRowDescriptor(props, "median", "Median line",
                            "medianVisible", "", "medianColor",
                            "medianWidth", "medianStyle",
                            PROP_GROUP_STYLE);
   //--- Outer parallels compact row
   AddCompactRowDescriptor(props, "outer", "Outer parallels",
                            "outerVisible", "", "outerColor",
                            "outerWidth", "outerStyle",
                            PROP_GROUP_STYLE);
   //--- Inner parallels compact row
   AddCompactRowDescriptor(props, "inner", "Inner parallels",
                            "innerVisible", "", "innerColor",
                            "innerWidth", "innerStyle",
                            PROP_GROUP_STYLE);
  }

//+------------------------------------------------------------------+
//| Populate `props` with the editable descriptors for the tool type |
//+------------------------------------------------------------------+
void BuildPropertyListForTool(TOOL_TYPE toolType, SToolProperty &props[])
  {
   //--- Start with an empty descriptor list
   ArrayResize(props, 0);

   //--- Dispatch to the matching Register* helper based on tool type
   switch(toolType)
     {
      //--- Trendline + horizontal/vertical lines + ray + extended + info + trend-angle all use the full labeled-line set
      case TOOL_TRENDLINE:
      case TOOL_HLINE:
      case TOOL_VLINE:
      case TOOL_RAY:
      case TOOL_EXTENDED_LINE:
      case TOOL_INFO_LINE:
      case TOOL_TREND_ANGLE:
         RegisterLineToolWithLabelProperties(props);
         break;

      //--- Cross line uses the unlabeled base set (no per-tool text)
      case TOOL_CROSS_LINE:
         RegisterLineToolBaseProperties(props);
         break;

      //--- Path (open polyline) uses the unlabeled base set
      case TOOL_PATH:
         RegisterLineToolBaseProperties(props);
         break;

      //--- Text annotation
      case TOOL_TEXT:
         RegisterTextAnnotationProperties(props);
         break;

      //--- Arrow annotation
      case TOOL_ARROW:
         RegisterArrowAnnotationProperties(props);
         break;

      //--- Simple markers (arrow marker, up/down arrows) share the minimal marker set
      case TOOL_ARROW_MARKER:
      case TOOL_ARROW_UP:
      case TOOL_ARROW_DOWN:
         RegisterSimpleMarkerProperties(props);
         break;

      //--- Note annotation (connector + box + text)
      case TOOL_NOTE:
         RegisterNoteAnnotationProperties(props);
         break;

      //--- Price-note annotation (no body text, just price tag)
      case TOOL_PRICE_NOTE:
         RegisterPriceNoteAnnotationProperties(props);
         break;

      //--- Callout annotation (border + leader shaft + body fill + text)
      case TOOL_CALLOUT:
         RegisterCalloutAnnotationProperties(props);
         break;

      //--- Comment annotation (speech-bubble shape)
      case TOOL_COMMENT:
         RegisterCommentAnnotationProperties(props);
         break;

      //--- Channels: parallel + regression + std-dev each have their own helper
      case TOOL_PARALLEL_CHANNEL:
         RegisterParallelChannelProperties(props);
         break;
      case TOOL_REGRESSION_CHANNEL:
         RegisterRegressionChannelProperties(props);
         break;
      case TOOL_STDDEV_CHANNEL:
         RegisterStdDevChannelProperties(props);
         break;

      //--- Pitchforks (Andrews + Schiff + Modified Schiff) all share one helper
      case TOOL_PITCHFORK:
      case TOOL_SCHIFF_PITCHFORK:
      case TOOL_MOD_SCHIFF:
         RegisterPitchforkProperties(props);
         break;

      //--- Gann line (single line, no levels)
      case TOOL_GANN_LINE:
         RegisterGannLineProperties(props);
         break;

      //--- Gann fan (multi-ray with level list)
      case TOOL_GANN_FAN:
         RegisterGannFanProperties(props);
         break;

      //--- Gann box (grid lines with level list)
      case TOOL_GANN_BOX:
         RegisterGannBoxProperties(props);
         break;

      //--- Fibonacci retracement uses its bespoke helper (inline level list registration)
      case TOOL_FIBO_RETRACEMENT:
         RegisterFibonacciRetracementProperties(props);
         break;

      //--- Fibonacci expansion / channel / time-zones / fan / arcs each go through AddLevelListDescriptor
      case TOOL_FIBO_EXPANSION:
         RegisterFibonacciExpansionProperties(props);
         break;

      case TOOL_FIBO_CHANNEL:
         RegisterFibonacciChannelProperties(props);
         break;

      case TOOL_FIBO_TIMEZONES:
         RegisterFibonacciTimezonesProperties(props);
         break;

      case TOOL_FIBO_FAN:
         RegisterFibonacciFanProperties(props);
         break;

      case TOOL_FIBO_ARCS:
         RegisterFibonacciArcsProperties(props);
         break;

      //--- Rectangle + triangle + rotated rectangle support dashed strokes
      case TOOL_RECTANGLE:
      case TOOL_TRIANGLE:
      case TOOL_ROTATED_RECTANGLE:
         RegisterClosedShapeProperties(props, true);
         break;

      //--- Ellipse + circle + arc don't support dashed strokes (curved edges need parametric dashing)
      case TOOL_ELLIPSE:
      case TOOL_CIRCLE:
      case TOOL_ARC:
         RegisterClosedShapeProperties(props, false);
         break;

      //--- Curve shape (open curve, no fill or text)
      case TOOL_CURVE:
         RegisterCurveShapeProperties(props);
         break;

      //--- Any unhandled tool type yields an empty descriptor list (no ribbon, no settings)
      default:
         break;
     }

   //--- Universal action icons (Settings + Remove) appended only when there are ribbon-visible properties
   bool hasRibbonProps = false;
   const int existing = ArraySize(props);
   for(int i = 0; i < existing; i++)
     {
      if(props[i].showInRibbon) { hasRibbonProps = true; break; }
     }
   //--- Append the Settings + Remove action descriptors when ribbon-eligible properties were registered
   if(hasRibbonProps)
     {
      AddPropertyDescriptor(props, "settings", "",
                             PROP_ACTION, PROP_GROUP_STYLE,
                             true, false, "Settings");
      AddPropertyDescriptor(props, "remove", "",
                             PROP_ACTION, PROP_GROUP_STYLE,
                             true, false, "Remove");
     }
  }

#endif // TOOLS_PALETTE_PROPERTIES_MQH
//+------------------------------------------------------------------+