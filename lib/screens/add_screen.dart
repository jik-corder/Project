import 'package:flutter/material.dart';
import '../models/models.dart';
import '../utils/app_theme.dart';
import '../utils/date_helper.dart';

class AddScreen extends StatefulWidget {
  final TugasKuliah? tugasToEdit;

  const AddScreen({super.key, this.tugasToEdit});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  // 0 = Tugas kuliah, 1 = Rutinitas bulanan
  int _modeForm = 0;

  // State form Tugas kuliah
  late final TextEditingController _matkulController;
  late final TextEditingController _judulTugasController;
  late DateTime _tanggalTenggat;
  late TimeOfDay _jamTenggat;
  late PrioritasTugas _prioritas;

  // State form Rutinitas bulanan
  final TextEditingController _namaRutinitasController = TextEditingController();
  int _tanggalTarget = 31;

  // Pengaturan notifikasi (H-1 & Hari-H)
  bool _notifH1 = true;
  bool _notifHariH = true;
  TimeOfDay _jamNotif = const TimeOfDay(hour: 7, minute: 0);

  String? _pesanError;

  bool get _sedangEditTugas => widget.tugasToEdit != null;

  @override
  void initState() {
    super.initState();
    final edit = widget.tugasToEdit;
    _matkulController = TextEditingController(text: edit?.mataKuliah ?? '');
    _judulTugasController = TextEditingController(text: edit?.judulTugas ?? '');

    if (edit != null) {
      _modeForm = 0;
      _tanggalTenggat = DateTime(
        edit.tenggatWaktu.year,
        edit.tenggatWaktu.month,
        edit.tenggatWaktu.day,
      );
      _jamTenggat = TimeOfDay(
        hour: edit.tenggatWaktu.hour,
        minute: edit.tenggatWaktu.minute,
      );
      _prioritas = edit.prioritas;
    } else {
      _tanggalTenggat = DateTime.now().add(const Duration(days: 1));
      _jamTenggat = const TimeOfDay(hour: 23, minute: 59);
      _prioritas = PrioritasTugas.sedang;
    }
  }

  @override
  void dispose() {
    _matkulController.dispose();
    _judulTugasController.dispose();
    _namaRutinitasController.dispose();
    super.dispose();
  }

  String _formatJam(TimeOfDay waktu) {
    final j = waktu.hour.toString().padLeft(2, '0');
    final m = waktu.minute.toString().padLeft(2, '0');
    return '$j.$m WIB';
  }

  String _formatTanggal(DateTime tgl) {
    const namaBulan = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${tgl.day} ${namaBulan[tgl.month - 1]} ${tgl.year}';
  }

