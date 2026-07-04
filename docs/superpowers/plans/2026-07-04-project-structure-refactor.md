# Project Structure Refactor Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reorganisir source Tools Palette (flat di root) menjadi struktur `src/` berlapis (`core/`, `engine/`, `ui/`, `tools/`, `primitives/`) yang self-contained dan compile-able via junction, tanpa mengubah behavior EA.

**Architecture:** Semua file `.mqh`/`.mq5` dipindah ke `src/` dengan `git mv` (mempertahankan history), lalu 15 baris `#include` lintas-folder di-update ke path relatif (`../folder/...`). Ditambah `.gitignore`, `README.md`, dan script PowerShell pembuat junction ke `MQL5\Experts`.

**Tech Stack:** MQL5 (MetaTrader 5), PowerShell (Windows), Git.

## Global Constraints

- Branch kerja: **`beta`** (semua commit di sini; merge ke `development` lalu `main` menyusul).
- **Tidak ada** perubahan logika/behavior — murni pemindahan file + path include.
- **Tidak ada** framework test di MT5. Verifikasi tiap task = **static check** (shell/grep: file ada, tidak ada include usang). Compile final di MetaEditor = tanggung jawab user.
- Nama file mengandung spasi (`Tools Palet.mq5`, `Tools Palet.ex5`) → **selalu** dikutip di command.
- Gunakan `git mv` (bukan hapus+buat ulang) agar history file terjaga.
- MQL5 `#include "..."` bersifat relatif terhadap file pemuat; `..` didukung.
- Semua command dijalankan dari repo root: `C:\Users\ardani\Documents\APLIKASI\Tools-Palet`.

---

### Task 1: Scaffold folder `src/` + pindahkan semua file

**Files:**
- Create (folder): `src/core/`, `src/engine/`, `src/ui/`, `src/tools/`, `src/primitives/`
- Move: 20 `.mqh` + 1 `.mq5` dari root ke subfolder `src/` (lihat pemetaan)

**Interfaces:**
- Consumes: kondisi awal — semua source flat di root repo.
- Produces: pohon `src/` berisi seluruh source di folder masing-masing; root repo bersih dari `.mqh`/`.mq5`. Path baru dikonsumsi Task 2.

- [ ] **Step 1: Pastikan berada di branch `beta` dan working tree bersih**

Run:
```powershell
git branch --show-current; git status --short
```
Expected: output `beta`, dan tidak ada perubahan tertunda selain yang diharapkan.

- [ ] **Step 2: Buat struktur folder**

Run:
```powershell
New-Item -ItemType Directory -Force -Path "src\core","src\engine","src\ui","src\tools","src\primitives" | Out-Null
```
Expected: 5 folder terbuat (tidak error).

- [ ] **Step 3: Pindahkan entry point ke `src/`**

Run:
```powershell
git mv "Tools Palet.mq5" "src/Tools Palet.mq5"
```

- [ ] **Step 4: Pindahkan file `core/`**

Run:
```powershell
git mv "ToolsPalette_Shell.mqh"   "src/core/ToolsPalette_Shell.mqh"
git mv "ToolsPalette_Sidebar.mqh" "src/core/ToolsPalette_Sidebar.mqh"
git mv "ToolsPalette_Tools.mqh"   "src/core/ToolsPalette_Tools.mqh"
```

- [ ] **Step 5: Pindahkan file `engine/`**

Run:
```powershell
git mv "ToolsPalette_Engine_Render.mqh"     "src/engine/ToolsPalette_Engine_Render.mqh"
git mv "ToolsPalette_Engine_Interact.mqh"   "src/engine/ToolsPalette_Engine_Interact.mqh"
git mv "ToolsPalette_Engine_Edit.mqh"       "src/engine/ToolsPalette_Engine_Edit.mqh"
git mv "ToolsPalette_Engine_Properties.mqh" "src/engine/ToolsPalette_Engine_Properties.mqh"
```

