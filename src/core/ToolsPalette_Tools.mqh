//+------------------------------------------------------------------+
//|                                           ToolsPalette_Tools.mqh |
//|                                            Copyright 2026, Om J. |
//|                                               https://t.me/HZFXI |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Om J."
#property link "https://t.me/HZFXI"
#property version "1.00"
#property strict

//--- Guard against multiple inclusion of this header
#ifndef TOOLS_PALETTE_TOOLS_MQH
#define TOOLS_PALETTE_TOOLS_MQH

//--- Pull in CAnnotationTools (the parent in the tool-rendering chain)
#include "../tools/ToolsPalette_Annotations.mqh"

//+------------------------------------------------------------------+
//| Icon definition: font name + character-code pair                 |
//+------------------------------------------------------------------+
struct SIconDefinition { string fontName; uchar charCode; };

//--- Category icons - one per ENUM_CATEGORY entry
SIconDefinition ICON_CATEGORY_CURSORS     = { "Wingdings",   (uchar)'v' };
SIconDefinition ICON_CATEGORY_LINES       = { "Wingdings 3", (uchar)'&' };
SIconDefinition ICON_CATEGORY_CHANNELS    = { "Wingdings 3", (uchar)'2' };
SIconDefinition ICON_CATEGORY_PITCHFORK   = { "Wingdings 3", (uchar)'H' };
SIconDefinition ICON_CATEGORY_GANN        = { "Wingdings",   (uchar)'T' };
SIconDefinition ICON_CATEGORY_FIBONACCI   = { "Wingdings",   (uchar)'z' };
SIconDefinition ICON_CATEGORY_SHAPES      = { "Wingdings",   (uchar)'o' };
SIconDefinition ICON_CATEGORY_ANNOTATIONS = { "Webdings",    (uchar)'>' };
SIconDefinition ICON_CATEGORY_DELETE      = { "Wingdings",   (uchar)0xFF };

//--- Tool icons - one per TOOL_TYPE entry (defensive fallback when no canvas icon exists)
SIconDefinition ICON_TOOL_POINTER         = { "Wingdings 3", (uchar)'-'  };
SIconDefinition ICON_TOOL_CROSSHAIR       = { "Wingdings",   (uchar)'W'  };
SIconDefinition ICON_TOOL_TRENDLINE       = { "Wingdings 3", (uchar)'&'  };
SIconDefinition ICON_TOOL_HLINE           = { "Wingdings 3", (uchar)'"'  };
SIconDefinition ICON_TOOL_VLINE           = { "Wingdings 3", (uchar)'#'  };
SIconDefinition ICON_TOOL_RAY             = { "Wingdings 3", (uchar)'&'  };
SIconDefinition ICON_TOOL_EXTENDED_LINE   = { "Wingdings 3", (uchar)'1'  };
SIconDefinition ICON_TOOL_INFO_LINE       = { "Wingdings 3", (uchar)'2'  };
SIconDefinition ICON_TOOL_TREND_ANGLE     = { "Wingdings 3", (uchar)'S'  };
SIconDefinition ICON_TOOL_CROSS_LINE      = { "Wingdings 3", (uchar)'t'  };
SIconDefinition ICON_TOOL_PARALLEL_CH     = { "Wingdings 3", (uchar)'H'  };
SIconDefinition ICON_TOOL_REGRESSION_CH   = { "Wingdings 3", (uchar)'I'  };
SIconDefinition ICON_TOOL_STDDEV_CH       = { "Wingdings 3", (uchar)'J'  };
SIconDefinition ICON_TOOL_PITCHFORK       = { "Wingdings 3", (uchar)'H'  };
SIconDefinition ICON_TOOL_SCHIFF          = { "Wingdings 3", (uchar)'I'  };
SIconDefinition ICON_TOOL_MOD_SCHIFF      = { "Wingdings 3", (uchar)'K'  };
SIconDefinition ICON_TOOL_GANN_LINE       = { "Wingdings 3", (uchar)'&'  };
SIconDefinition ICON_TOOL_GANN_FAN        = { "Wingdings 3", (uchar)'0'  };
SIconDefinition ICON_TOOL_GANN_BOX        = { "Wingdings",   (uchar)'i'  };
SIconDefinition ICON_TOOL_FIBO_RET        = { "Wingdings",   (uchar)'['  };
SIconDefinition ICON_TOOL_FIBO_EXP        = { "Wingdings 3", (uchar)'&'  };
SIconDefinition ICON_TOOL_FIBO_CH         = { "Wingdings 3", (uchar)'H'  };
SIconDefinition ICON_TOOL_FIBO_TZ         = { "Wingdings 3", (uchar)'#'  };
SIconDefinition ICON_TOOL_FIBO_FAN        = { "Wingdings 3", (uchar)'J'  };
SIconDefinition ICON_TOOL_FIBO_ARCS       = { "Wingdings",   (uchar)'l'  };
SIconDefinition ICON_TOOL_RECTANGLE       = { "Wingdings",   (uchar)'o'  };
SIconDefinition ICON_TOOL_ROTATED_RECT    = { "Wingdings",   (uchar)'o'  };
SIconDefinition ICON_TOOL_TRIANGLE        = { "Wingdings 3", (uchar)'p'  };
SIconDefinition ICON_TOOL_ELLIPSE         = { "Wingdings",   (uchar)'l'  };
SIconDefinition ICON_TOOL_CIRCLE          = { "Wingdings",   (uchar)'o'  };
SIconDefinition ICON_TOOL_ARC             = { "Wingdings",   (uchar)'o'  };
SIconDefinition ICON_TOOL_CURVE           = { "Wingdings",   (uchar)'o'  };
SIconDefinition ICON_TOOL_PATH            = { "Wingdings",   (uchar)'o'  };
SIconDefinition ICON_TOOL_TEXT            = { "Webdings",    (uchar)'>'  };
SIconDefinition ICON_TOOL_ARROW           = { "Wingdings",   (uchar)'o'  };
SIconDefinition ICON_TOOL_ARROW_MARKER    = { "Wingdings",   (uchar)'o'  };
SIconDefinition ICON_TOOL_ARROW_UP        = { "Wingdings",   (uchar)225  };
SIconDefinition ICON_TOOL_ARROW_DOWN      = { "Wingdings",   (uchar)226  };
SIconDefinition ICON_TOOL_NOTE            = { "Wingdings",   (uchar)'o'  };
SIconDefinition ICON_TOOL_PRICE_NOTE      = { "Wingdings",   (uchar)'o'  };
SIconDefinition ICON_TOOL_CALLOUT         = { "Wingdings",   (uchar)'o'  };
SIconDefinition ICON_TOOL_COMMENT         = { "Wingdings",   (uchar)'o'  };

//+------------------------------------------------------------------+
//| Drawing-tool type enum - one entry per supported tool            |
//+------------------------------------------------------------------+
enum TOOL_TYPE
  {
   TOOL_NONE = 0,
   TOOL_POINTER,
   TOOL_CROSSHAIR,
   TOOL_TRENDLINE,
   TOOL_HLINE,
   TOOL_VLINE,
   TOOL_RAY,
   TOOL_EXTENDED_LINE,
   TOOL_INFO_LINE,
   TOOL_TREND_ANGLE,
   TOOL_CROSS_LINE,
   TOOL_PARALLEL_CHANNEL,
   TOOL_REGRESSION_CHANNEL,
   TOOL_STDDEV_CHANNEL,
   TOOL_PITCHFORK,
   TOOL_SCHIFF_PITCHFORK,
   TOOL_MOD_SCHIFF,
   TOOL_GANN_LINE,
   TOOL_GANN_FAN,
   TOOL_GANN_BOX,
   TOOL_FIBO_RETRACEMENT,
   TOOL_FIBO_EXPANSION,
   TOOL_FIBO_CHANNEL,
   TOOL_FIBO_TIMEZONES,
   TOOL_FIBO_FAN,
   TOOL_FIBO_ARCS,
   TOOL_RECTANGLE,
   TOOL_TRIANGLE,
   TOOL_ELLIPSE,
   TOOL_TEXT,
   TOOL_ARROW_UP,
   TOOL_ARROW_DOWN,
   TOOL_THUMB_UP,
   TOOL_THUMB_DOWN,
   TOOL_PRICE_LABEL,
   TOOL_STOP_SIGN,
   TOOL_CHECK_MARK,
   TOOL_ROTATED_RECTANGLE, // appended last to keep other enum values stable
   TOOL_PATH,              // appended last - N-point polyline tool
   TOOL_CIRCLE,            // appended last - 2-click circle (center + border point)
   TOOL_ARC,               // appended last - 3-click arc (chord P1-P2 + bulge point P3)
   TOOL_CURVE,             // appended last - 3-click quadratic Bezier curve (no fill)
   TOOL_ARROW,             // appended last - 2-click annotation arrow (line + filled triangle head)
   TOOL_ARROW_MARKER,      // single-click arrow marker placed on the chart
   TOOL_NOTE,              // single-click note icon
   TOOL_PRICE_NOTE,        // single-click price-line note
   TOOL_CALLOUT,           // single-click callout marker
   TOOL_COMMENT            // single-click comment marker
  };

//+------------------------------------------------------------------+
//| Category enum - groups tools into sidebar tiles                  |
//+------------------------------------------------------------------+
enum ENUM_CATEGORY
  {
   CAT_NONE        = -1,
   CAT_CURSORS     =  0,
   CAT_LINES,
   CAT_CHANNELS,
   CAT_PITCHFORK,
   CAT_GANN,
   CAT_FIBONACCI,
   CAT_SHAPES,
   CAT_ANNOTATIONS,
   CAT_DELETE,
   CAT_COUNT
  };

//+------------------------------------------------------------------+
//| ToolDefinition: per-tool metadata stored in CategoryDefinition   |
//+------------------------------------------------------------------+
struct ToolDefinition
  {
   TOOL_TYPE toolType;        // Tool enum value
   string    toolLabel;       // Display label shown in the flyout row
   string    iconFontName;    // Fallback Wingdings font name
   uchar     iconCharCode;    // Fallback Wingdings glyph
   string    tooltipText;     // Tooltip shown on sidebar hover
  };

//+------------------------------------------------------------------+
//| CategoryDefinition: per-category metadata + owned tool list      |
//+------------------------------------------------------------------+
struct CategoryDefinition
  {
   string         categoryLabel;   // Display label shown in the flyout title
   string         iconFontName;    // Fallback Wingdings font for the sidebar tile
   uchar          iconCharCode;    // Fallback Wingdings glyph
   ToolDefinition tools[];         // Tools registered in this category
  };

//+------------------------------------------------------------------+
//| CToolRegistry owns category + tool definitions and last-used map |
//+------------------------------------------------------------------+
class CToolRegistry : public CAnnotationTools
  {
protected:
   //--- Category catalog indexed by ENUM_CATEGORY (the full set of registered categories)
   CategoryDefinition m_categories[CAT_COUNT];
   //--- Per-category memory of the last tool the user selected (drives sidebar tile icon)
   TOOL_TYPE     m_lastUsedToolPerCategory[CAT_COUNT];

protected:
   //--- Append a single tool entry to a category's tool array
   void          AddTool(ToolDefinition &arr[], TOOL_TYPE type, string label, string font, uchar code, string tooltip);
   //--- Seed last-used slots to the FIRST tool of each category
   void          InitLastUsedTools();
   //--- Test whether an ENUM_CATEGORY entry is an "action" category (CAT_DELETE today)
   bool          IsActionCategory(ENUM_CATEGORY cat);
   //--- Resolve the category that owns the given tool type (linear scan over m_categories)
   ENUM_CATEGORY GetCategoryForActiveTool(TOOL_TYPE activeTool);
   //--- Record a tool selection so that future renders of its category tile show that tool's icon
   void          RecordToolSelection(TOOL_TYPE toolType);
   //--- Resolve which TOOL the sidebar tile should display for this category
   TOOL_TYPE     GetCategoryDisplayToolType(ENUM_CATEGORY cat);
   //--- Return the number of chart clicks required to place the given tool (-1 = variable-N like Path)
   int           GetRequiredClickCount(TOOL_TYPE toolType);
   //--- Return the display label string for the given tool type
   string        GetToolLabel(TOOL_TYPE toolType);
   //--- Render the canvas icon for an action category (currently only CAT_DELETE = trash bin)
   bool          DrawActionCategoryIconOnCanvas(CCanvas &canvas, ENUM_CATEGORY cat,
                                                  int cx, int cy, int size,
                                                  color iconColor);
   //--- Populate all categories and their tool lists (calls AddTool for every registered tool)
   void          InitAllCategoriesAndTools();
  };

//+------------------------------------------------------------------+
//| Append a single tool entry to a category's tool array            |
//+------------------------------------------------------------------+
void CToolRegistry::AddTool(ToolDefinition &arr[], TOOL_TYPE type, string label, string font, uchar code, string tooltip)
  {
   //--- Grow the array by one and populate the new entry
   int sz = ArraySize(arr);
   ArrayResize(arr, sz + 1);
   arr[sz].toolType     = type;
   arr[sz].toolLabel    = label;
   arr[sz].iconFontName = font;
   arr[sz].iconCharCode = code;
   arr[sz].tooltipText  = tooltip;
  }

//+------------------------------------------------------------------+
//| Test whether a category is an "action" category (no tool list)   |
//+------------------------------------------------------------------+
bool CToolRegistry::IsActionCategory(ENUM_CATEGORY cat)
  {
   //--- Currently only CAT_DELETE qualifies - action categories have NO tools and invoke a one-shot action
   return (cat == CAT_DELETE);
  }

//+------------------------------------------------------------------+
//| Resolve the category that owns the given tool type               |
//+------------------------------------------------------------------+
ENUM_CATEGORY CToolRegistry::GetCategoryForActiveTool(TOOL_TYPE activeTool)
  {
   //--- TOOL_NONE and TOOL_POINTER don't belong to any visible category
   if(activeTool == TOOL_NONE || activeTool == TOOL_POINTER) return CAT_NONE;
   //--- Linear scan through every category's tool list looking for a match
   for(int c = 0; c < CAT_COUNT; c++)
      for(int t = 0; t < ArraySize(m_categories[c].tools); t++)
         if(m_categories[c].tools[t].toolType == activeTool) return (ENUM_CATEGORY)c;
   return CAT_NONE;
  }

//+------------------------------------------------------------------+
//| Seed last-used slots to the FIRST tool of each category          |
//+------------------------------------------------------------------+
void CToolRegistry::InitLastUsedTools()
  {
   //--- Walk every category and seed its last-used slot
   for(int c = 0; c < CAT_COUNT; c++)
     {
      //--- Categories with tools => first tool; empty (action) categories => TOOL_NONE
      if(ArraySize(m_categories[c].tools) > 0)
         m_lastUsedToolPerCategory[c] = m_categories[c].tools[0].toolType;
      else
         m_lastUsedToolPerCategory[c] = TOOL_NONE;
     }
  }

//+------------------------------------------------------------------+
//| Record a tool selection in the per-category last-used map        |
//+------------------------------------------------------------------+
void CToolRegistry::RecordToolSelection(TOOL_TYPE toolType)
  {
   //--- No-op for TOOL_NONE (would clobber category memory with a meaningless value)
   if(toolType == TOOL_NONE) return;
   //--- Resolve which category owns this tool; no-op for tools outside any category
   ENUM_CATEGORY cat = GetCategoryForActiveTool(toolType);
   if(cat == CAT_NONE) return;
   //--- Stash the tool as the category's new last-used selection
   m_lastUsedToolPerCategory[(int)cat] = toolType;
  }

//+------------------------------------------------------------------+
//| Resolve which TOOL the sidebar tile should display for this cat  |
//+------------------------------------------------------------------+
TOOL_TYPE CToolRegistry::GetCategoryDisplayToolType(ENUM_CATEGORY cat)
  {
   //--- Defensive bounds check - invalid categories return TOOL_NONE (caller falls back to Wingdings glyph)
   if(cat == CAT_NONE || (int)cat < 0 || (int)cat >= CAT_COUNT)
      return TOOL_NONE;
   //--- Read the stored last-used tool for this category
   TOOL_TYPE t = m_lastUsedToolPerCategory[(int)cat];
   //--- Defensive fallback: if the slot is uninitialized somehow, use the category's first tool
   if(t == TOOL_NONE && ArraySize(m_categories[(int)cat].tools) > 0)
      t = m_categories[(int)cat].tools[0].toolType;
   return t;
  }

//+------------------------------------------------------------------+
//| Number of chart clicks needed to place the given tool            |
//+------------------------------------------------------------------+
int CToolRegistry::GetRequiredClickCount(TOOL_TYPE toolType)
  {
   //--- Switch dispatches by tool type into click-count buckets (0, 1, 2, 3, or -1 = variable-N)
   switch(toolType)
     {
      //--- 0-click tools (cursors don't place anything)
      case TOOL_POINTER: case TOOL_CROSSHAIR:
         return 0;
      //--- 1-click tools (horizontal/vertical/cross line, text, single-shot annotations)
      case TOOL_HLINE: case TOOL_VLINE: case TOOL_CROSS_LINE: case TOOL_TEXT: case TOOL_ARROW_UP: case TOOL_ARROW_DOWN:
      case TOOL_THUMB_UP: case TOOL_THUMB_DOWN: case TOOL_PRICE_LABEL: case TOOL_STOP_SIGN:
      case TOOL_CHECK_MARK:
      case TOOL_COMMENT:
         return 1;
      //--- 2-click tools (trendlines, rays, rectangles, single-bar Fibos, circles, basic arrows)
      case TOOL_TRENDLINE: case TOOL_RAY: case TOOL_EXTENDED_LINE: case TOOL_INFO_LINE:
      case TOOL_TREND_ANGLE:
      case TOOL_RECTANGLE: case TOOL_FIBO_RETRACEMENT:
      case TOOL_FIBO_TIMEZONES:
      case TOOL_FIBO_FAN: case TOOL_FIBO_ARCS: case TOOL_GANN_LINE:
      case TOOL_GANN_FAN: case TOOL_GANN_BOX: case TOOL_REGRESSION_CHANNEL: case TOOL_STDDEV_CHANNEL:
      case TOOL_CIRCLE:
      case TOOL_ARROW:
      case TOOL_ARROW_MARKER:
      case TOOL_NOTE:
      case TOOL_PRICE_NOTE:
      case TOOL_CALLOUT:
         return 2;
      //--- 3-click tools (channels, pitchfork variants, triangles, ellipse, rotated rect, arc, curve)
      case TOOL_PARALLEL_CHANNEL: case TOOL_FIBO_CHANNEL: case TOOL_FIBO_EXPANSION:
      case TOOL_PITCHFORK: case TOOL_SCHIFF_PITCHFORK: case TOOL_MOD_SCHIFF:
      case TOOL_TRIANGLE:
      case TOOL_ELLIPSE:
      case TOOL_ROTATED_RECTANGLE:
      case TOOL_ARC:
      case TOOL_CURVE:
         return 3;
      //--- Path tool: variable-N (any number of points, terminated by double-click)
      case TOOL_PATH:
         return -1;
      //--- Default fallback: treat unknown tools as 1-click placements
      default: return 1;
     }
  }

