import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../db/database_helper.dart';
import '../models/user.dart';
import '../widgets/app_bottom_nav.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  List<User> _partners = [];
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
    if (_currentUserId == null) return;
    final partnerIds = await DatabaseHelper.instance.getConversationPartners(_currentUserId!);
    final partners = <User>[];
    for (final id in partnerIds) {
      final u = await DatabaseHelper.instance.getUserById(id);
      if (u != null) partners.add(u);
    }
    setState(() {
      _partners = partners;
      _loading = false;
    });
  }

  void _onNavTap(int i) {
    if (i == 0) Navigator.pushReplacementNamed(context, '/dashboard');
    else if (i == 1) Navigator.pushReplacementNamed(context, '/matches');
    else if (i == 2) {}
    else if (i == 3) Navigator.pushReplacementNamed(context, '/requests');
    else if (i == 4) Navigator.pushNamed(context, '/profile-edit');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mesajlar'),
        automaticallyImplyLeading: false,
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
            : _partners.isEmpty
                ? _emptyState()
                : RefreshIndicator(
                    onRefresh: _load,
                    color: const Color(0xFF8B5CF6),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _partners.length,
                      itemBuilder: (ctx, i) => _partnerTile(_partners[i]),
                    ),
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewChatDialog(),
        backgroundColor: const Color(0xFF8B5CF6),
        child: const Icon(Icons.edit_rounded, color: Colors.white),
      ),
      bottomNavigationBar: AppBottomNav(currentIndex: 2, onTap: _onNavTap),
    );
  }

  Widget _partnerTile(User partner) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/chat', arguments: {
          'partnerId': partner.id,
          'partnerAd': partner.ad,
        }).then((_) => _load());
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  partner.ad.isNotEmpty ? partner.ad[0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(partner.ad, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text('${partner.ilce}, ${partner.sehir}', style: const TextStyle(color: Colors.white38, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white24),
          ],
        ),
      ),
    );
  }

  Future<void> _showNewChatDialog() async {
    final allUsers = await DatabaseHelper.instance.getAllUsers();
    final others = allUsers.where((u) => u.id != _currentUserId && !u.isAdmin).toList();
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF130D24),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          const Text('Yeni Mesaj', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          ...others.map((u) => ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF8B5CF6),
              child: Text(u.ad[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
            ),
            title: Text(u.ad, style: const TextStyle(color: Colors.white)),
            subtitle: Text(u.sehir, style: const TextStyle(color: Colors.white38, fontSize: 12)),
            onTap: () {
              Navigator.pop(ctx);
              Navigator.pushNamed(context, '/chat', arguments: {'partnerId': u.id, 'partnerAd': u.ad}).then((_) => _load());
            },
          )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.chat_bubble_outline, color: Colors.white24, size: 60),
          const SizedBox(height: 16),
          const Text('Henüz mesaj yok', style: TextStyle(color: Colors.white54, fontSize: 16)),
          const SizedBox(height: 8),
          Text('Eşleşmelerinden birine mesaj at!', style: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 13)),
        ],
      ),
    );
  }
}
