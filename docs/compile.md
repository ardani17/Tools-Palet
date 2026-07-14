# Panduan Compile — Tools Palette (MT5)

Dokumen ini menjelaskan cara men-deploy, compile, dan memverifikasi EA **Tools Palette**
dari source code di repo ke MetaTrader 5.

## Prasyarat

| Item | Keterangan |
|------|------------|
| **MetaTrader 5** | Terminal MT5 terinstall (biasanya `C:\Program Files\MetaTrader 5\`) |
| **MetaEditor** | Terbundel dengan MT5 (`metaeditor64.exe`) |
| **PowerShell** | Untuk menjalankan script deploy (Windows) |
| **Git** | Repo sudah di-clone; branch aktif: `beta` (fitur terbaru) |

> EA ini ditulis dalam **MQL5**. Tidak ada test otomatis — verifikasi utama adalah
> **compile 0 error** + **smoke test manual** di chart.

---

## 1. Deploy source ke folder MT5 (junction)

Tools Palette memakai **directory junction** agar folder `src/` di repo langsung
terbaca oleh MetaEditor tanpa copy manual setiap kali edit.

### 1.1 Cari folder data terminal

1. Buka **MetaTrader 5** atau **MetaEditor**
2. Menu **File → Open Data Folder**
3. Catat path lengkapnya, contoh:

   ```
   C:\Users\ardani\AppData\Roaming\MetaQuotes\Terminal\XXXXXXXX
   ```

   Folder ini berisi subfolder `MQL5\`.

### 1.2 Jalankan script deploy

Dari **root repo** (PowerShell):

```powershell
cd C:\Users\ardani\Documents\APLIKASI\Tools-Palet
.\scripts\deploy-mt5.ps1 -TerminalDataPath "C:\Users\ardani\AppData\Roaming\MetaQuotes\Terminal\XXXXXXXX"
```

**Hasil sukses:**

```
OK. Junction dibuat:
  ...\MQL5\Experts\ToolsPalet  ->  ...\Tools-Palet\src
```

Junction memetakan:

```
<TerminalData>\MQL5\Experts\ToolsPalet  →  <repo>\src
```

Setelah ini, setiap perubahan file di `src/` langsung terlihat di MetaEditor.

### 1.3 Troubleshooting deploy

| Masalah | Solusi |
|---------|--------|
| `Folder Experts tidak ditemukan` | `-TerminalDataPath` salah — harus folder yang berisi `MQL5`, bukan subfolder `MQL5` saja |
| `Path sudah ada dan BUKAN junction` | Hapus/backup folder `Experts\ToolsPalet` yang lama, lalu jalankan script lagi |
| Junction sudah ada | Script otomatis menghapus junction lama dan membuat ulang |

---

## 2. Compile di MetaEditor (cara utama)

1. Buka **MetaEditor** (dari MT5: **Tools → MetaQuotes Language Editor**)
2. Di panel **Navigator**, navigasi ke:

   ```
   Experts\ToolsPalet\Tools Palet.mq5
   ```

3. Buka file tersebut (double-click)
4. Tekan **F7** atau klik tombol **Compile**
5. Periksa tab **Errors** di bagian bawah:

   ```
   0 error(s), 0 warning(s)
   ```

6. Jika sukses, binary terbuat:

   ```
   <repo>\src\Tools Palet.ex5
   ```

   (atau di path yang sama di folder junction MT5)

### File entry point

| File | Peran |
|------|-------|
| `src/Tools Palet.mq5` | Entry point EA — `OnInit`, `OnDeinit`, `OnChartEvent`, `OnTimer` |
| `src/core/*.mqh` | Shell, sidebar, engine inti |
| `src/engine/*.mqh` | Render, interaksi, edit, properties |
| `src/ui/*.mqh` | Ribbon, settings, property widgets |
| `src/tools/*.mqh` | Implementasi per kategori alat |
| `src/storage/*.mqh` | Persistensi drawing ke file |
| `src/primitives/*.mqh` | Helper gambar low-level, tema |

---

## 3. Compile via command line (opsional)

Jika MetaEditor terinstall di path default:

```powershell
& "C:\Program Files\MetaTrader 5\metaeditor64.exe" `
  /compile:"C:\Users\ardani\Documents\APLIKASI\Tools-Palet\src\Tools Palet.mq5" `
  /log
```

Cek hasil di log:

```powershell
Get-Content "C:\Users\ardani\Documents\APLIKASI\Tools-Palet\src\Tools Palet.log" -Tail 5
```

Harus berisi:

```
Result: 0 errors, 0 warnings, ... ms elapsed
```

---

## 4. Attach EA ke chart

1. Buka **MetaTrader 5**
2. Pastikan **Algo Trading** aktif (tombol **AutoTrading** hijau di toolbar)
3. Di **Navigator → Expert Advisors**, cari **ToolsPalet**
4. Drag **ToolsPalet** ke chart yang diinginkan
5. Di dialog properties, sesuaikan input jika perlu (lihat [panduan-penggunaan.md](panduan-penggunaan.md))
6. Klik **OK** — sidebar Tools Palette muncul di chart

### Verifikasi cepat setelah attach

- [ ] Sidebar muncul di kiri atau kanan chart
- [ ] Klik kategori (mis. Lines) → flyout alat terbuka
- [ ] Pilih Trendline → klik 2 titik di chart → garis muncul
- [ ] Ganti timeframe (M15 → H1) → gambar tetap ada (fitur persistensi)

---

## 5. Re-compile setelah edit kode

Karena junction sudah aktif:

1. Edit file di `src/` (di repo atau lewat MetaEditor — keduanya sama)
2. Simpan
3. **F7** di MetaEditor
4. Di MT5: **hapus EA dari chart lalu attach ulang**, atau tunggu MT5 reload otomatis
   (tergantung versi terminal; attach ulang paling aman)

> File `*.ex5` tidak di-track git (`.gitignore`). Binary hanya ada di mesin lokal.

---

## 6. Lokasi file persistensi drawing

Setelah EA berjalan dan Anda menggambar, file penyimpanan dibuat di:

```
<TerminalData>\MQL5\Files\ToolsPalette\drawings\<Symbol>_<ChartID>.dat
```

Contoh:

```
EURUSD_130834981.dat
```

Cara membuka folder Files:

1. MetaEditor/MT5 → **File → Open Data Folder**
2. Masuk ke `MQL5\Files\ToolsPalette\drawings\`

---

## 7. Checklist sebelum merge / release

- [ ] Compile **0 error, 0 warning**
- [ ] EA attach tanpa error di Experts tab
- [ ] Drawing survive ganti timeframe (M1–D1)
- [ ] Drawing survive restart terminal
- [ ] Multi-chart same symbol tidak saling tumpang
- [ ] Create / edit / delete / select / drag masih normal

---

## 8. Referensi

- [Panduan Penggunaan](panduan-penggunaan.md) — cara memakai semua fitur UI
- [README](../README.md) — ringkasan arsitektur dan branch workflow
- Script deploy: `scripts/deploy-mt5.ps1`
