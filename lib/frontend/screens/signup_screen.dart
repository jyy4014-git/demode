import 'package:flutter/material.dart';
import 'package:demode/frontend/widgets/social_login_button.dart';
import 'package:demode/frontend/screens/instagram_screen.dart';

class SignupScreen extends StatefulWidget {
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final SocialAuthService _socialAuthService = SocialAuthService();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('회원가입'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.shopping_bag,
              size: 100,
              color: Theme.of(context).primaryColor,
            ),
            SizedBox(height: 50),
            Text(
              '간편하게 시작하기',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            SocialLoginButton(
              text: '네이버로 시작하기',
              backgroundColor: Color(0xFF03C75A),
              onPressed: () => _handleSocialLogin(context, 'naver'),
              icon: 'assets/icons/naver_icon.png',
            ),
            SizedBox(height: 10),
            SocialLoginButton(
              text: '카카오로 시작하기',
              backgroundColor: Color(0xFFFEE500),
              textColor: Colors.black87,
              onPressed: () => _handleSocialLogin(context, 'kakao'),
              icon: 'assets/icons/kakao_icon.png',
            ),
            SizedBox(height: 10),
            SocialLoginButton(
              text: 'Google로 시작하기',
              backgroundColor: Colors.white,
              textColor: Colors.black87,
              onPressed: () => _handleSocialLogin(context, 'google'),
              icon: 'assets/icons/google_icon.png',
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSocialLogin(BuildContext context, String provider) async {
    try {
      final user = await _socialAuthService.signIn(provider);
      
      if (!mounted) return;  // State의 mounted 체크

      if (user != null) {
        if (!mounted) return;  // 추가 mounted 체크
        
        await Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => InstagramScreen(),
            settings: const RouteSettings(name: '/home'),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('로그인 중 오류가 발생했습니다.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
