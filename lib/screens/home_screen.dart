import 'package:flutter/material.dart';
import '../models/models.dart';
import '../utils/app_theme.dart';
import '../utils/date_helper.dart';
import 'add_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Kosong di awal; terisi setelah pengguna menginput tugas/rutinitas baru
  final List<TugasKuliah> _daftarTugas = [];
  final List<RutinitasBulanan> _daftarRutinitas = [];

  Future<void> _tampilkanPopupKonfirmasi({
    required String judulPopup,
    required String isiPesan,
  }) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.permukaanKartu,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppTheme.garisBatas),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: AppTheme.softBlue,
              size: 22,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                judulPopup,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.teksUtama,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          isiPesan,
          style: const TextStyle(
            fontSize: 13,
            color: AppTheme.teksSekunder,
            height: 1.4,
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.softBlue,
              foregroundColor: const Color(0xFF08121E),
            ),
            child: const Text(
              'Oke',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _bukaHalamanTambah() async {
    final hasil = await Navigator.push<Object?>(
      context,
      MaterialPageRoute(builder: (_) => const AddScreen()),
    );

    if (hasil is TugasKuliah) {
      setState(() => _daftarTugas.insert(0, hasil));
      await _tampilkanPopupKonfirmasi(
        judulPopup: 'Tugas kuliah ditambahkan',
        isiPesan:
            '${hasil.mataKuliah} — "${hasil.judulTugas}"\nTenggat: ${_formatTanggalPendek(hasil.tenggatWaktu)} WIB',
      );
    } else if (hasil is RutinitasBulanan) {
      setState(() => _daftarRutinitas.insert(0, hasil));
      final jam = hasil.jamNotif.toString().padLeft(2, '0');
      final menit = hasil.menitNotif.toString().padLeft(2, '0');
      await _tampilkanPopupKonfirmasi(
        judulPopup: 'Rutinitas bulanan aktif',
        isiPesan:
            '"${hasil.namaKegiatan}" dijadwalkan setiap tanggal ${hasil.tanggalTarget} pukul $jam.$menit WIB.',
      );
    }
  }

  Future<void> _editTugas(int index) async {
    final tugasLama = _daftarTugas[index];
    final hasil = await Navigator.push<Object?>(
      context,
      MaterialPageRoute(
        builder: (_) => AddScreen(tugasToEdit: tugasLama),
      ),
    );

    if (hasil is TugasKuliah) {
      setState(() => _daftarTugas[index] = hasil);
      await _tampilkanPopupKonfirmasi(
        judulPopup: 'Tugas diperbarui',
        isiPesan:
            '${hasil.mataKuliah} — "${hasil.judulTugas}"\nTenggat baru: ${_formatTanggalPendek(hasil.tenggatWaktu)} WIB',
      );
    }
  }

  Future<void> _hapusTugas(int index) async {
    final tugasTarget = _daftarTugas[index];
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.permukaanKartu,
        title: const Text(
          'Hapus tugas?',
          style: TextStyle(color: AppTheme.teksUtama),
        ),
        content: Text(
          'Hapus "${tugasTarget.judulTugas}" dari daftar tugas kuliah?',
          style: const TextStyle(color: AppTheme.teksSekunder),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFF7B7B),
              foregroundColor: const Color(0xFF08121E),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (konfirmasi == true) {
      setState(() => _daftarTugas.removeAt(index));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${tugasTarget.judulTugas}" telah dihapus.'),
          ),
        );
      }
    }
  }

  Future<void> _editRutinitas(int index) async {
    final rutinitasLama = _daftarRutinitas[index];
    final hasil = await Navigator.push<Object?>(
      context,
      MaterialPageRoute(
        builder: (_) => AddScreen(rutinitasToEdit: rutinitasLama),
      ),
    );

    if (hasil is RutinitasBulanan) {
      setState(() => _daftarRutinitas[index] = hasil);
      final jam = hasil.jamNotif.toString().padLeft(2, '0');
      final menit = hasil.menitNotif.toString().padLeft(2, '0');
      await _tampilkanPopupKonfirmasi(
        judulPopup: 'Rutinitas diperbarui',
        isiPesan:
            '"${hasil.namaKegiatan}" diperbarui menjadi setiap tanggal ${hasil.tanggalTarget} pukul $jam.$menit WIB.',
      );
    }
  }

  Future<void> _hapusRutinitas(int index) async {
    final target = _daftarRutinitas[index];
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.permukaanKartu,
        title: const Text(
          'Hapus rutinitas bulanan?',
          style: TextStyle(color: AppTheme.teksUtama),
        ),
        content: Text(
          'Hapus "${target.namaKegiatan}" dari daftar rutinitas bulanan?',
          style: const TextStyle(color: AppTheme.teksSekunder),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFF7B7B),
              foregroundColor: const Color(0xFF08121E),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (konfirmasi == true) {
      setState(() => _daftarRutinitas.removeAt(index));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Rutinitas "${target.namaKegiatan}" telah dihapus.'),
          ),
        );
      }
    }
  }

  String _formatTanggalPendek(DateTime tgl) {
    const bulan = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    final jam = tgl.hour.toString().padLeft(2, '0');
    final menit = tgl.minute.toString().padLeft(2, '0');
    return '${tgl.day} ${bulan[tgl.month - 1]} · $jam.$menit';
  }

  Color _warnaPrioritas(PrioritasTugas p) {
    switch (p) {
      case PrioritasTugas.tinggi:
        return const Color(0xFFFF7B7B);
      case PrioritasTugas.sedang:
        return AppTheme.softBlue;
      case PrioritasTugas.rendah:
        return const Color(0xFF7CE3B3);
    }
  }

  String _labelPrioritas(PrioritasTugas p) {
    switch (p) {
      case PrioritasTugas.tinggi:
        return 'Tinggi';
      case PrioritasTugas.sedang:
        return 'Sedang';
      case PrioritasTugas.rendah:
        return 'Rendah';
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalTugas = _daftarTugas.length;
    final tugasSelesai = _daftarTugas.where((t) => t.selesai).length;
    final progres = totalTugas == 0 ? 0.0 : tugasSelesai / totalTugas;
    final sekarang = DateTime.now();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 96),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.teksUtama,
                      letterSpacing: -0.5,
                    ),
                    children: [
                      TextSpan(text: 'ritme'),
                      TextSpan(
                        text: '.',
                        style: TextStyle(color: AppTheme.softBlue),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.permukaanKartu,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.garisBatas),
                  ),
                  child: Text(
                    '$tugasSelesai/$totalTugas selesai',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.softBlue,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Jaga ritme kuliah & rutinitas bulananmu tetap tenang.',
              style: TextStyle(fontSize: 13, color: AppTheme.teksSekunder),
            ),
            const SizedBox(height: 18),

            // Kartu ringkasan progres
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.permukaanKartu,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.garisBatas),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Progres tugas kuliah',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.teksUtama,
                        ),
                      ),
                      Text(
                        '${(progres * 100).round()}%',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.softBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progres,
                      minHeight: 8,
                      backgroundColor: AppTheme.permukaanElevasi,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppTheme.softBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Bagian Tugas Kuliah
            const Text(
              'Tugas kuliah',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppTheme.teksUtama,
              ),
            ),
            const SizedBox(height: 10),
            if (_daftarTugas.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.permukaanKartu,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.garisBatas),
                ),
                child: Column(
                  children: const [
                    Text(
                      'Belum ada tugas kuliah',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.teksUtama,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Daftar tugas kuliah masih kosong. Tekan "+ Tambah baru" di kanan bawah untuk mencatat tugas.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.teksSekunder,
                      ),
                    ),
                  ],
                ),
              )
            else
              ..._daftarTugas.asMap().entries.map((entry) {
                final index = entry.key;
                final tugas = entry.value;
                final warnaPrio = _warnaPrioritas(tugas.prioritas);

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.permukaanKartu,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.garisBatas),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: GestureDetector(
                          onTap: () {
                            setState(() => tugas.selesai = !tugas.selesai);
                          },
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: tugas.selesai
                                  ? AppTheme.softBlue
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: tugas.selesai
                                    ? AppTheme.softBlue
                                    : AppTheme.teksSekunder,
                                width: 1.6,
                              ),
                            ),
                            child: tugas.selesai
                                ? const Icon(
                                    Icons.check_rounded,
                                    size: 16,
                                    color: Color(0xFF08121E),
                                  )
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tugas.mataKuliah,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.6,
                                color: AppTheme.softBlue,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              tugas.judulTugas,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: tugas.selesai
                                    ? AppTheme.teksSekunder
                                    : AppTheme.teksUtama,
                                decoration: tugas.selesai
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              _formatTanggalPendek(tugas.tenggatWaktu),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.teksSekunder,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: warnaPrio.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _labelPrioritas(tugas.prioritas),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: warnaPrio,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                borderRadius: BorderRadius.circular(6),
                                onTap: () => _editTugas(index),
                                child: const Padding(
                                  padding: EdgeInsets.all(4),
                                  child: Icon(
                                    Icons.edit_outlined,
                                    size: 18,
                                    color: AppTheme.teksSekunder,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              InkWell(
                                borderRadius: BorderRadius.circular(6),
                                onTap: () => _hapusTugas(index),
                                child: const Padding(
                                  padding: EdgeInsets.all(4),
                                  child: Icon(
                                    Icons.delete_outline,
                                    size: 18,
                                    color: Color(0xFFFF7B7B),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),

            const SizedBox(height: 22),

            // Bagian Rutinitas Bulanan
            const Text(
              'Rutinitas bulanan',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppTheme.teksUtama,
              ),
            ),
            const SizedBox(height: 10),
            if (_daftarRutinitas.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.permukaanKartu,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.garisBatas),
                ),
                child: Column(
                  children: const [
                    Text(
                      'Belum ada rutinitas bulanan',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.teksUtama,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Daftar rutinitas bulanan masih kosong. Tekan "+ Tambah baru" lalu pilih tab Rutinitas bulanan untuk menjadwalkan.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.teksSekunder,
                      ),
                    ),
                  ],
                ),
              )
            else
              ..._daftarRutinitas.asMap().entries.map((entry) {
                final index = entry.key;
                final rutinitas = entry.value;
                final tglEfektif = DateHelper.tanggalRutinitasBulanan(
                  tahun: sekarang.year,
                  bulan: sekarang.month,
                  tanggalTarget: rutinitas.tanggalTarget,
                  jam: rutinitas.jamNotif,
                  menit: rutinitas.menitNotif,
                );
                final disesuaikan = tglEfektif.day != rutinitas.tanggalTarget;

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.permukaanKartu,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.garisBatas),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.softBlue.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${tglEfektif.day}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.softBlue,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              rutinitas.namaKegiatan,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.teksUtama,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              disesuaikan
                                  ? 'Target tgl ${rutinitas.tanggalTarget} -> tgl ${tglEfektif.day} bulan ini'
                                  : 'Setiap tanggal ${rutinitas.tanggalTarget} · ${rutinitas.jamNotif.toString().padLeft(2, '0')}.${rutinitas.menitNotif.toString().padLeft(2, '0')} WIB',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.teksSekunder,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  borderRadius: BorderRadius.circular(6),
                                  onTap: () => _editRutinitas(index),
                                  child: const Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Icon(
                                      Icons.edit_outlined,
                                      size: 18,
                                      color: AppTheme.teksSekunder,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                InkWell(
                                  borderRadius: BorderRadius.circular(6),
                                  onTap: () => _hapusRutinitas(index),
                                  child: const Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Icon(
                                      Icons.delete_outline,
                                      size: 18,
                                      color: Color(0xFFFF7B7B),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Switch.adaptive(
                        activeTrackColor: AppTheme.softBlue,
                        value: rutinitas.aktif,
                        onChanged: (val) {
                          setState(() => rutinitas.aktif = val);
                        },
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _bukaHalamanTambah,
        backgroundColor: AppTheme.softBlue,
        foregroundColor: const Color(0xFF08121E),
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Tambah baru',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
