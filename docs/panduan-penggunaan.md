# Panduan Penggunaan — Tools Palette (MT5)

Panduan lengkap memakai EA **Tools Palette**: palet alat drawing mirip TradingView
di atas chart MetaTrader 5. Semua objek dirender ke **canvas bitmap** (`CCanvas`),
bukan objek chart MT5 native.

> **Instalasi & compile:** lihat [compile.md](compile.md) jika EA belum terpasang.

---

## 1. Gambaran umum antarmuka

```
┌─────────────────────────────────────────────────────────────┐
│  Chart MT5                                                  │
│                                                             │
│  [Drawing objects di canvas overlay]                        │
│                                                             │
│  ┌──────┐                                                   │
│  │Side- │  ← Sidebar: ikon kategori alat                    │
│  │ bar  │                                                   │
│  │      │     ┌─────────────────┐                          │
│  │ Curs │     │ Flyout          │  ← Daftar alat per kategori│
│  │ Line │     │ • Trendline     │                          │
│  │ Fib  │     │ • Horizontal... │                          │
│  │ ...  │     └─────────────────┘                          │
│  └──────┘                                                   │
│                                                             │
│  [Ribbon properties] ← muncul saat objek dipilih              │
│  [Settings window]   ← panel properti lengkap (ikon gear)    │
└─────────────────────────────────────────────────────────────┘
```

### Komponen utama

| Komponen | Fungsi |
|----------|--------|
| **Sidebar** | Panel vertikal berisi ikon kategori (Cursors, Lines, Fibonacci, dll.) |
| **Flyout** | Panel yang muncul saat kategori diklik — berisi daftar alat dalam kategori |
| **Ribbon** | Toolbar properti cepat di atas objek yang sedang dipilih |
| **Settings** | Jendela properti lengkap (warna, level fibo, koordinat, teks, dll.) |
| **Crosshair** | Reticle + magnifier + label sumbu saat mode Crosshair aktif |

---

## 2. Memulai

1. Attach EA **ToolsPalet** ke chart (lihat [compile.md](compile.md))
2. Pastikan **Algo Trading** aktif
3. Sidebar muncul di tepi chart (kiri atau kanan, tergantung snap state)
4. Klik ikon kategori → pilih alat di flyout → gambar di chart

### Input EA (parameter saat attach)

#### Sidebar & panel

| Input | Default | Keterangan |
|-------|---------|------------|
| `CanvasY` | 50 | Posisi Y sidebar dari atas chart (px) |
| `CategoryIconSize` | 26 | Ukuran ikon kategori (pt) |
| `FlyoutIconSize` | 22 | Ukuran ikon di flyout (pt) |
| `FlyoutLabelSize` | 15 | Ukuran font label flyout (pt) |
| `FlyoutTitleSize` | 14 | Ukuran font judul flyout (pt) |
| `MouseScrollSpeed` | 8 | Kecepatan scroll mouse di sidebar (px) |
| `SnapThreshold` | 40 | Jarak dari tepi chart untuk snap sidebar (px) |

#### Tema & tampilan

| Input | Default | Keterangan |
|-------|---------|------------|
| `StartDark` | false | Mulai dengan tema gelap |
| `BorderWidth` | 1 | Lebar border panel (px); 0 = tanpa border |
| `BackgroundOpacity` | 0.92 | Opacity background panel (0.0–1.0) |

#### Crosshair

| Input | Default | Keterangan |
|-------|---------|------------|
| `ReticleOffset` | 30 | Jarak reticle dari kursor (px) |
| `ReticleTickLen` | 14 | Panjang tick reticle (px) |
| `ReticleThickness` | 2 | Ketebalan garis reticle (px) |
| `MagDiameter` | 180 | Diameter magnifier (px) |
| `MagZoom` | 3.0 | Faktor zoom magnifier |
| `MagOffset` | 45 | Jarak magnifier dari kursor (px) |
| `AxisLabelFontSize` | 9 | Ukuran font label sumbu (pt) |
| `AxisLabelFont` | Arial | Font label sumbu |

---

## 3. Sidebar — navigasi & layout

### Membuka kategori & memilih alat

1. **Klik ikon kategori** di sidebar → flyout terbuka di samping sidebar
2. **Klik alat** di flyout → alat aktif (highlight)
3. Klik lagi alat yang sama → **deaktivasi** (kembali ke mode netral)
4. Klik kategori lain → flyout berganti isi

