# Tools Palette (MetaTrader 5)

Expert Advisor (EA) MetaTrader 5 yang menyediakan palet alat drawing lengkap di
atas chart (mirip TradingView): trendline, shapes, Fibonacci, channels, annotations,
crosshair/magnifier, dengan sidebar kategori, ribbon properties, dan settings window.

Semua objek dirender ke canvas bitmap (`CCanvas`), bukan objek chart MT5 native.

## Arsitektur

Rantai inheritance:
`CDrawingEngine` -> `CSidebarLayout` -> `CChartEventHandler` -> `CToolsSidebar`

| Folder (`src/`) | Isi |
|-----------------|-----|
| `core/` | Shell (event router), Sidebar (layout/panel), Tools (engine inti + storage objek) |
| `engine/` | Render, Interact, Edit, Properties dari drawing engine |
| `ui/` | Ribbon, Settings, Settings_Interact, PropertyWidgets, Properties |
| `tools/` | Lines, Shapes, Fibonacci, Channels, Annotations, Crosshair |
| `primitives/` | Primitives (helper gambar low-level) |

Entry point: `src/Tools Palet.mq5`.

## Install / Compile

1. Cari folder data terminal MT5: di MetaEditor/Terminal pilih **File > Open Data Folder**.
2. Dari root repo, jalankan script deploy (membuat junction, tanpa copy manual):

   ```powershell
   .\scripts\deploy-mt5.ps1 -TerminalDataPath "C:\Users\<user>\AppData\Roaming\MetaQuotes\Terminal\<HASH>"
   ```

3. Buka MetaEditor -> `Experts\ToolsPalet\Tools Palet.mq5` -> **Compile (F7)**. Pastikan 0 error.
4. Di terminal MT5, attach EA `ToolsPalet` ke chart.

> Junction memetakan `MQL5\Experts\ToolsPalet` ke folder `src/` repo, jadi edit di repo langsung terpakai saat compile.

## Branch Workflow

```
beta  ->  development  ->  main
(dev)     (testing)        (production)
```

- **beta** — pengembangan fitur/eksperimen.
- **development** — testing sebelum produksi.
- **main** — versi stabil/produksi.

## Catatan

- Binary hasil compile (`*.ex5`) tidak di-track git (lihat `.gitignore`).
- Belum ada test otomatis (keterbatasan MT5); verifikasi = compile sukses + smoke test manual.
