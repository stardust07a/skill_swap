import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../db/database_helper.dart';
import '../models/review.dart';
import '../models/user.dart';
import '../widgets/gradient_button.dart';
import '../widgets/app_bottom_nav.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  List<Review> _reviews = [];
  Map<int, User> _userCache = {};
  bool _loading = true;
  int? _currentUserId;
  double _avgRating = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUserId = prefs.getInt('userId');
    if (_currentUserId == null) return;
    final reviews = await DatabaseHelper.instance.getReviewsForUser(_currentUserId!);
    final avg = await DatabaseHelper.instance.getAverageRating(_currentUserId!);
    final cache = <int, User>{};
    for (final r in reviews) {
      if (!cache.containsKey(r.yazanId)) {
        final u = await DatabaseHelper.instance.getUserById(r.yazanId);
        if (u != null) cache[r.yazanId] = u;
      }
    }
    setState(() {
      _reviews = reviews;
      _userCache = cache;
      _avgRating = avg;
      _loading = false;
    });
  }

  void _showAddReviewSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF130D24),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => _AddReviewSheet(
        currentUserId: _currentUserId!,
        onSaved: _load,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yorumlar'),
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
            : RefreshIndicator(
                onRefresh: _load,
                color: const Color(0xFF8B5CF6),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ortalama puan kartı
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star_rounded, color: Color(0xFFFBBF24), size: 40),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _avgRating > 0 ? _avgRating.toStringAsFixed(1) : '—',
                                  style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '${_reviews.length} yorum',
                                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Yorum ekle butonu
                      GradientButton(
                        text: 'Birine Yorum Yap',
                        onPressed: _showAddReviewSheet,
                        colors: [const Color(0xFF8B5CF6), const Color(0xFFEC4899)],
                      ),
                      const SizedBox(height: 20),
                      if (_reviews.isEmpty)
                        Center(
                          child: Column(
                            children: [
                              const SizedBox(height: 40),
                              const Icon(Icons.star_border_rounded, color: Colors.white24, size: 60),
                              const SizedBox(height: 12),
                              const Text('Henüz yorum yok', style: TextStyle(color: Colors.white54, fontSize: 16)),
                            ],
                          ),
                        )
                      else ...[
                        const Text('Gelen Yorumlar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 12),
                        ..._reviews.map((r) => _reviewCard(r)),
                      ],
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _reviewCard(Review review) {
    final yazan = _userCache[review.yazanId];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)]),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    yazan?.ad.isNotEmpty == true ? yazan!.ad[0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(yazan?.ad ?? 'Bilinmiyor', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    Icons.star_rounded,
                    size: 16,
                    color: i < review.puan ? const Color(0xFFFBBF24) : Colors.white12,
                  ),
                ),
              ),
            ],
          ),
          if (review.yorum.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(review.yorum, style: const TextStyle(color: Colors.white70, fontSize: 14)),
          ],
          const SizedBox(height: 6),
          Text(
            review.tarih.length >= 10 ? review.tarih.substring(0, 10) : review.tarih,
            style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _AddReviewSheet extends StatefulWidget {
  final int currentUserId;
  final VoidCallback onSaved;
  const _AddReviewSheet({required this.currentUserId, required this.onSaved});

  @override
  State<_AddReviewSheet> createState() => _AddReviewSheetState();
}

class _AddReviewSheetState extends State<_AddReviewSheet> {
  final _yorumCtrl = TextEditingController();
  int _puan = 5;
  int? _selectedUserId;
  List<User> _users = [];
  bool _saving = false;
  String? _hata;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final all = await DatabaseHelper.instance.getAllUsers();
    setState(() {
      _users = all.where((u) => u.id != widget.currentUserId && !u.isAdmin).toList();
    });
  }

  Future<void> _save() async {
    if (_selectedUserId == null) {
      setState(() => _hata = 'Lütfen bir kullanıcı seçin');
      return;
    }
    setState(() { _saving = true; _hata = null; });
    final already = await DatabaseHelper.instance.hasReviewed(widget.currentUserId, _selectedUserId!);
    if (already) {
      setState(() { _saving = false; _hata = 'Bu kullanıcıya zaten yorum yaptınız'; });
      return;
    }
    await DatabaseHelper.instance.insertReview(Review(
      yazanId: widget.currentUserId,
      hedefId: _selectedUserId!,
      puan: _puan,
      yorum: _yorumCtrl.text.trim(),
      tarih: DateTime.now().toIso8601String(),
    ));
    widget.onSaved();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(width: 40, height: 4, decoration: BoxDecoration(
              color: Colors.white24, borderRadius: BorderRadius.circular(2),
            )),
          ),
          const SizedBox(height: 16),
          const Text('Yorum Yap', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 16),
          if (_hata != null)
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B6B).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFF6B6B).withOpacity(0.3)),
              ),
              child: Text(_hata!, style: const TextStyle(color: Color(0xFFFF6B6B), fontSize: 13)),
            ),
          DropdownButtonFormField<int>(
            value: _selectedUserId,
            hint: const Text('Kullanıcı seç', style: TextStyle(color: Colors.white38)),
            dropdownColor: const Color(0xFF1A0B2E),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withOpacity(0.07),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            items: _users.map((u) => DropdownMenuItem(value: u.id, child: Text(u.ad))).toList(),
            onChanged: (v) => setState(() => _selectedUserId = v),
          ),
          const SizedBox(height: 14),
          // Yıldız seçimi
          Row(
            children: [
              const Text('Puan:', style: TextStyle(color: Colors.white70)),
              const SizedBox(width: 12),
              ...List.generate(5, (i) => GestureDetector(
                onTap: () => setState(() => _puan = i + 1),
                child: Icon(
                  Icons.star_rounded,
                  size: 30,
                  color: i < _puan ? const Color(0xFFFBBF24) : Colors.white12,
                ),
              )),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _yorumCtrl,
            maxLines: 3,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Yorumunu yaz (isteğe bağlı)...',
              hintStyle: const TextStyle(color: Colors.white30),
              filled: true,
              fillColor: Colors.white.withOpacity(0.07),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 20),
          GradientButton(text: 'Yorum Yap', onPressed: _save, isLoading: _saving),
        ],
      ),
    );
  }
}