### Menggeser & resize sidebar

| Aksi | Cara |
|------|------|
| **Pindah panel** | Drag strip grip di header sidebar |
| **Snap ke tepi** | Lepaskan panel dekat tepi kiri/kanan chart (dalam `SnapThreshold` px) |
| **Resize tinggi** | Drag handle di tepi bawah sidebar |
| **Scroll kategori** | Mouse wheel saat kursor di atas area kategori (jika kategori banyak) |

### Tombol header sidebar

| Tombol | Fungsi |
|--------|--------|
| **Close (X)** | Menutup / unload EA dari chart |
| **Theme toggle** | Beralih tema terang ↔ gelap |

---

## 4. Kategori & daftar alat

### Cursors (2 alat)

| Alat | Klik | Keterangan |
|------|------|------------|
| **Pointer** | 0 | Mode seleksi: pilih, drag, edit objek |
| **Crosshair** | 0 | Reticle + magnifier; bisa ukur jarak antar titik |

### Lines (8 alat)

| Alat | Klik | Keterangan |
|------|------|------------|
| Trendline | 2 | Garis antara 2 titik |
| Horizontal line | 1 | Garis horizontal di level harga |
| Vertical line | 1 | Garis vertikal di waktu/bar |
| Ray | 2 | Sinar dari titik 1 melalui titik 2 |
| Extended line | 2 | Garis tak terbatas kedua arah |
| Info line | 2 | Trendline + label info |
| Angle line | 2 | Garis dengan sudut |
| Cross line | 1 | Garis horizontal + vertikal bersilang |

### Channels (3 alat)

| Alat | Klik | Keterangan |
|------|------|------------|
| Parallel channel | 3 | Saluran paralel (3 titik anchor) |
| Regression channel | 2 | Channel regresi linear + band |
| StdDev channel | 2 | Channel standar deviasi |

### Pitchfork (3 alat)

| Alat | Klik | Keterangan |
|------|------|------------|
| Andrew pitchfork | 3 | Pitchfork Andrews klasik |
| Schiff pitchfork | 3 | Variasi Schiff |
| Modified Schiff | 3 | Variasi Modified Schiff |

### Gann (3 alat)

| Alat | Klik | Keterangan |
|------|------|------------|
| Gann line | 2 | Garis Gann |
| Gann fan | 2 | Kipas garis Gann |
| Gann box | 2 | Kotak Gann |

### Fibonacci (6 alat)

| Alat | Klik | Keterangan |
|------|------|------------|
| Fib retracement | 2 | Retracement antara 2 titik |
| Fib expansion | 3 | Ekspansi (3 titik) |
| Fib channel | 3 | Channel fibonacci |
| Fib time zone | 2 | Zona waktu fibonacci |
| Fib speed resistance fan | 2 | Kipas fibonacci |
| Fib speed resistance arcs | 2 | Busur fibonacci |

### Shapes (8 alat)

| Alat | Klik | Keterangan |
|------|------|------------|
| Rectangle | 2 | Kotak axis-aligned |
| Rotated rectangle | 3 | Kotak diputar (3 titik) |
| Path | N | Polyline multi-titik; **double-click** untuk selesai |
| Circle | 2 | Lingkaran (pusat + titik tepi) |
| Triangle | 3 | Segitiga (3 titik) |
| Ellipse | 3 | Elips (3 titik) |
| Arc | 3 | Busur (3 titik) |
| Curve | 3 | Kurva Bezier kuadratik (3 titik) |

### Annotate (9 alat)

| Alat | Klik | Keterangan |
|------|------|------------|
| Text | 1 | Label teks; klik lagi untuk edit |
| Arrow | 2 | Panah anotasi |
| Arrow Marker | 2 | Marker panah |
| Arrow Up | 1 | Panah ke atas |
| Arrow Down | 1 | Panah ke bawah |
| Note | 2 | Catatan dengan ikon |
| Price Note | 2 | Catatan di level harga |
| Callout | 2 | Callout/balon |
| Comment | 1 | Komentar single-click |

### Delete (aksi)

| Aksi | Keterangan |
|------|------------|
| **Delete (ikon tempat sampah)** | Menghapus **semua** objek drawing di chart saat ini |

> Bukan kategori alat — klik ikon ini langsung membersihkan seluruh canvas drawing.

