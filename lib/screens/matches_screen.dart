import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../db/database_helper.dart';
import '../models/user.dart';
import '../models/skill.dart';
import '../widgets/app_bottom_nav.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  List<Map<String, dynamic>> _matches = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    if (userId == null) return;
    final matches = await DatabaseHelper.instance.getMatches(userId);
    setState(() {
      _matches = matches;
      _loading = false;
    });
  }

  void _onNavTap(int i) {
    if (i == 0) Navigator.pushReplacementNamed(context, '/dashboard');
    else if (i == 1) {}
    else if (i == 2) Navigator.pushReplacementNamed(context, '/messages');
    else if (i == 3) Navigator.pushReplacementNamed(context, '/requests');
    else if (i == 4) Navigator.pushNamed(context, '/profile-edit');
  }

  Color _scoreColor(int score) {
    if (score >= 80) return const Color(0xFF10B981);
    if (score >= 50) return const Color(0xFF8B5CF6);
    return const Color(0xFF06B6D4);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eşleşmeler'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh_rounded)),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A0612), Color(0xFF130D24)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF8B5CF6)))
            : _matches.isEmpty
                ? _emptyState()
                : RefreshIndicator(
                    onRefresh: _load,
                    color: const Color(0xFF8B5CF6),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _matches.length,
                      itemBuilder: (ctx, i) => _matchCard(_matches[i]),
                    ),
                  ),
      ),
      bottomNavigationBar: AppBottomNav(currentIndex: 1, onTap: _onNavTap),
    );
  }

  Widget _matchCard(Map<String, dynamic> match) {
    final user = match['user'] as User;
    final score = match['score'] as int;
    final skills = match['skills'] as List<Skill>;
    final teachSkills = skills.where((s) => s.tip == 'ogretir').toList();
    final learnSkills = skills.where((s) => s.tip == 'ogrenir').toList();
    final color = _scoreColor(score);

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/user-detail', arguments: user.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Avatar
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color.withOpacity(0.8), color],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      user.ad.isNotEmpty ? user.ad[0].toUpperCase() : '?',
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.ad, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded, size: 12, color: Colors.white38),
                          const SizedBox(width: 4),
                          Text('${user.ilce}, ${user.sehir}', style: const TextStyle(color: Colors.white38, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
                // Skor
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color.withOpacity(0.3)),
                  ),
                  child: Text(
                    '%$score',
                    style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ],
            ),
            if (teachSkills.isNotEmpty || learnSkills.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(color: Colors.white12),
              const SizedBox(height: 8),
            ],
            if (teachSkills.isNotEmpty) ...[
              Text('Öğretiyor:', style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 11)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: teachSkills.take(4).map((s) => _chip(s.beceriAdi, const Color(0xFF8B5CF6))).toList(),
              ),
            ],
            if (learnSkills.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Öğrenmek istiyor:', style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 11)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: learnSkills.take(4).map((s) => _chip(s.beceriAdi, const Color(0xFFEC4899))).toList(),
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/user-detail', arguments: user.id),
                icon: const Icon(Icons.visibility_outlined, size: 16),
                label: const Text('Profile Git'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: color,
                  side: BorderSide(color: color.withOpacity(0.4)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 11)),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.people_outline, color: Colors.white24, size: 60),
          const SizedBox(height: 16),
          const Text('Henüz eşleşme bulunamadı', style: TextStyle(color: Colors.white54, fontSize: 16)),
          const SizedBox(height: 8),
          Text('Beceri ekleyerek eşleşme sayını artırabilirsin', style: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 13)),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/skill-add'),
            child: const Text('Beceri Ekle →', style: TextStyle(color: Color(0xFF8B5CF6))),
          ),
        ],
      ),
    );
  }
}