//+------------------------------------------------------------------+
//| Resolve the display label string for the given tool type         |
//+------------------------------------------------------------------+
string CToolRegistry::GetToolLabel(TOOL_TYPE toolType)
  {
   //--- Linear scan through every category's tool list looking for a match
   for(int c = 0; c < CAT_COUNT; c++)
      for(int t = 0; t < ArraySize(m_categories[c].tools); t++)
         if(m_categories[c].tools[t].toolType == toolType) return m_categories[c].tools[t].toolLabel;
   //--- Unknown tool => sentinel "None" label
   return "None";
  }

//+------------------------------------------------------------------+
//| Render the action-category canvas icon (currently CAT_DELETE)    |
//+------------------------------------------------------------------+
bool CToolRegistry::DrawActionCategoryIconOnCanvas(CCanvas &canvas,
                                                     ENUM_CATEGORY cat,
                                                     int cx, int cy, int size,
                                                     color iconColor)
  {
   //--- Currently only CAT_DELETE has a canvas icon; everything else falls back to Wingdings
   if(cat != CAT_DELETE) return false;
   //--- Compose ARGB and compute the icon's pixel-aligned bounding box (with 3 px inset)
   uint argb = ColorToARGB(iconColor, 255);
   int  half = size / 2;
   int  inset = 3;
   //--- Bounding box of the icon glyph (centered at cx,cy with the 3 px inset)
   int  L = cx - half + inset;
   int  R = cx + half - inset;
   int  T = cy - half + inset;
   int  B = cy + half - inset;
   int  W = R - L;
   int  H = B - T;
   //--- Lid + handle geometry (22% down from the top for the lid; 5% down for the handle)
   int lidY      = T + (int)MathRound(H * 0.22);
   int handleHalfW = (int)MathRound(W * 0.15);
   int handleTop = T + (int)MathRound(H * 0.05);
   //--- Body rectangle inset 10% from each side, starting 2 px below the lid
   int bodyL     = L + (int)MathRound(W * 0.10);
   int bodyR     = R - (int)MathRound(W * 0.10);
   int bodyT     = lidY + 2;
   int bodyB     = B;
   //--- Handle tab X-bounds (centered on cx)
   int tabL = cx - handleHalfW;
   int tabR = cx + handleHalfW;
   //--- Handle top + side strokes (2-px doubled lines for visual weight)
   canvas.Line(tabL, handleTop,     tabR, handleTop,     argb);
   canvas.Line(tabL, handleTop + 1, tabR, handleTop + 1, argb);
   canvas.Line(tabL, handleTop, tabL, lidY, argb);
   canvas.Line(tabR, handleTop, tabR, lidY, argb);
   //--- Lid strokes (full-width horizontal lines, 2 px thick)
   canvas.Line(L, lidY,     R, lidY,     argb);
   canvas.Line(L, lidY + 1, R, lidY + 1, argb);
   //--- Body side strokes (2 px doubled lines for visual weight)
   canvas.Line(bodyL,     bodyT, bodyL,     bodyB, argb);
   canvas.Line(bodyL + 1, bodyT, bodyL + 1, bodyB, argb);
   canvas.Line(bodyR,     bodyT, bodyR,     bodyB, argb);
   canvas.Line(bodyR - 1, bodyT, bodyR - 1, bodyB, argb);
   //--- Body bottom strokes (2 px doubled lines)
   canvas.Line(bodyL, bodyB,     bodyR, bodyB,     argb);
   canvas.Line(bodyL, bodyB - 1, bodyR, bodyB - 1, argb);
   //--- 3 internal "content" lines suggesting trash being deleted
   int contentT = bodyT + (int)MathRound(H * 0.10);
   int contentB = bodyB - (int)MathRound(H * 0.10);
   int bodyW    = bodyR - bodyL;
   //--- Evenly spaced X positions for the 3 content lines (at 25/50/75% of body width)
   int c1x = bodyL + bodyW / 4;
   int c2x = bodyL + bodyW / 2;
   int c3x = bodyL + (bodyW * 3) / 4;
   canvas.Line(c1x, contentT, c1x, contentB, argb);
   canvas.Line(c2x, contentT, c2x, contentB, argb);
   canvas.Line(c3x, contentT, c3x, contentB, argb);
   return true;
  }

//+------------------------------------------------------------------+
//| Populate all categories and their associated tool lists          |
//+------------------------------------------------------------------+
void CToolRegistry::InitAllCategoriesAndTools()
  {
   //--- Cursors category: 2 tools (Pointer, Crosshair)
   m_categories[CAT_CURSORS].categoryLabel = "Cursors";
   m_categories[CAT_CURSORS].iconFontName  = ICON_CATEGORY_CURSORS.fontName;
   m_categories[CAT_CURSORS].iconCharCode  = ICON_CATEGORY_CURSORS.charCode;
   ArrayResize(m_categories[CAT_CURSORS].tools, 0);
   AddTool(m_categories[CAT_CURSORS].tools, TOOL_POINTER,   "Pointer",   ICON_TOOL_POINTER.fontName,   ICON_TOOL_POINTER.charCode,   "Default Pointer");
   AddTool(m_categories[CAT_CURSORS].tools, TOOL_CROSSHAIR, "Crosshair", ICON_TOOL_CROSSHAIR.fontName, ICON_TOOL_CROSSHAIR.charCode, "Crosshair / Measure");

   //--- Lines category: 8 line-based tools (Trendline, H/V/Ray/Extended/Info/Angle/Cross)
   m_categories[CAT_LINES].categoryLabel = "Lines";
   m_categories[CAT_LINES].iconFontName  = ICON_CATEGORY_LINES.fontName;
   m_categories[CAT_LINES].iconCharCode  = ICON_CATEGORY_LINES.charCode;
   ArrayResize(m_categories[CAT_LINES].tools, 0);
   AddTool(m_categories[CAT_LINES].tools, TOOL_TRENDLINE,     "Trendline",       ICON_TOOL_TRENDLINE.fontName,     ICON_TOOL_TRENDLINE.charCode,     "Trendline");
   AddTool(m_categories[CAT_LINES].tools, TOOL_HLINE,         "Horizontal line", ICON_TOOL_HLINE.fontName,         ICON_TOOL_HLINE.charCode,         "Horizontal line");
   AddTool(m_categories[CAT_LINES].tools, TOOL_VLINE,         "Vertical line",   ICON_TOOL_VLINE.fontName,         ICON_TOOL_VLINE.charCode,         "Vertical line");
   AddTool(m_categories[CAT_LINES].tools, TOOL_RAY,           "Ray",             ICON_TOOL_RAY.fontName,           ICON_TOOL_RAY.charCode,           "Ray");
   AddTool(m_categories[CAT_LINES].tools, TOOL_EXTENDED_LINE, "Extended line",   ICON_TOOL_EXTENDED_LINE.fontName, ICON_TOOL_EXTENDED_LINE.charCode, "Extended line");
   AddTool(m_categories[CAT_LINES].tools, TOOL_INFO_LINE,     "Info line",       ICON_TOOL_INFO_LINE.fontName,     ICON_TOOL_INFO_LINE.charCode,     "Info line");
   AddTool(m_categories[CAT_LINES].tools, TOOL_TREND_ANGLE,   "Angle line",      ICON_TOOL_TREND_ANGLE.fontName,   ICON_TOOL_TREND_ANGLE.charCode,   "Angle line");
   AddTool(m_categories[CAT_LINES].tools, TOOL_CROSS_LINE,    "Cross line",      ICON_TOOL_CROSS_LINE.fontName,    ICON_TOOL_CROSS_LINE.charCode,    "Cross line");

   //--- Channels category: 3 channel-based tools (Parallel, Regression, StdDev)
   m_categories[CAT_CHANNELS].categoryLabel = "Channels";
   m_categories[CAT_CHANNELS].iconFontName  = ICON_CATEGORY_CHANNELS.fontName;
   m_categories[CAT_CHANNELS].iconCharCode  = ICON_CATEGORY_CHANNELS.charCode;
   ArrayResize(m_categories[CAT_CHANNELS].tools, 0);
   AddTool(m_categories[CAT_CHANNELS].tools, TOOL_PARALLEL_CHANNEL,   "Parallel channel", ICON_TOOL_PARALLEL_CH.fontName,   ICON_TOOL_PARALLEL_CH.charCode,   "Parallel Channel");
   AddTool(m_categories[CAT_CHANNELS].tools, TOOL_REGRESSION_CHANNEL, "Regression trend", ICON_TOOL_REGRESSION_CH.fontName, ICON_TOOL_REGRESSION_CH.charCode, "Regression Channel");
   AddTool(m_categories[CAT_CHANNELS].tools, TOOL_STDDEV_CHANNEL,     "StdDev trend",     ICON_TOOL_STDDEV_CH.fontName,     ICON_TOOL_STDDEV_CH.charCode,     "Standard Deviation Channel");

   //--- Pitchfork category: 3 pitchfork variants (Andrews, Schiff, Modified Schiff)
   m_categories[CAT_PITCHFORK].categoryLabel = "Pitchfork";
   m_categories[CAT_PITCHFORK].iconFontName  = ICON_CATEGORY_PITCHFORK.fontName;
   m_categories[CAT_PITCHFORK].iconCharCode  = ICON_CATEGORY_PITCHFORK.charCode;
   ArrayResize(m_categories[CAT_PITCHFORK].tools, 0);
   AddTool(m_categories[CAT_PITCHFORK].tools, TOOL_PITCHFORK,        "Andrew pitchfork",          ICON_TOOL_PITCHFORK.fontName,  ICON_TOOL_PITCHFORK.charCode,  "Andrews Pitchfork");
   AddTool(m_categories[CAT_PITCHFORK].tools, TOOL_SCHIFF_PITCHFORK, "Schiff pitchfork",          ICON_TOOL_SCHIFF.fontName,     ICON_TOOL_SCHIFF.charCode,     "Schiff Pitchfork");
   AddTool(m_categories[CAT_PITCHFORK].tools, TOOL_MOD_SCHIFF,       "Modified Schiff pitchfork", ICON_TOOL_MOD_SCHIFF.fontName, ICON_TOOL_MOD_SCHIFF.charCode, "Modified Schiff Pitchfork");

   //--- Gann category: 3 Gann-based tools (Line, Fan, Box)
   m_categories[CAT_GANN].categoryLabel = "Gann";
   m_categories[CAT_GANN].iconFontName  = ICON_CATEGORY_GANN.fontName;
   m_categories[CAT_GANN].iconCharCode  = ICON_CATEGORY_GANN.charCode;
   ArrayResize(m_categories[CAT_GANN].tools, 0);
   AddTool(m_categories[CAT_GANN].tools, TOOL_GANN_LINE, "Gann line", ICON_TOOL_GANN_LINE.fontName, ICON_TOOL_GANN_LINE.charCode, "Gann Line");
   AddTool(m_categories[CAT_GANN].tools, TOOL_GANN_FAN,  "Gann fan",  ICON_TOOL_GANN_FAN.fontName,  ICON_TOOL_GANN_FAN.charCode,  "Gann Fan");
   AddTool(m_categories[CAT_GANN].tools, TOOL_GANN_BOX, "Gann box", ICON_TOOL_GANN_BOX.fontName, ICON_TOOL_GANN_BOX.charCode, "Gann Box");

   //--- Fibonacci category: 6 Fibo tools (Retracement, Expansion, Channel, Timezones, Fan, Arcs)
   m_categories[CAT_FIBONACCI].categoryLabel = "Fibonacci";
   m_categories[CAT_FIBONACCI].iconFontName  = ICON_CATEGORY_FIBONACCI.fontName;
   m_categories[CAT_FIBONACCI].iconCharCode  = ICON_CATEGORY_FIBONACCI.charCode;
   ArrayResize(m_categories[CAT_FIBONACCI].tools, 0);
   AddTool(m_categories[CAT_FIBONACCI].tools, TOOL_FIBO_RETRACEMENT, "Fib retracement",            ICON_TOOL_FIBO_RET.fontName,  ICON_TOOL_FIBO_RET.charCode,  "Fibonacci Retracement");
   AddTool(m_categories[CAT_FIBONACCI].tools, TOOL_FIBO_EXPANSION,   "Fib expansion",              ICON_TOOL_FIBO_EXP.fontName,  ICON_TOOL_FIBO_EXP.charCode,  "Fibonacci Expansion");
   AddTool(m_categories[CAT_FIBONACCI].tools, TOOL_FIBO_CHANNEL,     "Fib channel",                ICON_TOOL_FIBO_CH.fontName,   ICON_TOOL_FIBO_CH.charCode,   "Fibonacci Channel");
   AddTool(m_categories[CAT_FIBONACCI].tools, TOOL_FIBO_TIMEZONES,   "Fib time zone",              ICON_TOOL_FIBO_TZ.fontName,   ICON_TOOL_FIBO_TZ.charCode,   "Fibonacci Time Zones");
   AddTool(m_categories[CAT_FIBONACCI].tools, TOOL_FIBO_FAN,         "Fib speed resistance fan",   ICON_TOOL_FIBO_FAN.fontName,  ICON_TOOL_FIBO_FAN.charCode,  "Fibonacci Speed Resistance Fan");
   AddTool(m_categories[CAT_FIBONACCI].tools, TOOL_FIBO_ARCS,        "Fib speed resistance arcs",  ICON_TOOL_FIBO_ARCS.fontName, ICON_TOOL_FIBO_ARCS.charCode, "Fibonacci Speed Resistance Arcs");

   //--- Shapes category: 8 shape tools (Rectangle, Rotated rect, Path, Circle, Triangle, Ellipse, Arc, Curve)
   m_categories[CAT_SHAPES].categoryLabel = "Shapes";
   m_categories[CAT_SHAPES].iconFontName  = ICON_CATEGORY_SHAPES.fontName;
   m_categories[CAT_SHAPES].iconCharCode  = ICON_CATEGORY_SHAPES.charCode;
   ArrayResize(m_categories[CAT_SHAPES].tools, 0);
   AddTool(m_categories[CAT_SHAPES].tools, TOOL_RECTANGLE,         "Rectangle",         ICON_TOOL_RECTANGLE.fontName,    ICON_TOOL_RECTANGLE.charCode,    "Rectangle");
   AddTool(m_categories[CAT_SHAPES].tools, TOOL_ROTATED_RECTANGLE, "Rotated rectangle", ICON_TOOL_ROTATED_RECT.fontName, ICON_TOOL_ROTATED_RECT.charCode, "Rotated rectangle");
   AddTool(m_categories[CAT_SHAPES].tools, TOOL_PATH,              "Path",              ICON_TOOL_PATH.fontName,         ICON_TOOL_PATH.charCode,         "Path");
   AddTool(m_categories[CAT_SHAPES].tools, TOOL_CIRCLE,            "Circle",            ICON_TOOL_CIRCLE.fontName,       ICON_TOOL_CIRCLE.charCode,       "Circle");
   AddTool(m_categories[CAT_SHAPES].tools, TOOL_TRIANGLE,          "Triangle",          ICON_TOOL_TRIANGLE.fontName,     ICON_TOOL_TRIANGLE.charCode,     "Triangle");
   AddTool(m_categories[CAT_SHAPES].tools, TOOL_ELLIPSE,           "Ellipse",           ICON_TOOL_ELLIPSE.fontName,      ICON_TOOL_ELLIPSE.charCode,      "Ellipse");
   AddTool(m_categories[CAT_SHAPES].tools, TOOL_ARC,               "Arc",               ICON_TOOL_ARC.fontName,          ICON_TOOL_ARC.charCode,          "Arc");
   AddTool(m_categories[CAT_SHAPES].tools, TOOL_CURVE,             "Curve",             ICON_TOOL_CURVE.fontName,        ICON_TOOL_CURVE.charCode,        "Curve");

   //--- Annotations category: 9 annotation tools (Text, Arrow, Arrow Marker, Up/Down arrows, Note, Price Note, Callout, Comment)
   m_categories[CAT_ANNOTATIONS].categoryLabel = "Annotate";
   m_categories[CAT_ANNOTATIONS].iconFontName  = ICON_CATEGORY_ANNOTATIONS.fontName;
   m_categories[CAT_ANNOTATIONS].iconCharCode  = ICON_CATEGORY_ANNOTATIONS.charCode;
   ArrayResize(m_categories[CAT_ANNOTATIONS].tools, 0);
   AddTool(m_categories[CAT_ANNOTATIONS].tools, TOOL_TEXT,          "Text",          ICON_TOOL_TEXT.fontName,          ICON_TOOL_TEXT.charCode,          "Text");
   AddTool(m_categories[CAT_ANNOTATIONS].tools, TOOL_ARROW,         "Arrow",         ICON_TOOL_ARROW.fontName,         ICON_TOOL_ARROW.charCode,         "Arrow");
   AddTool(m_categories[CAT_ANNOTATIONS].tools, TOOL_ARROW_MARKER,  "Arrow Marker",  ICON_TOOL_ARROW_MARKER.fontName,  ICON_TOOL_ARROW_MARKER.charCode,  "Arrow Marker");
   AddTool(m_categories[CAT_ANNOTATIONS].tools, TOOL_ARROW_UP,      "Arrow Up",      ICON_TOOL_ARROW_UP.fontName,      ICON_TOOL_ARROW_UP.charCode,      "Arrow Up");
   AddTool(m_categories[CAT_ANNOTATIONS].tools, TOOL_ARROW_DOWN,    "Arrow Down",    ICON_TOOL_ARROW_DOWN.fontName,    ICON_TOOL_ARROW_DOWN.charCode,    "Arrow Down");
   AddTool(m_categories[CAT_ANNOTATIONS].tools, TOOL_NOTE,          "Note",          ICON_TOOL_NOTE.fontName,          ICON_TOOL_NOTE.charCode,          "Note");
   AddTool(m_categories[CAT_ANNOTATIONS].tools, TOOL_PRICE_NOTE,    "Price Note",    ICON_TOOL_PRICE_NOTE.fontName,    ICON_TOOL_PRICE_NOTE.charCode,    "Price Note");
   AddTool(m_categories[CAT_ANNOTATIONS].tools, TOOL_CALLOUT,       "Callout",       ICON_TOOL_CALLOUT.fontName,       ICON_TOOL_CALLOUT.charCode,       "Callout");
   AddTool(m_categories[CAT_ANNOTATIONS].tools, TOOL_COMMENT,       "Comment",       ICON_TOOL_COMMENT.fontName,       ICON_TOOL_COMMENT.charCode,       "Comment");

   //--- Delete (action category) - no tools registered; invokes ClearAllDrawnObjects via the flyout
   m_categories[CAT_DELETE].categoryLabel = "Delete";
   m_categories[CAT_DELETE].iconFontName  = ICON_CATEGORY_DELETE.fontName;
   m_categories[CAT_DELETE].iconCharCode  = ICON_CATEGORY_DELETE.charCode;
   ArrayResize(m_categories[CAT_DELETE].tools, 0);

   //--- Seed the per-category last-used slots to each category's first tool (drives initial tile icons)
   InitLastUsedTools();
  }

