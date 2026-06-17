import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../db/database_helper.dart';
import '../models/user.dart';
import '../widgets/gradient_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _adCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _sifreCtrl = TextEditingController();
  final _sifre2Ctrl = TextEditingController();
  final _sehirCtrl = TextEditingController();
  final _ilceCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  bool _loading = false;
  bool _sifreGizli = true;
  String? _hata;

  @override
  void dispose() {
    _adCtrl.dispose();
    _emailCtrl.dispose();
    _sifreCtrl.dispose();
    _sifre2Ctrl.dispose();
    _sehirCtrl.dispose();
    _ilceCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _hata = null;
    });
    try {
      final emailVar = await DatabaseHelper.instance.emailExists(_emailCtrl.text.trim());
      if (emailVar) {
        setState(() => _hata = 'Bu e-posta zaten kayıtlı.');
        return;
      }
      final user = User(
        ad: _adCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        sifre: _sifreCtrl.text,
        sehir: _sehirCtrl.text.trim(),
        ilce: _ilceCtrl.text.trim(),
        bio: _bioCtrl.text.trim(),
      );
      final id = await DatabaseHelper.instance.insertUser(user);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('userId', id);
      if (mounted) Navigator.pushReplacementNamed(context, '/dashboard');
    } catch (e) {
      setState(() => _hata = 'Kayıt sırasında hata: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _field({
    required TextEditingController ctrl,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboard,
    bool obscure = false,
    Widget? suffix,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: ctrl,
      obscureText: obscure,
      keyboardType: keyboard,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF8B5CF6)),
        suffixIcon: suffix,
      ),
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A0612), Color(0xFF1A0B2E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 32),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white70),
                    ),
                    const SizedBox(width: 8),
                    ShaderMask(
                      shaderCallback: (b) => const LinearGradient(
                        colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                      ).createShader(b),
                      child: const Text(
                        'Hesap Oluştur',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 48),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Skill Swap topluluğuna katıl',
                      style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_hata != null) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6B6B).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFFF6B6B).withOpacity(0.4)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline, color: Color(0xFFFF6B6B), size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(_hata!, style: const TextStyle(color: Color(0xFFFF6B6B), fontSize: 13)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        _sectionLabel('Kişisel Bilgiler'),
                        const SizedBox(height: 12),
                        _field(
                          ctrl: _adCtrl,
                          label: 'Ad Soyad',
                          hint: 'Ahmet Yılmaz',
                          icon: Icons.person_outline,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Ad soyad zorunludur';
                            if (v.trim().length < 2) return 'En az 2 karakter giriniz';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        _field(
                          ctrl: _emailCtrl,
                          label: 'E-posta',
                          hint: 'ornek@mail.com',
                          icon: Icons.email_outlined,
                          keyboard: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'E-posta zorunludur';
                            if (!v.contains('@')) return 'Geçerli bir e-posta girin';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        _field(
                          ctrl: _sifreCtrl,
                          label: 'Şifre',
                          hint: '••••••',
                          icon: Icons.lock_outline,
                          obscure: _sifreGizli,
                          suffix: IconButton(
                            icon: Icon(
                              _sifreGizli ? Icons.visibility_off : Icons.visibility,
                              color: Colors.white38,
                            ),
                            onPressed: () => setState(() => _sifreGizli = !_sifreGizli),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Şifre zorunludur';
                            if (v.length < 6) return 'En az 6 karakter olmalı';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        _field(
                          ctrl: _sifre2Ctrl,
                          label: 'Şifre Tekrar',
                          hint: '••••••',
                          icon: Icons.lock_outline,
                          obscure: _sifreGizli,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Şifre tekrarı zorunludur';
                            if (v != _sifreCtrl.text) return 'Şifreler eşleşmiyor';
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        _sectionLabel('Konum'),
                        const SizedBox(height: 12),
                        _field(
                          ctrl: _sehirCtrl,
                          label: 'Şehir',
                          hint: 'İstanbul',
                          icon: Icons.location_city_outlined,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Şehir zorunludur';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        _field(
                          ctrl: _ilceCtrl,
                          label: 'İlçe',
                          hint: 'Kadıköy',
                          icon: Icons.place_outlined,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'İlçe zorunludur';
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        _sectionLabel('Hakkımda (isteğe bağlı)'),
                        const SizedBox(height: 12),
                        _field(
                          ctrl: _bioCtrl,
                          label: 'Bio',
                          hint: 'Kendini tanıt...',
                          icon: Icons.edit_note_outlined,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 24),
                        GradientButton(
                          text: 'Kayıt Ol',
                          onPressed: _register,
                          isLoading: _loading,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Zaten hesabın var mı? ',
                      style: TextStyle(color: Colors.white.withOpacity(0.55)),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pushReplacementNamed(context, '/login'),
                      child: const Text(
                        'Giriş Yap',
                        style: TextStyle(color: Color(0xFF8B5CF6), fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF8B5CF6),
        fontWeight: FontWeight.bold,
        fontSize: 13,
        letterSpacing: 0.5,
      ),
    );
  }
}
