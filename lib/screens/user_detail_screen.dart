import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../db/database_helper.dart';
import '../models/user.dart';
import '../models/skill.dart';
import '../models/request.dart';
import '../widgets/gradient_button.dart';

class UserDetailScreen extends StatefulWidget {
  final int userId;
  const UserDetailScreen({super.key, required this.userId});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  User? _user;
  List<Skill> _skills = [];
  double _avgRating = 0;
  bool _loading = true;
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUserId = prefs.getInt('userId');
    final user = await DatabaseHelper.instance.getUserById(widget.userId);
    final skills = await DatabaseHelper.instance.getSkillsByUser(widget.userId);
    final avg = await DatabaseHelper.instance.getAverageRating(widget.userId);
    setState(() {
      _user = user;
      _skills = skills;
      _avgRating = avg;
      _loading = false;
    });
  }

  Future<void> _sendMessage() async {
    Navigator.pushNamed(context, '/chat', arguments: {
      'partnerId': widget.userId,
      'partnerAd': _user?.ad ?? '',
    });
  }

  Future<void> _sendRequest(String tip) async {
    if (_currentUserId == null) return;
    final now = DateTime.now().toIso8601String();
    final req = SwapRequest(
      gonderenId: _currentUserId!,
      aliciId: widget.userId,
      tip: tip,
      tarih: now,
      mesaj: tip == 'takas' ? 'Beceri takası yapalım mı?' : 'Ücretli ders almak istiyorum.',
    );
    await DatabaseHelper.instance.insertRequest(req);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${tip == "takas" ? "Takas" : "Ders"} talebi gönderildi!'),
          backgroundColor: const Color(0xFF8B5CF6),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: Color(0xFF8B5CF6))));
    }
    if (_user == null) {
      return const Scaffold(body: Center(child: Text('Kullanıcı bulunamadı', style: TextStyle(color: Colors.white))));
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
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: 180,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
                      ),
                    ),
                    Positioned(
                      bottom: -40,
                      left: 20,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF0A0612), width: 4),
                        ),
                        child: Center(
                          child: Text(
                            _user!.ad.isNotEmpty ? _user!.ad[0].toUpperCase() : '?',
                            style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_user!.ad, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded, size: 14, color: Colors.white38),
                          const SizedBox(width: 4),
                          Text('${_user!.ilce}, ${_user!.sehir}', style: const TextStyle(color: Colors.white38, fontSize: 13)),
                          const SizedBox(width: 16),
                          const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFBBF24)),
                          const SizedBox(width: 4),
                          Text(_avgRating > 0 ? _avgRating.toStringAsFixed(1) : 'Yeni', style: const TextStyle(color: Colors.white38, fontSize: 13)),
                        ],
                      ),
                      if (_user!.bio.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(_user!.bio, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14)),
                      ],
                      const SizedBox(height: 20),
                      // Aksiyon butonları
                      if (_currentUserId != widget.userId) ...[
                        Row(
                          children: [
                            Expanded(
                              child: GradientButton(
                                text: 'Mesaj Gönder',
                                onPressed: _sendMessage,
                                colors: [const Color(0xFF06B6D4), const Color(0xFF0891B2)],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _sendRequest('takas'),
                                icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                                label: const Text('Takas Teklif Et'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF8B5CF6),
                                  side: const BorderSide(color: Color(0xFF8B5CF6)),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _sendRequest('ucretli'),
                                icon: const Icon(Icons.school_rounded, size: 18),
                                label: const Text('Ders Talep Et'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFFEC4899),
                                  side: const BorderSide(color: Color(0xFFEC4899)),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                      const Divider(color: Colors.white12),
                      const SizedBox(height: 16),
                      // Beceriler
                      if (teachSkills.isNotEmpty) ...[
                        _skillSection('Öğretiyor', teachSkills, const Color(0xFF8B5CF6)),
                        const SizedBox(height: 14),
                      ],
                      if (learnSkills.isNotEmpty)
                        _skillSection('Öğrenmek İstiyor', learnSkills, const Color(0xFFEC4899)),
                      const SizedBox(height: 20),
                      // Yorumlara git
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/reviews'),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star_outline_rounded, color: Color(0xFFFBBF24)),
                              const SizedBox(width: 10),
                              const Expanded(
                                child: Text('Yorumları Gör ve Yorum Yap', style: TextStyle(color: Colors.white70)),
                              ),
                              const Icon(Icons.chevron_right_rounded, color: Colors.white38),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _skillSection(String title, List<Skill> skills, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: skills.map((s) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.25)),
            ),
            child: Text(s.beceriAdi, style: TextStyle(color: color, fontSize: 13)),
          )).toList(),
        ),
      ],
    );
  }
}
