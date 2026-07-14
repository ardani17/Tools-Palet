# Changelog

Semua perubahan penting pada proyek **Tools Palette (MT5)** didokumentasikan di file ini.

Format mengikuti [Keep a Changelog](https://keepachangelog.com/id/1.1.0/),
dan proyek ini memakai [Semantic Versioning](https://semver.org/lang/id/).

## [1.1.0] - 2026-07-14

### Added

- **Lock drawing universal** melalui ikon gembok di ribbon. Drawing terkunci
  tetap dapat dipilih, diubah style/teks/visibility-nya, dihapus, dan dibuka
  kembali, tetapi tidak dapat dipindahkan atau diubah bentuknya.
- Status lock disimpan bersama drawing dan dipulihkan setelah ganti timeframe
  maupun restart terminal.

### Changed

- Lock juga memblokir perubahan koordinat melalui Settings agar anchor drawing
  tidak dapat bergeser dari jalur mana pun.

## [1.0.0] - 2026-07-04

Rilis stabil pertama ke `main`. EA menyediakan palet alat drawing lengkap
di atas chart MetaTrader 5 (mirip TradingView), dirender ke canvas bitmap
(`CCanvas`) alih-alih objek chart MT5 native.

### Added

- **Palet alat drawing** dengan kategori: Cursors (Pointer, Crosshair),
  Lines (8 alat), Channels (3), Pitchfork (3), Gann (3), Fibonacci (6),
  Shapes (8), Annotate (9), dan aksi Delete.
- **Sidebar + flyout** — panel kategori vertikal yang bisa digeser,
  di-snap ke tepi chart, dan di-resize.
- **Ribbon properti cepat** dan **Settings window** (Style, Coordinates,
  Text, Levels) untuk mengedit objek terpilih.
- **Crosshair** dengan reticle, magnifier, dan label sumbu harga/waktu,
  plus pengukuran jarak antar titik.
- **Persistensi drawing** — objek disimpan ke
  `MQL5\Files\ToolsPalette\drawings\<Symbol>_<ChartID>.dat`, dipulihkan saat
  init, dan bertahan ketika ganti timeframe / restart terminal
  (flush debounced ~400 ms + saat `OnDeinit`).
- **Input EA** untuk sidebar/panel, tema (terang/gelap), dan crosshair.
- **Tema terang/gelap** dengan toggle di header sidebar.
- **Script deploy** `scripts/deploy-mt5.ps1` — membuat directory junction ke
  folder MT5 sehingga `src/` langsung terbaca MetaEditor tanpa copy manual.
- **Dokumentasi**: [panduan compile](docs/compile.md) dan
  [panduan penggunaan](docs/panduan-penggunaan.md) lengkap, plus README arsitektur.

### Changed

- **Struktur proyek** dirapikan ke layout berlapis di `src/`
  (`core/`, `engine/`, `ui/`, `tools/`, `primitives/`, `storage/`).
- **Copyright** seluruh source diselaraskan ke `Copyright 2026, Om J.`
  (`https://t.me/HZFXI`).

### Notes

- Ditulis dalam **MQL5**; tidak ada test otomatis — verifikasi utama adalah
  **compile 0 error/warning** + smoke test manual di chart.
- Binary hasil compile (`*.ex5`) tidak di-track git.

[1.1.0]: https://github.com/ardani17/Tools-Palet/releases/tag/v1.1.0
[1.0.0]: https://github.com/ardani17/Tools-Palet/releases/tag/v1.0.0
