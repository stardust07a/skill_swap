import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../db/database_helper.dart';
import '../models/user.dart';
import '../widgets/gradient_button.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _adCtrl = TextEditingController();
  final _sehirCtrl = TextEditingController();
  final _ilceCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  User? _user;
  bool _loading = true;
  bool _saving = false;
  String? _basari;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    if (userId == null) return;
    final user = await DatabaseHelper.instance.getUserById(userId);
    if (user == null) return;
    setState(() {
      _user = user;
      _adCtrl.text = user.ad;
      _sehirCtrl.text = user.sehir;
      _ilceCtrl.text = user.ilce;
      _bioCtrl.text = user.bio;
      _loading = false;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _saving = true; _basari = null; });
    final updated = _user!.copyWith(
      ad: _adCtrl.text.trim(),
      sehir: _sehirCtrl.text.trim(),
      ilce: _ilceCtrl.text.trim(),
      bio: _bioCtrl.text.trim(),
    );
    await DatabaseHelper.instance.updateUser(updated);
    setState(() { _saving = false; _basari = 'Profil güncellendi!'; });
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _adCtrl.dispose();
    _sehirCtrl.dispose();
    _ilceCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFF8B5CF6))),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profili Düzenle'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Avatar
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8B5CF6).withOpacity(0.3),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      (_user?.ad.isNotEmpty == true) ? _user!.ad[0].toUpperCase() : '?',
                      style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _user?.email ?? '',
                style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 13),
              ),
              const SizedBox(height: 28),
              if (_basari != null)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline, color: Colors.green, size: 18),
                      const SizedBox(width: 8),
                      Text(_basari!, style: const TextStyle(color: Colors.green)),
                    ],
                  ),
                ),
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
                    children: [
                      _field(ctrl: _adCtrl, label: 'Ad Soyad', icon: Icons.person_outline,
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Zorunlu alan' : null),
                      const SizedBox(height: 14),
                      _field(ctrl: _sehirCtrl, label: 'Şehir', icon: Icons.location_city_outlined,
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Zorunlu alan' : null),
                      const SizedBox(height: 14),
                      _field(ctrl: _ilceCtrl, label: 'İlçe', icon: Icons.place_outlined,
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Zorunlu alan' : null),
                      const SizedBox(height: 14),
                      _field(ctrl: _bioCtrl, label: 'Bio', icon: Icons.edit_note_outlined, maxLines: 3),
                      const SizedBox(height: 24),
                      GradientButton(text: 'Kaydet', onPressed: _save, isLoading: _saving),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController ctrl,
    required String label,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF8B5CF6)),
      ),
    );
  }
}
