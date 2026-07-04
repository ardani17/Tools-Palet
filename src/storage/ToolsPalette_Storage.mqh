//+------------------------------------------------------------------+
//|                              ToolsPalette_Storage.mqh            |
//|  Per-chart drawing persistence: versioned tagged-text serializer |
//+------------------------------------------------------------------+
#ifndef TOOLS_PALETTE_STORAGE_MQH
#define TOOLS_PALETTE_STORAGE_MQH

//--- On-disk schema version (bump only on incompatible format changes)
#define TP_DRAW_SCHEMA_VERSION 1

//+------------------------------------------------------------------+
//| Per-chart file path: ToolsPalette\drawings\<Symbol>_<ChartID>   |
//+------------------------------------------------------------------+
string CDrawingEngine::DrawingsFilePath()
  {
   return "ToolsPalette\\drawings\\" + _Symbol + "_" +
          IntegerToString((long)ChartID()) + ".dat";
  }

//+------------------------------------------------------------------+
//| Mark the store dirty + stamp the change time (debounce input)    |
//+------------------------------------------------------------------+
void CDrawingEngine::MarkDrawingsDirty()
  {
   m_drawingsDirty     = true;
   m_drawingsDirtyTick = GetTickCount();
  }

//--- Escape newlines/CR so a labelText never breaks the one-line format
string TP_Escape(string s)
  {
   StringReplace(s, "\\", "\\\\");
   StringReplace(s, "\r", "\\r");
   StringReplace(s, "\n", "\\n");
   return s;
  }
string TP_Unescape(string s)
  {
   StringReplace(s, "\\n", "\n");
   StringReplace(s, "\\r", "\r");
   StringReplace(s, "\\\\", "\\");
   return s;
  }

//--- Comma-join helpers for the parallel level-arrays
string TP_JoinDouble(const double &a[])
  {
   string out=""; int n=ArraySize(a);
   for(int i=0;i<n;i++){ if(i>0) out+=","; out+=DoubleToString(a[i],8); }
   return out;
  }
string TP_JoinInt(const int &a[])
  {
   string out=""; int n=ArraySize(a);
   for(int i=0;i<n;i++){ if(i>0) out+=","; out+=IntegerToString(a[i]); }
   return out;
  }
string TP_JoinColor(const color &a[])
  {
   string out=""; int n=ArraySize(a);
   for(int i=0;i<n;i++){ if(i>0) out+=","; out+=IntegerToString((int)a[i]); }
   return out;
  }
string TP_JoinBool(const bool &a[])
  {
   string out=""; int n=ArraySize(a);
   for(int i=0;i<n;i++){ if(i>0) out+=","; out+=(a[i]?"1":"0"); }
   return out;
  }

//--- Split a comma list into typed arrays (empty string -> size 0)
void TP_SplitDouble(string s, double &out[])
  {
   ArrayResize(out,0);
   if(StringLen(s)==0) return;
   string parts[]; int n=StringSplit(s, (ushort)',', parts);
   ArrayResize(out,n);
   for(int i=0;i<n;i++) out[i]=StringToDouble(parts[i]);
  }
void TP_SplitInt(string s, int &out[])
  {
   ArrayResize(out,0);
   if(StringLen(s)==0) return;
   string parts[]; int n=StringSplit(s, (ushort)',', parts);
   ArrayResize(out,n);
   for(int i=0;i<n;i++) out[i]=(int)StringToInteger(parts[i]);
  }
void TP_SplitColor(string s, color &out[])
  {
   ArrayResize(out,0);
   if(StringLen(s)==0) return;
   string parts[]; int n=StringSplit(s, (ushort)',', parts);
   ArrayResize(out,n);
   for(int i=0;i<n;i++) out[i]=(color)StringToInteger(parts[i]);
  }
void TP_SplitBool(string s, bool &out[])
  {
   ArrayResize(out,0);
   if(StringLen(s)==0) return;
   string parts[]; int n=StringSplit(s, (ushort)',', parts);
   ArrayResize(out,n);
   for(int i=0;i<n;i++) out[i]=(parts[i]=="1");
  }

//--- Key/value lookup over a block's accumulated keys[]/vals[]
string TP_Get(const string &keys[], const string &vals[], string key, string def)
  {
   int n=ArraySize(keys);
   for(int i=0;i<n;i++) if(keys[i]==key) return vals[i];
   return def;
  }