---

## 5. Cara menggambar (placement)

### Pola klik

| Pola | Alat contoh | Langkah |
|------|-------------|---------|
| **1 klik** | H-Line, Text, Comment | Klik sekali di chart → objek terbuat |
| **2 klik** | Trendline, Rectangle, Fib Ret | Klik titik 1 → klik titik 2 → selesai |
| **3 klik** | Parallel Channel, Triangle | Klik P1 → P2 → P3 → selesai |
| **N klik (Path)** | Path | Klik banyak titik → **double-click** untuk commit |
| **0 klik** | Pointer, Crosshair | Tidak membuat objek; mode interaksi saja |

Saat menempatkan objek multi-klik, **rubber-band preview** mengikuti kursor
antara klik.

### Setelah objek terbuat

- Objek baru otomatis **terpilih** (handles + ribbon muncul)
- Alat placement di-**reset** — klik berikutnya membuat objek baru
  (kecuali Anda memilih alat yang sama lagi dari flyout)

### Membatalkan placement

- Tekan **Escape** → batalkan placement yang sedang berjalan
- Ganti ke **Pointer** atau kategori lain → placement dibatalkan otomatis

---

## 6. Mode Pointer — seleksi & edit

Aktifkan **Pointer** dari kategori Cursors.

### Seleksi

| Aksi | Hasil |
|------|-------|
| Klik objek | Objek terpilih; ribbon + label sumbu muncul |
| Klik area kosong | Deselect semua objek |
| Hover objek | Highlight + handles tampil |

### Memindahkan objek

- **Drag body objek** → pindahkan seluruh objek
- **Drag handle (titik anchor)** → ubah posisi titik tertentu

### Mengunci drawing

1. Aktifkan **Pointer**, lalu pilih drawing yang ingin dikunci.
2. Klik ikon **Lock/unlock (gembok)** di ribbon.

Drawing yang terkunci tetap dapat dipilih, diubah style, teks, dan visibilitasnya,
dihapus, serta dibuka kembali kuncinya. Namun, body dan handle tidak dapat digeser.
Klik ikon gembok lagi untuk membuka kunci. Semua jenis drawing mendukung penguncian,
dan status kunci setiap objek tetap tersimpan.

### Menghapus objek

| Cara | Keterangan |
|------|------------|
| **Delete** (keyboard) | Hapus objek yang sedang dipilih |
| **Kategori Delete** | Hapus semua objek sekaligus |

### Edit teks (Text, Note, dll.)

1. Pilih objek teks
2. **Klik** pada body teks (tanpa drag signifikan) → masuk mode edit
3. Ketik teks; **Enter** = baris baru
4. Klik di luar atau ganti alat → commit teks

---

## 7. Ribbon & Settings — mengubah properti

### Ribbon (toolbar cepat)

Muncul otomatis saat objek dipilih. Berisi:

- Warna garis / fill / teks
- Opacity (slider + input angka)
- Lebar garis, style garis
- Font size (untuk objek teks)
- Tombol **Lock/unlock (gembok)** → kunci atau buka posisi dan bentuk drawing
- Tombol **Settings (gear)** → buka panel lengkap

**Popover warna:** klik swatch → pilih warna + opacity → klik di luar untuk tutup.

### Settings window (panel lengkap)

Dibuka dari ikon gear di ribbon. Tab umum:

| Tab | Isi |
|-----|-----|
| **Style** | Warna, opacity, lebar, style per elemen |
| **Coordinates** | Edit time/price tiap anchor point |
| **Text** | Isi teks multi-baris (untuk objek anotasi) |
| **Levels** | Level fibonacci/gann (ratio, warna, visibility) |

**Koordinat:** edit angka di tab Coordinates → tekan Enter untuk commit.

---

## 8. Crosshair & pengukuran

1. Pilih **Crosshair** dari kategori Cursors
2. Gerakkan mouse → reticle + magnifier + label harga/waktu mengikuti
3. **Klik** titik pertama → mulai pengukuran
4. **Klik** titik kedua → tampilkan jarak harga & waktu
5. Ganti ke alat lain → crosshair & pengukuran disembunyikan

Parameter crosshair dapat diatur via input EA (lihat bagian 2).

---

## 9. Persistensi drawing

