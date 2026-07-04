# Tools Palette (MetaTrader 5)

Expert Advisor (EA) MetaTrader 5 yang menyediakan **palet alat drawing lengkap** di atas chart — mirip TradingView. Termasuk trendline, shapes, Fibonacci, channels, pitchfork, Gann, annotations, serta crosshair dengan magnifier.

Semua objek dirender ke **canvas bitmap** (`CCanvas`), bukan objek chart MT5 native. Drawing **tetap ada** saat ganti timeframe atau restart terminal berkat persistensi file.

| | |
|---|---|
| **Versi** | 1.0.0 |
| **Bahasa** | MQL5 |
| **Platform** | MetaTrader 5 (Windows) |
| **Rilis** | [`v1.0.0`](https://github.com/ardani17/Tools-Palet/releases/tag/v1.0.0) |

## Fitur utama

- **42+ alat drawing** dalam 8 kategori: Cursors, Lines, Channels, Pitchfork, Gann, Fibonacci, Shapes, Annotate
- **Sidebar + flyout** — panel kategori vertikal yang bisa digeser, di-snap ke tepi chart, dan di-resize
- **Ribbon properti cepat** dan **Settings window** (Style, Coordinates, Text, Levels)
- **Crosshair** dengan reticle, magnifier, label sumbu harga/waktu, dan pengukuran jarak antar titik
- **Persistensi drawing** — objek disimpan ke `MQL5\Files\ToolsPalette\drawings\<Symbol>_<ChartID>.dat`
- **Tema terang/gelap** dengan toggle di header sidebar
- **Script deploy** junction — edit `src/` langsung terbaca MetaEditor tanpa copy manual

## Persyaratan

- **MetaTrader 5** + **MetaEditor** (terbundel dengan MT5)
- **Windows** + **PowerShell** (untuk script deploy)
- **Algo Trading** aktif di terminal saat EA dipasang

## Instalasi cepat

```powershell
# 1. Clone repo
git clone https://github.com/ardani17/Tools-Palet.git
cd Tools-Palet

# 2. Deploy junction ke folder data MT5
#    (cari path via MT5: File → Open Data Folder)
.\scripts\deploy-mt5.ps1 -TerminalDataPath "C:\Users\<user>\AppData\Roaming\MetaQuotes\Terminal\<HASH>"

# 3. Compile di MetaEditor
#    Experts\ToolsPalet\Tools Palet.mq5 → F7 → 0 error

# 4. Attach EA "ToolsPalet" ke chart; aktifkan Algo Trading
```

Panduan lengkap: **[docs/compile.md](docs/compile.md)**

## Dokumentasi

| Dokumen | Isi |
|---------|-----|
| **[Panduan Compile](docs/compile.md)** | Deploy junction, compile MetaEditor/CLI, attach EA, troubleshooting |
| **[Panduan Penggunaan](docs/panduan-penggunaan.md)** | UI, semua kategori alat, placement, edit, persistensi, shortcut |
| **[CHANGELOG](CHANGELOG.md)** | Riwayat versi dan catatan rilis |

## Arsitektur

Rantai inheritance:
`CDrawingEngine` → `CSidebarLayout` → `CChartEventHandler` → `CToolsSidebar`

| Folder (`src/`) | Isi |
|-----------------|-----|
| `core/` | Shell (event router), Sidebar (layout/panel), Tools (engine inti + storage objek) |
| `engine/` | Render, Interact, Edit, Properties dari drawing engine |
| `ui/` | Ribbon, Settings, Settings_Interact, PropertyWidgets, Properties |
| `tools/` | Lines, Shapes, Fibonacci, Channels, Annotations, Crosshair |
| `primitives/` | Primitives (helper gambar low-level, tema) |
| `storage/` | Serializer dan persistensi drawing ke file |

Entry point: `src/Tools Palet.mq5` (20 file source: 1 `.mq5` + 19 `.mqh`).

## Struktur repo

```
Tools-Palet/
├── src/                  # Source MQL5 (entry point + include)
├── scripts/              # deploy-mt5.ps1 (junction ke folder Experts MT5)
├── docs/                 # Panduan compile & penggunaan
├── CHANGELOG.md          # Riwayat versi
└── README.md
```

## Catatan teknis

- Binary hasil compile (`*.ex5`) **tidak** di-track git — lihat `.gitignore`.
- Belum ada test otomatis (keterbatasan MT5); verifikasi = **compile 0 error/warning** + smoke test manual di chart.
- Drawing **tidak** muncul di daftar Objects MT5 (Ctrl+B) karena dirender ke canvas overlay, bukan objek chart native.
- Persistensi: lihat bagian **Persistensi** di [panduan-penggunaan.md](docs/panduan-penggunaan.md).

## Kontak

Copyright 2026, Om J. — [https://t.me/HZFXI](https://t.me/HZFXI)