int    TP_GetI(const string &keys[], const string &vals[], string key, int def)
  { string v=TP_Get(keys,vals,key,""); return (v=="")?def:(int)StringToInteger(v); }
long   TP_GetL(const string &keys[], const string &vals[], string key, long def)
  { string v=TP_Get(keys,vals,key,""); return (v=="")?def:(long)StringToInteger(v); }
double TP_GetD(const string &keys[], const string &vals[], string key, double def)
  { string v=TP_Get(keys,vals,key,""); return (v=="")?def:StringToDouble(v); }
color  TP_GetC(const string &keys[], const string &vals[], string key, color def)
  { string v=TP_Get(keys,vals,key,""); return (v=="")?def:(color)StringToInteger(v); }
bool   TP_GetB(const string &keys[], const string &vals[], string key, bool def)
  { string v=TP_Get(keys,vals,key,""); return (v=="")?def:(v=="1"); }

//--- Read one fibo/gann group from keys/vals into 6 parallel arrays
void TP_ReadLevelGroup(const string &keys[], const string &vals[], string prefix,
                       double &ratio[], color &col[], int &op[], int &wd[], int &st[], bool &vis[])
  {
   TP_SplitDouble(TP_Get(keys,vals,prefix+".ratio",""),   ratio);
   TP_SplitColor (TP_Get(keys,vals,prefix+".color",""),   col);
   TP_SplitInt   (TP_Get(keys,vals,prefix+".opacity",""), op);
   TP_SplitInt   (TP_Get(keys,vals,prefix+".width",""),   wd);
   TP_SplitInt   (TP_Get(keys,vals,prefix+".style",""),   st);
   TP_SplitBool  (TP_Get(keys,vals,prefix+".visible",""), vis);
  }

//--- Write one fibo/gann level group (6 parallel arrays) under a prefix
void TP_WriteLevelGroup(int h, string prefix,
                        const double &ratio[], const color &col[],
                        const int &op[], const int &wd[],
                        const int &st[], const bool &vis[])
  {
   FileWriteString(h, prefix+".n="+IntegerToString(ArraySize(ratio))+"\r\n");
   FileWriteString(h, prefix+".ratio="+TP_JoinDouble(ratio)+"\r\n");
   FileWriteString(h, prefix+".color="+TP_JoinColor(col)+"\r\n");
   FileWriteString(h, prefix+".opacity="+TP_JoinInt(op)+"\r\n");
   FileWriteString(h, prefix+".width="+TP_JoinInt(wd)+"\r\n");
   FileWriteString(h, prefix+".style="+TP_JoinInt(st)+"\r\n");
   FileWriteString(h, prefix+".visible="+TP_JoinBool(vis)+"\r\n");
  }

