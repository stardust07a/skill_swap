import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../db/database_helper.dart';
import '../models/user.dart';
import '../models/skill.dart';
import '../widgets/gradient_card.dart';
import '../widgets/app_bottom_nav.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  User? _user;
  List<Skill> _skills = [];
  int _matchCount = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    if (userId == null) {
      if (mounted) Navigator.pushReplacementNamed(context, '/login');
      return;
    }
    final user = await DatabaseHelper.instance.getUserById(userId);
    final skills = await DatabaseHelper.instance.getSkillsByUser(userId);
    final matches = await DatabaseHelper.instance.getMatches(userId);
    setState(() {
      _user = user;
      _skills = skills;
      _matchCount = matches.length;
      _loading = false;
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    if (mounted) Navigator.pushReplacementNamed(context, '/login');
  }

  void _onNavTap(int i) {
    switch (i) {
      case 0:
        break;
      case 1:
        Navigator.pushNamed(context, '/matches').then((_) => _load());
        break;
      case 2:
        Navigator.pushNamed(context, '/messages').then((_) => _load());
        break;
      case 3:
        Navigator.pushNamed(context, '/requests').then((_) => _load());
        break;
      case 4:
        Navigator.pushNamed(context, '/profile-edit').then((_) => _load());
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFF8B5CF6))),
      );
    }

    final teachSkills = _skills.where((s) => s.tip == 'ogretir').toList();
    final learnSkills = _skills.where((s) => s.tip == 'ogrenir').toList();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A0612), Color(0xFF130D24)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _load,
            color: const Color(0xFF8B5CF6),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // AppBar benzeri başlık
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Merhaba, 👋',
                            style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 13),
                          ),
                          Text(
                            _user?.ad ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          if (_user?.isAdmin == true)
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.admin_panel_settings, color: Color(0xFFEC4899)),
                            ),
                          IconButton(
                            onPressed: _logout,
                            icon: const Icon(Icons.logout_rounded, color: Colors.white54),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // İstatistik kartları
                  Row(
                    children: [
                      Expanded(
                        child: _statCard(
                          icon: Icons.school_rounded,
                          label: 'Öğretirim',
                          value: '${teachSkills.length}',
                          color: const Color(0xFF8B5CF6),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _statCard(
                          icon: Icons.auto_stories_rounded,
                          label: 'Öğrenirim',
                          value: '${learnSkills.length}',
                          color: const Color(0xFFEC4899),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _statCard(
                          icon: Icons.people_alt_rounded,
                          label: 'Eşleşme',
                          value: '$_matchCount',
                          color: const Color(0xFF06B6D4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Konum kartı
                  GradientCard(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF06B6D4).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.location_on_rounded, color: Color(0xFF06B6D4)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Konumun',
                                style: TextStyle(color: Colors.white54, fontSize: 12),
                              ),
                              Text(
                                '${_user?.ilce}, ${_user?.sehir}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pushNamed(context, '/profile-edit').then((_) => _load()),
                          child: const Text('Güncelle', style: TextStyle(color: Color(0xFF8B5CF6))),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Beceri Ekle kısa yol
                  GradientCard(
                    onTap: () => Navigator.pushNamed(context, '/skill-add').then((_) => _load()),
                    gradientColors: [
                      const Color(0xFF8B5CF6).withOpacity(0.2),
                      const Color(0xFFEC4899).withOpacity(0.1),
                    ],
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.add_rounded, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Beceri Ekle',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, color: Colors.white38),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Beceri listesi
                  if (_skills.isNotEmpty) ...[
                    const Text(
                      'Becerilerim',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (teachSkills.isNotEmpty) ...[
                      _skillSection('Öğrettiğim Beceriler', teachSkills, const Color(0xFF8B5CF6)),
                      const SizedBox(height: 12),
                    ],
                    if (learnSkills.isNotEmpty)
                      _skillSection('Öğrenmek İstediklerim', learnSkills, const Color(0xFFEC4899)),
                  ] else ...[
                    GradientCard(
                      child: Column(
                        children: [
                          const Icon(Icons.lightbulb_outline, color: Colors.white38, size: 40),
                          const SizedBox(height: 12),
                          const Text(
                            'Henüz beceri eklemedin',
                            style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Eşleşme bulmak için beceri ekle',
                            style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  // Hızlı erişim
                  const Text(
                    'Hızlı Erişim',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _quickAction(
                          icon: Icons.people_rounded,
                          label: 'Eşleşmeler',
                          color: const Color(0xFF8B5CF6),
                          onTap: () => Navigator.pushNamed(context, '/matches').then((_) => _load()),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _quickAction(
                          icon: Icons.star_rounded,
                          label: 'Yorumlar',
                          color: const Color(0xFFEC4899),
                          onTap: () => Navigator.pushNamed(context, '/reviews').then((_) => _load()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(currentIndex: 0, onTap: _onNavTap),
    );
  }

  Widget _statCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
        ],
      ),
    );
  }

  Widget _skillSection(String title, List<Skill> skills, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: skills
              .map((s) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: color.withOpacity(0.3)),
                    ),
                    child: Text(s.beceriAdi, style: TextStyle(color: color, fontSize: 13)),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _quickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
