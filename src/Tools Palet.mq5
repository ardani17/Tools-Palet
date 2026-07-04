//+------------------------------------------------------------------+
//|                                         Tools Palet.mq5          |
//|                                    Copyright 2026, Om J.         |
//|                                   https://t.me/HZFXI             |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Om J."
#property link "https://t.me/HZFXI"
#property version "1.00"
#property strict

//--- Pull in the sidebar shell header that defines the CToolsSidebar class
#include "ToolsPalette_Shell.mqh"

//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
CToolsSidebar g_sidebar; // Top-level sidebar that owns every canvas and routes chart events

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   //--- Spin up sidebar canvases, register event hooks, and paint the panel
   if(!g_sidebar.Init(ChartID()))
     {
      //--- Report the initialization failure to the experts journal
      Print("ToolsPalette: Failed to initialize. Check journal for details.");
      //--- Abort the EA startup by returning a failure code to the terminal
      return INIT_FAILED;
     }
   //--- Force an immediate chart redraw so the sidebar appears on load
   ChartRedraw();
   //--- Signal a successful initialization to the terminal
   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   //--- Tear down every sidebar canvas and free all associated resources
   g_sidebar.Destroy();
   //--- Refresh the chart so no leftover sidebar artifacts remain visible
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
  {
   //--- Forward every chart event straight to the sidebar dispatcher
   g_sidebar.OnEvent(id, lparam, dparam, sparam);
  }

//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
   //--- Pass each timer tick to the sidebar so the label edit cursor can blink
   g_sidebar.OnTimer();
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
  }
//+------------------------------------------------------------------+