//--- Write every field of one DrawnObject as an [OBJ] block
void TP_WriteObject(int h, const DrawnObject &o)
  {
   FileWriteString(h, "[OBJ]\r\n");
   FileWriteString(h, "toolType="+IntegerToString((int)o.toolType)+"\r\n");
   FileWriteString(h, "id="+IntegerToString(o.id)+"\r\n");
   FileWriteString(h, "time1="+IntegerToString((long)o.time1)+"\r\n");
   FileWriteString(h, "price1="+DoubleToString(o.price1,8)+"\r\n");
   FileWriteString(h, "time2="+IntegerToString((long)o.time2)+"\r\n");
   FileWriteString(h, "price2="+DoubleToString(o.price2,8)+"\r\n");
   FileWriteString(h, "time3="+IntegerToString((long)o.time3)+"\r\n");
   FileWriteString(h, "price3="+DoubleToString(o.price3,8)+"\r\n");
   //--- N-point path arrays
   FileWriteString(h, "path.n="+IntegerToString(ArraySize(o.pathTimes))+"\r\n");
   { string t=""; int n=ArraySize(o.pathTimes);
     for(int i=0;i<n;i++){ if(i>0) t+=","; t+=IntegerToString((long)o.pathTimes[i]); }
     FileWriteString(h, "path.time="+t+"\r\n"); }
   FileWriteString(h, "path.price="+TP_JoinDouble(o.pathPrices)+"\r\n");
   //--- Core style / visibility / label
   FileWriteString(h, "objColor="+IntegerToString((int)o.objColor)+"\r\n");
   FileWriteString(h, "visible="+(o.visible?"1":"0")+"\r\n");
   FileWriteString(h, "labelText="+TP_Escape(o.labelText)+"\r\n");
   FileWriteString(h, "lineWidth="+IntegerToString(o.lineWidth)+"\r\n");
   FileWriteString(h, "lineStyle="+IntegerToString(o.lineStyle)+"\r\n");
   FileWriteString(h, "textColor="+IntegerToString((int)o.textColor)+"\r\n");
   FileWriteString(h, "lineOpacity="+IntegerToString(o.lineOpacity)+"\r\n");
   FileWriteString(h, "textOpacity="+IntegerToString(o.textOpacity)+"\r\n");
   FileWriteString(h, "fontSize="+IntegerToString(o.fontSize)+"\r\n");
   FileWriteString(h, "bold="+(o.bold?"1":"0")+"\r\n");
   FileWriteString(h, "vAlign="+IntegerToString(o.vAlign)+"\r\n");
   FileWriteString(h, "hAlign="+IntegerToString(o.hAlign)+"\r\n");
   FileWriteString(h, "fillColor="+IntegerToString((int)o.fillColor)+"\r\n");
   FileWriteString(h, "fillOpacity="+IntegerToString(o.fillOpacity)+"\r\n");
   FileWriteString(h, "midColor="+IntegerToString((int)o.midColor)+"\r\n");
   FileWriteString(h, "midOpacity="+IntegerToString(o.midOpacity)+"\r\n");
   FileWriteString(h, "fillColor2="+IntegerToString((int)o.fillColor2)+"\r\n");
   FileWriteString(h, "fillOpacity2="+IntegerToString(o.fillOpacity2)+"\r\n");
   //--- Channel midline
   FileWriteString(h, "midVisible="+(o.midVisible?"1":"0")+"\r\n");
   FileWriteString(h, "midWidth="+IntegerToString(o.midWidth)+"\r\n");
   FileWriteString(h, "midStyle="+IntegerToString(o.midStyle)+"\r\n");
   FileWriteString(h, "midOffset="+DoubleToString(o.midOffset,8)+"\r\n");
   //--- Regression centerline + bands
   FileWriteString(h, "centerVisible="+(o.centerVisible?"1":"0")+"\r\n");
   FileWriteString(h, "centerColor="+IntegerToString((int)o.centerColor)+"\r\n");
   FileWriteString(h, "centerOpacity="+IntegerToString(o.centerOpacity)+"\r\n");
   FileWriteString(h, "centerWidth="+IntegerToString(o.centerWidth)+"\r\n");
   FileWriteString(h, "centerStyle="+IntegerToString(o.centerStyle)+"\r\n");
   FileWriteString(h, "upperBandVisible="+(o.upperBandVisible?"1":"0")+"\r\n");
   FileWriteString(h, "upperBandSigma="+DoubleToString(o.upperBandSigma,8)+"\r\n");
   FileWriteString(h, "lowerBandVisible="+(o.lowerBandVisible?"1":"0")+"\r\n");
   FileWriteString(h, "lowerBandSigma="+DoubleToString(o.lowerBandSigma,8)+"\r\n");
   FileWriteString(h, "pearsonVisible="+(o.pearsonVisible?"1":"0")+"\r\n");
   //--- Fibonacci + Gann level groups
   TP_WriteLevelGroup(h,"fibo",   o.fiboLevelRatio,   o.fiboLevelColor,   o.fiboLevelOpacity,   o.fiboLevelWidth,   o.fiboLevelStyle,   o.fiboLevelVisible);
   TP_WriteLevelGroup(h,"fibex",  o.fibexLevelRatio,  o.fibexLevelColor,  o.fibexLevelOpacity,  o.fibexLevelWidth,  o.fibexLevelStyle,  o.fibexLevelVisible);
   TP_WriteLevelGroup(h,"fibch",  o.fibchLevelRatio,  o.fibchLevelColor,  o.fibchLevelOpacity,  o.fibchLevelWidth,  o.fibchLevelStyle,  o.fibchLevelVisible);
   TP_WriteLevelGroup(h,"fibtz",  o.fibtzLevelRatio,  o.fibtzLevelColor,  o.fibtzLevelOpacity,  o.fibtzLevelWidth,  o.fibtzLevelStyle,  o.fibtzLevelVisible);
   TP_WriteLevelGroup(h,"fibfan", o.fibfanLevelRatio, o.fibfanLevelColor, o.fibfanLevelOpacity, o.fibfanLevelWidth, o.fibfanLevelStyle, o.fibfanLevelVisible);
   TP_WriteLevelGroup(h,"fibarc", o.fibarcLevelRatio, o.fibarcLevelColor, o.fibarcLevelOpacity, o.fibarcLevelWidth, o.fibarcLevelStyle, o.fibarcLevelVisible);
   TP_WriteLevelGroup(h,"gannfan",o.gannfanLevelRatio,o.gannfanLevelColor,o.gannfanLevelOpacity,o.gannfanLevelWidth,o.gannfanLevelStyle,o.gannfanLevelVisible);
   TP_WriteLevelGroup(h,"gannbox",o.gannboxLevelRatio,o.gannboxLevelColor,o.gannboxLevelOpacity,o.gannboxLevelWidth,o.gannboxLevelStyle,o.gannboxLevelVisible);
   //--- Pitchfork lines
   FileWriteString(h, "medianVisible="+(o.medianVisible?"1":"0")+"\r\n");
   FileWriteString(h, "medianColor="+IntegerToString((int)o.medianColor)+"\r\n");
   FileWriteString(h, "medianWidth="+IntegerToString(o.medianWidth)+"\r\n");
   FileWriteString(h, "medianStyle="+IntegerToString(o.medianStyle)+"\r\n");
   FileWriteString(h, "outerVisible="+(o.outerVisible?"1":"0")+"\r\n");
   FileWriteString(h, "outerColor="+IntegerToString((int)o.outerColor)+"\r\n");
   FileWriteString(h, "outerWidth="+IntegerToString(o.outerWidth)+"\r\n");
   FileWriteString(h, "outerStyle="+IntegerToString(o.outerStyle)+"\r\n");
   FileWriteString(h, "innerVisible="+(o.innerVisible?"1":"0")+"\r\n");
   FileWriteString(h, "innerColor="+IntegerToString((int)o.innerColor)+"\r\n");
   FileWriteString(h, "innerWidth="+IntegerToString(o.innerWidth)+"\r\n");
   FileWriteString(h, "innerStyle="+IntegerToString(o.innerStyle)+"\r\n");
   FileWriteString(h, "[/OBJ]\r\n");
  }

