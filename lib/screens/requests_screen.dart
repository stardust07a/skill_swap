import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../db/database_helper.dart';
import '../models/request.dart';
import '../models/user.dart';
import '../widgets/app_bottom_nav.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  List<SwapRequest> _requests = [];
  Map<int, User> _userCache = {};
  bool _loading = true;
  int? _currentUserId;
  int _tabIndex = 0; // 0=Gelen, 1=Giden

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUserId = prefs.getInt('userId');
    if (_currentUserId == null) return;
    final reqs = await DatabaseHelper.instance.getRequestsForUser(_currentUserId!);
    final cache = <int, User>{};
    for (final r in reqs) {
      if (!cache.containsKey(r.gonderenId)) {
        final u = await DatabaseHelper.instance.getUserById(r.gonderenId);
        if (u != null) cache[r.gonderenId] = u;
      }
      if (!cache.containsKey(r.aliciId)) {
        final u = await DatabaseHelper.instance.getUserById(r.aliciId);
        if (u != null) cache[r.aliciId] = u;
      }
    }
    setState(() {
      _requests = reqs;
      _userCache = cache;
      _loading = false;
    });
  }

  Future<void> _updateStatus(int reqId, String status) async {
    await DatabaseHelper.instance.updateRequestStatus(reqId, status);
    await _load();
    if (mounted) {
      final msg = status == 'kabul' ? 'Talep kabul edildi!' : 'Talep reddedildi.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: status == 'kabul' ? Colors.green : const Color(0xFFFF6B6B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _onNavTap(int i) {
    if (i == 0) Navigator.pushReplacementNamed(context, '/dashboard');
    else if (i == 1) Navigator.pushReplacementNamed(context, '/matches');
    else if (i == 2) Navigator.pushReplacementNamed(context, '/messages');
    else if (i == 3) {}
    else if (i == 4) Navigator.pushNamed(context, '/profile-edit');
  }

  @override
  Widget build(BuildContext context) {
    final gelen = _requests.where((r) => r.aliciId == _currentUserId).toList();
    final giden = _requests.where((r) => r.gonderenId == _currentUserId).toList();
    final shown = _tabIndex == 0 ? gelen : giden;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Talepler'),
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _tabBtn('Gelen (${gelen.length})', 0),
                _tabBtn('Giden (${giden.length})', 1),
              ],
            ),
          ),
        ),
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
            : shown.isEmpty
                ? _emptyState()
                : RefreshIndicator(
                    onRefresh: _load,
                    color: const Color(0xFF8B5CF6),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: shown.length,
                      itemBuilder: (ctx, i) => _reqCard(shown[i]),
                    ),
                  ),
      ),
      bottomNavigationBar: AppBottomNav(currentIndex: 3, onTap: _onNavTap),
    );
  }

  Widget _tabBtn(String text, int index) {
    final active = _tabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            gradient: active
                ? const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)])
                : null,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: active ? Colors.white : Colors.white38,
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _reqCard(SwapRequest req) {
    final isGelen = req.aliciId == _currentUserId;
    final otherId = isGelen ? req.gonderenId : req.aliciId;
    final other = _userCache[otherId];
    final tipColor = req.tip == 'takas' ? const Color(0xFF8B5CF6) : const Color(0xFFEC4899);
    final durumColor = req.durum == 'kabul'
        ? Colors.green
        : req.durum == 'red'
            ? const Color(0xFFFF6B6B)
            : const Color(0xFFFBBF24);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [tipColor.withOpacity(0.7), tipColor]),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    other?.ad.isNotEmpty == true ? other!.ad[0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(other?.ad ?? 'Bilinmiyor', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(other?.sehir ?? '', style: const TextStyle(color: Colors.white38, fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: tipColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(req.tip == 'takas' ? 'Takas' : 'Ücretli', style: TextStyle(color: tipColor, fontSize: 11)),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: durumColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      req.durum == 'kabul' ? 'Kabul' : req.durum == 'red' ? 'Red' : 'Bekliyor',
                      style: TextStyle(color: durumColor, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (req.mesaj.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(req.mesaj, style: const TextStyle(color: Colors.white60, fontSize: 13)),
            ),
          ],
          // Gelen + bekliyor ise butonlar göster
          if (isGelen && req.durum == 'bekliyor') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _updateStatus(req.id!, 'kabul'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.withOpacity(0.2),
                      foregroundColor: Colors.green,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Kabul Et'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _updateStatus(req.id!, 'red'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B6B).withOpacity(0.15),
                      foregroundColor: const Color(0xFFFF6B6B),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Reddet'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.swap_horiz_rounded, color: Colors.white24, size: 60),
          const SizedBox(height: 16),
          Text(_tabIndex == 0 ? 'Gelen talep yok' : 'Gönderilen talep yok',
              style: const TextStyle(color: Colors.white54, fontSize: 16)),
        ],
      ),
    );
  }
}
