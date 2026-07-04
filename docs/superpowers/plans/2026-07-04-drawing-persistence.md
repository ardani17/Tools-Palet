# Drawing Persistence Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Persist user drawings to a per-chart file so they survive timeframe changes and MT5 restarts.

**Architecture:** A new `src/storage/ToolsPalette_Storage.mqh` module implements a versioned tagged-text serializer/parser plus atomic file I/O. `CDrawingEngine` gains `SaveDrawings()`, `RestoreDrawings()`, `MarkDrawingsDirty()`, `MaybeFlushDrawings()` (declared in the class, defined in the storage include). Committed mutations mark the store dirty; a persistent chart timer flushes it (debounced); `Init()` restores it; `Destroy()` does a final flush.

**Tech Stack:** MQL5 (MetaEditor), MT5 file sandbox (`FileOpen`/`FileWriteString`/`FileReadString`/`FileMove`).

## Global Constraints

- Branch: `beta`. All commits land on `beta`.
- Language: MQL5. No automated test framework exists — verification = **MetaEditor compile with 0 errors** + **manual MT5 smoke test**. (README: "verifikasi = compile sukses + smoke test manual".)
- Compile: MetaEditor → `Experts\ToolsPalet\Tools Palet.mq5` → **F7** → require 0 errors, 0 warnings. Optional CLI: `& "<MT5>\metaeditor64.exe" /compile:"<repo>\src\Tools Palet.mq5" /log` then read the `.log`.
- Source layout is `src/` layered folders (post-#1 refactor). New module goes in `src/storage/`.
- Storage key: `Symbol() + "_" + IntegerToString(ChartID())`. File path (sandbox): `ToolsPalette\drawings\<key>.dat`.
- On-disk format: header `TPDRAW v=1`, `counter=<n>`, then `[OBJ]`…`[/OBJ]` blocks of `key=value` lines. Reader skips unknown keys and tolerates missing keys.
- Serialize ALL `DrawnObject` fields except transient UI state (`selected` always restored as `false`).
- Debounce: flush when dirty and `GetTickCount() - dirtyTick >= 400` ms. Persistent timer interval: `500` ms.
- Do NOT `EventKillTimer()` when a label edit ends (re-arm the heartbeat instead); only `Destroy()` kills the timer.
- Never crash on bad/missing/newer-version file — log via `Print(...)` and start empty.

---

### Task 1: Storage module — engine state, declarations, include wiring, and serializer (`SaveDrawings`)

**Files:**
- Create: `src/storage/ToolsPalette_Storage.mqh`
- Modify: `src/core/ToolsPalette_Tools.mqh` (add dirty-flag state + method declarations to `CDrawingEngine`; `#include` the storage module at end-of-file)

**Interfaces:**
- Consumes: `DrawnObject` struct (`src/core/ToolsPalette_Tools.mqh:526`), `CDrawingEngine::m_drawnObjects[]`, `m_drawnObjectCount`, `m_drawnObjectCounter`.
- Produces (methods on `CDrawingEngine`, used by later tasks):
  - `void SaveDrawings()`
  - `bool RestoreDrawings()` (implemented in Task 2)
  - `void MarkDrawingsDirty()`
  - `void MaybeFlushDrawings()`
  - `string DrawingsFilePath()` — returns `ToolsPalette\drawings\<Symbol>_<ChartID>.dat`
  - member state: `bool m_drawingsDirty; uint m_drawingsDirtyTick;`

- [ ] **Step 1: Declare state + methods on `CDrawingEngine`**

In `src/core/ToolsPalette_Tools.mqh`, inside `class CDrawingEngine`, immediately after the drawn-object store counters (after line 668 `int m_drawnObjectCounter;`), add the dirty-flag state:

```mql5
   //--- Persistence dirty-flag + last-change tick (drives debounced flush; see ToolsPalette_Storage.mqh)
   bool        m_drawingsDirty;
   uint        m_drawingsDirtyTick;
```

Then in the `protected:` methods region (next to `RemoveDrawnObject` declaration, ~line 773), add:

```mql5
   //--- Drawing persistence (impl in src/storage/ToolsPalette_Storage.mqh)
   string       DrawingsFilePath();
   void         MarkDrawingsDirty();
   void         MaybeFlushDrawings();
   void         SaveDrawings();
   bool         RestoreDrawings();
   void         MaterializeLoadedObject(const string &keys[], const string &vals[], int &maxId);
```

- [ ] **Step 2: Initialise the dirty-flag state**

In `src/core/ToolsPalette_Shell.mqh`, in `CToolsSidebar::InitDefaults()` right after the drawn-object counter resets (after line 890 `m_drawnObjectCount = 0;`), add:

```mql5
   m_drawingsDirty           = false;
   m_drawingsDirtyTick       = 0;
```

- [ ] **Step 3: Create the storage module with file-path + dirty + serializer**

Create `src/storage/ToolsPalette_Storage.mqh` with the writer half (reader is Task 2). This file is `#include`d after `CDrawingEngine` is fully declared, so it can define its methods:

```mql5
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

#endif // TOOLS_PALETTE_STORAGE_MQH
```

- [ ] **Step 4: Wire the include**

At the very end of `src/core/ToolsPalette_Tools.mqh`, immediately before its final `#endif`, add the include so the storage methods are defined after `CDrawingEngine`:

```mql5
//--- Drawing persistence methods (defined after the class is fully declared)
#include "..\storage\ToolsPalette_Storage.mqh"
```

Add a temporary caller so the linker keeps `SaveDrawings` and it compiles: none needed — methods are class members, they compile regardless. `MaybeFlushDrawings`/`RestoreDrawings` are only *declared* so far; add empty stubs at the bottom of the storage file to satisfy the compiler until later tasks:

```mql5
void CDrawingEngine::MaybeFlushDrawings() { }
bool CDrawingEngine::RestoreDrawings()    { return false; }
```

Place these stubs *before* the final `#endif` of `ToolsPalette_Storage.mqh`. They are replaced with real bodies in Tasks 2–3.

- [ ] **Step 5: Compile**

Open MetaEditor → `Experts\ToolsPalet\Tools Palet.mq5` → **F7**.
Expected: **0 errors, 0 warnings**. If "function already defined" appears for `MaybeFlushDrawings`/`RestoreDrawings`, ensure the real bodies in later tasks *replace* these stubs (do not keep both).

- [ ] **Step 6: Commit**

```bash
git add "src/storage/ToolsPalette_Storage.mqh" "src/core/ToolsPalette_Tools.mqh" "src/core/ToolsPalette_Shell.mqh"
git commit -m "feat: add drawing serializer + persistence scaffolding (#2)"
```

---

### Task 2: Deserializer (`RestoreDrawings`)

**Files:**
- Modify: `src/storage/ToolsPalette_Storage.mqh` (replace the `RestoreDrawings` stub with a real parser + helpers)

**Interfaces:**
- Consumes: file written by `SaveDrawings` (Task 1); `DrawnObject`, `m_drawnObjects[]`, `m_drawnObjectCount`, `m_drawnObjectCounter`.
- Produces: `bool RestoreDrawings()` — returns `true` if a file was loaded (even if empty), `false` if missing/unreadable. Populates `m_drawnObjects[]` and sets `m_drawnObjectCounter = max(loaded ids, counter-from-header)`.

- [ ] **Step 1: Add split/lookup helpers**

In `src/storage/ToolsPalette_Storage.mqh`, above `SaveDrawings` (with the other `TP_*` helpers), add parsing helpers:

```mql5
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
```

- [ ] **Step 2: Replace the `RestoreDrawings` stub with the real parser**

Replace `bool CDrawingEngine::RestoreDrawings() { return false; }` with:

```mql5
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
         if(inObj) TP_MaterializeObject(keys, vals, maxId);
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
```

- [ ] **Step 3: Add `TP_MaterializeObject` (fills one `DrawnObject` and appends it)**

Add this helper *above* `RestoreDrawings` (it must see `DrawnObject`). It is a free function taking the engine's array via a reference is awkward in MQL5, so make it a method: declare `void MaterializeLoadedObject(const string &keys[], const string &vals[], int &maxId);` in `CDrawingEngine` (Task 1 Step 1 region) — **update Task 1 declarations to include it** — and define it here. For clarity within this plan, define it as a method:

```mql5
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
```

Then change the `[/OBJ]` branch call in Step 2 from `TP_MaterializeObject(keys, vals, maxId);` to `MaterializeLoadedObject(keys, vals, maxId);` (method form). Also add `void MaterializeLoadedObject(const string &keys[], const string &vals[], int &maxId);` to the `CDrawingEngine` declarations added in Task 1 Step 1.

- [ ] **Step 4: Compile**

MetaEditor → **F7**. Expected: **0 errors, 0 warnings**.

- [ ] **Step 5: Commit**

```bash
git add "src/storage/ToolsPalette_Storage.mqh" "src/core/ToolsPalette_Tools.mqh"
git commit -m "feat: add tolerant drawing file parser (RestoreDrawings) (#2)"
```

---

### Task 3: Lifecycle wiring — persistent timer, restore on init, flush on timer + destroy

**Files:**
- Modify: `src/storage/ToolsPalette_Storage.mqh` (replace `MaybeFlushDrawings` stub)
- Modify: `src/core/ToolsPalette_Shell.mqh` (`Init()`, `OnTimer()`, `Destroy()`)

**Interfaces:**
- Consumes: `SaveDrawings()`, `RestoreDrawings()`, `RedrawAllObjects()`, `m_drawingsDirty`, `m_drawingsDirtyTick`.
- Produces: `void MaybeFlushDrawings()` (debounced flush); restore-on-init behavior.

- [ ] **Step 1: Implement `MaybeFlushDrawings`**

In `src/storage/ToolsPalette_Storage.mqh`, replace `void CDrawingEngine::MaybeFlushDrawings() { }` with:

```mql5
//+------------------------------------------------------------------+
//| Flush the store if dirty and the debounce window has elapsed     |
//+------------------------------------------------------------------+
void CDrawingEngine::MaybeFlushDrawings()
  {
   if(!m_drawingsDirty) return;
   if(GetTickCount() - m_drawingsDirtyTick < 400) return;
   SaveDrawings();
   m_drawingsDirty = false;
  }
```

- [ ] **Step 2: Restore drawings + install persistent timer in `Init()`**

In `src/core/ToolsPalette_Shell.mqh`, in `CToolsSidebar::Init(long chartId)`, just before `return true;` (line 1013), add:

```mql5
   //--- Restore any persisted drawings for this chart, then paint them
   if(RestoreDrawings())
      RedrawAllObjects();
   //--- Persistent heartbeat timer drives the debounced drawing flush (and label-caret blink)
   EventSetMillisecondTimer(500);
```

- [ ] **Step 3: Drive the flush from `OnTimer()`**

In `src/core/ToolsPalette_Shell.mqh`, in `CToolsSidebar::OnTimer()` (line 1527), after `RibbonTick();` (line 1539), add:

```mql5
   //--- Debounced persistence flush (writes at most ~once per change burst)
   MaybeFlushDrawings();
```

- [ ] **Step 4: Final flush + kill timer in `Destroy()`**

In `src/core/ToolsPalette_Shell.mqh`, in `CToolsSidebar::Destroy()` (line 1040), replace the timer-kill line:

```mql5
   //--- Kill any active edit-mode timer (StartLabelEdit's timer drives the cursor blink)
   if(m_isEditingLabel) EventKillTimer();
```

with:

```mql5
   //--- Final persistence flush before teardown (covers timeframe change / EA removal)
   if(m_drawingsDirty) { SaveDrawings(); m_drawingsDirty = false; }
   //--- Kill the persistent heartbeat timer
   EventKillTimer();
```

- [ ] **Step 5: Compile**

MetaEditor → **F7**. Expected: **0 errors, 0 warnings**.

- [ ] **Step 6: Manual smoke test — the core fix (timeframe + restart)**

Deploy (junction already set per README) and attach the EA. Then:
1. Draw a trendline + a rectangle.
2. Switch M15 → H1. **Expected:** both reappear at the same time/price anchors.
3. Switch H1 → D1 → back to M15. **Expected:** still present, correct anchors.
4. Note: at this point saving happens on `Destroy` (timeframe change) — objects drawn but with NO subsequent timeframe change won't be written until a change/close. That is fine; Task 4 adds mid-session saves.
5. Confirm `MQL5\Files\ToolsPalette\drawings\<Symbol>_<ChartID>.dat` exists and contains `[OBJ]` blocks.

- [ ] **Step 7: Commit**

```bash
git add "src/storage/ToolsPalette_Storage.mqh" "src/core/ToolsPalette_Shell.mqh"
git commit -m "feat: restore drawings on init, flush on timer + deinit (#2)"
```

---

### Task 4: Mark dirty at every committed mutation + label-timer coexistence

**Files:**
- Modify: `src/core/ToolsPalette_Tools.mqh` (`AddDrawnObject`, `RemoveDrawnObject`, `ClearAllDrawnObjects`)
- Modify: `src/engine/ToolsPalette_Engine_Edit.mqh` (`CommitLabel`, `CancelLabel`)
- Modify: `src/engine/ToolsPalette_Engine_Interact.mqh` (mouse-up drag release)
- Modify: `src/engine/ToolsPalette_Engine_Properties.mqh` (5 `SetObjectProperty` overloads)

**Interfaces:**
- Consumes: `MarkDrawingsDirty()`.
- Produces: every committed change marks the store dirty so the Task 3 timer flushes it.

- [ ] **Step 1: Mark dirty in add/remove/clear**

In `src/core/ToolsPalette_Tools.mqh`:

In `AddDrawnObject`, before `return m_drawnObjectCounter;` (line 1705) add:
```mql5
   MarkDrawingsDirty();
```
In `RemoveDrawnObject`, inside the found branch right before `RedrawAllObjects();` (line 1734) add:
```mql5
         MarkDrawingsDirty();
```
In `ClearAllDrawnObjects`, before the final closing brace (after line 1759) add:
```mql5
   MarkDrawingsDirty();
```

- [ ] **Step 2: Mark dirty on label commit; keep the heartbeat alive on edit end**

In `src/engine/ToolsPalette_Engine_Edit.mqh`:

In `CommitLabel`, replace:
```mql5
   //--- Stop the caret-blink timer
   EventKillTimer();
   RedrawAllObjects();
```
with:
```mql5
   //--- Re-arm the persistent heartbeat (do not kill it - it drives the persistence flush)
   EventSetMillisecondTimer(500);
   //--- Label text changed -> persist it
   MarkDrawingsDirty();
   RedrawAllObjects();
```

In `CancelLabel`, replace:
```mql5
   //--- Stop the caret-blink timer
   EventKillTimer();
   RedrawAllObjects();
```
with:
```mql5
   //--- Re-arm the persistent heartbeat (do not kill it - it drives the persistence flush)
   EventSetMillisecondTimer(500);
   RedrawAllObjects();
```

- [ ] **Step 3: Mark dirty on drag release**

In `src/engine/ToolsPalette_Engine_Interact.mqh`, in the mouse-up handler, replace:
```mql5
   //--- Redraw to restore the hidden-during-drag handle and any prompt visibility
   if(wasDragging) RedrawAllObjects();
```
with:
```mql5
   //--- Redraw to restore the hidden-during-drag handle and any prompt visibility
   if(wasDragging) { MarkDrawingsDirty(); RedrawAllObjects(); }
```

- [ ] **Step 4: Mark dirty on committed property changes (5 overloads)**

In `src/engine/ToolsPalette_Engine_Properties.mqh`, at the TOP of each of the 5 `SetObjectProperty` overloads (lines 350, 498, 755, 844, 967), immediately after the opening brace, add the same guard. Use the existing object-index lookup that each function already performs; place this line right after that lookup succeeds (or immediately after `{` if the lookup is later) — marking slightly early is harmless because it only sets a flag:

```mql5
   if(!preview) MarkDrawingsDirty();
```

Add it once per overload (5 total).

- [ ] **Step 5: Compile**

MetaEditor → **F7**. Expected: **0 errors, 0 warnings**.

- [ ] **Step 6: Manual smoke test — mid-session persistence + regression**

1. Draw an object, wait ~1s (no timeframe change), then **remove the EA and re-attach** (or reload). **Expected:** object persists (proves timer flush wrote it mid-session).
2. Draw fibonacci; recolor a level via the ribbon; drag an opacity slider then release. Switch timeframe. **Expected:** committed color/opacity persists; the live-drag frames did not thrash the file.
3. Move an object by dragging; switch timeframe. **Expected:** new position persists.
4. Delete an object; switch timeframe. **Expected:** stays deleted (file updated).
5. Edit a text label; switch timeframe. **Expected:** new text persists.
6. Regression: create / select / edit / drag / delete all behave exactly as before.

- [ ] **Step 7: Commit**

```bash
git add "src/core/ToolsPalette_Tools.mqh" "src/engine/ToolsPalette_Engine_Edit.mqh" "src/engine/ToolsPalette_Engine_Interact.mqh" "src/engine/ToolsPalette_Engine_Properties.mqh"
git commit -m "feat: mark drawings dirty on all committed mutations (#2)"
```

---

### Task 5: Full acceptance verification + docs

**Files:**
- Modify: `README.md` (note the new persistence behavior + file location)

**Interfaces:**
- Consumes: the fully wired feature.
- Produces: signed-off acceptance criteria.

- [ ] **Step 1: Run the full acceptance matrix in MT5**

Verify every issue #2 acceptance criterion:
1. Drawing survives timeframe change across M1, M5, M15, H1, H4, D1. ✅ expected
2. Drawing survives full MT5 terminal restart (close terminal, reopen same chart/profile). ✅ expected — file reloads on `OnInit`.
3. Multi-chart isolation: open a 2nd chart of the **same symbol**, draw different objects on each, switch timeframes. **Expected:** no cross-over (distinct `ChartID` files).
4. No regression: create, edit, delete, select all normal.
5. Performance: draw 50+ objects, switch timeframe. **Expected:** no visible lag; single file write.
6. Crash-safety: with unsaved changes present, kill the terminal process mid-session; reopen. **Expected:** the `.dat` file is still valid (atomic tmp+move) — either the prior good state or the latest flushed state, never a corrupt file.

If any check fails, fix in the owning task's file and re-compile before continuing.

- [ ] **Step 2: Document the behavior**

In `README.md`, under the features/notes section, add:

```markdown
### Persistensi Drawing

Objek drawing otomatis disimpan per-chart ke
`MQL5\Files\ToolsPalette\drawings\<Symbol>_<ChartID>.dat` dan dipulihkan saat
ganti timeframe maupun restart terminal. Isolasi per-chart memakai ChartID.
```

- [ ] **Step 3: Commit**

```bash
git add "README.md"
git commit -m "docs: document drawing persistence behavior (#2)"
```

---

## Self-Review

**1. Spec coverage**

| Spec requirement | Task |
|------------------|------|
| Survive timeframe change | Task 3 (restore on init + flush on deinit) |
| Survive terminal restart | Task 3 (file-based restore on init) |
| Per-chart isolation (Symbol+ChartID) | Task 1 `DrawingsFilePath()` |
| Versioned tagged-text format | Task 1 writer + Task 2 reader (`TPDRAW v=1`) |
| Tolerant reader (unknown/missing keys) | Task 2 `TP_Get*` defaults + skip-on-no-`=` |
| Hybrid save (dirty + debounced timer + deinit) | Task 3 (`MaybeFlushDrawings`, timer, Destroy) + Task 4 (mark sites) |
| Preview-guard coalescing | Task 4 Step 4 (`if(!preview)`) |
| Persistent timer (timer not idle-running) | Task 3 Step 2 + Task 4 Step 2 (re-arm on label end) |
| Atomic write | Task 1 `SaveDrawings` tmp + `FileMove` |
| Counter restore (no ID collisions) | Task 2 `m_drawnObjectCounter = max(...)` |
| Restore deselected | Task 2 `o.selected=false` |
| Clear persists empty state | Task 4 Step 1 (`ClearAllDrawnObjects` marks dirty) |
| 50+ objects performance | Task 5 Step 1 check |
| No create/edit/delete regression | Task 4 Step 6 + Task 5 Step 1 |

**2. Placeholder scan:** No "TBD"/"handle edge cases"/"similar to". All code blocks are concrete.

**3. Type consistency:** `SaveDrawings`/`RestoreDrawings`/`MarkDrawingsDirty`/`MaybeFlushDrawings`/`DrawingsFilePath`/`MaterializeLoadedObject` names match across declaration (Task 1 Step 1) and definitions (Tasks 1–3). `TP_*` free helpers are defined once in the storage file and referenced consistently. `m_drawingsDirty`/`m_drawingsDirtyTick` declared (Task 1), initialised (Task 1 Step 2), used (Tasks 3–4). Note: `MaterializeLoadedObject` must be added to the Task 1 declaration list (called out in Task 2 Step 3).