//+------------------------------------------------------------------+
//| DrawnObject - per-instance state for every placed drawing object |
//+------------------------------------------------------------------+
struct DrawnObject
  {
   //--- Core identity + anchor points (P1/P2/P3) and N-point path arrays
   TOOL_TYPE toolType;
   int       id;
   datetime  time1;
   double    price1;
   datetime  time2;
   double    price2;
   datetime  time3;
   double    price3;
   datetime  pathTimes[];
   double    pathPrices[];
   //--- Selection + visibility + label text
   color     objColor;
   bool      selected;
   bool      visible;
   string    labelText;
   //--- Per-object style overrides (line, text, opacity, font, alignment)
   int       lineWidth;
   int       lineStyle;
   color     textColor;
   int       lineOpacity;
   int       textOpacity;
   int       fontSize;
   bool      bold;
   int       vAlign;
   int       hAlign;
   //--- Fill colors and opacities (primary + secondary band fill)
   color     fillColor;
   int       fillOpacity;
   color     midColor;
   int       midOpacity;
   color     fillColor2;
   int       fillOpacity2;
   //--- Channel midline (used by Parallel/Regression/StdDev channels)
   bool      midVisible;
   int       midWidth;
   int       midStyle;
   double    midOffset;
   //--- Regression channel centerline + std-dev band visibility
   bool      centerVisible;
   color     centerColor;
   int       centerOpacity;
   int       centerWidth;
   int       centerStyle;
   bool      upperBandVisible;
   double    upperBandSigma;
   bool      lowerBandVisible;
   double    lowerBandSigma;
   bool      pearsonVisible;
   //--- Fibonacci retracement levels (per-level ratio + style + visibility arrays)
   double    fiboLevelRatio[];
   color     fiboLevelColor[];
   int       fiboLevelOpacity[];
   int       fiboLevelWidth[];
   int       fiboLevelStyle[];
   bool      fiboLevelVisible[];
   //--- Fibonacci expansion levels (parallel arrays for fibex)
   double    fibexLevelRatio[];
   color     fibexLevelColor[];
   int       fibexLevelOpacity[];
   int       fibexLevelWidth[];
   int       fibexLevelStyle[];
   bool      fibexLevelVisible[];
   //--- Fibonacci channel levels (parallel arrays for fibch)
   double    fibchLevelRatio[];
   color     fibchLevelColor[];
   int       fibchLevelOpacity[];
   int       fibchLevelWidth[];
   int       fibchLevelStyle[];
   bool      fibchLevelVisible[];
   //--- Fibonacci time-zone levels (parallel arrays for fibtz)
   double    fibtzLevelRatio[];
   color     fibtzLevelColor[];
   int       fibtzLevelOpacity[];
   int       fibtzLevelWidth[];
   int       fibtzLevelStyle[];
   bool      fibtzLevelVisible[];
   //--- Fibonacci fan levels (parallel arrays for fibfan)
   double    fibfanLevelRatio[];
   color     fibfanLevelColor[];
   int       fibfanLevelOpacity[];
   int       fibfanLevelWidth[];
   int       fibfanLevelStyle[];
   bool      fibfanLevelVisible[];
   //--- Fibonacci arc levels (parallel arrays for fibarc)
   double    fibarcLevelRatio[];
   color     fibarcLevelColor[];
   int       fibarcLevelOpacity[];
   int       fibarcLevelWidth[];
   int       fibarcLevelStyle[];
   bool      fibarcLevelVisible[];
   //--- Gann fan levels (parallel arrays for gannfan)
   double    gannfanLevelRatio[];
   color     gannfanLevelColor[];
   int       gannfanLevelOpacity[];
   int       gannfanLevelWidth[];
   int       gannfanLevelStyle[];
   bool      gannfanLevelVisible[];
   //--- Gann box levels (parallel arrays for gannbox)
   double    gannboxLevelRatio[];
   color     gannboxLevelColor[];
   int       gannboxLevelOpacity[];
   int       gannboxLevelWidth[];
   int       gannboxLevelStyle[];
   bool      gannboxLevelVisible[];
   //--- Pitchfork median + outer + inner line visibility/style (per-line override)
   bool      medianVisible;
   color     medianColor;
   int       medianWidth;
   int       medianStyle;
   bool      outerVisible;
   color     outerColor;
   int       outerWidth;
   int       outerStyle;
   bool      innerVisible;
   color     innerColor;
   int       innerWidth;
   int       innerStyle;
  };

//--- Label anchor-mode constants (drives DrawObjectLabel vertical placement)
#define LBL_ANCHOR_ABOVE_LINE   0
#define LBL_ANCHOR_CENTERED     1
#define LBL_ANCHOR_TOP          2
#define LBL_ANCHOR_AUTO_FIT     3

//--- Label shape-kind constants (drives DrawObjectLabel shape-clipping)
#define LBL_SHAPE_NONE          0
#define LBL_SHAPE_CIRCLE        1
#define LBL_SHAPE_ELLIPSE       2

//+------------------------------------------------------------------+
//| CDrawingEngine owns the drawn-object store and placement engine  |
//+------------------------------------------------------------------+
class CDrawingEngine : public CToolRegistry
  {
protected:
   //--- Drawn-object store + counters (m_drawnObjects array, monotonic ID counter, live count)
   DrawnObject m_drawnObjects[];
   int         m_drawnObjectCount;
   int         m_drawnObjectCounter;
   //--- Persistence dirty-flag + last-change tick (drives debounced flush; see ToolsPalette_Storage.mqh)
   bool        m_drawingsDirty;
   uint        m_drawingsDirtyTick;
   //--- In-progress placement state (click counter + the 3 anchor points captured per click)
   int         m_toolDrawingClickCount;
   datetime    m_drawPoint1Time;
   datetime    m_drawPoint2Time;
   double      m_drawPoint1Price;
   double      m_drawPoint2Price;
   //--- Path tool accumulator (N-point polyline; double-click within 500ms commits)
   datetime    m_pathBuildTimes[];
   double      m_pathBuildPrices[];
   ulong       m_pathLastClickMicros;
   int         m_pathLastClickX;
   int         m_pathLastClickY;
   //--- Hover + selection state (pointer-mode interaction)
   int         m_hoveredObjectId;
   int         m_hoveredHandleIdx;
   int         m_hoveredHandleHostId;
   int         m_selectedObjectId;
   int         m_draggedHandleIdx;
   bool        m_isDraggingHandle;
   int         m_hitThreshold;
   bool        m_isDraggingObject;
   int         m_dragLastMouseX;
   int         m_dragLastMouseY;
   ulong       m_lastPointerClickMicros;
   int         m_lastPointerClickHitId;
   //--- Pending text-edit state (armed on the first click before edit mode fully engages)
   bool        m_pendingTextEditArmed;
   int         m_pendingTextEditObjId;
   int         m_pendingTextEditStartX;
   int         m_pendingTextEditStartY;
   //--- Add-text-prompt overlay state (rotated-rect highlight before commit)
   int         m_addTextPromptObjId;
   int         m_addTextPromptX1;
   int         m_addTextPromptY1;
   int         m_addTextPromptX2;
   int         m_addTextPromptY2;
   int         m_addTextPromptCornerX[];
   int         m_addTextPromptCornerY[];
   //--- Label-hit state (which object's label was last hit, plus its rotated-rect corners)
   bool        m_labelHitActive;
   int         m_labelHitObjIdForLast;
   int         m_labelHitObjIdForSelected;
   int         m_labelHitX1;
   int         m_labelHitY1;
   int         m_labelHitX2;
   int         m_labelHitY2;
   int         m_labelHitCornerX[];
   int         m_labelHitCornerY[];
   //--- Rubber-band preview state (active during multi-click tool placement)
   bool        m_isPreviewActive;
   int         m_previewMouseX;
   int         m_previewMouseY;
   TOOL_TYPE   m_previewToolType;
   //--- Label editing state (buffer + caret + selection + saved keyboard nav state)
   bool        m_isEditingLabel;
   string      m_labelEditBuffer;
   int         m_labelCaretPos;
   int         m_labelSelectionAnchor;
   bool        m_savedKeyboardControl;
   bool        m_savedQuickNavigation;
   bool        m_keyboardOverrideActive;
   //--- Drawings canvas (full-chart overlay where all objects render)
   CCanvas     m_canvasDrawings;
   string      m_nameDrawings;
   //--- Object axis-label canvases (price + time labels on the chart axes for the active object)
   CCanvas     m_canvasObjPriceLabel1;
   CCanvas     m_canvasObjTimeLabel1;
   CCanvas     m_canvasObjPriceLabel2;
   CCanvas     m_canvasObjTimeLabel2;
   CCanvas     m_canvasObjPriceLabel3;
   CCanvas     m_canvasObjTimeLabel3;
   string      m_nameObjPriceLabel1;
   string      m_nameObjTimeLabel1;
   string      m_nameObjPriceLabel2;
   string      m_nameObjTimeLabel2;
   string      m_nameObjPriceLabel3;
   string      m_nameObjTimeLabel3;
   bool        m_objLabelsVisible;
   //--- Property-backup snapshot (taken by SnapshotProperties, restored by RestoreProperties on cancel)
   bool        m_propertyBackupValid;
   int         m_propertyBackupObjectId;
   DrawnObject m_propertyBackupSnapshot;
   //--- Per-tool memory (64 slots indexed by TOOL_TYPE; carries style overrides between placements)
   DrawnObject m_toolMemory[64];
   bool        m_toolMemoryValid[64];

protected:
   //--- Drawings canvas lifecycle (create / destroy / resize)
   bool         CreateDrawingsCanvas();
   void         DestroyDrawingsCanvas();
   void         ResizeDrawingsCanvas();
   //--- Object axis-label canvases lifecycle (create / destroy + show/hide helpers)
   bool         CreateObjLabelCanvases();
   void         DestroyObjLabelCanvases();
   void         HideObjLabels();
   void         UpdateObjLabels();
   //--- Engine_Render hooks (impl in ToolsPalette_Engine_Render.mqh)
   void         RedrawPermanentAxisLabels();
   void         DeletePermanentAxisLabelsFor(int objId);
   //--- Object store management
   int          FindObjectIndexById(int id);
   int          AddDrawnObject(TOOL_TYPE toolType, datetime t1, double p1,
                               datetime t2, double p2, datetime t3, double p3, color objColor,
                               bool useMemory = true);
   void         RemoveDrawnObject(int id);
   //--- Drawing persistence (impl in src/storage/ToolsPalette_Storage.mqh)
   string       DrawingsFilePath();
   void         MarkDrawingsDirty();
   void         MaybeFlushDrawings();
   bool         SaveDrawings();
   bool         RestoreDrawings();
   void         MaterializeLoadedObject(const string &keys[], const string &vals[], int &maxId);
   void         ClearAllDrawnObjects();
   void         ApplyToolDefaults(int objId);
   //--- Per-tool style memory (captures/applies style between same-tool placements)
   void         CaptureToolMemory(int liveIdx);
   void         ApplyToolMemory(int newIdx);
   //--- Render orchestrator + per-shape draw + rubber-band (impls split across Engine_Render/.mqh files)
   void         RedrawAllObjects();
   void         DrawRectangle(int x1, int y1, int x2, int y2, color objColor, bool selected, bool hovered);
   void         DrawTriangle(int x1, int y1, int x2, int y2, int x3, int y3, color objColor, bool selected, bool hovered);
   void         DrawEllipse(int x1, int y1, int x2, int y2, int x3, int y3, color objColor, bool selected, bool hovered);
   void         DrawRubberBand(int x1, int y1, int x2, int y2, TOOL_TYPE toolType, color objColor);
   void         UpdatePreviewMousePos(int mouseX, int mouseY);
   //--- Per-tool default color resolver
   color        GetToolDefaultColor(TOOL_TYPE toolType);
   //--- Hit-testing primitives (rectangle, ellipse, handle, full-scan)
   bool         HitTestRectangle(int mx, int my, int x1, int y1, int x2, int y2);
   bool         HitTestEllipse(int mx, int my, int cx, int cy, int rx, int ry);
   int          HitTestHandles(int mx, int my, int objIdx);
   int          HitTestAllObjects(int mouseX, int mouseY);
   bool         PointInRotatedRect(int px, int py, const int &cx[], const int &cy[]);
   //--- Path tool helpers (declared early so HandleDrawingClick can call CommitPath / CancelPath)
   void         CommitPath(TOOL_TYPE &activeTool, string &instruction);
   void         CancelPath();
   //--- Selection helpers (declared early so HandleDrawingClick can call SelectObjectById)
   void         SelectObjectById(int objId);
   //--- Placement engine (1/2/3-click placement paths and main click dispatcher)
   void         PlaceSingleClickObject(datetime t, double p, int sub, TOOL_TYPE toolType);
   void         PlaceTwoClickObject(TOOL_TYPE toolType);
   void         PlaceThreeClickObject(datetime t3, double p3, TOOL_TYPE toolType);
   void         HandleDrawingClick(int mouseX, int mouseY, TOOL_TYPE &activeTool, string &instruction);
   //--- Pointer-mode interaction (impl in ToolsPalette_Engine_Interact.mqh)
   void         HandlePointerMouseMove(int mouseX, int mouseY);
   void         HandlePointerClick(int mouseX, int mouseY);
   void         HandlePointerDoubleClick(int mouseX, int mouseY);
   void         HandlePointerDragMove(int mouseX, int mouseY);
   void         HandlePointerDragRelease();
   void         DeleteSelectedObject();
   //--- Engine_Edit method declarations (implementations in ToolsPalette_Engine_Edit.mqh)
   void         BeginKeyboardOverride();
   void         EndKeyboardOverride();
   void         StartLabelEdit();
   void         AppendLabelChar(string ch);
   void         BackspaceLabelChar();
   void         CommitLabel();
   void         CancelLabel();
   bool         HasLabelSelection();
   bool         GetLabelSelectionRange(int &outStart, int &outEnd);
   bool         DeleteLabelSelection();
   void         LabelSelectAll();
   void         ClearLabelSelection();
   void         ShiftExtendCaretLeft();
   void         ShiftExtendCaretRight();
   void         ShiftExtendCaretUp();
   void         ShiftExtendCaretDown();
   void         ShiftExtendCaretHome();
   void         ShiftExtendCaretEnd();
   void         InsertCharAtCaret(string ch);
   void         InsertNewlineAtCaret();
   void         BackspaceAtCaret();
   void         DeleteAtCaret();
   void         MoveCaretLeft();
   void         MoveCaretRight();
   void         MoveCaretUp();
   void         MoveCaretDown();
   void         MoveCaretHome();
   void         MoveCaretEnd();
   bool         ResolveCaretVisualLayout(string &outLines[], int &outBufOffsets[]);
   void         ComputeCaretLineColumn(int &outLine, int &outCol);
   void         SplitTextIntoLines(const string text, string &lines[]);
   int          LineColumnToCaret(int line, int col);
   bool         GetHostTextLayout(int objIdx, int &outPadX, int &outPadY,
                                   string &outFontName, int &outFontPt, int &outWrapWidth);
   void         SetCaretFromMouseClick(int mx, int my, int hostPaddingX, int hostPaddingY,
                                        const string fontName, int fontPt, int wrapWidth = 0);
   //--- DrawObjectLabel declaration (implementation in ToolsPalette_Engine_Render.mqh)
   void         DrawObjectLabel(int mx, int my, int x1, int y1, int x2, int y2,
                                const string labelText, bool selected, bool hovered, color objColor,
                                int anchorMode = 0, bool recordHitRect = false,
                                int wrapWidth = 0,
                                int hostClipL = -1, int hostClipT = -1,
                                int hostClipR = -1, int hostClipB = -1,
                                int shapeKind = 0,
                                double shapeRadiusA = 0.0,
                                double shapeRadiusB = 0.0,
                                int maxVisibleLines = 0,
                                int shapeCenterX = 0,
                                int shapeCenterY = 0,
                                int availableHeight = 0,
                                int textOpacity = 100,
                                int fontSize = 11,
                                bool bold = false,
                                int vAlign = 0,
                                int hAlign = 1);
   //--- Local helpers implemented inline in this file
   string       MakeUniqueObjectName();
   bool         FinalizeOpenLabelEdit();
   bool         CancelInProgressPlacement();
   bool         DeselectAll();
   //--- Engine_Properties method declarations (implementations in ToolsPalette_Engine_Properties.mqh)
   bool         GetObjectProperty(int objId, string propId, color &outValue);
   bool         GetObjectProperty(int objId, string propId, int &outValue);
   bool         GetObjectProperty(int objId, string propId, string &outValue);
   bool         GetObjectProperty(int objId, string propId, bool &outValue);
   bool         GetObjectProperty(int objId, string propId, double &outValue);
   bool         SetObjectProperty(int objId, string propId, color value, bool preview);
   bool         SetObjectProperty(int objId, string propId, int value, bool preview);
   bool         SetObjectProperty(int objId, string propId, string value, bool preview);
   bool         SetObjectProperty(int objId, string propId, bool value, bool preview);
   bool         SetObjectProperty(int objId, string propId, double value, bool preview);
   bool         SnapshotProperties(int objId);
   bool         RestoreProperties();
   void         DiscardSnapshot();
   bool         AppendFibLevel(int objId);
   bool         RemoveFibLevel(int objId, int levelIdx);
   int          GetObjectPointCount(int objId);
   bool         GetObjectPointPrice(int objId, int pointIdx, double &outPrice);
   bool         GetObjectPointTime(int objId, int pointIdx, datetime &outTime);
   bool         SetObjectPointPrice(int objId, int pointIdx, double newPrice, bool preview);
   bool         SetObjectPointTime(int objId, int pointIdx, datetime newTime, bool preview);
   //--- Selection-change notification hook (Part 8 ribbon overrides this to refresh property panes)
   virtual void OnSelectionChanged(int objId) { /* default no-op */ }
  };

//+------------------------------------------------------------------+
//| Create the full-chart drawings canvas (the object render surface)|
//+------------------------------------------------------------------+
bool CDrawingEngine::CreateDrawingsCanvas()
  {
   //--- Cache chart dimensions for the canvas creation
   int chartW = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
   int chartH = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
   //--- Create the canvas as a chart bitmap label spanning the full chart area
   if(!m_canvasDrawings.CreateBitmapLabel(0, 0, m_nameDrawings, 0, 0, chartW, chartH, COLOR_FORMAT_ARGB_NORMALIZE))
     { Print("Failed to create drawings canvas"); return false; }
   //--- Make the canvas visible on every timeframe + set its Z-order below the sidebar (50 < 86)
   ObjectSetInteger(0, m_nameDrawings, OBJPROP_TIMEFRAMES, OBJ_ALL_PERIODS);
   ObjectSetInteger(0, m_nameDrawings, OBJPROP_ZORDER, 50);
   //--- Clear the canvas and push the initial transparent state
   m_canvasDrawings.Erase(0x00000000);
   m_canvasDrawings.Update();
   return true;
  }

