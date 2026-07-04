# Task 1: Scaffold folder `src/` + pindahkan semua file

**Bagian dari:** Refactor struktur project Tools Palette (EA MetaTrader 5). Saat ini 21 file source (`.mqh`/`.mq5`) flat di root repo; task ini memindahkannya ke `src/` berlapis. TIDAK mengubah isi/logika file apa pun — hanya `git mv`.

## Global Constraints (WAJIB dipatuhi)

- Branch kerja: **`beta`**. Jangan pindah/rename branch.
- **Tidak ada** perubahan isi file (logika/kode) di task ini — MURNI pemindahan lokasi via `git mv`.
- **Tidak ada** framework test di MT5. JANGAN menulis unit test MQL5. Verifikasi = **static check** via PowerShell (file ada di lokasi benar, jumlah benar). Ini menggantikan TDD.
- Nama file mengandung spasi (`Tools Palet.mq5`) → SELALU dikutip di command.
- Gunakan `git mv` (bukan hapus+buat ulang) agar history terjaga.
- Semua command dijalankan dari repo root: `C:\Users\ardani\Documents\APLIKASI\Tools-Palet`.
- Shell: PowerShell (Windows). Jangan pakai `&&` sebagai separator.

## Files

- Create (folder): `src/core/`, `src/engine/`, `src/ui/`, `src/tools/`, `src/primitives/`
- Move: 20 `.mqh` + 1 `.mq5` dari root ke subfolder `src/`

## Pemetaan file → folder tujuan

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

> Catatan: `Tools Palet.ex5` (binary) TETAP di root untuk task ini — jangan dipindah/hapus (ditangani task lain).

## Langkah

1. Pastikan di branch `beta`: `git branch --show-current` → harus `beta`.
2. Buat folder:
   ```powershell
   New-Item -ItemType Directory -Force -Path "src\core","src\engine","src\ui","src\tools","src\primitives" | Out-Null
   ```
3. `git mv` entry point:
   ```powershell
   git mv "Tools Palet.mq5" "src/Tools Palet.mq5"
   ```
4. `git mv` core:
   ```powershell
   git mv "ToolsPalette_Shell.mqh"   "src/core/ToolsPalette_Shell.mqh"
   git mv "ToolsPalette_Sidebar.mqh" "src/core/ToolsPalette_Sidebar.mqh"
   git mv "ToolsPalette_Tools.mqh"   "src/core/ToolsPalette_Tools.mqh"
   ```
5. `git mv` engine:
   ```powershell
   git mv "ToolsPalette_Engine_Render.mqh"     "src/engine/ToolsPalette_Engine_Render.mqh"
   git mv "ToolsPalette_Engine_Interact.mqh"   "src/engine/ToolsPalette_Engine_Interact.mqh"
   git mv "ToolsPalette_Engine_Edit.mqh"       "src/engine/ToolsPalette_Engine_Edit.mqh"
   git mv "ToolsPalette_Engine_Properties.mqh" "src/engine/ToolsPalette_Engine_Properties.mqh"
   ```
6. `git mv` ui:
   ```powershell
   git mv "ToolsPalette_Ribbon.mqh"            "src/ui/ToolsPalette_Ribbon.mqh"
   git mv "ToolsPalette_Settings.mqh"          "src/ui/ToolsPalette_Settings.mqh"
   git mv "ToolsPalette_Settings_Interact.mqh" "src/ui/ToolsPalette_Settings_Interact.mqh"
   git mv "ToolsPalette_PropertyWidgets.mqh"   "src/ui/ToolsPalette_PropertyWidgets.mqh"
   git mv "ToolsPalette_Properties.mqh"        "src/ui/ToolsPalette_Properties.mqh"
   ```
7. `git mv` tools:
   ```powershell
   git mv "ToolsPalette_Lines.mqh"       "src/tools/ToolsPalette_Lines.mqh"
   git mv "ToolsPalette_Shapes.mqh"      "src/tools/ToolsPalette_Shapes.mqh"
   git mv "ToolsPalette_Fibonacci.mqh"   "src/tools/ToolsPalette_Fibonacci.mqh"
   git mv "ToolsPalette_Channels.mqh"    "src/tools/ToolsPalette_Channels.mqh"
   git mv "ToolsPalette_Annotations.mqh" "src/tools/ToolsPalette_Annotations.mqh"
   git mv "ToolsPalette_Crosshair.mqh"   "src/tools/ToolsPalette_Crosshair.mqh"
   ```
8. `git mv` primitives:
   ```powershell
   git mv "ToolsPalette_Primitives.mqh" "src/primitives/ToolsPalette_Primitives.mqh"
   ```
9. Verifikasi statis:
   ```powershell
   Write-Host "Root .mqh/.mq5 (harus 0):"; (Get-ChildItem -File | Where-Object { $_.Extension -in ".mqh",".mq5" }).Count
   Write-Host "src total .mqh/.mq5 (harus 21):"; (Get-ChildItem -Recurse src -File | Where-Object { $_.Extension -in ".mqh",".mq5" }).Count
   git status --short
   ```
   Expected: root = `0`, src = `21`, git status menampilkan 21 entri renamed (`R`).
10. Commit:
    ```powershell
    git add -A
    git commit -m "refactor: move source into src/ layered folders (#1)"
    ```

## Acceptance Criteria

- [ ] 5 folder `src/` terbuat.
- [ ] Semua 21 file source ada di folder sesuai pemetaan.
- [ ] Root repo tidak lagi punya `.mqh`/`.mq5` (0).
- [ ] `git status` menunjukkan operasi rename (bukan delete+add) → history terjaga.
- [ ] Isi file tidak berubah (hanya lokasi).
- [ ] Commit dibuat dengan pesan persis: `refactor: move source into src/ layered folders (#1)`.
