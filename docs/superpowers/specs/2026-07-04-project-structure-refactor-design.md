# Design: Refactor Struktur Folder Project Tools Palette

- **Tanggal:** 2026-07-04
- **Issue:** [#1](https://github.com/ardani17/Tools-Palet/issues/1)
- **Branch kerja:** `beta`
- **Status:** Approved (siap masuk tahap implementation plan)

## 1. Latar Belakang

Tools Palette adalah Expert Advisor (EA) MetaTrader 5 yang menyediakan palet alat
drawing di atas chart (mirip TradingView). Semua drawing dirender ke canvas bitmap
(`CCanvas`) melalui rantai inheritance:
`CDrawingEngine` → `CSidebarLayout` → `CChartEventHandler` → `CToolsSidebar`.

Saat ini seluruh source (1 file `.mq5`, 19 file `.mqh`, 1 binary `.ex5`) berada
flat di root repo tanpa struktur direktori. Branch `main` dan `development` sengaja
dikosongkan menunggu struktur dirapikan sebelum menerima merge dari `beta`.

## 2. Tujuan

- Mengorganisir source ke folder logis: `core/`, `engine/`, `ui/`, `tools/`, `primitives/`.
- Menjadikan repo **self-contained**: folder `src/` bisa langsung dipakai MetaTrader
  via junction dan compile tanpa langkah copy manual.
- Menambah `.gitignore`, `README.md`, dan script deploy.
- Menyiapkan fondasi rapi sebelum bug persistence drawing (issue #2) dikerjakan.

### Non-Tujuan (YAGNI)

- Tidak mengubah logika/behavior EA apa pun.
- Tidak menambah fitur baru.
- Tidak refactor isi class atau memecah file besar (di luar scope issue ini).
- Tidak menambah unit test (MT5 tidak punya framework test; verifikasi = compile + smoke test manual).

## 3. Keputusan Desain (hasil brainstorming)

| Topik | Keputusan |
|-------|-----------|
| Workflow compile | Belum ada; refactor sekalian mempermudahnya |
| Target deploy | Self-contained; folder `src/` di-junction ke `MQL5\Experts\ToolsPalet` |
| Pengelompokan | Ikuti usulan issue #1: `core/`, `engine/`, `ui/`, `tools/`, `primitives/` |
| Binary `.ex5` | Di-ignore dari git (`*.ex5`) |
| Alat bantu deploy | Script PowerShell pembuat junction |

## 4. Struktur Folder Final

Unit deploy = folder `src/`. MetaTrader hanya melihat `src/` (via junction),
sehingga `.git/`, `docs/`, `README.md` tidak ikut ke terminal.

```
Tools-Palet/                     # repo root
├── src/                         # di-junction ke MQL5\Experts\ToolsPalet
│   ├── Tools Palet.mq5          # entry point EA
│   ├── core/
│   │   ├── ToolsPalette_Shell.mqh
│   │   ├── ToolsPalette_Sidebar.mqh
│   │   └── ToolsPalette_Tools.mqh
│   ├── engine/
│   │   ├── ToolsPalette_Engine_Render.mqh
│   │   ├── ToolsPalette_Engine_Interact.mqh
│   │   ├── ToolsPalette_Engine_Edit.mqh
│   │   └── ToolsPalette_Engine_Properties.mqh
│   ├── ui/
│   │   ├── ToolsPalette_Ribbon.mqh
│   │   ├── ToolsPalette_Settings.mqh
│   │   ├── ToolsPalette_Settings_Interact.mqh
│   │   ├── ToolsPalette_PropertyWidgets.mqh
│   │   └── ToolsPalette_Properties.mqh
│   ├── tools/
│   │   ├── ToolsPalette_Lines.mqh
│   │   ├── ToolsPalette_Shapes.mqh
│   │   ├── ToolsPalette_Fibonacci.mqh
│   │   ├── ToolsPalette_Channels.mqh
│   │   ├── ToolsPalette_Annotations.mqh
│   │   └── ToolsPalette_Crosshair.mqh
│   └── primitives/
│       └── ToolsPalette_Primitives.mqh
├── scripts/
│   └── deploy-mt5.ps1
├── docs/
│   └── superpowers/specs/
├── .gitignore
└── README.md
```

### Pemetaan file → folder

| File | Folder tujuan |
|------|---------------|
| `Tools Palet.mq5` | `src/` |
| `ToolsPalette_Shell.mqh` | `src/core/` |
| `ToolsPalette_Sidebar.mqh` | `src/core/` |
| `ToolsPalette_Tools.mqh` | `src/core/` |
| `ToolsPalette_Engine_Render.mqh` | `src/engine/` |
| `ToolsPalette_Engine_Interact.mqh` | `src/engine/` |
| `ToolsPalette_Engine_Edit.mqh` | `src/engine/` |
| `ToolsPalette_Engine_Properties.mqh` | `src/engine/` |
| `ToolsPalette_Ribbon.mqh` | `src/ui/` |
| `ToolsPalette_Settings.mqh` | `src/ui/` |
| `ToolsPalette_Settings_Interact.mqh` | `src/ui/` |
| `ToolsPalette_PropertyWidgets.mqh` | `src/ui/` |
| `ToolsPalette_Properties.mqh` | `src/ui/` |
| `ToolsPalette_Lines.mqh` | `src/tools/` |
| `ToolsPalette_Shapes.mqh` | `src/tools/` |
| `ToolsPalette_Fibonacci.mqh` | `src/tools/` |
| `ToolsPalette_Channels.mqh` | `src/tools/` |
| `ToolsPalette_Annotations.mqh` | `src/tools/` |
| `ToolsPalette_Crosshair.mqh` | `src/tools/` |
| `ToolsPalette_Primitives.mqh` | `src/primitives/` |

## 5. Perubahan `#include`

MQL5 mendukung path relatif termasuk `..` pada `#include "..."` (relatif terhadap
file yang memuat directive). Include sesama folder tetap; hanya lintas folder yang
diberi prefix.

| File | Include lama | Include baru |
|------|--------------|--------------|
| `src/Tools Palet.mq5` | `"ToolsPalette_Shell.mqh"` | `"core/ToolsPalette_Shell.mqh"` |
| `src/core/ToolsPalette_Tools.mqh` | `"ToolsPalette_Annotations.mqh"` | `"../tools/ToolsPalette_Annotations.mqh"` |
| `src/core/ToolsPalette_Tools.mqh` | `"ToolsPalette_Engine_Edit.mqh"` | `"../engine/ToolsPalette_Engine_Edit.mqh"` |
| `src/core/ToolsPalette_Tools.mqh` | `"ToolsPalette_Engine_Interact.mqh"` | `"../engine/ToolsPalette_Engine_Interact.mqh"` |
| `src/core/ToolsPalette_Tools.mqh` | `"ToolsPalette_Engine_Render.mqh"` | `"../engine/ToolsPalette_Engine_Render.mqh"` |
| `src/core/ToolsPalette_Tools.mqh` | `"ToolsPalette_Engine_Properties.mqh"` | `"../engine/ToolsPalette_Engine_Properties.mqh"` |
| `src/core/ToolsPalette_Sidebar.mqh` | `"ToolsPalette_Tools.mqh"` | *(tetap)* |
| `src/core/ToolsPalette_Shell.mqh` | `"ToolsPalette_Sidebar.mqh"` | *(tetap)* |
| `src/core/ToolsPalette_Shell.mqh` | `"ToolsPalette_Ribbon.mqh"` | `"../ui/ToolsPalette_Ribbon.mqh"` |
| `src/core/ToolsPalette_Shell.mqh` | `"ToolsPalette_Settings.mqh"` | `"../ui/ToolsPalette_Settings.mqh"` |
| `src/engine/ToolsPalette_Engine_Render.mqh` | `"ToolsPalette_Tools.mqh"` | `"../core/ToolsPalette_Tools.mqh"` |
| `src/engine/ToolsPalette_Engine_Interact.mqh` | `"ToolsPalette_Tools.mqh"` | `"../core/ToolsPalette_Tools.mqh"` |
| `src/engine/ToolsPalette_Engine_Edit.mqh` | `"ToolsPalette_Tools.mqh"` | `"../core/ToolsPalette_Tools.mqh"` |
| `src/engine/ToolsPalette_Engine_Properties.mqh` | `"ToolsPalette_Tools.mqh"` | `"../core/ToolsPalette_Tools.mqh"` |
| `src/ui/ToolsPalette_Ribbon.mqh` | `"ToolsPalette_Sidebar.mqh"` | `"../core/ToolsPalette_Sidebar.mqh"` |
| `src/ui/ToolsPalette_Ribbon.mqh` | `"ToolsPalette_Properties.mqh"` | *(tetap)* |
| `src/ui/ToolsPalette_Ribbon.mqh` | `"ToolsPalette_PropertyWidgets.mqh"` | *(tetap)* |
| `src/ui/ToolsPalette_PropertyWidgets.mqh` | `"ToolsPalette_Sidebar.mqh"` | `"../core/ToolsPalette_Sidebar.mqh"` |
| `src/ui/ToolsPalette_Properties.mqh` | `"ToolsPalette_Tools.mqh"` | `"../core/ToolsPalette_Tools.mqh"` |
| `src/ui/ToolsPalette_Settings.mqh` | `"ToolsPalette_Ribbon.mqh"` | *(tetap)* |
| `src/ui/ToolsPalette_Settings.mqh` | `"ToolsPalette_Settings_Interact.mqh"` | *(tetap)* |
| `src/ui/ToolsPalette_Settings_Interact.mqh` | `"ToolsPalette_Settings.mqh"` | *(tetap)* |
| `src/tools/ToolsPalette_Shapes.mqh` | `"ToolsPalette_Fibonacci.mqh"` | *(tetap)* |
| `src/tools/ToolsPalette_Fibonacci.mqh` | `"ToolsPalette_Channels.mqh"` | *(tetap)* |
| `src/tools/ToolsPalette_Channels.mqh` | `"ToolsPalette_Lines.mqh"` | *(tetap)* |
| `src/tools/ToolsPalette_Lines.mqh` | `"ToolsPalette_Crosshair.mqh"` | *(tetap)* |
| `src/tools/ToolsPalette_Annotations.mqh` | `"ToolsPalette_Shapes.mqh"` | *(tetap)* |
| `src/tools/ToolsPalette_Crosshair.mqh` | `"ToolsPalette_Primitives.mqh"` | `"../primitives/ToolsPalette_Primitives.mqh"` |

Total baris berubah: **15** (sisanya sesama folder, tetap).

## 6. File Pendukung Baru

### `.gitignore`

```
# MetaTrader compiled binary
*.ex5

# MetaTrader logs & temp
*.log
*.tmp

# OS
Thumbs.db
Desktop.ini
```

### `README.md`

Berisi: deskripsi EA, ringkasan arsitektur (rantai class + peran tiap folder),
cara install via junction, cara compile di MetaEditor, dan branch workflow
`beta → development → main`.

### `scripts/deploy-mt5.ps1`

- Parameter: `-TerminalDataPath` (path folder data terminal MT5 yang berisi `MQL5`).
- Membuat junction: `MQL5\Experts\ToolsPalet` → `<repo>\src`.
- Validasi: cek folder target ada, cek junction lama, beri pesan jelas + contoh cara cari path terminal MT5.

## 7. Verifikasi

Tidak ada test otomatis di MT5. Verifikasi bertingkat:

1. **Static check (agent):** pastikan tiap `#include` menunjuk file yang ada di path barunya; tidak ada file tertinggal di root.
2. **Compile (user):** buka `src/Tools Palet.mq5` di MetaEditor via junction → **0 error, 0 warning**.
3. **Smoke test manual (user):** attach EA ke chart, gambar beberapa objek, buka settings/ribbon → berfungsi seperti sebelum refactor.

## 8. Rencana Rollout Git

1. Kerjakan semua perubahan di branch **`beta`**.
2. Commit dengan referensi `#1`.
3. Compile & smoke test.
4. Merge `beta` → `development` (testing), lalu `development` → `main` (production) setelah stabil.
5. Update deskripsi issue #2 agar path file mengacu ke `src/...`.

## 9. Risiko & Mitigasi

| Risiko | Mitigasi |
|--------|----------|
| Include path salah → gagal compile | Tabel pemetaan eksplisit + static check sebelum handoff |
| `..` di include tidak diterima MetaEditor tertentu | Praktik umum & didukung MQL5; jika gagal, fallback ke struktur flat di `src/` |
| Junction gagal (butuh hak akses) | Script beri pesan jelas; junction (`/J`) tidak perlu admin, beda dgn symlink |
| Nama file dengan spasi (`Tools Palet.mq5`) | Path selalu dikutip di script & include |
```