//+------------------------------------------------------------------+
//| Destroy the drawings canvas and its chart-object label           |
//+------------------------------------------------------------------+
void CDrawingEngine::DestroyDrawingsCanvas()
  {
   //--- Free the canvas buffer and delete the chart-object label
   m_canvasDrawings.Destroy();
   ObjectDelete(0, m_nameDrawings);
  }

//+------------------------------------------------------------------+
//| Resize the drawings canvas to match the current chart dimensions |
//+------------------------------------------------------------------+
void CDrawingEngine::ResizeDrawingsCanvas()
  {
   //--- Cache chart dimensions for the resize
   int chartW = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
   int chartH = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
   //--- Resize the canvas buffer + sync the chart-object size attributes
   m_canvasDrawings.Resize(chartW, chartH);
   ObjectSetInteger(0, m_nameDrawings, OBJPROP_XSIZE, chartW);
   ObjectSetInteger(0, m_nameDrawings, OBJPROP_YSIZE, chartH);
   //--- Re-render all objects so they're correctly positioned in the new canvas dimensions
   RedrawAllObjects();
  }

//+------------------------------------------------------------------+
//| Create the 6 object axis-label canvases (price+time for P1/P2/P3)|
//+------------------------------------------------------------------+
bool CDrawingEngine::CreateObjLabelCanvases()
  {
   //--- Price label 1 (P1's price axis label)
   if(!m_canvasObjPriceLabel1.CreateBitmapLabel(0,0,m_nameObjPriceLabel1,0,0,100,20,COLOR_FORMAT_ARGB_NORMALIZE))
     { Print("Failed to create obj price label 1"); return false; }
   ObjectSetInteger(0,m_nameObjPriceLabel1,OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS);
   ObjectSetInteger(0,m_nameObjPriceLabel1,OBJPROP_ZORDER,86);
   //--- Time label 1 (P1's time axis label)
   if(!m_canvasObjTimeLabel1.CreateBitmapLabel(0,0,m_nameObjTimeLabel1,0,0,150,20,COLOR_FORMAT_ARGB_NORMALIZE))
     { Print("Failed to create obj time label 1"); return false; }
   ObjectSetInteger(0,m_nameObjTimeLabel1,OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS);
   ObjectSetInteger(0,m_nameObjTimeLabel1,OBJPROP_ZORDER,86);
   //--- Price label 2 (P2's price axis label)
   if(!m_canvasObjPriceLabel2.CreateBitmapLabel(0,0,m_nameObjPriceLabel2,0,0,100,20,COLOR_FORMAT_ARGB_NORMALIZE))
     { Print("Failed to create obj price label 2"); return false; }
   ObjectSetInteger(0,m_nameObjPriceLabel2,OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS);
   ObjectSetInteger(0,m_nameObjPriceLabel2,OBJPROP_ZORDER,86);
   //--- Time label 2 (P2's time axis label)
   if(!m_canvasObjTimeLabel2.CreateBitmapLabel(0,0,m_nameObjTimeLabel2,0,0,150,20,COLOR_FORMAT_ARGB_NORMALIZE))
     { Print("Failed to create obj time label 2"); return false; }
   ObjectSetInteger(0,m_nameObjTimeLabel2,OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS);
   ObjectSetInteger(0,m_nameObjTimeLabel2,OBJPROP_ZORDER,86);
   //--- Price label 3 (P3's price axis label)
   if(!m_canvasObjPriceLabel3.CreateBitmapLabel(0,0,m_nameObjPriceLabel3,0,0,100,20,COLOR_FORMAT_ARGB_NORMALIZE))
     { Print("Failed to create obj price label 3"); return false; }
   ObjectSetInteger(0,m_nameObjPriceLabel3,OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS);
   ObjectSetInteger(0,m_nameObjPriceLabel3,OBJPROP_ZORDER,86);
   //--- Time label 3 (P3's time axis label)
   if(!m_canvasObjTimeLabel3.CreateBitmapLabel(0,0,m_nameObjTimeLabel3,0,0,150,20,COLOR_FORMAT_ARGB_NORMALIZE))
     { Print("Failed to create obj time label 3"); return false; }
   ObjectSetInteger(0,m_nameObjTimeLabel3,OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS);
   ObjectSetInteger(0,m_nameObjTimeLabel3,OBJPROP_ZORDER,86);
   //--- All canvases start hidden (visible only when an object is selected/hovered)
   m_objLabelsVisible = false;
   return true;
  }

//+------------------------------------------------------------------+
//| Destroy all 6 object axis-label canvases                         |
//+------------------------------------------------------------------+
void CDrawingEngine::DestroyObjLabelCanvases()
  {
   //--- Free each canvas buffer and delete its chart-object label
   m_canvasObjPriceLabel1.Destroy(); ObjectDelete(0,m_nameObjPriceLabel1);
   m_canvasObjTimeLabel1.Destroy();  ObjectDelete(0,m_nameObjTimeLabel1);
   m_canvasObjPriceLabel2.Destroy(); ObjectDelete(0,m_nameObjPriceLabel2);
   m_canvasObjTimeLabel2.Destroy();  ObjectDelete(0,m_nameObjTimeLabel2);
   m_canvasObjPriceLabel3.Destroy(); ObjectDelete(0,m_nameObjPriceLabel3);
   m_canvasObjTimeLabel3.Destroy();  ObjectDelete(0,m_nameObjTimeLabel3);
  }

//+------------------------------------------------------------------+
//| Hide all 6 object axis-label canvases                            |
//+------------------------------------------------------------------+
void CDrawingEngine::HideObjLabels()
  {
   //--- Bail if labels are already hidden (avoid redundant chart-object property writes)
   if(!m_objLabelsVisible) return;
   //--- Detach every label from all timeframes - effectively hides them
   ObjectSetInteger(0,m_nameObjPriceLabel1,OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS);
   ObjectSetInteger(0,m_nameObjTimeLabel1, OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS);
   ObjectSetInteger(0,m_nameObjPriceLabel2,OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS);
   ObjectSetInteger(0,m_nameObjTimeLabel2, OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS);
   ObjectSetInteger(0,m_nameObjPriceLabel3,OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS);
   ObjectSetInteger(0,m_nameObjTimeLabel3, OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS);
   m_objLabelsVisible = false;
  }

//+------------------------------------------------------------------+
//| Find the index of a drawn object by ID (linear scan)             |
//+------------------------------------------------------------------+
int CDrawingEngine::FindObjectIndexById(int id)
  {
   //--- Linear scan through m_drawnObjects looking for a matching ID
   int n = ArraySize(m_drawnObjects);
   for(int i = 0; i < n; i++)
      if(m_drawnObjects[i].id == id) return i;
   //--- Not found
   return -1;
  }

//+------------------------------------------------------------------+
//| Update the object axis labels for the active (hovered/selected)  |
//+------------------------------------------------------------------+
void CDrawingEngine::UpdateObjLabels()
  {
   //--- Selection takes priority over hover when deciding which object's labels to render
   int activeId = (m_selectedObjectId >= 0) ? m_selectedObjectId : m_hoveredObjectId;
   if(activeId < 0) { HideObjLabels(); return; }
   //--- Resolve the object's index from its ID
   int idx = FindObjectIndexById(activeId);
   if(idx < 0) { HideObjLabels(); return; }
   //--- Text annotations only show axis labels when selected (not when merely hovered)
   if(m_drawnObjects[idx].toolType == TOOL_TEXT &&
      activeId != m_selectedObjectId)
     { HideObjLabels(); return; }
   //--- Cache chart dimensions + symbol digits + theme foreground/background colors
   int chartW = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
   int chartH = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   color fgColor = (color)ChartGetInteger(0, CHART_COLOR_FOREGROUND);
   color bgColor = (color)ChartGetInteger(0, CHART_COLOR_BACKGROUND);
   uint fg = ColorToARGB(fgColor, 255);
   uint bg = ColorToARGB(bgColor, 255);
   //--- Visibility flags for each axis label (P1/P2/P3 price + time)
   bool showP1 = false, showT1 = false, showP2 = false, showT2 = false;
   bool showP3 = false, showT3 = false;
   //--- Pixel coords of each anchor point (resolved from time+price via ChartTimePriceToXY)
   int  x1=0,y1=0,x2=0,y2=0,x3=0,y3=0;
   //--- Always resolve P1's pixel coords; resolve P2 and P3 only if their times are non-zero
   ChartTimePriceToXY(m_chartId,0,m_drawnObjects[idx].time1,m_drawnObjects[idx].price1,x1,y1);
   if(m_drawnObjects[idx].time2 != 0)
      ChartTimePriceToXY(m_chartId,0,m_drawnObjects[idx].time2,m_drawnObjects[idx].price2,x2,y2);
   if(m_drawnObjects[idx].time3 != 0)
      ChartTimePriceToXY(m_chartId,0,m_drawnObjects[idx].time3,m_drawnObjects[idx].price3,x3,y3);
   //--- Dispatch by tool type to decide which axis labels are visible for this tool
   switch(m_drawnObjects[idx].toolType)
     {
      //--- Horizontal / vertical / cross lines hide all axis labels (price/time is already on the line)
      case TOOL_HLINE:
      case TOOL_VLINE:
      case TOOL_CROSS_LINE:
         break;
      //--- 2-point tools show P1 + P2 axis labels
      case TOOL_TRENDLINE: case TOOL_RAY: case TOOL_EXTENDED_LINE: case TOOL_INFO_LINE:
      case TOOL_TREND_ANGLE:
      case TOOL_RECTANGLE: case TOOL_FIBO_RETRACEMENT:
      case TOOL_PARALLEL_CHANNEL: case TOOL_REGRESSION_CHANNEL: case TOOL_STDDEV_CHANNEL:
      case TOOL_GANN_LINE: case TOOL_GANN_FAN: case TOOL_GANN_BOX:
      case TOOL_FIBO_TIMEZONES: case TOOL_FIBO_FAN: case TOOL_FIBO_ARCS:
      case TOOL_CIRCLE:
      case TOOL_ARROW:
      case TOOL_ARROW_MARKER:
      case TOOL_NOTE:
      case TOOL_PRICE_NOTE:
      case TOOL_CALLOUT:
         showP1 = true; showT1 = true; showP2 = true; showT2 = true;
         break;
      //--- 3-point tools show P1 + P2 + P3 axis labels
      case TOOL_PITCHFORK:
      case TOOL_SCHIFF_PITCHFORK:
      case TOOL_MOD_SCHIFF:
      case TOOL_FIBO_EXPANSION:
      case TOOL_FIBO_CHANNEL:
      case TOOL_TRIANGLE:
      case TOOL_ELLIPSE:
      case TOOL_ROTATED_RECTANGLE:
      case TOOL_ARC:
      case TOOL_CURVE:
         showP1 = true; showT1 = true;
         showP2 = true; showT2 = true;
         showP3 = true; showT3 = true;
         break;
      //--- Default fallback: show only P1's axis labels (covers 1-click tools like TEXT)
      default:
         showP1 = true; showT1 = true;
         break;
     }
   //--- Macro that renders one axis label canvas (price or time, on chart edge, centered on the pixel pos)
   #define RENDER_LABEL(canvas, objName, labelText, isPriceAxis, pixelPos) \
   { \
      TextSetFont("Arial", -(9 * 10)); \
      uint _tw=0,_th=0; \
      TextGetSize(labelText,_tw,_th); \
      int _lw=(int)_tw+8,_lh=(int)_th+4; \
      if(canvas.Width()!=_lw||canvas.Height()!=_lh) canvas.Resize(_lw,_lh); \
      ObjectSetInteger(0,objName,OBJPROP_XSIZE,_lw); \
      ObjectSetInteger(0,objName,OBJPROP_YSIZE,_lh); \
      uint _buf[]; \
      int _tot=_lw*_lh; \
      ArrayResize(_buf,_tot); \
      ArrayFill(_buf,0,_tot,bg&0x00FFFFFF); \
      TextOut(labelText,4,2,TA_LEFT|TA_TOP,_buf,_lw,_lh,fg&0x00FFFFFF,COLOR_FORMAT_XRGB_NOALPHA); \
      for(int _py=0;_py<_lh;_py++) for(int _px=0;_px<_lw;_px++) canvas.PixelSet(_px,_py,_buf[_py*_lw+_px]|0xFF000000); \
      canvas.Rectangle(0,0,_lw-1,_lh-1,fg); \
      canvas.Update(); \
      ObjectSetInteger(0,objName,OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS); \
      if(isPriceAxis) { \
         ObjectSetInteger(0,objName,OBJPROP_XDISTANCE,chartW-_lw+1); \
         int _ly = pixelPos - _lh/2; \
         if(_ly < 0) _ly = 0; \
         if(_ly + _lh > chartH) _ly = chartH - _lh; \
         ObjectSetInteger(0,objName,OBJPROP_YDISTANCE,_ly); \
      } else { \
         int _lx = pixelPos - _lw/2; \
         if(_lx < 0) _lx = 0; \
         if(_lx + _lw > chartW) _lx = chartW - _lw; \
         ObjectSetInteger(0,objName,OBJPROP_XDISTANCE,_lx); \
         ObjectSetInteger(0,objName,OBJPROP_YDISTANCE,chartH-_lh); \
      } \
   }
   //--- Render P1 price + time labels (or hide them when the flag is off)
   if(showP1)
      RENDER_LABEL(m_canvasObjPriceLabel1, m_nameObjPriceLabel1,
                   DoubleToString(m_drawnObjects[idx].price1, digits), true, y1)
   else
      ObjectSetInteger(0,m_nameObjPriceLabel1,OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS);
   if(showT1)
      RENDER_LABEL(m_canvasObjTimeLabel1, m_nameObjTimeLabel1,
                   TimeToString(m_drawnObjects[idx].time1, TIME_DATE|TIME_MINUTES), false, x1)
   else
      ObjectSetInteger(0,m_nameObjTimeLabel1,OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS);
   //--- Render P2 price + time labels (only if the object has a real P2)
   if(showP2 && m_drawnObjects[idx].time2 != 0)
      RENDER_LABEL(m_canvasObjPriceLabel2, m_nameObjPriceLabel2,
                   DoubleToString(m_drawnObjects[idx].price2, digits), true, y2)
   else
      ObjectSetInteger(0,m_nameObjPriceLabel2,OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS);
   if(showT2 && m_drawnObjects[idx].time2 != 0)
      RENDER_LABEL(m_canvasObjTimeLabel2, m_nameObjTimeLabel2,
                   TimeToString(m_drawnObjects[idx].time2, TIME_DATE|TIME_MINUTES), false, x2)
   else
      ObjectSetInteger(0,m_nameObjTimeLabel2,OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS);
   //--- Render P3 price + time labels (only if the object has a real P3)
   if(showP3 && m_drawnObjects[idx].time3 != 0)
      RENDER_LABEL(m_canvasObjPriceLabel3, m_nameObjPriceLabel3,
                   DoubleToString(m_drawnObjects[idx].price3, digits), true, y3)
   else
      ObjectSetInteger(0,m_nameObjPriceLabel3,OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS);
   if(showT3 && m_drawnObjects[idx].time3 != 0)
      RENDER_LABEL(m_canvasObjTimeLabel3, m_nameObjTimeLabel3,
                   TimeToString(m_drawnObjects[idx].time3, TIME_DATE|TIME_MINUTES), false, x3)
   else
      ObjectSetInteger(0,m_nameObjTimeLabel3,OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS);
   #undef RENDER_LABEL
   //--- Mark labels as currently visible (HideObjLabels will check this and tear them down on next hide)
   m_objLabelsVisible = true;
  }

//+------------------------------------------------------------------+
//| Resolve the default color for the given tool type                |
//+------------------------------------------------------------------+
color CDrawingEngine::GetToolDefaultColor(TOOL_TYPE toolType)
  {
   //--- Switch dispatches per-tool defaults; falls back to clrDodgerBlue for unknown tools
   switch(toolType)
     {
      case TOOL_RECTANGLE:          return clrDodgerBlue;
      case TOOL_ROTATED_RECTANGLE:  return clrTeal;
      case TOOL_TRIANGLE:           return clrMediumSeaGreen;
      case TOOL_ELLIPSE:            return clrCrimson;
      case TOOL_PATH:               return clrDodgerBlue;
      case TOOL_CIRCLE:             return clrDarkOrange;
      case TOOL_ARC:                return clrDeepPink;
      case TOOL_CURVE:              return clrDodgerBlue;
      case TOOL_PITCHFORK:          return clrMediumSeaGreen;
      case TOOL_SCHIFF_PITCHFORK:   return clrMediumSeaGreen;
      case TOOL_MOD_SCHIFF:         return clrMediumSeaGreen;
      case TOOL_ARROW_UP:           return clrGreen;
      case TOOL_ARROW_DOWN:         return clrRed;
      case TOOL_THUMB_UP:           return clrLime;
      case TOOL_THUMB_DOWN:         return clrRed;
      case TOOL_STOP_SIGN:          return clrRed;
      case TOOL_CHECK_MARK:         return clrLime;
      case TOOL_NOTE:               return clrDodgerBlue;
      case TOOL_PRICE_NOTE:         return clrDodgerBlue;
      case TOOL_CALLOUT:            return C'0,100,100';
      case TOOL_COMMENT:            return clrDodgerBlue;
      default:                      return clrDodgerBlue;
     }
  }