- [ ] **Step 6: Pindahkan file `ui/`**

Run:
```powershell
git mv "ToolsPalette_Ribbon.mqh"            "src/ui/ToolsPalette_Ribbon.mqh"
git mv "ToolsPalette_Settings.mqh"          "src/ui/ToolsPalette_Settings.mqh"
git mv "ToolsPalette_Settings_Interact.mqh" "src/ui/ToolsPalette_Settings_Interact.mqh"
git mv "ToolsPalette_PropertyWidgets.mqh"   "src/ui/ToolsPalette_PropertyWidgets.mqh"
git mv "ToolsPalette_Properties.mqh"        "src/ui/ToolsPalette_Properties.mqh"
```

- [ ] **Step 7: Pindahkan file `tools/`**

Run:
```powershell
git mv "ToolsPalette_Lines.mqh"       "src/tools/ToolsPalette_Lines.mqh"
git mv "ToolsPalette_Shapes.mqh"      "src/tools/ToolsPalette_Shapes.mqh"
git mv "ToolsPalette_Fibonacci.mqh"   "src/tools/ToolsPalette_Fibonacci.mqh"
git mv "ToolsPalette_Channels.mqh"    "src/tools/ToolsPalette_Channels.mqh"
git mv "ToolsPalette_Annotations.mqh" "src/tools/ToolsPalette_Annotations.mqh"
git mv "ToolsPalette_Crosshair.mqh"   "src/tools/ToolsPalette_Crosshair.mqh"
```

- [ ] **Step 8: Pindahkan file `primitives/`**

Run:
```powershell
git mv "ToolsPalette_Primitives.mqh" "src/primitives/ToolsPalette_Primitives.mqh"
```

- [ ] **Step 9: Verifikasi statis — root bersih & jumlah file benar**

Run:
```powershell
Write-Host "Root .mqh/.mq5 (harus 0):"; (Get-ChildItem -File | Where-Object { $_.Extension -in ".mqh",".mq5" }).Count
Write-Host "src total .mqh/.mq5 (harus 20):"; (Get-ChildItem -Recurse src -File | Where-Object { $_.Extension -in ".mqh",".mq5" }).Count
git status --short
```
Expected: root = `0`, src total = `20`, `git status` menampilkan 20 entri `R` (renamed).

- [ ] **Step 10: Commit**

Run:
```powershell
git add -A
git commit -m "refactor: move source into src/ layered folders (#1)"
```
Expected: commit sukses, 20 file renamed.

---

### Task 2: Update `#include` lintas-folder (15 baris)

**Files:**
- Modify: `src/Tools Palet.mq5`
- Modify: `src/core/ToolsPalette_Tools.mqh`
- Modify: `src/core/ToolsPalette_Shell.mqh`
- Modify: `src/engine/ToolsPalette_Engine_Render.mqh`
- Modify: `src/engine/ToolsPalette_Engine_Interact.mqh`
- Modify: `src/engine/ToolsPalette_Engine_Edit.mqh`
- Modify: `src/engine/ToolsPalette_Engine_Properties.mqh`
- Modify: `src/ui/ToolsPalette_Ribbon.mqh`
- Modify: `src/ui/ToolsPalette_PropertyWidgets.mqh`
- Modify: `src/ui/ToolsPalette_Properties.mqh`
- Modify: `src/tools/ToolsPalette_Crosshair.mqh`

**Interfaces:**
- Consumes: pohon `src/` dari Task 1.
- Produces: seluruh `#include` menunjuk path valid relatif terhadap lokasi baru; EA siap compile. Tidak ada interface kode berubah.

> Include **sesama folder tidak diubah** (Sidebar↔Tools, Settings↔Ribbon↔Settings_Interact, Shapes→Fibonacci→Channels→Lines→Crosshair, Annotations→Shapes, Ribbon→Properties/PropertyWidgets). Hanya 15 baris lintas-folder di bawah ini yang diubah.

