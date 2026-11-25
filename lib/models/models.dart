enum PrioritasTugas {
  tinggi,
  sedang,
  rendah,
}

class TugasKuliah {
  final String id;
  final String mataKuliah;
  final String judulTugas;
  final DateTime tenggatWaktu;
  final PrioritasTugas prioritas;
  bool selesai;

  TugasKuliah({
    required this.id,
    required this.mataKuliah,
    required this.judulTugas,
    required this.tenggatWaktu,
    required this.prioritas,
    this.selesai = false,
  });
}

class RutinitasBulanan {
  final String id;
  final String namaKegiatan;
  final int tanggalTarget;
  final int jamNotif;
  final int menitNotif;
  bool aktif;

  RutinitasBulanan({
    required this.id,
    required this.namaKegiatan,
    required this.tanggalTarget,
    required this.jamNotif,
    required this.menitNotif,
    this.aktif = true,
  });
}