//+------------------------------------------------------------------+
//| Apply remembered tool style to a newly added object              |
//+------------------------------------------------------------------+
void CDrawingEngine::ApplyToolMemory(int newIdx)
  {
   //--- Bounds-check the index against the live object array
   if(newIdx < 0 || newIdx >= ArraySize(m_drawnObjects)) return;
   //--- Resolve the object's tool type and its memory slot
   const TOOL_TYPE tt = m_drawnObjects[newIdx].toolType;
   const int slot = (int)tt;
   if(slot < 0 || slot >= 64) return;
   //--- Bail if no memory has been captured for this tool yet (no prior placement of this tool type)
   if(!m_toolMemoryValid[slot]) return;
   //--- Save the new object's identity + anchor points + selection state (must NOT be overwritten by memory)
   const int       savedId       = m_drawnObjects[newIdx].id;
   const TOOL_TYPE savedToolType = m_drawnObjects[newIdx].toolType;
   const datetime  savedT1       = m_drawnObjects[newIdx].time1;
   const double    savedP1       = m_drawnObjects[newIdx].price1;
   const datetime  savedT2       = m_drawnObjects[newIdx].time2;
   const double    savedP2       = m_drawnObjects[newIdx].price2;
   const datetime  savedT3       = m_drawnObjects[newIdx].time3;
   const double    savedP3       = m_drawnObjects[newIdx].price3;
   const bool      savedSelected = m_drawnObjects[newIdx].selected;
   const bool      savedVisible  = m_drawnObjects[newIdx].visible;
   const string    savedLabelText = m_drawnObjects[newIdx].labelText;
   //--- Save the path arrays too (since paths can have many points distinct from P1/P2/P3)
   datetime savedPathTimes[];
   double   savedPathPrices[];
   ArrayCopy(savedPathTimes,  m_drawnObjects[newIdx].pathTimes);
   ArrayCopy(savedPathPrices, m_drawnObjects[newIdx].pathPrices);
   //--- Bulk-copy the remembered style state from memory into the live object
   m_drawnObjects[newIdx] = m_toolMemory[slot];
   //--- Deep-copy all Fibonacci level arrays (since struct assignment doesn't deep-copy dynamic arrays)
   ArrayCopy(m_drawnObjects[newIdx].fiboLevelRatio,    m_toolMemory[slot].fiboLevelRatio);
   ArrayCopy(m_drawnObjects[newIdx].fiboLevelColor,    m_toolMemory[slot].fiboLevelColor);
   ArrayCopy(m_drawnObjects[newIdx].fiboLevelOpacity,  m_toolMemory[slot].fiboLevelOpacity);
   ArrayCopy(m_drawnObjects[newIdx].fiboLevelWidth,    m_toolMemory[slot].fiboLevelWidth);
   ArrayCopy(m_drawnObjects[newIdx].fiboLevelStyle,    m_toolMemory[slot].fiboLevelStyle);
   ArrayCopy(m_drawnObjects[newIdx].fiboLevelVisible,  m_toolMemory[slot].fiboLevelVisible);
   ArrayCopy(m_drawnObjects[newIdx].fibexLevelRatio,   m_toolMemory[slot].fibexLevelRatio);
   ArrayCopy(m_drawnObjects[newIdx].fibexLevelColor,   m_toolMemory[slot].fibexLevelColor);
   ArrayCopy(m_drawnObjects[newIdx].fibexLevelOpacity, m_toolMemory[slot].fibexLevelOpacity);
   ArrayCopy(m_drawnObjects[newIdx].fibexLevelWidth,   m_toolMemory[slot].fibexLevelWidth);
   ArrayCopy(m_drawnObjects[newIdx].fibexLevelStyle,   m_toolMemory[slot].fibexLevelStyle);
   ArrayCopy(m_drawnObjects[newIdx].fibexLevelVisible, m_toolMemory[slot].fibexLevelVisible);
   ArrayCopy(m_drawnObjects[newIdx].fibchLevelRatio,   m_toolMemory[slot].fibchLevelRatio);
   ArrayCopy(m_drawnObjects[newIdx].fibchLevelColor,   m_toolMemory[slot].fibchLevelColor);
   ArrayCopy(m_drawnObjects[newIdx].fibchLevelOpacity, m_toolMemory[slot].fibchLevelOpacity);
   ArrayCopy(m_drawnObjects[newIdx].fibchLevelWidth,   m_toolMemory[slot].fibchLevelWidth);
   ArrayCopy(m_drawnObjects[newIdx].fibchLevelStyle,   m_toolMemory[slot].fibchLevelStyle);
   ArrayCopy(m_drawnObjects[newIdx].fibchLevelVisible, m_toolMemory[slot].fibchLevelVisible);
   ArrayCopy(m_drawnObjects[newIdx].fibtzLevelRatio,   m_toolMemory[slot].fibtzLevelRatio);
   ArrayCopy(m_drawnObjects[newIdx].fibtzLevelColor,   m_toolMemory[slot].fibtzLevelColor);
   ArrayCopy(m_drawnObjects[newIdx].fibtzLevelOpacity, m_toolMemory[slot].fibtzLevelOpacity);
   ArrayCopy(m_drawnObjects[newIdx].fibtzLevelWidth,   m_toolMemory[slot].fibtzLevelWidth);
   ArrayCopy(m_drawnObjects[newIdx].fibtzLevelStyle,   m_toolMemory[slot].fibtzLevelStyle);
   ArrayCopy(m_drawnObjects[newIdx].fibtzLevelVisible, m_toolMemory[slot].fibtzLevelVisible);
   ArrayCopy(m_drawnObjects[newIdx].fibfanLevelRatio,   m_toolMemory[slot].fibfanLevelRatio);
   ArrayCopy(m_drawnObjects[newIdx].fibfanLevelColor,   m_toolMemory[slot].fibfanLevelColor);
   ArrayCopy(m_drawnObjects[newIdx].fibfanLevelOpacity, m_toolMemory[slot].fibfanLevelOpacity);
   ArrayCopy(m_drawnObjects[newIdx].fibfanLevelWidth,   m_toolMemory[slot].fibfanLevelWidth);
   ArrayCopy(m_drawnObjects[newIdx].fibfanLevelStyle,   m_toolMemory[slot].fibfanLevelStyle);
   ArrayCopy(m_drawnObjects[newIdx].fibfanLevelVisible, m_toolMemory[slot].fibfanLevelVisible);
   ArrayCopy(m_drawnObjects[newIdx].fibarcLevelRatio,   m_toolMemory[slot].fibarcLevelRatio);
   ArrayCopy(m_drawnObjects[newIdx].fibarcLevelColor,   m_toolMemory[slot].fibarcLevelColor);
   ArrayCopy(m_drawnObjects[newIdx].fibarcLevelOpacity, m_toolMemory[slot].fibarcLevelOpacity);
   ArrayCopy(m_drawnObjects[newIdx].fibarcLevelWidth,   m_toolMemory[slot].fibarcLevelWidth);
   ArrayCopy(m_drawnObjects[newIdx].fibarcLevelStyle,   m_toolMemory[slot].fibarcLevelStyle);
   ArrayCopy(m_drawnObjects[newIdx].fibarcLevelVisible, m_toolMemory[slot].fibarcLevelVisible);
   //--- Deep-copy all Gann level arrays
   ArrayCopy(m_drawnObjects[newIdx].gannfanLevelRatio,   m_toolMemory[slot].gannfanLevelRatio);
   ArrayCopy(m_drawnObjects[newIdx].gannfanLevelColor,   m_toolMemory[slot].gannfanLevelColor);
   ArrayCopy(m_drawnObjects[newIdx].gannfanLevelOpacity, m_toolMemory[slot].gannfanLevelOpacity);
   ArrayCopy(m_drawnObjects[newIdx].gannfanLevelWidth,   m_toolMemory[slot].gannfanLevelWidth);
   ArrayCopy(m_drawnObjects[newIdx].gannfanLevelStyle,   m_toolMemory[slot].gannfanLevelStyle);
   ArrayCopy(m_drawnObjects[newIdx].gannfanLevelVisible, m_toolMemory[slot].gannfanLevelVisible);
   ArrayCopy(m_drawnObjects[newIdx].gannboxLevelRatio,   m_toolMemory[slot].gannboxLevelRatio);
   ArrayCopy(m_drawnObjects[newIdx].gannboxLevelColor,   m_toolMemory[slot].gannboxLevelColor);
   ArrayCopy(m_drawnObjects[newIdx].gannboxLevelOpacity, m_toolMemory[slot].gannboxLevelOpacity);
   ArrayCopy(m_drawnObjects[newIdx].gannboxLevelWidth,   m_toolMemory[slot].gannboxLevelWidth);
   ArrayCopy(m_drawnObjects[newIdx].gannboxLevelStyle,   m_toolMemory[slot].gannboxLevelStyle);
   ArrayCopy(m_drawnObjects[newIdx].gannboxLevelVisible, m_toolMemory[slot].gannboxLevelVisible);
   //--- Restore the new object's identity + anchor points (memory only applies style, not geometry)
   m_drawnObjects[newIdx].id        = savedId;
   m_drawnObjects[newIdx].toolType  = savedToolType;
   m_drawnObjects[newIdx].time1     = savedT1;
   m_drawnObjects[newIdx].price1    = savedP1;
   m_drawnObjects[newIdx].time2     = savedT2;
   m_drawnObjects[newIdx].price2    = savedP2;
   m_drawnObjects[newIdx].time3     = savedT3;
   m_drawnObjects[newIdx].price3    = savedP3;
   m_drawnObjects[newIdx].selected  = savedSelected;
   m_drawnObjects[newIdx].visible   = savedVisible;
   m_drawnObjects[newIdx].labelText = savedLabelText;
   ArrayCopy(m_drawnObjects[newIdx].pathTimes,  savedPathTimes);
   ArrayCopy(m_drawnObjects[newIdx].pathPrices, savedPathPrices);
  }

