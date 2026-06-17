import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../db/database_helper.dart';
import '../widgets/gradient_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _sifreCtrl = TextEditingController();
  bool _loading = false;
  bool _sifreGizli = true;
  String? _hata;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _sifreCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _hata = null;
    });
    try {
      final user = await DatabaseHelper.instance.loginUser(
        _emailCtrl.text.trim(),
        _sifreCtrl.text,
      );
      if (user == null) {
        setState(() => _hata = 'E-posta veya şifre hatalı.');
      } else {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('userId', user.id!);
        if (mounted) Navigator.pushReplacementNamed(context, '/dashboard');
      }
    } catch (e) {
      setState(() => _hata = 'Bir hata oluştu: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
                const SizedBox(height: 60),
                // Logo
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8B5CF6).withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.swap_horiz_rounded, size: 38, color: Colors.white),
                ),
                const SizedBox(height: 24),
                ShaderMask(
                  shaderCallback: (b) => const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                  ).createShader(b),
                  child: const Text(
                    'Skill Swap',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Hesabına giriş yap',
                  style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 14),
                ),
                const SizedBox(height: 40),
                // Form kartı
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
                      children: [
                        // Hata mesajı
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
                                  child: Text(
                                    _hata!,
                                    style: const TextStyle(color: Color(0xFFFF6B6B), fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        // E-posta
                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'E-posta',
                            hintText: 'ornek@mail.com',
                            prefixIcon: Icon(Icons.email_outlined, color: Color(0xFF8B5CF6)),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'E-posta zorunludur';
                            if (!v.contains('@')) return 'Geçerli bir e-posta girin';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        // Şifre
                        TextFormField(
                          controller: _sifreCtrl,
                          obscureText: _sifreGizli,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Şifre',
                            hintText: '••••••',
                            prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF8B5CF6)),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _sifreGizli ? Icons.visibility_off : Icons.visibility,
                                color: Colors.white38,
                              ),
                              onPressed: () => setState(() => _sifreGizli = !_sifreGizli),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Şifre zorunludur';
                            if (v.length < 6) return 'Şifre en az 6 karakter olmalı';
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        GradientButton(
                          text: 'Giriş Yap',
                          onPressed: _login,
                          isLoading: _loading,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Hesabın yok mu? ',
                      style: TextStyle(color: Colors.white.withOpacity(0.55)),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/register'),
                      child: const Text(
                        'Kayıt Ol',
                        style: TextStyle(
                          color: Color(0xFF8B5CF6),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Demo giriş ipucu
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF06B6D4).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF06B6D4).withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info_outline, color: Color(0xFF06B6D4), size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'Demo Hesap',
                            style: TextStyle(
                              color: const Color(0xFF06B6D4).withOpacity(0.9),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ahmet@skillswap.com / 123456',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
