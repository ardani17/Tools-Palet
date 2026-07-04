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

## Dokumentasi

| Dokumen | Isi |
|---------|-----|
| **[Panduan Compile](docs/compile.md)** | Deploy junction, compile MetaEditor/CLI, attach EA, troubleshooting |
| **[Panduan Penggunaan](docs/panduan-penggunaan.md)** | UI, semua kategori alat, placement, edit, persistensi, shortcut |

## Install / Compile (ringkas)

1. Deploy junction: `.\scripts\deploy-mt5.ps1 -TerminalDataPath "<folder data MT5>"`
2. MetaEditor → `Experts\ToolsPalet\Tools Palet.mq5` → **Compile (F7)** → 0 error
3. Attach EA **ToolsPalet** ke chart; aktifkan **Algo Trading**

Detail lengkap: **[docs/compile.md](docs/compile.md)**

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
- Persistensi drawing: lihat bagian **Persistensi** di [panduan-penggunaan.md](docs/panduan-penggunaan.md).