//+------------------------------------------------------------------+
//| Add a new drawn object to storage and return its monotonic ID    |
//+------------------------------------------------------------------+
int CDrawingEngine::AddDrawnObject(TOOL_TYPE toolType,
                                    datetime t1, double p1,
                                    datetime t2, double p2,
                                    datetime t3, double p3,
                                    color objColor,
                                    bool useMemory)
  {
   //--- Bump the monotonic ID counter + grow the array by one
   m_drawnObjectCounter++;
   int sz = ArraySize(m_drawnObjects);
   ArrayResize(m_drawnObjects, sz + 1);
   //--- Core identity + anchor points + color
   m_drawnObjects[sz].toolType  = toolType;
   m_drawnObjects[sz].id        = m_drawnObjectCounter;
   m_drawnObjects[sz].time1     = t1;
   m_drawnObjects[sz].price1    = p1;
   m_drawnObjects[sz].time2     = t2;
   m_drawnObjects[sz].price2    = p2;
   m_drawnObjects[sz].time3     = t3;
   m_drawnObjects[sz].price3    = p3;
   m_drawnObjects[sz].objColor  = objColor;
   //--- New objects start unselected - callers are responsible for SelectObjectById if desired
   m_drawnObjects[sz].selected  = false;
   m_drawnObjects[sz].visible   = true;
   m_drawnObjects[sz].labelText = "";
   //--- Default line + text style overrides
   m_drawnObjects[sz].lineWidth   = 2;
   m_drawnObjects[sz].lineStyle   = 0;
   m_drawnObjects[sz].textColor   = objColor;
   m_drawnObjects[sz].lineOpacity = 100;
   m_drawnObjects[sz].textOpacity = 100;
   m_drawnObjects[sz].fontSize    = 11;
   m_drawnObjects[sz].bold        = false;
   m_drawnObjects[sz].vAlign      = 0;
   m_drawnObjects[sz].hAlign      = 1;
   //--- Default fill + secondary fill colors
   m_drawnObjects[sz].fillColor   = objColor;
   m_drawnObjects[sz].fillOpacity = 30;
   m_drawnObjects[sz].midColor     = objColor;
   m_drawnObjects[sz].midOpacity   = 80;
   m_drawnObjects[sz].fillColor2   = clrCrimson;
   m_drawnObjects[sz].fillOpacity2 = 30;
   //--- Default channel midline (used by Parallel/Regression/StdDev channels)
   m_drawnObjects[sz].midVisible       = true;
   m_drawnObjects[sz].midWidth         = 1;
   m_drawnObjects[sz].midStyle         = 1;
   m_drawnObjects[sz].midOffset        = 0.5;
   //--- Default regression centerline + std-dev band visibility
   m_drawnObjects[sz].centerVisible    = true;
   m_drawnObjects[sz].centerColor      = objColor;
   m_drawnObjects[sz].centerOpacity    = 100;
   m_drawnObjects[sz].centerWidth      = 2;
   m_drawnObjects[sz].centerStyle      = 1;
   m_drawnObjects[sz].upperBandVisible = true;
   m_drawnObjects[sz].upperBandSigma   = 2.0;
   m_drawnObjects[sz].lowerBandVisible = true;
   m_drawnObjects[sz].lowerBandSigma   = 2.0;
   m_drawnObjects[sz].pearsonVisible   = true;
   //--- Fibonacci retracement level defaults (11 levels: 0, 0.236, 0.382, 0.5, 0.618, 0.786, 1.0, 1.618, 2.618, 3.618, 4.236)
     {
      const int FIBO_DEFAULT_N = 11;
      //--- Size the 6 parallel level-arrays to match
      ArrayResize(m_drawnObjects[sz].fiboLevelRatio,    FIBO_DEFAULT_N);
      ArrayResize(m_drawnObjects[sz].fiboLevelColor,    FIBO_DEFAULT_N);
      ArrayResize(m_drawnObjects[sz].fiboLevelOpacity,  FIBO_DEFAULT_N);
      ArrayResize(m_drawnObjects[sz].fiboLevelWidth,    FIBO_DEFAULT_N);
      ArrayResize(m_drawnObjects[sz].fiboLevelStyle,    FIBO_DEFAULT_N);
      ArrayResize(m_drawnObjects[sz].fiboLevelVisible,  FIBO_DEFAULT_N);
      const double defRatios[] = {0.0, 0.236, 0.382, 0.5, 0.618, 0.786,
                                   1.0, 1.618, 2.618, 3.618, 4.236};
      const color  defColors[] = {clrGray,        clrCrimson,    clrOrange,
                                   clrGoldenrod,   clrSeaGreen,   clrDarkCyan,
                                   clrGray,        clrDodgerBlue, clrMediumOrchid,
                                   clrBlueViolet,  clrCrimson};
      //--- Populate each level's defaults
      for(int k = 0; k < FIBO_DEFAULT_N; k++)
        {
         m_drawnObjects[sz].fiboLevelRatio[k]    = defRatios[k];
         m_drawnObjects[sz].fiboLevelColor[k]    = defColors[k];
         m_drawnObjects[sz].fiboLevelOpacity[k]  = 100;
         m_drawnObjects[sz].fiboLevelWidth[k]    = 2;
         m_drawnObjects[sz].fiboLevelStyle[k]    = 0;
         m_drawnObjects[sz].fiboLevelVisible[k]  = true;
        }
     }
   //--- Fibonacci expansion (fibex) defaults - 11 levels with same ratios as fibo retracement
     {
      const int N = 11;
      ArrayResize(m_drawnObjects[sz].fibexLevelRatio,    N);
      ArrayResize(m_drawnObjects[sz].fibexLevelColor,    N);
      ArrayResize(m_drawnObjects[sz].fibexLevelOpacity,  N);
      ArrayResize(m_drawnObjects[sz].fibexLevelWidth,    N);
      ArrayResize(m_drawnObjects[sz].fibexLevelStyle,    N);
      ArrayResize(m_drawnObjects[sz].fibexLevelVisible,  N);
      const double dr[] = {0.0, 0.236, 0.382, 0.5, 0.618, 0.786,
                             1.0, 1.618, 2.618, 3.618, 4.236};
      const color  dc[] = {clrGray,        clrCrimson,    clrOrange,
                             clrGoldenrod,   clrSeaGreen,   clrDarkCyan,
                             clrGray,        clrDodgerBlue, clrMediumOrchid,
                             clrBlueViolet,  clrCrimson};
      //--- Populate each level's defaults
      for(int k = 0; k < N; k++)
        {
         m_drawnObjects[sz].fibexLevelRatio[k]    = dr[k];
         m_drawnObjects[sz].fibexLevelColor[k]    = dc[k];
         m_drawnObjects[sz].fibexLevelOpacity[k]  = 100;
         m_drawnObjects[sz].fibexLevelWidth[k]    = 2;
         m_drawnObjects[sz].fibexLevelStyle[k]    = 0;
         m_drawnObjects[sz].fibexLevelVisible[k]  = true;
        }
     }
   //--- Fibonacci channel (fibch) defaults - 10 levels
     {
      const int N = 10;
      ArrayResize(m_drawnObjects[sz].fibchLevelRatio,    N);
      ArrayResize(m_drawnObjects[sz].fibchLevelColor,    N);
      ArrayResize(m_drawnObjects[sz].fibchLevelOpacity,  N);
      ArrayResize(m_drawnObjects[sz].fibchLevelWidth,    N);
      ArrayResize(m_drawnObjects[sz].fibchLevelStyle,    N);
      ArrayResize(m_drawnObjects[sz].fibchLevelVisible,  N);
      const double dr[] = {0.0, 0.382, 0.5, 0.618, 0.786, 1.0,
                             1.618, 2.618, 3.618, 4.236};
      const color  dc[] = {clrGray,        clrOrange,     clrGoldenrod,
                             clrSeaGreen,   clrDarkCyan,    clrGray,
                             clrDodgerBlue, clrMediumOrchid, clrBlueViolet,
                             clrCrimson};
      //--- Populate each level's defaults
      for(int k = 0; k < N; k++)
        {
         m_drawnObjects[sz].fibchLevelRatio[k]    = dr[k];
         m_drawnObjects[sz].fibchLevelColor[k]    = dc[k];
         m_drawnObjects[sz].fibchLevelOpacity[k]  = 100;
         m_drawnObjects[sz].fibchLevelWidth[k]    = 2;
         m_drawnObjects[sz].fibchLevelStyle[k]    = 0;
         m_drawnObjects[sz].fibchLevelVisible[k]  = true;
        }
     }
   //--- Fibonacci time zones (fibtz) defaults - integer Fib sequence stored as double, 11 levels
     {
      const int N = 11;
      ArrayResize(m_drawnObjects[sz].fibtzLevelRatio,    N);
      ArrayResize(m_drawnObjects[sz].fibtzLevelColor,    N);
      ArrayResize(m_drawnObjects[sz].fibtzLevelOpacity,  N);
      ArrayResize(m_drawnObjects[sz].fibtzLevelWidth,    N);
      ArrayResize(m_drawnObjects[sz].fibtzLevelStyle,    N);
      ArrayResize(m_drawnObjects[sz].fibtzLevelVisible,  N);
      const double dr[] = {0, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89};
      //--- Populate each level's defaults (color matches objColor for visual continuity with the tool)
      for(int k = 0; k < N; k++)
        {
         m_drawnObjects[sz].fibtzLevelRatio[k]    = dr[k];
         m_drawnObjects[sz].fibtzLevelColor[k]    = objColor;
         m_drawnObjects[sz].fibtzLevelOpacity[k]  = 100;
         m_drawnObjects[sz].fibtzLevelWidth[k]    = 2;
         m_drawnObjects[sz].fibtzLevelStyle[k]    = 0;
         m_drawnObjects[sz].fibtzLevelVisible[k]  = true;
        }
     }
   //--- Fibonacci fan (fibfan) defaults - 7 levels
     {
      const int N = 7;
      ArrayResize(m_drawnObjects[sz].fibfanLevelRatio,    N);
      ArrayResize(m_drawnObjects[sz].fibfanLevelColor,    N);
      ArrayResize(m_drawnObjects[sz].fibfanLevelOpacity,  N);
      ArrayResize(m_drawnObjects[sz].fibfanLevelWidth,    N);
      ArrayResize(m_drawnObjects[sz].fibfanLevelStyle,    N);
      ArrayResize(m_drawnObjects[sz].fibfanLevelVisible,  N);
      const double dr[] = {0.0, 0.25, 0.382, 0.5, 0.618, 0.75, 1.0};
      const color  dc[] = {clrGray,      clrCrimson,    clrOrange,
                             clrGoldenrod, clrSeaGreen,   clrDarkCyan,
                             clrGray};
      //--- Populate each level's defaults
      for(int k = 0; k < N; k++)
        {
         m_drawnObjects[sz].fibfanLevelRatio[k]    = dr[k];
         m_drawnObjects[sz].fibfanLevelColor[k]    = dc[k];
         m_drawnObjects[sz].fibfanLevelOpacity[k]  = 100;
         m_drawnObjects[sz].fibfanLevelWidth[k]    = 2;
         m_drawnObjects[sz].fibfanLevelStyle[k]    = 0;
         m_drawnObjects[sz].fibfanLevelVisible[k]  = true;
        }
     }
   //--- Fibonacci arcs (fibarc) defaults - 11 levels
     {
      const int N = 11;
      ArrayResize(m_drawnObjects[sz].fibarcLevelRatio,    N);
      ArrayResize(m_drawnObjects[sz].fibarcLevelColor,    N);
      ArrayResize(m_drawnObjects[sz].fibarcLevelOpacity,  N);
      ArrayResize(m_drawnObjects[sz].fibarcLevelWidth,    N);
      ArrayResize(m_drawnObjects[sz].fibarcLevelStyle,    N);
      ArrayResize(m_drawnObjects[sz].fibarcLevelVisible,  N);
      const double dr[] = {0.236, 0.382, 0.5, 0.618, 0.786, 1.0,
                             1.618, 2.618, 3.618, 4.236, 4.618};
      const color  dc[] = {clrCrimson,    clrOrange,     clrGoldenrod,
                             clrSeaGreen,   clrDarkCyan,    clrGray,
                             clrDodgerBlue, clrMediumOrchid, clrBlueViolet,
                             clrCrimson,    clrDeepPink};
      //--- Populate each level's defaults
      for(int k = 0; k < N; k++)
        {
         m_drawnObjects[sz].fibarcLevelRatio[k]    = dr[k];
         m_drawnObjects[sz].fibarcLevelColor[k]    = dc[k];
         m_drawnObjects[sz].fibarcLevelOpacity[k]  = 100;
         m_drawnObjects[sz].fibarcLevelWidth[k]    = 2;
         m_drawnObjects[sz].fibarcLevelStyle[k]    = 0;
         m_drawnObjects[sz].fibarcLevelVisible[k]  = true;
        }
     }
   //--- Pitchfork (all 3 variants) defaults - median, outer, inner trendline visibility + style
   if(toolType == TOOL_PITCHFORK
      || toolType == TOOL_SCHIFF_PITCHFORK
      || toolType == TOOL_MOD_SCHIFF)
     {
      m_drawnObjects[sz].medianVisible  = true;
      m_drawnObjects[sz].medianColor    = clrCrimson;
      m_drawnObjects[sz].medianWidth    = 2;
      m_drawnObjects[sz].medianStyle    = 0;
      m_drawnObjects[sz].outerVisible   = true;
      m_drawnObjects[sz].outerColor     = clrDodgerBlue;
      m_drawnObjects[sz].outerWidth     = 2;
      m_drawnObjects[sz].outerStyle     = 0;
      m_drawnObjects[sz].innerVisible   = true;
      m_drawnObjects[sz].innerColor     = clrMediumSeaGreen;
      m_drawnObjects[sz].innerWidth     = 2;
      m_drawnObjects[sz].innerStyle     = 0;
      m_drawnObjects[sz].fillOpacity    = 30;
      //--- Defensive: ensure lineOpacity isn't zero (would render lines invisible)
      if(m_drawnObjects[sz].lineOpacity <= 0)
         m_drawnObjects[sz].lineOpacity = 100;
     }
   //--- Gann Line defaults - just enforce reasonable line opacity + width
   if(toolType == TOOL_GANN_LINE)
     {
      if(m_drawnObjects[sz].lineOpacity <= 0)
         m_drawnObjects[sz].lineOpacity = 100;
      if(m_drawnObjects[sz].lineWidth   <= 0)
         m_drawnObjects[sz].lineWidth   = 2;
     }
   //--- Gann Fan defaults - 9 canonical ratios (8x1, 4x1, 3x1, 2x1, 1x1, 1x2, 1x3, 1x4, 1x8)
   if(toolType == TOOL_GANN_FAN)
     {
      const int N = 9;
      ArrayResize(m_drawnObjects[sz].gannfanLevelRatio,    N);
      ArrayResize(m_drawnObjects[sz].gannfanLevelColor,    N);
      ArrayResize(m_drawnObjects[sz].gannfanLevelOpacity,  N);
      ArrayResize(m_drawnObjects[sz].gannfanLevelWidth,    N);
      ArrayResize(m_drawnObjects[sz].gannfanLevelStyle,    N);
      ArrayResize(m_drawnObjects[sz].gannfanLevelVisible,  N);
      const double dr[] = {8.0,   4.0,  3.0,        2.0,  1.0,
                             0.5,   1.0/3.0, 0.25, 0.125};
      const color  dc[] = {clrRed,        clrCrimson,   clrBlueViolet,
                             clrRoyalBlue,  clrDodgerBlue, clrDarkCyan,
                             clrSeaGreen,   clrTeal,       clrOrange};
      //--- Populate each level's defaults
      for(int k = 0; k < N; k++)
        {
         m_drawnObjects[sz].gannfanLevelRatio[k]    = dr[k];
         m_drawnObjects[sz].gannfanLevelColor[k]    = dc[k];
         m_drawnObjects[sz].gannfanLevelOpacity[k]  = 100;
         m_drawnObjects[sz].gannfanLevelWidth[k]    = 2;
         m_drawnObjects[sz].gannfanLevelStyle[k]    = 0;
         m_drawnObjects[sz].gannfanLevelVisible[k]  = true;
        }
      m_drawnObjects[sz].fillOpacity = 30;
      //--- Defensive: ensure lineOpacity isn't zero
      if(m_drawnObjects[sz].lineOpacity <= 0)
         m_drawnObjects[sz].lineOpacity = 100;
     }
   //--- Gann Box defaults - 7 levels (0, 0.25, 0.382, 0.5, 0.618, 0.75, 1.0)
   if(toolType == TOOL_GANN_BOX)
     {
      const int N = 7;
      ArrayResize(m_drawnObjects[sz].gannboxLevelRatio,    N);
      ArrayResize(m_drawnObjects[sz].gannboxLevelColor,    N);
      ArrayResize(m_drawnObjects[sz].gannboxLevelOpacity,  N);
      ArrayResize(m_drawnObjects[sz].gannboxLevelWidth,    N);
      ArrayResize(m_drawnObjects[sz].gannboxLevelStyle,    N);
      ArrayResize(m_drawnObjects[sz].gannboxLevelVisible,  N);
      const double dr[] = {0.0, 0.25, 0.382, 0.5, 0.618, 0.75, 1.0};
      const color  dc[] = {clrGray,        clrOrange,    clrDarkCyan,
                             clrSeaGreen,   clrTeal,       clrDodgerBlue,
                             clrGray};
      //--- Populate each level's defaults
      for(int k = 0; k < N; k++)
        {
         m_drawnObjects[sz].gannboxLevelRatio[k]    = dr[k];
         m_drawnObjects[sz].gannboxLevelColor[k]    = dc[k];
         m_drawnObjects[sz].gannboxLevelOpacity[k]  = 100;
         m_drawnObjects[sz].gannboxLevelWidth[k]    = 2;
         m_drawnObjects[sz].gannboxLevelStyle[k]    = 0;
         m_drawnObjects[sz].gannboxLevelVisible[k]  = true;
        }
      m_drawnObjects[sz].fillOpacity = 30;
      //--- Defensive: ensure lineOpacity isn't zero
      if(m_drawnObjects[sz].lineOpacity <= 0)
         m_drawnObjects[sz].lineOpacity = 100;
     }
   //--- Per-tool vAlign/hAlign + style overrides (drive label placement and content fill)
   if(toolType == TOOL_HLINE || toolType == TOOL_VLINE || toolType == TOOL_CROSS_LINE)
     {
      //--- Single-axis lines: center vertical alignment for the label
      m_drawnObjects[sz].vAlign = 1;
     }
   else if(toolType == TOOL_RECTANGLE || toolType == TOOL_TRIANGLE
        || toolType == TOOL_ELLIPSE   || toolType == TOOL_CIRCLE)
     {
      //--- 2D shapes: center both vertical + horizontal alignment for the label
      m_drawnObjects[sz].vAlign = 1;
      m_drawnObjects[sz].hAlign = 1;
     }
   else if(toolType == TOOL_TEXT)
     {
      //--- Text annotations: slightly larger default font, centered both axes
      m_drawnObjects[sz].fontSize = 12;
      m_drawnObjects[sz].vAlign   = 1;
      m_drawnObjects[sz].hAlign   = 1;
     }
   else if(toolType == TOOL_ARROW)
     {
      //--- Arrow annotations: ensure line + text style defaults are populated
      m_drawnObjects[sz].lineWidth   = 2;
      m_drawnObjects[sz].lineOpacity = 100;
      m_drawnObjects[sz].fontSize    = 11;
      m_drawnObjects[sz].bold        = false;
      m_drawnObjects[sz].textOpacity = 100;
      m_drawnObjects[sz].vAlign      = 0;
      m_drawnObjects[sz].hAlign      = 1;
     }
   else if(toolType == TOOL_ARROW_MARKER
           || toolType == TOOL_ARROW_UP
           || toolType == TOOL_ARROW_DOWN)
     {
      //--- Arrow markers: ensure line opacity is non-zero
      m_drawnObjects[sz].lineOpacity = 100;
     }
   else if(toolType == TOOL_NOTE)
     {
      //--- Note annotations: chart-bg-filled box with colored text, slightly larger font
      m_drawnObjects[sz].lineOpacity = 100;
      m_drawnObjects[sz].fontSize    = 12;
      m_drawnObjects[sz].bold        = false;
      m_drawnObjects[sz].fillColor   = (color)ChartGetInteger(0, CHART_COLOR_BACKGROUND);
      m_drawnObjects[sz].fillOpacity = 100;
      m_drawnObjects[sz].textColor   = objColor;
      m_drawnObjects[sz].textOpacity = 100;
     }
   else if(toolType == TOOL_PRICE_NOTE)
     {
      //--- Price-note annotations: colored bg + white text, compact font
      m_drawnObjects[sz].lineOpacity = 100;
      m_drawnObjects[sz].fontSize    = 10;
      m_drawnObjects[sz].fillColor   = objColor;
      m_drawnObjects[sz].fillOpacity = 100;
      m_drawnObjects[sz].textColor   = clrWhite;
      m_drawnObjects[sz].textOpacity = 100;
     }
   else if(toolType == TOOL_CALLOUT)
     {
      //--- Callout annotations: colored bg + white text + standard font
      m_drawnObjects[sz].lineOpacity = 100;
      m_drawnObjects[sz].fontSize    = 12;
      m_drawnObjects[sz].bold        = false;
      m_drawnObjects[sz].fillColor   = objColor;
      m_drawnObjects[sz].fillOpacity = 100;
      m_drawnObjects[sz].textColor   = clrWhite;
      m_drawnObjects[sz].textOpacity = 100;
     }
   else if(toolType == TOOL_COMMENT)
     {
      //--- Comment annotations: same as Callout but a different tool dispatch
      m_drawnObjects[sz].lineOpacity = 100;
      m_drawnObjects[sz].fontSize    = 12;
      m_drawnObjects[sz].bold        = false;
      m_drawnObjects[sz].fillColor   = objColor;
      m_drawnObjects[sz].fillOpacity = 100;
      m_drawnObjects[sz].textColor   = clrWhite;
      m_drawnObjects[sz].textOpacity = 100;
     }
   else if(toolType == TOOL_PARALLEL_CHANNEL)
     {
      //--- Parallel channel default fill color
      m_drawnObjects[sz].fillColor = clrDodgerBlue;
     }
   else if(toolType == TOOL_REGRESSION_CHANNEL)
     {
      //--- Regression channel default fill color
      m_drawnObjects[sz].fillColor = clrDodgerBlue;
     }
   else if(toolType == TOOL_STDDEV_CHANNEL)
     {
      //--- StdDev channel default fill color
      m_drawnObjects[sz].fillColor = clrDodgerBlue;
     }
   //--- Bump the live count and (if requested) overlay any remembered style from prior placements
   m_drawnObjectCount++;
   if(useMemory) ApplyToolMemory(sz);
   MarkDrawingsDirty();
   return m_drawnObjectCounter;
  }

//+------------------------------------------------------------------+
//| Remove a drawn object by ID + clear axis labels + redraw         |
//+------------------------------------------------------------------+
void CDrawingEngine::RemoveDrawnObject(int id)
  {
   //--- Tear down any permanent axis labels owned by this object (implementation in Engine_Render.mqh)
   DeletePermanentAxisLabelsFor(id);
   //--- Remember whether we're removing the currently selected object (drives selection-change notification)
   bool wasSelected = (m_selectedObjectId == id);
   int n = ArraySize(m_drawnObjects);
   //--- Linear scan looking for the ID; shift-erase + truncate when found
   for(int i = 0; i < n; i++)
     {
      if(m_drawnObjects[i].id == id)
        {
         //--- Shift every subsequent element down by one to fill the gap
         for(int j = i; j < n - 1; j++) m_drawnObjects[j] = m_drawnObjects[j + 1];
         ArrayResize(m_drawnObjects, n - 1);
         m_drawnObjectCount--;
         //--- Notify the ribbon about selection loss when removing the selected object
         if(wasSelected)
           {
            m_selectedObjectId = -1;
            OnSelectionChanged(-1);
           }
         MarkDrawingsDirty();
         //--- Re-render the canvas without the removed object
         RedrawAllObjects();
         return;
        }
     }
  }

//+------------------------------------------------------------------+
//| Clear ALL drawn objects + tear down their axis labels            |
//+------------------------------------------------------------------+
void CDrawingEngine::ClearAllDrawnObjects()
  {
   //--- Remember whether a selection was active (drives selection-change notification)
   bool hadSelection = (m_selectedObjectId >= 0);
   int n = ArraySize(m_drawnObjects);
   //--- Tear down every object's permanent axis labels
   for(int i = 0; i < n; i++)
      DeletePermanentAxisLabelsFor(m_drawnObjects[i].id);
   //--- Truncate the live array + reset counters + selection state
   ArrayResize(m_drawnObjects, 0);
   m_drawnObjectCount = 0;
   m_selectedObjectId = -1;
   //--- Clear the canvas and push the update
   m_canvasDrawings.Erase(0x00000000);
   m_canvasDrawings.Update();
   //--- Notify the ribbon about selection loss (if there was one)
   if(hadSelection) OnSelectionChanged(-1);
   MarkDrawingsDirty();
  }