//+------------------------------------------------------------------+
//| Serialize the whole store to the chart file (atomic tmp+move)    |
//+------------------------------------------------------------------+
void CDrawingEngine::SaveDrawings()
  {
   string path = DrawingsFilePath();
   string tmp  = path + ".tmp";
   int h = FileOpen(tmp, FILE_WRITE|FILE_TXT|FILE_ANSI);
   if(h == INVALID_HANDLE)
     { Print("ToolsPalette: SaveDrawings FileOpen failed for ",tmp," err=",GetLastError()); return; }
   FileWriteString(h, "TPDRAW v="+IntegerToString(TP_DRAW_SCHEMA_VERSION)+"\r\n");
   FileWriteString(h, "counter="+IntegerToString(m_drawnObjectCounter)+"\r\n");
   int n = ArraySize(m_drawnObjects);
   for(int i=0;i<n;i++) TP_WriteObject(h, m_drawnObjects[i]);
   FileClose(h);
   //--- Atomically replace the live file (avoids corruption on interrupted write)
   if(!FileMove(tmp, 0, path, FILE_REWRITE))
      Print("ToolsPalette: SaveDrawings FileMove failed err=",GetLastError());
  }

//+------------------------------------------------------------------+
//| Build one DrawnObject from a parsed block + append to the store  |
//+------------------------------------------------------------------+
void CDrawingEngine::MaterializeLoadedObject(const string &keys[], const string &vals[], int &maxId)
  {
   DrawnObject o;
   o.toolType = (TOOL_TYPE)TP_GetI(keys,vals,"toolType",0);
   o.id       = TP_GetI(keys,vals,"id",0);
   o.time1    = (datetime)TP_GetL(keys,vals,"time1",0);
   o.price1   = TP_GetD(keys,vals,"price1",0);
   o.time2    = (datetime)TP_GetL(keys,vals,"time2",0);
   o.price2   = TP_GetD(keys,vals,"price2",0);
   o.time3    = (datetime)TP_GetL(keys,vals,"time3",0);
   o.price3   = TP_GetD(keys,vals,"price3",0);
   //--- N-point path
   { string t=TP_Get(keys,vals,"path.time",""); string parts[];
     int pn=(StringLen(t)==0)?0:StringSplit(t,(ushort)',',parts);
     ArrayResize(o.pathTimes,pn);
     for(int i=0;i<pn;i++) o.pathTimes[i]=(datetime)StringToInteger(parts[i]); }
   TP_SplitDouble(TP_Get(keys,vals,"path.price",""), o.pathPrices);
   //--- Core style / visibility / label
   o.objColor    = TP_GetC(keys,vals,"objColor",clrRed);
   o.selected    = false;                       // never restore selection
   o.visible     = TP_GetB(keys,vals,"visible",true);
   o.labelText   = TP_Unescape(TP_Get(keys,vals,"labelText",""));
   o.lineWidth   = TP_GetI(keys,vals,"lineWidth",2);
   o.lineStyle   = TP_GetI(keys,vals,"lineStyle",0);
   o.textColor   = TP_GetC(keys,vals,"textColor",o.objColor);
   o.lineOpacity = TP_GetI(keys,vals,"lineOpacity",100);
   o.textOpacity = TP_GetI(keys,vals,"textOpacity",100);
   o.fontSize    = TP_GetI(keys,vals,"fontSize",11);
   o.bold        = TP_GetB(keys,vals,"bold",false);
   o.vAlign      = TP_GetI(keys,vals,"vAlign",0);
   o.hAlign      = TP_GetI(keys,vals,"hAlign",1);
   o.fillColor   = TP_GetC(keys,vals,"fillColor",o.objColor);
   o.fillOpacity = TP_GetI(keys,vals,"fillOpacity",30);
   o.midColor    = TP_GetC(keys,vals,"midColor",o.objColor);
   o.midOpacity  = TP_GetI(keys,vals,"midOpacity",80);
   o.fillColor2  = TP_GetC(keys,vals,"fillColor2",clrCrimson);
   o.fillOpacity2= TP_GetI(keys,vals,"fillOpacity2",30);
   //--- Channel midline
   o.midVisible  = TP_GetB(keys,vals,"midVisible",true);
   o.midWidth    = TP_GetI(keys,vals,"midWidth",1);
   o.midStyle    = TP_GetI(keys,vals,"midStyle",1);
   o.midOffset   = TP_GetD(keys,vals,"midOffset",0.5);
   //--- Regression centerline + bands
   o.centerVisible   = TP_GetB(keys,vals,"centerVisible",true);
   o.centerColor     = TP_GetC(keys,vals,"centerColor",o.objColor);
   o.centerOpacity   = TP_GetI(keys,vals,"centerOpacity",100);
   o.centerWidth     = TP_GetI(keys,vals,"centerWidth",2);
   o.centerStyle     = TP_GetI(keys,vals,"centerStyle",1);
   o.upperBandVisible= TP_GetB(keys,vals,"upperBandVisible",true);
   o.upperBandSigma  = TP_GetD(keys,vals,"upperBandSigma",2.0);
   o.lowerBandVisible= TP_GetB(keys,vals,"lowerBandVisible",true);
   o.lowerBandSigma  = TP_GetD(keys,vals,"lowerBandSigma",2.0);
   o.pearsonVisible  = TP_GetB(keys,vals,"pearsonVisible",true);
   //--- Fibonacci + Gann groups
   TP_ReadLevelGroup(keys,vals,"fibo",   o.fiboLevelRatio,   o.fiboLevelColor,   o.fiboLevelOpacity,   o.fiboLevelWidth,   o.fiboLevelStyle,   o.fiboLevelVisible);
   TP_ReadLevelGroup(keys,vals,"fibex",  o.fibexLevelRatio,  o.fibexLevelColor,  o.fibexLevelOpacity,  o.fibexLevelWidth,  o.fibexLevelStyle,  o.fibexLevelVisible);
   TP_ReadLevelGroup(keys,vals,"fibch",  o.fibchLevelRatio,  o.fibchLevelColor,  o.fibchLevelOpacity,  o.fibchLevelWidth,  o.fibchLevelStyle,  o.fibchLevelVisible);
   TP_ReadLevelGroup(keys,vals,"fibtz",  o.fibtzLevelRatio,  o.fibtzLevelColor,  o.fibtzLevelOpacity,  o.fibtzLevelWidth,  o.fibtzLevelStyle,  o.fibtzLevelVisible);
   TP_ReadLevelGroup(keys,vals,"fibfan", o.fibfanLevelRatio, o.fibfanLevelColor, o.fibfanLevelOpacity, o.fibfanLevelWidth, o.fibfanLevelStyle, o.fibfanLevelVisible);
   TP_ReadLevelGroup(keys,vals,"fibarc", o.fibarcLevelRatio, o.fibarcLevelColor, o.fibarcLevelOpacity, o.fibarcLevelWidth, o.fibarcLevelStyle, o.fibarcLevelVisible);
   TP_ReadLevelGroup(keys,vals,"gannfan",o.gannfanLevelRatio,o.gannfanLevelColor,o.gannfanLevelOpacity,o.gannfanLevelWidth,o.gannfanLevelStyle,o.gannfanLevelVisible);
   TP_ReadLevelGroup(keys,vals,"gannbox",o.gannboxLevelRatio,o.gannboxLevelColor,o.gannboxLevelOpacity,o.gannboxLevelWidth,o.gannboxLevelStyle,o.gannboxLevelVisible);
   //--- Pitchfork lines
   o.medianVisible=TP_GetB(keys,vals,"medianVisible",true);
   o.medianColor  =TP_GetC(keys,vals,"medianColor",o.objColor);
   o.medianWidth  =TP_GetI(keys,vals,"medianWidth",2);
   o.medianStyle  =TP_GetI(keys,vals,"medianStyle",0);
   o.outerVisible =TP_GetB(keys,vals,"outerVisible",true);
   o.outerColor   =TP_GetC(keys,vals,"outerColor",o.objColor);
   o.outerWidth   =TP_GetI(keys,vals,"outerWidth",1);
   o.outerStyle   =TP_GetI(keys,vals,"outerStyle",0);
   o.innerVisible =TP_GetB(keys,vals,"innerVisible",true);
   o.innerColor   =TP_GetC(keys,vals,"innerColor",o.objColor);
   o.innerWidth   =TP_GetI(keys,vals,"innerWidth",1);
   o.innerStyle   =TP_GetI(keys,vals,"innerStyle",0);
   //--- Append + track max id
   int sz=ArraySize(m_drawnObjects); ArrayResize(m_drawnObjects,sz+1);
   m_drawnObjects[sz]=o;
   if(o.id>maxId) maxId=o.id;
  }

