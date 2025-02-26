import 'package:flutter/material.dart';
import 'package:demode/backend/services/auth_service.dart';
import 'package:demode/frontend/widgets/social_login_button.dart';
import 'package:demode/frontend/screens/instagram_screen.dart';
import 'package:demode/frontend/screens/signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  final _authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final success = await _authService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (success) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => InstagramScreen(),
          ),
        );
      } else {
        _showError('이메일 또는 비밀번호가 올바르지 않습니다.');
      }
    } catch (e) {
      if (!mounted) return;
      _showError('로그인 중 오류가 발생했습니다.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.shopping_bag,
                  size: 100,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 50),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: '이메일',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '이메일을 입력하세요';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: '비밀번호',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '비밀번호를 입력하세요';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('로그인'),
                ),
                const SizedBox(height: 20),
                const Text(
                  '또는',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),
                SocialLoginButton(
                  text: '네이버로 시작하기',
                  backgroundColor: const Color(0xFF03C75A),
                  onPressed: () => _handleSocialLogin('naver'),
                  icon: 'assets/icons/naver_icon.png',
                ),
                const SizedBox(height: 10),
                SocialLoginButton(
                  text: '카카오로 시작하기',
                  backgroundColor: const Color(0xFFFEE500),
                  textColor: Colors.black87,
                  onPressed: () => _handleSocialLogin('kakao'),
                  icon: 'assets/icons/kakao_icon.png',
                ),
                const SizedBox(height: 10),
                SocialLoginButton(
                  text: 'Google로 시작하기',
                  backgroundColor: Colors.white,
                  textColor: Colors.black87,
                  onPressed: () => _handleSocialLogin('google'),
                  icon: 'assets/icons/google_icon.png',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSocialLogin(String provider) async {
    // 소셜 로그인 구현
  }
}