//+------------------------------------------------------------------+
//| Reset an object's style to defaults (re-runs AddDrawnObject body)|
//+------------------------------------------------------------------+
void CDrawingEngine::ApplyToolDefaults(int objId)
  {
   //--- Resolve the live object's index; bail if invalid
   const int liveIdx = FindObjectIndexById(objId);
   if(liveIdx < 0) return;
   //--- Save the object's identity + geometry + label (these MUST survive the style reset)
   const int       savedId       = m_drawnObjects[liveIdx].id;
   const TOOL_TYPE savedToolType = m_drawnObjects[liveIdx].toolType;
   const datetime  savedT1       = m_drawnObjects[liveIdx].time1;
   const double    savedP1       = m_drawnObjects[liveIdx].price1;
   const datetime  savedT2       = m_drawnObjects[liveIdx].time2;
   const double    savedP2       = m_drawnObjects[liveIdx].price2;
   const datetime  savedT3       = m_drawnObjects[liveIdx].time3;
   const double    savedP3       = m_drawnObjects[liveIdx].price3;
   const bool      savedSelected = m_drawnObjects[liveIdx].selected;
   const bool      savedVisible  = m_drawnObjects[liveIdx].visible;
   const string    savedLabelText = m_drawnObjects[liveIdx].labelText;
   //--- Save the path arrays too (since paths can have many points distinct from P1/P2/P3)
   datetime savedPathTimes[];
   double   savedPathPrices[];
   ArrayCopy(savedPathTimes,  m_drawnObjects[liveIdx].pathTimes);
   ArrayCopy(savedPathPrices, m_drawnObjects[liveIdx].pathPrices);
   //--- Spawn a brand-new "template" object of the same tool type with default styling (useMemory=false skips memory overlay)
   const color seedColor = GetToolDefaultColor(savedToolType);
   const int   tplId     = AddDrawnObject(savedToolType,
                                            savedT1, savedP1,
                                            savedT2, savedP2,
                                            savedT3, savedP3,
                                            seedColor,
                                            false);
   const int   tplIdx    = FindObjectIndexById(tplId);
   if(tplIdx < 0) return;
   //--- Bulk-copy the template's style state into the live object
   m_drawnObjects[liveIdx] = m_drawnObjects[tplIdx];
   //--- Deep-copy all Fibonacci level arrays (since struct assignment doesn't deep-copy dynamic arrays)
   ArrayCopy(m_drawnObjects[liveIdx].fiboLevelRatio,    m_drawnObjects[tplIdx].fiboLevelRatio);
   ArrayCopy(m_drawnObjects[liveIdx].fiboLevelColor,    m_drawnObjects[tplIdx].fiboLevelColor);
   ArrayCopy(m_drawnObjects[liveIdx].fiboLevelOpacity,  m_drawnObjects[tplIdx].fiboLevelOpacity);
   ArrayCopy(m_drawnObjects[liveIdx].fiboLevelWidth,    m_drawnObjects[tplIdx].fiboLevelWidth);
   ArrayCopy(m_drawnObjects[liveIdx].fiboLevelStyle,    m_drawnObjects[tplIdx].fiboLevelStyle);
   ArrayCopy(m_drawnObjects[liveIdx].fiboLevelVisible,  m_drawnObjects[tplIdx].fiboLevelVisible);
   ArrayCopy(m_drawnObjects[liveIdx].fibexLevelRatio,   m_drawnObjects[tplIdx].fibexLevelRatio);
   ArrayCopy(m_drawnObjects[liveIdx].fibexLevelColor,   m_drawnObjects[tplIdx].fibexLevelColor);
   ArrayCopy(m_drawnObjects[liveIdx].fibexLevelOpacity, m_drawnObjects[tplIdx].fibexLevelOpacity);
   ArrayCopy(m_drawnObjects[liveIdx].fibexLevelWidth,   m_drawnObjects[tplIdx].fibexLevelWidth);
   ArrayCopy(m_drawnObjects[liveIdx].fibexLevelStyle,   m_drawnObjects[tplIdx].fibexLevelStyle);
   ArrayCopy(m_drawnObjects[liveIdx].fibexLevelVisible, m_drawnObjects[tplIdx].fibexLevelVisible);
   ArrayCopy(m_drawnObjects[liveIdx].fibchLevelRatio,   m_drawnObjects[tplIdx].fibchLevelRatio);
   ArrayCopy(m_drawnObjects[liveIdx].fibchLevelColor,   m_drawnObjects[tplIdx].fibchLevelColor);
   ArrayCopy(m_drawnObjects[liveIdx].fibchLevelOpacity, m_drawnObjects[tplIdx].fibchLevelOpacity);
   ArrayCopy(m_drawnObjects[liveIdx].fibchLevelWidth,   m_drawnObjects[tplIdx].fibchLevelWidth);
   ArrayCopy(m_drawnObjects[liveIdx].fibchLevelStyle,   m_drawnObjects[tplIdx].fibchLevelStyle);
   ArrayCopy(m_drawnObjects[liveIdx].fibchLevelVisible, m_drawnObjects[tplIdx].fibchLevelVisible);
   ArrayCopy(m_drawnObjects[liveIdx].fibtzLevelRatio,   m_drawnObjects[tplIdx].fibtzLevelRatio);
   ArrayCopy(m_drawnObjects[liveIdx].fibtzLevelColor,   m_drawnObjects[tplIdx].fibtzLevelColor);
   ArrayCopy(m_drawnObjects[liveIdx].fibtzLevelOpacity, m_drawnObjects[tplIdx].fibtzLevelOpacity);
   ArrayCopy(m_drawnObjects[liveIdx].fibtzLevelWidth,   m_drawnObjects[tplIdx].fibtzLevelWidth);
   ArrayCopy(m_drawnObjects[liveIdx].fibtzLevelStyle,   m_drawnObjects[tplIdx].fibtzLevelStyle);
   ArrayCopy(m_drawnObjects[liveIdx].fibtzLevelVisible, m_drawnObjects[tplIdx].fibtzLevelVisible);
   ArrayCopy(m_drawnObjects[liveIdx].fibfanLevelRatio,   m_drawnObjects[tplIdx].fibfanLevelRatio);
   ArrayCopy(m_drawnObjects[liveIdx].fibfanLevelColor,   m_drawnObjects[tplIdx].fibfanLevelColor);
   ArrayCopy(m_drawnObjects[liveIdx].fibfanLevelOpacity, m_drawnObjects[tplIdx].fibfanLevelOpacity);
   ArrayCopy(m_drawnObjects[liveIdx].fibfanLevelWidth,   m_drawnObjects[tplIdx].fibfanLevelWidth);
   ArrayCopy(m_drawnObjects[liveIdx].fibfanLevelStyle,   m_drawnObjects[tplIdx].fibfanLevelStyle);
   ArrayCopy(m_drawnObjects[liveIdx].fibfanLevelVisible, m_drawnObjects[tplIdx].fibfanLevelVisible);
   ArrayCopy(m_drawnObjects[liveIdx].fibarcLevelRatio,   m_drawnObjects[tplIdx].fibarcLevelRatio);
   ArrayCopy(m_drawnObjects[liveIdx].fibarcLevelColor,   m_drawnObjects[tplIdx].fibarcLevelColor);
   ArrayCopy(m_drawnObjects[liveIdx].fibarcLevelOpacity, m_drawnObjects[tplIdx].fibarcLevelOpacity);
   ArrayCopy(m_drawnObjects[liveIdx].fibarcLevelWidth,   m_drawnObjects[tplIdx].fibarcLevelWidth);
   ArrayCopy(m_drawnObjects[liveIdx].fibarcLevelStyle,   m_drawnObjects[tplIdx].fibarcLevelStyle);
   ArrayCopy(m_drawnObjects[liveIdx].fibarcLevelVisible, m_drawnObjects[tplIdx].fibarcLevelVisible);
   //--- Deep-copy all Gann level arrays
   ArrayCopy(m_drawnObjects[liveIdx].gannfanLevelRatio,   m_drawnObjects[tplIdx].gannfanLevelRatio);
   ArrayCopy(m_drawnObjects[liveIdx].gannfanLevelColor,   m_drawnObjects[tplIdx].gannfanLevelColor);
   ArrayCopy(m_drawnObjects[liveIdx].gannfanLevelOpacity, m_drawnObjects[tplIdx].gannfanLevelOpacity);
   ArrayCopy(m_drawnObjects[liveIdx].gannfanLevelWidth,   m_drawnObjects[tplIdx].gannfanLevelWidth);
   ArrayCopy(m_drawnObjects[liveIdx].gannfanLevelStyle,   m_drawnObjects[tplIdx].gannfanLevelStyle);
   ArrayCopy(m_drawnObjects[liveIdx].gannfanLevelVisible, m_drawnObjects[tplIdx].gannfanLevelVisible);
   ArrayCopy(m_drawnObjects[liveIdx].gannboxLevelRatio,   m_drawnObjects[tplIdx].gannboxLevelRatio);
   ArrayCopy(m_drawnObjects[liveIdx].gannboxLevelColor,   m_drawnObjects[tplIdx].gannboxLevelColor);
   ArrayCopy(m_drawnObjects[liveIdx].gannboxLevelOpacity, m_drawnObjects[tplIdx].gannboxLevelOpacity);
   ArrayCopy(m_drawnObjects[liveIdx].gannboxLevelWidth,   m_drawnObjects[tplIdx].gannboxLevelWidth);
   ArrayCopy(m_drawnObjects[liveIdx].gannboxLevelStyle,   m_drawnObjects[tplIdx].gannboxLevelStyle);
   ArrayCopy(m_drawnObjects[liveIdx].gannboxLevelVisible, m_drawnObjects[tplIdx].gannboxLevelVisible);
   //--- Restore identity + geometry + selection state (template only contributes style, not these)
   m_drawnObjects[liveIdx].id        = savedId;
   m_drawnObjects[liveIdx].toolType  = savedToolType;
   m_drawnObjects[liveIdx].time1     = savedT1;
   m_drawnObjects[liveIdx].price1    = savedP1;
   m_drawnObjects[liveIdx].time2     = savedT2;
   m_drawnObjects[liveIdx].price2    = savedP2;
   m_drawnObjects[liveIdx].time3     = savedT3;
   m_drawnObjects[liveIdx].price3    = savedP3;
   m_drawnObjects[liveIdx].selected  = savedSelected;
   m_drawnObjects[liveIdx].visible   = savedVisible;
   m_drawnObjects[liveIdx].labelText = savedLabelText;
   ArrayCopy(m_drawnObjects[liveIdx].pathTimes,  savedPathTimes);
   ArrayCopy(m_drawnObjects[liveIdx].pathPrices, savedPathPrices);
   //--- Discard the throwaway template + re-render the canvas
   RemoveDrawnObject(tplId);
   RedrawAllObjects();
  }

//+------------------------------------------------------------------+
//| Capture an object's current style into the per-tool memory slot  |
//+------------------------------------------------------------------+
void CDrawingEngine::CaptureToolMemory(int liveIdx)
  {
   //--- Bounds-check the index against the live object array
   if(liveIdx < 0 || liveIdx >= ArraySize(m_drawnObjects)) return;
   //--- Resolve the object's tool type and its memory slot
   const TOOL_TYPE tt = m_drawnObjects[liveIdx].toolType;
   const int slot = (int)tt;
   if(slot < 0 || slot >= 64) return;
   //--- Bulk-copy the live object into the memory slot
   m_toolMemory[slot] = m_drawnObjects[liveIdx];
   //--- Deep-copy all Fibonacci level arrays
   ArrayCopy(m_toolMemory[slot].fiboLevelRatio,    m_drawnObjects[liveIdx].fiboLevelRatio);
   ArrayCopy(m_toolMemory[slot].fiboLevelColor,    m_drawnObjects[liveIdx].fiboLevelColor);
   ArrayCopy(m_toolMemory[slot].fiboLevelOpacity,  m_drawnObjects[liveIdx].fiboLevelOpacity);
   ArrayCopy(m_toolMemory[slot].fiboLevelWidth,    m_drawnObjects[liveIdx].fiboLevelWidth);
   ArrayCopy(m_toolMemory[slot].fiboLevelStyle,    m_drawnObjects[liveIdx].fiboLevelStyle);
   ArrayCopy(m_toolMemory[slot].fiboLevelVisible,  m_drawnObjects[liveIdx].fiboLevelVisible);
   ArrayCopy(m_toolMemory[slot].fibexLevelRatio,   m_drawnObjects[liveIdx].fibexLevelRatio);
   ArrayCopy(m_toolMemory[slot].fibexLevelColor,   m_drawnObjects[liveIdx].fibexLevelColor);
   ArrayCopy(m_toolMemory[slot].fibexLevelOpacity, m_drawnObjects[liveIdx].fibexLevelOpacity);
   ArrayCopy(m_toolMemory[slot].fibexLevelWidth,   m_drawnObjects[liveIdx].fibexLevelWidth);
   ArrayCopy(m_toolMemory[slot].fibexLevelStyle,   m_drawnObjects[liveIdx].fibexLevelStyle);
   ArrayCopy(m_toolMemory[slot].fibexLevelVisible, m_drawnObjects[liveIdx].fibexLevelVisible);
   ArrayCopy(m_toolMemory[slot].fibchLevelRatio,   m_drawnObjects[liveIdx].fibchLevelRatio);
   ArrayCopy(m_toolMemory[slot].fibchLevelColor,   m_drawnObjects[liveIdx].fibchLevelColor);
   ArrayCopy(m_toolMemory[slot].fibchLevelOpacity, m_drawnObjects[liveIdx].fibchLevelOpacity);
   ArrayCopy(m_toolMemory[slot].fibchLevelWidth,   m_drawnObjects[liveIdx].fibchLevelWidth);
   ArrayCopy(m_toolMemory[slot].fibchLevelStyle,   m_drawnObjects[liveIdx].fibchLevelStyle);
   ArrayCopy(m_toolMemory[slot].fibchLevelVisible, m_drawnObjects[liveIdx].fibchLevelVisible);
   ArrayCopy(m_toolMemory[slot].fibtzLevelRatio,   m_drawnObjects[liveIdx].fibtzLevelRatio);
   ArrayCopy(m_toolMemory[slot].fibtzLevelColor,   m_drawnObjects[liveIdx].fibtzLevelColor);
   ArrayCopy(m_toolMemory[slot].fibtzLevelOpacity, m_drawnObjects[liveIdx].fibtzLevelOpacity);
   ArrayCopy(m_toolMemory[slot].fibtzLevelWidth,   m_drawnObjects[liveIdx].fibtzLevelWidth);
   ArrayCopy(m_toolMemory[slot].fibtzLevelStyle,   m_drawnObjects[liveIdx].fibtzLevelStyle);
   ArrayCopy(m_toolMemory[slot].fibtzLevelVisible, m_drawnObjects[liveIdx].fibtzLevelVisible);
   ArrayCopy(m_toolMemory[slot].fibfanLevelRatio,   m_drawnObjects[liveIdx].fibfanLevelRatio);
   ArrayCopy(m_toolMemory[slot].fibfanLevelColor,   m_drawnObjects[liveIdx].fibfanLevelColor);
   ArrayCopy(m_toolMemory[slot].fibfanLevelOpacity, m_drawnObjects[liveIdx].fibfanLevelOpacity);
   ArrayCopy(m_toolMemory[slot].fibfanLevelWidth,   m_drawnObjects[liveIdx].fibfanLevelWidth);
   ArrayCopy(m_toolMemory[slot].fibfanLevelStyle,   m_drawnObjects[liveIdx].fibfanLevelStyle);
   ArrayCopy(m_toolMemory[slot].fibfanLevelVisible, m_drawnObjects[liveIdx].fibfanLevelVisible);
   ArrayCopy(m_toolMemory[slot].fibarcLevelRatio,   m_drawnObjects[liveIdx].fibarcLevelRatio);
   ArrayCopy(m_toolMemory[slot].fibarcLevelColor,   m_drawnObjects[liveIdx].fibarcLevelColor);
   ArrayCopy(m_toolMemory[slot].fibarcLevelOpacity, m_drawnObjects[liveIdx].fibarcLevelOpacity);
   ArrayCopy(m_toolMemory[slot].fibarcLevelWidth,   m_drawnObjects[liveIdx].fibarcLevelWidth);
   ArrayCopy(m_toolMemory[slot].fibarcLevelStyle,   m_drawnObjects[liveIdx].fibarcLevelStyle);
   ArrayCopy(m_toolMemory[slot].fibarcLevelVisible, m_drawnObjects[liveIdx].fibarcLevelVisible);
   //--- Deep-copy all Gann level arrays
   ArrayCopy(m_toolMemory[slot].gannfanLevelRatio,   m_drawnObjects[liveIdx].gannfanLevelRatio);
   ArrayCopy(m_toolMemory[slot].gannfanLevelColor,   m_drawnObjects[liveIdx].gannfanLevelColor);
   ArrayCopy(m_toolMemory[slot].gannfanLevelOpacity, m_drawnObjects[liveIdx].gannfanLevelOpacity);
   ArrayCopy(m_toolMemory[slot].gannfanLevelWidth,   m_drawnObjects[liveIdx].gannfanLevelWidth);
   ArrayCopy(m_toolMemory[slot].gannfanLevelStyle,   m_drawnObjects[liveIdx].gannfanLevelStyle);
   ArrayCopy(m_toolMemory[slot].gannfanLevelVisible, m_drawnObjects[liveIdx].gannfanLevelVisible);
   ArrayCopy(m_toolMemory[slot].gannboxLevelRatio,   m_drawnObjects[liveIdx].gannboxLevelRatio);
   ArrayCopy(m_toolMemory[slot].gannboxLevelColor,   m_drawnObjects[liveIdx].gannboxLevelColor);
   ArrayCopy(m_toolMemory[slot].gannboxLevelOpacity, m_drawnObjects[liveIdx].gannboxLevelOpacity);
   ArrayCopy(m_toolMemory[slot].gannboxLevelWidth,   m_drawnObjects[liveIdx].gannboxLevelWidth);
   ArrayCopy(m_toolMemory[slot].gannboxLevelStyle,   m_drawnObjects[liveIdx].gannboxLevelStyle);
   ArrayCopy(m_toolMemory[slot].gannboxLevelVisible, m_drawnObjects[liveIdx].gannboxLevelVisible);
   //--- Flag the slot as valid (ApplyToolMemory checks this before applying)
   m_toolMemoryValid[slot] = true;
  }

//+------------------------------------------------------------------+
//| Build a unique chart-object name for a new drawing               |
//+------------------------------------------------------------------+
string CDrawingEngine::MakeUniqueObjectName()
  {
   //--- Bump the counter and assemble a name that's unique across time + draw history
   m_drawnObjectCounter++;
   return "ToolsPalette_Drawing_" + IntegerToString(m_drawnObjectCounter) + "_" + IntegerToString((int)TimeCurrent());
  }

//+------------------------------------------------------------------+
//| Select an object by ID + clear previous selection                |
//+------------------------------------------------------------------+
void CDrawingEngine::SelectObjectById(int objId)
  {
   //--- Clear the previous selection's .selected flag (no-op if same object or no prior selection)
   if(m_selectedObjectId >= 0 && m_selectedObjectId != objId)
     {
      int prevIdx = FindObjectIndexById(m_selectedObjectId);
      if(prevIdx >= 0) m_drawnObjects[prevIdx].selected = false;
     }
   //--- Stash the new selection ID
   m_selectedObjectId = objId;
   //--- Mark the new object as selected (negative IDs are sentinel "no selection" values)
   if(objId >= 0)
     {
      int newIdx = FindObjectIndexById(objId);
      if(newIdx >= 0) m_drawnObjects[newIdx].selected = true;
     }
   //--- Notify the ribbon about the selection change (drives property pane refresh in Part 8)
   OnSelectionChanged(objId);
  }

//+------------------------------------------------------------------+
//| Commit the in-progress path (N-point polyline) as a real object  |
//+------------------------------------------------------------------+
void CDrawingEngine::CommitPath(TOOL_TYPE &activeTool, string &instruction)
  {
   //--- Need at least 2 points to commit; smaller commits silently degrade to a tool reset
   int nPts = ArraySize(m_pathBuildTimes);
   if(nPts >= 2)
     {
      //--- Use the default tool color + the first 2 anchors as P1/P2 (the rest go into pathTimes/pathPrices)
      color objColor = GetToolDefaultColor(TOOL_PATH);
      datetime t1 = m_pathBuildTimes[0];
      double   p1 = m_pathBuildPrices[0];
      datetime t2 = m_pathBuildTimes[1];
      double   p2 = m_pathBuildPrices[1];
      int id = AddDrawnObject(TOOL_PATH, t1, p1, t2, p2, 0, 0.0, objColor);
      //--- Copy the full N-point path into the freshly-added object
      int sz = ArraySize(m_drawnObjects);
      if(sz > 0)
        {
         ArrayResize(m_drawnObjects[sz - 1].pathTimes,  nPts);
         ArrayResize(m_drawnObjects[sz - 1].pathPrices, nPts);
         for(int i = 0; i < nPts; i++)
           {
            m_drawnObjects[sz - 1].pathTimes[i]  = m_pathBuildTimes[i];
            m_drawnObjects[sz - 1].pathPrices[i] = m_pathBuildPrices[i];
           }
         //--- Auto-select the newly committed path object (SelectObjectById clears any previous selection)
         SelectObjectById(m_drawnObjects[sz - 1].id);
        }
     }
   //--- Reset the path accumulator + tool state regardless of whether commit happened
   ArrayResize(m_pathBuildTimes,  0);
   ArrayResize(m_pathBuildPrices, 0);
   m_toolDrawingClickCount = 0;
   m_isPreviewActive       = false;
   activeTool = TOOL_NONE; instruction = "";
   //--- Push a final redraw so the committed path appears + any preview state clears
   RedrawAllObjects();
  }

//+------------------------------------------------------------------+
//| Cancel the in-progress path (no commit, just discard accumulator)|
//+------------------------------------------------------------------+
void CDrawingEngine::CancelPath()
  {
   //--- Truncate the accumulator + reset the click counter + preview flag
   ArrayResize(m_pathBuildTimes,  0);
   ArrayResize(m_pathBuildPrices, 0);
   m_toolDrawingClickCount = 0;
   m_isPreviewActive       = false;
   //--- Push a redraw to clear any preview state from the canvas
   RedrawAllObjects();
  }

//+------------------------------------------------------------------+
//| Place a single-click object at the given time/price coordinates  |
//+------------------------------------------------------------------+
void CDrawingEngine::PlaceSingleClickObject(datetime t, double p, int sub, TOOL_TYPE toolType)
  {
   //--- Resolve the default color + add the object + redraw the canvas
   color objColor = GetToolDefaultColor(toolType);
   AddDrawnObject(toolType, t, p, 0, 0.0, 0, 0.0, objColor);
   RedrawAllObjects();
  }