//+------------------------------------------------------------------+
//| Load the chart file into m_drawnObjects[]; tolerant + safe       |
//+------------------------------------------------------------------+
bool CDrawingEngine::RestoreDrawings()
  {
   string path = DrawingsFilePath();
   if(!FileIsExist(path)) return false;
   int h = FileOpen(path, FILE_READ|FILE_TXT|FILE_ANSI);
   if(h == INVALID_HANDLE)
     { Print("ToolsPalette: RestoreDrawings FileOpen failed err=",GetLastError()); return false; }

   //--- Start from a clean store
   ArrayResize(m_drawnObjects, 0);
   m_drawnObjectCount = 0;

   int    headerCounter = 0;
   int    maxId         = 0;
   bool   inObj         = false;
   string keys[]; string vals[]; int kn = 0;

   while(!FileIsEnding(h))
     {
      string line = FileReadString(h);
      if(line == "TPDRAW v=1") continue;
      if(StringFind(line, "TPDRAW v=") == 0)
        {
         int ver = (int)StringToInteger(StringSubstr(line, 9));
         if(ver > TP_DRAW_SCHEMA_VERSION)
           { Print("ToolsPalette: drawing file schema v",ver," newer than supported; starting empty"); FileClose(h); return true; }
         continue;
        }
      if(StringFind(line, "counter=") == 0)
        { headerCounter = (int)StringToInteger(StringSubstr(line, 8)); continue; }
      if(line == "[OBJ]")   { inObj=true;  kn=0; ArrayResize(keys,0); ArrayResize(vals,0); continue; }
      if(line == "[/OBJ]")
        {
         if(inObj) MaterializeLoadedObject(keys, vals, maxId);
         inObj=false; continue;
        }
      if(inObj)
        {
         int eq = StringFind(line, "=");
         if(eq < 0) continue;
         ArrayResize(keys, kn+1); ArrayResize(vals, kn+1);
         keys[kn] = StringSubstr(line, 0, eq);
         vals[kn] = StringSubstr(line, eq+1);
         kn++;
        }
     }
   FileClose(h);

   //--- Restore counter so future IDs never collide with loaded ones
   m_drawnObjectCounter = MathMax(headerCounter, maxId);
   m_drawnObjectCount   = ArraySize(m_drawnObjects);
   return true;
  }

// MaybeFlushDrawings() is implemented in Task 3.
void CDrawingEngine::MaybeFlushDrawings() { }

#endif // TOOLS_PALETTE_STORAGE_MQH
