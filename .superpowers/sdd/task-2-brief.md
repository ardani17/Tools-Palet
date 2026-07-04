# Task 2: Update `#include` lintas-folder

**Bagian dari:** Refactor struktur Tools Palette (EA MetaTrader 5). Task 1 sudah memindahkan 20 file source ke `src/` berlapis. Sekarang path `#include` yang menunjuk file di folder LAIN harus diperbaiki ke path relatif, agar EA bisa compile dari struktur baru.

## Global Constraints (WAJIB)

- Branch kerja: **`beta`**. Jangan pindah/rename branch.
- Ubah **HANYA baris `#include`** yang tercantum di tabel bawah. JANGAN sentuh kode lain.
- Include **sesama folder TIDAK diubah** (biarkan apa adanya).
- **Tidak ada** framework test MT5. JANGAN tulis unit test. Verifikasi = **static check** PowerShell (tiap include resolve ke file yang ada).
- MQL5 `#include "..."` relatif terhadap file pemuat; `..` = folder induk. Contoh dari file di `src/engine/`, `"../core/X.mqh"` menunjuk `src/core/X.mqh`.
- Shell: PowerShell (Windows). Jangan pakai `&&`. Kutip path berisi spasi.
- Repo root: `C:\Users\ardani\Documents\APLIKASI\Tools-Palet`.

## Files yang dimodifikasi (11 file, total 15 baris)

### 1. `src/Tools Palet.mq5`
`"ToolsPalette_Shell.mqh"` → `"core/ToolsPalette_Shell.mqh"`

### 2. `src/core/ToolsPalette_Tools.mqh` (5 baris)
- `"ToolsPalette_Annotations.mqh"` → `"../tools/ToolsPalette_Annotations.mqh"`
- `"ToolsPalette_Engine_Edit.mqh"` → `"../engine/ToolsPalette_Engine_Edit.mqh"`
- `"ToolsPalette_Engine_Interact.mqh"` → `"../engine/ToolsPalette_Engine_Interact.mqh"`
- `"ToolsPalette_Engine_Render.mqh"` → `"../engine/ToolsPalette_Engine_Render.mqh"`
- `"ToolsPalette_Engine_Properties.mqh"` → `"../engine/ToolsPalette_Engine_Properties.mqh"`

### 3. `src/core/ToolsPalette_Shell.mqh` (2 baris)
- `"ToolsPalette_Ribbon.mqh"` → `"../ui/ToolsPalette_Ribbon.mqh"`
- `"ToolsPalette_Settings.mqh"` → `"../ui/ToolsPalette_Settings.mqh"`
- (BIARKAN `"ToolsPalette_Sidebar.mqh"` — sesama folder core/)

### 4. `src/engine/ToolsPalette_Engine_Render.mqh`
`"ToolsPalette_Tools.mqh"` → `"../core/ToolsPalette_Tools.mqh"`

### 5. `src/engine/ToolsPalette_Engine_Interact.mqh`
`"ToolsPalette_Tools.mqh"` → `"../core/ToolsPalette_Tools.mqh"`

### 6. `src/engine/ToolsPalette_Engine_Edit.mqh`
`"ToolsPalette_Tools.mqh"` → `"../core/ToolsPalette_Tools.mqh"`

### 7. `src/engine/ToolsPalette_Engine_Properties.mqh`
`"ToolsPalette_Tools.mqh"` → `"../core/ToolsPalette_Tools.mqh"`

### 8. `src/ui/ToolsPalette_Ribbon.mqh`
- `"ToolsPalette_Sidebar.mqh"` → `"../core/ToolsPalette_Sidebar.mqh"`
- (BIARKAN `"ToolsPalette_Properties.mqh"` & `"ToolsPalette_PropertyWidgets.mqh"` — sesama folder ui/)

### 9. `src/ui/ToolsPalette_PropertyWidgets.mqh`
`"ToolsPalette_Sidebar.mqh"` → `"../core/ToolsPalette_Sidebar.mqh"`

### 10. `src/ui/ToolsPalette_Properties.mqh`
`"ToolsPalette_Tools.mqh"` → `"../core/ToolsPalette_Tools.mqh"`

### 11. `src/tools/ToolsPalette_Crosshair.mqh`
`"ToolsPalette_Primitives.mqh"` → `"../primitives/ToolsPalette_Primitives.mqh"`

## Include yang HARUS TETAP (jangan diubah — sesama folder)

- `src/core/ToolsPalette_Sidebar.mqh`: `"ToolsPalette_Tools.mqh"`
- `src/core/ToolsPalette_Shell.mqh`: `"ToolsPalette_Sidebar.mqh"`
- `src/ui/ToolsPalette_Settings.mqh`: `"ToolsPalette_Ribbon.mqh"`, `"ToolsPalette_Settings_Interact.mqh"`
- `src/ui/ToolsPalette_Settings_Interact.mqh`: `"ToolsPalette_Settings.mqh"`
- `src/ui/ToolsPalette_Ribbon.mqh`: `"ToolsPalette_Properties.mqh"`, `"ToolsPalette_PropertyWidgets.mqh"`
- `src/tools/ToolsPalette_Shapes.mqh`: `"ToolsPalette_Fibonacci.mqh"`
- `src/tools/ToolsPalette_Fibonacci.mqh`: `"ToolsPalette_Channels.mqh"`
- `src/tools/ToolsPalette_Channels.mqh`: `"ToolsPalette_Lines.mqh"`
- `src/tools/ToolsPalette_Lines.mqh`: `"ToolsPalette_Crosshair.mqh"`
- `src/tools/ToolsPalette_Annotations.mqh`: `"ToolsPalette_Shapes.mqh"`

## Verifikasi statis (WAJIB jalankan sebelum commit)

Cek semua include resolve ke file yang ada:
```powershell
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
Expected: `Broken includes (harus 0): 0`.

Juga pastikan tidak ada include flat lintas-folder yang tertinggal — inspeksi manual daftar semua include:
```powershell
Select-String -Path "src\*.mq5","src\core\*.mqh","src\engine\*.mqh","src\ui\*.mqh","src\tools\*.mqh","src\primitives\*.mqh" -Pattern '#include\s+"' | ForEach-Object { "$($_.Filename):$($_.LineNumber): $($_.Line.Trim())" }
```

## Commit

```powershell
git add -A
git commit -m "refactor: update include paths for src/ layout (#1)"
```

## Acceptance Criteria

- [ ] 15 baris include lintas-folder diubah persis sesuai tabel.
- [ ] Include sesama folder tidak diubah.
- [ ] Tidak ada kode non-include yang berubah.
- [ ] `Broken includes (harus 0): 0`.
- [ ] Commit dibuat dengan pesan persis: `refactor: update include paths for src/ layout (#1)`.