  Future<void> _pilihTanggalTenggat() async {
    final sekarang = DateTime.now();
    final hariIni = DateTime(sekarang.year, sekarang.month, sekarang.day);
    final firstDate = _tanggalTenggat.isBefore(hariIni) ? _tanggalTenggat : hariIni;
    final initialDate = _tanggalTenggat.isBefore(firstDate)
        ? firstDate
        : _tanggalTenggat;

    final dipilih = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime(sekarang.year + 3),
    );
    if (dipilih != null) {
      setState(() {
        _tanggalTenggat = dipilih;
        _pesanError = null;
      });
    }
  }

  Future<void> _pilihJamTenggat() async {
    final dipilih = await showTimePicker(
      context: context,
      initialTime: _jamTenggat,
    );
    if (dipilih != null) {
      setState(() {
        _jamTenggat = dipilih;
        _pesanError = null;
      });
    }
  }

  Future<void> _pilihJamNotif() async {
    final dipilih = await showTimePicker(
      context: context,
      initialTime: _jamNotif,
    );
    if (dipilih != null) {
      setState(() {
        _jamNotif = dipilih;
      });
    }
  }

  void _simpanTugas() {
    final tenggatGabungan = DateTime(
      _tanggalTenggat.year,
      _tanggalTenggat.month,
      _tanggalTenggat.day,
      _jamTenggat.hour,
      _jamTenggat.minute,
    );

    final error = DateHelper.validasiTugas(
      mataKuliah: _matkulController.text,
      judulTugas: _judulTugasController.text,
      tenggatWaktu: tenggatGabungan,
    );

    if (error != null) {
      setState(() => _pesanError = error);
      return;
    }

    final edit = widget.tugasToEdit;
    final tugasHasil = TugasKuliah(
      id: edit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      mataKuliah: _matkulController.text.trim().toUpperCase(),
      judulTugas: _judulTugasController.text.trim(),
      tenggatWaktu: tenggatGabungan,
      prioritas: _prioritas,
      selesai: edit?.selesai ?? false,
    );

    Navigator.pop(context, tugasHasil);
  }

  void _simpanRutinitas() {
    final error = DateHelper.validasiRutinitas(
      namaKegiatan: _namaRutinitasController.text,
      tanggalTarget: _tanggalTarget,
    );

    if (error != null) {
      setState(() => _pesanError = error);
      return;
    }

    final rutinitasBaru = RutinitasBulanan(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      namaKegiatan: _namaRutinitasController.text.trim(),
      tanggalTarget: _tanggalTarget,
      jamNotif: _jamNotif.hour,
      menitNotif: _jamNotif.minute,
      aktif: true,
    );

    Navigator.pop(context, rutinitasBaru);
  }

  @override
  Widget build(BuildContext context) {
    final sekarang = DateTime.now();
    final tanggalEfektifBulanIni = DateHelper.tanggalRutinitasBulanan(
      tahun: sekarang.year,
      bulan: sekarang.month,
      tanggalTarget: _tanggalTarget,
      jam: _jamNotif.hour,
      menit: _jamNotif.minute,
    );
    final akanMundur = tanggalEfektifBulanIni.day != _tanggalTarget;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _sedangEditTugas && _modeForm == 0 ? 'Edit tugas kuliah' : 'Tambah baru',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            // Switcher Tugas kuliah / Rutinitas bulanan
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.permukaanKartu,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.garisBatas),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _ModeTabButton(
                      label: 'Tugas kuliah',
                      aktif: _modeForm == 0,
                      onTap: () => setState(() {
                        _modeForm = 0;
                        _pesanError = null;
                      }),
                    ),
                  ),
                  Expanded(
                    child: _ModeTabButton(
                      label: 'Rutinitas bulanan',
                      aktif: _modeForm == 1,
                      onTap: () => setState(() {
                        _modeForm = 1;
                        _pesanError = null;
                      }),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            if (_modeForm == 0) ...[
              Text(
                _sedangEditTugas ? 'Edit tugas kuliah' : 'Tugas kuliah baru',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.teksUtama,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _sedangEditTugas
                    ? 'Perbarui detail tugas jika ada salah input atau perubahan.'
                    : 'Catat tugasnya sekarang, fokus mengerjakannya nanti.',
                style: const TextStyle(fontSize: 13, color: AppTheme.teksSekunder),
              ),
              const SizedBox(height: 20),

              const _LabelField('Mata kuliah *'),
              TextField(
                controller: _matkulController,
                onChanged: (_) {
                  if (_pesanError != null) setState(() => _pesanError = null);
                },
                decoration: const InputDecoration(
                  hintText: 'Contoh: Desain Antarmuka',
                ),
              ),
              const SizedBox(height: 16),

              const _LabelField('Judul tugas *'),
              TextField(
                controller: _judulTugasController,
                onChanged: (_) {
                  if (_pesanError != null) setState(() => _pesanError = null);
                },
                decoration: const InputDecoration(
                  hintText: 'Apa yang perlu kamu kerjakan?',
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _LabelField('Tanggal tenggat *'),
                        InkWell(
                          onTap: _pilihTanggalTenggat,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.permukaanElevasi,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.garisBatas),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatTanggal(_tanggalTenggat),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.teksUtama,
                                  ),
                                ),
                                const Icon(
                                  Icons.calendar_today_outlined,
                                  size: 16,
                                  color: AppTheme.softBlue,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _LabelField('Jam tenggat *'),
                        InkWell(
                          onTap: _pilihJamTenggat,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.permukaanElevasi,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.garisBatas),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatJam(_jamTenggat),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.teksUtama,
                                  ),
                                ),
                                const Icon(
                                  Icons.access_time_rounded,
                                  size: 16,
                                  color: AppTheme.softBlue,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              const _LabelField('Prioritas'),
              Row(
                children: [
                  _PrioritasPill(
                    label: 'Tinggi',
                    aktif: _prioritas == PrioritasTugas.tinggi,
                    onTap: () =>
                        setState(() => _prioritas = PrioritasTugas.tinggi),
                  ),
                  const SizedBox(width: 8),
                  _PrioritasPill(
                    label: 'Sedang',
                    aktif: _prioritas == PrioritasTugas.sedang,
                    onTap: () =>
                        setState(() => _prioritas = PrioritasTugas.sedang),
                  ),
                  const SizedBox(width: 8),
                  _PrioritasPill(
                    label: 'Rendah',
                    aktif: _prioritas == PrioritasTugas.rendah,
                    onTap: () =>
                        setState(() => _prioritas = PrioritasTugas.rendah),
                  ),
                ],
              ),
            ] else ...[
              const Text(
                'Rutinitas bulanan baru',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.teksUtama,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Satu kali diatur, diingatkan setiap bulan.',
                style: TextStyle(fontSize: 13, color: AppTheme.teksSekunder),
              ),
              const SizedBox(height: 20),

              const _LabelField('Nama rutinitas *'),
              TextField(
                controller: _namaRutinitasController,
                onChanged: (_) {
                  if (_pesanError != null) setState(() => _pesanError = null);
                },
                decoration: const InputDecoration(
                  hintText: 'Contoh: Ganti oli motor',
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _LabelField('Ulangi'),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.permukaanElevasi,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.garisBatas),
                          ),
                          child: const Text(
                            'Setiap bulan',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.teksSekunder,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _LabelField('Tanggal target *'),
                        DropdownButtonFormField<int>(
                          initialValue: _tanggalTarget,
                          dropdownColor: AppTheme.permukaanElevasi,
                          items: List.generate(31, (i) => i + 1)
                              .map(
                                (tgl) => DropdownMenuItem<int>(
                                  value: tgl,
                                  child: Text('$tgl'),
                                ),
                              )
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _tanggalTarget = val;
                                _pesanError = null;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.permukaanKartu,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.garisBatas),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Penyesuaian akhir bulan',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.teksUtama,
                          ),
                        ),
                        Text(
                          'AKTIF',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.softBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Jika tanggal target tidak ada, gunakan hari terakhir bulan tersebut.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.teksSekunder,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.permukaanElevasi,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.garisBatas),
                      ),
                      child: Text(
                        akanMundur
                            ? '$_tanggalTarget -> ${tanggalEfektifBulanIni.day} bulan ini · otomatis mundur, lalu kembali ke tanggal $_tanggalTarget bulan berikutnya.'
                            : 'Tanggal target $_tanggalTarget tersedia di bulan ini (${_formatTanggal(tanggalEfektifBulanIni)}).',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.softBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Bagian Notifikasi H-1 & Hari-H
            const Text(
              'Notifikasi',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.teksUtama,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.permukaanKartu,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.garisBatas),
              ),
              child: Column(
                children: [
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    activeTrackColor: AppTheme.softBlue,
                    title: const Text(
                      'H-1',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.teksUtama,
                      ),
                    ),
                    subtitle: const Text(
                      'Sehari sebelum tanggal target',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.teksSekunder,
                      ),
                    ),
                    value: _notifH1,
                    onChanged: (val) => setState(() => _notifH1 = val),
                  ),
                  const Divider(color: AppTheme.garisBatas, height: 12),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    activeTrackColor: AppTheme.softBlue,
                    title: const Text(
                      'Hari-H',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.teksUtama,
                      ),
                    ),
                    subtitle: const Text(
                      'Pagi di tanggal target',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.teksSekunder,
                      ),
                    ),
                    value: _notifHariH,
                    onChanged: (val) => setState(() => _notifHariH = val),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _pilihJamNotif,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.permukaanElevasi,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.garisBatas),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Jam notifikasi',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.teksSekunder,
                            ),
                          ),
                          Text(
                            _formatJam(_jamNotif),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.teksUtama,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (_pesanError != null) ...[
              const SizedBox(height: 14),
              Text(
                _pesanError!,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFFFF6B6B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],

            const SizedBox(height: 22),

            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _modeForm == 0 ? _simpanTugas : _simpanRutinitas,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.softBlue,
                  foregroundColor: const Color(0xFF08121E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  _modeForm == 0
                      ? (_sedangEditTugas ? 'Simpan perubahan' : 'Simpan tugas')
                      : 'Simpan rutinitas',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                '* Kolom wajib diisi',
                style: TextStyle(fontSize: 12, color: AppTheme.teksSekunder),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LabelField extends StatelessWidget {
  final String teks;
  const _LabelField(this.teks);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        teks,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppTheme.teksUtama,
        ),
      ),
    );
  }
}

class _ModeTabButton extends StatelessWidget {
  final String label;
  final bool aktif;
  final VoidCallback onTap;

  const _ModeTabButton({
    required this.label,
    required this.aktif,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: aktif ? AppTheme.softBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: aktif ? const Color(0xFF08121E) : AppTheme.teksSekunder,
          ),
        ),
      ),
    );
  }
}

class _PrioritasPill extends StatelessWidget {
  final String label;
  final bool aktif;
  final VoidCallback onTap;

  const _PrioritasPill({
    required this.label,
    required this.aktif,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: aktif
                ? AppTheme.softBlue.withValues(alpha: 0.18)
                : AppTheme.permukaanKartu,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: aktif ? AppTheme.softBlue : AppTheme.garisBatas,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            aktif ? '✓ $label' : label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: aktif ? AppTheme.softBlue : AppTheme.teksSekunder,
            ),
          ),
        ),
      ),
    );
  }
}
