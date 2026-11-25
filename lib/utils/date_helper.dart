class DateHelper {
  /// Menghitung jumlah hari pada bulan dan tahun tertentu.
  static int jumlahHariDalamBulan(int tahun, int bulan) {
    // Tanggal 0 dari bulan berikutnya = tanggal terakhir bulan ini
    return DateTime(tahun, bulan + 1, 0).day;
  }

  /// Menyesuaikan tanggal target (1-31) agar otomatis mundur ke tanggal
  /// terakhir jika bulan tersebut jumlah harinya lebih sedikit.
  static DateTime tanggalRutinitasBulanan({
    required int tahun,
    required int bulan,
    required int tanggalTarget,
    int jam = 8,
    int menit = 0,
  }) {
    final validTarget = tanggalTarget.clamp(1, 31);
    final maxHari = jumlahHariDalamBulan(tahun, bulan);
    final hariAman = validTarget > maxHari ? maxHari : validTarget;
    return DateTime(tahun, bulan, hariAman, jam, menit);
  }

  /// Menghasilkan daftar jadwal notifikasi pagi (H-1 dan Hari-H) untuk tugas kuliah.
  /// Melewati notifikasi H-1 jika jadwalnya sudah terlewat dari [sekarang].
  static List<DateTime> jadwalNotifTugas({
    required DateTime tenggatWaktu,
    int jamPagi = 7,
    int menitPagi = 0,
    DateTime? sekarang,
  }) {
    final now = sekarang ?? DateTime.now();
    final hasil = <DateTime>[];

    final notifH1 = DateTime(
      tenggatWaktu.year,
      tenggatWaktu.month,
      tenggatWaktu.day - 1,
      jamPagi,
      menitPagi,
    );

    final notifHariH = DateTime(
      tenggatWaktu.year,
      tenggatWaktu.month,
      tenggatWaktu.day,
      jamPagi,
      menitPagi,
    );

    if (notifH1.isAfter(now)) {
      hasil.add(notifH1);
    }
    if (notifHariH.isAfter(now)) {
      hasil.add(notifHariH);
    }

    return hasil;
  }

  /// Validasi input rutinitas bulanan. Mengembalikan pesan error jika tidak valid.
  static String? validasiRutinitas({
    required String namaKegiatan,
    required int tanggalTarget,
  }) {
    if (namaKegiatan.trim().isEmpty) {
      return 'Nama kegiatan rutinitas tidak boleh kosong.';
    }
    if (tanggalTarget < 1 || tanggalTarget > 31) {
      return 'Tanggal target harus antara 1 sampai 31.';
    }
    return null;
  }

  /// Validasi input tugas kuliah. Mengembalikan pesan error jika tidak valid.
  static String? validasiTugas({
    required String mataKuliah,
    required String judulTugas,
    required DateTime tenggatWaktu,
    DateTime? sekarang,
  }) {
    final now = sekarang ?? DateTime.now();
    if (mataKuliah.trim().isEmpty) {
      return 'Nama mata kuliah tidak boleh kosong.';
    }
    if (judulTugas.trim().isEmpty) {
      return 'Judul tugas tidak boleh kosong.';
    }
    if (!tenggatWaktu.isAfter(now)) {
      return 'Tenggat waktu harus setelah waktu saat ini.';
    }
    return null;
  }
}
