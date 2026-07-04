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

// RestoreDrawings() + MaybeFlushDrawings() are implemented in Task 2 / Task 3.
void CDrawingEngine::MaybeFlushDrawings() { }
bool CDrawingEngine::RestoreDrawings()    { return false; }

#endif // TOOLS_PALETTE_STORAGE_MQH
