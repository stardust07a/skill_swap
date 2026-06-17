import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../db/database_helper.dart';
import '../models/skill.dart';
import '../widgets/gradient_button.dart';

class SkillAddScreen extends StatefulWidget {
  const SkillAddScreen({super.key});

  @override
  State<SkillAddScreen> createState() => _SkillAddScreenState();
}

class _SkillAddScreenState extends State<SkillAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _beceriCtrl = TextEditingController();
  String _tip = 'ogretir';
  List<Skill> _skills = [];
  bool _loading = true;
  bool _saving = false;
  int? _userId;

  final List<String> _onerilenBeceriler = [
    'Kod', 'React', 'Flutter', 'Python', 'JavaScript',
    'Gitar', 'Piyano', 'Müzik', 'Resim', 'Fotoğraf',
    'İngilizce', 'Almanca', 'Fransızca', 'İspanyolca',
    'Yoga', 'Pilates', 'Dans', 'Spor', 'Satranç', 'Aşçılık',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getInt('userId');
    if (_userId == null) return;
    final skills = await DatabaseHelper.instance.getSkillsByUser(_userId!);
    setState(() {
      _skills = skills;
      _loading = false;
    });
  }

  Future<void> _add() async {
    if (!_formKey.currentState!.validate()) return;
    if (_userId == null) return;
    setState(() => _saving = true);
    final skill = Skill(
      userId: _userId!,
      beceriAdi: _beceriCtrl.text.trim(),
      tip: _tip,
    );
    await DatabaseHelper.instance.insertSkill(skill);
    _beceriCtrl.clear();
    await _load();
    setState(() => _saving = false);
  }

  Future<void> _delete(int skillId) async {
    await DatabaseHelper.instance.deleteSkill(skillId);
    await _load();
  }

  @override
  void dispose() {
    _beceriCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: Color(0xFF8B5CF6))));
    }

    final teachSkills = _skills.where((s) => s.tip == 'ogretir').toList();
    final learnSkills = _skills.where((s) => s.tip == 'ogrenir').toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Beceri Yönetimi')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A0612), Color(0xFF130D24)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Beceri ekleme formu
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Yeni Beceri Ekle',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _beceriCtrl,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Beceri Adı',
                          hintText: 'örn. Gitar, React...',
                          prefixIcon: Icon(Icons.psychology_rounded, color: Color(0xFF8B5CF6)),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Beceri adı zorunludur';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      // Tip seçimi
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _tip = 'ogretir'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  gradient: _tip == 'ogretir'
                                      ? const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)])
                                      : null,
                                  color: _tip == 'ogretir' ? null : Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _tip == 'ogretir'
                                        ? Colors.transparent
                                        : Colors.white.withOpacity(0.15),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.school_rounded, size: 18, color: Colors.white),
                                    const SizedBox(width: 6),
                                    const Text('Öğretirim', style: TextStyle(color: Colors.white, fontSize: 13)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _tip = 'ogrenir'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  gradient: _tip == 'ogrenir'
                                      ? const LinearGradient(colors: [Color(0xFFEC4899), Color(0xFFBE185D)])
                                      : null,
                                  color: _tip == 'ogrenir' ? null : Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _tip == 'ogrenir'
                                        ? Colors.transparent
                                        : Colors.white.withOpacity(0.15),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.auto_stories_rounded, size: 18, color: Colors.white),
                                    const SizedBox(width: 6),
                                    const Text('Öğrenirim', style: TextStyle(color: Colors.white, fontSize: 13)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      GradientButton(text: 'Ekle', onPressed: _add, isLoading: _saving),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Önerilen beceriler
              const Text('Popüler Beceriler', style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _onerilenBeceriler
                    .map((b) => GestureDetector(
                          onTap: () => _beceriCtrl.text = b,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withOpacity(0.12)),
                            ),
                            child: Text(b, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 24),
              // Mevcut beceriler
              if (_skills.isNotEmpty) ...[
                const Text('Mevcut Becerilerim', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                if (teachSkills.isNotEmpty) ...[
                  _skillGroup('Öğretirim', teachSkills, const Color(0xFF8B5CF6)),
                  const SizedBox(height: 12),
                ],
                if (learnSkills.isNotEmpty)
                  _skillGroup('Öğrenirim', learnSkills, const Color(0xFFEC4899)),
              ],
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _skillGroup(String title, List<Skill> skills, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 8),
        ...skills.map((s) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(Icons.circle, color: color, size: 8),
              const SizedBox(width: 12),
              Expanded(child: Text(s.beceriAdi, style: const TextStyle(color: Colors.white, fontSize: 14))),
              IconButton(
                onPressed: () => _delete(s.id!),
                icon: const Icon(Icons.delete_outline, color: Colors.white38, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        )),
      ],
    );
  }
}