- [ ] **Step 1: `src/Tools Palet.mq5` — entry point**

Ganti:
```mql5
#include "ToolsPalette_Shell.mqh"
```
menjadi:
```mql5
#include "core/ToolsPalette_Shell.mqh"
```

- [ ] **Step 2: `src/core/ToolsPalette_Tools.mqh` — 5 include (1 tools + 4 engine)**

Ganti baris 16:
```mql5
#include "ToolsPalette_Annotations.mqh"
```
menjadi:
```mql5
#include "../tools/ToolsPalette_Annotations.mqh"
```

Ganti blok (baris ~2445-2448):
```mql5
#include "ToolsPalette_Engine_Edit.mqh"
#include "ToolsPalette_Engine_Interact.mqh"
#include "ToolsPalette_Engine_Render.mqh"
#include "ToolsPalette_Engine_Properties.mqh"
```
menjadi:
```mql5
#include "../engine/ToolsPalette_Engine_Edit.mqh"
#include "../engine/ToolsPalette_Engine_Interact.mqh"
#include "../engine/ToolsPalette_Engine_Render.mqh"
#include "../engine/ToolsPalette_Engine_Properties.mqh"
```

- [ ] **Step 3: `src/core/ToolsPalette_Shell.mqh` — 2 include ke ui/**

Ganti (baris ~19-20):
```mql5
#include "ToolsPalette_Ribbon.mqh"
#include "ToolsPalette_Settings.mqh"
```
menjadi:
```mql5
#include "../ui/ToolsPalette_Ribbon.mqh"
#include "../ui/ToolsPalette_Settings.mqh"
```

> Baris `#include "ToolsPalette_Sidebar.mqh"` (baris 16) **tetap** — Sidebar sesama folder `core/`.

- [ ] **Step 4: `src/engine/ToolsPalette_Engine_Render.mqh` — ke core/**

Ganti baris 16:
```mql5
#include "ToolsPalette_Tools.mqh"
```
menjadi:
```mql5
#include "../core/ToolsPalette_Tools.mqh"
```

- [ ] **Step 5: `src/engine/ToolsPalette_Engine_Interact.mqh` — ke core/**

Ganti baris 16:
```mql5
#include "ToolsPalette_Tools.mqh"
```
menjadi:
```mql5
#include "../core/ToolsPalette_Tools.mqh"
```

- [ ] **Step 6: `src/engine/ToolsPalette_Engine_Edit.mqh` — ke core/**

Ganti baris 16:
```mql5
#include "ToolsPalette_Tools.mqh"
```
menjadi:
```mql5
#include "../core/ToolsPalette_Tools.mqh"
```

- [ ] **Step 7: `src/engine/ToolsPalette_Engine_Properties.mqh` — ke core/**

Ganti baris 16:
```mql5
#include "ToolsPalette_Tools.mqh"
```
menjadi:
```mql5
#include "../core/ToolsPalette_Tools.mqh"
```

- [ ] **Step 8: `src/ui/ToolsPalette_Ribbon.mqh` — 1 include ke core/**

Ganti baris 16:
```mql5
#include "ToolsPalette_Sidebar.mqh"
```
menjadi:
```mql5
#include "../core/ToolsPalette_Sidebar.mqh"
```

> Baris 17-18 (`ToolsPalette_Properties.mqh`, `ToolsPalette_PropertyWidgets.mqh`) **tetap** — sesama folder `ui/`.

- [ ] **Step 9: `src/ui/ToolsPalette_PropertyWidgets.mqh` — ke core/**

Ganti baris 16:
```mql5
#include "ToolsPalette_Sidebar.mqh"
```
menjadi:
```mql5
#include "../core/ToolsPalette_Sidebar.mqh"
```

- [ ] **Step 10: `src/ui/ToolsPalette_Properties.mqh` — ke core/**

Ganti baris 16:
```mql5
#include "ToolsPalette_Tools.mqh"
```
menjadi:
```mql5
#include "../core/ToolsPalette_Tools.mqh"
```

- [ ] **Step 11: `src/tools/ToolsPalette_Crosshair.mqh` — ke primitives/**

Ganti baris 16:
```mql5
#include "ToolsPalette_Primitives.mqh"
```
menjadi:
```mql5
#include "../primitives/ToolsPalette_Primitives.mqh"
```

- [ ] **Step 12: Verifikasi statis — tidak ada include usang & semua target ada**

Run (cek tidak ada include lintas-folder yang masih flat):
```powershell
Write-Host "=== Semua include (untuk inspeksi manual) ==="
Select-String -Path "src\*.mq5","src\**\*.mqh" -Pattern '#include\s+"' | ForEach-Object { $_.RelativePath = (Resolve-Path -Relative $_.Path); "$($_.Path):$($_.LineNumber): $($_.Line.Trim())" }
```

Run (validasi tiap include resolve ke file yang ada):
```powershell
$bad = 0
Get-ChildItem -Recurse src -Include *.mqh,*.mq5 -File | ForEach-Object {
  $dir = $_.DirectoryName
  Select-String -Path $_.FullName -Pattern '#include\s+"([^"]+)"' | ForEach-Object {
    $inc = $_.Matches[0].Groups[1].Value
    $full = Join-Path $dir $inc
    if (-not (Test-Path $full)) { Write-Host "MISSING: $($_.Path) -> $inc"; $script:bad++ }
  }
}
Write-Host "Broken includes (harus 0): $bad"
```
Expected: `Broken includes (harus 0): 0`.

- [ ] **Step 13: Commit**

Run:
```powershell
git add -A
git commit -m "refactor: update include paths for src/ layout (#1)"
```

---

### Task 3: Tambah `.gitignore` + untrack binary `.ex5`

**Files:**
- Create: `.gitignore`
- Untrack: `Tools Palet.ex5`

**Interfaces:**
- Consumes: repo pasca-Task 2.
- Produces: `.ex5` tidak lagi di-track; binary compile mendatang otomatis diabaikan.

- [ ] **Step 1: Buat `.gitignore`**

Buat file `.gitignore` di root repo dengan isi:
```gitignore
# MetaTrader compiled binary
*.ex5

# MetaTrader logs & temp
*.log
*.tmp

# OS
Thumbs.db
Desktop.ini
```

- [ ] **Step 2: Untrack binary lama + hapus file stale di root**

Run:
```powershell
git rm --cached "Tools Palet.ex5"
Remove-Item "Tools Palet.ex5" -ErrorAction SilentlyContinue
```
Expected: `rm 'Tools Palet.ex5'` (keluar dari index). File fisik stale di root dihapus (hasil compile baru akan muncul di `src/`).

- [ ] **Step 3: Verifikasi statis — .ex5 tidak ter-track & ter-ignore**

Run:
```powershell
Write-Host "Tracked .ex5 (harus kosong):"; git ls-files "*.ex5"
Write-Host "Ignore check:"; git check-ignore "src/Tools Palet.ex5"
```
Expected: baris pertama kosong; baris kedua mengembalikan `src/Tools Palet.ex5` (artinya ter-ignore).

- [ ] **Step 4: Commit**

Run:
```powershell
git add -A
git commit -m "chore: add .gitignore and untrack compiled .ex5 (#1)"
```

---

### Task 4: Script deploy junction ke MT5

**Files:**
- Create: `scripts/deploy-mt5.ps1`

**Interfaces:**
- Consumes: folder `src/` sebagai sumber junction.
- Produces: perintah `deploy-mt5.ps1 -TerminalDataPath <path>` membuat junction `MQL5\Experts\ToolsPalet` → `<repo>\src`.

- [ ] **Step 1: Buat `scripts/deploy-mt5.ps1`**

Buat file `scripts/deploy-mt5.ps1` dengan isi:
```powershell
<#
.SYNOPSIS
  Deploy Tools Palette ke MetaTrader 5 via junction (tanpa copy manual).
.DESCRIPTION
  Membuat directory junction: <TerminalDataPath>\MQL5\Experts\ToolsPalet -> <repo>\src
  Junction (/J) tidak butuh hak admin, beda dengan symbolic link.
.PARAMETER TerminalDataPath
  Path folder data terminal MT5 (yang berisi subfolder MQL5).
  Cari via MetaEditor/Terminal: File > Open Data Folder.
.EXAMPLE
  .\scripts\deploy-mt5.ps1 -TerminalDataPath "C:\Users\ardani\AppData\Roaming\MetaQuotes\Terminal\<HASH>"
#>
param(
    [Parameter(Mandatory = $true)]
    [string]$TerminalDataPath
)

$ErrorActionPreference = "Stop"

# Repo root = parent dari folder scripts ini
$repoRoot = Split-Path -Parent $PSScriptRoot
$srcPath  = Join-Path $repoRoot "src"

if (-not (Test-Path $srcPath)) {
    Write-Error "Folder src/ tidak ditemukan di: $srcPath"
    exit 1
}

$expertsPath = Join-Path $TerminalDataPath "MQL5\Experts"
if (-not (Test-Path $expertsPath)) {
    Write-Error "Folder Experts tidak ditemukan: $expertsPath`nPastikan -TerminalDataPath menunjuk folder data MT5 (berisi MQL5). Di terminal: File > Open Data Folder."
    exit 1
}

$linkPath = Join-Path $expertsPath "ToolsPalet"

if (Test-Path $linkPath) {
    $item = Get-Item $linkPath -Force
    if ($item.LinkType) {
        Write-Host "Junction sudah ada, menghapus yang lama: $linkPath"
        (Get-Item $linkPath -Force).Delete()
    } else {
        Write-Error "Path sudah ada dan BUKAN junction (folder/file asli): $linkPath`nHapus/backup manual dulu sebelum menjalankan script ini."
        exit 1
    }
}

New-Item -ItemType Junction -Path $linkPath -Target $srcPath | Out-Null

Write-Host ""
Write-Host "OK. Junction dibuat:" -ForegroundColor Green
Write-Host "  $linkPath  ->  $srcPath"
Write-Host ""
Write-Host "Langkah berikut:"
Write-Host "  1. Buka MetaEditor"
Write-Host "  2. Navigasi: Experts\ToolsPalet\Tools Palet.mq5"
Write-Host "  3. Compile (F7) -> pastikan 0 error, 0 warning"
```

- [ ] **Step 2: Verifikasi statis — syntax script valid**

Run:
```powershell
powershell -NoProfile -Command "[void][System.Management.Automation.Language.Parser]::ParseFile('scripts\deploy-mt5.ps1',[ref]$null,[ref]$null); Write-Host 'Parse OK'"
```
Expected: `Parse OK` (tidak ada syntax error).

- [ ] **Step 3: Commit**

Run:
```powershell
git add -A
git commit -m "chore: add MT5 junction deploy script (#1)"
```

---

### Task 5: README

**Files:**
- Create: `README.md`

**Interfaces:**
- Consumes: struktur final repo.
- Produces: dokumentasi onboarding (deskripsi, arsitektur, install, workflow branch).

- [ ] **Step 1: Buat `README.md`**

Buat file `README.md` di root dengan isi:
```markdown
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
```

- [ ] **Step 2: Commit**

Run:
```powershell
git add -A
git commit -m "docs: add README with architecture, install, workflow (#1)"
```

---

### Task 6: Verifikasi final & handoff compile

**Files:** tidak ada perubahan kode (verifikasi + dokumentasi status).

**Interfaces:**
- Consumes: hasil Task 1-5.
- Produces: konfirmasi struktur benar; instruksi compile/smoke test untuk user; update issue #2.

- [ ] **Step 1: Verifikasi struktur final**

Run:
```powershell
Write-Host "=== Tree src/ ==="; Get-ChildItem -Recurse src -File | ForEach-Object { $_.FullName.Replace((Get-Location).Path + "\", "") } | Sort-Object
Write-Host "`n=== Root (harus tak ada .mqh/.mq5/.ex5) ==="; Get-ChildItem -File | Where-Object { $_.Extension -in ".mqh",".mq5",".ex5" }
Write-Host "`n=== Broken include check ==="
$bad = 0
Get-ChildItem -Recurse src -Include *.mqh,*.mq5 -File | ForEach-Object {
  $dir = $_.DirectoryName
  Select-String -Path $_.FullName -Pattern '#include\s+"([^"]+)"' | ForEach-Object {
    $inc = $_.Matches[0].Groups[1].Value
    if (-not (Test-Path (Join-Path $dir $inc))) { Write-Host "MISSING: $($_.Path) -> $inc"; $script:bad++ }
  }
}
Write-Host "Broken includes (harus 0): $bad"
```
Expected: 20 file source di `src/`, root tidak ada `.mqh/.mq5/.ex5`, broken includes = `0`.

- [ ] **Step 2: [USER] Compile di MetaEditor**

Instruksi untuk user (agent tidak bisa menjalankan MetaEditor):
1. Jalankan `.\scripts\deploy-mt5.ps1 -TerminalDataPath "<path data MT5>"`.
2. Buka `Experts\ToolsPalet\Tools Palet.mq5` di MetaEditor, tekan **F7**.
3. Konfirmasi **0 error, 0 warning**.

Jika ada error include: cek pesan, cocokkan dengan tabel di spec §5, perbaiki path, ulangi.

- [ ] **Step 3: [USER] Smoke test manual di MT5**

1. Attach EA `ToolsPalet` ke chart.
2. Gambar beberapa objek (trendline, rectangle, fibonacci).
3. Buka sidebar, ribbon properties, settings window.
4. Konfirmasi tampil & berfungsi seperti sebelum refactor.

- [ ] **Step 4: Update issue #2 (path baru)**

Run (sesuaikan referensi file ke `src/...`):
```powershell
gh issue comment 2 --repo ardani17/Tools-Palet --body "Setelah refactor #1, path file berubah: m_drawnObjects[] ada di ``src/core/ToolsPalette_Tools.mqh``, RedrawAllObjects() di ``src/engine/ToolsPalette_Engine_Render.mqh``, OnChartChangeEvent() di ``src/core/ToolsPalette_Shell.mqh``, OnInit/OnDeinit di ``src/Tools Palet.mq5``. Modul persistence baru diletakkan di ``src/storage/``."
```

- [ ] **Step 5: Merge ke development (setelah compile & smoke test OK)**

Run:
```powershell
git checkout development
git merge --no-ff beta -m "merge: project structure refactor from beta (#1)"
git push origin development
git checkout beta
```

> Merge `development` -> `main` menyusul setelah testing di `development` dianggap stabil (langkah terpisah, atas keputusan user).

## Self-Review

**Spec coverage:**
- Struktur folder (spec §4) → Task 1. ✓
- Perubahan include 15 baris (spec §5) → Task 2 (semua baris tercakup). ✓
- `.gitignore` + untrack .ex5 (spec §6) → Task 3. ✓
- `deploy-mt5.ps1` (spec §6) → Task 4. ✓
- `README.md` (spec §6) → Task 5. ✓
- Verifikasi & rollout git (spec §7-8) → Task 6. ✓
- Update issue #2 (spec §8) → Task 6 Step 4. ✓

**Placeholder scan:** Tidak ada TBD/TODO; semua step berisi command/konten konkret. Langkah yang butuh MetaEditor ditandai eksplisit `[USER]` karena di luar kemampuan agent. ✓

**Type consistency:** Tidak ada perubahan signature/tipe (murni pemindahan file + path include). Nama file di tabel Task 2 konsisten dengan pemetaan Task 1. ✓