> Fitur baru di branch `beta` (issue #2).

### Apa yang disimpan

Semua objek drawing disimpan otomatis per-chart ke file:

```
MQL5\Files\ToolsPalette\drawings\<Symbol>_<ChartID>.dat
```

Data yang dipulihkan mencakup jenis drawing, koordinat waktu/harga, style, teks,
visibilitas, dan status kunci per objek.

### Kapan disimpan

- Setelah mutasi (tambah / edit / hapus / drag / ubah properti) — flush debounced ~400 ms
- Saat EA di-unload, termasuk saat **ganti timeframe** (`OnDeinit` → `OnInit`)

### Kapan dipulihkan

- Saat EA di-attach atau chart reload (termasuk setelah ganti timeframe atau restart terminal)

### Isolasi per chart

Setiap chart punya `ChartID` unik → drawing chart A tidak muncul di chart B,
meskipun symbol sama.

### Yang tidak disimpan

- State seleksi (objek selalu dimuat **tidak terpilih**)
- State hover / drag sementara

### Cara verifikasi persistensi

1. Gambar beberapa objek
2. Ganti timeframe M15 → H1 → D1 → kembali M15
3. Restart terminal MT5
4. Cek file `.dat` ada di `MQL5\Files\ToolsPalette\drawings\`

---

## 10. Pintasan keyboard

| Tombol | Konteks | Aksi |
|--------|---------|------|
| **Escape** | Placement aktif | Batalkan placement |
| **Escape** | Popover/settings terbuka | Tutup panel |
| **Delete** | Objek terpilih | Hapus objek |
| **Delete** | Edit teks aktif | Hapus karakter di caret |
| **Backspace** | Edit teks aktif | Hapus karakter sebelum caret |
| **Enter** | Edit teks aktif | Baris baru |
| **Arrow / Home / End** | Edit teks aktif | Navigasi caret |
| **T** | (lihat handler) | Shortcut internal label |

> Saat edit teks aktif, input keyboard chart MT5 dinonaktifkan sementara
> agar pengetikan tidak menggeser chart.

---

## 11. Tips & perilaku khusus

### Ganti timeframe

- Drawing **tetap ada** (persistensi file)
- Sidebar & canvas di-resize otomatis ke dimensi chart baru
- Scroll chart di-lock saat mode Pointer aktif

### Multi-chart

- Buka beberapa chart → attach EA di masing-masing
- Drawing terisolasi per `ChartID`
- Edit di satu chart tidak mempengaruhi chart lain

### Performa

- Dirancang untuk puluhan objek (50+) tanpa lag signifikan
- File persistensi berukuran kecil (teks, beberapa KB)

### Objek bukan native MT5

Drawing dirender ke canvas overlay — objek **tidak** muncul di:
- Daftar Objects MT5 (Ctrl+B)
- Template chart standar MT5
- Export objek chart bawaan MT5

Hanya terlihat selama EA Tools Palette aktif di chart tersebut.

---

## 12. Troubleshooting

| Gejala | Kemungkinan penyebab | Solusi |
|--------|---------------------|--------|
| Sidebar tidak muncul | EA belum attach / Algo Trading off | Attach EA; aktifkan AutoTrading |
| Tidak bisa gambar | Masih di mode Pointer/Crosshair | Pilih alat drawing dari flyout |
| Gambar hilang ganti TF | Compile dari kode lama / EA versi lama | Pastikan branch `beta` ter-compile; cek file `.dat` |
| Flyout tidak terbuka | Klik di luar area sidebar | Klik langsung ikon kategori |
| Keyboard tidak responsif | Mode edit teks aktif | Klik di luar objek teks atau tekan Escape |
| File `.dat` tidak ada | Belum ada mutasi / EA baru attach | Gambar objek, tunggu ~1 detik, atau ganti timeframe |
| Junction rusak setelah pindah folder repo | Path junction invalid | Jalankan ulang `deploy-mt5.ps1` |

---

## 13. Referensi teknis

| Dokumen | Isi |
|---------|-----|
| [compile.md](compile.md) | Deploy, compile, verifikasi |
| [README](../README.md) | Arsitektur & ringkasan proyek |
| `src/core/ToolsPalette_Tools.mqh` | Definisi alat & kategori |
| `src/storage/ToolsPalette_Storage.mqh` | Implementasi penyimpanan file |

---

*Tools Palette — Copyright 2026, Om J. — https://t.me/HZFXI*