//+------------------------------------------------------------------+
//| Place a two-click object using the captured P1+P2 anchors        |
//+------------------------------------------------------------------+
void CDrawingEngine::PlaceTwoClickObject(TOOL_TYPE toolType)
  {
   //--- Resolve the default color and stage the click-captured anchor points
   color objColor = GetToolDefaultColor(toolType);
   datetime storeT1 = m_drawPoint1Time;
   datetime storeT2 = m_drawPoint2Time;
   double   storeP1 = m_drawPoint1Price;
   double   storeP2 = m_drawPoint2Price;
   //--- Regression channel: clamp anchor times to the latest bar + compute regression endpoints
   if(toolType == TOOL_REGRESSION_CHANNEL)
     {
      //--- Cap anchor times at the latest bar (can't regress into the future)
      datetime tMaxBar = (datetime)iTime(_Symbol, _Period, 0);
      if(storeT1 > tMaxBar) storeT1 = tMaxBar;
      if(storeT2 > tMaxBar) storeT2 = tMaxBar;
      //--- Compute the regression line's endpoints (inherited from CChannelTools)
      double lp = 0, rp = 0;
      if(ComputeRegressionEndpoints(storeT1, storeT2, lp, rp))
        {
         storeP1 = lp;
         storeP2 = rp;
        }
     }
   //--- StdDev channel: same regression endpoint computation as TOOL_REGRESSION_CHANNEL
   if(toolType == TOOL_STDDEV_CHANNEL)
     {
      datetime tMaxBar = (datetime)iTime(_Symbol, _Period, 0);
      if(storeT1 > tMaxBar) storeT1 = tMaxBar;
      if(storeT2 > tMaxBar) storeT2 = tMaxBar;
      double lp = 0, rp = 0;
      if(ComputeRegressionEndpoints(storeT1, storeT2, lp, rp))
        {
         storeP1 = lp;
         storeP2 = rp;
        }
     }
   //--- Add the object using the (potentially adjusted) anchor points + redraw
   AddDrawnObject(toolType, storeT1, storeP1,
                             storeT2, storeP2,
                             0, 0.0, objColor);
   RedrawAllObjects();
  }

//+------------------------------------------------------------------+
//| Place a three-click object using P1+P2+P3 anchors                |
//+------------------------------------------------------------------+
void CDrawingEngine::PlaceThreeClickObject(datetime t3, double p3, TOOL_TYPE toolType)
  {
   //--- Resolve the default color + stage P3 (may be re-derived for some tools)
   color objColor = GetToolDefaultColor(toolType);
   datetime t3_store = t3;
   double   p3_store = p3;
   //--- Parallel channel: re-derive P3 as an offset price at P1's time (parallel-to-P1P2 trend)
   if(toolType == TOOL_PARALLEL_CHANNEL)
     {
      double offsetP;
      //--- Time delta between P1 and P2 (used to project trend price at P3's time)
      long dtAB = (long)m_drawPoint2Time - (long)m_drawPoint1Time;
      if(dtAB != 0)
        {
         //--- Linear interpolation: project trend price at t3, then offset = (p3 - trendP)
         double tt = (double)((long)t3 - (long)m_drawPoint1Time) / (double)dtAB;
         double trendP = m_drawPoint1Price + tt * (m_drawPoint2Price - m_drawPoint1Price);
         offsetP = p3 - trendP;
        }
      else
        {
         //--- Degenerate case (P1.time == P2.time): use plain price offset
         offsetP = p3 - m_drawPoint1Price;
        }
      //--- Store P3 at P1's time + the computed offset
      t3_store = m_drawPoint1Time;
      p3_store = m_drawPoint1Price + offsetP;
     }
   //--- Stage P1 + P2 for storage (may be re-derived for the rotated-rectangle case)
   datetime t1_store = m_drawPoint1Time;
   double   p1_store = m_drawPoint1Price;
   datetime t2_store = m_drawPoint2Time;
   double   p2_store = m_drawPoint2Price;
   //--- Rotated rectangle: shift P1 + P2 to the rectangle's midline (so P3 controls perpendicular width)
   if(toolType == TOOL_ROTATED_RECTANGLE)
     {
      //--- Convert the 3 anchor points to pixel coords for the geometry math
      int sP1x=0, sP1y=0, sP2x=0, sP2y=0, sP3x=0, sP3y=0;
      ChartTimePriceToXY(m_chartId, 0, m_drawPoint1Time, m_drawPoint1Price, sP1x, sP1y);
      ChartTimePriceToXY(m_chartId, 0, m_drawPoint2Time, m_drawPoint2Price, sP2x, sP2y);
      ChartTimePriceToXY(m_chartId, 0, t3,               p3,               sP3x, sP3y);
      //--- Direction vector B = P2 - P1
      double dxB = (double)(sP2x - sP1x);
      double dyB = (double)(sP2y - sP1y);
      double lenB = MathSqrt(dxB * dxB + dyB * dyB);
      //--- Defensive: skip the shift if P1==P2 (zero-length base)
      if(lenB >= 2.0)
        {
         //--- Unit vector along base + perpendicular (rotated 90 deg)
         double ux = dxB / lenB;
         double uy = dyB / lenB;
         double vx = -uy;
         double vy =  ux;
         //--- Project P3 onto the perpendicular to find the rectangle's half-width
         double perpSide = ((double)sP3x - (double)sP1x) * vx + ((double)sP3y - (double)sP1y) * vy;
         double shift = perpSide * 0.5;
         //--- Shift P1 and P2 to the midline (so the rectangle's center axis is on the click line)
         int midP1x = (int)MathRound((double)sP1x + shift * vx);
         int midP1y = (int)MathRound((double)sP1y + shift * vy);
         int midP2x = (int)MathRound((double)sP2x + shift * vx);
         int midP2y = (int)MathRound((double)sP2y + shift * vy);
         //--- Convert the shifted pixel coords back to time + price
         datetime nt1, nt2; double np1, np2; int subs;
         if(ChartXYToTimePrice(m_chartId, midP1x, midP1y, subs, nt1, np1)) { t1_store = nt1; p1_store = np1; }
         if(ChartXYToTimePrice(m_chartId, midP2x, midP2y, subs, nt2, np2)) { t2_store = nt2; p2_store = np2; }
        }
     }
   //--- Add the object using the (potentially adjusted) anchor points + redraw
   AddDrawnObject(toolType, t1_store, p1_store,
                             t2_store, p2_store,
                             t3_store, p3_store, objColor);
   RedrawAllObjects();
  }

//+------------------------------------------------------------------+
//| Dispatch a chart click to the active tool's placement logic      |
//+------------------------------------------------------------------+
void CDrawingEngine::HandleDrawingClick(int mouseX, int mouseY, TOOL_TYPE &activeTool, string &instruction)
  {
   //--- Convert the pixel click into time + price coords; bail if conversion fails
   datetime barTime; double barPrice; int sub;
   if(!ChartXYToTimePrice(m_chartId, mouseX, mouseY, sub, barTime, barPrice)) return;
   //--- PATH tool: variable-N polyline accumulator (double-click within 500ms commits)
   if(activeTool == TOOL_PATH)
     {
      //--- Measure click position + time delta vs the previous click
      ulong  nowMicros = GetMicrosecondCount();
      int    dx = mouseX - m_pathLastClickX;
      int    dy = mouseY - m_pathLastClickY;
      //--- Position-close test: within 6 px of the previous click (squared distance check)
      bool   positionClose = (dx * dx + dy * dy) <= (6 * 6);
      //--- Double-click test: within 500ms AND position-close
      bool   isDoubleClick = (m_pathLastClickMicros != 0 &&
                               nowMicros - m_pathLastClickMicros < 500000 &&
                               positionClose);
      //--- Path needs at least 2 points to be committable
      int    nPts = ArraySize(m_pathBuildTimes);
      //--- Commit path on double-click (when we have enough points)
      if(isDoubleClick && nPts >= 2)
        {
         m_pathLastClickMicros = 0;
         CommitPath(activeTool, instruction);
         return;
        }
      //--- Single click: append a new point to the accumulator
      ArrayResize(m_pathBuildTimes,  nPts + 1);
      ArrayResize(m_pathBuildPrices, nPts + 1);
      m_pathBuildTimes[nPts]  = barTime;
      m_pathBuildPrices[nPts] = barPrice;
      //--- Activate preview state so the canvas shows a rubber-band from the last point to the mouse
      m_isPreviewActive  = true;
      m_previewToolType  = TOOL_PATH;
      m_previewMouseX    = mouseX;
      m_previewMouseY    = mouseY;
      m_toolDrawingClickCount = nPts + 1;
      //--- Remember this click's time + position for the next double-click test
      m_pathLastClickMicros = nowMicros;
      m_pathLastClickX      = mouseX;
      m_pathLastClickY      = mouseY;
      instruction = "Click to add points. Double-click to finish.";
      RedrawAllObjects();
      return;
     }
   //--- TEXT / COMMENT: single-click drops empty box + immediately enters label-edit mode
   if(activeTool == TOOL_TEXT || activeTool == TOOL_COMMENT)
     {
      PlaceSingleClickObject(barTime, barPrice, sub, activeTool);
      //--- Auto-select the freshly-placed object + start label editing
      int nObjs = ArraySize(m_drawnObjects);
      if(nObjs > 0)
        {
         SelectObjectById(m_drawnObjects[nObjs - 1].id);
         StartLabelEdit();
        }
      //--- Reset tool state - placement is complete
      m_toolDrawingClickCount = 0;
      m_isPreviewActive       = false;
      activeTool = TOOL_NONE;
      instruction = "";
      RedrawAllObjects();
      return;
     }
   //--- Resolve click-count needed for the active tool; bail if zero (cursor mode)
   int clicksNeeded = GetRequiredClickCount(activeTool);
   if(clicksNeeded <= 0) return;
   //--- Increment the click counter + dispatch based on which click this is
   m_toolDrawingClickCount++;
   //--- CLICK 1: stash P1; for 1-click tools, place immediately and exit
   if(m_toolDrawingClickCount == 1)
     {
      m_drawPoint1Time  = barTime;
      m_drawPoint1Price = barPrice;
      //--- 1-click tool: place + auto-select + reset state
      if(clicksNeeded == 1)
        {
         PlaceSingleClickObject(barTime, barPrice, sub, activeTool);
         //--- Auto-select on placement (SelectObjectById clears any previous selection)
         int nObjs = ArraySize(m_drawnObjects);
         if(nObjs > 0)
            SelectObjectById(m_drawnObjects[nObjs - 1].id);
         m_toolDrawingClickCount = 0;
         m_isPreviewActive       = false;
         activeTool = TOOL_NONE; instruction = "";
        }
      else
        {
         //--- 2+ click tool: activate preview rubber-band + prompt for P2
         m_isPreviewActive  = true;
         m_previewToolType  = activeTool;
         m_previewMouseX    = mouseX;
         m_previewMouseY    = mouseY;
         instruction = "Click second point for " + GetToolLabel(activeTool) + ".";
         RedrawAllObjects();
        }
     }
   //--- CLICK 2: stash P2; for 2-click tools, place; for 3-click tools, prompt for P3
   else if(m_toolDrawingClickCount == 2)
     {
      m_drawPoint2Time  = barTime;
      m_drawPoint2Price = barPrice;
      //--- 2-click tool: place + auto-select + reset state
      if(clicksNeeded == 2)
        {
         PlaceTwoClickObject(activeTool);
         //--- Auto-select on placement (SelectObjectById clears any previous selection)
         int nObjs = ArraySize(m_drawnObjects);
         if(nObjs > 0)
           {
            SelectObjectById(m_drawnObjects[nObjs - 1].id);
            //--- Note and Callout auto-enter edit mode on placement (label-bearing annotations)
            if(activeTool == TOOL_NOTE || activeTool == TOOL_CALLOUT)
               StartLabelEdit();
           }
         m_toolDrawingClickCount = 0;
         m_isPreviewActive       = false;
         activeTool = TOOL_NONE; instruction = "";
        }
      else
        {
         //--- 3-click tool: prompt for P3 (preview rubber-band stays active)
         instruction = "Click third point for " + GetToolLabel(activeTool) + ".";
         RedrawAllObjects();
        }
     }
   //--- CLICK 3: 3-click tool placement (PlaceThreeClickObject + auto-select + reset)
   else if(m_toolDrawingClickCount == 3)
     {
      PlaceThreeClickObject(barTime, barPrice, activeTool);
      //--- Auto-select on placement (SelectObjectById clears any previous selection)
      int nObjs = ArraySize(m_drawnObjects);
      if(nObjs > 0)
         SelectObjectById(m_drawnObjects[nObjs - 1].id);
      m_toolDrawingClickCount = 0;
      m_isPreviewActive       = false;
      activeTool = TOOL_NONE; instruction = "";
     }
  }

//+------------------------------------------------------------------+
//| Update the cached preview-mode mouse position (for rubber-band)  |
//+------------------------------------------------------------------+
void CDrawingEngine::UpdatePreviewMousePos(int mouseX, int mouseY)
  {
   //--- Simple setter (Engine_Render reads these to draw the rubber-band preview)
   m_previewMouseX = mouseX;
   m_previewMouseY = mouseY;
  }

//+------------------------------------------------------------------+
//| Draw a dashed rubber-band line between two points + end handles  |
//+------------------------------------------------------------------+
void CDrawingEngine::DrawRubberBand(int x1, int y1, int x2, int y2,
                                     TOOL_TYPE toolType, color objColor)
  {
   //--- Semi-transparent line color (180/255 alpha) for the rubber-band appearance
   uint argb = ColorToARGB(objColor, 180);
   //--- Compute the line length in pixels
   double dx = x2 - x1, dy = y2 - y1;
   double len = MathSqrt(dx*dx + dy*dy);
   if(len < 1) return;
   //--- Walk the line in 1-px steps + render every other 4-px segment (dashed pattern)
   int steps = (int)len;
   for(int s = 0; s < steps; s++)
     {
      //--- 4-on/4-off dash pattern (skip when modulo 8 is in the 4-7 range)
      if(s % 8 >= 4) continue;
      int px = x1 + (int)(dx * s / steps);
      int py = y1 + (int)(dy * s / steps);
      //--- Bounds-check + blend the pixel onto the canvas
      if(px >= 0 && px < m_canvasDrawings.Width() &&
         py >= 0 && py < m_canvasDrawings.Height())
         BlendPixelSet(m_canvasDrawings, px, py, argb);
     }
   //--- Draw handle markers at both endpoints (small filled circles)
   DrawHandleOnCanvas(m_canvasDrawings, x1, y1, false, objColor);
   DrawHandleOnCanvas(m_canvasDrawings, x2, y2, false, objColor);
  }

//+------------------------------------------------------------------+
//| Finalize an open label-edit session (commit or discard the text) |
//+------------------------------------------------------------------+
bool CDrawingEngine::FinalizeOpenLabelEdit()
  {
   //--- No edit session active means nothing to finalize
   if(!m_isEditingLabel) return false;
   //--- Resolve whether the selected object is a text-bearing annotation (TEXT/NOTE/CALLOUT/COMMENT)
   int editIdx = FindObjectIndexById(m_selectedObjectId);
   bool isTextAnnot = (editIdx >= 0 &&
                       (m_drawnObjects[editIdx].toolType == TOOL_TEXT ||
                        m_drawnObjects[editIdx].toolType == TOOL_NOTE ||
                        m_drawnObjects[editIdx].toolType == TOOL_CALLOUT ||
                        m_drawnObjects[editIdx].toolType == TOOL_COMMENT));
   bool bufferEmpty = (StringLen(m_labelEditBuffer) == 0);
   //--- Empty text annotations get discarded entirely (no point keeping a blank label)
   if(isTextAnnot && bufferEmpty)
     {
      int discardId = (editIdx >= 0) ? m_drawnObjects[editIdx].id : -1;
      CancelLabel();
      if(discardId > 0)
         RemoveDrawnObject(discardId);
     }
   else
     {
      //--- Non-empty (or non-text-annot): commit the label edit buffer to the object
      CommitLabel();
     }
   return true;
  }

//+------------------------------------------------------------------+
//| Cancel any in-progress placement (preview state + click counter) |
//+------------------------------------------------------------------+
bool CDrawingEngine::CancelInProgressPlacement()
  {
   //--- Track whether a redraw is needed to clear the preview state
   bool needsRedraw = false;
   //--- Cancel the preview rubber-band; special-case PATH to also clear its accumulator
   if(m_isPreviewActive)
     {
      if(m_previewToolType == TOOL_PATH)
         CancelPath();
      m_isPreviewActive = false;
      needsRedraw = true;
     }
   //--- Reset the click counter (cleanly aborts multi-click placement sequences)
   if(m_toolDrawingClickCount != 0)
     {
      m_toolDrawingClickCount = 0;
      needsRedraw = true;
     }
   return needsRedraw;
  }

//+------------------------------------------------------------------+
//| Deselect everything: selection, hover, drag, text-edit prompt    |
//+------------------------------------------------------------------+
bool CDrawingEngine::DeselectAll()
  {
   //--- Track whether a redraw is needed + whether selection actually changed (drives OnSelectionChanged)
   bool needsRedraw = false;
   bool selectionDidChange = false;
   //--- Clear the selection state (selected.id + the object's .selected flag)
   if(m_selectedObjectId >= 0)
     {
      int idx = FindObjectIndexById(m_selectedObjectId);
      if(idx >= 0) m_drawnObjects[idx].selected = false;
      m_selectedObjectId = -1;
      needsRedraw = true;
      selectionDidChange = true;
     }
   //--- Clear hover state
   if(m_hoveredObjectId >= 0)
     {
      m_hoveredObjectId = -1;
      needsRedraw = true;
     }
   //--- Clear handle-hover state
   if(m_hoveredHandleIdx >= 0 || m_hoveredHandleHostId >= 0)
     {
      m_hoveredHandleIdx    = -1;
      m_hoveredHandleHostId = -1;
      needsRedraw = true;
     }
   //--- Clear pending text-edit arm (no redraw needed; it's just an internal flag)
   if(m_pendingTextEditArmed)
     {
      m_pendingTextEditArmed = false;
      m_pendingTextEditObjId = -1;
     }
   //--- Clear active drag state (object drag or handle drag)
   if(m_isDraggingObject || m_isDraggingHandle)
     {
      m_isDraggingObject = false;
      m_isDraggingHandle = false;
      needsRedraw = true;
     }
   //--- Notify the ribbon about selection loss (only if there was a real selection to lose)
   if(selectionDidChange) OnSelectionChanged(-1);
   return needsRedraw;
  }

//--- Pull in the CDrawingEngine implementation files (Edit / Interact / Render / Properties)
#include "../engine/ToolsPalette_Engine_Edit.mqh"
#include "../engine/ToolsPalette_Engine_Interact.mqh"
#include "../engine/ToolsPalette_Engine_Render.mqh"
#include "../engine/ToolsPalette_Engine_Properties.mqh"

//--- Drawing persistence methods (defined after the class is fully declared)
#include "..\storage\ToolsPalette_Storage.mqh"

#endif // TOOLS_PALETTE_TOOLS_MQH
//+------------------------------------------------------------------+
